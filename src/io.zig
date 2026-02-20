//! Terminal I/O micro library
const std = @import("std");
const Size = @import("position.zig").Size;
const Err = std.posix.UnexpectedError;

var buf_w: [4096]u8 = undefined;
var stdout = std.fs.File.stdout().writer(&buf_w);
const writer = &stdout.interface;

var buf_r: [4096]u8 = undefined;
var stdin = std.fs.File.stdin().reader(&buf_r);
var reader = &stdin.interface;

var original_state: std.posix.termios = undefined;

// ---- I/O -------

pub fn getReader() *std.Io.Reader {
    return reader;
}

pub fn getWriter() *std.Io.Writer {
    return writer;
}

pub fn print(bytes: []const u8) void {
    writer.writeAll(bytes) catch {};
}

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    writer.print(fmt, args) catch {};
}

pub fn flush() void {
    writer.flush() catch {};
}

pub fn inputChar() !u8 {
    return reader.takeByte();
}

// ---- Wrappers/Helpers -------

pub fn screen_clear() void {
    print("\x1b[2J\x1b[H");
}

pub fn mouse_hide() void {
    print("\x1b[?25l");
}

pub fn mouse_show() void {
    print("\x1b[?25h");
}

// ---- Colors -------

pub const Bg = enum(u8) {
    default = 39,
};

pub const Fg = enum(u8) {
    red = 31,
    default = 39,
};

// ---- Config -------

inline fn handle() std.fs.File.Handle {
    return stdin.file.handle;
}

pub fn getSize() Err!Size {
    var size: std.posix.winsize = undefined;

    const ret = std.posix.system.ioctl(
        handle(),
        std.posix.T.IOCGWINSZ,
        @intFromPtr(&size),
    );

    if (ret != 0) return std.posix.unexpectedErrno(std.posix.errno(ret));
    return .{ .cols = size.col, .rows = size.row };
}

pub fn rawEnable() !void {
    original_state = try std.posix.tcgetattr(handle());
    var raw = original_state;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.cc[@intFromEnum(std.posix.V.MIN)] = 1; // Non-blocking
    raw.cc[@intFromEnum(std.posix.V.TIME)] = 0; // Non-blocking
    try std.posix.tcsetattr(handle(), .FLUSH, raw);

    screen_clear();
    mouse_hide();
    flush();
}

pub fn rawDisable() void {
    mouse_show();
    screen_clear();
    flush();

    std.posix.tcsetattr(handle(), .FLUSH, original_state) catch {
        std.log.err("Failed to disable the terminal raw mode.", .{});
        std.process.exit(1);
    };
}
