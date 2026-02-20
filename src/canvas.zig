const std = @import("std");
const io = @import("io.zig");
const p = @import("position.zig");
const Cell = @import("cell.zig");
const Text = @import("text.zig");
const Box = @import("box.zig");
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
size: p.Size = undefined,
// front buffer
fb: []Cell,
// back buffer
bb: []Cell,

// === Primitives ===

pub fn createTextCS(self: *const Canvas, comptime str: []const u8, bg: io.Bg, fg: io.Fg) ![]Cell {
    const text = try self.allocator.alloc(Cell, str.len);

    for (text, 0..) |*c, i| {
        c.* = .{ .char = str[i], .bg = bg, .fg = fg };
    }
    return text;
}

pub fn present(self: *Canvas) void {
    for (0..self.bb.len) |idx| {
        if (!std.meta.eql(self.fb[idx], self.bb[idx])) {
            const width = self.size.cols;
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
    self.present();
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

/// Draws/Erases given widget on backbuffer at given position.
pub fn render(self: *Canvas, widget: anytype, position: p.UnitGroup, m: Mode) CanvasError!void {
    switch (@TypeOf(widget)) {
        Cell => try self.implCell(position.col, position.row, widget, m),
        Text => try self.implText(position.col, position.row, widget, m),
        Box => try self.implBox(position.col, position.row, widget, m),
        else => @compileError("Unsupported widget."),
    }
}

// === Wrappers ===

/// Draws/Erases given widget on backbuffer at given position, but is bounded within the canvas size.
/// If given position exceed canvas size then it's automatically clamped.
pub fn renderFit(self: *Canvas, widget: anytype, position: p.OffsetGroup, m: Mode) CanvasError!void {
    const new_col: p.Unit = @intCast(std.math.clamp(position.col, 0, self.size.cols - 1));
    const new_row: p.Unit = @intCast(std.math.clamp(position.row, 0, self.size.rows - 1));

    try self.render(widget, .{ .col = new_col, .row = new_row }, m);
}

// TODO: may change to name to drawAligned.
// TODO: Needs to account for erase mode. IDEA: Change the method to not render but locally mutate the variable position, then people only use render function to draw stuff.
/// Draws given widget on backbuffer at wanted position, when accuracy doesn't matter.
/// Returns coords of the position determined, so that erasure can be accurate
pub fn renderAlign(self: *Canvas, widget: anytype, v: p.VAlign, h: p.HAlign) CanvasError!p.UnitGroup {
    var coords = self.size.getCoords(h, v);
    // NOTE: Every widget must have `.len()` method built in them.
    if (h == .right) coords.col -= widget.len(); // reduce shift for left align.
    if (h == .center) coords.col -= widget.len() / 2; // reduce shift for center align.

    try self.render(widget, coords, .draw);
    return coords;
}

// --- POSITIONING WRAPPERS ---

// Returns Co-ordinates for center position.
pub fn getCenter(self: *const Canvas) p.UnitGroup {
    return self.size.getCenter(0, 0, .reduce);
}

// === Implementation ===

pub fn implCell(self: *Canvas, col: p.Unit, row: p.Unit, c: Cell, m: Mode) CanvasError!void {
    const index = self.size.cols * row + col;
    if (self.bb.len <= index) {
        if (col >= self.size.cols) return error.ColOutOfBounds;
        if (row >= self.size.rows) return error.RowOutOfBounds;
        unreachable;
    }

    switch (m) {
        .draw => self.bb[index] = c,
        .erase => self.bb[index] = .{ .char = ' ' },
    }
}

pub fn implText(self: *Canvas, col: p.Unit, row: p.Unit, text: Text, m: Mode) CanvasError!void {
    const index = self.size.cols * row + col;
    if (self.bb.len <= index) {
        if (col >= self.size.cols) return error.ColOutOfBounds;
        if (row >= self.size.rows) return error.RowOutOfBounds;
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

pub fn implBox(self: *Canvas, col: p.Unit, row: p.Unit, box: Box, m: Mode) CanvasError!void {
    // mark points
    // create lines
}

// === Config ===

pub fn init(allocator: Allocator) !Canvas {
    const t_size = try io.getSize();
    // std.log.debug("size: {}x{}\n", .{ t_size.cols, t_size.rows });
    const buf_len: usize = t_size.cols * t_size.rows;

    try io.rawEnable();

    return .{
        .allocator = allocator,
        .size = t_size,
        .fb = try allocator.alloc(Cell, buf_len),
        .bb = try allocator.alloc(Cell, buf_len),
    };
}

pub fn deinit(self: *const Canvas) void {
    self.allocator.free(self.fb);
    self.allocator.free(self.bb);
    io.rawDisable();
}
