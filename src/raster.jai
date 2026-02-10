//
// # @todo list for improvements:
// - Adjustable resolution
// - Transparency
// - Wireframes
// - Frustum culling
// - Proper near-plane clipping
// - Some sort of custom shader system
// - SIMD
// - Anti-aliasing
//

TILE_SIZE :: 128;

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

open_window :: (width: int, height: int, title: string) {
    init_thread_group_stuff();

    window = create_window(width, height, title);
    Simp.set_render_target(window, .LEFT_HANDED);

    resize_viewport({width,height});
}

close_window :: () {
    array_free(pixels);
    array_free(z_buffer);

    for tiles array_free(it);
    array_free(tiles);
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
    projection_matrix = make_projection_matrix(60 * PI / 180.0, cast(float)window_width / cast(float)window_height, 0.01, 100);
    view_matrix       = make_look_at_matrix(camera_transform.position, camera_transform.position + get_forward(camera_transform), V3_UP, x_is_forward=false);

    tiles_across := ceil_to_int(cast(float) window_width / TILE_SIZE);
    tiles_along  := ceil_to_int(cast(float) window_height / TILE_SIZE);
    total_tiles  := tiles_across * tiles_along;

    for draw_calls {
        using it;

        draw_call_index := it_index;
        mesh := model.meshes[0];
        i := 0;

        mvp := projection_matrix * view_matrix * transform;

        while i + 2 < mesh.indices.count {
            v0 := mesh.vertices[mesh.indices[i + 0]];
            v1 := mesh.vertices[mesh.indices[i + 1]];
            v2 := mesh.vertices[mesh.indices[i + 2]];

            p0 := V4_ONE; p0.xyz = v0.position; p0 = mvp * p0; p0 = perspective_divide(p0); p0 = screen_to_viewport(p0);
            p1 := V4_ONE; p1.xyz = v1.position; p1 = mvp * p1; p1 = perspective_divide(p1); p1 = screen_to_viewport(p1);
            p2 := V4_ONE; p2.xyz = v2.position; p2 = mvp * p2; p2 = perspective_divide(p2); p2 = screen_to_viewport(p2);

            min_x := min(p0.x, p1.x, p2.x);
            max_x := max(p0.x, p1.x, p2.x);
            min_y := min(p0.y, p1.y, p2.y);
            max_y := max(p0.y, p1.y, p2.y);

            tile_start_x := max(0, floor_to_int(min_x / TILE_SIZE));
            tile_end_x   := min(tiles_across - 1, ceil_to_int(max_x / TILE_SIZE));
            tile_start_y := max(0, floor_to_int(min_y / TILE_SIZE));
            tile_end_y   := min(tiles_along - 1, ceil_to_int(max_y / TILE_SIZE));

            for ty: tile_start_y..tile_end_y {
                for tx: tile_start_x..tile_end_x {
                    tile_index := tx + ty * tiles_across;

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
    defer Simp.texture_destroy(*texture);

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
tiles: [][..] Tile_Bin;

camera_transform: Transform;

projection_matrix : Matrix4;
view_matrix       : Matrix4;

Tile_Bin :: struct {
    triangle_start_i: int;
    draw_call_idx: int;
}

draw_tile :: (tile_index: int) {
    tiles_x := ceil_to_int(cast(float) window_width / TILE_SIZE);

    tile_x := tile_index % tiles_x;
    tile_y := tile_index / tiles_x;

    tile_min_x := tile_x * TILE_SIZE;
    tile_min_y := tile_y * TILE_SIZE;
    tile_max_x := tile_min_x + TILE_SIZE;
    tile_max_y := tile_min_y + TILE_SIZE;

    for tiles[tile_index] {
        using draw_calls[it.draw_call_idx];

        mesh := model.meshes[0];

        texture := model.textures[0];
        assert(texture.valid);
        texture_pixels := cast(*u8) texture.data;
        texture_stride := stbi_format_size(texture.format);

        mvp := projection_matrix * view_matrix * transform;

        v0 := mesh.vertices[mesh.indices[it.triangle_start_i + 0]];
        v1 := mesh.vertices[mesh.indices[it.triangle_start_i + 1]];
        v2 := mesh.vertices[mesh.indices[it.triangle_start_i + 2]];

        p0 := screen_to_viewport(perspective_divide(mvp * v4f.{v0.position.x,v0.position.y,v0.position.z,1}));
        p1 := screen_to_viewport(perspective_divide(mvp * v4f.{v1.position.x,v1.position.y,v1.position.z,1}));
        p2 := screen_to_viewport(perspective_divide(mvp * v4f.{v2.position.x,v2.position.y,v2.position.z,1}));

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

        min_x := min(cast(int) floor(p0.x), cast(int) floor(p1.x), cast(int) floor(p2.x));
        max_x := max(cast(int) floor(p0.x), cast(int) floor(p1.x), cast(int) floor(p2.x));
        min_y := min(cast(int) floor(p0.y), cast(int) floor(p1.y), cast(int) floor(p2.y));
        max_y := max(cast(int) floor(p0.y), cast(int) floor(p1.y), cast(int) floor(p2.y));

        render_min_x := max(0, min_x, tile_min_x);
        render_max_x := min(window_width-1, max_x, tile_max_x-1);
        render_min_y := max(0, min_y, tile_min_y);
        render_max_y := min(window_height-1, max_y, tile_max_y-1);

        inv_det := 1.0 / det012;

        dx01 := p1.x - p0.x; dy01 := p1.y - p0.y;
        dx12 := p2.x - p1.x; dy12 := p2.y - p1.y;
        dx20 := p0.x - p2.x; dy20 := p0.y - p2.y;

        step_x01 := -dy01; step_y01 := dx01;
        step_x12 := -dy12; step_y12 := dx12;
        step_x20 := -dy20; step_y20 := dx20;

        depth_step_x := (step_x12 * p0.w + step_x20 * p1.w + step_x01 * p2.w) * inv_det;
        depth_step_y := (step_y12 * p0.w + step_y20 * p1.w + step_y01 * p2.w) * inv_det;
        
        uv_step_x := (v0.uv * step_x12 + v1.uv * step_x20 + v2.uv * step_x01) * inv_det;
        uv_step_y := (v0.uv * step_y12 + v1.uv * step_y20 + v2.uv * step_y01) * inv_det;

        p_start := v4f.{ render_min_x + 0.5, render_min_y + 0.5, 0, 0 };
        
        row_det_a := det2d(p1 - p0, p_start - p0);
        row_det_b := det2d(p2 - p1, p_start - p1);
        row_det_c := det2d(p0 - p2, p_start - p2);

        row_depth := (row_det_b * p0.w + row_det_c * p1.w + row_det_a * p2.w) * inv_det;
        row_uv    := (v0.uv * row_det_b + v1.uv * row_det_c + v2.uv * row_det_a) * inv_det;

        for y: render_min_y..render_max_y {
            det_a := row_det_a;
            det_b := row_det_b;
            det_c := row_det_c;
            pixel_depth := row_depth;
            pixel_uv    := row_uv;

            for x: render_min_x..render_max_x {
                if (cast(s32,det_a) | cast(s32,det_b) | cast(s32,det_c)) >= 0 {
                    index := x + y * window_width;
                    
                    if pixel_depth < z_buffer[index] {
                        tex_x := cast(s32)(pixel_uv.x * cast(float)texture.width)  % texture.width;
                        tex_y := cast(s32)(pixel_uv.y * cast(float)texture.height) % texture.height;

                        if tex_x < 0 then tex_x += texture.width;
                        if tex_y < 0 then tex_y += texture.height;

                        pixel_offset := (tex_y * texture.width + tex_x) * texture_stride;
                        
                        z_buffer[index] = pixel_depth;
                        pixels[index] = Color.{
                            texture_pixels[pixel_offset + 0]/255.0, 
                            texture_pixels[pixel_offset + 1]/255.0, 
                            texture_pixels[pixel_offset + 2]/255.0, 
                            texture_pixels[pixel_offset + 3]/255.0
                        };
                    }
                }

                det_a += step_x01;
                det_b += step_x12;
                det_c += step_x20;
                pixel_depth += depth_step_x;
                pixel_uv    += uv_step_x;
            }

            row_det_a += step_y01;
            row_det_b += step_y12;
            row_det_c += step_y20;
            row_depth += depth_step_y;
            row_uv    += uv_step_y;
        }
    }
}

resize_viewport :: (new_dimensions: v2i) {
    array_resize(*pixels, new_dimensions.x * new_dimensions.y);
    array_resize(*z_buffer, new_dimensions.x * new_dimensions.y);

    total_tiles := ceil_to_int(cast(float)new_dimensions.x / TILE_SIZE) * ceil_to_int(cast(float)new_dimensions.y / TILE_SIZE);
    array_resize(*tiles, total_tiles);

    {
        using bitmap;
        width        = xx new_dimensions.x;
        height       = xx new_dimensions.y;
        mipmap_count = 1;

        bpp := Simp.get_image_bytes_per_texel(.RGBA32F);
        size := width * height * bpp;

        data         = { data = xx pixels.data, count = pixels.count * 16 };
        stride       = xx (width*bpp);

        format       = .RGBA32F;
        flags       |= .FREE_DATA_ON_DEINIT;
    }
}

screen_to_viewport :: inline (using vec: v4f) -> v4f {
    return {
        window_width * (0.5 + 0.5 * x),
        window_height * (0.5 - 0.5 * y),
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
#load "texture.jai";

#import "Basic";
#import "Hash";
#import "Random";
#import "Hash_Table";
#import "File";
#import "String";
#import "Flat_Pool";
#import "Thread";
#import "System";

#import "My_Math";

Simp :: #import "Simp";
Input :: #import "Input";
#import "Window_Creation";
#import "stb_image";
