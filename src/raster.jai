// @todo: make dynamic
RESOLUTION :: v2i.{1280, 720};
TILE_SIZE :: 16;
TOTAL_TILES :: #run (RESOLUTION.x / TILE_SIZE) * (RESOLUTION.y / TILE_SIZE);
TITLE :: "raster";

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

// scale is ignored
set_camera_pose :: (transform: Transform) {
    camera_transform = transform;
}

draw :: (draw_call: Draw_Call) {
    array_add(*draw_calls, draw_call);
}

open_window :: () {
    init_thread_group_stuff();

    window = create_window(RESOLUTION.x, RESOLUTION.y, TITLE);

    Simp.set_render_target(window, .LEFT_HANDED);

    pixels   = NewArray(RESOLUTION.x * RESOLUTION.y, Color);
    z_buffer = NewArray(RESOLUTION.x * RESOLUTION.y, float);

    {
        using bitmap;
        width        = xx RESOLUTION.x;
        height       = xx RESOLUTION.y;
        mipmap_count = 1;

        bpp := Simp.get_image_bytes_per_texel(.RGBA32F);
        size := width * height * bpp;

        data         = { data = xx pixels.data, count = pixels.count * 16 };
        stride       = xx (width*bpp);

        format       = .RGBA32F;
        flags       |= .FREE_DATA_ON_DEINIT;

    }
}

close_window :: () {
    // Window_Creation module doesn't have destroy window proc ????
}

window_should_close :: () -> bool {
    current_time = seconds_since_init();
    dt = cast(float)(current_time - last_time);
    Clamp(*dt, 0, 0.1);
    last_time = current_time;

    quit := update_input();

    return quit;
}

get_delta_time :: () -> float { return dt; }

begin_drawing :: () {
    Simp.clear_render_target(.15, .08, .08, 1);

    for * z_buffer it.* = FLOAT32_MAX;
    for * pixels it.* = { 0, 0, 0, 1 };
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
        view := make_look_at_matrix(camera_transform.position, camera_transform.position + get_forward(camera_transform), V3_UP, x_is_forward=false);
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

    texture: Simp.Texture;
    Simp.texture_load_from_bitmap(*texture, *bitmap);
    Simp.set_shader_for_images(*texture);
    Simp.immediate_quad(0, 0, xx window_width, xx window_height, { 1, 1, 1, 1 });

    Simp.immediate_flush();
    Simp.swap_buffers(window);

    draw_calls.count = 0;
    for * tiles it.count = 0;
}

#scope_module

window : Window_Type;
window_width  : s64;
window_height : s64;

current_time : float64;
last_time    : float64;
dt           : float;

bitmap   : Simp.Bitmap;
pixels   : [] Color;
z_buffer : [] float;

thread_group: Thread_Group;

draw_calls: [..] Draw_Call;
tiles: [TOTAL_TILES][..] Tile_Bin;

camera_transform: Transform;

Tile_Bin :: struct {
    triangle_start_i: int;
    draw_call_idx: int;
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
        view := make_look_at_matrix(camera_transform.position, camera_transform.position + get_forward(camera_transform), V3_UP, x_is_forward=false);
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

#load "model.jai";
#load "input.jai";

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

Simp :: #import "Simp";
Input :: #import "Input";
#import "Window_Creation";
