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
    front_buf: []u8,
    /// Back buffer (where new frame is drawn).
    back_buf: []u8,
    /// Tracking changes between frames
    changes: std.ArrayList(usize) = .empty,

    /// Returns an instance of canvas that allows operations on it.
    pub fn init(allocator: std.mem.Allocator, hn: std.fs.File.Handle) !Canvas {
        var term_size: std.posix.winsize = undefined;
        const ret = std.posix.system.ioctl(hn, std.posix.T.IOCGWINSZ, @intFromPtr(&term_size));
        if (ret != 0) return std.posix.unexpectedErrno(std.posix.errno(ret));

        const size = term_size.row * term_size.col * @sizeOf(u8);

        const front_buf = try allocator.alloc(u8, size);
        const back_buf = try allocator.alloc(u8, size);

        @memset(front_buf, ' ');
        @memset(back_buf, ' ');

        return .{
            .allocator = allocator,
            .height = term_size.row,
            .width = term_size.col,
            .front_buf = front_buf,
            .back_buf = back_buf,
        };
    }

    pub fn deinit(self: *Canvas) void {
        self.changes.deinit(self.allocator);
        self.allocator.free(self.front_buf);
        self.allocator.free(self.back_buf);
    }

    pub fn drawPixel(self: *Canvas, row: usize, col: usize, char: u8) !void {
        const index = row * self.width + col;
        self.back_buf[index] = char;
        try self.changes.append(self.allocator, index);
    }

    pub fn render(self: *Canvas) void {
        for (self.changes.items) |x| {
            if (self.front_buf[x] != self.back_buf[x]) {
                self.front_buf[x] = self.back_buf[x];
                const row = x / self.width;
                const col = x % self.width;
                fmt.printf("\x1b[{d};{d}H{c}", .{ row, col, self.front_buf[x] });
            }
        }
        fmt.flush();
        self.changes.clearRetainingCapacity();
    }
};
