const std = @import("std");
const tui = @import("tuilip");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: tui.Canvas = .init(allocator, 0);
    defer cv.deinit();

    // TODO: Use `cv.children.addBox()` instead.
    try cv.createBox("world", 10, 10, .center, .center); // TODO: use this function for insertBox too.

    var world = try cv.children.getBox("world");
    // TODO: reduce the size -- use direct params honestly, but also offer a clubbed struct (size x pos) instead of separate structs for them.
    try world.insertBox(
        "char",
        .{ .height = 5, .width = 5 },
        .{ .col = 1, .row = 1 },
    );

    try cv.onScreen(world, .draw);
    cv.render();

    while (cv.poll()) |event| {
        if (event == 'q') break;
        const pos = cv.getCenter(1); // offset
        try cv.draw(pos.col, pos.row, event);
        cv.render();
    }
}
