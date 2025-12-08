const std = @import("std");
const f = @import("fmt.zig");
const t = @import("types.zig");

// Represents the main canvas responsible for all drawing operations.
// The measurement is in grid row/col.
pub const Canvas = struct {
    height: t.Unit,
    width: t.Unit,
    fmt: *f.Fmt,
    margin: t.Unit = 2,

    /// Returns an instance of canvas that allows operations on it.
    pub fn init(fmt: *f.Fmt) !Canvas {
        var term_size: std.posix.winsize = undefined;
        const ret = std.posix.system.ioctl(fmt.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&term_size));
        if (ret != 0) return std.posix.unexpectedErrno(std.posix.errno(ret));

        return .{
            .height = term_size.row,
            .width = term_size.col,
            .fmt = fmt,
        };
    }

    // ======== Drawing ========

    /// Draw pixel on canvas at `x` (col) and `y` (row).
    pub fn drawPoint(self: *const Canvas, x: t.Unit, y: t.Unit, char: ?t.Unicode) !void {
        if (x >= self.width or y >= self.height) return error.ScreenLimitExceeded;
        self.fmt.printf("\x1b[{d};{d}H{u}", .{ y, x, char orelse '*' });
    }

    /// Clear pixel on canvas at `x` (col) and `y` (row).
    pub fn clearPoint(self: *const Canvas, x: t.Unit, y: t.Unit) !void {
        try self.drawPoint(x, y, ' ');
    }

    // ======== Config ========

    /// Disables (currently: ECHO, ICANON) flags for terminal,
    /// returns original instance for restoring original state at the end of program.
    pub fn enableRaw(self: *const Canvas) !std.posix.termios {
        const original = try std.posix.tcgetattr(self.fmt.handle);

        var raw = original;
        raw.lflag.ECHO = false;
        raw.lflag.ICANON = false;

        try std.posix.tcsetattr(self.fmt.handle, .FLUSH, raw);
        return original;
    }

    pub fn disableRaw(self: *const Canvas, original: std.posix.termios) void {
        std.posix.tcsetattr(self.fmt.handle, .FLUSH, original) catch {};
    }
};
