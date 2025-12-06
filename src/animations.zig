const std = @import("std");
const t = @import("types.zig");
const Canvas = @import("canvas.zig").Canvas;
const shapes = @import("shapes.zig");

/// Horizontal transition of string on canvas.
/// Example: `try animations.slidingX(&cv, 1, 5, cv.width, 2, "===", 31);`
pub fn slidingX(cv: *const Canvas, x: t.Unit, y: t.Unit, limit: t.Unit, speed: usize, str: []const u8, color: ?usize) !void {
    var pos: t.Unit = x;

    while (pos < limit) {
        // drawing (for next frame)
        if (color) |c| cv.fmt.printf("\x1b[{d}m", .{c});
        try shapes.drawTextFrom(cv, .{ .x = pos, .y = y }, str);
        if (color) |_| cv.fmt.printf("\x1b[0m", .{});

        // render
        cv.fmt.flush();

        // post-render drawing
        try shapes.clearTextFrom(cv, .{ .x = pos, .y = y }, str);

        std.Thread.sleep(std.time.ns_per_ms * 10 * (speed / 2));
        pos += 1;

        if (pos + str.len > limit) return;
    }
}

/// Vertical transition of string on canvas.
/// Example: `try animations.slidingY(&cv, 5, 1, cv.height, 2, "|||", 34);`
pub fn slidingY(cv: *const Canvas, x: t.Unit, y: t.Unit, limit: t.Unit, speed: usize, str: []const u8, color: ?usize) !void {
    var pos: t.Unit = y;

    while (pos < limit) {
        // drawing (for next frame)
        if (color) |c| cv.fmt.printf("\x1b[{d}m", .{c});
        try shapes.drawTextFrom(cv, .{ .x = x, .y = pos }, str);
        if (color) |_| cv.fmt.printf("\x1b[0m", .{});

        // render
        cv.fmt.flush();

        // post-render drawing
        try shapes.clearTextFrom(cv, .{ .x = x, .y = pos }, str);

        std.Thread.sleep(std.time.ns_per_ms * 10 * speed);
        pos += 1;
    }
}
