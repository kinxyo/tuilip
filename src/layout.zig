const std = @import("std");
const t = @import("types.zig");
const shapes = @import("shapes.zig");
const Canvas = @import("canvas.zig").Canvas;
const helpers = @import("helpers.zig");
const b = @import("box.zig");

pub const Layout = struct {
    cv: *Canvas,
    list: std.ArrayList(b.Box) = .empty,
    allocator: std.mem.Allocator,

    pub fn drawStackBox(self: *Layout, box: b.StackBox) !void {
        try self.list.append(self.allocator, box);
    }

    pub fn drawBox(self: *Layout, box: b.Box) !void {
        try self.list.append(self.allocator, box);
    }

    pub fn render(self: *Layout) !void {
        const box = self.list.items[0];

        try box.draw(self.cv);

        self.cv.render();
    }

    // ======= Random Fns ========

    pub fn stackAll(cv: *Canvas, count: usize, orientation: t.Orientation) !void {
        switch (orientation) {
            .HORIZONTAL => try helpers.autoBoxes(
                cv,
                count,
                cv.getCol() - 1,
                cv.getRow() - 1,
                cv.margin,
                .HORIZONTAL,
            ),
            .VERTICAL => try helpers.autoBoxes(
                cv,
                count,
                cv.getRow() - 1,
                cv.getCol() - 1,
                cv.margin,
                .VERTICAL,
            ),
        }
    }
};
