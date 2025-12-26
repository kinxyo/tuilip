const std = @import("std");
const t = @import("types.zig");

// TOB:
// 1. PRIMITVES
// 2. WRAPPER

var buf_r: [1024 * 4]u8 = undefined; // 4kb (input)
var buf_w: [1024 * 4]u8 = undefined; // 4kb (output)

var reader = std.fs.File.stdin().reader(&buf_r);
var writer = std.fs.File.stdout().writer(&buf_w);
var stdin: *std.Io.Reader = &reader.interface;
const stdout: *std.Io.Writer = &writer.interface;

// === PRIMITIVES ===

/// Returns handle of current terminal
pub fn getHandle() std.fs.File.Handle {
    return reader.file.handle;
}

/// Returns handle of current terminal
pub fn inputString() !?[]u8 {
    return try stdin.takeDelimiter('\n');
}

/// Returns handle of current terminal
pub fn inputChar() !u8 {
    return try stdin.takeByte();
}

/// Drains all remaining buffered data to stdout.
pub fn flush() void {
    stdout.flush() catch {};
}

/// writer to buffer with format
pub fn printf(comptime fmt: []const u8, args: anytype) void {
    stdout.print(fmt, args) catch {};
}

/// writer to buffer directly
pub fn print(bytes: []const u8) void {
    stdout.writeAll(bytes) catch {};
}

// === WRAPPERS ===

/// hide the cursor
pub fn cursor_hide() void {
    print("\x1b[?25l");
}

/// show the cursor
pub fn cursor_show() void {
    print("\x1b[?25h");
    flush();
}

/// clear screen and reset cursor pos
pub fn clear_screen() void {
    print("\x1b[2J\x1b[H");
}

/// Draw directly on canvas by passing buffers and other configurations.
pub fn directDraw(x: usize, y: usize, char: t.Unicode) void {
    printf("\x1b[{d};{d}H{u}", .{ y + 1, x + 1, char });
}

/// Set color for terminal output.
/// Follow it up by `resetCode()`.
pub fn setColor(bg: t.colors.BackgroundColor, fg: t.colors.ForegroundColor) void {
    if (bg.isSet()) printf("\x1b[{d};{d}m", .{ fg, bg }) else printf("\x1b[{d}m", .{fg});
}

/// Removes applied styles and code on terminal output.
pub fn resetCode() void {
    print("\x1b[0m");
}
