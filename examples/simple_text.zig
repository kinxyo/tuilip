const std = @import("std");
const Init = std.process.Init;
const tui = @import("tuilip");
const Canvas = tui.Canvas;
const Text = tui.Text;

pub fn main(init: Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    var cv: Canvas = try .init(io, allocator);
    defer cv.deinit();

    _ = try cv.renderAlign(Text.new("work"), .top, .left);
    _ = try cv.renderAlign(Text.new("in"), .center, .center);
    _ = try cv.renderAlign(Text.new("progress..."), .bottom, .right);
    cv.present();

    try io.sleep(.fromSeconds(5), .awake);
}
