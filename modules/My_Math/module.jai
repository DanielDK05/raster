#load "rectangle.jai";

#import "Basic";
#import "Sloppy_Math";

Transform :: struct {
    position :  v3;
    rotation :  Quaternion;
    scale    := v3.{ 1, 1, 1 };
}

m4x4 :: (position: v3, rotation: Quaternion, scale: v3) -> Matrix4 {
    return m4x4(Transform.{ position, rotation, scale });
}

m4x4 :: (transform: Transform) -> Matrix4 {
    //@perf: I ain't no expert, but I think this can be improved.
    m := Matrix4_Identity;

    translate(*m, xx,force transform.position);
    m = rotate(m, xx,force transform.rotation);
    scale(*m, xx,force transform.scale);

    return m;
}

scale :: (using transform: Transform, _scale: v3f) -> Transform {
    return .{ position, rotation, scale * _scale }; 
}

transform_point :: (transform: Transform, point: v3f) -> v3f {
    return transform_point(m4x4(transform), point);
}

v2 :: struct ($T := f32) {
    x, y : T;

    #overlay (x) fields : [2] T; @JsonIgnore
}

v3 :: struct ($T := f32) {
    x, y, z : T;

    // For euler angles
    #overlay (x) pitch : T; @JsonIgnore
    #overlay (y) yaw   : T; @JsonIgnore
    #overlay (z) roll  : T; @JsonIgnore

    // For euler angles
    #overlay (x) width  : T; @JsonIgnore
    #overlay (y) height : T; @JsonIgnore
    #overlay (z) depth  : T; @JsonIgnore

    // For colors 
    #overlay (x) r : T; @JsonIgnore
    #overlay (y) g : T; @JsonIgnore
    #overlay (z) b : T; @JsonIgnore

    #overlay (x) fields : [3] T; @JsonIgnore
}

v4 :: struct ($T := f32) {
    x, y, z, w : T;

    // For colors 
    #overlay (x) r : T; @JsonIgnore
    #overlay (y) g : T; @JsonIgnore
    #overlay (z) b : T; @JsonIgnore
    #overlay (w) a : T; @JsonIgnore

    #overlay (x) fields : [4] T; @JsonIgnore
    #overlay (x) xyz    : v3f; @JsonIgnore
}

f32 :: float32;
f64 :: float64;

v2f :: v2(float);
v3f :: v3(float);
v4f :: v4(float);

v2i :: v2(int);
v3i :: v3(int);
v4i :: v4(int);

v2s :: v2(s64);
v3s :: v3(s64);
v4s :: v4(s64);

__MY_VECTORS :: Type.[
    v2(float), v2(s64), v2(s32), v2(u64), v2(u32),
    v3(float), v3(s64), v3(s32), v3(u64), v3(u32),
    v4(float), v4(s64), v4(s32), v4(u64), v4(u32),
];

V3_ZERO     :: v3f.{  0,  0,  0 };
V3_ONE      :: v3f.{  1,  1,  1 };
V3_UP       :: v3f.{  0,  1,  0 };
V3_DOWN     :: v3f.{  0, -1,  0 };
V3_FORWARD  :: v3f.{  0,  0,  1 };
V3_BACKWARD :: v3f.{  0,  0, -1 };
V3_RIGHT    :: v3f.{  1,  0,  0 };
V3_LEFT     :: v3f.{ -1,  0,  0 };

V2_ZERO     :: v2f.{  0,  0 };
V2_ONE      :: v2f.{  1,  1 };
V2_UP       :: v2f.{  0,  1 };
V2_DOWN     :: v2f.{  0, -1 };
V2_RIGHT    :: v2f.{  1,  0 };
V2_LEFT     :: v2f.{ -1,  0 };

Color :: #type,distinct v4f;

//
// @note: Apparently distinct types don't get the operator overloads??
//        I don't feel like looking into it rn, so I'm just putting custom Color overloads here
//

operator + :: (a: Color, b: Color) -> Color { return .{ a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w }; }
operator - :: (a: Color, b: Color) -> Color { return .{ a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w }; }
operator * :: (a: Color, b: Color) -> Color { return .{ a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w }; }
operator * :: (a: Color, x: float) -> Color { return .{ a.x * x, a.y * x, a.z * x, a.w * x }; }

COLOR_WHITE     :: Color.{ 1, 1, 1, 1 };
COLOR_BLACK     :: Color.{ 0, 0, 0, 1 };
COLOR_RED       :: Color.{ 1, 0, 0, 1 };
COLOR_GREEN     :: Color.{ 0, 1, 0, 1 };
COLOR_BLUE      :: Color.{ 0, 0, 1, 1 };
COLOR_ORANGE    :: Color.{ 1.0, 0.5, 0.0, 1.0 };
COLOR_PURPLE    :: Color.{ 0.5, 0.0, 0.5, 1.0 };
COLOR_PINK      :: Color.{ 1.0, 0.4, 0.7, 1.0 };
COLOR_YELLOW    :: Color.{ 1.0, 1.0, 0.0, 1.0 };
COLOR_CYAN      :: Color.{ 0.0, 1.0, 1.0, 1.0 };
COLOR_MAGENTA   :: Color.{ 1.0, 0.0, 1.0, 1.0 };
COLOR_BROWN     :: Color.{ 0.6, 0.3, 0.0, 1.0 };
COLOR_LIME      :: Color.{ 0.7, 1.0, 0.0, 1.0 };
COLOR_TEAL      :: Color.{ 0.0, 0.5, 0.5, 1.0 };
COLOR_INDIGO    :: Color.{ 0.3, 0.0, 0.5, 1.0 };
COLOR_MAROON    :: Color.{ 0.5, 0.0, 0.0, 1.0 };
COLOR_GOLD      :: Color.{ 1.0, 0.84, 0.0, 1.0 };
COLOR_SILVER    :: Color.{ 0.75, 0.75, 0.75, 1.0 };
COLOR_SLATE     :: Color.{ 0.44, 0.5, 0.56, 1.0 };
COLOR_CORAL     :: Color.{ 1.0, 0.5, 0.31, 1.0 };
COLOR_TURQUOISE :: Color.{ 0.25, 0.88, 0.82, 1.0 };
COLOR_MINT      :: Color.{ 0.6, 1.0, 0.6, 1.0 };
COLOR_LAVENDER  :: Color.{ 0.9, 0.9, 0.98, 1.0 };
COLOR_NAVY      :: Color.{ 0.0, 0.0, 0.5, 1.0 };
COLOR_CHARCOAL  :: Color.{ 0.2, 0.2, 0.2, 1.0 };
COLOR_IVORY     :: Color.{ 1.0, 1.0, 0.94, 1.0 };
COLOR_SALMON    :: Color.{ 0.98, 0.5, 0.45, 1.0 };
COLOR_PEACH     :: Color.{ 1.0, 0.85, 0.73, 1.0 };
COLOR_SKY_BLUE  :: Color.{ 0.53, 0.81, 0.98, 1.0 };

floor_to_int :: (x: float) -> int { return xx floor(x); }

log2 :: (x: f32) -> f32 {
    if x <= 0 {
        return -FLOAT32_INFINITY;
    }

    return log(x) / log(2);
}

quaternion_from_euler :: (using euler: v3f) -> Quaternion {
    return quaternion_from_axis_angle(.{ 0, 0, 1 }, roll) *
           quaternion_from_axis_angle(.{ 0, 1, 0 }, yaw) *
           quaternion_from_axis_angle(.{ 1, 0, 0 }, pitch);
}

get_forward :: (q: Quaternion) -> v3f {
    normalized := q;
    normalize_or_identity(*normalized);

    using normalized;

    return .{
        x = -2 * (x * z - w * y),
        y = -2 * (y * z + w * x),
        z = 1 - 2 * (x * x + y * y),
    };
}

quaternion_from_axis_angle :: (v: v3f, theta: float) -> Quaternion {
    q: Quaternion;
    set_from_axis_and_angle(*q, v, theta);
    return q;
}

quaternion_from_axis_angle :: (x: float, y: float, z: float, theta: float) -> Quaternion {
    q: Quaternion;
    set_from_axis_and_angle(*q, x, y, z, theta);
    return q;
}

set_from_axis_and_angle :: (using q: *Quaternion, v: v3f, theta: float) {
    axis := unit_vector(v);

    st := sin(theta * 0.5);
    ct := cos(theta * 0.5);

    x = axis.x * st;
    y = axis.y * st;
    z = axis.z * st;
    w = ct;
}

set_from_axis_and_angle :: inline (q: *Quaternion, x: float, y: float, z: float, theta: float) {
    set_from_axis_and_angle(q, .{x, y, z}, theta);
}

get_axis_and_angle :: (using q: Quaternion) -> x: float64, y: float64, z: float64, theta: float64 {
    safe_w := w;
    Clamp(*safe_w, -1, 1);

    theta := acos(safe_w);

    assert(theta >= -7);
    assert(theta <= 7);

    sin_theta := sin(theta);
    theta *= 2;

    EPSILON :: 0.0001;  // @Cleanup: Think about whether this is a good value.
    if (sin_theta < EPSILON) && (sin_theta > -EPSILON) {
        return 1, 0, 0, theta;
    }

    return  x / sin_theta, y / sin_theta, z / sin_theta, theta;
}

get_euler :: (using q: Quaternion) -> v3f {
    euler: v3f;

    sinp := 2.0 * (w * z + y * x);
    cosp := 1.0 - 2.0 * (x * z + y * y);
    euler.roll = atan2(sinp, cosp);

    siny := 2.0 * (w * y - x * z);
    euler.pitch = ifx abs(siny) >= 1.0 
                  then PI / 2 * sign(1.0)
                  else asin(siny);

    sinr := 2.0 * (w * x + z * y);
    cosr := 1.0 - 2.0 * (y * y + x * x);
    euler.yaw = atan2(sinr, cosr);

    return euler;
}

sign :: (x: float) -> float {
    if x > 0 return 1;
    else if x < 0 return -1;
    else return 0;
}

with_r :: with_x; 
with_g :: with_y;
with_b :: with_z; 
with_a :: with_w; 

with_x :: (a: v3f, x: float) -> v3f { return .{ x,   a.y, a.z }; }
with_y :: (a: v3f, y: float) -> v3f { return .{ a.x, y,   a.z }; }
with_z :: (a: v3f, z: float) -> v3f { return .{ a.x, a.y, z   }; }

with_x :: (a: v4f, x: float) -> v4f { return .{ x,   a.y, a.z, a.w }; }
with_y :: (a: v4f, y: float) -> v4f { return .{ a.x, y,   a.z, a.w }; }
with_z :: (a: v4f, z: float) -> v4f { return .{ a.x, a.y, z,   a.w }; }
with_w :: (a: v4f, w: float) -> v4f { return .{ a.x, a.y, a.z, w   }; }
with_x :: (a: Color, x: float) -> Color { return .{ x,   a.y, a.z, a.w }; }
with_y :: (a: Color, y: float) -> Color { return .{ a.x, y,   a.z, a.w }; }
with_z :: (a: Color, z: float) -> Color { return .{ a.x, a.y, z,   a.w }; }
with_w :: (a: Color, w: float) -> Color { return .{ a.x, a.y, a.z, w   }; }

operator + :: (a: $T/v2, b: T) -> T { return .{ a.x + b.x, a.y + b.y }; }
operator + :: (a: $T/v3, b: T) -> T { return .{ a.x + b.x, a.y + b.y, a.z + b.z }; }
operator + :: (a: $T/v4, b: T) -> T { return .{ a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w }; }

operator - :: (a: $T/v2, b: T) -> T { return .{ a.x - b.x, a.y - b.y }; }
operator - :: (a: $T/v3, b: T) -> T { return .{ a.x - b.x, a.y - b.y, a.z - b.z }; }
operator - :: (a: $T/v4, b: T) -> T { return .{ a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w }; }

operator - :: (using v: $T/v2) -> T { return .{ -x, -y }; }
operator - :: (using v: $T/v3) -> T { return .{ -x, -y, -z }; }
operator - :: (using v: $T/v4) -> T { return .{ -x, -y, -z, -w }; }

operator * :: (a: $T/v2, k: float) -> T #symmetric { return .{ a.x * k, a.y * k }; }
operator * :: (a: $T/v3, k: float) -> T #symmetric { return .{ a.x * k, a.y * k, a.z * k }; }
operator * :: (a: $T/v4, k: float) -> T #symmetric { return .{ a.x * k, a.y * k, a.z * k, a.w * k }; }

operator / :: (a: $T/v2, k: $I) -> T #modify { return IsScalar(I); } { return .{ a.x / k, a.y / k }; }
operator / :: (a: $T/v3, k: $I) -> T #modify { return IsScalar(I); } { return .{ a.x / k, a.y / k, a.z / k }; }
operator / :: (a: $T/v4, k: $I) -> T #modify { return IsScalar(I); } { return .{ a.x / k, a.y / k, a.z / k, a.w / k }; }

operator * :: (a: $T/v2, b: T) -> T { return .{ a.x * b.x, a.y * b.y }; }
operator * :: (a: $T/v3, b: T) -> T { return .{ a.x * b.x, a.y * b.y, a.z * b.z }; }
operator * :: (a: $T/v4, b: T) -> T { return .{ a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w }; }

operator / :: (a: $T/v2, b: T) -> T { return .{ a.x / b.x, a.y / b.y }; }
operator / :: (a: $T/v3, b: T) -> T { return .{ a.x / b.x, a.y / b.y, a.z / b.z }; }
operator / :: (a: $T/v4, b: T) -> T { return .{ a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w }; }

//
// @cleanup: Do we want to implement this operator? And also implicitly using values_are_close might be confusing..
//           Maybe remove this. I need to think more about it
//
operator == :: (a: v2i, b: v2i) -> bool { return a.x == b.x && a.y == b.y; }
operator == :: (a: v3i, b: v3i) -> bool { return a.x == b.x && a.y == b.y && a.z == b.z; }
operator == :: (a: v4i, b: v4i) -> bool { return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w; }

operator == :: (a: $T/v2, b: T) -> bool { return values_are_close(a.x, b.x) && values_are_close(a.y, b.y); }
operator == :: (a: $T/v3, b: T) -> bool { return values_are_close(a.x, b.x) && values_are_close(a.y, b.y) && values_are_close(a.z, b.z); }
operator == :: (a: $T/v4, b: T) -> bool { return values_are_close(a.x, b.x) && values_are_close(a.y, b.y) && values_are_close(a.z, b.z) && values_are_close(a.w, b.w); }

// 
// @cleanup: Not sure if it's worth implementing this operator over using the rotate function.
//           Could be confusing what `multiply` means in the context. This is how it works in Unity though.
//
operator * :: (a: Quaternion, b: v3f) -> v3f { return rotate(b, a); }

rotate :: (v: v3f, q: Quaternion) -> v3f {
    // For derivation, see: https://fgiesen.wordpress.com/2019/02/09/rotating-a-single-vector-using-a-quaternion/
    t := cross(q.xyz, v) * 2.0;
    return v + t * q.w + cross(q.xyz, t);
}

get_length :: inline (a: v2f) -> float { return sqrt(get_length_squared(a)); }
get_length :: inline (a: v3f) -> float { return sqrt(get_length_squared(a)); }
get_length :: inline (a: v4f) -> float { return sqrt(get_length_squared(a)); }

get_length_squared :: inline (using v: v2) -> v.T { return x * x + y * y; }
get_length_squared :: inline (using v: v3) -> v.T { return x * x + y * y + z * z; }
get_length_squared :: inline (using v: v4) -> v.T { return x * x + y * y + z * z + w * w; }

floor :: inline (using v: v2f) -> v2f { return .{ floor(x), floor(y) }; }
floor :: inline (using v: v3f) -> v3f { return .{ floor(x), floor(y), floor(z) }; }
floor :: inline (using v: v4f) -> v4f { return .{ floor(x), floor(y), floor(z), floor(w) }; }

floor_to_int :: inline (using v: v2f) -> v2i { return .{ xx floor(x), xx floor(y) }; }
floor_to_int :: inline (using v: v3f) -> v3i { return .{ xx floor(x), xx floor(y), xx floor(z) }; }
floor_to_int :: inline (using v: v4f) -> v4i { return .{ xx floor(x), xx floor(y), xx floor(z), xx floor(w) }; }

cross :: (a: v3f, b: v3f) -> v3f {
    n: v3 = ---;

    n.x = a.y * b.z - a.z * b.y;
    n.y = a.z * b.x - a.x * b.z;
    n.z = a.x * b.y - a.y * b.x;

    return n;
}

dot :: (a: $T/v2, b: T) -> float {
    return a.x*b.x + a.y*b.y;
}

dot :: (a: $T/v3, b: T) -> float {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}

dot :: (a: $T/v4, b: T) -> float {
    return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w;
}

abs :: (using a: $T/v2) -> T { return .{ abs(x), abs(y) }; }
abs :: (using a: $T/v3) -> T { return .{ abs(x), abs(y), abs(z) }; }
abs :: (using a: $T/v4) -> T { return .{ abs(x), abs(y), abs(z), abs(w) }; }

signed_angle :: (from: v2f, to: v2f) -> float {
    unsigned_angle := acos(clamp(dot(from, to), -1, 1));
    cross_product := from.x * to.y - from.y * to.x;
    _sign := sign(cross_product);
    return unsigned_angle * _sign;
}

lerp :: (a: $T/__MY_VECTORS, b: T, t: float) -> T {
    return a + (b - a) * t;
}

normalize :: (v: *v3f, epsilon := 0.0, fallback := v3f.{}) {
    sq := get_length(v);
    if sq <= epsilon {
        v.* = fallback;
        return;
    }

    factor := 1 / sq;
    v.x *= factor;
    v.y *= factor;
    v.z *= factor;

    // #if T == v3 || T == v4 then v.z *= factor;
    // #if T == v4            then v.w *= factor;
}

normalize :: (v: v3f, epsilon := 0.0, fallback := v3f.{}) -> v3f {
    r := v;
    inline normalize(*r, epsilon, fallback);
    return r;
}

get_hash :: (vec: v2) -> u32 { return get_hash(vec.T.[vec.x, vec.y]); }
get_hash :: (vec: v3) -> u32 { return get_hash(vec.T.[vec.x, vec.y, vec.z]); }
get_hash :: (vec: v4) -> u32 { return get_hash(vec.T.[vec.x, vec.y, vec.z, vec.w]); }

_v2f :: (a: float) -> v2f { return .{ a, a }; }
_v3f :: (a: float) -> v3f { return .{ a, a, a }; }
_v4f :: (a: float) -> v4f { return .{ a, a, a, a }; }

_v2i :: (a: int) -> v2i { return .{ a, a }; }
_v3i :: (a: int) -> v3i { return .{ a, a, a }; }
_v4i :: (a: int) -> v4i { return .{ a, a, a, a }; }

unit_vector :: (v: v3f) -> v3f {
    // Uses (0, 0, 0) as the fallback if v is 0.
    sq := sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
    if sq == 0 return v;

    result: v3f = ---;
    factor := 1.0 / sq;
    result.x = v.x * factor;
    result.y = v.y * factor;
    result.z = v.z * factor;

    return result;
}

unit_vector :: (v: v2f) -> v2f {
    // Uses (0, 0) as the fallback if v is 0.
    sq := sqrt(v.x*v.x + v.y*v.y);
    if sq == 0 return v;

    result: v2f = ---;
    factor := 1.0 / sq;
    result.x = v.x * factor;
    result.y = v.y * factor;

    return result;
}

abs :: inline (using v: v2f) -> v2f {
    return .{abs(x), abs(y)};
}

abs :: inline (using v: v3f) -> v3f {
    return .{abs(x), abs(y), abs(z)};
}

abs :: inline (using v: v4f) -> v4f {
    return .{abs(x), abs(y), abs(z), abs(w)};
}

min :: inline (v1: v2f, v2: v2f) -> v2f {
    return .{Min(v1.x, v2.x), Min(v1.y, v2.y)};
}

min :: inline (v1: v3f, v2: v3f) -> v3f {
    return .{Min(v1.x, v2.x), Min(v1.y, v2.y), Min(v1.z, v2.z)};
}

min :: inline (v1: v4f, v2: v4f) -> v4f {
    return .{Min(v1.x, v2.x), Min(v1.y, v2.y), Min(v1.z, v2.z), Min(v1.w, v2.w)};
}

max :: inline (v1: v2f, v2: v2f) -> v2f {
    return .{Max(v1.x, v2.x), Max(v1.y, v2.y)};
}

max :: inline (v1: v3f, v2: v3f) -> v3f {
    return .{Max(v1.x, v2.x), Max(v1.y, v2.y), Max(v1.z, v2.z)};
}

max :: inline (v1: v4f, v2: v4f) -> v4f {
    return .{Max(v1.x, v2.x), Max(v1.y, v2.y), Max(v1.z, v2.z), Max(v1.w, v2.w)};
}

TAU   :: cast(float32) 6.283185;
TAU64 :: 6.28318530717958648;

PI    :: cast(float32) 3.1415927;
PI64  :: 3.141592653589793;

FLOAT16_MAX : float :   65504.0;

FLOAT32_MIN        :: 0h00800000;
FLOAT32_MAX        :: 0h7F7FFFFF;
FLOAT32_INFINITY   :: 0h7F800000;
FLOAT32_NAN        :: 0h7FBFFFFF;

FLOAT64_MIN        :: 0h00100000_00000000;
FLOAT64_MAX        :: 0h7FEFFFFF_FFFFFFFF;
FLOAT64_INFINITY   :: 0h7FF00000_00000000;
FLOAT64_NAN        :: 0h7FF7FFFF_FFFFFFFF;

S8_MIN  :s8:    -128;
S8_MAX  :s8:    127;
U8_MAX  :u8:    255;
S16_MIN :s16:   -32768;
S16_MAX :s16:   32767;
U16_MAX :u16:   0xffff;
S32_MIN :s32:   0x8000_0000;
S32_MAX :s32:   0x7fff_ffff;
U32_MAX :u32:   0xffff_ffff;
S64_MIN :s64:   0x8000_0000_0000_0000;
S64_MAX :s64:   0x7fff_ffff_ffff_ffff;
U64_MAX :u64:   0xffff_ffff_ffff_ffff;

Clamp :: inline (pointer: *$T, low: T, high: T) {
    if pointer.* < low    pointer.* = low;
    if pointer.* > high   pointer.* = high;
} @NoProfile

// ## Scalar functions

// ### Integer functions

abs :: inline (x: int) -> int {
    if x < 0 return -x;
    return x;
}

abs :: inline (x: s32) -> s32 {
    if x < 0 return -x;
    return x;
}

// ### Float functions

is_nan_is_inf :: (x: float64) -> (isnan: bool, isinf: bool) {
    uf := (cast(*u64)*x).*;

    unbiased_exponent := cast(s32) ((uf >> 52) & 0x7ff);  // @Feature: What we really mean here is "cast to whatever you think is a fast number, that is at least some size... [in this case it needs to be at least 11 bits!]

    if unbiased_exponent == 0x7ff {
        raw_mantissa := uf & 0xf_ffff_ffff_ffff;
        if raw_mantissa == 0 {
            return false, true;
        } else {
            return true, false;
        }
    }

    return false, false;
}

isnan :: (x: float64) -> bool {
    return is_nan_is_inf(x);
}

isinf :: (x: float64) -> bool {
    _, _isinf := is_nan_is_inf(x);
    return _isinf;
}

is_finite :: (x: float64) -> bool {
    uf := (cast(*u64)*x).*;
    unbiased_exponent := cast(s32) ((uf >> 52) & 0x7ff);  // @Speed: Could remove shift by doing big mask.
    return unbiased_exponent != 0x7ff;
}

is_nan_is_inf :: (x: float32) -> (isnan: bool, isinf: bool) {
    uf := (cast(*u32)*x).*;
    unbiased_exponent := (uf >> 23) & 0xff;
    if unbiased_exponent == 0xff {
        raw_mantissa := uf & 0x7f_ffff;
        if raw_mantissa == 0 {
            return false, true;
        } else {
            return true, false;
        }
    }

    return false, false;
}

isnan :: (x: float32) -> bool {
    return is_nan_is_inf(x);
}

isinf :: (x: float32) -> bool {
    _, _isinf := is_nan_is_inf(x);
    return _isinf;
}

is_finite :: (x: float) -> bool {
    uf := (cast(*u32)*x).*;
    unbiased_exponent := (uf >> 23) & 0xff;
    return unbiased_exponent != 0xff;
}

abs :: inline (x: float64) -> float64 {
    union {
        _float64: float64;
        _u64:     u64;
    }

    _float64 = x;
    _u64 &= 0x7fff_ffff_ffff_ffff;
    return _float64;
}

abs :: inline (x: float32) -> float32 {
    union {
        _float32: float32;
        _u32:     u32;
    }

    _float32 = x;
    _u32 &= 0x7fff_ffff;
    return _float32;
}

// 'frac' just returns x - floor(x). If you want it to have different
// behavior for negative numbers, write in and explain.
frac :: inline (x: $T) -> T
#modify {
    if (T == float32) || (T == float64) return true;
    return false;
} {
    return x - floor(x);
}

// We call this fmod_cycling to clarify that its behavior is different
// from that in base libc, which most people don't want. (But we want to
// avoid people introducing errors by using a familiar name that they think
// they know what it means, or by porting old C code). This fmod
// just generates a repeating pattern that cycles continuously, rather
// than being reflected for positive and negative inputs.
fmod_cycling :: inline (x: float64, y: float64) -> float64 {
    if y == 0 {
        log_error("Cannot fmod_cycling with denominator 0.\n");
        return FLOAT64_INFINITY;
    }

    // Not being that particular about if x is NaN or whatever...

    remainder := x - (floor(x/y) * y);

    return remainder;
}

fmod_cycling :: inline (x: float, divisor: float) -> float { return cast(float) fmod_cycling(cast(float64) x, cast(float64) divisor); }

// Float32 versions.
tan  :: inline (theta: float) -> float { return cast(float) tan (cast(float64) theta); }
acos :: inline (theta: float) -> float { return cast(float) acos(cast(float64) theta); }
asin :: inline (theta: float) -> float { return cast(float) asin(cast(float64) theta); }

sqrt :: inline (x: float) -> float { return cast(float) sqrt(cast(float64) x); }

pow  :: inline (x: float, power: float) -> float  { return cast(float) pow(cast(float64)x, cast(float64) power); }
exp  :: inline (x: float) -> float { return cast(float) exp(cast(float64) x); }
log  :: inline (x: float) -> float { return cast(float) log(cast(float64) x); }


// This 'saturate' stuff is not necessarily a good name for a general-purpose routine.
// That's a graphics-specific name. These things should probably be in some kind of
// GPU Math library, or, I don't know.
// Also, note that we have a non-functional Clamp already in this file...!
saturate :: (f: float)   -> float   {  return clamp(f, 0, 1);  }
saturate :: (f: float64) -> float64 {  return clamp(f, 0, 1);  }
square   :: (a : $T) -> T {  return a * a;  }

// See: https://fgiesen.wordpress.com/2012/03/28/half-to-float-done-quic/
// This seems like a specialist routine that probably should be elsewhere.
half_to_float :: (h: u16) -> float {
    magic      :: 0h77800000;  // This is ((254 - 15) << 23) as a float.
    was_infnan :: 0h47800000;  // This is ((127 + 16) << 23) as a float.

    union { u: u32; f: float; };

    u = (cast(u32)h & 0x7fff) << 13;  // exponent/mantissa bits
    f *= magic;                       // exponent adjust
    if f >= was_infnan                // make sure Inf/NaN survive
        u |= 255 << 23;
    u |= (cast(u32)h & 0x8000) << 16; // sign bit
    return f;
}

Quaternion :: struct {
    x, y, z:  float;
    w      := 1.0;

    #overlay (x) component: [4] float = ---;
    #overlay (x) xyz: v3f = ---;
}

normalize_or_identity :: (using q: *Quaternion) -> float {
    sq := sqrt(x*x + y*y + z*z + w*w);
    if sq == 0 {
        w = 1;
        return sq;
    }

    factor := 1.0 / sq;
    x *= factor;
    y *= factor;
    z *= factor;
    w *= factor;

    return sq;
} @NoProfile

lerp :: inline (a: float, b: float, t: float) -> float {
    return a + (b - a) * t;
} @NoProfile

lerp :: inline (a: float64, b: float64, t: float64) -> float64 {
    return a + (b - a) * t;
} @NoProfile

lerp :: (a: $R, b: R, t: float) -> R
#modify {
    // This lerp only applies to the types below:
    return (R == v2f) || (R == v3f) || (R == v4f) || (R == Quaternion);
} {
    return a + (b - a) * t;
}

lerp :: (a: Quaternion, b: Quaternion, t: float) -> Quaternion {
    r: Quaternion = ---;

    r.x = a.x + t * (b.x - a.x);
    r.y = a.y + t * (b.y - a.y);
    r.z = a.z + t * (b.z - a.z);
    r.w = a.w + t * (b.w - a.w);

    return r;
} @NoProfile

nlerp :: inline (p0: Quaternion, p1: Quaternion, fraction: float) -> Quaternion {
    result := lerp(p0, p1, fraction);
	normalize_or_identity(*result);

    return result;
}

slerp :: (start: Quaternion, end: Quaternion, t: float) -> Quaternion {
    // Input quaternions should be unit length or else
    // something broken will happen.

    // The technique below will work for input vectors of any
    // number of dimensions (you could write a templatized version
    // of the code, or one that takes a generic N-vector data type,
    // and it would just work).


    // Compute the cosine of the angle between the two vectors.
    dot := dot_product(start, end);

    DOT_THRESHOLD :: 0.9995;
    if dot > DOT_THRESHOLD {
        // If the inputs are too close for comfort, linearly interpolate
        // and normalize the result.
        result := lerp(start, end, t);
        normalize_or_identity(*result);
        return result;
    }

    Clamp(*dot, -1, 1);
    theta_0 := acos(dot);  // Angle between input vectors
    theta   := theta_0 * t;  // Angle between 'start' and result

    e1 := start;
    e2 := end - start * dot;
    normalize_or_identity(*e2);              // { e1, e2 } is now an orthonormal basis

    return (e1 * cos(theta)) + (e2 * sin(theta));
}

dot_product :: (a: Quaternion, b: Quaternion) -> float {
    return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w;
}

operator + :: (a: Quaternion, b: Quaternion) -> Quaternion {
    return .{a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w};
}

operator * :: (a: Quaternion, k: float) -> Quaternion  #symmetric {
    return .{a.x*k, a.y*k, a.z*k, a.w*k};
}

operator - :: (a: Quaternion, b: Quaternion) -> Quaternion {
    return .{a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w};
}

operator == :: (a: Quaternion, b: Quaternion) -> bool {
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
}

operator - :: (using a: Quaternion) -> Quaternion {
    return .{-x, -y, -z, -w};
}

conjugate :: (using q: Quaternion) -> Quaternion {
    r: Quaternion = ---;
    r.x = -x;
    r.y = -y;
    r.z = -z;
    r.w = w;

    return r;
}

operator * :: (m: Quaternion, a: Quaternion) -> Quaternion {
    v  := m.xyz;
    av := a.xyz;

    r: Quaternion;
    r.w = m.w * a.w - dot(v, av);

    rv := cross(v, av);

    av *= m.w;
    v  *= a.w;

    rv = rv + av + v;

    r.x = rv.x;
    r.y = rv.y;
    r.z = rv.z;

    return r;

}

// == stdlib Modules/Math/cephes.jai
/*
Most of the code in this file comes from cephes:

Cephes Math Library Release 2.8:  June, 2000
Copyright 1984, 1995, 2000 by Stephen L. Moshier
*/



/*							ceil()
 *							floor()
 *							frexp()
 *							ldexp()
 *							signbit()
 *							isnan()
 *							isfinite()
 *
 *	Floating point numeric utilities
 *
 *
 * DESCRIPTION:
 *
 * All four routines return a double precision floating point
 * result.
 *
 * floor() returns the largest integer less than or equal to x.
 * It truncates toward minus infinity.
 *
 * ceil() returns the smallest integer greater than or equal
 * to x.  It truncates toward plus infinity.
 *
 * frexp() extracts the exponent from x.  It returns an integer
 * power of two to expnt and the significand between 0.5 and 1
 * to y.  Thus  x = y * 2**expn.
 *
 * ldexp() multiplies x by 2**n.
 *
 * signbit(x) returns 1 if the sign bit of x is 1, else 0.
 *
 * These functions are part of the standard C run time library
 * for many but not all C compilers.  The ones supplied are
 * written in C for either DEC or IEEE arithmetic.  They should
 * be used only if your compiler library does not already have
 * them.
 *
 * The IEEE versions assume that denormal numbers are implemented
 * in the arithmetic.  Some modifications will be required if
 * the arithmetic has abrupt rather than gradual underflow.
 */



// IMPORTANT:
// IMPORTANT:
// IMPORTANT:
// The cephes web site gave us permission to use the code, but
// we really should email the dude and get real serious permission
// before shipping this.   -jblow, 28 August 2018
// 'floor' was VERY HEAVILY modified; it doesn't even work the same
// basic way any more, but I did use the cephes routine as a starting
// point for the modifications.

ceil :: (x: float64) -> float64 {
    if !is_finite(x)     return x;

    y := floor(x);
    if y < x  y += 1;

    if (y == 0) && (x < 0)  return NEGATIVE_ZERO_64;

    return y;
}

// Someone in chat asked whether we should just implement floor
// by casting to int and back ... obviously we would need to check
// the exponent and return x if it's too high to fit. That might
// be simpler than this implementation, but it's still more of
// a hack than just using an intrinsic, so maybe we should just
// get our intrinsics figured out.
floor :: (x: float64) -> float64 {
    if !is_finite(x)     return x;
    if x == 0       return x;
    
    // Find the exponent (power of 2).
    uf := (cast(*u64)*x).*;
    e  := (cast(s32) ((uf >> 52) & 0x7ff)) - 1023;

    if e < 0 {
	    if x < 0   return -1;
        else       return 0;
	}

    e = (MANTISSA_BITS - 1) - e;
    
    mask : u64 = 0xffff_ffff_ffff_ffff;
    mask = mask << e;
    uf &= mask;

    result := (cast(*float64)*uf).*;
    if (x < 0) && (result != x) {  // This seems expensive, can we just determine that we did not make a change?
	    result -= 1.0;
    }
    
    return result;
}

ceil :: (f: float) -> float {
    return cast(float) ceil(cast(float64) f);
}

floor :: (f: float) -> float {
    return cast(float) floor(cast(float64) f);
}


/*							sin.c
 *
 *	Circular sine
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, sin();
 *
 * y = sin( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Range reduction is into intervals of pi/4.  The reduction
 * error is nearly eliminated by contriving an extended precision
 * modular arithmetic.
 *
 * Two polynomial approximating functions are employed.
 * Between 0 and pi/4 the sine is approximated by
 *      x  +  x**3 P(x**2).
 * Between pi/4 and pi/2 the cosine is represented as
 *      1  -  x**2 Q(x**2).
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain      # trials      peak         rms
 *    DEC       0, 10       150000       3.0e-17     7.8e-18
 *    IEEE -1.07e9,+1.07e9  130000       2.1e-16     5.4e-17
 * 
 * ERROR MESSAGES:
 *
 *   message           condition        value returned
 * sin total loss   x > 1.073741824e9      0.0
 *
 * Partial loss of accuracy begins to occur at x = 2**30
 * = 1.074e9.  The loss is not gradual, but jumps suddenly to
 * about 1 part in 10e7.  Results may be meaningless for
 * x > 2**49 = 5.6e14.  The routine as implemented flags a
 * TLOSS error for x > 2**30 and returns 0.0.
 */

/*							cos.c
 *
 *	Circular cosine
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, cos();
 *
 * y = cos( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Range reduction is into intervals of pi/4.  The reduction
 * error is nearly eliminated by contriving an extended precision
 * modular arithmetic.
 *
 * Two polynomial approximating functions are employed.
 * Between 0 and pi/4 the cosine is approximated by
 *      1  -  x**2 Q(x**2).
 * Between pi/4 and pi/2 the sine is represented as
 *      x  +  x**3 P(x**2).
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain      # trials      peak         rms
 *    IEEE -1.07e9,+1.07e9  130000       2.1e-16     5.4e-17
 *    DEC        0,+1.07e9   17000       3.0e-17     7.2e-18
 */

/*							sin.c	*/

/*
Cephes Math Library Release 2.8:  June, 2000
Copyright 1985, 1995, 2000 by Stephen L. Moshier
*/
/*
sincof :: float64.[
           1.58962301576546568060E-10,
           -2.50507477628578072866E-8,
           2.75573136213857245213E-6,
           -1.98412698295895385996E-4,
           8.33333333332211858878E-3,
           -1.66666666666666307295E-1,
          ];
coscof :: float64.[
           -1.13585365213876817300E-11,
           2.08757008419747316778E-9,
           -2.75573141792967388112E-7,
           2.48015872888517045348E-5,
           -1.38888888888730564116E-3,
           4.16666666666665929218E-2,
          ];
*/
DP1 :: 7.85398125648498535156E-1;
DP2 :: 3.77489470793079817668E-8;
DP3 :: 2.69515142907905952645E-15;
LOSSTH : float64 : 1.073741824e9; 

sin :: (x: float32) -> float32 { return cast(float32) sin(cast(float64) x); }
cos :: (x: float32) -> float32 { return cast(float32) cos(cast(float64) x); }



//
// We worked on this code a bunch to make it faster than base Cephes, and we did --
// by a more-than-2x speedup. However, now we are in a place where we are still
// slower than the Windows libc version, and it looks like the bottleneck now
// is just how much math we are doing. So maybe it would be fruitful to look
// at a different algorithm at this point, for something that approximates
// with fewer multiply-adds in some way.
//
// Alternatively, it seems we are still spending a fair chunk of CPU power just
// to do an fmod on x, essentially. So, if we had a faster way of doing that,
// we would be pretty good. Note that even though we have this variable j that
// is limited to a small positive number, for the math shown here, y has to stay big
// because x is big. That seems like an opportunity to fix something.
//
//    -jblow, 30 June 2020
//

sin_or_cos :: (x: float64, $IS_SIN: bool) -> float64 {
    #if IS_SIN  if x == 0 return x;

    sf := (cast(*s64)*x).*;
    exponent := cast(s32) ((sf >> 52) & 0x7ff);
    if exponent == 0x7ff {  // It is nan or inf. Replace with an intrinsic.
        if isnan(x) return x;  // @Cleanup: Redundancies...

        // It's not nan, so it's inf.

        // :MathError
        // @Incomplete: Do we signal errors in any other way? Programmer-only error log?
	    // mtherr( "sin", DOMAIN );
	    return FLOAT64_NAN;
    }

    /* make argument positive but save the sign */
    negate : s64 = 0;
    {
        //
        // The code here was:
        //
        //   if x < 0 {   // We could do a branch-free negate here if we really wanted to, like we do on returning, but ... is it worth it?
	    //       x = -x;
	    //       #if IS_SIN  negate = 1;
	    //   }
        //
        // But we wanted to do it in a branch-free way, so, you see the below:
        //
        flint: FloatInt64 = ---;
        flint._float64 = x;
        #if IS_SIN  negate = xx(flint._u64 >> 63);
        flint._u64 &= 0x7fff_ffff_ffff_ffff;
        x = flint._float64;
    }
    

    if x > LOSSTH {
        // :MathError
	    // mtherr( "sin", TLOSS );
	    return 0;
	}


    // We know x is not negative.
    // So taking the floor is the same as casting to int (casts round toward 0,
    // but when you're always positive, that is the floor).
    // Here we cast to s64, which will not preserve input angles greater than
    // 2**64, but, we don't have enough precision up there to sensibly perform
    // trig anyway -- and this algorithm already bailed out if the input angle
    // is higher than LOSSTH, which is only about 1 billion, way less than
    // 2**64.
    j := cast(s64)(x/PIO4);

    /* map zeros to origin */
    j += (j & 1);

    y := cast(float64) j;
    
    j = j & 0b111; /* octant modulo 360 degrees */  // But, the low bit actually cannot be 1, since we made j even above, so we could have masked by 0b110.

    // The code below used to be:
    //
    // if j > 3 {
	//    negate ^= 1;
	//    j -= 4;
    // }
    //
    // But we wanted to get rid of the 'if' statement, for performance, because
    // the branch predictor might have problems with it in many use cases.
    //
    // If j > 3, then j & 4, and furthermore, no higher bits are set on j.
    // So if we want to toggle 'negate' iff j > 3, we xor it with (j >> 2).
    // j -= 4 is the same as masking j & 2.
    //
    
    /* reflect in x axis */

    negate ^= (j >> 2);
    j = j & 2;  // Semi-redundant with & 6 above?!?
    
    // When we get to this point, j can only be 0 or 2.
    // Each increment of j represents 45 degrees, so 0 and 2 are one quadrant apart.
    // sin and cos want the same behavior, offset by one quadrant.
    #if !IS_SIN {
        // Here we wanted to do:
        //     if j  negate ^= 1;
        // But j can only be 2 or 0, so we toggle by j >> 1.
        negate ^= (j >> 1);
        j = xx !j;   // Should get optimized out alongside the if below.
    }
    
    /* Extended precision modular arithmetic */

    z := ((x - y * DP1) - y * DP2) - y * DP3;
    zz := z * z;
    
    r: float64 = ---;
    if j  r = 1.0 - zz*.5 + zz * zz * polynomial_eval_coscof5(zz);
	else  r = z  +  z * (zz * polynomial_eval_sincof5(zz));

    //
    // The code here to return the value was:
    //
    //    if negate  return -r;
    //    return r;
    //
    // But we want to return in a branch-free way, so, we do the thing
    // where we toggle the sign bit of the result if negate is 1.
    //
    flint: FloatInt64 = ---;
    flint._float64 = r;
    flint._u64 ^= xx,no_check(negate << 63);
    return flint._float64;
}

sin :: (x: float64) -> float64 {
    return inline sin_or_cos(x, true);
}

cos :: (x: float64) -> float64 {
    return inline sin_or_cos(x, false);
}



/*							atan.c
 *
 *	Inverse circular tangent
 *      (arctangent)
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, atan();
 *
 * y = atan( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns radian angle between -pi/2 and +pi/2 whose tangent
 * is x.
 *
 * Range reduction is from three intervals into the interval
 * from zero to 0.66.  The approximant uses a rational
 * function of degree 4/5 of the form x + x**3 P(x)/Q(x).
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       -10, 10     50000       2.4e-17     8.3e-18
 *    IEEE      -10, 10      10^6       1.8e-16     5.0e-17
 *
 */

atan :: inline (x: float64) -> float64 {
    if x == 0.0 return x;

    if x ==  INFINITY return  PIO2;
    if x == -INFINITY return -PIO2;

    sign: s16 = 1;

    if x < 0 {
	    sign = -1;
	    x = -x;
	}
    
    /* range reduction */

    flag: s16;  // @Cleanup: Remove flag?

    y: float64 = ---;
    if x > T3P8 {
	    y = PIO2;
	    flag = 1;
	    x = -1/x;
	} else if x <= 0.66 {
	    y = 0;
	} else {
	    y = PIO4;
	    flag = 2;
	    x = (x-1)/(x+1);
	}
    
    z := x * x;
    z = z * polynomial_eval(z, P, 4) / polynomial_eval_1(z, Q, 5);

    z = x * z + x;
    
    if flag == 2       z += 0.5 * MOREBITS;
    else if flag == 1  z += MOREBITS;

    y += z;

    if sign < 0  return -y;
    return y;
}

atan :: inline (y: float32) -> float32 { return cast(float32) atan(cast(float64)y); }


/*							atan2()
 *
 *	Quadrant correct inverse circular tangent
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, z, atan2();
 *
 * z = atan2( y, x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns radian angle whose tangent is y/x.
 * Range -PI < z <= +PI.
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    IEEE      -10, 10      10^6       2.5e-16     6.9e-17
 * See atan.c.
 *
 */

atan2 :: (y: float, x: float) -> float { return cast(float) atan2(cast(float64) y, cast(float64) x); }

atan2 :: (y: float64, x: float64) -> float64 {
    //
    // Here we have some preambles to check for nans, +/- zero, and infinities.
    // Original Cephes had ifdefs so that you could compile these out.
    // If you don't care about these, you could skip them. But really, I think
    // if you don't care about these, you are likely to be using some other
    // fast atan2 approximation anyway. Hard to say!
    //

    //
    // We did a substantial amount of streamlining here to remove
    // unnecessary assignments to variables, 'else's that didn't need
    // to be there, etc!
    //
    if isnan(x) return x;
    if isnan(y) return y;

    if y == 0 {  // 0.0 compares as equal to -0.0, so .. yeah.
	    if signbit(y) {
		    if x > 0  return y;
		    if x < 0  return -PI;

			if signbit(x) return -PI;
			return y;
		} else {
            // y is +0 if we get here.
		    if x == 0 {
			    if signbit(x) return PI;
			    return 0;
			}

            if x > 0   return 0;
            return PI;
		}
	}
    
    if x == 0 {
        if y > 0 return PIO2;
        return -PIO2;
	}
    
    if x == INFINITY {
	    if y == INFINITY  return 0.25 * PI;
	    if y == -INFINITY return -0.25 * PI;
	    if y < 0  	      return -0.0;

	    return 0;
	}
    
    if x == -INFINITY {
	    if y == INFINITY   return 0.75 * PI;
	    if y <= -INFINITY  return -0.75 * PI;
	    if y >= 0          return PI;
        
	    return -PI;
	}

    if y ==  INFINITY return  PIO2;
    if y == -INFINITY return -PIO2;

    code: s16;
    if x < 0  code = 2;
    if y < 0  code |= 1;

    if x == 0.0 {
	    if code & 1  return -PIO2;
	    if y == 0    return 0;

	    return PIO2;
	}

    if y == 0 {
	    if code & 2 return PI;
	    return 0;
	}

    z := atan(y/x);
    
    if      code == 2  z += PI;
    else if code == 3  z -= PI;

    if (z == 0) && (y < 0) z = -0.0;
    
    return z;
}

#scope_file 


/*							polevl.c
 *							p1evl.c
 *
 *	Evaluate polynomial
 *
 *
 *
 * SYNOPSIS:
 *
 * int N;
 * double x, y, coef[N+1], polevl[];
 *
 * y = polevl( x, coef, N );
 *
 *
 *
 * DESCRIPTION:
 *
 * Evaluates polynomial of degree N:
 *
 *                     2          N
 * y  =  C  + C x + C x  +...+ C x
 *        0    1     2          N
 *
 * Coefficients are stored in reverse order:
 *
 * coef[0] = C  , ..., coef[N] = C  .
 *            N                   0
 *
 *  The function p1evl() assumes that coef[N] = 1.0 and is
 * omitted from the array.  Its calling arguments are
 * otherwise the same as polevl().
 *
 *
 * SPEED:
 *
 * In the interest of speed, there are no checks for out
 * of bounds arithmetic.  This routine is used by most of
 * the functions in the library.  Depending on available
 * equipment features, the user may wish to rewrite the
 * program in microcode or assembly language.
 *
 */

/*
Cephes Math Library Release 2.1:  December, 1988
Copyright 1984, 1987, 1988 by Stephen L. Moshier
Direct inquiries to 30 Frost Street, Cambridge, MA 02140
*/


// Speed idea! We can mark polynomial_* as inline, and also make N
// a compile-time constant, and have some nice inlined guaranteed
// loop unroll action!

polynomial_eval :: (x: float64, coef: [] float64, N: s32) -> float64 {
    ans := coef[0];

    for 1..N  ans = ans * x + coef[it];
    
    return ans;
}

polynomial_eval_coscof5 :: inline (x: float64) -> float64 {
    x2 := x*x;
    x4 := x2*x2;

    return (-1.13585365213876817300E-11*x + 2.08757008419747316778E-9)*x4 +
           (-2.75573141792967388112E-7*x  + 2.48015872888517045348E-5)*x2 +
            -1.38888888888730564116E-3*x  + 4.16666666666665929218E-2;
}

polynomial_eval_sincof5 :: inline (x: float64) -> float64 {
    x2 := x*x;
    x4 := x2*x2;

    return (1.58962301576546568060E-10*x -  2.50507477628578072866E-8)*x4 +
           (2.75573136213857245213E-6*x  -  1.98412698295895385996E-4)*x2 +
            8.33333333332211858878E-3*x  -  1.66666666666666307295E-1;
}

/*							polynomial_eval_1()	*/
/*                                          N
 * Evaluate polynomial when coefficient of x  is 1.0.
 * Otherwise same as polevl.
 */

polynomial_eval_1 :: (x: float64, coef: [] float64, N: s32) -> float64 {
    ans := x + coef[0];

    for 1..N-1  ans = ans * x + coef[it];

    return ans;
}


MANTISSA_BITS  :: 53;
NEGATIVE_ZERO_64 :: 0h8000_0000_0000_0000;

MOREBITS :: 6.123233995736765886130e-17;

INFINITY :: FLOAT64_INFINITY;

PIO2  :: 0h3ff9_21fb_5444_2d18;
PIO4  :: 0h3fe9_21fb_5444_2d18;
LOG2E :: 0h3ff7_1547_652b_82fe;

/* log2(e) - 1 */
// @Incomplete: Why is this not a hexfloat?
LOG2EA :: 0.44269504088896340736;


/* tan( 3*pi/8 ) */
T3P8 :: 2.41421356237309504880;

P :: float64.[
      0hbfec007fa1f72594,  // -8.750608600031904122785e-1
      0hc03028545b6b807a,  // -1.615753718733365076637e1
      0hc052c08c36880273,  // -7.500855792314704667340e1
      0hc05eb8bf2d05ba25,  // -1.228866684490136173410e2
      0hc0503669fd28ec8e   // -6.485021904942025371773e1
];

Q :: float64.[
      /* 1.000000000000000000000e0, */
      0h4038dbc45b14603c,  // 2.485846490142306297962e1
      0h4064a0dd43b8fa25,  // 1.650270098316988542046e2
      0h407b0e18d2e2be3b,  // 4.328810604912902668951e2
      0h407e563f13b049ea,  // 4.853903996359136964868e2
      0h4068519efbbd62ec   // 1.945506571482613964425e2
];

FloatInt64 :: union {
    _u64:     u64;
    _s64:     s64;
    _float64: float64;
}

signbit :: inline (x: float64) -> u64 {
    value: FloatInt64 = ---;
    value._float64 = x;
    return value._u64 & 0x8000_0000_0000_0000;
}





/*
 *	Square root
 *
 * SYNOPSIS:
 *
 * double x, y, sqrt();
 *
 * y = sqrt( x );
 *
 *
 * DESCRIPTION:
 *
 * Returns the square root of x.
 *
 * Range reduction involves isolating the power of two of the
 * argument and using a polynomial approximation to obtain
 * a rough value for the square root.  Then Heron's iteration
 * is used three times to converge to an accurate value.
 *
 *
 * ACCURACY:
 *
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       0, 10       60000       2.1e-17     7.9e-18
 *    IEEE      0,1.7e308   30000       1.7e-16     6.3e-17
 *
 *
 * ERROR MESSAGES:
 *
 *   message         condition      value returned
 * sqrt domain        x < 0            0.0
 *
 */

/*
Cephes Math Library Release 2.8:  June, 2000
Copyright 1984, 1987, 1988, 2000 by Stephen L. Moshier
*/

#scope_export
frexp :: (x: float64) -> (result: float64, pow2: s32) {
    union {
	    _float64: float64;
        _u64:     u64;
    }

    _float64 = x;
    i  :=  cast(s32)(_u64 >> 52);
    i &= 0x7ff;
    if i == 0 {
        // Handle denormal numbers.
        // Could static-if this, as the cephes code does...?

        k: s32;
        while 1 {
	        _float64 *= 2.0;
	        i -= 1;
	        k := cast(s32)(_u64 >> 52) & 0x7ff;

            if k != 0  break;
	    }

        i = i + k;
    }

    i -= 0x3fe;
    _u64 &= 0x800f_ffff_ffff_ffff;  // @Speed: Could just AND 16 bits depending on endian, as C cephes does? We just need to have a global that tells us endian, which we currently do not...
    _u64 |= 0x3fe0_0000_0000_0000;

    return _float64, i;
}

ldexp :: (x: float64, pw2: s32) -> float64 {
    union {
        _float64: float64;
        _u64:     u64;
    };

    _float64 = x;

    e: s32;
    while 1 {
        e = cast(s32)((_u64 & 0x7ff0_0000_0000_0000) >> 52);
        if e != 0  break;

	    if _float64 == 0  return 0;

        /* Input is denormal. */
	    if pw2 > 0  {
		    _float64 *= 2;
		    pw2 -= 1;
		}
        
	    if pw2 < 0 {
		    if pw2 < -53  return 0;
		    _float64 *= .5;
		    pw2 += 1;
		}
        
	    if pw2 == 0  return _float64;
	}

    e += pw2;

    // Handle overflow.
    MEXP :: 0x7ff;
    MAXNUM :: 0h7fef_ffff_ffff_ffff;
    if e >= MEXP  return 2*MAXNUM;
    
    // Handle denormalized results.
    if e < 1 {
        DENORMAL :: 1;
        #if DENORMAL {
	        if e < -53  return 0;

	        _u64 &= 0x800f_ffff_ffff_ffff;
	        _u64 |= 0x0010_0000_0000_0000;
	        /* For denormals, significant bits may be lost even
         	   when dividing by 2.  Construct 2^-(1-e) so the result
         	   is obtained with only one multiplication.  */

	        _float64 *= ldexp(1.0, e-1);
	        return _float64;
        } else {
	        return 0;
        }
	} else {
        _u64 &= 0x800f_ffff_ffff_ffff;
	    _u64 |= (cast(u64)(e & 0x7ff)) << 52;

        return _float64;
	}
}


SQRT2 :: 1.41421356237309504880;

sqrt :: (x: float64) -> float64 {
    if x <= 0 {
	    if x < 0 {
            log_error("Invalid argument to sqrt: %\n", x);
        }
        
        return 0;
	}
    
    /* separate exponent and significand */
    /* Note, frexp and ldexp are used in order to
     * handle denormal numbers properly.
     */
    z, e := frexp(x);

    w := x;
    
    /* approximate square root of number between 0.5 and 1
     * relative error of approximation = 7.47e-3
     */
    x = 4.173075996388649989089E-1 + 5.9016206709064458299663E-1 * z;

    /* adjust for odd powers of 2 */
    if e & 1  x *= SQRT2;

    // Newton iterations:

    x = ldexp(x, (e >> 1));

    x = 0.5*(x+w/x);
    x = 0.5*(x+w/x);
    x = 0.5*(x+w/x);

    return x;
}



/*
 *
 *	Natural logarithm
 *
 *
 * SYNOPSIS:
 *
 * double x, y, log();
 *
 * y = log( x );
 *
 *
 * DESCRIPTION:
 *
 * Returns the base e (2.718...) logarithm of x.
 *
 * The argument is separated into its exponent and fractional
 * parts.  If the exponent is between -1 and +1, the logarithm
 * of the fraction is approximated by
 *
 *     log(1+x) = x - 0.5 x**2 + x**3 P(x)/Q(x).
 *
 * Otherwise, setting  z = 2(x-1)/x+1),
 * 
 *     log(x) = z + z**3 P(z)/Q(z).
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    IEEE      0.5, 2.0    150000      1.44e-16    5.06e-17
 *    IEEE      +-MAXNUM    30000       1.20e-16    4.78e-17
 *    DEC       0, 10       170000      1.8e-17     6.3e-18
 *
 * In the tests over the interval [+-MAXNUM], the logarithms
 * of the random arguments were uniformly distributed over
 * [0, MAXLOG].
 *
 * ERROR MESSAGES:
 *
 * log singularity:  x = 0; returns -INFINITY
 * log domain:       x < 0; returns NAN
 */

/*
Cephes Math Library Release 2.8:  June, 2000
Copyright 1984, 1995, 2000 by Stephen L. Moshier
*/

/* Coefficients for log(1+x) = x - x**2/2 + x**3 P(x)/Q(x)
 * 1/sqrt(2) <= x < sqrt(2)
 */

SQRTH :: 0.70710678118654752440;

log :: (x: float64) -> float64 {
    // @Feature: The log2 function in cephes is mostly copypasta
    // from log10, with a few lines of code difference; we could
    // make a log_10_or_2 function with a bakeable parameter
    // that switches between.

    if isnan(x) return x;
    if x ==  INFINITY return x;
    if x == -INFINITY return x;
    
    /* Test for domain */
    if x <= 0 {
        log_error("Invalid argument to log(): %\n", x);
	    if x == 0 return -INFINITY;
        else      return FLOAT64_NAN;
	}

    /* separate mantissa from exponent */
    e: s32;
    x, e = frexp(x);

    /* logarithm using log(x) = z + z**3 P(z)/Q(z),
     * where z = 2(x-1)/x+1)
     */

    if (e > 2) || (e < -2) {
        y, z: float64 = ---;
        
        if x < SQRTH  {
	        // 2( 2x-1 )/( 2x+1 )
	        e -= 1;
	        z = x - 0.5;
	        y = 0.5 * z + 0.5;
	    } else {
            //  2 (x-1)/(x+1) 
	        z = x - 0.5;
	        z -= 0.5;
	        y = 0.5 * x  + 0.5;
	    }


        x = z / y;


        /* Coefficients for log(x) = z + z**3 P(z)/Q(z),
         * where z = 2(x-1)/(x+1)
         * 1/sqrt(2) <= x < sqrt(2)
         */

        R :: float64.[
            0hbfe9_443d_dc6c_0e84,
            0h4030_62fc_7302_7b6b,
            0hc050_0906_1122_2a20,
        ];

        S :: float64.[
            1,
            0hc041_d60d_43ec_6d0a,
            0h4073_8180_112a_e40e,
            0hc088_0d89_19b3_3f3b
        ];

        /* rational form */
        z = x*x;
        z = x * (z * polynomial(z, R) / polynomial(z, S));
        y = cast(float64)e; // wtf... why not just factor e into the next line?
        z = z - y * 2.121944400546905827679e-4;
        z = z + x;
        z = z + e * 0.693359375;

        return z;
    }

    /* logarithm using log(1+x) = x - .5x**2 + x**3 P(x)/Q(x) */

    if x < SQRTH {
	    e -= 1;
	    x = ldexp(x, 1) - 1; /*  2x - 1  */
	} else {
	    x = x - 1;
	}

    
    P :: float64.[
        0h3f1a_b4c2_93c3_1bb0,
        0h3fdf_d6f5_3f56_52f2,
        0h4012_d2ba_ed92_6911,
        0h402c_ff72_c63e_eb2e,
        0h4031_efd6_924b_c84d,
        0h401e_d563_7d7e_dcf8
    ];

    Q :: float64.[
        1,
        0h4026_9320_ae97_ef8e,
        0h4046_9d2c_4e19_c033,
        0h4054_bf33_a326_bdbd,
        0h4051_c9e2_eb5e_ae21,
        0h4037_200a_9e1f_25b2
    ];

    /* rational form */
    z := x*x;
    y := x * (z * polynomial(x, P) / polynomial(x, Q));

    if e  y = y - e * 2.121944400546905827679e-4;
    y = y - ldexp(z, -1);   /*  y - 0.5 * z  */
    z = x + y;
    if e  z = z + e * 0.693359375;

    return z;
}




/*							tan.c
 *
 *	Circular tangent
 *
 *
 * DESCRIPTION:
 *
 * Returns the circular tangent of the radian argument x.
 *
 * Range reduction is modulo pi/4.  A rational function
 *       x + x**3 P(x**2)/Q(x**2)
 * is employed in the basic interval [0, pi/4].
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC      +-1.07e9      44000      4.1e-17     1.0e-17
 *    IEEE     +-1.07e9      30000      2.9e-16     8.1e-17
 *
 * ERROR MESSAGES:
 *
 *   message         condition          value returned
 * tan total loss   x > 1.073741824e9     0.0
 *
 */
/*							cot.c
 *
 *	Circular cotangent
 *
 *
 * DESCRIPTION:
 *
 * Returns the circular cotangent of the radian argument x.
 *
 * Range reduction is modulo pi/4.  A rational function
 *       x + x**3 P(x**2)/Q(x**2)
 * is employed in the basic interval [0, pi/4].
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    IEEE     +-1.07e9      30000      2.9e-16     8.2e-17
 *
 *
 * ERROR MESSAGES:
 *
 *   message         condition          value returned
 * cot total loss   x > 1.073741824e9       0.0
 * cot singularity  x = 0                  INFINITY
 *
 */


tan :: (x: float64) -> float64 {
    if x == 0  return x;

    if isnan(x) return x;
    if !is_finite(x) {
        log_error("Invalid argument to tan(): %\n", x);
        return FLOAT64_NAN;
    }

    return tancot(x, false);
}

cot :: (x: float64) -> float64 {
    if x == 0 {
	    log_error("Invalid argument to cot(): %\n", x);
	    return FLOAT64_INFINITY;
	}
    
    return tancot(x, true);
}


#scope_file

TANCOT_P :: float64.[
    0hc0c9_92d8_d24f_3f38,
    0h4131_99ec_a5fc_9ddd,
    0hc171_1fea_d329_9176
];

TANCOT_Q :: float64.[
    1,
    0h40ca_b8a5_eeb3_6572,
    0hc134_27bc_582a_bc96,
    0h4177_d98f_c2ea_d8ef,
    0hc189_afe0_3cbe_5a31
];

tancot :: (input_x: float64, $is_cotangent: bool) -> float64 {

    lossth : float64 : 1.073741824e9;

    // make argument positive but save the sign.

    x: float64 = ---;
    sign: float64 = ---;
    if input_x < 0  {
	    x = -input_x;
	    sign = -1;
	} else {
	    x = input_x;
	    sign = 1;
	}

    if x > lossth {
        NAME :: #ifx is_cotangent then "cot" else "tan";  
        log_error("Argument to %() is too high: %\n", NAME, x);
        return 0;
    }

    /* compute x mod PIO4 */
    y := floor( x/PIO4 );

    /* strip high bits of integer part */
    z := ldexp( y, -3 );
    z = floor(z);		/* integer part of y/8 */
    z = y - ldexp( z, 3 );  /* y - 16 * (y/16) */

    /* integer and fractional part modulo one octant */
    j := cast(s32) z;

    /* map zeros and singularities to origin */
    if j & 1 {
	    j += 1;
	    y += 1.0;
	}

    DP1 :: 0h3fe9_21fb_4000_0000;
    DP2 :: 0h3e64_442d_0000_0000;
    DP3 :: 0h3ce8_4698_98cc_5170;

    z = ((x - y * DP1) - y * DP2) - y * DP3;

    zz := z * z;

    if zz > 1.0e-14 {
	    y = z + z * (zz * polynomial(zz, TANCOT_P)/polynomial(zz, TANCOT_Q));
    } else {
	    y = z;
    }
	
    if j & 2 {
	    if is_cotangent y = -y;
	    else y = -1/y;
	} else {
	    if is_cotangent y = 1/y;
	}

    return y * sign;
}

/*							asin.c
 *
 *	Inverse circular sine
 *
 *
 * DESCRIPTION:
 *
 * Returns radian angle between -pi/2 and +pi/2 whose sine is x.
 *
 * A rational function of the form x + x**3 P(x**2)/Q(x**2)
 * is used for |x| in the interval [0, 0.5].  If |x| > 0.5 it is
 * transformed by the identity
 *
 *    asin(x) = pi/2 - 2 asin( sqrt( (1-x)/2 ) ).
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC      -1, 1        40000       2.6e-17     7.1e-18
 *    IEEE     -1, 1        10^6        1.9e-16     5.4e-17
 *
 *
 * ERROR MESSAGES:
 *
 *   message         condition      value returned
 * asin domain        |x| > 1           NAN
 *
 */
/*							acos()
 *
 *	Inverse circular cosine
 *
 *
 * DESCRIPTION:
 *
 * Returns radian angle between 0 and pi whose cosine
 * is x.
 *
 * Analytically, acos(x) = pi/2 - asin(x).  However if |x| is
 * near 1, there is cancellation error in subtracting asin(x)
 * from pi/2.  Hence if x < -0.5,
 *
 *    acos(x) =	 pi - 2.0 * asin( sqrt((1+x)/2) );
 *
 * or if x > +0.5,
 *
 *    acos(x) =	 2.0 * asin(  sqrt((1-x)/2) ).
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       -1, 1       50000       3.3e-17     8.2e-18
 *    IEEE      -1, 1       10^6        2.2e-16     6.5e-17
 *
 *
 * ERROR MESSAGES:
 *
 *   message         condition      value returned
 * asin domain        |x| > 1           NAN
 */

#scope_export
asin :: (x: float64) -> float64 {
    /* pi/2 = PIO2 + MOREBITS.  */
    MOREBITS :: 6.123233995736765886130E-17;

    sign: float64 = ---;
    a:    float64 = ---;
    if x > 0 {
	    sign = 1;
	    a = x;
	} else {
	    sign = -1;
	    a = -x;
	}

    if a > 1 {
        if (a > ASIN_AND_ACOS_ERROR_REPORTING_LIMIT) {
	        log_error("Argument to asin() is out of range: %\n", x);
	        return FLOAT64_NAN;
        }

        // Allow people to call us with a little bit of slop, like a dot product result.
        a = 1;
	}

    if a > 0.625 {
        // arcsin(1-x) = pi/2 - sqrt(2x)(1+R(x))
        // 0 <= x <= 0.5
        // Peak relative error = 4.2e-18
        
        R :: float64.[
            0h3f68_4fc3_988e_9f08,
            0hbfe2_0792_59f9_290f,
            0h401b_dff5_baf3_3e6a,
            0hc039_91aa_ac01_ab68,
            0h403c_8962_40f3_081d,
        ];

        S :: float64.[
            1,
            0hc035_f2a2_b6bf_5d8c,
            0h4062_6219_af6a_7f42,
            0hc077_fe08_9590_63ee,
            0h4075_6709_b0b6_44be,
        ];

	    zz := 1.0 - a;
	    p := zz * polynomial(zz, R)/polynomial(zz, S);
	    zz = sqrt(zz+zz);
	    z := PIO4 - zz;
	    zz = zz * p - MOREBITS;
	    z = z - zz;
	    z = z + PIO4;

        return z * sign;
	} else {
        // arcsin(x)  =  x + x^3 P(x^2)/Q(x^2)
        // 0 <= x <= 0.625
        // Peak relative error = 1.2e-18 
        P :: float64.[
            0h3f71_6b9b_0bd4_8ad3,
            0hbfe3_4341_333e_5c16,
            0h4015_c74b_178a_2dd9,
            0hc030_4331_de27_907b,
            0h4033_9007_da77_9259,
            0hc020_656c_06ce_afd5,
        ];
        
        Q :: float64.[
            1,
            0hc02d_7b59_0b5e_0eab,
            0h4051_9fc0_25fe_9054,
            0hc062_65bb_6d35_76d7,
            0h4061_7056_84ff_bf9d,
            0hc048_9822_0a36_07ac,
        ];

	    if a < 1.0e-8  return x;

	    zz := a * a;
	    z := zz * polynomial(zz, P)/polynomial(zz, Q);
	    z = a * z + a;
        
        return z * sign;
	}
}


ASIN_AND_ACOS_ERROR_REPORTING_LIMIT :: 1.000001;

acos :: (x: float64) -> float64 {
    // Do some basic range checking.
    if (x < -1) || (x > 1) {
        if (x < -ASIN_AND_ACOS_ERROR_REPORTING_LIMIT) || (x > ASIN_AND_ACOS_ERROR_REPORTING_LIMIT) {
	        log_error("Argument to acos() is out of range: %\n", x);
	        return FLOAT64_NAN;
        }

        // Allow people to call us with a little bit of slop, like a dot product result.
        if x < -1  x = -1;
        if x >  1  x =  1;

        // It's a bit @Redunant since we also do some range-checking inside asin.
	}

    if x > 0.5 	{
        return(2 * asin(sqrt(0.5 - 0.5*x)));  // Do we know that this will not magnify error in x? Hmm.
    }

    z := PIO4 - asin(x);
    z = z + MOREBITS;
    z = z + PIO4;

    return z;
}

/*
 *
 *	Exponential function
 *
 *
 * DESCRIPTION:
 *
 * Returns e (2.71828...) raised to the x power.
 *
 * Range reduction is accomplished by separating the argument
 * into an integer k and fraction f such that
 *
 *     x    k  f
 *    e  = 2  e.
 *
 * A Pade' form  1 + 2x P(x**2)/( Q(x**2) - P(x**2) )
 * of degree 2/3 is used to approximate exp(f) in the basic
 * interval [-0.5, 0.5].
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       +- 88       50000       2.8e-17     7.0e-18
 *    IEEE      +- 708      40000       2.0e-16     5.6e-17
 *
 *
 * Error amplification in the exponential function can be
 * a serious matter.  The error propagation involves
 * exp( X(1+delta) ) = exp(X) ( 1 + X*delta + ... ),
 * which shows that a 1 lsb error in representing X produces
 * a relative error of X times 1 lsb in the function.
 * While the routine gives an accurate result for arguments
 * that are exactly represented by a double precision
 * computer number, the result contains amplified roundoff
 * error for large arguments not exactly represented.
 *
 *
 * ERROR MESSAGES:
 *
 *   message         condition      value returned
 * exp underflow    x < MINLOG         0.0
 * exp overflow     x > MAXLOG         INFINITY
 *
 */

//
// Note, 17 December 2022:
//
// This is not as accurate as the Windows libc exp() and I am a little
// worried about that. Can we just give it a longer polynomial? Or do we
// need to do something different here?  -jblow
//

/*	Exponential function	*/

exp :: (x: float64) -> float64 {
    if isnan(x) return x;

    MAXLOG ::  170.0;
    MINLOG :: -170.0;
    if x > MAXLOG  return FLOAT64_INFINITY;
    if x < MINLOG  return 0;

    // Express e**x = e**g 2**n
    //   = e**g e**( n loge(2) )
    //   = e**( g + n loge(2) )
    //
    
    px := floor(LOG2E * x + 0.5); /* floor() truncates toward -infinity. */
    n := cast(s32) px;

    C1 :: 0h3fe6_2e40_0000_0000;
    C2 :: 0h3eb7_f7d1_cf79_abca;

    x -= px * C1;
    x -= px * C2;

    // rational approximation for exponential
    // of the fractional part:
    // e**x = 1 + 2x P(x**2)/( Q(x**2) - P(x**2) )
    //

    P :: float64.[
        0h3f20_89cd_d5e4_4be8,
        0h3f9f_06d1_0cca_2c7e,
        0h3ff0_0000_0000_0000,
    ];

    Q :: float64.[
        0h3ec9_2eb6_bc36_5fa0,
        0h3f64_ae39_b508_b6c0,
        0h3fcd_1709_9887_e074,
        0h4000_0000_0000_0000,
    ];

    XX := x * x;
    px = x * polynomial(XX, P);
    x =  px/(polynomial(XX, Q) - px);
    x = 1 + 2 * x;

    /* multiply by power of 2 */
    x = ldexp(x, n);
    return x;
}



/*
 *
 *	Power function
 *
 *
 * DESCRIPTION:
 *
 * Computes x raised to the yth power.  Analytically,
 *
 *      x**y  =  exp( y log(x) ).
 *
 * Following Cody and Waite, this program uses a lookup table
 * of 2**-i/16 and pseudo extended precision arithmetic to
 * obtain an extra three bits of accuracy in both the logarithm
 * and the exponential.
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    IEEE     -26,26       30000      4.2e-16      7.7e-17
 * 1/26 < x < 26, with log(x) uniformly distributed.
 * -26 < y < 26, y uniformly distributed.
 *    IEEE     0,8700       30000      1.5e-14      2.1e-15
 * 0.99 < x < 1.01, 0 < y < 8700, uniformly distributed.
 *
 *
 * ERROR MESSAGES:
 *
 *   message         condition      value returned
 * pow overflow     x**y > MAXNUM      INFINITY
 * pow underflow   x**y < 1/MAXNUM       0.0
 * pow domain      x<0 and y noninteger  0.0
 *
 */

//
// Note: This function is off by a few significant digits relative to
// the Windows implementation, and it is also a mess, so we would like
// to substitute it with something else.  -jblow, 18 December 2022
//

#scope_export 
pow :: (x: float64, y: float64) -> float64 {
    if y == 0    return 1;

    if isnan(x)  return x;
    if isnan(y)  return y;

    if y == 1    return x;

    if !is_finite(y) && ((x == 1) || (x == -1)) {
	    log_error("Invalid arguments to pow(): (%, %)\n", x, y);
        return FLOAT64_NAN;
	}

    if x == 1  return 1;

    MAXNUM :: 0h7fef_ffff_ffff_ffff;
    if y >= MAXNUM {
	    if x > 1  return INFINITY;
	    if (x > 0) && (x < 1)  return 0;

	    if x < -1 return INFINITY;

	    if (x > -1) && (x < 0)  return 0;
	}

    if y <= -MAXNUM {
	    if x > 1  return 0;
	    if (x > 0) && (x < 1)  return INFINITY;

	    if x < -1  return 0;
	    if (x > -1) && (x < 0) return INFINITY;
	}

    if x >= MAXNUM {
	    if y > 0  return( INFINITY );
	    return 0;
	}

    /* Set iyflg to 1 if y is an integer.  */
    w := floor(y);
    y_is_integer := (w == y);

    /* Test for odd integer y.  */
    y_is_odd := false;
    if y_is_integer {
	    ya := abs(y);
	    ya  = floor(0.5 * ya);
	    yb := 0.5 * abs(w);

	    y_is_odd = (ya != yb);
	}

    if x <= -MAXNUM {
	    if y > 0 {
		    if y_is_odd return -INFINITY;
		    return INFINITY;
		}
        
	    if y < 0 {
		    return ifx y_is_odd then NEGATIVE_ZERO_64 else 0;
		}
 	}

    nflg: bool;	/* flag = 1 if x<0 raised to integer power */

    if x <= 0 {
	    if x == 0 {
		    if y < 0 {
			    if signbit(x) && y_is_odd return -INFINITY;
			    return INFINITY;
			}
            
		    if y > 0 {
			    return ifx signbit(x) && y_is_odd then NEGATIVE_ZERO_64;
			}

		    return 1;
		} else {
		    if !y_is_integer {
			    /* noninteger power of negative number */
			    log_error("Invalid arguments to pow(): (%, %)\n", x, y);
			    return FLOAT64_NAN;
			}

		    nflg = true;
		}
	}


    /*
    /* Integer power of an integer.  */
    // @Cleanup: Why is this code here? Is it just to avoid using the FPU
    // for speed purposes in older computers? Because nowadays it is probably
    // faster to use the FPU than to do this integer stuff, before you even talk
    // about the branching etc.

    // Actually there is kind of a reason to keep this here, which is to preserve
    // exactness for integer-stored-in-double inputs. But I don't think we need
    // to spec pow to preserve that. So let's just remove this code please.
    
    if y_is_integer {
	    i = w;
	    w = floor(x);
	    if( (w == x) && (fabs(y) < 32768.0) )
		{
		    w = powi( x, (int) y );
		    return( w );
		}
	}
    */

    if nflg  x = abs(x);  // We could move this to the place where nflg is set, and remove the 'if', presuming the intervening code stays deleted.

    /* For results close to 1, use a series expansion.  */
    w   = x - 1.0;
    aw := abs(w);
    ay := abs(y);
    wy := w * y;
    ya := abs(wy);

    ReturnZ :: () #expand {  // The old code used a goto, which we don't support at this time.
        /* Negate if odd integer power of negative number */
        if nflg && y_is_odd {
	        if z == 0  z = NEGATIVE_ZERO_64;
            else z = -z;
	    }

        `return z;
    }

    z: float64 = ---;
    if ((aw <= 1.0e-3) && (ay <= 1)) || ((ya <= 1.0e-3) && (ay >= 1)) {
	    z = (((((w*(y-5)/720 + 1/120.0)*w*(y-4) + 1/24.0)*w*(y-3)
		       + 1/6.0)*w*(y-2) + 0.5)*w*(y-1) )*wy + wy + 1;
        ReturnZ();
	}

    /* separate significand from exponent */
    e: s32;
    x, e = frexp(x);

    /*
    #if 0
    /* For debugging, check for gross overflow. */
    if( (e * y)  > (MEXP + 1024) )
    	goto overflow;
    #endif
    */

    A :: float64.[
        0h3ff0_0000_0000_0000, 0h3fee_a4af_a2a4_90da, 0h3fed_5818_dcfb_a487, 0h3fec_199b_dd85_529c,
        0h3fea_e89f_995a_d3ad, 0h3fe9_c491_82a3_f090, 0h3fe8_ace5_422a_a0db, 0h3fe7_a114_73eb_0187,
        0h3fe6_a09e_667f_3bcd, 0h3fe5_ab07_dd48_5429, 0h3fe4_bfda_d536_2a27, 0h3fe3_dea6_4c12_3422,
        0h3fe3_06fe_0a31_b715, 0h3fe2_387a_6e75_6238, 0h3fe1_72b8_3c7d_517b, 0h3fe0_b558_6cf9_890f,
        0h3fe0_0000_0000_0000
    ];

    B :: float64.[
        0,
        0h3c72_ed02_d75b_3707, 0h3c87_a1cd_345d_cc81, 0h3c86_e9f1_5686_4b27,
        0hbc8b_dd34_13b2_6456, 0h3c6d_4397_afec_42e2, 0h3c76_f46a_d231_82e4, 0hbc71_9041_b9d7_8a76,
        0
    ];
    
    /* Find significand of x in antilog table A[]. */
    i: s32 = 1;
    if x <= A[9]   i = 9;
    if x <= A[i+4] i += 4;
    if x <= A[i+2] i += 2;
    if x >= A[1]   i = -1;
    i += 1;


/* Find (x - A[i])/A[i]
 * in order to compute log(x/A[i]):
 *
 * log(x) = log( a x/a ) = log(a) + log(x/a)
 *
 * log(x/a) = log(1+v),  v = x/a - 1 = (x-a)/a
 */
    x -= A[i];
    x -= B[i/2];
    x /= A[i];

/* rational approximation for log(1+v):
 *
 * log(1+v)  =  v  -  v**2/2  +  v**3 P(v) / Q(v)
 */
    P :: float64.[
        0h3fdf_db99_7f5b_5cf0,
        0h400d_ddef_ea9e_df15,
        0h401e_ccbd_7f78_eb6f,
        0h4012_aa83_b65c_9b74
    ];

    Q :: float64.[
        0h4022_aab4_9b20_914e,
        0h403b_ffff_41c1_c9f5,
        0h4040_ccbc_1b17_6402,
        0h402b_ffc5_918a_e92e
    ];

    z = x*x;
    w = x * (z * polynomial(x, P) / polynomial(x, Q));
    w = w - ldexp( z, -1 );   /*  w - 0.5 * z  */

    /* Convert to base 2 logarithm:
     * multiply by log2(e)
     */
    w = w + LOG2EA * w;
    
    /* Note x was not yet added in
     * to above rational approximation,
     * so do it now, while multiplying
     * by log2(e).
     */
    z = w + LOG2EA * x;
    z = z + x;

    /* Compute exponent term of the base 2 logarithm. */
    w = cast(float64) -i;
    w = ldexp(w, -4);	/* divide by 16 */
    w += e;

    /* Now base 2 log of x is w + z. */

    /* Multiply base 2 log by y, in extended precision. */

    /* separate y into large part ya
     * and small part yb less than 1/16
     */

    ya = reduc(y);
    yb := y - ya;

    F  := z * y  +  w * yb;
    Fa := reduc(F);
    Fb := F - Fa;

    G  := Fa + w * ya;
    Ga := reduc(G);
    Gb := G - Ga;

    H  := Fb + Gb;
    Ha := reduc(H);
    w = ldexp(Ga+Ha, 4);

    MEXP  :: 16383.0;
    MNEXP :: -17183.0;
    // If !DENORMAL, MNEXP :: -16383.0;

    /* Test the power of 2 for overflow */
    if w > MEXP { 
	    return ifx nflg && y_is_odd  then -INFINITY else INFINITY;
	}

    if w < (MNEXP - 1) {
	    return ifx nflg && y_is_odd then NEGATIVE_ZERO_64;
	}

    e = cast(s32) w;
    Hb := H - Ha;

    if Hb > 0 {
	    e += 1;
	    Hb -= 0.0625;
	}

    R :: float64.[
        0h3eef_6307_d7f2_937f,
        0h3f24_2fbe_60fc_9259,
        0h3f55_d87e_c84a_ef1d,
        0h3f83_b2ab_6ef1_33b7,
        0h3fac_6b08_d704_1a92,
        0h3fce_bfbd_ff82_c56d,
        0h3fe6_2e42_fefa_39ef
    ];

    /* Now the product y * log2(x)  =  Hb + e/16.0.
     *
     * Compute base 2 exponential of Hb,
     * where -0.0625 <= Hb <= 0.
     */
    z = Hb * polynomial(Hb, R);  /*    z  =  2**Hb - 1    */

    /* Express e/16 as an integer plus a negative number of 16ths.
     * Find lookup table entry for the fractional power of 2.
     */

    {
        // Note: New i!
        i := cast(s32) (e >= 0);

        i = e/16 + i;
        e = 16*i - e;
        w = A[e];
        z = w + w * z;      /*    2**-e * ( 1 + (2**Hb-1) )    */
        z = ldexp(z, i);  /* multiply by integer power of 2 */
    }
    
    ReturnZ();
}


/* Find a multiple of 1/16 that is within 1/16 of x. */
reduc :: (x: float64) -> float64 {
    t := ldexp(x, 4);
    t = floor(t);
    t = ldexp(t, -4);
    return t;
}


#scope_file


/*
 *
 *	Evaluate polynomial
 *
 *
 * DESCRIPTION:
 *
 * Evaluates polynomial of degree N:
 *
 *                     2          N
 * y  =  C  + C x + C x  +...+ C x
 *        0    1     2          N
 *
 * Coefficients are stored in reverse order:
 *
 * coef[0] = C  , ..., coef[N] = C  .
 *            N                   0
 *
 *  The function p1evl() assumes that coef[N] = 1.0 and is
 * omitted from the array.  Its calling arguments are
 * otherwise the same as polevl().
 *
 */


// This implementation of polevl, renamed 'polynomial',
// has been totally rewritten to leverage compiler features.
// If we want to, we could write a version that just generates
// the string to multiply-add all constants of coef in a hardcoded
// way... not sure if that is worth it!

// Original cephes had a p1evl, but since we see the array and know
// that it is constant, and dereferencing it is constant,
// it is easy to optimize out the initial multiply by 1, so
// we are just good. This function is much less error-prone.

polynomial :: (x: float64, $coef: [$N] float64) -> float64 {
    #assert (N >= 2) && (N <= 7);

    ans := coef[0] * x + coef[1];
    #if N > 2  ans = ans * x + coef[2];
    #if N > 3  ans = ans * x + coef[3];
    #if N > 4  ans = ans * x + coef[4];
    #if N > 5  ans = ans * x + coef[5];
    #if N > 6  ans = ans * x + coef[6];
    
    return ans;
}


#scope_export

Matrix2 :: struct {
    _11, _12 : float;
    _21, _22 : float;

    #overlay (_11) v:      [2]    v2f = ---; // These are row vectors.
    #overlay (_11) coef:   [2][2] float   = ---;
    #overlay (_11) floats: [4]    float   = ---;

    Row_Type    :: v2f;
    Column_Type :: v2f;

    IsMatrixFromMathModule :: true;
}

Matrix2_Identity :: Matrix2.{_11=1, _22=1};

Matrix3 :: struct {
    _11, _12, _13 : float;
    _21, _22, _23 : float;
    _31, _32, _33 : float;

    #overlay (_11) v:      [3]    v3f = ---; // These are row vectors.
    #overlay (_11) coef:   [3][3] float   = ---;
    #overlay (_11) floats: [9]    float   = ---;

    Row_Type    :: v3f;
    Column_Type :: v3f;

    IsMatrixFromMathModule :: true;
}

Matrix3_Identity :: Matrix3.{_11=1, _22=1, _33=1};

Matrix4 :: struct {
    _11, _12, _13, _14 : float;
    _21, _22, _23, _24 : float;
    _31, _32, _33, _34 : float;
    _41, _42, _43, _44 : float;

    #overlay (_11) mat4x3: Matrix4x3 = ---;

    #overlay (_11) v:      [4]    v4f = ---; // These are row vectors.
    #overlay (_11) coef:   [4][4] float   = ---;
    #overlay (_11) floats: [16]   float   = ---;

    Row_Type    :: v4f;
    Column_Type :: v4f;

    IsMatrixFromMathModule :: true;
}

Matrix4_Identity :: Matrix4.{_11=1, _22=1, _33=1, _44=1};

Matrix4x3 :: struct {
    _11, _12, _13, _14 : float;
    _21, _22, _23, _24 : float;
    _31, _32, _33, _34 : float;

    // Matrix4x3 is used when you want to have a matrix that is
    // mathematically a Matrix4, but bottom row is known to be
    // [0, 0, 0, 1], which is a common case when doing affine
    // computer graphics. We eliminate the storage for that row
    // in order to save memory, avoid extra multiplies and adds, etc.

    #overlay (_11) v:      [3]    v4f = ---; // These are row vectors.
    #overlay (_11) coef:   [3][4] float   = ---;
    #overlay (_11) floats: [12]   float   = ---;

    Row_Type    :: v4f;
    Column_Type :: v3f;

    IsMatrixFromMathModule :: true;
}

Matrix4x3_Identity :: Matrix4x3.{_11=1, _22=1, _33=1};

// We use AnyMatrix3 as an interface to do certain matrix operations on
// Matrix3, Matrix4, and Matrix4x3. get_rotation actually uses the coef[]
// array as well, but right now we do not have a way to declare this in
// an interface in any way that makes sense, so, you will just have to
// make sure any type you pass also has the appropriate coef array for now!
AnyMatrix3 :: struct {
    _11, _12, _13 : float;
    _21, _22, _23 : float;
    _31, _32, _33 : float;
}

// See the comment on AnyMatrix3 above.
AnyMatrix4x3 :: struct {
    _11, _12, _13, _14 : float;
    _21, _22, _23, _24 : float;
    _31, _32, _33, _34 : float;
}

AnyMatrix2 :: struct {
    _11, _12 : float;
    _21, _22 : float;
}

AnyMatrix :: struct {
    IsMatrixFromMathModule :: true;
}

// @Cleanup: Make row, column polymorphic?
row :: (m: Matrix4, i: int) -> v4f {
    return m.v[i];
}

column :: (m: Matrix4, i: int) -> v4f {
    return .{m.coef[0][i], m.coef[1][i], m.coef[2][i], m.coef[3][i]};
}


multiply :: (m: Matrix4, v: v4f) -> v4f {
    result: v4f = ---;
    result.x = m._11 * v.x + m._12 * v.y + m._13 * v.z + m._14 * v.w;
    result.y = m._21 * v.x + m._22 * v.y + m._23 * v.z + m._24 * v.w;
    result.z = m._31 * v.x + m._32 * v.y + m._33 * v.z + m._34 * v.w;
    result.w = m._41 * v.x + m._42 * v.y + m._43 * v.z + m._44 * v.w;
    return result;
}

multiply :: (m: Matrix4x3, v: v4f) -> v3f {
    result: v3f = ---;
    result.x = m._11 * v.x + m._12 * v.y + m._13 * v.z + m._14 * v.w;
    result.y = m._21 * v.x + m._22 * v.y + m._23 * v.z + m._24 * v.w;
    result.z = m._31 * v.x + m._32 * v.y + m._33 * v.z + m._34 * v.w;
    return result;
}

multiply :: (m: Matrix2, v: v2f) -> v2f {
    r: v2f = ---;
    r.x = m._11 * v.x + m._12 * v.y;
    r.y = m._21 * v.x + m._22 * v.y;

    return r;
}


// We can't condense these matrix-vector multiplies into one
// routine because of the thing where Matrix4x3*v4f yields v3f.
// (Unless we add another field saying what multiply returns, or
// do a one-off weird hack.)
operator * :: (m: Matrix4, v: v4f) -> v4f {
    return inline multiply(m, v);
}

operator * :: (m: Matrix4x3, v: v4f) -> v3f {
    return inline multiply(m, v);
}

operator * :: (m: Matrix3, v: v3f) -> v3f {
    return inline multiply(m, v);
}

transform_point :: (m: $T/interface AnyMatrix4x3, v: v3f) -> v3f {
    result: v3f = ---;
    result.x = m._11 * v.x + m._12 * v.y + m._13 * v.z + m._14;
    result.y = m._21 * v.x + m._22 * v.y + m._23 * v.z + m._24;
    result.z = m._31 * v.x + m._32 * v.y + m._33 * v.z + m._34;
    return result;
}

multiply :: (m: $T/interface AnyMatrix3, v: v3f) -> v3f {
    result: v3f = ---;
    result.x = m._11 * v.x + m._12 * v.y + m._13 * v.z;
    result.y = m._21 * v.x + m._22 * v.y + m._23 * v.z;
    result.z = m._31 * v.x + m._32 * v.y + m._33 * v.z;
    return result;
}

transform_vector :: (m: $T/interface AnyMatrix3, v: v3f) -> v3f {
    return inline multiply(m, v);
}


// We could and maybe should do some 'interface' stuff to cut down on all these
// 'multiply' variants, or, at least factoring out the 3x3 coefficients
// and adding the rest in. Possibly we can do some #if action.

multiply :: (m: Matrix2, n: Matrix2) -> Matrix2 {
    result: Matrix2 = ---;

    result._11 = m._11 * n._11 + m._12 * n._21;
    result._21 = m._21 * n._11 + m._22 * n._21;

    result._12 = m._11 * n._12 + m._12 * n._22;
    result._22 = m._21 * n._12 + m._22 * n._22;

    return result;
}

multiply :: (m: Matrix3, n: Matrix3) -> Matrix3 {
    result: Matrix3 = ---;

    result._11 = m._11 * n._11 + m._12 * n._21 + m._13 * n._31;
    result._21 = m._21 * n._11 + m._22 * n._21 + m._23 * n._31;
    result._31 = m._31 * n._11 + m._32 * n._21 + m._33 * n._31;

    result._12 = m._11 * n._12 + m._12 * n._22 + m._13 * n._32;
    result._22 = m._21 * n._12 + m._22 * n._22 + m._23 * n._32;
    result._32 = m._31 * n._12 + m._32 * n._22 + m._33 * n._32;

    result._13 = m._11 * n._13 + m._12 * n._23 + m._13 * n._33;
    result._23 = m._21 * n._13 + m._22 * n._23 + m._23 * n._33;
    result._33 = m._31 * n._13 + m._32 * n._23 + m._33 * n._33;

    return result;
}


multiply :: (m: Matrix4, n: Matrix3) -> Matrix4 {
    result: Matrix4 = ---;

    result._11 = m._11*n._11 + m._12*n._21 + m._13*n._31;
    result._21 = m._21*n._11 + m._22*n._21 + m._23*n._31;
    result._31 = m._31*n._11 + m._32*n._21 + m._33*n._31;
    result._41 = m._41*n._11 + m._42*n._21 + m._43*n._31;

    result._12 = m._11*n._12 + m._12*n._22 + m._13*n._32;
    result._22 = m._21*n._12 + m._22*n._22 + m._23*n._32;
    result._32 = m._31*n._12 + m._32*n._22 + m._33*n._32;
    result._42 = m._41*n._12 + m._42*n._22 + m._43*n._32;

    result._13 = m._11*n._13 + m._12*n._23 + m._13*n._33;
    result._23 = m._21*n._13 + m._22*n._23 + m._23*n._33;
    result._33 = m._31*n._13 + m._32*n._23 + m._33*n._33;
    result._43 = m._41*n._13 + m._42*n._23 + m._43*n._33;

    result._14 = m._14;
    result._24 = m._24;
    result._34 = m._34;
    result._44 = m._44;

    return result;
}


multiply :: (m: Matrix4, n: Matrix4) -> Matrix4 {
    result: Matrix4 = ---;

    result._11 = m._11*n._11 + m._12*n._21 + m._13*n._31 + m._14*n._41;
    result._21 = m._21*n._11 + m._22*n._21 + m._23*n._31 + m._24*n._41;
    result._31 = m._31*n._11 + m._32*n._21 + m._33*n._31 + m._34*n._41;
    result._41 = m._41*n._11 + m._42*n._21 + m._43*n._31 + m._44*n._41;

    result._12 = m._11*n._12 + m._12*n._22 + m._13*n._32 + m._14*n._42;
    result._22 = m._21*n._12 + m._22*n._22 + m._23*n._32 + m._24*n._42;
    result._32 = m._31*n._12 + m._32*n._22 + m._33*n._32 + m._34*n._42;
    result._42 = m._41*n._12 + m._42*n._22 + m._43*n._32 + m._44*n._42;

    result._13 = m._11*n._13 + m._12*n._23 + m._13*n._33 + m._14*n._43;
    result._23 = m._21*n._13 + m._22*n._23 + m._23*n._33 + m._24*n._43;
    result._33 = m._31*n._13 + m._32*n._23 + m._33*n._33 + m._34*n._43;
    result._43 = m._41*n._13 + m._42*n._23 + m._43*n._33 + m._44*n._43;

    result._14 = m._11*n._14 + m._12*n._24 + m._13*n._34 + m._14*n._44;
    result._24 = m._21*n._14 + m._22*n._24 + m._23*n._34 + m._24*n._44;
    result._34 = m._31*n._14 + m._32*n._24 + m._33*n._34 + m._34*n._44;
    result._44 = m._41*n._14 + m._42*n._24 + m._43*n._34 + m._44*n._44;

    return result;
}

multiply :: (m: Matrix4x3, n: Matrix4x3) -> Matrix4x3 {
    result: Matrix4x3 = ---;

    result._11 = m._11*n._11 + m._12*n._21 + m._13*n._31;
    result._21 = m._21*n._11 + m._22*n._21 + m._23*n._31;
    result._31 = m._31*n._11 + m._32*n._21 + m._33*n._31;

    result._12 = m._11*n._12 + m._12*n._22 + m._13*n._32;
    result._22 = m._21*n._12 + m._22*n._22 + m._23*n._32;
    result._32 = m._31*n._12 + m._32*n._22 + m._33*n._32;

    result._13 = m._11*n._13 + m._12*n._23 + m._13*n._33;
    result._23 = m._21*n._13 + m._22*n._23 + m._23*n._33;
    result._33 = m._31*n._13 + m._32*n._23 + m._33*n._33;

    result._14 = m._11*n._14 + m._12*n._24 + m._13*n._34 + m._14;
    result._24 = m._21*n._14 + m._22*n._24 + m._23*n._34 + m._24;
    result._34 = m._31*n._14 + m._32*n._24 + m._33*n._34 + m._34;

    return result;
}

multiply :: (m: Matrix4, n: Matrix4x3) -> Matrix4 {
    result: Matrix4 = ---;

    result._11 = m._11*n._11 + m._12*n._21 + m._13*n._31;
    result._21 = m._21*n._11 + m._22*n._21 + m._23*n._31;
    result._31 = m._31*n._11 + m._32*n._21 + m._33*n._31;
    result._41 = m._41*n._11 + m._42*n._21 + m._43*n._31;

    result._12 = m._11*n._12 + m._12*n._22 + m._13*n._32;
    result._22 = m._21*n._12 + m._22*n._22 + m._23*n._32;
    result._32 = m._31*n._12 + m._32*n._22 + m._33*n._32;
    result._42 = m._41*n._12 + m._42*n._22 + m._43*n._32;

    result._13 = m._11*n._13 + m._12*n._23 + m._13*n._33;
    result._23 = m._21*n._13 + m._22*n._23 + m._23*n._33;
    result._33 = m._31*n._13 + m._32*n._23 + m._33*n._33;
    result._43 = m._41*n._13 + m._42*n._23 + m._43*n._33;

    result._14 = m._11*n._14 + m._12*n._24 + m._13*n._34 + m._14;
    result._24 = m._21*n._14 + m._22*n._24 + m._23*n._34 + m._24;
    result._34 = m._31*n._14 + m._32*n._24 + m._33*n._34 + m._34;
    result._44 = m._41*n._14 + m._42*n._24 + m._43*n._34 + m._44;

    return result;
}

multiply :: (m: Matrix4x3, n: Matrix4) -> Matrix4 {
    result: Matrix4 = ---;

    result._11 = m._11*n._11 + m._12*n._21 + m._13*n._31 + m._14*n._41;
    result._21 = m._21*n._11 + m._22*n._21 + m._23*n._31 + m._24*n._41;
    result._31 = m._31*n._11 + m._32*n._21 + m._33*n._31 + m._34*n._41;
    result._41 = n._41;

    result._12 = m._11*n._12 + m._12*n._22 + m._13*n._32 + m._14*n._42;
    result._22 = m._21*n._12 + m._22*n._22 + m._23*n._32 + m._24*n._42;
    result._32 = m._31*n._12 + m._32*n._22 + m._33*n._32 + m._34*n._42;
    result._42 = n._42;

    result._13 = m._11*n._13 + m._12*n._23 + m._13*n._33 + m._14*n._43;
    result._23 = m._21*n._13 + m._22*n._23 + m._23*n._33 + m._24*n._43;
    result._33 = m._31*n._13 + m._32*n._23 + m._33*n._33 + m._34*n._43;
    result._43 = n._43;

    result._14 = m._11*n._14 + m._12*n._24 + m._13*n._34 + m._14*n._44;
    result._24 = m._21*n._14 + m._22*n._24 + m._23*n._34 + m._24*n._44;
    result._34 = m._31*n._14 + m._32*n._24 + m._33*n._34 + m._34*n._44;
    result._44 = n._44;

    return result;
}

// We cannot use #symmetric on operator *, unless one of the coefficients is a scalar,
// because matrix multiplication is not symmetric!
operator * :: (a: Matrix4, b: Matrix4) -> Matrix4 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix4x3, b: Matrix4x3) -> Matrix4x3 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix4, b: Matrix4x3) -> Matrix4 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix4x3, b: Matrix4) -> Matrix4 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix4, b: Matrix3) -> Matrix4 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix3, b: Matrix3) -> Matrix3 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix2, b: Matrix2) -> Matrix2 {
    return inline multiply(a, b);
}

operator * :: (a: Matrix2, b: v2f) -> v2f {
    return inline multiply(a, b);
}

operator * :: (a: $T/interface AnyMatrix, t: float) -> T #symmetric {
    r: T = ---;
    for 0..a.floats.count-1  r.floats[it] = a.floats[it] * t;
    return r;
}

operator + :: (a: $T/interface AnyMatrix, b: T) -> T {
    r: T = ---;
    for 0..a.floats.count-1  r.floats[it] = a.floats[it] + b.floats[it];
    return r;
}

operator - :: (a: $T/interface AnyMatrix, b: T) -> T {
    r: T = ---;
    for 0..a.floats.count-1  r.floats[it] = a.floats[it] - b.floats[it];
    return r;
}

operator == :: (a: $T/interface AnyMatrix, b: T) -> bool {
    for i: 0..a.floats.count-1 {
        if a.floats[i] != b.floats[i] return false;
    }

    return true;
}

make_matrix3 :: (m: $T/interface AnyMatrix3) -> Matrix3 {  // Can use this to go from Matrix4x3 or Matrix4 down to Matrix3.
    r: Matrix3 = ---;
    for i: 0..2 for j: 0..2 {
        r.coef[i][j] = m.coef[i][j];
    }

    return r;
}

make_matrix4 :: (m: $T/interface AnyMatrix3) -> Matrix4 {
    // We'll start with Matrix4_Identity, then overwrite members below. Instead of this,
    // we could do a bunch of static checks that make the code more complex, but
    // that are more guaranteed to be optimized. But here we are relying on the
    // runtime optimizer.
    r := Matrix4_Identity;

    // We are being a little fast and loose, because we are using the coef array,
    // but AnyMatrix3 is declared to just use the _ab members.

    row := Basic.min(3, m.coef.count-1);     // Index of the highest row (0-based!)
    col := Basic.min(3, m.coef[0].count-1);  // Index of the highest column (0-based!)

    for i: 0..row {
        for j: 0..col {
            r.coef[i][j] = m.coef[i][j];
        }
    }

    return r;
}

// We should remove this. I mean, come on...
make_matrix4 :: (values: ..float) -> Matrix4 #deprecated "Use a struct literal instead." {
    r: Matrix4 = ---;

    for values {
        r.floats[it_index] = it;
    }

    return r;
}

// @Cleanup: Make transpose() polymorphic?

// Transpose a 4x4 matrix.
transpose :: (m: Matrix4) -> Matrix4 {
    r: Matrix4 = ---;

    for i: 0..3 for j: 0..3 {
        r.coef[i][j] = m.coef[j][i];
    }

    return r;
}

// Transpose a 3x3 matrix.
transpose :: (m: Matrix3) -> Matrix3 {
    r: Matrix3 = ---;

    for i: 0..2 for j: 0..2 {
        r.coef[i][j] = m.coef[j][i];
    }

    return r;
}

// Transpose a 4x4 matrix in place.
transpose :: (m: *Matrix4) {
    Swap(*m.coef[0][1], *m.coef[1][0]);
    Swap(*m.coef[0][2], *m.coef[2][0]);
    Swap(*m.coef[0][3], *m.coef[3][0]);

    Swap(*m.coef[1][2], *m.coef[2][1]);
    Swap(*m.coef[1][3], *m.coef[3][1]);

    Swap(*m.coef[2][3], *m.coef[3][2]);
}

// Transpose a 3x3 matrix in place.
transpose :: (m: *Matrix3) {
    Swap(*m.coef[0][1], *m.coef[1][0]);
    Swap(*m.coef[0][2], *m.coef[2][0]);
    Swap(*m.coef[1][2], *m.coef[2][1]);
}


// @Cleanup: Remove make_scale_*, these are goofy.

make_scale_matrix4 :: (v: v3f) -> Matrix4 {
    m: Matrix4 = ---;
    identity(*m);

    m._11 = v.x;
    m._22 = v.y;
    m._33 = v.z;

    return m;
}

scale :: (m: $T/interface AnyMatrix3, s: float) -> T {
    scale(*m, s);   // This * implicitly creates a copy of m.
    return m;
}

scale :: (m: *$T/interface AnyMatrix3, s: float) {
    m._11 *= s;
    m._21 *= s;
    m._31 *= s;

    m._12 *= s;
    m._22 *= s;
    m._32 *= s;

    m._13 *= s;
    m._23 *= s;
    m._33 *= s;
}

scale :: (m: $T/interface AnyMatrix3, v: v3f) -> T {
    scale(*m, v);   // This * implicitly creates a copy of m.
    return m;
}

scale :: (m: *$T/interface AnyMatrix3, v: v3f) {
    m._11 *= v.x;
    m._21 *= v.x;
    m._31 *= v.x;

    m._12 *= v.y;
    m._22 *= v.y;
    m._32 *= v.y;

    m._13 *= v.z;
    m._23 *= v.z;
    m._33 *= v.z;
}


// Returns a translation matrix given a translation vector.
make_translation_matrix4 :: (v: v3f) -> Matrix4 {
    m: Matrix4 = ---;
    identity(*m);

    m._14 = v.x;
    m._24 = v.y;
    m._34 = v.z;

    return m;
}

// Apply a translation to the given matrix.
translate :: (using m: Matrix4, t: v3f) -> Matrix4 {
    result := m;
    inline translate(*result, t);
    return result;
}

// Apply a translation to the given matrix in place.
translate :: (using m: *Matrix4, t: v3f) {
    m.coef[0][3] += m.coef[0][0] * t.x + m.coef[0][1] * t.y + m.coef[0][2] * t.z;
    m.coef[1][3] += m.coef[1][0] * t.x + m.coef[1][1] * t.y + m.coef[1][2] * t.z;
    m.coef[2][3] += m.coef[2][0] * t.x + m.coef[2][1] * t.y + m.coef[2][2] * t.z;
    m.coef[3][3] += m.coef[3][0] * t.x + m.coef[3][1] * t.y + m.coef[3][2] * t.z;
}


// @Cleanup: Remove this...
// Apply the given quaternion rotation to the given 3x3 matrix.
rotate :: (m: Matrix3, q: Quaternion) -> Matrix3 {
    R := rotation_matrix(Matrix3, q);
    return m * R;
}

// @Cleanup: Remove this...
// Apply the given quaternion rotation to the given 4x4 matrix.
rotate :: (m: Matrix4, q: Quaternion) -> Matrix4 {
    R := rotation_matrix(Matrix3, q);
    return m * R;
}


// make_matrix_from_rows() and make_matrix_from_columns() are
// just convenience functions that can be useful when building
// matrices that transform from one space to another. The classic
// way to do this is put the basis vectors in one matrix as rows,
// in the other as columns, and then multiply them together.

make_matrix_from_rows :: (xprime: v3f, yprime: v3f, zprime: v3f, $T := Matrix4) -> T {
    result: T;
    result._11 = xprime.x;
    result._12 = xprime.y;
    result._13 = xprime.z;

    result._21 = yprime.x;
    result._22 = yprime.y;
    result._23 = yprime.z;

    result._31 = zprime.x;
    result._32 = zprime.y;
    result._33 = zprime.z;

    #if T == Matrix4  result._44 = 1;

    return result;
}

make_matrix_from_columns :: (xprime: v3f, yprime: v3f, zprime: v3f, $T := Matrix4) -> T {
    result: T;
    result._11 = xprime.x;
    result._21 = xprime.y;
    result._31 = xprime.z;

    result._12 = yprime.x;
    result._22 = yprime.y;
    result._32 = yprime.z;

    result._13 = zprime.x;
    result._23 = zprime.y;
    result._33 = zprime.z;

    #if T == Matrix4  result._44 = 1;

    return result;
}


//
// Probably the graphics-centric matrix routines, like make_look_at_matrix, projection_matrix, etc,
// should be somewhere else?
//
make_look_at_matrix :: (viewpoint: v3f,
                        look_at: v3f,
                        reference_up_vector: v3f, $x_is_forward := true) -> Matrix4 {

    forward := look_at - viewpoint;
    normalize(*forward, fallback=.{z=1});

    left := cross_product(reference_up_vector, forward);
    normalize(*left, fallback=.{z=1});

    up := cross_product(forward, left);
    normalize(*up, fallback=.{z=1});  // Just for accuracy's sake.

    // We are making the inverse of the transform that takes axis_forward to the forward vector.
    // So we use make_matrix_from_rows to get the inverse rotation, then multiply the translation
    // negation on the right-hand side.

    #if x_is_forward {
        rotation := make_matrix_from_rows(forward, left, up);
    } else {
        rotation := make_matrix_from_rows(left * -1, up, forward * -1);
    }

    //translation := Matrix4_Identity;
    //translation._14 = -viewpoint.x;
    //translation._24 = -viewpoint.y;
    //translation._34 = -viewpoint.z;
    //result := rotation * translation;
    result := translate(rotation, -viewpoint);

    return result;
}

orthographic_projection_matrix :: (left: float, right: float, bottom: float, top: float, near: float, far: float, depth_range_01:=false) -> Matrix4
{
    m : Matrix4;

    m._11 = 2.0 / (right - left);
    m._14 = - (right + left) / (right - left);

    m._22 = 2.0 / (top - bottom);
    m._24 = - (top + bottom) / (top - bottom);

    // if depth_range_01 {
    //     m._33 = -1 / (far - near);
    //     m._34 = near / (far - near);
    // }
    // else {
        m._33 = -2 / (far - near);
        m._34 = - (far + near) / (far - near);
    // }
    m._44 = 1.0;

    if depth_range_01 {
        // To map -1,1 depth range to 0,1 we transform z as follows: z' = z * 0.5 + 0.5
        m._33 = m._33 * 0.5 + m._43 * 0.5;
        m._34 = m._34 * 0.5 + m._44 * 0.5;
    }

    return m;
}

//
// This makes a minus-z-forward projection matrix.
// Minus-z-forward is a super dumb and confusing standard, but it is what most people use.
// In the engine we use x-forward for everything, and apply a fixup to the
// projection matrix returned here, to swizzle around the result of the
// x-forward view matrix.
//
make_projection_matrix :: (fov_vertical: float, aspect_ratio_horizontal_over_vertical: float, z_near: float, z_far: float, x_offset:=0.0, y_offset:=0.0, depth_range_01:=false) -> Matrix4 {
    result := Matrix4_Identity;

    tan_theta := tan(fov_vertical * 0.5);
    cot_theta := 1 / tan_theta;

    // this was d3d-style (ndc z 0->1)
    // @Hack 6 August 2016, I just stuck a - in here to put things the right way;
    // clean this up!
//    beta := -z_far / (z_far - z_near);
    f := z_far;
    n := z_near;
    denom := 1 / (f - n);

    result._11 = cot_theta / aspect_ratio_horizontal_over_vertical;
    result._22 = cot_theta;
    result._33 = -(f + n) * denom;
    result._43 = -1;
    result._34 = -2 * f * n * denom;
    result._44 = 0;

    result._13 = x_offset; // / w;
    result._23 = y_offset; // / h;

    // if depth_range_01 {
    //     result._33 = -f * denom;
    //     result._34 = -f * denom * n;
    // }
    // else {
    //     result._33 = -(f + n) * denom;
    //     result._34 = -2 * f * n * denom;
    // }

    if depth_range_01 {
        // To map -1,1 depth range to 0,1 we transform z as follows: z' = z * 0.5 + 0.5
        result._33 = result._33 * 0.5 + result._43 * 0.5;
        result._34 = result._34 * 0.5 + result._44 * 0.5;
        // In you wanna do any derivations with our depth_range_01 projection
        // matrix, the previous 2-line transform produces this:
        // result._33 = 0.5 * (-(f+n)/(f-n)) - 0.5 = 0.5*(-1+(-f-n)/(f-n))
        // result._34 = 0.5 * (-2*f*n / (f-n)) = -f*n / (f-n)
    }

    return result;
}


// IC: Right-handed perspective projection matrix. Maps near plane to z=-1, far to z=1. Looks along the negative Z axis.
make_frustum_matrix :: (l: float, r: float, b: float, t: float, n: float, f: float, depth_range_01:=false) -> Matrix4 {

    double_znear := 2.0 * n;
    one_deltax := 1.0 / (r - l);
    one_deltay := 1.0 / (t - b);
    one_deltaz := 1.0 / (f - n);

    result := Matrix4_Identity;
    result._11 = double_znear * one_deltax;
    result._22 = double_znear * one_deltay;
    result._13 = (r + l) * one_deltax;
    result._23 = (t + b) * one_deltay;
    result._33 = -(f + n) * one_deltaz;
    result._43 = -1;
    result._34 = -f * double_znear * one_deltaz;
    result._44 = 0;

    // if depth_range_01 {
    //     result._33 = -f * one_deltaz;
    //     result._34 = -f * one_deltaz * n;
    // }
    // else {
    //     result._33 = -(f + n) * one_deltaz;
    //     result._34 = -f * double_znear * one_deltaz;
    // }

    if depth_range_01 {
        // To map -1,1 depth range to 0,1 we transform z as follows: z' = z * 0.5 + 0.5
        result._33 = result._33 * 0.5 + result._43 * 0.5;
        result._34 = result._34 * 0.5 + result._44 * 0.5;
    }

    return result;
}

lerp :: (a: Matrix3, b: Matrix3, t: float) -> Matrix3 {
    // We provide lerp on a Matrix3 because we use it for
    // scale/shear matrices. But if you have a Matrix3 that
    // represents a rotation or a general transformation,
    // you *really* should not linearly interpolate it
    // unless you really really really know what you are doing.

    r: Matrix3 = ---;

    // We would like to be able to write the following thing
    // instead of the expanded-out code below, and have full
    // confidence that the compiler generates something efficient
    // for it even in Debug builds.

    // #unroll for 0..8  r.floats[it] = inline lerp(a.floats[it], b.floats[it], t);

    r._11 = a._11 + t*(b._11 - a._11);
    r._12 = a._12 + t*(b._12 - a._12);
    r._13 = a._13 + t*(b._13 - a._13);

    r._21 = a._21 + t*(b._21 - a._21);
    r._22 = a._22 + t*(b._22 - a._22);
    r._23 = a._23 + t*(b._23 - a._23);

    r._31 = a._31 + t*(b._31 - a._31);
    r._32 = a._32 + t*(b._32 - a._32);
    r._33 = a._33 + t*(b._33 - a._33);


    return r;
}


inverse :: (a: Matrix3, epsilon := 0.001) -> (success: bool, result: Matrix3) {
    r: Matrix3 = ---;

    c11 := a._22*a._33 - a._32*a._23;
    c12 := a._21*a._33 - a._31*a._23;
    c13 := a._21*a._32 - a._31*a._22;

    // Determinant.
    det := a._11*c11 - a._12*c12 + a._13*c13;

    if (det < epsilon) && (det > -epsilon)  return false, a;  // Failure... undefined!

    idet := 1/det;

    r._11 =  idet*c11;
    r._12 = -idet*(a._12*a._33 - a._13*a._32);
    r._13 =  idet*(a._12*a._23 - a._13*a._22);
    r._21 = -idet*c12;
    r._22 =  idet*(a._11*a._33 - a._13*a._31);
    r._23 = -idet*(a._11*a._23 - a._13*a._21);
    r._31 =  idet*c13;
    r._32 = -idet*(a._11*a._32 - a._12*a._31);
    r._33 =  idet*(a._11*a._22 - a._12*a._21);

    return true, r;
}



//
// UGLY STUFF!
//

inverse :: (m: Matrix4) -> (success: bool, result: Matrix4) {
    matr := m; // Arguments are immutable, even though the code below compiles fine! -ic 7 August 2019

    k, l, ll: int = ---;
    icol := 0;
    irow := 0;

    indxc: [4] int = ---;
    indxr: [4] int = ---;
    ipiv:  [4] int;

    ident := Matrix4_Identity;

    for i: 0..3 {
        big : float64 = 0.0;
        for j: 0..3 {
            if ipiv[j] != 1 {  // @Cleanup: Invert this nesting w/ a continue.
                for k: 0..3 {
                    if ipiv[k] == 0 {
                        if abs(matr.coef[j][k]) >= big {
                            big = abs(matr.coef[j][k]);
                            irow=j;
                            icol=k;
                        }
                    } else {
                        if ipiv[k] > 1  return false, ident;
                    }
                }
            }
        }

        ipiv[icol] += 1;

        if irow != icol {
            for l: 0..3 Swap(*matr .coef[irow][l], *matr .coef[icol][l]);
            for l: 0..3 Swap(*ident.coef[irow][l], *ident.coef[icol][l]);
        }

        indxr[i] = irow;
        indxc[i] = icol;

        if matr.coef[icol][icol] == 0.0  return false, ident;
        pivinv : float64 = 1 / matr.coef[icol][icol];
        matr.coef[icol][icol] = 1;

        //
        // @Robustness: The auto-casts here on pivinv are losing us
        // precision. How do we notate that we want the * to happen
        // as float64 even though the thing on the left is float32?
        //               -jblow, 1 February 2017.
        //
        // WARNING: I may have destabilized the results of this routine!!!
        //

        // Do not use *= here, because we want to do the multiply in float64,
        // then cast to float32.
        for l: 0..3 { matr .coef[icol][l] = cast(float32)(matr .coef[icol][l] * pivinv); }
        for l: 0..3 { ident.coef[icol][l] = cast(float32)(ident.coef[icol][l] * pivinv); }

        for ll: 0..3 {
            if ll != icol {
                dum := matr.coef[ll][icol];
                matr.coef[ll][icol] = 0;

                for l: 0..3 { matr .coef[ll][l] -= xx (matr .coef[icol][l]*dum); }
                for l: 0..3 { ident.coef[ll][l] -= xx (ident.coef[icol][l]*dum); }
            }
        }
    }

    for < l: 0..3 {
        if indxr[l] != indxc[l] {
            for k: 0..3 {
                Swap(*matr.coef[k][indxr[l]], *matr.coef[k][indxc[l]]);
            }
        }
    }

    return true, ident;
}

// Inverse using gaussian elimination.
inverse_gaussian_elimination :: (m: Matrix4) -> (success: bool, result: Matrix4) {
    A := m;
    B := Matrix4_Identity;
    det := 1.0;

    for i: 0..3 {                       // eliminate in column i, below diag
        j: int;
        max := -1.0;
        for k: i..3 {                   // find pivot for column i
            if abs(A.coef[k][i]) > max {
                max = abs(A.coef[k][i]);
                j = k;
            }
        }

        if max <= 0 return false, B;           // if no nonzero pivot, PUNT
        
        if j != i {                     // swap rows i and j
            for k: i..3     Swap(*A.coef[i][k], *A.coef[j][k]);
            for k: 0..3     Swap(*B.coef[i][k], *B.coef[j][k]);
            det = -det;
        }

        pivot := A.coef[i][i];
        det *= pivot;
        for k: i+1..3   A.coef[i][k] /= pivot;      // only do elems to right of pivot
        for k: 0..3     B.coef[i][k] /= pivot;
        // we know that A(i, i) will be set to 1, so don't bother to do it

        for j: i+1..3 {                 // eliminate in rows below i
            t := A.coef[j][i];          // we're gonna zero this guy
            for k: i+1..3               // subtract scaled row i from row j
                A.coef[j][k] -= A.coef[i][k]*t;                // (ignore k<=i, we know they're 0)
            for k: 0..3
                B.coef[j][k] -= B.coef[i][k]*t;
        }
    }

    /*---------- backward elimination ----------*/

    for < i: 1..3 {                 // eliminate in column i, above diag
        for j: 0..i-1 {                 // eliminate in rows above i
            t := A.coef[j][i];          // we're gonna zero this guy
            for k: 0..3                 // subtract scaled row i from row j
                B.coef[j][k] -= B.coef[i][k]*t;
        }
    }

    return true, B;
}


// An efficient inverse for small 4x4 matrices.  Note that it does not try to maximize floating point precision,
// but is faster and  works well enough for most of the well conditioned matrices we have typically have in the game.
//
// For reference, see: 1.7.5 Inverses of Small Matrices in 'Foundations of Game Development: Mathematics' by Eric Lengyel.
inverse_lengyel :: (m: Matrix4, epsilon := 0.0001) -> (success: bool, result: Matrix4) {
    a := v3f.{m._11, m._21, m._31};
    b := v3f.{m._12, m._22, m._32};
    c := v3f.{m._13, m._23, m._33};
    d := v3f.{m._14, m._24, m._34};

    x := m._41;
    y := m._42;
    z := m._43;
    w := m._44;

    s := cross(a, b);
    t := cross(c, d);
    u := a * y - b * x;
    v := c * w - d * z;

    det := dot(s, v) + dot(t, u);
    
    if abs(det) < epsilon {
        return false, Matrix4_Identity;
    }
    
    inv_det := 1.0 / det;
    s *= inv_det;
    t *= inv_det;
    u *= inv_det;
    v *= inv_det;

    r0 := cross(b, v) + t * y;
    r1 := cross(v, a) - t * x;
    r2 := cross(d, u) + s * w;
    r3 := cross(u, c) - s * z;

    return true,
           .{
            r0.x, r0.y, r0.z, -dot(b, t),
            r1.x, r1.y, r1.z,  dot(a, t),
            r2.x, r2.y, r2.z, -dot(d, s),
            r3.x, r3.y, r3.z,  dot(c, s)};
}

// The adjugate is the inverse of matrix M multiplied by its determinant. The adjugate always exists and is a cheaper to compute than the inverse.
//
// For reference, see: 1.7.5 Inverses of Small Matrices in 'Foundations of Game Development: Mathematics' by Eric Lengyel.
adjugate_lengyel :: (m: Matrix4) -> Matrix4 {

    a := v3f.{m._11, m._21, m._31};
    b := v3f.{m._12, m._22, m._32};
    c := v3f.{m._13, m._23, m._33};
    d := v3f.{m._14, m._24, m._34};

    x := m._41;
    y := m._42;
    z := m._43;
    w := m._44;

    s := cross(a, b);
    t := cross(c, d);
    u := a * y - b * x;
    v := c * w - d * z;

    r0 := cross(b, v) + t * y;
    r1 := cross(v, a) - t * x;
    r2 := cross(d, u) + s * w;
    r3 := cross(u, c) - s * z;

    return .{
            r0.x, r0.y, r0.z, -dot(b, t),
            r1.x, r1.y, r1.z,  dot(a, t),
            r2.x, r2.y, r2.z, -dot(d, s),
            r3.x, r3.y, r3.z,  dot(c, s)};
}

adjugate :: adjugate_lengyel;

determinant :: (m: Matrix4) -> float {
    // return
    //     m._14 * m._23 * m._32 * m._41 - m._13 * m._24 * m._32 * m._41 - m._14 * m._22 * m._33 * m._41 + m._12 * m._24 * m._33 * m._41 +
    //     m._13 * m._22 * m._34 * m._41 - m._12 * m._23 * m._34 * m._41 - m._14 * m._23 * m._31 * m._42 + m._13 * m._24 * m._31 * m._42 +
    //     m._14 * m._21 * m._33 * m._42 - m._11 * m._24 * m._33 * m._42 - m._13 * m._21 * m._34 * m._42 + m._11 * m._23 * m._34 * m._42 +
    //     m._14 * m._22 * m._31 * m._43 - m._12 * m._24 * m._31 * m._43 - m._14 * m._21 * m._32 * m._43 + m._11 * m._24 * m._32 * m._43 +
    //     m._12 * m._21 * m._34 * m._43 - m._11 * m._22 * m._34 * m._43 - m._13 * m._22 * m._31 * m._44 + m._12 * m._23 * m._31 * m._44 +
    //     m._13 * m._21 * m._32 * m._44 - m._11 * m._23 * m._32 * m._44 - m._12 * m._21 * m._33 * m._44 + m._11 * m._22 * m._33 * m._44;

    a := m.v[0].xyz;
    b := m.v[1].xyz;
    c := m.v[2].xyz;
    d := m.v[3].xyz;

    x := m.v[0].w;
    y := m.v[1].w;
    z := m.v[2].w;
    w := m.v[3].w;

    s := cross(a, b);
    t := cross(c, d);
    u := a * y - b * x;
    v := c * w - d * z;

    return dot(s, v) + dot(t, u);
}

isometry_inverse :: (m: Matrix4) -> Matrix4 {
    result := Matrix4_Identity;

    // transposed 3x3 upper left matrix
    for i: 0..2 {
        for j: 0..2 {
            result.coef[i][j] = m.coef[j][i];
        }
    }

    // translate by the negative offsets
    t := v3f.{-m.coef[0][3], -m.coef[1][3], -m.coef[2][3]};

    //return translate(result, t);

    // This is slightly more efficient, because we know the last row is (0,0,0,1)
    result.coef[0][3] = result.coef[0][0] * t.x + result.coef[0][1] * t.y + result.coef[0][2] * t.z;
    result.coef[1][3] = result.coef[1][0] * t.x + result.coef[1][1] * t.y + result.coef[1][2] * t.z;
    result.coef[2][3] = result.coef[2][0] * t.x + result.coef[2][1] * t.y + result.coef[2][2] * t.z;
    return result;
}

// For reference:
// https://github.com/erich666/GraphicsGems/blob/master/gemsiv/polar_decomp/Decompose.c

// @@ Is the adjoint_transpose == adjugate ?
adjoint_transpose :: (m: Matrix3) -> Matrix3 {
    r: Matrix3 = ---;
    r.v[0] = cross(m.v[1], m.v[2]);
    r.v[1] = cross(m.v[2], m.v[0]);
    r.v[2] = cross(m.v[0], m.v[1]);
    return r;
}

// Compute either the 1 or infinity norm of M, depending on tpose
mat_norm :: (M: Matrix3, tpose: bool) -> float {
    max := 0.0;
    for i: 0..2 {
        sum: float;
        if tpose sum = abs(M.coef[0][i]) + abs(M.coef[1][i]) + abs(M.coef[2][i]);
        else     sum = abs(M.coef[i][0]) + abs(M.coef[i][1]) + abs(M.coef[i][2]);
        if (max < sum) max = sum;

    }
    return max;
}

norm_inf :: #bake_arguments mat_norm(tpose=false);
norm_one :: #bake_arguments mat_norm(tpose=true);

/** Setup u for Householder reflection to zero all v components but first **/
make_reflector :: (v: v3f) -> (u: v3f) {
    s := sqrt(dot(v, v));

    u: v3f = ---;
    u.x = v.x;
    u.y = v.y;
    u.z = v.z + ifx v.z<0 then -s else s;

    s = sqrt(2/dot(u, u));

    return u * s;
}

/** Apply Householder reflection represented by u to column vectors of M **/
reflect_cols :: (M: *Matrix3, u: v3f) {
    for i: 0..2 {
        s := u.x*M.coef[0][i] + u.y*M.coef[1][i] + u.z*M.coef[2][i];
        for j: 0..2 M.coef[j][i] -= u.fields[j]*s;
    }
}

/** Apply Householder reflection represented by u to row vectors of M **/
reflect_rows :: (M: *Matrix3, u: v3f) {
    for i: 0..2 {
        s := dot(u, M.v[i]);
        for j: 0..2 M.coef[i][j] -= u.fields[j]*s;
    }
}


/*
/** Return index of column of M containing maximum abs entry, or -1 if M=0 **/
int find_max_col(HMatrix M)
{
    float abs, max;
    int i, j, col;
    max = 0.f; col = -1;
    for (i=0; i<3; i++) for (j=0; j<3; j++) {
    abs = M[i][j]; if (abs<0.f) abs = -abs;
    if (abs>max) {max = abs; col = j;}
    }
    return col;
}

/** Find orthogonal factor Q of rank 1 (or less) M **/
void do_rank1(HMatrix M, HMatrix Q)
{
    float v1[3], v2[3], s;
    int col;
    /* If rank(M) is 1, we should find a non-zero column in M */
    col = find_max_col(M);
    if (col<0) {mat_copy(Q,=,mat_id,4); return;} /* Rank is 0 */
    v1[0] = M[0][col]; v1[1] = M[1][col]; v1[2] = M[2][col];
    make_reflector(v1, v1); reflect_cols(M, v1);
    v2[0] = M[2][0]; v2[1] = M[2][1]; v2[2] = M[2][2];
    make_reflector(v2, v2); reflect_rows(M, v2);
    s = M[2][2];
    mat_copy(Q,=,mat_id,4);
    if (s<0.f) Q[2][2] = -1.f;
    reflect_cols(Q, v1); reflect_rows(Q, v2);
}

/** Find orthogonal factor Q of rank 2 (or less) M using adjoint transpose **/
void do_rank2(HMatrix M, HMatrix MadjT, HMatrix Q)
{
    float v1[3], v2[3];
    float w, x, y, z, c, s, d;
    int col;
    /* If rank(M) is 2, we should find a non-zero column in MadjT */
    col = find_max_col(MadjT);
    if (col<0) {do_rank1(M, Q); return;} /* Rank<2 */
    v1[0] = MadjT[0][col]; v1[1] = MadjT[1][col]; v1[2] = MadjT[2][col];
    make_reflector(v1, v1); reflect_cols(M, v1);
    vcross(M[0], M[1], v2);
    make_reflector(v2, v2); reflect_rows(M, v2);
    w = M[0][0]; x = M[0][1]; y = M[1][0]; z = M[1][1];
    if (w*z>x*y) {
    c = z+w; s = y-x; d = sqrtf(c*c+s*s); c = c/d; s = s/d;
    Q[0][0] = Q[1][1] = c; Q[0][1] = -(Q[1][0] = s);
    } else {
    c = z-w; s = y+x; d = sqrtf(c*c+s*s); c = c/d; s = s/d;
    Q[0][0] = -(Q[1][1] = c); Q[0][1] = Q[1][0] = s;
    }
    Q[0][2] = Q[2][0] = Q[1][2] = Q[2][1] = 0.f; Q[2][2] = 1.f;
    reflect_cols(Q, v1); reflect_rows(Q, v2);
}
*/


// Polar matrix decomposition.
// This returns an orthogonal matrix Q, and a matrix S such that M=Q*S.
polar_decomp :: (M: Matrix3) -> (Q: Matrix3, S: Matrix3, det: float) {  // Note: If we just made this polymorphic, it could automatically work on Matrix4 or Matrix3 arguments, and you wouldn't need to care or make an intermediate temporary variable.
    do_rank2 :: (M: *Matrix3, MadjT: Matrix3) -> Matrix3 {
        Q: Matrix3;

        v1: v3f;

        /* If rank(M) is 2, we should find a non-zero column in MadjT */
        col := 0;//find_max_col(MadjT); // @@
        //if (col<0) {do_rank1(M, Q); return;} /* Rank<2 */

        //v1 = column(Madj, col);
        v1.x = MadjT.coef[0][col];
        v1.y = MadjT.coef[1][col];
        v1.z = MadjT.coef[2][col];
        v1 = make_reflector(v1);
        reflect_cols(M, v1);

        v2 := cross(M.v[0], M.v[1]);
        v2 = make_reflector(v2);
        reflect_rows(M, v2);

        w := M.coef[0][0];
        x := M.coef[0][1];
        y := M.coef[1][0];
        z := M.coef[1][1];
        if w*z > x*y {
            c := z+w;
            s := y-x;
            d := sqrt(c*c+s*s);
            c /= d;
            s /= d;
            Q.coef[0][0], Q.coef[1][1] = c;
            Q.coef[0][1] = -s;
            Q.coef[1][0] = s;
        } else {
            c := z-w;
            s := y+x;
            d := sqrt(c*c+s*s);
            c /= d;
            s /= d;
            Q.coef[0][0] = -c;
            Q.coef[1][1] = c;
            Q.coef[0][1], Q.coef[1][0] = s;
        }

        Q.coef[0][2], Q.coef[2][0], Q.coef[1][2], Q.coef[2][1] = 0.0;
        Q.coef[2][2] = 1.0;

        reflect_cols(*Q, v1);
        reflect_rows(*Q, v2);
        return Q;
    }

    TOL :: 1.0e-6;

    Mk := transpose(M);

    det: float;
    E_one := FLOAT32_MAX;
    M_one := norm_one(Mk);
    M_inf := norm_inf(Mk);

    while E_one > M_one*TOL {
        MadjTk := adjoint_transpose(Mk);

        det = dot(Mk.v[0], MadjTk.v[0]);
        if det == 0.0 {
            Mk = do_rank2(*Mk, MadjTk);
            break;
        }

        MadjT_one := norm_one(MadjTk);
        MadjT_inf := norm_inf(MadjTk);

        gamma := sqrt(sqrt((MadjT_one*MadjT_inf)/(M_one*M_inf))/abs(det));
        g1 := gamma * 0.5;
        g2 := 0.5 / (gamma*det);

        Ek := Mk;
        Mk = g1 * Mk + g2 * MadjTk;
        Ek -= Mk;

        E_one = norm_one(Ek);
        M_one = norm_one(Mk);
        M_inf = norm_inf(Mk);
    }

    Q := transpose(Mk);
    S := Mk * M;

    for i: 0..2 for j: 0..2 {
        S.coef[i][j] = 0.5 * (S.coef[i][j] + S.coef[j][i]);
        S.coef[j][i] = S.coef[i][j];
    }

    return Q, S, det;
}

rotation_matrix :: ($T: Type, q: Quaternion) -> T {
    m: T;

    #if T == Matrix4  m._44 = 1;

    xs := q.x * 2;
    ys := q.y * 2;
    zs := q.z * 2;

    wx := q.w * xs;
    wy := q.w * ys;
    wz := q.w * zs;

    _xx := q.x * xs;
    xy := q.x * ys;
    xz := q.x * zs;

    yy := q.y * ys;
    yz := q.y * zs;
    zz := q.z * zs;

    m._11 = 1.0 - (yy + zz);
    m._12 = xy - wz;
    m._13 = xz + wy;

    m._21 = xy + wz;
    m._22 = 1.0 - (_xx + zz);
    m._23 = yz - wx;

    m._31 = xz - wy;
    m._32 = yz + wx;
    m._33 = 1.0 - (_xx + yy);

    return m;
}

identity_of :: ($T: Type) -> T {
    result: T;
    identity(*result);
    return result;
}


identity :: (m: *$T/interface AnyMatrix) {
    // Pass a pointer to an uninitialized matrix.
    // We fill out out as the identity.

    memset(m, 0, size_of(T));
    m._11 = 1;
    m._22 = 1;

    #if T.coef.count > 2 then m._33 = 1;
    #if T == Matrix4     then m._44 = 1;
}
