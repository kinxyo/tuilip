const std = @import("std");
const tui = @import("tuilip");

const fmt = tui.fmt;
const config = tui.config;
const Canvas = tui.Canvas;
const shapes = tui.shapes;

/// This is for testing the library apis work to produce intended TUI,
/// and also help as an example for how to do things.
pub fn main() !void {
    const hn = fmt.getHandle();

    const cv: Canvas = try .init(hn);

    fmt.cursor_hide();
    defer fmt.cursor_show();

    try config.enableRaw(hn);
    defer config.disableRaw(hn);

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
        fmt.print("\x1b[34m");
        try shapes.drawTextFrom(cv, .{ .x = x, .y = y }, TEXT);
        fmt.print("\x1b[0m");

        fmt.flush();

        std.Thread.sleep(20 * std.time.ns_per_ms);

        try shapes.clearTextFrom(cv, .{ .x = x, .y = y }, TEXT);
        x += 1;

        if (x + TEXT.len >= cv.width) {
            iter += 1;
            x = 1;
        }
    }
}
