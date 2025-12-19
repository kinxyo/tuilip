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
        try cv.insert(.BOX, .{ .row = pos_row, .col = pos_col }, 10, 15);
        cv.render();

        const key = try cv.fmt.reader.takeByte();
        if (key == 'q') break;
        if (key == 'a' and pos_col > 0) {
            try cv.remove(.BOX, .{ .row = pos_row, .col = pos_col }, 10, 15);
            pos_col -= 1;
        }
        if (key == 'd' and pos_col + 15 < cv.getCol()) {
            try cv.remove(.BOX, .{ .row = pos_row, .col = pos_col }, 10, 15);
            pos_col += 1;
        }
    }
}
