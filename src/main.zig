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
    defer cv.fmt.clear();

    var char_col: f32 = 1;
    var char_row: f32 = 1;

    while (true) {
        var world = cv.createBox(10, 20, .center, .center);

        const character = try world.addBox(
            allocator,
            .{ .height = 2, .width = 2 },
            .{ .row = char_row, .col = char_col },
        );
        defer world.child.deinit(allocator);

        try cv.onScreen(world, .draw);

        cv.render();
        const key = try cv.fmt.reader.takeByte();
        if (key == 'q') break;
        if (key == 'a') {
            try cv.onScreen(character, .erase);
            char_col -= 1;
        }
        if (key == 'd') {
            try cv.onScreen(character, .erase);
            char_col += 1;
        }
        if (key == 's') {
            try cv.onScreen(character, .erase);
            char_row += 1;
        }
        if (key == 'w') {
            try cv.onScreen(character, .erase);
            char_row -= 1;
        }
    }
}
