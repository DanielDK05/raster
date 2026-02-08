Model_ID :: #type,distinct int;
Model :: struct {
    id       : Model_ID;
    meshes   : [] Mesh;
    textures : [] Texture;
}

Mesh_ID :: #type,distinct u32;
Mesh :: struct {
    id       : Mesh_ID;
    vertices : [] Vertex;
    indices  : [] u32;
}

Vertex :: struct {
    position : v3f;
    normal   : v3f;
    uv       : v2f;
}

free :: (using mesh: Mesh) {
    array_free(vertices);
    array_free(indices);
}

read_obj_file :: (path: string, flip_uv_vertical := true, yeet_duplicates := false) -> bool, Model {
    #if OS == .ANDROID {
        Android_File :: #import "Android/File";
        file, read_success := Android_File.read_entire_file(context.android_app.activity.assetManager, path);
    } else {
        file, read_success := read_entire_file(path);
    }

    if !read_success {
        log_error("failed to read model");
        return false, .{};
    }

    temp_vertices : [..]v3;
    temp_uvs      : [..]v2;
    temp_normals  : [..]v3;
    vert_indices, uv_indices, normal_indices: [..]u32;

    texture: Texture;

    lines := split(file, "\n");

    for line: lines {
        if line == "" {
            continue;
        }

        if begins_with(line, "usemtl") {
            parts := split(line, " ");
            assert(parts.count == 2);
            // @Todo: support more than png lol
            filename := parts[1];
            if filename[filename.count-1] == "\r" then filename.count = filename.count - 1;
            texture_path := join(path_strip_filename(path), filename, ".png"); 

            success:, texture = load_texture(texture_path);
        }

        if line[0] == {
            case #char "#"; {
                continue;
            }
            case #char "v"; {
                if line[1] ==  {
                    case #char "t"; {
                        parts := split_whitespace(line);
                        assert(parts.count == 3 || parts.count == 4); // TODO: `w` param
                        x, _ := parse_float(*parts[1]);
                        y, _ := parse_float(*parts[2]);
                        array_add(*temp_uvs, .{x, y});
                        continue;
                    }
                    case #char "n"; {
                        parts := split_whitespace(line);
                        assert(parts.count == 4);
                        x, _ := parse_float(*parts[1]);
                        y, _ := parse_float(*parts[2]);
                        z, _ := parse_float(*parts[3]);
                        array_add(*temp_normals, .{x, y, z});
                        continue;
                    }
                }

                parts := split_whitespace(line);
                assert(parts.count == 4);
                x, _ := parse_float(*parts[1]);
                y, _ := parse_float(*parts[2]);
                z, _ := parse_float(*parts[3]);
                array_add(*temp_vertices, .{x, y, z});
            }
            case #char "f"; {
                parts := split_whitespace(line);

                if parts.count == {
                    case 4; {
                        for i: 1..3 {
                            inner_parts := split(parts[i], "/");

                            assert(inner_parts.count == 3);

                            array_add(*vert_indices,   parse_int(*inner_parts[0], u32));
                            array_add(*uv_indices,     parse_int(*inner_parts[1], u32));
                            array_add(*normal_indices, parse_int(*inner_parts[2], u32));
                        }
                    }
                    // Quad
                    case 5; {
                        do_the_thing :: (v_i: *[..]u32, uv_i: *[..]u32, n_i: *[..]u32, thing: []string, i: u32) {
                            inner_parts := split(thing[i], "/");

                            assert(inner_parts.count == 3);

                            array_add(v_i,  parse_int(*inner_parts[0], u32));
                            array_add(uv_i, parse_int(*inner_parts[1], u32));
                            array_add(n_i,  parse_int(*inner_parts[2], u32));
                        }

                        do_the_thing(*vert_indices, *uv_indices, *normal_indices, parts, 1);
                        do_the_thing(*vert_indices, *uv_indices, *normal_indices, parts, 2);
                        do_the_thing(*vert_indices, *uv_indices, *normal_indices, parts, 3);
                        do_the_thing(*vert_indices, *uv_indices, *normal_indices, parts, 1);
                        do_the_thing(*vert_indices, *uv_indices, *normal_indices, parts, 3);
                        do_the_thing(*vert_indices, *uv_indices, *normal_indices, parts, 4);
                    }
                }
            }
        }
    }

    vertices : [..] Vertex;
    uvs      : [..] v2;
    normals  : [..] v3;
    indices  : [..] u32;
    array_reserve(*uvs, uv_indices.count);
    array_reserve(*normals, normal_indices.count);

    unique_vertices: Table(
        Vertex, u32,
        given_compare_function = (lhs: Vertex, rhs: Vertex) -> bool { return lhs == rhs; },
        given_hash_function = get_vertex_hash
    );

    if yeet_duplicates init(*unique_vertices);

    for _, i: vert_indices {
        vertex := Vertex.{
            position = temp_vertices[vert_indices[i] - 1],
            normal   = temp_normals[normal_indices[i] - 1],
            uv = ifx flip_uv_vertical then .{
                temp_uvs[uv_indices[i] - 1].x,
                1 - temp_uvs[uv_indices[i] - 1].y,
            } else temp_uvs[uv_indices[i] - 1],
        };

        // @Todo: something wrong with this. I can't be assed to fix it right now. Hence the reason `yeet_duplicates` is false by default.
        //        It should be true by default ideally.
        if yeet_duplicates {
            found, index := table_find(*unique_vertices, vertex);
            
            if !found {
                index = xx vertices.count;
                table_set(*unique_vertices, vertex, xx index);
                array_add(*vertices, vertex);
                array_add(*uvs, temp_uvs[uv_indices[i] - 1]);
                array_add(*normals, temp_normals[normal_indices[i] - 1]);
            }

            array_add(*indices, index);
        } else {
            array_add(*vertices, vertex);
            array_add(*uvs, temp_uvs[uv_indices[i] - 1]);
            array_add(*normals, temp_normals[normal_indices[i] - 1]);
            array_add(*indices, cast(u32) vertices.count - 1);
        }
    }

    // array_reserve(*indices, vertices.count);
    // for vertices array_add(*indices, xx it_index);

    // current_model_id += 1;
    // current_mesh_id  += 1;

    mesh: Mesh;
    mesh.id       = 0;
    mesh.vertices = vertices;
    mesh.indices  = indices;

    meshes := NewArray(1, Mesh);
    meshes[0] = mesh;

    textures := NewArray(1, Texture);
    textures[0] = texture;

    return true, .{
        id       = 0,
        meshes   = meshes,
        textures = textures,
    };
}

operator == :: (lhs: Vertex, rhs: Vertex) -> bool {
    return lhs.position == rhs.position && lhs.normal == rhs.normal && lhs.uv == rhs.uv;
}

get_vertex_hash :: (using vertex: Vertex) -> u32 {
    return ((get_hash(position) ^ (get_hash(normal) << 1)) >> 1) ^ (get_hash(uv) << 1);
}

#scope_file;

split_whitespace :: (input: string) -> []string {
    split_result := split(trim(input), " ");

    result: [..]string;
    array_reserve(*result, split_result.count);

    for split_result if it != "" && it != " " array_add(*result, it);

    return result;
}
