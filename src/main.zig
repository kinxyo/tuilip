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

    // configs
    cv.drawCS(20, 10);

    // render loop
    while (cv.poll()) |event| {
        if (event == 'q') break;
    }
}
