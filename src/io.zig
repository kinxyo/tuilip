const std = @import("std");

var buf_w: [4096]u8 = undefined;
var stdout = std.fs.File.stdout().writer(&buf_w);
const writer = &stdout.interface;

var buf_r: [4096]u8 = undefined;
var stdin = std.fs.File.stdin().reader(&buf_r);
var reader = &stdin.interface;

pub fn getHandle() std.fs.File.Handle {
    return stdin.file.handle;
}

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

// -----------

pub fn screen_clear() void {
    print("\x1b[2J\x1b[H");
}

pub fn mouse_hide() void {
    print("\x1b[?25l");
}

pub fn mouse_show() void {
    print("\x1b[?25h");
}
