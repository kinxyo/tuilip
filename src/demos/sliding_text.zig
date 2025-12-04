const std = @import("std");
const tui = @import("tuilip");

const fmt = tui.fmt;
const config = tui.config;
const Canvas = tui.Canvas;
const Shapes = tui.Shapes;

/// This is for testing the library apis work to produce intended TUI,
/// and also help as an example for how to do things.
pub fn main() !void {
    var buffer: [1024 * 10]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&buffer);
    const allocator = fba.allocator();

    const hn = fmt.getHandle();

    var cv: Canvas = try .init(allocator, hn);
    defer cv.deinit();

    fmt.cursor_hide();
    defer fmt.cursor_show();

    try config.enableRaw(hn);
    defer config.disableRaw(hn);

    try renderLoop(cv);
}

fn renderLoop(cv: Canvas) !void {
    // var stdin = fmt.getStdIn();

    var x: usize = 1;
    const y: usize = cv.height / 2;

    var iter: usize = 0;

    var argIter = std.process.args();
    defer argIter.deinit();
    _ = argIter.skip();

    const TEXT = argIter.next() orelse "-->";

    const sh: Shapes = .{ .cv = &cv };

    while (true) {
        fmt.print("\x1b[34m");
        try sh.drawTextFrom(.{ .x = x, .y = y }, TEXT);
        fmt.print("\x1b[0m");

        fmt.flush();

        std.Thread.sleep(20 * std.time.ns_per_ms);

        try sh.clearTextFrom(.{ .x = x, .y = y }, TEXT);
        x += 1;

        if (x + TEXT.len >= sh.cv.width) {
            iter += 1;
            x = 1;
        }
    }
}
