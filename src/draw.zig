const std = @import("std");
const fmt = @import("fmt.zig");

const Unit = usize;
const Unicode = u21;

pub const Canvas = struct {
    height: Unit,
    width: Unit,

    pub fn init(hn: std.fs.File.Handle) Canvas {
        var size: std.posix.winsize = undefined;
        const res = std.posix.system.ioctl(hn, std.posix.T.IOCGWINSZ, @intFromPtr(&size));
        if (res < 0) return .{ .height = 0, .width = 0 };
        return .{ .height = size.row, .width = size.col };
    }

    pub fn drawPoint(self: *const Canvas, origin: Point, char: ?Unicode) !void {
        if (origin.x >= self.width or origin.y >= self.height) return error.ScreenLimitExceeded;
        fmt.printf("\x1b[{d};{d}H{u}", .{ origin.y, origin.x, char orelse '*' });
    }

    pub fn drawText(self: *const Canvas, origin: Point, str: []const u8) !void {
        for (str, 0..) |char, idx| {
            try self.drawPoint(.{ .x = origin.x - str.len + 1 + idx, .y = origin.y }, char);
        }
    }

    pub fn drawCorner(self: *const Canvas, p: Point, c: Box) !void {
        try self.drawPoint(p, c.render());
    }

    pub fn drawLineHzn(self: *const Canvas, origin: Point, length: Unit) !void {
        for (origin.x..(origin.x + length)) |idx| {
            try self.drawPoint(.{ .x = idx, .y = origin.y }, Box.SideHzn.render());
        }
    }

    pub fn drawLineVtl(self: *const Canvas, origin: Point, length: Unit) !void {
        for (origin.y..(origin.y + length)) |idx| {
            try self.drawPoint(.{ .x = origin.x, .y = idx }, Box.SideVtl.render());
        }
    }

    pub fn drawRect(self: *const Canvas, origin: Point, length: Unit, breadth: Unit) !void {
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

    pub fn drawSquare(self: *const Canvas, origin: Point, side: Unit) !void {
        // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
        try self.drawRect(origin, side, side * 2);
    }
};

pub const Point = struct {
    x: Unit,
    y: Unit,
};

pub const Box = enum {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
    SideHzn,
    SideVtl,

    pub fn render(self: Box) Unicode {
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
