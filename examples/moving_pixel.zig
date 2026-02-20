const std = @import("std");
const tui = @import("tuilip");

pub fn main() !void {
    // init
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: tui.Canvas = try .init(allocator);
    defer cv.deinit();

    // define
    const pixel: tui.Cell = .{ .char = '*', .fg = .red };
    var pos: tui.P.OffsetGroup = .{ .col = 20, .row = 10 };

    // pre-draw loop
    try cv.renderFit(pixel, pos, .draw);

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
