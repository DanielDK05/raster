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

    for * model.meshes[0].vertices  it.color = { xx (random_get_zero_to_one()), xx (random_get_zero_to_one()), xx (random_get_zero_to_one()), 1 };

    t := 0.0;
    rotating_transform: Transform;
    rotating_transform.position = { 0.5, 0.2, 0.3 };

    defer reset_temporary_storage();
 
    while !window_should_close() {
        begin_drawing();
        defer end_drawing();

        if key_just_released(.ESCAPE) then break;

        dt := get_delta_time();
        log("FPS: %", floor(1 / dt));

        t += dt;
        rotating_transform.rotation = quaternion_from_axis_angle(normalize(.{1, 1, 0}), t);

        update_freecam(dt);
        set_camera_pose(freecam_transform);

        for x: 0..9
        for z: 0..9 {
            transform := rotating_transform;
            transform.position.x = xx (x * 2);
            transform.position.z = xx (z * 2);

            draw({
                model = model,
                transform = m4x4(transform),
                cull_mode = .BACK,
            });
        }
    }
}

update_freecam :: (dt: float) {
    // Rotation
    if key_pressed(.MOUSE_RIGHT) {
        mouse_delta := get_mouse_delta_f();
        freecam_pitch += mouse_delta.y * FREECAM_LOOK_SENSITIVITY;
        freecam_yaw   -= mouse_delta.x * FREECAM_LOOK_SENSITIVITY;

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

        if key_pressed(.W) then velocity += forward;
        if key_pressed(.A) then velocity += left;
        if key_pressed(.S) then velocity -= forward;
        if key_pressed(.D) then velocity -= left;
        if key_pressed(.E) then velocity += .{  0,  1,  0 };
        if key_pressed(.Q) then velocity += .{  0, -1,  0 };

        normalize(*velocity);

        freecam_transform.position += velocity * FREECAM_SPEED * dt;
    }
}

#import,file "raster.jai";

#import "Basic";
#import "My_Math";
#import "Random";

Input :: #import "Input";
