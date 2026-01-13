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

/// Returns half of text length in integer type to be passed in offset function.
pub fn lenHalf(self: *const Text) p.Offset {
    return @intCast(self.value.len / 2);
}
