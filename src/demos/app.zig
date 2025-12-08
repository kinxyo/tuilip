const std = @import("std");
const tui = @import("tuilip");
const fmt = tui.fmt;
const Canvas = tui.Canvas;
const shapes = tui.shapes;
const Layout = tui.layout;

pub fn main() !void {
    var buffer_main: [1024 * 10]u8 = undefined;
    var fba: std.heap.FixedBufferAllocator = .init(&buffer_main);
    const allocator = fba.allocator();

    var buf_w: [4 * 1024]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&buf_w);
    const stdout: *std.Io.Writer = &writer.interface;

    var buf_r: [4 * 1024]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&buf_r);
    const stdin: *std.Io.Reader = &reader.interface;

    var app_fmt: tui.Fmt = .{
        .writer = stdout,
        .reader = stdin,
        .handle = reader.file.handle,
    };

    const cv = Canvas.init(&app_fmt) catch |err| {
        std.log.err("Failed to initialize canvas: {s}\n", .{@errorName(err)});
        return;
    };

    const original_state = try cv.enableRaw();
    defer cv.disableRaw(original_state);

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();
    defer cv.fmt.clear();

    try renderLoop(&cv, allocator);
}

fn renderLoop(cv: *const Canvas, allocator: std.mem.Allocator) !void {
    var l: Layout = .{ .cv = cv, .allocator = allocator };

    try l.drawBox(.{ .height = 5, .width = 4, .fill = false, .direction = .RIGHT });

    try l.render();
}
