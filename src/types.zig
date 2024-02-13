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

    const Self = @This();

    pub fn init(r: u8, g: u8, b: u8) Color {
        return Color{ .r = r, .g = g, .b = b };
    }

    pub fn colorToVec(color: Self) Vec3f {
        const r_norm = @as(f32, @floatFromInt(color.r)) / 255.0;
        const g_norm = @as(f32, @floatFromInt(color.g)) / 255.0;
        const b_norm = @as(f32, @floatFromInt(color.b)) / 255.0;

        return Vec3f{ .x = r_norm, .y = g_norm, .z = b_norm };
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

    pub fn normalize(self: *Self) !void {
        const length = @sqrt(self.dot_product(self.*));
        self.x /= length;
        self.y /= length;
        self.z /= length;

        try self.reverse_update();
    }

    pub fn vecToColor(vec: Self) Color {
        const r = @as(u8, @intFromFloat(vec.x * 255.0));
        const g = @as(u8, @intFromFloat(vec.y * 255.0));
        const b = @as(u8, @intFromFloat(vec.z * 255.0));

        return Color{ .r = r, .g = g, .b = b };
    }
};

pub const Sphere = struct {
    center: Vec3f,
    radius: f32,
    material: Material,

    const Self = @This();

    pub fn init(center: Vec3f, radius: f32, material: Material) Sphere {
        return Sphere{ .center = center, .radius = radius, .material = material };
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

pub const Ray = struct {
    orig: Vec3f,
    dir: Vec3f,

    pub fn init(orig: Vec3f, dir: Vec3f) Ray {
        return Ray{ .orig = orig, .dir = dir };
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

    pub fn cast_ray(orig: Vec3f, dir: Vec3f, sphere: Sphere) Color {
        var sphere_dist: f32 = f32_MAX;
        if (!try sphere.ray_intersect(orig, dir, &sphere_dist)) {
            return Color.init(52, 235, 225);
        }
        return Color.init(3, 3, 3);
    }

    //     bool scene_intersect(const Vec3f &orig, const Vec3f &dir, const std::vector<Sphere> &spheres, Vec3f &hit, Vec3f &N, Material &material) {
    //     float spheres_dist = std::numeric_limits<float>::max();
    //     for (size_t i=0; i < spheres.size(); i++) {
    //         float dist_i;
    //         if (spheres[i].ray_intersect(orig, dir, dist_i) && dist_i < spheres_dist) {
    //             spheres_dist = dist_i;
    //             hit = orig + dir*dist_i;
    //             N = (hit - spheres[i].center).normalize();
    //             material = spheres[i].material;
    //         }
    //     }
    //     return spheres_dist<1000;
    // }

    // TODO: Test and refactor - this is a direct translation and can't be right
    pub fn sceneIntersect(orig: Vec3f, dir: Vec3f, spheres: ArrayList(Sphere), hit: Vec3f, N: Vec3f, material: Material) bool {
        var spheres_dist = f32_MAX;

        // NOTE: Iterate directly over the list instead of the index?
        for (0..spheres.items.len) |i| {
            // NOTE: IS the above initialization to undefined or 0?
            var dist_i: f32 = 0.0;

            if (spheres.items[i].ray_intersect(orig, dir, dist_i) and dist_i < spheres_dist) {
                spheres_dist = dist_i;

                // NOTE: Do these 3 _need_ to be passed in?
                hit = orig + dir * dist_i;
                N = try (hit - spheres.items[i].center).normalize();
                material = spheres.items[i].material;
            }
        }

        return spheres_dist < 1000;
    }
};

pub const Material = struct {
    diffuse_color: Vec3f!Color,

    pub fn init(color: Vec3f!Color) Material {
        return Material{
            .diffuse_color = color,
        };
    }

    pub fn initDefault() Material {
        return Material{
            .diffuse_color = Vec3f{ .x = 0, .y = 0, .z = 0 },
        };
    }
};
