//! Common types that are exported everywhere
const std = @import("std");
const Cell = @import("cell.zig");

pub const Unit = u16;
pub const Unicode = u21;

pub const UnxpErr = std.posix.UnexpectedError;

pub const Bg = enum(u8) {
    default = 39,
};
pub const Fg = enum(u8) {
    red = 31,
    default = 39,
};

pub const Widget = union(enum) {
    cell: Cell,
};
