Model_ID :: #type,distinct int;
Model :: struct {
    id      : Model_ID;
    mesh    : Mesh(u32);
    texture : Texture;
}

Mesh_ID :: #type,distinct u32;

Mesh :: struct(Index_Type := u32)
#modify {
    return Index_Type == u32 || Index_Type == u16, "Mesh Index type has to be either u16 or u32";
} {
    id       : Mesh_ID;
    vertices : [] Vertex;
    indices  : [] Index_Type;
}

Vertex :: struct {
    position : v3f;
    normal   : v3f;
    uv       : v2f;
}
operator == :: (lhs: Vertex, rhs: Vertex) -> bool {
    return lhs.position == rhs.position && lhs.normal == rhs.normal && lhs.uv == rhs.uv;
}
get_vertex_hash :: (using vertex: Vertex) -> u32 {
    return ((get_hash(position) ^ (get_hash(normal) << 1)) >> 1) ^ (get_hash(uv) << 1);
}

Draw_Call :: struct {
    model     : Model;
    cull_mode : Cull_Mode = .BACK;
    transform : Matrix4   = Matrix4_Identity;
}

Cull_Mode :: enum {
    NONE;
    FRONT;
    BACK;
}

model: Model;
transform: Transform;
t: float;

pixels: [] Color;
position: v3f;

init :: () {
    pixels = NewArray(RESOLUTION.x * RESOLUTION.y, Color);

    success:, model = read_obj_file("assets/model.obj");
    if !success return;
}

frame :: (dt: float) {
    t += dt;
    transform.rotation = quaternion_from_axis_angle(normalize(.{1, 1, 0}), t);

    log("frame: %", dt);
    // Update pixels
    {
        for * pixels it.* = COLOR_BLACK;

        // draw({
        //     model = model,
        //     transform = m4x4(transform),
        //     cull_mode = .BACK,
        // });
    }

    // rl.UpdateTexture(texture, pixels.data);

    // rl.DrawTexture(texture, 0, 0, rl.WHITE);
    // rl.DrawText(temp_c_string(tprint("FPS: %", rl.GetFPS())), 25, 25, 30, rl.WHITE);
}

draw :: (using draw_call: Draw_Call) {
    i := 0;

    projection := make_projection_matrix(60, cast(float)RESOLUTION.x / cast(float)RESOLUTION.y, 0.01, 100);
    projection.coef[1][1] *= -1;

    view := make_look_at_matrix(position, .{}, V3_UP, x_is_forward=false);

    mvp := projection * view * transform;

    mesh := model.mesh;

    while i + 2 < mesh.indices.count {
        defer i += 3;

        v0 := mesh.vertices[mesh.indices[i + 0]];
        v1 := mesh.vertices[mesh.indices[i + 1]];
        v2 := mesh.vertices[mesh.indices[i + 2]];

        p0 := V4_ONE; p0.xyz = v0.position; p0 = mvp * p0; p0 = perspective_divide(p0); p0 = screen_to_viewport(p0);
        p1 := V4_ONE; p1.xyz = v1.position; p1 = mvp * p1; p1 = perspective_divide(p1); p1 = screen_to_viewport(p1);
        p2 := V4_ONE; p2.xyz = v2.position; p2 = mvp * p2; p2 = perspective_divide(p2); p2 = screen_to_viewport(p2);

        det012 := det2d(p1 - p0, p2 - p0);
        counter_clockwise := det012 < 0;

        if cull_mode == {
            case .NONE;
            case .FRONT; if !counter_clockwise continue;
            case .BACK;  if  counter_clockwise continue;
        }

        if counter_clockwise {
            temp := p1;
            p1 = p2;
            p2 = temp;
            det012 = -det012;
        }

        min_x := min(int.[ xx floor(p0.x), xx floor(p1.x), xx floor(p2.x) ]); min_x = max(0, min_x);
        max_x := max(int.[ xx floor(p0.x), xx floor(p1.x), xx floor(p2.x) ]); max_x = min(RESOLUTION.x, max_x) - 1;
        min_y := min(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); min_y = max(0, min_y);
        max_y := max(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); max_y = min(RESOLUTION.y, max_y) - 1;

        for y: min_y..max_y - 1
        for x: min_x..max_x - 1 {
            p := v4f.{ x + 0.5, y + 0.5, 0, 0 };

            det_a := det2d(p1 - p0, p - p0);
            det_b := det2d(p2 - p1, p - p1);
            det_c := det2d(p0 - p2, p - p2);

            if det_a >= 0 && det_b >= 0 && det_c >= 0 {
                l0 := det_b / det012;
                l1 := det_c / det012;
                l2 := det_a / det012;

                // c0 := Color.{ xx (l0 * v0.color.r), xx (l0 * v0.color.g), xx (l0 * v0.color.b), v0.color.a };
                // c1 := Color.{ xx (l1 * v1.color.r), xx (l1 * v1.color.g), xx (l1 * v1.color.b), v1.color.a };
                // c2 := Color.{ xx (l2 * v2.color.r), xx (l2 * v2.color.g), xx (l2 * v2.color.b), v2.color.a };

                pixels[x + y * RESOLUTION.x] = COLOR_RED;
            }
        }
    }
}

screen_to_viewport :: (using vec: v4f) -> v4f {
    return {
        RESOLUTION.x * (0.5 + 0.5 * x),
        RESOLUTION.y * (0.5 - 0.5 * y),
        z,
        w,
    };
}

perspective_divide :: (using vec: v4f) -> v4f {
    result := vec;

    result.x /= w;
    result.y /= w;
    result.z /= w;

    return result;
}

det2d :: (v0: v4f, v1: v4f) -> float {
    return v0.x * v1.y - v0.y * v1.x;
}

read_obj_file :: (path: string, flip_uv_vertical := false, yeet_duplicates := false) -> bool, Model {
    #if OS == .ANDROID {
        Android_File :: #import "Android/File";
        file, read_success := Android_File.read_entire_file(context.android_app.activity.assetManager, path);
    } else {
        file, read_success := read_entire_file(path);
    }

    if !read_success {
        log_error("Failed to read file at path `%`", path);
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
    // mesh.id       = current_mesh_id;
    mesh.vertices = vertices;
    mesh.indices  = indices;

    return true, .{
        // id      = current_model_id,
        mesh    = mesh,
        texture = texture,
    };
}
