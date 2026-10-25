//! Sketch/play/test APIs

const std = @import("std");
const tui = @import("tuilip");
const Canvas = tui.Canvas;
const Text = tui.Text;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    var cv: Canvas = try .init(io, allocator);
    defer cv.deinit();

    // const d: tui.Box = .new(50, 10);
    const d: tui.Cell = .{ .char = 'u' };
    // const d: tui.Text = .new("welcome.");
    try cv.renderAlign(d, .center, .center);

    cv.present();

    cv.pause(2);
}
