const std = @import("std");

const tui = @import("tuilip");
const fmt = tui.fmt;
const Canvas = tui.Canvas;

pub fn main() !void {
    // SETUP ------------
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

    const os = try cv.enableRaw();
    defer cv.disableRaw(os);

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    // RENDER LOOP ------------
    var bg: tui.types.BG = .red;
    var fg: tui.types.FG = .red;

    var iter: i32 = 0;
    while (iter < 5) : (iter += 1) {
        switch (iter) {
            else => {
                bg = .red;
                fg = .red;
            },
            1 => {
                bg = .yellow;
                fg = .yellow;
            },
            2 => {
                bg = .bright_blue;
                fg = .bright_blue;
            },
            3 => {
                bg = .green;
                fg = .green;
            },
            4 => {
                bg = .bright_red;
                fg = .bright_red;
                iter = -1;
            },
        }

        for (cv.margin..cv.getCol()) |x| {
            for (cv.margin..cv.getRow()) |y| {
                try cv.drawC(x, y, .{ .char = ' ', .bg = bg, .fg = fg });
            }

            cv.render();
            std.Thread.sleep(std.time.ns_per_ms * 15);
        }
    }
}
