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

    _ = try cv.renderAlign(Text.new("work"), .top, .left);
    _ = try cv.renderAlign(Text.new("in"), .center, .center);
    _ = try cv.renderAlign(Text.new("progress..."), .bottom, .right);
    cv.present();

    std.Thread.sleep(std.time.ns_per_s * 5);
}
