const std = @import("std");
const tui = @import("tuilip");

const fmt = tui.fmt;
const config = tui.config;
const Canvas = tui.Canvas;
const shapes = tui.shapes;

/// This is for testing the library apis work to produce intended TUI,
/// and also help as an example for how to do things.
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

    var cv: Canvas = try .init(&app_fmt);

    const os = try cv.enableRaw();
    defer cv.disableRaw(os);

    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    try renderLoop(&cv);
}

fn renderLoop(cv: *const Canvas) !void {
    // var stdin = fmt.getStdIn();

    var x: tui.types.Unit = 1;
    const y: tui.types.Unit = cv.height / 2;

    var iter: usize = 0;

    var argIter = std.process.args();
    defer argIter.deinit();
    _ = argIter.skip();

    const TEXT = argIter.next() orelse "-->";

    while (true) {
        cv.fmt.print("\x1b[34m");
        try shapes.drawTextFrom(cv, .{ .x = x, .y = y }, TEXT);
        cv.fmt.print("\x1b[0m");

        cv.fmt.flush();

        std.Thread.sleep(20 * std.time.ns_per_ms);

        try shapes.clearTextFrom(cv, .{ .x = x, .y = y }, TEXT);
        x += 1;

        if (x + TEXT.len >= cv.width) {
            iter += 1;
            x = 1;
        }
    }
}
