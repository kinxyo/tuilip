const std = @import("std");
const term = @import("terminal.zig");
const t = @import("types.zig");
const Cell = @import("cell.zig");
const Text = @import("text.zig");
const Box = @import("box.zig");
const Allocator = std.mem.Allocator;

const CanvasError = error{
    ExceedsScreenSize,
    RowOutOfBounds,
    ColOutOfBounds,
    InvalidShape,
};

pub const Canvas = @This();

io: std.Io,
/// allocator
allocator: Allocator,
/// metadata (underlying Box; containing size and position)
body: Box = undefined,
/// front buffer
fb: []Cell,
/// back buffer
bb: []Cell,

// === Primitives ===

/// Flush the back buffer to print on the screen.
/// To be called after drawing.
pub fn present(self: *Canvas) void {
    for (0..self.bb.len) |idx| {
        if (!std.meta.eql(self.fb[idx], self.bb[idx])) {
            const width = self.body.cols;
            const row = idx / width;
            const col = idx % width;

            term.printf("\x1b[{d};{d}m", .{ self.bb[idx].bg, self.bb[idx].fg });
            term.printf("\x1b[{d};{d}H{u}", .{ row + 1, col + 1, self.bb[idx].char });
            term.print("\x1b[0m");
            self.fb[idx] = self.bb[idx];
        }
    }

    term.flush();
}

pub fn poll(self: *Canvas) ?u8 {
    self.present();
    return term.inputChar() catch null;
}

pub fn pollOnly(self: *Canvas) ?u8 {
    _ = self;
    return term.inputChar() catch null;
}

// === Render Methods ===

const Mode = enum {
    draw,
    erase,
};

/// Draws/Erases given widget on backbuffer at given position.
/// NOTE: For container widget (Box), position arg will be ignored since that is already embedded in its def.
pub fn render(self: *Canvas, widget: anytype, position: ?t.UnitGroup, m: Mode) CanvasError!void {
    switch (@TypeOf(widget)) {
        *const Box => @compileError("remove `const` from the box if you're passing it as ref."),
        *Box => {
            if (position) |pos| widget.size.origin = pos;
            try self.implBox(widget.*, m);
        },
        Box => try self.implBox(widget, m),
        Cell => try self.implCell(position.?.col, position.?.row, widget, m),
        Text => try self.implText(position.?.col, position.?.row, widget, m),
        else => @compileError("Unsupported widget."),
    }
}

/// Draws/Erases given widget on backbuffer at given position, but is bounded within the canvas size.
/// If given position exceed canvas size then it's automatically clamped.
pub fn renderFit(self: *Canvas, widget: anytype, position: t.OffsetGroup, m: Mode) CanvasError!void {
    const new_col: t.Unit = @intCast(std.math.clamp(position.col, 0, self.body.cols - 1));
    const new_row: t.Unit = @intCast(std.math.clamp(position.row, 0, self.body.rows - 1));

    try self.render(widget, .{ .col = new_col, .row = new_row }, m);
}

// TODO: may change to name to drawAligned.
// TODO: Needs to account for erase mode. IDEA: Change the method to not render but locally mutate the variable position, then people only use render function to draw stuff.
/// Draws given widget on backbuffer at wanted position, when accuracy doesn't matter.
/// Returns coords of the position determined, so that erasure can be accurate
pub fn renderAlign(self: *Canvas, widget: anytype, v: t.VAlign, h: t.HAlign) CanvasError!void {
    // widget_length
    const wl: t.Unit = switch (@TypeOf(widget)) {
        Cell => 1,
        Text => @intCast(widget.value.len),
        Box => @intCast(widget.cols),
        else => 0,
    };

    // parent container's coordinate
    var coords = self.body.getCoords(h, v);

    // reduce shift
    if (h == .right) coords.col -= wl; // for right align.
    if (h == .center) coords.col -= wl / 2; // for center align.

    // call render
    try self.render(widget, coords, .draw);
}

// --- POSITIONING WRAPPERS ---

// Returns Co-ordinates for center position.
pub fn getCenter(self: *const Canvas) t.UnitGroup {
    return self.body.getCenter(0, 0, .reduce);
}

// === Implementation ===

// COMMON RULES
// NOTE: box is the only shape that has origin and dimesions embedded in it.
// - `col` & `row` represents origin points.

///
pub fn implCell(self: *Canvas, col: t.Unit, row: t.Unit, c: Cell, m: Mode) CanvasError!void {
    const index = self.body.cols * row + col;
    if (self.bb.len <= index) {
        if (col >= self.body.cols) return error.ColOutOfBounds;
        if (row >= self.body.rows) return error.RowOutOfBounds;
        unreachable;
    }

    switch (m) {
        .draw => self.bb[index] = c,
        .erase => self.bb[index] = .{ .char = ' ' },
    }
}

pub fn implText(self: *Canvas, col: t.Unit, row: t.Unit, text: Text, m: Mode) CanvasError!void {
    const index = self.body.cols * row + col;
    if (self.bb.len <= index) {
        if (col >= self.body.cols) return error.ColOutOfBounds;
        if (row >= self.body.rows) return error.RowOutOfBounds;
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

pub fn implBox(self: *Canvas, box: Box, m: Mode) CanvasError!void {
    _ = m;

    var char: t.BoxChar = .None;

    const col = box.size.origin.col;
    const row = box.size.origin.row;

    // Calculating corners first.
    const topleft = try self.returnIndex(row, col);
    const topright = try self.returnIndex(row, col + box.size.cols);
    const bottomright = try self.returnIndex(row + box.size.rows, col + box.size.cols);
    const bottomleft = try self.returnIndex(row + box.size.rows, col);

    for (topleft..topright) |idx| {
        if (idx == topleft) char = .TopLeft;
        if (idx == topright) char = .TopRight;

        char = .SideHzn;

        self.bb[idx] = .{ .char = @backingInt(char) };
    }

    for (bottomleft..bottomright) |idx| {
        if (idx == bottomleft) char = .BottomLeft;
        if (idx == bottomright) char = .BottomRight;

        char = .SideHzn;

        self.bb[idx] = .{ .char = @backingInt(char) };
    }

    // mark points
    // create lines
}

// === Config ===

pub fn init(io: std.Io, allocator: Allocator) !Canvas {
    term.init(io);

    const t_size = try term.getSize();
    std.log.debug("size: {}x{}\n", .{ t_size.origin.col, t_size.origin.row });
    const buf_len: usize = t_size.cols * t_size.rows;

    try term.rawEnable();

    return .{
        .io = io,
        .allocator = allocator,
        .body = t_size,
        .fb = try allocator.alloc(Cell, buf_len),
        .bb = try allocator.alloc(Cell, buf_len),
    };
}

pub fn deinit(self: *const Canvas) void {
    self.allocator.free(self.fb);
    self.allocator.free(self.bb);
    term.rawDisable();
}

pub fn pause(self: *const Canvas, comptime secs: f32) void {
    self.io.sleep(.fromSeconds(secs), .awake) catch unreachable; // deal with it later
}

// === Helpers ===
inline fn returnIndex(self: *const Canvas, row: t.Unit, col: t.Unit) CanvasError!t.Unit {
    const index = self.body.cols * row + col;
    if (self.bb.len <= index) {
        if (col >= self.body.cols) return error.ColOutOfBounds;
        if (row >= self.body.rows) return error.RowOutOfBounds;
        unreachable;
    }
    return index;
}
