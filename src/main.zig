const std = @import("std");
const fmt = @import("fmt.zig");
const draw = @import("draw.zig");
const config = @import("config.zig");

pub fn main() !void {
    var stdin = fmt.getStdIn();
    const hn = fmt.getHandle();

    const cv: draw.Canvas = .init(hn);
    if (cv.width == 0) {
        std.log.err("\x1b[31mFailed to retrieve terminal size.\x1b[0m", .{});
        return;
    }

    fmt.print("\x1b[?25l");
    defer {
        fmt.print("\x1b[?25h");
        fmt.print("\x1b[2J\x1b[H");
        fmt.flush();
    }

    try config.enableRaw(hn);
    defer config.disableRaw(hn);

    while (true) {
        fmt.print("\x1b[2J\x1b[H");
        fmt.flush();

        // render
        try cv.drawSquare(.{ .x = 1, .y = 1 }, 2);
        fmt.flush();

        // poll events
        const key = try stdin.takeByte();
        if (key == 'q') break;
    }
}
