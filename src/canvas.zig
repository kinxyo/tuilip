const std = @import("std");
const io = @import("io.zig");
const Terminal = @import("terminal.zig");
const Cell = @import("cell.zig");
const Allocator = std.mem.Allocator;

pub const Canvas = @This();

allocator: Allocator,
T: Terminal,
fb: []Cell,
bb: []Cell,

pub fn init(allocator: Allocator) !Canvas {
    const term: Terminal = try .init(io.getHandle());

    const size: usize = term.size.col * term.size.row;

    return .{
        .allocator = allocator,
        .T = term,
        .fb = try allocator.alloc(Cell, size),
        .bb = try allocator.alloc(Cell, size),
    };
}
pub fn deinit(self: *const Canvas) void {
    self.allocator.free(self.fb);
    self.allocator.free(self.bb);
    self.T.rawNo();
}
