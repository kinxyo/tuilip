//! Cell widget definitiion
const std = @import("std");
const io = @import("io.zig");

pub const Cell = @This();

bg: io.Bg = .default,
fg: io.Fg = .default,
char: u21 = ' ',
