const std = @import("std");
const t = @import("types.zig");

const Cell = @This();

bg: t.Bg = .default,
fg: t.Fg = .default,
char: t.Unicode = ' ',
