//! Text widget definitiion
const std = @import("std");
const t = @import("types.zig");
const term = @import("terminal.zig");

// Text is defined not as []Cell so it can be defined like this,
// & be passed around instead of needing allocator and functions,
// to construct if tied with `Cell`.
const Text = @This();

value: []const u8,
bg: term.Bg = .default,
fg: term.Fg = .default,

pub fn new(str: []const u8) Text {
    return .{ .value = str };
}
