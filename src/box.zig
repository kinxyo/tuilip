const std = @import("std");
const t = @import("types.zig");
const Canvas = @import("canvas.zig").Canvas;
const shapes = @import("shapes.zig");

/// Container
pub const Box = struct {
    length: t.Unit = 1,
    breadth: t.Unit = 1,
    fill: bool = true,
    /// Percentage
    position: t.Position = .{ .top = 0, .left = 0 },
    zindex: usize = 1,

    pub fn draw(self: *const Box, cv: *const Canvas) !void {
        const origin_x = self.position.left / 100.0 * @as(f32, @floatFromInt(cv.width));
        const origin_y = self.position.top / 100.0 * @as(f32, @floatFromInt(cv.height));

        try shapes.drawRect(
            cv,
            .{
                .x = @intFromFloat(origin_x),
                .y = @intFromFloat(origin_y),
            },
            self.length,
            self.breadth,
        );
    }
};

pub const StackBox = struct {
    height: t.Unit = 1,
    width: t.Unit = 1,
    fill: bool = true,
    direction: t.Direction = .RIGHT,
    zindex: usize = 1,
};
