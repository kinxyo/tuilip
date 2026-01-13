const std = @import("std");
const io = @import("io.zig");
const t = @import("types.zig");
const Terminal = @import("terminal.zig");
const Cell = @import("cell.zig");
const Allocator = std.mem.Allocator;

pub const Canvas = @This();

allocator: Allocator,
T: Terminal,
fb: []Cell,
bb: []Cell,

// === Primitives ===

pub fn drawCS(self: *Canvas, col: t.Unit, row: t.Unit) void {
    const index = self.T.getCol() * row + col;
    self.bb[index] = .{ .char = '*' };
}

pub fn render(self: *Canvas) void {
    for (0..self.bb.len) |idx| {
        if (!std.meta.eql(self.fb[idx], self.bb[idx])) {
            const width = self.T.getCol();
            const row = idx / width;
            const col = idx % width;

            io.printf("\x1b[{d};{d}H{u}", .{ row + 1, col + 1, self.bb[idx].char });
            self.fb[idx] = self.bb[idx];
        }
    }

    io.flush();
}

pub fn poll(self: *Canvas) ?u8 {
    self.render();
    return io.inputChar() catch null;
}

// === Config ===

pub fn init(allocator: Allocator) !Canvas {
    const term: Terminal = try .init(io.getHandle());

    const size: usize = term.size.col * term.size.row;

    const buf = try allocator.alloc(Cell, size);
    defer allocator.free(buf);

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
