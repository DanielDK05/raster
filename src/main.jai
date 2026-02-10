FREECAM_LOOK_SENSITIVITY :: 0.005;
FREECAM_SPEED :: 4.0;

MAX_TILES :: 1024;

Tile_Type :: enum {
    GRASS;
    WATER;
    BUILDING;
    COUNT;
}

Tile :: struct {
    active: bool;
    type: Tile_Type;
    grid_position: v3i;
}

freecam_pitch     : float;
freecam_yaw       : float;
freecam_transform : Transform = {
    position.x = 2,
    position.y = 1,
    position.z = -2,
};

tile_models: [#run cast(int) Tile_Type.COUNT] Model;
tiles: [MAX_TILES] Tile;

main :: () {
    open_window(1920, 1080, "raster example");
    defer close_window();

    for * tile_models {
        path := get_tile_path(xx it_index);
        success:, it.* = read_obj_file(path);
        if !success {
            log_error("Failed to load model for tile of type %, path: `%`", cast(Tile_Type) it_index, path);
            exit(1);
        }
    }

    // Building the environment
    {
        // Grass
        for x: -5..4
        for z: -5..4 {
            add_tile(.GRASS, x, 0, z);
        }

        // Water
        for x: -8..7
        for z: -8..7 {
            if x >= -5 && x <= 4 && z >= -5 && z <= 4 continue;

            add_tile(.WATER, x, 0, z);
        }

        add_tile(.BUILDING, 0, 0, 0);
    }
 
    while !window_should_close() {
        dt := get_delta_time();
        log("FPS: %", 1./dt);

        defer reset_temporary_storage();

        begin_drawing();
        defer end_drawing();

        if key_just_released(.ESCAPE) then break;

        update_freecam(dt);
        set_camera_pose(freecam_transform);

        for tiles {
            if !it.active break;

            model := tile_models[xx it.type];

            transform: Transform;
            transform.position = hex_grid_pos_to_world_pos(it.grid_position);

            draw({
                model = model,
                transform = m4x4(transform),
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

add_tile :: (type: Tile_Type, x: int, y: int, z: int) { add_tile(type, {x,y,z}); }
add_tile :: (type: Tile_Type, hex_pos: v3s) {
    for * tiles {
        if it.active continue;

        it.active = true;
        it.grid_position = hex_pos;
        it.type = type;

        return;
    }

    log_error("Trying to add more tiles than the max amount of %!", MAX_TILES);
}

get_tile_path :: (type: Tile_Type) -> string {
    if type == {
        case .GRASS; return "assets/medieval_megapack/Assets/obj/tiles/base/hex_grass.obj";
        case .WATER; return "assets/medieval_megapack/Assets/obj/tiles/base/hex_water.obj";
        case .BUILDING; return "assets/medieval_megapack/Assets/obj/buildings/blue/building_castle_blue.obj";
    }

    return "";
}

hex_grid_pos_to_world_pos :: (hex: v3s) -> v3f {
    x := cast(float) (hex.x * 2 + (ifx hex.z % 2 then 1 else 0));
    z := cast(float) (hex.z * sqrt(3));
    
    return { x, xx hex.y, z };
}

#import,file "raster.jai";

#import "Basic";
#import "My_Math";
#import "Random";

Input :: #import "Input";
