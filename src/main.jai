FREECAM_LOOK_SENSITIVITY :: 0.005;
FREECAM_SPEED :: 4.0;

freecam_pitch     : float;
freecam_yaw       : float;
freecam_transform : Transform = {
    position.x = 2,
    position.y = 1,
    position.z = -2,
};

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
        set_camera_pose(freecam_transform);

        draw({
            model = model,
            transform = m4x4(rotating_transform),
            cull_mode = .BACK,
        });
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

#import,file "raster.jai";

#import "Basic";
#import "My_Math";
#import "Random";

rl :: #import "raylib";
