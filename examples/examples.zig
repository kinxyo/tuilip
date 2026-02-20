const Examples = @This();

pub fn run(arg: []const u8) !void {
    const CHOICE = @import("std").fmt.parseInt(usize, arg, 10) catch return error.InvalidArg;
    switch (CHOICE) {
        0 => try @import("./moving_pixel.zig").main(),
        1 => try @import("./simple_text.zig").main(),
        else => return error.InvalidArg,
    }
}
