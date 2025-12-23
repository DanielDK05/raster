RESOLUTION :: v2i.{1280, 720};
TITLE :: "raster";

main :: () {
    rl.InitWindow(xx RESOLUTION.x, xx RESOLUTION.y, TITLE);
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    pixels := NewArray(RESOLUTION.x * RESOLUTION.y, Color);
    for * pixels {
        it.* = ifx it_index % 2 == 0 then rl.WHITE else rl.BLACK;
    }


    image := rl.Image.{
        data = pixels.data,
        width = xx RESOLUTION.x,
        height = xx RESOLUTION.y,
        mipmaps = 1,
        format = .PIXELFORMAT_UNCOMPRESSED_R32G32B32A32,
    };

    texture := rl.LoadTextureFromImage(image);

    while !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.UpdateTexture(texture, pixels.data);

        rl.DrawTexture(texture, 0, 0, rl.WHITE);
    }
}

#import "Random";
#import "Basic";
#import "My_Math";
rl :: #import "raylib";
