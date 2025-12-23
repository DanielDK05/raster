Rectangle :: struct {
    x      : float;
    y      : float;
    width  : float;
    height : float;

    #overlay (x)     pos  : v2f;
    #overlay (width) size : v2f;
}

center :: (rect: Rectangle, container: Rectangle) -> Rectangle {
    return .{
        x = container.x + container.width  / 2 - rect.width  / 2,
        y = container.y + container.height / 2 - rect.height / 2,
        size = rect.size,
    };
}

vertical_center :: (rect: Rectangle, container: Rectangle) -> Rectangle {
    return .{
        x = rect.x,
        y = container.y + container.height / 2 - rect.height / 2,
        size = rect.size,
    };
}

horizontal_center :: (rect: Rectangle, container: Rectangle) -> Rectangle {
    return .{
        y = rect.y,
        x = container.x + container.width / 2 - rect.width / 2,
        size = rect.size,
    };
}

align_right :: (rect: Rectangle, container: Rectangle) -> Rectangle {
    return .{
        y = rect.y,
        x = container.x + container.width - rect.width,
        size = rect.size,
    };
}
