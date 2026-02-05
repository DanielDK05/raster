RESOLUTION :: v2i.{1280, 720};
TILE_SIZE :: 16;
TOTAL_TILES :: #run (RESOLUTION.x / TILE_SIZE) * (RESOLUTION.y / TILE_SIZE);
TITLE :: "raster";

Model_ID :: #type,distinct int;
Model :: struct {
    id       : Model_ID;
    meshes   : [] Mesh;
    // textures : [] Texture;
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
    color    : Color;
}

free :: (using mesh: Mesh) {
    array_free(vertices);
    array_free(indices);
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

FREECAM_LOOK_SENSITIVITY :: 0.005;
FREECAM_SPEED :: 4.0;

freecam_pitch     : float;
freecam_yaw       : float;
freecam_transform : Transform = {
    position.x = 2,
    position.y = 1,
    position.z = -2,
};

texture: rl.Texture2D;
pixels   : [] Color;
z_buffer : [] float;

thread_group: Thread_Group;

draw_calls: [..] Draw_Call;
tiles: [TOTAL_TILES][..] Tile_Bin;

Tile_Bin :: struct {
    triangle_start_i: int;
    draw_call_idx: int;
}

main :: () {
    open_window();
    defer close_window();

    success, model := read_obj_file("assets/model.obj");
    if !success then return;

    for * model.meshes[0].vertices  it.color = { xx (random_get_zero_to_one() * 255), xx (random_get_zero_to_one() * 255), xx (random_get_zero_to_one() * 255), 255 };

    t := 0.0;
    rotating_transform: Transform;
    rotating_transform.position = { 0.5, 0.2, 0.3 };

    while !rl.WindowShouldClose() {
        defer reset_temporary_storage();

        begin_drawing();
        defer end_drawing();

        t += rl.GetFrameTime();
        // rotating_transform.rotation = quaternion_from_axis_angle(normalize(.{1, 1, 0}), t);

        update_freecam(rl.GetFrameTime());

        draw({
            model = model,
            transform = m4x4(rotating_transform),
            cull_mode = .BACK,
        });
    }
}

open_window :: () {
    init_thread_group_stuff();

    rl.InitWindow(xx RESOLUTION.x, xx RESOLUTION.y, TITLE);

    pixels   = NewArray(RESOLUTION.x * RESOLUTION.y, Color);
    z_buffer = NewArray(RESOLUTION.x * RESOLUTION.y, float);

    image := rl.Image.{
        data = pixels.data,
        width = xx RESOLUTION.x,
        height = xx RESOLUTION.y,
        mipmaps = 1,
        format = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
    };

    texture = rl.LoadTextureFromImage(image);
}

close_window :: () {
    rl.CloseWindow();
}

begin_drawing :: () {
    rl.BeginDrawing();
    rl.ClearBackground(rl.BLACK);

    for * z_buffer it.* = FLOAT32_MAX;
    for * pixels it.* = rl.BLACK;
}

end_drawing :: () {
    tiles_across := RESOLUTION.x / TILE_SIZE;
    tiles_along  := RESOLUTION.y / TILE_SIZE;
    total_tiles  := tiles_across * tiles_along;

    for draw_calls {
        using it;
        draw_call_index := it_index;
        mesh := model.meshes[0];
        i := 0;

        // Pre-calculate MVP here so it's not done per-triangle
        projection := make_projection_matrix(60 * PI / 180.0, cast(float)RESOLUTION.x / cast(float)RESOLUTION.y, 0.01, 100);
        view := make_look_at_matrix(freecam_transform.position, freecam_transform.position + get_forward(freecam_transform), V3_UP, x_is_forward=false);
        mvp := projection * view * transform;

        while i + 2 < mesh.indices.count {
            // ... (Your vertex transformation and culling logic here) ...
            // We assume p0, p1, p2 are now in screen space
            v0 := mesh.vertices[mesh.indices[i + 0]];
            v1 := mesh.vertices[mesh.indices[i + 1]];
            v2 := mesh.vertices[mesh.indices[i + 2]];

            p0 := V4_ONE; p0.xyz = v0.position; p0 = mvp * p0; p0 = perspective_divide(p0); p0 = screen_to_viewport(p0);
            p1 := V4_ONE; p1.xyz = v1.position; p1 = mvp * p1; p1 = perspective_divide(p1); p1 = screen_to_viewport(p1);
            p2 := V4_ONE; p2.xyz = v2.position; p2 = mvp * p2; p2 = perspective_divide(p2); p2 = screen_to_viewport(p2);

            // 1. Get the screen-space bounding box of the triangle
            min_x := min(p0.x, p1.x, p2.x);
            max_x := max(p0.x, p1.x, p2.x);
            min_y := min(p0.y, p1.y, p2.y);
            max_y := max(p0.y, p1.y, p2.y);

            // 2. Convert screen-space bounds to tile-space bounds
            // We use floor and divide by TILE_SIZE to see which tile index we are in
            tile_start_x := max(0, cast(int)(min_x / TILE_SIZE));
            tile_end_x   := min(tiles_across - 1, cast(int)(max_x / TILE_SIZE));
            tile_start_y := max(0, cast(int)(min_y / TILE_SIZE));
            tile_end_y   := min(tiles_along - 1, cast(int)(max_y / TILE_SIZE));

            // 3. Add this triangle to every tile it touches
            for ty: tile_start_y..tile_end_y {
                for tx: tile_start_x..tile_end_x {
                    tile_index := tx + ty * tiles_across;

                    // Add the work to the specific tile bin
                    // Storing the triangle's starting index 'i' and which draw call it belongs to
                    array_add(*tiles[tile_index], .{ triangle_start_i = i, draw_call_idx = draw_call_index });
                }
            }

            i += 3;
        }
    }

    for 0..total_tiles-1 {
        tile_index := New(int,, temp);
        tile_index.* = it;
        add_work(*thread_group, tile_index, tprint("Work item %", it));
    }

    work_remaining := total_tiles;

    while work_remaining > 0 {
        results := get_completed_work(*thread_group);
        work_remaining -= results.count;
    }

    rl.UpdateTexture(texture, pixels.data);
    rl.DrawTexture(texture, 0, 0, rl.WHITE);
    rl.DrawText(temp_c_string(tprint("FPS: %", rl.GetFPS())), 25, 25, 30, rl.WHITE);

    rl.EndDrawing();
    draw_calls.count = 0;
    for * tiles it.count = 0;
}

init_thread_group_stuff :: () {
    num_cpus := get_number_of_processors();

    assert(num_cpus >= 1);
    if num_cpus > 200  num_cpus = 200; // Clamp to a value that is reasonable as of 2025, in case we get weird data.

    #if (OS == .WINDOWS) || (OS == .LINUX) {
        // This routine reports hyperthreads, so, divide by two, because of Intel marketing.
        num_cpus /= 2;
    }

    num_threads := max(num_cpus - 1, 2);

    log("This machine reports % CPUs; starting % threads.\n", num_cpus, num_threads);

    init(*thread_group, num_threads, thread_group_proc);

    thread_group.name    = "Raster Thread Group";
    thread_group.logging = false;

    start(*thread_group);
}

thread_group_proc :: (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status {
    tile_index := cast(*int) work;

    draw_tile(tile_index.*);

    return .CONTINUE;
}

update_freecam :: (dt: float) {
    // Rotation
    if rl.IsMouseButtonDown(.MOUSE_BUTTON_RIGHT) {
        delta := rl.GetMouseDelta();

        freecam_pitch += delta.y * FREECAM_LOOK_SENSITIVITY;
        freecam_yaw   -= delta.x * FREECAM_LOOK_SENSITIVITY;

        freecam_pitch = clamp(freecam_pitch, -PI / 2 + 0.001, PI / 2 - 0.001);

        yaw\ _quat := quaternion_from_axis_angle(.{ 0, 1, 0 }, freecam_yaw);
        pitch_quat := quaternion_from_axis_angle(.{ 1, 0, 0 }, freecam_pitch);
        freecam_transform.rotation = pitch_quat * yaw_quat;
    }

    // Position
    {
        velocity: v3f;

        forward := get_forward(freecam_transform);
        forward.y = 0;

        left := v3f.{ forward.z, 0, -forward.x };

        if rl.IsKeyDown(.KEY_W) then velocity += forward;
        if rl.IsKeyDown(.KEY_A) then velocity += left;
        if rl.IsKeyDown(.KEY_S) then velocity -= forward;
        if rl.IsKeyDown(.KEY_D) then velocity -= left;
        if rl.IsKeyDown(.KEY_E) then velocity += .{  0,  1,  0 };
        if rl.IsKeyDown(.KEY_Q) then velocity += .{  0, -1,  0 };

        normalize(*velocity);

        freecam_transform.position += velocity * FREECAM_SPEED * dt;
    }
}

draw :: (draw_call: Draw_Call) {
    array_add(*draw_calls, draw_call);
}

draw_tile :: (tile_index: int) {
    // Number of tiles across the screen
    TILES_X := RESOLUTION.x / TILE_SIZE;

    // Calculate tile coordinates (e.g., tile 5 might be x=1, y=2)
    tile_x := tile_index % TILES_X;
    tile_y := tile_index / TILES_X;

    // Screen space bounds for this specific tile
    tile_min_x := tile_x * TILE_SIZE;
    tile_min_y := tile_y * TILE_SIZE;
    tile_max_x := tile_min_x + TILE_SIZE;
    tile_max_y := tile_min_y + TILE_SIZE;

    for tiles[tile_index] {
        using draw_calls[it.draw_call_idx];

        mesh := model.meshes[0];

        projection := make_projection_matrix(60 * PI / 180.0, cast(float)RESOLUTION.x / cast(float)RESOLUTION.y, 0.01, 100);
        view := make_look_at_matrix(freecam_transform.position, freecam_transform.position + get_forward(freecam_transform), V3_UP, x_is_forward=false);
        mvp := projection * view * transform;

        v0 := mesh.vertices[mesh.indices[it.triangle_start_i + 0]];
        v1 := mesh.vertices[mesh.indices[it.triangle_start_i + 1]];
        v2 := mesh.vertices[mesh.indices[it.triangle_start_i + 2]];

        p0 := V4_ONE; p0.xyz = v0.position; p0 = mvp * p0; p0 = perspective_divide(p0); p0 = screen_to_viewport(p0);
        p1 := V4_ONE; p1.xyz = v1.position; p1 = mvp * p1; p1 = perspective_divide(p1); p1 = screen_to_viewport(p1);
        p2 := V4_ONE; p2.xyz = v2.position; p2 = mvp * p2; p2 = perspective_divide(p2); p2 = screen_to_viewport(p2);

        det012 := det2d(p1 - p0, p2 - p0);
        counter_clockwise := det012 < 0;

        if cull_mode == {
            case .NONE;
            case .FRONT; if  counter_clockwise continue;
            case .BACK;  if !counter_clockwise continue;
        }

        if counter_clockwise {
            temp := p1;
            p1 = p2;
            p2 = temp;
            det012 = -det012;
        }

        // @todo: improve this detection
        if p0.w < 0.01 || p1.w < 0.01 || p2.w < 0.01 {
            continue;
        }

        min_x := min(int.[ xx floor(p0.x), xx floor(p1.x), xx floor(p2.x) ]); min_x = max(0, min_x);
        max_x := max(int.[ xx floor(p0.x), xx floor(p1.x), xx floor(p2.x) ]); max_x = min(RESOLUTION.x, max_x) - 1;
        min_y := min(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); min_y = max(0, min_y);
        max_y := max(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); max_y = min(RESOLUTION.y) - 1;

        render_min_x := max(min_x, tile_min_x);
        render_max_x := min(max_x, tile_max_x - 1);
        render_min_y := max(min_y, tile_min_y);
        render_max_y := min(max_y, tile_max_y - 1);

        inv_det := 1.0 / det012;

        dx01 := p1.x - p0.x; dy01 := p1.y - p0.y;
        dx12 := p2.x - p1.x; dy12 := p2.y - p1.y;
        dx20 := p0.x - p2.x; dy20 := p0.y - p2.y;

        step_x01 := -dy01; step_y01 := dx01;
        step_x12 := -dy12; step_y12 := dx12;
        step_x20 := -dy20; step_y20 := dx20;

        p_start := v4f.{ render_min_x + 0.5, render_min_y + 0.5, 0, 0 };
        row_det_a := det2d(p1 - p0, p_start - p0);
        row_det_b := det2d(p2 - p1, p_start - p1);
        row_det_c := det2d(p0 - p2, p_start - p2);

        for y: render_min_y..render_max_y {
            det_a := row_det_a;
            det_b := row_det_b;
            det_c := row_det_c;

            for x: render_min_x..render_max_x {
                if det_a > 0 && det_b > 0 && det_c > 0 {
                    l0 := det_b * inv_det;
                    l1 := det_c * inv_det;
                    l2 := det_a * inv_det;

                    c0 := Color.{ xx (l0 * v0.color.r), xx (l0 * v0.color.g), xx (l0 * v0.color.b), v0.color.a };
                    c1 := Color.{ xx (l1 * v1.color.r), xx (l1 * v1.color.g), xx (l1 * v1.color.b), v1.color.a };
                    c2 := Color.{ xx (l2 * v2.color.r), xx (l2 * v2.color.g), xx (l2 * v2.color.b), v2.color.a };

                    depth := (l0 * p0.w) + (l1 * p1.w) + (l2 * p2.w);

                    index := x + y * RESOLUTION.x;
                    if depth < z_buffer[index] {
                        z_buffer[index] = depth;
                        pixels[index] = c0 + c1 + c2;
                    }
                }

                det_a += step_x01;
                det_b += step_x12;
                det_c += step_x20;
            }

            row_det_a += step_y01;
            row_det_b += step_y12;
            row_det_c += step_y20;
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

perspective_divide :: inline (using vec: v4f) -> v4f {
    result := vec;

    inv_w := 1 / w;
    result.x *= inv_w;
    result.y *= inv_w;
    result.z *= inv_w;

    return result;
}

det2d :: inline (v0: v4f, v1: v4f) -> float {
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
        log_error("failed to read model");
        return false, .{};
    }

    temp_vertices : [..]v3;
    temp_uvs      : [..]v2;
    temp_normals  : [..]v3;
    vert_indices, uv_indices, normal_indices: [..]u32;

    // texture: Texture;

    lines := split(file, "\n");

    for line: lines {
        if line == "" {
            continue;
        }

        if begins_with(line, "usemtl") {
            // parts := split(line, " ");
            // assert(parts.count == 2);
            // // @Todo: support more than png lol
            // filename := parts[1];
            // if filename[filename.count-1] == "\r" then filename.count = filename.count - 1;
            // texture_path := join(path_strip_filename(path), filename, ".png"); 
            //
            // success:, texture = load_texture(texture_path);
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

    // textures := NewArray(1, Texture);
    // textures[0] = texture;

    return true, .{
        id       = 0,
        meshes   = meshes,
        // textures = textures,
    };
}

split_whitespace :: (input: string) -> []string {
    split_result := split(trim(input), " ");

    result: [..]string;
    array_reserve(*result, split_result.count);

    for split_result if it != "" && it != " " array_add(*result, it);

    return result;
}

operator == :: (lhs: Vertex, rhs: Vertex) -> bool {
    return lhs.position == rhs.position && lhs.normal == rhs.normal && lhs.uv == rhs.uv;
}

get_vertex_hash :: (using vertex: Vertex) -> u32 {
    return ((get_hash(position) ^ (get_hash(normal) << 1)) >> 1) ^ (get_hash(uv) << 1);
}


#import "Hash";
#import "Random";
#import "Hash_Table";
#import "Basic";
#import "File";
#import "String";
#import "Flat_Pool";
#import "Thread";
#import "System";

#import "My_Math";
rl :: #import "raylib";
