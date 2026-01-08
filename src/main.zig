const std = @import("std");
const tui = @import("tuilip");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: tui.Canvas = .init(allocator, 0);
    defer cv.deinit();

    try cv.createBox("world", 10, 10, .center, .center);

    var world = try cv.getBox("world");
    try world.insertBox("char", 5, 5, .center, .center);

    try cv.onScreen(world, .draw);
    cv.render();

    while (cv.poll()) |event| {
        if (event == 'q') break;
        const pos = cv.getCenter(1); // offset
        try cv.draw(pos.col, pos.row, event);
        cv.render();
    }
}
