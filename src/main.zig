// ========= TODO ===========
// [ ] Collision Detection: Create 2 renderAlign in same direction and try to stack them.
// [ ] Widget management: Confirm if previous implementation is already a tree structure. Dont bother with BFS/DFS until actually needed.
// [ ] Box: Copy previous impl
// [ ] Lists: Fun new stuff (easy!)

pub fn main() !void {
    var args = @import("std").process.args();
    _ = args.skip();

    if (args.next()) |arg| {
        try @import("examples").run(arg);
    }

    try @import("playground.zig").main();
}
