const std = @import("std");
const tui = @import("tuilip");

const SIZE = 1024 * 4;

pub fn main() !void {
    //  BOILER PLATE
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

    cv.fmt.clear_screen();
    cv.fmt.cursor_hide();
    defer cv.fmt.cursor_show();
    defer cv.fmt.clear_screen();

    // APP LOGIC
    var world = cv.createBox(allocator, 10, 20, .center, .center);
    defer world.deinit();

    const character = try world.addBox(
        "char",
        .{ .height = 2, .width = 2 },
        .{ .row = 1, .col = 1 },
    );

    // RENDER LOOP
    while (true) {
        cv.clearScreen();
        try cv.onScreen(world, .draw);

        cv.render();
        if (try poll_events(&cv, character)) break;
    }
}

// EVENTS
fn poll_events(cv: *tui.Canvas, character: *tui.Box) !bool {
    const key = try cv.fmt.reader.takeByte();
    if (key == 'q') return true;
    if (key == 'w') character.origin.row -= 1;
    if (key == 'a') character.origin.col -= 1;
    if (key == 's') character.origin.row += 1;
    if (key == 'd') character.origin.col += 1;
    return false;
}
