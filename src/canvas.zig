const std = @import("std");
const fmt = @import("fmt.zig");
const t = @import("types.zig");

/// Represents a drawable canvas with double buffering.
pub const Canvas = struct {
    allocator: std.mem.Allocator,
    /// No. of rows in the terminal screen.
    height: t.Unit,
    /// No. of cols in the terminal screen.
    width: t.Unit,
    /// Front buffer (what's currently on screen).
    fb: []u8,
    /// Back buffer (where new frame is drawn).
    bb: []u8,

    /// Returns an instance of canvas that allows operations on it.
    pub fn init(allocator: std.mem.Allocator, hn: std.fs.File.Handle) !Canvas {
        var term_size: std.posix.winsize = undefined;
        const res = std.posix.system.ioctl(hn, std.posix.T.IOCGWINSZ, @intFromPtr(&term_size));
        // TODO: how do i return descriptive errors here since i don't know all error codes being returned?
        if (res != 0) return error.CanvasInitFailed;

        const size = term_size.row * term_size.col;

        const front_buf = try allocator.alloc(u8, size);
        const back_buf = try allocator.alloc(u8, size);

        return .{
            .allocator = allocator,
            .height = term_size.row,
            .width = term_size.col,
            .fb = front_buf,
            .bb = back_buf,
        };
    }

    pub fn deinit(self: *Canvas) void {
        self.allocator.free(self.fb);
        self.allocator.free(self.bb);
    }

    pub fn drawPoint(self: *const Canvas, x: t.Unit, y: t.Unit, char: ?t.Unicode) !void {
        if (x >= self.width or y >= self.height) return error.ScreenLimitExceeded;
        fmt.printf("\x1b[{d};{d}H{u}", .{ y, x, char orelse '*' });
    }

    pub fn clearPoint(self: *const Canvas, x: t.Unit, y: t.Unit) !void {
        if (x >= self.width or y >= self.height) return error.ScreenLimitExceeded;
        fmt.printf("\x1b[{d};{d}H{u}", .{ y, x, ' ' });
    }
};
