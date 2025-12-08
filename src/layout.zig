const std = @import("std");
const t = @import("types.zig");
const shapes = @import("shapes.zig");
const Canvas = @import("canvas.zig").Canvas;
const helpers = @import("helpers.zig");
const b = @import("box.zig");

pub const Layout = struct {
    cv: *const Canvas,
    list: std.ArrayList(b.Box) = .empty,
    allocator: std.mem.Allocator,

    pub fn drawBox(self: *Layout, box: b.Box) !void {
        try self.list.append(self.allocator, box);
    }

    pub fn render(self: *Layout) !void {
        _ = self;
        // TODO: Draw a box on screen.
    }

    // ======= Random Fns ========

    pub fn stackAll(cv: *const Canvas, count: usize, orientation: t.Orientation) !void {
        switch (orientation) {
            .HORIZONTAL => try helpers.autoBoxes(
                cv,
                count,
                cv.width,
                cv.height,
                cv.margin,
                .HORIZONTAL,
            ),
            .VERTICAL => try helpers.autoBoxes(
                cv,
                count,
                cv.height,
                cv.width,
                cv.margin,
                .VERTICAL,
            ),
        }
    }
};
