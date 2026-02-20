const std = @import("std");
const p = @import("position.zig");

const Box = @This();

size: p.Size,

pub fn len(self: *const Box) p.Unit {
    return self.size.cols;
}

pub fn new(rows: p.Unit, cols: p.Unit) Box {
    return .{ .size = .{ .cols = cols, .rows = rows } };
}
