#run build();

OUTPUT_PATH     :: "out";
EXECUTABLE_NAME :: "raster";
MAIN_PATH       :: "src/main.jai";

build :: () {
    defer set_build_options_dc(.{do_output=false});

    arguments := get_toplevel_command_line();
    release := array_find(arguments, "-release");
    dev     := array_find(arguments, "-dev");

    success := make_directory_if_it_does_not_exist(OUTPUT_PATH, true);
    if !success {
        print("Failed to create build directory: %. Ending process...\n", OUTPUT_PATH);
        return;
    }

    w := compiler_create_workspace();

    options := get_build_options();
    set_optimization(*options, ifx release then .OPTIMIZED else .DEBUG);

    {
        using options;

        output_executable_name = EXECUTABLE_NAME;
        output_path            = OUTPUT_PATH;
        intermediate_path      = tprint("%/.temp/", OUTPUT_PATH);
        backend                = ifx release then .LLVM else .X64;
    }

    set_build_options(options, w);

    compiler_begin_intercept(w);

    add_build_string(tprint("DEVELOPER :: %;", dev), w);

    add_build_file(MAIN_PATH, w);

    message_loop();

    compiler_end_intercept(w);
}

message_loop :: () { }

#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
