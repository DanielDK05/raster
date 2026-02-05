#load "texture.jai";
#load "raster.jai";
#load "sdl.jai";

RESOLUTION :: v2i.{1280, 720};
TITLE :: "raster";

main :: () {
    SDL_Init(SDL_INIT_VIDEO);
    defer SDL_Quit();

    window := SDL_CreateWindow(
        TITLE,
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        xx RESOLUTION.x, xx RESOLUTION.y,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN
    );

    if !window {
        log_error("Could not create window: %", to_string(SDL_GetError()));
        return;
    }

    defer SDL_DestroyWindow(window);

    now := SDL_GetPerformanceCounter();
    last: u64;
    dt: float;

    surface: *SDL_Surface;

    init();

    exit := false;
    while !exit {
        last = now;
        now = SDL_GetPerformanceCounter();

        dt = (now - last) * 1000 / cast(float, SDL_GetPerformanceFrequency());

        event: SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT;
                    exit = true;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE exit = true;
            }
        }

        surface = SDL_CreateRGBSurfaceWithFormat(
            0,
            RESOLUTION.x, RESOLUTION.y, 32,
            SDL_PixelFormatEnum.SDL_PIXELFORMAT_RGBA32
        );
        SDL_SetSurfaceBlendMode(surface, SDL_BLENDMODE_NONE);

        frame(dt);
    }
}

split_whitespace :: (input: string) -> []string {
    split_result := split(trim(input), " ");

    result: [..]string;
    array_reserve(*result, split_result.count);

    for split_result if it != "" && it != " " array_add(*result, it);

    return result;
}

#import "Random";
#import "Basic";
#import "My_Math";
#import "stb_image";
#import "File";
#import "String";
#import "Hash_Table";
#import "SDL";
