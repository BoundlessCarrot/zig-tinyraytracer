// Necessary
const std = @import("std");
const render = @import("render.zig");
const types = @import("types.zig");

// Functions
const print = std.debug.print;
const assert = std.debug.assert;
const render_color = render.render_color;
const render_vec = render.render_vec;

// Types
const ArrayList = std.ArrayList;
const Color = types.Color;
const Sphere = types.Sphere;
const Vec3f = types.Vec3f;

// Constants
const PI = 3.14159;
const ZERO_VECTOR = Vec3f.init(0.0, 0.0, 0.0);

// fn whiteout(framebuffer: *ArrayList(Color), len: usize) !void {
//     framebuffer.clearAndFree();
//     try framebuffer.appendNTimes(Color.init(255, 255, 255), len);
// }

pub fn main() !void {
    const width = 1024;
    const height = 768;
    const fov: f32 = PI / 2.0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var framebuffer = ArrayList(Color).init(arena.allocator());
    defer framebuffer.deinit();

    var sphere = Sphere.init(Vec3f.init(-3.0, 0.0, -16.0), 2.0);

    for (0..height) |j| {
        for (0..width) |i| {
            var x: f32 = (2 * (@as(f32, @floatFromInt(i)) + 0.5) / @as(f32, @floatFromInt(width)) - 1) * @tan(fov / 2.0) * @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height));
            var y: f32 = -(2 * (@as(f32, @floatFromInt(j)) + 0.5) / @as(f32, @floatFromInt(height)) - 1) * @tan(fov / 2.0);
            var dir: Vec3f = Vec3f.init(x, y, -1.0);
            try dir.normalize();
            // framebuffer.items[i + j * width] = Vec3f.cast_ray(ZERO_VECTOR, dir, sphere);
            try framebuffer.insert(i + j * width, Vec3f.cast_ray(ZERO_VECTOR, dir, sphere));
        }
    }

    try render_color("out.ppm", framebuffer, width, height);
}
