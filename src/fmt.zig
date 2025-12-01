const std = @import("std");

const SIZE = 1024 * 10; // 10KB

var buf_r: [SIZE]u8 = undefined;
var buf_w: [SIZE]u8 = undefined;

var reader = std.fs.File.stdin().reader(&buf_r);
var writer = std.fs.File.stdout().writer(&buf_w);

var stdin: *std.Io.Reader = &reader.interface;
var stdout: *std.Io.Writer = &writer.interface;

pub fn getHandle() std.fs.File.Handle {
    return reader.file.handle;
}

pub fn clear() void {
    stdout.writeAll("\x1b[2J\x1b[H") catch unreachable;
}

pub fn getStdIn() *std.Io.Reader {
    return stdin;
}

pub fn getStdOut() *std.Io.Writer {
    return stdout;
}

pub fn flush() void {
    stdout.flush() catch unreachable;
}

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    stdout.print(fmt, args) catch unreachable;
}

pub fn print(bytes: []const u8) void {
    stdout.writeAll(bytes) catch unreachable;
}
