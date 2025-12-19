const std = @import("std");
const tui = @import("tuilip");

const SIZE = 1024 * 4;

pub fn main() !void {
    var buffer_writer: [SIZE]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&buffer_writer);

    var buffer_reader: [SIZE]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&buffer_reader);

    var fmt: tui.Fmt = .{
        .writer = &writer.interface,
        .reader = &reader.interface,
        .handle = reader.file.handle,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var cv: tui.Canvas = .init(&fmt, allocator, 5);
    defer cv.deinit(allocator);

    const os = try cv.enableRaw();
    defer cv.disableRaw(os);

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    const pos_row: tui.types.Unit = 2;
    var pos_col: tui.types.Unit = 1;

    while (true) {
        var box: tui.types.Box = .{ .height = 10, .width = 15, .origin = .{ .col = pos_col, .row = pos_row } };
        try box.insert(allocator, .{ .text = "click here" }, .{ .top = 50, .left = 50 });

        defer box.child.deinit(allocator);
        cv.onScreen(box, .draw) catch break;
        cv.render();

        std.Thread.sleep(std.time.ns_per_ms * 10);
        try cv.onScreen(box, .erase);
        pos_col += 1;
    }
}
