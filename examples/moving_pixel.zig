const std = @import("std");
const Init = std.process.Init;
const tui = @import("tuilip");

pub fn main(init: Init) !void {
    // init
    const io = init.io;
    const allocator = init.gpa;

    var cv: tui.Canvas = try .init(io, allocator);
    defer cv.deinit();

    // define
    const pixel: tui.Cell = .{ .char = '*', .fg = .red };
    var pos: tui.T.OffsetGroup = .{ .col = 20, .row = 10 };

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
            'k' => pos.row -= 1,
            'h' => pos.col -= 1,
            'j' => pos.row += 1,
            'l' => pos.col += 1,
            else => {},
        }
        try cv.renderFit(pixel, pos, .draw);
    }
}
