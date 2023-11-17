// Necessary
const std = @import("std");

// QoL
const ArrayList = std.ArrayList;
const assert = std.debug.assert;

// Constants
const PI = 3.14159;
const f32_MAX = std.math.floatMax(f32);

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,

    pub fn init(r: u8, g: u8, b: u8) Color {
        return Color{ .r = r, .g = g, .b = b };
    }
};

pub const Vec3f = struct {
    items: @Vector(3, f32),
    x: f32,
    y: f32,
    z: f32,

    const Self = @This();

    pub fn init(x: f32, y: f32, z: f32) Vec3f {
        var new_vec = Vec3f{ .items = @Vector(3, f32){ x, y, z }, .x = undefined, .y = undefined, .z = undefined };
        try new_vec.update();
        return new_vec;
    }

    pub fn init_from_vec(vec: @Vector(3, f32)) Vec3f {
        var new_vec = Vec3f{ .items = vec, .x = undefined, .y = undefined, .z = undefined };
        try new_vec.update();
        return new_vec;
    }

    pub fn update(self: *Self) !void {
        self.x = self.items[0];
        self.y = self.items[1];
        self.z = self.items[2];
    }

    pub fn reverse_update(self: *Self) !void {
        self.items = @Vector(3, f32){ self.x, self.y, self.z };
    }

    pub fn dot_product(vec_a: Vec3f, vec_b: Vec3f) f32 {
        return vec_a.x * vec_b.x + vec_a.y * vec_b.y + vec_a.z * vec_b.z;
    }

    pub fn cast_ray(orig: Vec3f, dir: Vec3f, sphere: Sphere) Color {
        var sphere_dist: f32 = f32_MAX;
        if (!try sphere.ray_intersect(orig, dir, &sphere_dist)) {
            return Color.init(52, 235, 225);
        }
        return Color.init(3, 3, 3);
    }

    pub fn normalize(self: *Self) !void {
        const length = @sqrt(self.dot_product(self.*));
        self.x /= length;
        self.y /= length;
        self.z /= length;

        try self.reverse_update();
    }
};

pub const Sphere = struct {
    center: Vec3f,
    radius: f32,

    const Self = @This();

    pub fn init(center: Vec3f, radius: f32) Sphere {
        return Sphere{ .center = center, .radius = radius };
    }

    pub fn ray_intersect(self: Sphere, orig: Vec3f, dir: Vec3f, t0: *f32) !bool {
        var L: Vec3f = Vec3f.init_from_vec(self.center.items - orig.items);
        var tca: f32 = Vec3f.dot_product(L, dir);
        var d2: f32 = Vec3f.dot_product(L, L) - (tca * tca);

        if (d2 > (self.radius * self.radius)) {
            return false;
        }

        var thc: f32 = @sqrt(self.radius * self.radius - d2);
        t0.* = tca - thc;

        var t1: f32 = tca + thc;

        if (t0.* < 0) {
            t0.* = t1;
        }

        const intersect_bool = if (t0.* < 0) false else true;
        return intersect_bool;
    }
};
