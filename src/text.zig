//! Text widget definitiion
const std = @import("std");
const p = @import("position.zig");
const io = @import("io.zig");

// Text is defined not as []Cell so it can be defined like this,
// & be passed around instead of needing allocator and functions,
// to construct if tied with `Cell`.
const Text = @This();

value: []const u8,
bg: io.Bg = .default,
fg: io.Fg = .default,

pub fn new(str: []const u8) Text {
    return .{ .value = str };
}

pub fn len(self: *const Text) p.Unit {
    return @intCast(self.value.len);
}
