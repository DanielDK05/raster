Texture :: struct {
    width, height: s32;
    data: *void;
    format: STBI;
    valid: bool;
}

load_texture :: (path: string, format := STBI.rgb_alpha) -> success: bool, texture: Texture {
    width, height, channels: s32;
    data := stbi_load(temp_c_string(path), *width, *height, *channels, xx format);
    if !data return false, .{};

    return true, .{
        format = format,
        width  = width,
        height = height, 
        data   = data,
        valid  = true,
    };
}

free :: (texture: Texture) {
    stbi_image_free(texture.data);
}

mip_levels :: (using texture: Texture) -> u32 {
    return cast(u32) floor(log2(max(cast(f32) width, xx height))) + 1;
}

stbi_format_size :: (format: STBI) -> int {
    if #complete format == {
        case .rgb_alpha;  #through;
        case .grey_alpha; return 4;

        case .default; #through;
        case .rgb;     #through;
        case .grey;    return 3;
    };
}
