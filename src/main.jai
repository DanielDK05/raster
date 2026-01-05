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

pixels: [] Color;

main :: () {
    rl.InitWindow(xx RESOLUTION.x, xx RESOLUTION.y, TITLE);
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    pixels = NewArray(RESOLUTION.x * RESOLUTION.y, Color);

    image := rl.Image.{
        data = pixels.data,
        width = xx RESOLUTION.x,
        height = xx RESOLUTION.y,
        mipmaps = 1,
        format = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,
    };

    texture := rl.LoadTextureFromImage(image);

    while !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        mouse := rl.GetMousePosition();

        // Update pixels
        {
            for * pixels it.* = rl.BLUE;

            for i: 0..99 {
                draw({
                    mesh = {
                        vertices = .[
                            { {   0,   0, 0 }, rl.RED },
                            { { 100,   0, 0 }, rl.RED },
                            { {   0, 100, 0 }, rl.RED},
                        ],
                        indices = .[ 0, 1, 2 ]
                    },
                    transform = {
                        1, 0, 0, mouse.x + 100 * (i % 10),
                        0, 1, 0, mouse.y + 100 * (i / 10),
                        0, 0, 1, 0,
                        0, 0, 0, 1,
                    },
                });
            }
        }

        rl.UpdateTexture(texture, pixels.data);

        rl.DrawTexture(texture, 0, 0, rl.WHITE);
        rl.DrawText(temp_c_string(tprint("FPS: %", rl.GetFPS())), 25, 25, 30, rl.WHITE);
    }
}

draw :: (using draw_call: Draw_Call) {
    i := 0;

    while i + 2 < mesh.indices.count {
        defer i += 3;

        v0 := mesh.vertices[mesh.indices[i + 0]];
        v1 := mesh.vertices[mesh.indices[i + 1]];
        v2 := mesh.vertices[mesh.indices[i + 2]];

        p0 := V4_ONE; p0.xyz = v0.position; p0 = transform * p0;
        p1 := V4_ONE; p1.xyz = v1.position; p1 = transform * p1;
        p2 := V4_ONE; p2.xyz = v2.position; p2 = transform * p2;

        {
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
        }

        min_x := min(int.[ xx floor(p0.x), xx floor(p1.x), xx floor(p2.x) ]); min_x = max(0, min_x);
        max_x := max(int.[ xx floor(p0.x), xx floor(p1.x), xx floor(p2.x) ]); max_x = min(RESOLUTION.x-1, max_x);
        min_y := min(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); min_y = max(0, min_y);
        max_y := max(int.[ xx floor(p0.y), xx floor(p1.y), xx floor(p2.y) ]); max_y = min(RESOLUTION.y-1, max_y);

        for y: min_y..max_y - 1
        for x: min_x..max_x - 1 {
            p := v4f.{ x + 0.5, y + 0.5, 0, 0 };

            det_a := det2d(p1 - p0, p - p0);
            det_b := det2d(p2 - p1, p - p1);
            det_c := det2d(p0 - p2, p - p2);

            if det_a >= 0 && det_b >= 0 && det_c >= 0 {
                pixels[x + y * RESOLUTION.x] = v0.color;
            }
        }
    }
}

det2d :: (v0: v4f, v1: v4f) -> float {
    return v0.x * v1.y - v0.y * v1.x;
}

#import "Random";
#import "Basic";
#import "My_Math";
rl :: #import "raylib";
