const std = @import("std");
const t = @import("types.zig");

/// Struct representing Box (underlying definition for various shapes and classes).
pub const Box = struct {
    allocator: std.mem.Allocator,
    origin: t.Point,
    height: t.Unit = 1,
    width: t.Unit = 1,
    zindex: usize = 1,
    /// children are lazy init
    children: t.WidgetList,

    //  ========= PUBLIC =========

    // NOTE: No constructor function.

    /// Get widget from children list.
    pub fn get(self: *const Box, id: []const u8) ?*t.Widget {
        if (self.children) |c| {
            return c.getPtr(id);
        }
        return null;
    }

    /// To insert `Box` widget in the container.
    /// The position is not calculated internally but provided by user.
    pub fn insertBoxCS(self: *Box, id: []const u8, size: t.Size, pos: t.Point) !void {
        try self.children.add(self.allocator, id, .{
            .box = .{
                .allocator = self.allocator,
                .height = size.height,
                .width = size.width,
                .origin = pos,
                .children = .{},
            },
        });
    }

    /// To insert `Box` widget in the container.
    /// The position is calculated internally; relative to the parent's boundary.
    pub fn insertBox(self: *Box, id: []const u8, size: t.Size, pos: t.Point) !void {
        try self.insertBoxCS(id, size, self.calcalatePos(pos));
    }

    /// To insert Text widget in the container.
    pub fn addTextCS(self: *Box, id: []const u8, str: []const u8, pos: t.Point) !void {
        const text: t.Text = .{
            .value = str,
            .origin = pos,
        };
        try self.insert(id, .{ .text = text });
    }

    /// To insert Text widget in the container.
    pub fn addText(self: *Box, id: []const u8, str: []const u8, pos: t.Point) !void {
        try self.addTextCS(id, str, self.calcalatePos(pos));
    }

    /// Meant for debugging.
    pub fn log(self: *const Box) void {
        std.log.debug("Up: row={}, col={}\n", .{ self.origin.row, self.origin.col });
    }

    /// Destroy all box data.
    pub fn deinit(self: *Box) void {
        self.children.deinit();
    }

    //  ========= PRIVATE =========

    /// Evaluates position considering parent's boundary as constraint.
    fn calcalatePos(self: *Box, pos: t.Point) t.Point {
        // TODO: Optimize it further.
        if (pos.col < 0) return .{ .col = 1, .row = pos.row };
        if (pos.row < 0) return .{ .col = pos.col, .row = 1 };
        if (pos.col >= self.origin.col + self.width) return .{ .col = self.origin.col - 1, .row = pos.row };
        if (pos.row >= self.origin.row + self.height) return .{ .col = pos.col, .row = self.origin.row - 1 };
        return .{ .col = self.origin.col + pos.col, .row = self.origin.row + pos.row };
    }
};
