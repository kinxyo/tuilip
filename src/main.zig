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

    // define
    const pixel: tui.Cell = .{ .char = '*' };

    // initial render (before polling for input).
    try cv.renderBounded(pixel, pos_x, pos_y, .draw);

    // render loop
    while (cv.poll()) |event| {
        try cv.renderBounded(pixel, pos_x, pos_y, .erase);
        switch (event) {
            'q' => break,
            'w' => pos_y -= 1,
            'a' => pos_x -= 1,
            's' => pos_y += 1,
            'd' => pos_x += 1,
            else => {},
        }
        try cv.renderBounded(pixel, pos_x, pos_y, .draw);
    }
}
