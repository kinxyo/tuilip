const std = @import("std");
const tui = @import("tuilip");

// TODO: better drawing and position.

pub fn main() !void {
    // init
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: tui.Canvas = try .init(allocator);
    defer cv.deinit();

    var pos_x: i32 = 20;
    var pos_y: i32 = 10;

    // configs
    cv.drawBounded(pos_x, pos_y, '*');

    // render loop
    while (cv.poll()) |event| {
        cv.clearBounded(pos_x, pos_y);
        switch (event) {
            'q' => break,
            'd' => pos_x += 1,
            'a' => pos_x -= 1,
            'w' => pos_y -= 1,
            's' => pos_y += 1,
            else => {},
        }
        // TODO: can create a redraw function that clears the previous stuff that draws the new function automatically, possible take function function as input;
        cv.drawBounded(pos_x, pos_y, '*');
    }
}
