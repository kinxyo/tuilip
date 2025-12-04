const std = @import("std");

const SIZE = 1024 * 4; // 10KB

var buf_r: [SIZE]u8 = undefined;
var buf_w: [SIZE]u8 = undefined;
var buf_e: [1024]u8 = undefined;

var reader = std.fs.File.stdin().reader(&buf_r);
var writer = std.fs.File.stdout().writer(&buf_w);
var err_writer = std.fs.File.stderr().writer(&buf_e);

var stdin: *std.Io.Reader = &reader.interface;
var stdout: *std.Io.Writer = &writer.interface;
var stderr: *std.Io.Writer = &err_writer.interface;

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

pub fn cursor_hide() void {
    print("\x1b[2J\x1b[H"); // clear screen and reset cursor pos
    print("\x1b[?25l"); // hide the cursor
}

pub fn cursor_show() void {
    print("\x1b[?25h");
    print("\x1b[2J\x1b[H");
    flush();
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    stderr.writeAll("\x1b[31m") catch {};
    stderr.print(fmt, args) catch {};
    stderr.writeAll("\x1b[0m") catch {};
    stderr.flush() catch {};
    std.process.exit(1);
}
