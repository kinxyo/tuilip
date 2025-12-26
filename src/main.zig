const std = @import("std");
const tui = @import("tuilip");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: tui.Canvas = .init(allocator, 0);
    defer cv.deinit();

    try cv.createBox("world", 10, 10, .center, .center);

    var world = try cv.children.getBox("world");
    try world.insertBox(
        "char",
        .{ .height = 5, .width = 5 },
        .{ .col = 1, .row = 1 },
    );

    try cv.onScreen(world, .draw);
    cv.render();

    while (cv.poll()) |event| {
        if (event == 'q') break;
        const pos = cv.getCenter();
        try cv.draw(pos.col - 1, pos.row - 1, event);
        cv.render();
    }
}
