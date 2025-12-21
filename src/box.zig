const std = @import("std");
const t = @import("types.zig");

/// Struct representing Box (underlying definition for various shapes and classes).
/// children are lazy init
pub const Box = struct {
    allocator: std.mem.Allocator,
    origin: t.Point,
    height: t.Unit = 1,
    width: t.Unit = 1,
    zindex: usize = 1,
    children: ?std.StringHashMap(t.Widget) = null,

    //  ========= PUBLIC =========

    /// To insert Box widget in the container.
    /// The position provided IS NOT bounded within container's constraints.
    pub fn addBox(
        self: *Box,
        id: []const u8,
        size: t.Size,
        pos: t.ArbPoint,
    ) !*Box {
        const box: t.Box = .{
            .allocator = self.allocator,
            .height = size.height,
            .width = size.width,
            .origin = self.calculatePos(pos),
            .children = null,
        };

        try self.insert(id, .{ .box = box });
        return &self.children.?.getPtr(id).?.box;
    }

    /// To insert Box widget in the container.
    /// The position provided IS bounded within container's constraints.
    pub fn addBoundedBox(self: *Box, id: []const u8, size: t.Size, pos: t.Point) !Box {
        const box: t.Box = .{
            .height = size.height,
            .width = size.width,
            .origin = self.calculateBoundedPos(pos),
        };
        try self.insert(id, .{ .box = box });
        return &self.children.?.getPtr(id).?.box;
    }

    /// To insert Text widget in the container.
    pub fn addText(self: *Box, id: []const u8, str: []const u8, pos: t.Point) !void {
        const text: t.Text = .{
            .value = str,
            .origin = self.calculatePos(pos),
        };
        try self.insert(id, .{ .text = text });
    }

    /// Meant for debugging.
    pub fn log(self: *const Box) void {
        std.log.debug("Up: row={}, col={}\n", .{ self.origin.row, self.origin.col });
    }

    /// Destroy all box data.
    pub fn deinit(self: *Box) void {
        if (self.children) |*c| {
            c.deinit();
        }
    }

    //  ========= PRIVATE =========

    // TODO: Optimize it further.
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

    fn insert(self: *Box, id: []const u8, child: t.Widget) !void {
        if (self.children) |*c| {
            try c.put(id, child);
            return;
        }

        self.children = .init(self.allocator);
        try self.children.?.put(id, child);
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
