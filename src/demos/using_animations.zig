const std = @import("std");
const tui = @import("tuilip");

const fmt = tui.fmt;
const animations = tui.animations;
const Canvas = tui.Canvas;

pub fn main() !void {
    var buffer_alloc: [1024 * 60]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&buffer_alloc);
    const allocator = fba.allocator();

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

    var cv: Canvas = .init(&app_fmt, allocator, 0);
    defer cv.deinit(allocator);

    const original_state = try cv.enableRaw();
    defer cv.disableRaw(original_state);

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    for (0..5) |_| {
        try animations.slidingX(&cv, 1, 5, cv.getCol(), 2, "===", 31);
        try animations.slidingY(&cv, 5, 1, cv.getRow(), 2, "|||", 34);
    }

    cv.fmt.clear();
}
