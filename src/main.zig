const std = @import("std");
const fmt = @import("fmt.zig");
const tui = @import("tui.zig");

pub fn main() !void {
    const hn = fmt.getHandle();

    const cv: tui.Canvas = .init(hn);
    if (cv.width == 0) {
        std.log.err("\x1b[31mFailed to retrieve terminal size.\x1b[0m", .{});
        return;
    }

    fmt.print("\x1b[2J\x1b[H");

    fmt.printf("{d}:{d}", .{ cv.height, cv.width });

    try cv.drawPoint(cv.height - 1, cv.width - 1, null);

    fmt.print("\n");
    fmt.flush();
}
