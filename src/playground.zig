//! Sketch/play/test APIs

const std = @import("std");
const tui = @import("tuilip");
const Canvas = tui.Canvas;
const Text = tui.Text;

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: Canvas = try .init(allocator);
    defer cv.deinit();

    const box: tui.Box = .new(10, 15);
    // cv.render(box, box.size.origin, .draw);
    cv.renderAlign(box, .center, .center);

    cv.present();
}
