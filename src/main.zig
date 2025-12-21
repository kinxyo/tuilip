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

    var cv: tui.Canvas = .init(&fmt, allocator, 0);
    defer cv.deinit(allocator);

    const os = try cv.enableRaw();
    defer cv.disableRaw(os);

    cv.fmt.clear();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();

    // cv.log();

    while (true) {
        const box_u = cv.createBox(10, 20, .up, .center);
        const box_l = cv.createBox(10, 20, .center, .left);
        const box_d = cv.createBox(10, 20, .down, .center);
        const box_r = cv.createBox(10, 20, .center, .right);

        try cv.onScreen(box_u, .draw);
        try cv.onScreen(box_l, .draw);
        try cv.onScreen(box_d, .draw);
        try cv.onScreen(box_r, .draw);

        cv.render();
        const key = try cv.fmt.reader.takeByte();
        if (key == 'q') break;
    }
}
