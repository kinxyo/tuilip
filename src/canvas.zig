const std = @import("std");
const io = @import("io.zig");
const p = @import("position.zig");
const Cell = @import("cell.zig");
const Text = @import("text.zig");
const Terminal = @import("terminal.zig");
const Allocator = std.mem.Allocator;

const CanvasError = error{
    ExceedsScreenSize,
    RowOutOfBounds,
    ColOutOfBounds,
    InvalidShape,
};

pub const Canvas = @This();

allocator: Allocator,
T: Terminal,
fb: []Cell,
bb: []Cell,

// === Primitives ===

pub fn createTextCS(self: *const Canvas, comptime str: []const u8, bg: io.Bg, fg: io.Fg) ![]Cell {
    const text = try self.allocator.alloc(Cell, str.len);

    for (text, 0..) |*c, i| {
        c.* = .{ .char = str[i], .bg = bg, .fg = fg };
    }
    return text;
}

pub fn flush(self: *Canvas) void {
    for (0..self.bb.len) |idx| {
        if (!std.meta.eql(self.fb[idx], self.bb[idx])) {
            const width = self.getCol();
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

/// Draws given widget on backbuffer at given position.
pub fn renderCS(self: *Canvas, widget: anytype, position: p.UnitGroup, m: Mode) CanvasError!void {
    switch (@TypeOf(widget)) {
        Cell => try self.drawCell(position.col, position.row, widget, m),
        Text => try self.drawText(position.col, position.row, widget, m),
        else => @compileError("Unsupported widget."),
    }
}

// === Wrappers ===

/// Draws given widget on backbuffer at given position, but is bounded within the canvas size.
/// If given position exceed canvas size then it's automatically clamped.
pub fn renderFit(self: *Canvas, widget: anytype, position: p.OffsetGroup, m: Mode) CanvasError!void {
    const c: p.Unit = @intCast(std.math.clamp(position.col, 0, self.getCol() - 1));
    const r: p.Unit = @intCast(std.math.clamp(position.row, 0, self.getRow() - 1));

    try self.renderCS(widget, .{ .col = c, .row = r }, m);
}

pub fn getCol(self: *const Canvas) p.Unit {
    return self.T.size.cols;
}

pub fn getRow(self: *const Canvas) p.Unit {
    return self.T.size.rows;
}

// Returns Co-ordinates for center position.
pub fn getCenter(self: *const Canvas) p.UnitGroup {
    return self.getCenterWithOffsets(.{ .col = 0, .row = 0 });
}

// Returns Co-ordinates for center position with Offset for both axis.
pub fn getCenterWithOffsets(self: *const Canvas, offset: p.OffsetGroup) p.UnitGroup {
    const c = @as(i16, @intCast(self.getCol() / 2)) + offset.col;
    const r = @as(i16, @intCast(self.getRow() / 2)) + offset.row;
    return .{
        .col = @intCast(c),
        .row = @intCast(r),
    };
}

// Returns Co-ordinates for center position with Offset for X axis.
pub fn getCenterOffsetX(self: *const Canvas, offset_col: p.Offset) p.UnitGroup {
    return self.getCenterWithOffsets(.{ .col = offset_col, .row = 0 });
}

// Returns Co-ordinates for center position with Offset for Y axis.
pub fn getCenterOffsetY(self: *const Canvas, offset_row: p.Offset) p.UnitGroup {
    return self.getCenterWithOffsets(.{ .col = 0, .row = offset_row });
}

// === Implementation ===

pub fn drawCell(self: *Canvas, col: p.Unit, row: p.Unit, c: Cell, m: Mode) CanvasError!void {
    const index = self.getCol() * row + col;
    if (self.bb.len <= index) {
        if (col >= self.getCol()) return error.ColOutOfBounds;
        if (row >= self.getRow()) return error.RowOutOfBounds;
        unreachable;
    }

    switch (m) {
        .draw => self.bb[index] = c,
        .erase => self.bb[index] = .{ .char = ' ' },
    }
}

pub fn drawText(self: *Canvas, col: p.Unit, row: p.Unit, text: Text, m: Mode) CanvasError!void {
    const index = self.getCol() * row + col;
    if (self.bb.len <= index) {
        if (col >= self.getCol()) return error.ColOutOfBounds;
        if (row >= self.getRow()) return error.RowOutOfBounds;
        unreachable;
    }

    switch (m) {
        .draw => {
            for (text.value, 0..) |char, idx| {
                self.bb[index + idx] = .{ .char = char };
            }
        },
        .erase => {
            for (0..text.value.len) |idx| {
                self.bb[index + idx] = .{ .char = ' ' };
            }
        },
    }
}

// === Config ===

pub fn init(allocator: Allocator) !Canvas {
    const term: Terminal = try .init(io.getHandle());

    const size: usize = term.size.cols * term.size.rows;

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
