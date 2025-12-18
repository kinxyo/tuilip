const std = @import("std");

const tui = @import("tuilip");
const fmt = tui.fmt;
const Canvas = tui.Canvas;

pub fn main() !void {
    // SETUP ------------
    var buffer_alloc: [1024 * 70]u8 = undefined;
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

    const os = try cv.enableRaw();
    defer cv.disableRaw(os);

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    // RENDER LOOP ------------
    try renderLoop(&cv);
}
fn renderLoop(cv: *Canvas) !void {
    var pos_col: tui.types.Unit = 1;

    while (true) {
        try cv.div(.{ .row = 1, .col = pos_col }, 5, 10);
        cv.render();

        const key = try cv.fmt.reader.takeByte();
        if (key == 'q') break;
        if (key == 'e') pos_col += 1;
    }
}
