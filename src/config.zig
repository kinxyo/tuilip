const std = @import("std");
// ========== Config ==========

var original: std.posix.termios = undefined;

fn getSize(handle: std.fs.File.Handle) !std.posix.winsize {
    var s: std.posix.winsize = undefined;
    const result = std.posix.system.ioctl(handle, std.posix.T.IOCGWINSZ, @intFromPtr(&s));
    if (result != 0) return error.IoctlFailed else return s;
}

pub fn enableRaw(handle: std.fs.File.Handle) !void {
    original = try std.posix.tcgetattr(handle);

    var raw = original;
    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;

    try std.posix.tcsetattr(handle, .FLUSH, raw);
}

pub fn disableRaw(handle: std.fs.File.Handle) void {
    std.posix.tcsetattr(handle, .FLUSH, original) catch {};
}
