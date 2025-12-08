const std = @import("std");

// demos
const demo1 = @import("demos/sliding_text.zig");
const demo2 = @import("demos/using_animations.zig");
const demo3 = @import("demos/stackBoxes.zig");

// main testing
const app = @import("demos/app.zig");

const CHOICE = 0;

pub fn main() !void {
    if (CHOICE == 0) try app.main() else try run_demo(comptime CHOICE);
}

fn run_demo(comptime s: usize) !void {
    switch (s) {
        1 => try demo1.main(),
        2 => try demo2.main(),
        3 => try demo3.main(),
        else => return,
    }
}
