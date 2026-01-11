const std = @import("std");
const tui = @import("tuilip");

// TODO: better drawing and position.

pub fn main() !void {
    // init
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var c: tui.Canvas = try .init(allocator);
    defer c.deinit();

    // configs
    std.debug.print("{d}\n", .{c.T.getCol()});
    std.debug.print("{d}\n", .{c.T.getRow()});

    // render loop
    std.Thread.sleep(std.time.ns_per_s * 3);
}
