const std = @import("std");
const t = @import("types.zig");

/// Struct representing Box (underlying definition for various shapes and classes).
pub const Box = struct {
    origin: t.Point,
    height: t.Unit = 1,
    width: t.Unit = 1,
    zindex: usize = 1,
    child: std.ArrayList(t.Widget) = .empty,

    //  ========= PUBLIC =========

    pub fn addBox(
        self: *Box,
        allocator: std.mem.Allocator,
        size: t.Size,
        pos: t.ArbPoint,
    ) !Box {
        const box: t.Box = .{
            .height = size.height,
            .width = size.width,
            .origin = self.calculatePos(pos),
        };
        try self.insert(allocator, .{ .box = box });
        return box;
    }

    pub fn addBoundedBox(self: *Box, allocator: std.mem.Allocator, size: t.Size, pos: t.Point) !Box {
        const box: t.Box = .{
            .height = size.height,
            .width = size.width,
            .origin = self.calculateBoundedPos(pos),
        };
        try self.insert(allocator, .{ .box = box });
        return box;
    }

    pub fn addText(self: *Box, allocator: std.mem.Allocator, str: []const u8, pos: t.Point) !void {
        const text: t.Text = .{
            .value = str,
            .origin = self.calculatePos(pos),
        };
        try self.insert(allocator, .{ .text = text });
    }

    /// Meant for debugging.
    pub fn log(self: *const Box) void {
        std.log.debug("Up: row={}, col={}\n", .{ self.origin.row, self.origin.col });
    }

    //  ========= PRIVATE =========

    fn calculatePos(self: *Box, pos: t.ArbPoint) t.Point {
        const pos_col: t.Unit = @intFromFloat(@abs(pos.col));
        const pos_row: t.Unit = @intFromFloat(@abs(pos.row));
        const col = if (pos.col > 0) self.origin.col + pos_col else self.origin.col - pos_col;
        const row = if (pos.row > 0) self.origin.row + pos_row else self.origin.row - pos_row;
        return .{ .col = col, .row = row };
    }

    fn calculateBoundedPos(self: *Box, pos: t.Point) t.Point {
        if (pos.col < 0) return .{ .col = 1, .row = pos.row };
        if (pos.row < 0) return .{ .col = pos.col, .row = 1 };
        if (pos.col >= self.origin.col + self.width) return .{ .col = self.origin.col - 1, .row = pos.row };
        if (pos.row >= self.origin.row + self.height) return .{ .col = pos.col, .row = self.origin.row - 1 };
        return .{ .col = self.origin.col + pos.col, .row = self.origin.row + pos.row };
    }

    fn insert(self: *Box, allocator: std.mem.Allocator, child: t.Widget) !void {
        try self.child.append(allocator, child);
    }

    /// Depreciated calculate pos function
    fn oldCalculatePos(self: *Box, top: f32, left: f32) t.Point {
        const float_bh: f32 = @floatFromInt(self.height);
        const float_bw: f32 = @floatFromInt(self.width);

        const float_row_offset: f32 = top * float_bh / 100;
        const float_col_offset: f32 = left * float_bw / 100;

        const row_offset: usize = @intFromFloat(float_row_offset);
        const col_offset: usize = @intFromFloat(float_col_offset);

        const row = self.origin.row + row_offset;
        const col = self.origin.col + col_offset;

        return .{ .col = @intCast(col), .row = @intCast(row) };
    }
};
