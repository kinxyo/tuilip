const std = @import("std");
const t = @import("types.zig");

/// Struct representing Box (underlying definition for various shapes and classes).
pub const Box = struct {
    origin: t.Point,
    height: t.Unit = 1,
    width: t.Unit = 1,
    zindex: usize = 1,
    child: std.ArrayList(t.Child) = .empty,

    pub fn insert(self: *Box, allocator: std.mem.Allocator, child: t.Widget, pos: t.Position) !void {
        try self.child.append(allocator, .{ .widget = child, .pos = pos });
    }

    /// Meant for debugging.
    pub fn log(self: *const Box) void {
        std.log.debug("Up: row={}, col={}\n", .{ self.origin.row, self.origin.col });
    }
};
