//! Cell widget definitiion
const std = @import("std");
const term = @import("terminal.zig");
const t = @import("types.zig");

pub const Cell = @This();

bg: term.Bg = .default,
fg: term.Fg = .default,
char: t.Unicode = ' ',
