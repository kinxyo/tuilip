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

    // define
    const pixel: tui.Cell = .{ .char = '*', .fg = .red };
    var pos: tui.P.Delta = .{ .col = 20, .row = 10 };

    const str: tui.Text = .{ .value = "Press any key to start and `q` to exit." };
    try cv.render(str, cv.getCenterOffsetX(-str.lenHalf()), .draw);

    cv.flush();
    if (cv.pollOnly() == 'q') return;
    try cv.render(str, cv.getCenterOffsetX(-str.lenHalf()), .erase);

    // render loop
    while (cv.poll()) |event| {
        try cv.renderFit(pixel, pos, .erase);
        switch (event) {
            'q' => break,
            'w' => pos.row -= 1,
            'a' => pos.col -= 1,
            's' => pos.row += 1,
            'd' => pos.col += 1,
            else => {},
        }
        try cv.renderFit(pixel, pos, .draw);
    }
}
