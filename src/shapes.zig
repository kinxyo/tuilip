const std = @import("std");
const t = @import("types.zig");
const Canvas = @import("canvas.zig").Canvas;

/// Starts drawing text from the point of origin.
pub fn drawTextFrom(cv: *Canvas, origin: Point, str: []const u8) !void {
    for (str, 0..) |char, idx| {
        const tmp: u16 = @intCast(idx);
        try cv.draw(origin.x + tmp, origin.y, char);
    }
}

/// clear text drawn from `drawTextFrom` from the screen.
pub fn clearTextFrom(cv: *Canvas, origin: Point, str: []const u8) !void {
    for (0..str.len) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.clear(origin.x + tmp, origin.y);
    }
}

/// Drawned text is aligned center at point of origin.
pub fn drawTextAt(cv: *Canvas, origin: Point, str: []const u8) !void {
    for (str, 0..) |char, idx| {
        const tmp: u16 = @intCast(idx);
        try cv.draw(origin.x - str.len + 1 + tmp, origin.y, char);
    }
}

/// clear text drawn from `drawTextAt` from the screen.
pub fn clearTextAt(cv: *Canvas, origin: Point, str: []const u8) !void {
    for (0..str.len) |idx| {
        const tmp: u16 = @intCast(idx);
        try cv.clear(origin.x - str.len + 1 + tmp, origin.y);
    }
}

pub fn drawCorner(cv: *Canvas, p: Point, c: Side) !void {
    try cv.draw(p.x, p.y, c.toChar());
}

pub fn clearCorner(cv: *Canvas, p: Point) !void {
    try cv.clear(p.x, p.y);
}

pub fn drawLineHzn(cv: *Canvas, origin: Point, length: t.Unit) !void {
    for (origin.x..(origin.x + length)) |idx| {
        try cv.draw(idx, origin.y, Side.SideHzn.toChar());
    }
}

pub fn clearLineHzn(cv: *Canvas, origin: Point, length: t.Unit) !void {
    for (origin.x..(origin.x + length)) |idx| {
        try cv.clear(idx, origin.y);
    }
}

pub fn drawLineVtl(cv: *Canvas, origin: Point, length: t.Unit) !void {
    for (origin.y..(origin.y + length)) |idx| {
        try cv.draw(origin.x, idx, Side.SideVtl.toChar());
    }
}

pub fn clearLineVtl(cv: *Canvas, origin: Point, length: t.Unit) !void {
    for (origin.y..(origin.y + length)) |idx| {
        try cv.clear(origin.x, idx);
    }
}

pub fn drawRect(cv: *Canvas, origin: Point, length: t.Unit, breadth: t.Unit) !void {
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

pub fn clearRect(cv: *Canvas, origin: Point, length: t.Unit, breadth: t.Unit) !void {
    try clearLineHzn(cv, .{ .x = origin.x, .y = origin.y }, breadth);
    try clearLineVtl(cv, .{ .x = origin.x + breadth, .y = origin.y }, length);
    try clearLineHzn(cv, .{ .x = origin.x, .y = origin.y + length }, breadth);

    try clearCorner(cv, .{ .x = origin.x, .y = origin.y });
    try clearCorner(cv, .{ .x = origin.x + breadth, .y = origin.y });
    try clearCorner(cv, .{ .x = origin.x, .y = origin.y + length });
    try clearCorner(cv, .{ .x = origin.x + breadth, .y = origin.y + length });
}

pub fn drawSquare(cv: *Canvas, origin: Point, side: t.Unit) !void {
    // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
    try drawRect(cv, origin, side, side * 2);
}

pub fn clearSquare(cv: *Canvas, origin: Point, side: t.Unit) !void {
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

    pub fn toChar(self: Side) t.Unicode {
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
