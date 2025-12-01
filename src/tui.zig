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

    pub fn drawPoint(self: *const Canvas, r: Unit, c: Unit, char: ?Unicode) !void {
        if (r >= self.height or c >= self.width) return error.ScreenLimitExceeded;
        fmt.printf("\x1b[{d};{d}H{u}", .{ r, c, char orelse '*' });
    }

    pub fn drawCorner(self: *const Canvas, p: Point, c: Box) !void {
        try self.drawPoint(p.y, p.x, c.render());
    }

    pub fn drawLineHzn(self: *const Canvas, origin: Point, length: Unit) !void {
        for (origin.x..(origin.x + length)) |idx| {
            try self.drawPoint(origin.y, idx, Box.SideHzn.render());
        }
    }

    pub fn drawLineVtl(self: *const Canvas, origin: Point, length: Unit) !void {
        for (origin.y..(origin.y + length)) |idx| {
            try self.drawPoint(idx, origin.x, Box.SideVtl.render());
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

    pub fn drawSquare(self: *const Canvas, origin: Point, length: Unit, breadth: Unit) !void {
        // Terminal characters are typically twice as tall as they are wide (roughly 8x16 pixels, or similar ratio).
        try self.drawRect(origin, length, breadth * 2);
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
