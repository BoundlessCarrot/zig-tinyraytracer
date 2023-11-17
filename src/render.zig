// Necessary
const std = @import("std");
const types = @import("types.zig");

// Functions
const assert = std.debug.assert;

// Types
const Color = types.Color;
const Vec3f = types.Vec3f;
const arrayList = std.ArrayList;

// Shortcuts
const fs = std.fs;

// pub fn render(t: anytype, data: anytype) !void;

pub fn render_color(filename: []const u8, image: arrayList(Color), width: usize, height: usize) !void {
    assert(image.items.len == width * height);

    const file = try fs.cwd().createFile(filename, .{});
    defer file.close();
    var writer = file.writer();

    try writer.print("P3\n{} {}\n255\n", .{ width, height });

    for (image.items) |pixel| {
        try writer.print("{} {} {}\n", .{ pixel.r, pixel.g, pixel.b });
    }
}

pub fn render_vec(filename: []const u8, image: arrayList(Vec3f), width: usize, height: usize) !void {
    assert(image.items.len == width * height);

    const file = try fs.cwd().createFile(filename, .{});
    defer file.close();
    var writer = file.writer();

    try writer.print("P3\n{} {}\n255\n", .{ width, height });

    for (image.items) |vec| {
        try writer.print("{} {} {}\n", .{ vec.x, vec.y, vec.z });
    }
}
