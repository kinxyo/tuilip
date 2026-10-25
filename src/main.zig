// ========= TODO ===========
// [ ] Collision Detection: Create 2 renderAlign in same direction and try to stack them.
// [ ] Widget management: Confirm if previous implementation is already a tree structure. Dont bother with BFS/DFS until actually needed.
// [ ] Box: Copy previous impl
// [ ] Lists: Fun new stuff (easy!)

const Init = @import("std").process.Init;

pub fn main(init: Init) !void {
    var args = init.minimal.args.iterate();

    _ = args.skip();

    if (args.next()) |arg| {
        try @import("examples").run(init, arg);
        return;
    }

    try @import("playground.zig").main(init);
}

// https://ziglang.org/download/0.16.0/release-notes.html
// https://ziglang.org/download/0.17.0/release-notes.html
