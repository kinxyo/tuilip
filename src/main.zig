const std = @import("std");

// demos
const demo1 = @import("demos/sliding_text.zig");

// main testing
const app = @import("demos/app.zig");

const CHOICE = 0;

pub fn main() !void {
    if (CHOICE == 0) try app.main() else try run_demo(comptime CHOICE);
}

fn run_demo(comptime s: usize) !void {
    switch (s) {
        1 => try demo1.main(),
        else => return,
    }
}
