const Examples = @This();
const Init = @import("std").process.Init;

pub fn run(init: Init, arg: []const u8) !void {
    const CHOICE = @import("std").fmt.parseInt(usize, arg, 10) catch return error.InvalidArg;
    switch (CHOICE) {
        0 => try @import("./moving_pixel.zig").main(init),
        1 => try @import("./simple_text.zig").main(init),
        else => return error.InvalidArg,
    }
}
