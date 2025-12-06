const std = @import("std");
const tui = @import("tuilip");

const fmt = tui.fmt;
const animations = tui.animations;
const Canvas = tui.Canvas;

pub fn main() !void {
    var buf_w: [4 * 1024]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&buf_w);
    const stdout: *std.Io.Writer = &writer.interface;

    var buf_r: [4 * 1024]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&buf_r);
    const stdin: *std.Io.Reader = &reader.interface;

    var app_fmt: tui.Fmt = .{
        .writer = stdout,
        .reader = stdin,
        .handle = reader.file.handle,
    };

    var cv = Canvas.init(&app_fmt) catch |err| {
        std.log.err("Failed to initialize canvas: {s}\n", .{@errorName(err)});
        return;
    };

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    for (0..5) |_| {
        try animations.slidingX(&cv, 1, 5, cv.width, 2, "===", 31);
        try animations.slidingY(&cv, 5, 1, cv.height, 2, "|||", 34);
    }

    cv.fmt.clear();
}
