const std = @import("std");
const io = @import("io.zig");
const p = @import("position.zig");

const Terminal = @This();

handle: std.fs.File.Handle,
size: p.Size = undefined,
original_state: std.posix.termios = undefined,

// ===================

pub fn init(hn: std.fs.File.Handle) !Terminal {
    var term: Terminal = .{ .handle = hn };

    try term.setSize();
    try term.rawYes();
    return term;
}

pub fn setSize(self: *Terminal) std.posix.UnexpectedError!void {
    var size: std.posix.winsize = undefined;

    const hn = self.handle;
    const cmd = std.posix.T.IOCGWINSZ;
    const ptr = @intFromPtr(&size);
    const return_code = std.posix.system.ioctl(hn, cmd, ptr);

    self.size = .{ .ux = size.col, .uy = size.row };

    if (return_code != 0) return std.posix.unexpectedErrno(std.posix.errno(return_code));
}

pub fn rawYes(self: *Terminal) !void {
    self.original_state = try std.posix.tcgetattr(self.handle);
    var raw = self.original_state;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    try std.posix.tcsetattr(self.handle, .FLUSH, raw);

    io.screen_clear();
    io.mouse_hide();
    io.flush();
}

pub fn rawNo(self: *const Terminal) void {
    io.mouse_show();
    io.screen_clear();
    io.flush();

    std.posix.tcsetattr(self.handle, .FLUSH, self.original_state) catch {
        std.log.err("Failed to disable the raw mode.", .{});
        std.process.exit(1);
    };
}
