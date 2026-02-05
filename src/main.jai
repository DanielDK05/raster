RESOLUTION :: v2i.{1280, 720};
TITLE :: "raster";

Mesh :: struct {
    vertices : [] Vertex;
    indices  : [] u32;
}

Vertex :: struct {
    position : v3f;
    color    : Color;
}

Draw_Call :: struct {
    mesh      : Mesh;
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

pixels   : [] Color;
z_buffer : [] float;

cube_mesh := Mesh.{
    vertices = .[
        // Front (Red) - Z = 0.5
        { { -0.5, -0.5,  0.5 }, rl.RED },   // 0
        { {  0.5, -0.5,  0.5 }, rl.RED },   // 1
        { {  0.5,  0.5,  0.5 }, rl.RED },   // 2
        { { -0.5,  0.5,  0.5 }, rl.RED },   // 3

        // Back (Blue) - Z = -0.5
        { { -0.5, -0.5, -0.5 }, rl.BLUE },  // 4
        { {  0.5, -0.5, -0.5 }, rl.BLUE },  // 5
        { {  0.5,  0.5, -0.5 }, rl.BLUE },  // 6
        { { -0.5,  0.5, -0.5 }, rl.BLUE },  // 7

        // Top (Green) - Y = 0.5
        { { -0.5,  0.5,  0.5 }, rl.GREEN }, // 8
        { {  0.5,  0.5,  0.5 }, rl.GREEN }, // 9
        { {  0.5,  0.5, -0.5 }, rl.GREEN }, // 10
        { { -0.5,  0.5, -0.5 }, rl.GREEN }, // 11

        // Bottom (Yellow) - Y = -0.5
        { { -0.5, -0.5,  0.5 }, rl.YELLOW }, // 12
        { {  0.5, -0.5,  0.5 }, rl.YELLOW }, // 13
        { {  0.5, -0.5, -0.5 }, rl.YELLOW }, // 14
        { { -0.5, -0.5, -0.5 }, rl.YELLOW }, // 15

        // Right (Magenta) - X = 0.5
        { {  0.5, -0.5,  0.5 }, rl.MAGENTA }, // 16
        { {  0.5,  0.5,  0.5 }, rl.MAGENTA }, // 17
        { {  0.5,  0.5, -0.5 }, rl.MAGENTA }, // 18
        { {  0.5, -0.5, -0.5 }, rl.MAGENTA }, // 19

        // Left (Cyan) - X = -0.5
        { { -0.5, -0.5,  0.5 }, rl.WHITE },    // 20
        { { -0.5,  0.5,  0.5 }, rl.WHITE },    // 21
        { { -0.5,  0.5, -0.5 }, rl.WHITE },    // 22
        { { -0.5, -0.5, -0.5 }, rl.WHITE },    // 23
    ],
    indices = .[
        0,  1,  2,   0,  2,  3,  // Front
        5,  4,  7,   5,  7,  6,  // Back
        8,  9,  10,  8,  10, 11, // Top
        13, 12, 15,  13, 15, 14, // Bottom
        16, 19, 18,  16, 18, 17, // Right
        23, 20, 21,  23, 21, 22, // Left
    ],
};

main :: () {
    rl.InitWindow(xx RESOLUTION.x, xx RESOLUTION.y, TITLE);
    defer rl.CloseWindow();

    pixels   = NewArray(RESOLUTION.x * RESOLUTION.y, Color);
    z_buffer = NewArray(RESOLUTION.x * RESOLUTION.y, float);

    image := rl.Image.{
        data = pixels.data,
        width = xx RESOLUTION.x,
        height = xx RESOLUTION.y,
        mipmaps = 1,
        format = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
    };

    texture := rl.LoadTextureFromImage(image);

    t := 0.0;
    rotating_transform: Transform;
    rotating_transform.position = { 0.5, 0.2, 0.3 };

    while !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        for * z_buffer it.* = FLOAT32_MAX;
        for * pixels it.* = rl.BLACK;

        mouse := rl.GetMousePosition();

        t += rl.GetFrameTime();
        // rotating_transform.rotation = quaternion_from_axis_angle(normalize(.{1, 1, 0}), t);

        update_freecam(rl.GetFrameTime());

        time := current_time_monotonic();
        // Update pixels
        {
            for x: 0..4
            for z: 0..4 {
                transform := rotating_transform;
                transform.position.x = xx x;
                transform.position.z = xx z;
                draw({
                    mesh = cube_mesh,
                    transform = m4x4(transform),
                    cull_mode = .BACK,
                });
            }
        }
        log("draw time: %", to_microseconds(current_time_monotonic() - time));

        rl.UpdateTexture(texture, pixels.data);

        rl.DrawTexture(texture, 0, 0, rl.WHITE);
        rl.DrawText(temp_c_string(tprint("FPS: %", rl.GetFPS())), 25, 25, 30, rl.WHITE);
    }
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

draw :: (using draw_call: Draw_Call) {
    i := 0;

    projection := make_projection_matrix(60 * PI / 180.0, cast(float)RESOLUTION.x / cast(float)RESOLUTION.y, 0.01, 100);

    view := make_look_at_matrix(freecam_transform.position, freecam_transform.position + get_forward(freecam_transform), V3_UP, x_is_forward=false);

    mvp := projection * view * transform;

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
        max_y := max(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); max_y = min(RESOLUTION.y, max_y) - 1;

        inv_det := 1.0 / det012;

        x := min_x;
        y := min_y;

        for y: min_y..max_y - 1
        for x: min_x..max_x - 1 {
            p := v4f.{ x + 0.5, y + 0.5, 0, 0 };
            det_a := det2d(p1 - p0, p - p0);
            det_b := det2d(p2 - p1, p - p1);
            det_c := det2d(p0 - p2, p - p2);

            if (cast(s32, det_a) | cast(s32, det_b) | cast(s32, det_c)) >= 0 {
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

    result.x /= w;
    result.y /= w;
    result.z /= w;

    return result;
}

det2d :: inline (v0: v4f, v1: v4f) -> float {
    return v0.x * v1.y - v0.y * v1.x;
}

#import "Random";
#import "Basic";
#import "SIMD";
#import "My_Math";
rl :: #import "raylib";
