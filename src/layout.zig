const std = @import("std");
const t = @import("types.zig");
const shapes = @import("shapes.zig");
const Canvas = @import("canvas.zig").Canvas;
const helpers = @import("helpers.zig");

pub const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

pub const Box = struct {
    height: t.Unit = 1,
    width: t.Unit = 1,
    fill: bool = true,
    direction: Direction = .RIGHT,
    zindex: usize = 1,
};

pub const Layout = struct {
    cv: *const Canvas,
    list: std.ArrayList(Box) = .empty,
    allocator: std.mem.Allocator,

    pub fn drawBox(self: *Layout, box: Box) !void {
        try self.list.append(self.allocator, box);
    }

    pub fn stackAll(self: *Layout, count: usize, orientation: helpers.Orientation) !void {
        switch (orientation) {
            .HORIZONTAL => try helpers.autoBoxes(
                self.cv,
                count,
                self.cv.width,
                self.cv.height,
                self.cv.margin,
                .HORIZONTAL,
            ),
            .VERTICAL => try helpers.autoBoxes(
                self.cv,
                count,
                self.cv.height,
                self.cv.width,
                self.cv.margin,
                .VERTICAL,
            ),
        }
    }
};
