const std = @import("std");
const fmt = @import("fmt.zig");
const t = @import("types.zig");
const cv = @import("canvas.zig");

pub const Shapes = struct {
    cv: *const cv.Canvas,

    pub fn drawTextFrom(self: *const Shapes, origin: Point, str: []const u8) !void {
        for (str, 0..) |char, idx| {
            try self.cv.drawPoint(origin.x + idx, origin.y, char);
        }
    }

    pub fn clearTextFrom(self: *const Shapes, origin: Point, str: []const u8) !void {
        for (0..str.len) |idx| {
            try self.cv.clearPoint(origin.x + idx, origin.y);
        }
    }

    pub fn drawTextAt(self: *const Shapes, origin: Point, str: []const u8) !void {
        for (str, 0..) |char, idx| {
            try self.cv.drawPoint(origin.x - str.len + 1 + idx, origin.y, char);
        }
    }

    pub fn clearTextAt(self: *const Shapes, origin: Point, str: []const u8) !void {
        for (0..str.len) |idx| {
            try self.cv.clearPoint(origin.x - str.len + 1 + idx, origin.y);
        }
    }

    pub fn drawCorner(self: *const Shapes, p: Point, c: Box) !void {
        try self.cv.drawPoint(p.x, p.y, c.render());
    }

    pub fn clearCorner(self: *const Shapes, p: Point) !void {
        try self.cv.clearPoint(p.x, p.y);
    }

    pub fn drawLineHzn(self: *const Shapes, origin: Point, length: t.Unit) !void {
        for (origin.x..(origin.x + length)) |idx| {
            try self.cv.drawPoint(idx, origin.y, Box.SideHzn.render());
        }
    }

    pub fn clearLineHzn(self: *const Shapes, origin: Point, length: t.Unit) !void {
        for (origin.x..(origin.x + length)) |idx| {
            try self.cv.clearPoint(idx, origin.y);
        }
    }

    pub fn drawLineVtl(self: *const Shapes, origin: Point, length: t.Unit) !void {
        for (origin.y..(origin.y + length)) |idx| {
            try self.cv.drawPoint(origin.x, idx, Box.SideVtl.render());
        }
    }

    pub fn clearLineVtl(self: *const Shapes, origin: Point, length: t.Unit) !void {
        for (origin.y..(origin.y + length)) |idx| {
            try self.cv.clearPoint(origin.x, idx);
        }
    }

    pub fn drawRect(self: *const Shapes, origin: Point, length: t.Unit, breadth: t.Unit) !void {
        // roof
        try self.drawLineHzn(.{ .x = origin.x, .y = origin.y }, breadth);
        // left side
        try self.drawLineVtl(.{ .x = origin.x + breadth, .y = origin.y }, length);
        // right side
        try self.drawLineVtl(.{ .x = origin.x, .y = origin.y }, length);
        // base
        try self.drawLineHzn(.{ .x = origin.x, .y = origin.y + length }, breadth);

        try self.drawCorner(.{ .x = origin.x, .y = origin.y }, .TopLeft);
        try self.drawCorner(.{ .x = origin.x + breadth, .y = origin.y }, .TopRight);
        try self.drawCorner(.{ .x = origin.x, .y = origin.y + length }, .BottomLeft);
        try self.drawCorner(.{ .x = origin.x + breadth, .y = origin.y + length }, .BottomRight);
    }

    pub fn clearRect(self: *const Shapes, origin: Point, length: t.Unit, breadth: t.Unit) !void {
        // roof
        try self.clearLineHzn(.{ .x = origin.x, .y = origin.y }, breadth);
        // left side
        try self.clearLineVtl(.{ .x = origin.x + breadth, .y = origin.y }, length);
        // right side
        try self.clearLineVtl(.{ .x = origin.x, .y = origin.y }, length);
        // base
        try self.clearLineHzn(.{ .x = origin.x, .y = origin.y + length }, breadth);

        try self.clearCorner(.{ .x = origin.x, .y = origin.y });
        try self.clearCorner(.{ .x = origin.x + breadth, .y = origin.y });
        try self.clearCorner(.{ .x = origin.x, .y = origin.y + length });
        try self.clearCorner(.{ .x = origin.x + breadth, .y = origin.y + length });
    }

    pub fn drawSquare(self: *const Shapes, origin: Point, side: t.Unit) !void {
        // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
        try self.drawRect(origin, side, side * 2);
    }

    pub fn clearSquare(self: *const Shapes, origin: Point, side: t.Unit) !void {
        // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
        try self.clearRect(origin, side, side * 2);
    }
};

pub const Point = struct {
    x: t.Unit,
    y: t.Unit,
};

pub const Box = enum {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
    SideHzn,
    SideVtl,

    pub fn render(self: Box) t.Unicode {
        return switch (self) {
            // ┌─┐│└┘
            .TopLeft => '┌',
            .TopRight => '┐',
            .BottomLeft => '└',
            .BottomRight => '┘',
            .SideHzn => '─',
            .SideVtl => '│',
        };
    }
};
