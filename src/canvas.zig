const std = @import("std");
const io = @import("io.zig");
const t = @import("types.zig");
const Terminal = @import("terminal.zig");
const Cell = @import("cell.zig");
const Allocator = std.mem.Allocator;

const CanvasError = error{
    ExceedsScreenSize,
};

pub const Canvas = @This();

allocator: Allocator,
T: Terminal,
fb: []Cell,
bb: []Cell,

// === Primitives ===

pub fn flush(self: *Canvas) void {
    for (0..self.bb.len) |idx| {
        if (!std.meta.eql(self.fb[idx], self.bb[idx])) {
            const width = self.T.getCol();
            const row = idx / width;
            const col = idx % width;

            io.printf("\x1b[{d};{d}m", .{ self.bb[idx].bg, self.bb[idx].fg });
            io.printf("\x1b[{d};{d}H{u}", .{ row + 1, col + 1, self.bb[idx].char });
            io.print("\x1b[0m");
            self.fb[idx] = self.bb[idx];
        }
    }

    io.flush();
}

pub fn poll(self: *Canvas) ?u8 {
    self.flush();
    return io.inputChar() catch null;
}

pub fn pollOnly(self: *Canvas) ?u8 {
    _ = self;
    return io.inputChar() catch null;
}

const Mode = enum {
    draw,
    erase,
};

pub fn render(self: *Canvas, widget: anytype, col: t.Unit, row: t.Unit, m: Mode) CanvasError!void {
    switch (@TypeOf(widget)) {
        Cell => try self.drawCell(col, row, widget, m),
        else => @compileError("Unsupported widget."),
    }
}

// === Wrappers ===

pub fn renderBounded(self: *Canvas, widget: anytype, col: i32, row: i32, m: Mode) CanvasError!void {
    const c: t.Unit = @intCast(std.math.clamp(col, 0, self.T.getCol() - 1));
    const r: t.Unit = @intCast(std.math.clamp(row, 0, self.T.getRow() - 1));

    try self.render(widget, c, r, m);
}

// === Implementation ===

pub fn drawCell(self: *Canvas, col: t.Unit, row: t.Unit, c: Cell, m: Mode) CanvasError!void {
    const index = self.T.getCol() * row + col;
    if (self.bb.len <= index) return error.ExceedsScreenSize;

    switch (m) {
        .draw => self.bb[index] = c,
        .erase => self.bb[index] = .{ .char = ' ' },
    }
}

// === Config ===

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
