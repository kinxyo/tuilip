const std = @import("std");
const t = @import("types.zig");
const Canvas = @import("canvas.zig").Canvas;

/// Starts drawing text from the point of origin.
pub fn drawTextFrom(cv: *const Canvas, origin: Point, str: []const u8) !void {
    for (str, 0..) |char, idx| {
        const tmp: u16 = @intCast(idx);
        try cv.drawPoint(origin.x + tmp, origin.y, char);
    }
}

/// clear text drawn from `drawTextFrom` from the screen.
pub fn clearTextFrom(cv: *const Canvas, origin: Point, str: []const u8) !void {
    for (0..str.len) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.clearPoint(origin.x + tmp, origin.y);
    }
}

/// Drawned text is aligned center at point of origin.
pub fn drawTextAt(cv: *const Canvas, origin: Point, str: []const u8) !void {
    for (str, 0..) |char, idx| {
        const tmp: u16 = @intCast(idx);
        try cv.drawPoint(origin.x - str.len + 1 + tmp, origin.y, char);
    }
}

/// clear text drawn from `drawTextAt` from the screen.
pub fn clearTextAt(cv: *const Canvas, origin: Point, str: []const u8) !void {
    for (0..str.len) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.clearPoint(origin.x - str.len + 1 + tmp, origin.y);
    }
}

pub fn drawCorner(cv: *const Canvas, p: Point, c: Side) !void {
    try cv.drawPoint(p.x, p.y, c.render());
}

pub fn clearCorner(cv: *const Canvas, p: Point) !void {
    try cv.clearPoint(p.x, p.y);
}

pub fn drawLineHzn(cv: *const Canvas, origin: Point, length: t.Unit) !void {
    for (origin.x..(origin.x + length)) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.drawPoint(tmp, origin.y, Side.SideHzn.render());
    }
}

pub fn clearLineHzn(cv: *const Canvas, origin: Point, length: t.Unit) !void {
    for (origin.x..(origin.x + length)) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.clearPoint(tmp, origin.y);
    }
}

pub fn drawLineVtl(cv: *const Canvas, origin: Point, length: t.Unit) !void {
    for (origin.y..(origin.y + length)) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.drawPoint(origin.x, tmp, Side.SideVtl.render());
    }
}

pub fn clearLineVtl(cv: *const Canvas, origin: Point, length: t.Unit) !void {
    for (origin.y..(origin.y + length)) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.clearPoint(origin.x, tmp);
    }
}

pub fn drawRect(cv: *const Canvas, origin: Point, length: t.Unit, breadth: t.Unit) !void {
    // roof
    try drawLineHzn(cv, .{ .x = origin.x, .y = origin.y }, breadth);
    // left side
    try drawLineVtl(cv, .{ .x = origin.x + breadth, .y = origin.y }, length);
    // right side
    try drawLineVtl(cv, .{ .x = origin.x, .y = origin.y }, length);
    // base
    try drawLineHzn(cv, .{ .x = origin.x, .y = origin.y + length }, breadth);

    try drawCorner(cv, .{ .x = origin.x, .y = origin.y }, .TopLeft);
    try drawCorner(cv, .{ .x = origin.x + breadth, .y = origin.y }, .TopRight);
    try drawCorner(cv, .{ .x = origin.x, .y = origin.y + length }, .BottomLeft);
    try drawCorner(cv, .{ .x = origin.x + breadth, .y = origin.y + length }, .BottomRight);
}

pub fn clearRect(cv: *const Canvas, origin: Point, length: t.Unit, breadth: t.Unit) !void {
    try clearLineHzn(cv, .{ .x = origin.x, .y = origin.y }, breadth);
    try clearLineVtl(cv, .{ .x = origin.x + breadth, .y = origin.y }, length);
    try clearLineHzn(cv, .{ .x = origin.x, .y = origin.y + length }, breadth);

    try clearCorner(cv, .{ .x = origin.x, .y = origin.y });
    try clearCorner(cv, .{ .x = origin.x + breadth, .y = origin.y });
    try clearCorner(cv, .{ .x = origin.x, .y = origin.y + length });
    try clearCorner(cv, .{ .x = origin.x + breadth, .y = origin.y + length });
}

pub fn drawSquare(cv: *const Canvas, origin: Point, side: t.Unit) !void {
    // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
    try drawRect(cv, origin, side, side * 2);
}

pub fn clearSquare(cv: *const Canvas, origin: Point, side: t.Unit) !void {
    // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
    try clearRect(cv, origin, side, side * 2);
}

pub const Point = struct {
    x: t.Unit,
    y: t.Unit,
};

/// For creating shape of box
/// ┌─┐│└┘
pub const Side = enum {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
    SideHzn,
    SideVtl,

    pub fn render(self: Side) t.Unicode {
        return switch (self) {
            .TopLeft => '┌',
            .TopRight => '┐',
            .BottomLeft => '└',
            .BottomRight => '┘',
            .SideHzn => '─',
            .SideVtl => '│',
        };
    }
};
