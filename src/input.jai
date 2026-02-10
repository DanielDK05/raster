update_input :: () -> bool {
    quit := false;

    Input.update_window_events();

    keys_this_frame.just_pressed.count = 0;
    keys_this_frame.released.count = 0;
    scroll_delta = 0;

    for Input.get_window_resizes() {
        Simp.update_window(it.window);

        if it.window == window {
            window_width  = it.width;
            window_height = it.height;

            resize_viewport({it.width, it.height});
        }
    }

    for Input.events_this_frame {
        if it.type == {
            case .QUIT; quit = true;
            case .KEYBOARD; handle_keyboard_event(it);
            case .MOUSE_WHEEL; scroll_delta = it.wheel_delta;
        };
    }

    return quit;
}

key_pressed :: (keycode: Key_Code) -> bool {
    return array_find(keys_this_frame.pressed, keycode);
}

key_just_pressed :: (keycode: Key_Code) -> bool {
    return array_find(keys_this_frame.just_pressed, keycode);
}

key_just_released :: (keycode: Key_Code) -> bool {
    return array_find(keys_this_frame.released, keycode);
}

get_mouse_delta :: () -> v2i {
    return .{ Input.mouse_delta_x, Input.mouse_delta_y };
}

get_mouse_delta_f :: () -> v2f {
    return .{ xx Input.mouse_delta_x, xx Input.mouse_delta_y };
}

get_scroll_delta :: inline () -> s32 {
    return scroll_delta;
}

Key_Code :: enum {
    UNKNOWN :: 0;

    BACKSPACE   :: 8;
    TAB         :: 9;
    LINEFEED    :: 10;
    ENTER       :: 13;
    ESCAPE      :: 27;
    SPACEBAR    :: 32;

    A;
    B;
    C;
    D;
    E;
    F;
    G;
    H;
    I;
    J;
    K;
    L;
    M;
    N;
    O;
    P;
    Q;
    R;
    S;
    T;
    U;
    V;
    W;
    X;
    Y;
    Z;

    DELETE      :: 127;
    ARROW_UP    :: 128;
    ARROW_DOWN  :: 129;
    ARROW_LEFT  :: 130;
    ARROW_RIGHT :: 131;
    PAGE_UP     :: 132;
    PAGE_DOWN   :: 133;
    HOME        :: 134;
    END         :: 135;
    INSERT      :: 136;
    PAUSE       :: 137;
    SCROLL_LOCK :: 138;
    ALT;
    CTRL;
    SHIFT;
    CMD;
    F1;
    F2;
    F3;
    F4;
    F5;
    F6;
    F7;
    F8;
    F9;
    F10;
    F11;
    F12;
    F13;
    F14;
    F15;
    F16;
    F17;
    F18;
    F19;
    F20;
    F21;
    F22;
    F23;
    F24;
    PRINT_SCREEN;

    MOUSE_LEFT;
    MOUSE_RIGHT;
    MOUSE_MIDDLE;
}

#scope_module

Press_State :: struct {
    pressed       : bool;
    just_pressed  : bool;
    just_released : bool;
}

#scope_file

//
// @todo: use Press_State
//

Keys :: struct {
    pressed      : [..] Key_Code;
    just_pressed : [..] Key_Code;
    released     : [..] Key_Code;
}

keys_this_frame : Keys;
scroll_delta    : s32;

handle_keyboard_event :: (event: Input.Event) {
    keycode := jai_keycode_to_my_keycode(event.key_code);

    if keycode == .UNKNOWN return;

    if event.key_pressed {
        if !key_pressed(keycode) {
            array_add(*keys_this_frame.just_pressed, keycode);
            array_add(*keys_this_frame.pressed, keycode);
        }
    } else {
        if key_pressed(keycode) {
            array_add(*keys_this_frame.released, keycode);
        }

        removed := array_unordered_remove_by_value(*keys_this_frame.pressed, keycode);
        assert(removed == 1);
    }
}

jai_keycode_to_my_keycode :: (keycode: Input.Key_Code) -> Key_Code {
    if keycode == {
        case .UNKNOWN; return .UNKNOWN;
        case #char "A"; return .A;
        case #char "B"; return .B;
        case #char "C"; return .C;
        case #char "D"; return .D;
        case #char "E"; return .E;
        case #char "F"; return .F;
        case #char "G"; return .G;
        case #char "H"; return .H;
        case #char "I"; return .I;
        case #char "J"; return .J;
        case #char "K"; return .K;
        case #char "L"; return .L;
        case #char "M"; return .M;
        case #char "N"; return .N;
        case #char "O"; return .O;
        case #char "P"; return .P;
        case #char "Q"; return .Q;
        case #char "R"; return .R;
        case #char "S"; return .S;
        case #char "T"; return .T;
        case #char "U"; return .U;
        case #char "V"; return .V;
        case #char "W"; return .W;
        case #char "X"; return .X;
        case #char "Y"; return .Y;
        case #char "Z"; return .Z;
        case .BACKSPACE; return .BACKSPACE;
        case .TAB; return .TAB;
        case .LINEFEED; return .LINEFEED;
        case .ENTER; return .ENTER;
        case .ESCAPE; return .ESCAPE;
        case .SPACEBAR; return .SPACEBAR;
        case .DELETE; return .DELETE;
        case .ARROW_UP; return .ARROW_UP;
        case .ARROW_DOWN; return .ARROW_DOWN;
        case .ARROW_LEFT; return .ARROW_LEFT;
        case .ARROW_RIGHT; return .ARROW_RIGHT;
        case .PAGE_UP; return .PAGE_UP;
        case .PAGE_DOWN; return .PAGE_DOWN;
        case .HOME; return .HOME;
        case .END; return .END;
        case .INSERT; return .INSERT;
        case .PAUSE; return .PAUSE;
        case .SCROLL_LOCK; return .SCROLL_LOCK;
        case .ALT; return .ALT;
        case .CTRL; return .CTRL;
        case .SHIFT; return .SHIFT;
        case .CMD; return .CMD;
        case .F1; return .F1;
        case .F2; return .F2;
        case .F3; return .F3;
        case .F4; return .F4;
        case .F5; return .F5;
        case .F6; return .F6;
        case .F7; return .F7;
        case .F8; return .F8;
        case .F9; return .F9;
        case .F10; return .F10;
        case .F11; return .F11;
        case .F12; return .F12;
        case .F13; return .F13;
        case .F14; return .F14;
        case .F15; return .F15;
        case .F16; return .F16;
        case .F17; return .F17;
        case .F18; return .F18;
        case .F19; return .F19;
        case .F20; return .F20;
        case .F21; return .F21;
        case .F22; return .F22;
        case .F23; return .F23;
        case .F24; return .F24;
        case .PRINT_SCREEN; return .PRINT_SCREEN;
        case .MOUSE_BUTTON_LEFT; return .MOUSE_LEFT;
        case .MOUSE_BUTTON_RIGHT; return .MOUSE_RIGHT;
        case .MOUSE_BUTTON_MIDDLE; return .MOUSE_MIDDLE;
        case; return .UNKNOWN;
    }
}
