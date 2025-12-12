const std = @import("std");

// demos
const demo1 = @import("demos/sliding_text.zig");
const demo2 = @import("demos/using_animations.zig");
const demo3 = @import("demos/stackBoxes.zig");
const demo4 = @import("demos/color_transition_fullpage.zig");

// main testing
const app = @import("demos/app.zig");

const CHOICE = 0;

pub fn main() !void {
    return switch (comptime CHOICE) {
        1 => try demo1.main(),
        2 => try demo2.main(),
        3 => try demo3.main(),
        4 => try demo4.main(),
        else => app.main(),
    };
}
