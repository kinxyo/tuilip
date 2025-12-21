const std = @import("std");

pub const Fmt = struct {
    handle: std.fs.File.Handle,
    reader: *std.Io.Reader,
    writer: *std.Io.Writer,

    /// Drains all remaining buffered data to stdout.
    pub fn flush(self: *Fmt) void {
        self.writer.flush() catch {};
    }

    /// writer to buffer with format
    pub fn printf(self: *Fmt, comptime fmt: []const u8, args: anytype) void {
        self.writer.print(fmt, args) catch {};
    }

    /// writer to buffer directly
    pub fn print(self: *Fmt, bytes: []const u8) void {
        self.writer.writeAll(bytes) catch {};
    }

    /// hide the cursor
    pub fn cursor_hide(self: *Fmt) void {
        self.print("\x1b[?25l");
    }

    /// show the cursor
    pub fn cursor_show(self: *Fmt) void {
        self.print("\x1b[?25h");
        self.flush();
    }

    /// clear screen and reset cursor pos
    pub fn clear_screen(self: *Fmt) void {
        self.print("\x1b[2J\x1b[H");
    }
};
