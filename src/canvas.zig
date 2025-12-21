const std = @import("std");
const f = @import("fmt.zig");
const t = @import("types.zig");

pub const CanvasError = error{
    RowOutOfBounds,
    ColOutOfBounds,
    InvalidShape,
};

/// Unified API responsible for following operations:
/// Primitives, Wrapper functions, Implementation of Shapes & Terminal configuration.
pub const Canvas = struct {
    /// needs it to output to terminal
    fmt: *f.Fmt,
    /// defines the drawable area
    rows: t.Unit,
    /// defines the drawable area
    cols: t.Unit,
    /// the actual pixels (next-screen)
    back_buffer: []t.Cell,
    /// the actual pixels (on-screen)
    front_buffer: []t.Cell,
    /// part of the drawable area definition
    margin: t.Unit,

    // ======== Primitives ========

    /// Draw directly on canvas by passing buffers and other configurations.
    pub fn directDraw(self: *const Canvas, x: usize, y: usize, comptime char: t.Unicode) void {
        self.fmt.printf("\x1b[{d};{d}H{u}", .{ y + 1, x + 1, char });
    }

    /// Draw on canvas by updating back buffer along with Color & style configuration.
    pub fn drawC(self: *Canvas, col: usize, row: usize, cell: t.Cell) CanvasError!void {
        if (col >= self.cols) return error.ColOutOfBounds;
        if (row >= self.rows) return error.RowOutOfBounds;

        const index = row * self.cols + col;
        self.back_buffer[index] = cell;
    }

    pub fn drawStringC(self: *Canvas, col: usize, row: usize, s: []const u8, fg: t.colors.ForegroundColor, bg: t.colors.BackgroundColor, m: Mode) CanvasError!void {
        if (col >= self.cols) return error.ColOutOfBounds;
        if (row >= self.rows) return error.RowOutOfBounds;

        for (s, 0..) |c, idx| {
            const index = row * self.cols + col;
            self.back_buffer[index + idx - (s.len / 2)].char = if (m == .draw) c else ' ';
            self.back_buffer[index + idx - (s.len / 2)].fg = fg;
            self.back_buffer[index + idx - (s.len / 2)].bg = bg;
        }
    }

    /// Flush back buffer & sync front buffer.
    pub fn render(self: *Canvas) void {
        for (self.front_buffer, self.back_buffer, 0..) |front, back, idx| {
            if (!std.meta.eql(front, back)) {
                const r = idx / self.cols;
                const c = idx % self.cols;

                if (back.bg.isSet()) {
                    self.fmt.printf("\x1b[{d};{d}m", .{ back.fg, back.bg });
                } else {
                    self.fmt.printf("\x1b[{d}m", .{back.fg});
                }

                self.fmt.printf("\x1b[{d};{d}H{u}", .{ r + 1, c + 1, back.char });
                self.fmt.print("\x1b[0m");

                self.front_buffer[idx] = self.back_buffer[idx];
            }
        }

        self.fmt.flush();
    }

    /// Flush back buffer without comparing with front buffer
    /// And copy the whole back buffer to front buffer.
    /// Less performant; only use when necessary.
    pub fn renderForce(self: *Canvas) void {
        for (self.back_buffer, 0..) |back, idx| {
            const r = idx / self.cols;
            const c = idx % self.cols;

            self.fmt.printf("\x1b[{d};{d}H{u}", .{ r + 1, c + 1, back.char });
        }
        self.fmt.flush();
        @memcpy(self.front_buffer, self.back_buffer);
    }

    // ======== Wrapper Functions ========

    /// Draw a pixel on specified coordinates on canvas by updating back buffer.
    pub fn draw(self: *const Canvas, col: usize, row: usize, char: t.Unicode) CanvasError!void {
        try self.drawC(col, row, .{ .char = char });
    }

    /// Clear a pixel on specified coordinates by updating back buffer.
    /// Will require `.flush()` to render on canvas.
    pub fn clear(self: *Canvas, col: usize, row: usize) CanvasError!void {
        try self.drawC(col, row, .{ .char = ' ' });
    }

    pub fn drawString(self: *Canvas, col: usize, row: usize, s: []const u8) CanvasError!void {
        try self.drawStringC(col, row, s, .default, .default, .draw);
    }

    pub fn clearString(self: *Canvas, col: usize, row: usize, s: []const u8) CanvasError!void {
        try self.drawStringC(col, row, s, .default, .default, .erase);
    }

    /// WARN: EXPERMINATAL right now -- only use if the canvas is empty and nothing is drawn.
    pub fn createBox(self: *const Canvas, allocator: std.mem.Allocator, height: t.Unit, width: t.Unit, yaxis: t.YAxis, xaxis: t.XAxis) t.Box {
        const x = switch (xaxis) {
            .left => self.margin,
            .right => self.getCol() - width,
            .center => self.getCol() / 2 - width / 2,
        };

        const y = switch (yaxis) {
            .up => self.margin,
            .down => self.getRow() - height,
            .center => self.getRow() / 2 - height / 2,
        };

        return .{
            .allocator = allocator,
            .height = height,
            .width = width,
            .origin = .{ .col = x, .row = y },
            .children = null,
        };
    }

    // ======== Implmentations (shapes/classes) ========

    const Mode = enum {
        draw,
        erase,
    };

    // Directly pass the widget to draw it on back buffer (next frame).
    pub fn onScreen(self: *Canvas, widget: anytype, m: Mode) CanvasError!void {
        switch (@TypeOf(widget)) {
            t.Box => try self.drawBox(widget, m),
            t.Text => try self.drawText(widget, m),
            else => @compileError("Invalid widget provided."),
        }
    }

    /// Implementation of Text widget. Draws on back buffer.
    fn drawText(self: *Canvas, text: t.Text, m: Mode) CanvasError!void {
        switch (m) {
            .draw => try self.drawString(text.origin.col, text.origin.row, text.value),
            .erase => try self.clearString(text.origin.col, text.origin.row, text.value),
        }
    }

    /// Implementation of Box widget. Draws on back buffer.
    fn drawBox(self: *Canvas, box: t.Box, m: Mode) CanvasError!void {
        for (box.origin.row..(box.origin.row + box.height)) |y| {
            for (box.origin.col..(box.origin.col + box.width)) |x| {
                switch (m) {
                    .erase => {
                        try self.clear(x, y);
                    },
                    .draw => {
                        var char: t.Side = .None;

                        // NOTE: `-1` is needed because loop running is exclusive of last element. (I keep forgetting).
                        const lh = box.height - 1;
                        const lw = box.width - 1;

                        // Sides
                        if (x == box.origin.col) {
                            if (y == box.origin.row) {
                                char = .TopLeft;
                            } else if (y == box.origin.row + lh) {
                                char = .BottomLeft;
                            } else {
                                char = .SideVtl;
                            }
                        } else if (x == box.origin.col + lw) {
                            if (y == box.origin.row) {
                                char = .TopRight;
                            } else if (y == box.origin.row + lh) {
                                char = .BottomRight;
                            } else {
                                char = .SideVtl;
                            }
                        } else if (y == box.origin.row) {
                            char = .SideHzn;
                        } else if (y == box.origin.row + lh) {
                            char = .SideHzn;
                        }

                        if (char != .None) {
                            try self.drawC(x, y, .{ .char = @intFromEnum(char) });
                        }
                    },
                }
            }
        }
        try self.drawChild(box, m);
    }

    fn drawChild(self: *Canvas, box: t.Box, m: Mode) !void {
        if (box.children) |*c| {
            var iter = c.iterator();

            while (iter.next()) |widget| {
                const child = widget.value_ptr.*;
                switch (child) {
                    .box => try self.drawBox(.{
                        .allocator = child.box.allocator,
                        .height = child.box.height,
                        .width = child.box.width,
                        .origin = .{
                            .col = @intCast(child.box.origin.col),
                            .row = @intCast(child.box.origin.row),
                        },
                    }, m),
                    .text => try self.drawText(child.text, m),
                }
            }
        }
    }

    // pub fn flexBox(self: *Canvas, count: usize, ori: t.Orientation) !void {}

    // ======== Config ========

    /// Create a canvas instance that contains terminal size and allows draw operations.
    /// Needs to pass a `fmt` instance for drawing and event polling.
    /// The function will panic if memory is insufficient.
    pub fn init(fmt: *f.Fmt, allocator: std.mem.Allocator, margin: t.Unit) Canvas {
        var size: std.posix.winsize = undefined;
        const ret = std.posix.system.ioctl(fmt.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&size));

        // TODO: Review appraoch: NOT HANDLING ERROR BUT CREATING ARBITRARY CANVAS
        const term_r: t.Unit = if (ret != 0) 10 else size.row;
        const term_c: t.Unit = if (ret != 0) 10 else size.col;

        const total_cells: usize = term_r * term_c;

        const bb = allocator.alloc(t.Cell, total_cells) catch {
            const needed_size = total_cells * @sizeOf(t.Cell) * 2 + 2;
            std.log.err("Out of memory: {d} is needed!\n", .{needed_size});
            std.process.exit(1);
        };
        const fb = allocator.alloc(t.Cell, total_cells) catch {
            const needed_size = total_cells * @sizeOf(t.Cell) * 2 + 2;
            std.log.err("Out of memory: {d} is needed!\n", .{needed_size});
            std.process.exit(1);
        };

        return .{
            .fmt = fmt,
            .rows = term_r,
            .cols = term_c,
            .back_buffer = bb,
            .front_buffer = fb,
            .margin = margin,
        };
    }

    /// Use this function if you want Canvas height with margin consideration.
    pub fn getRow(self: *const Canvas) t.Unit {
        return self.rows - self.margin;
    }

    /// Use this function if you want Canvas width with margin consideration.
    pub fn getCol(self: *const Canvas) t.Unit {
        return self.cols - self.margin;
    }

    /// Disables (currently: ECHO, ICANON) flags for terminal,
    /// returns original instance for restoring original state at the end of program.
    pub fn enableRaw(self: *const Canvas) !std.posix.termios {
        const original = try std.posix.tcgetattr(self.fmt.handle);

        var raw = original;
        raw.lflag.ECHO = false;
        raw.lflag.ICANON = false;

        try std.posix.tcsetattr(self.fmt.handle, .FLUSH, raw);
        return original;
    }

    pub fn disableRaw(self: *const Canvas, original: std.posix.termios) void {
        std.posix.tcsetattr(self.fmt.handle, .FLUSH, original) catch {};
    }

    pub fn clearScreen(self: *Canvas) void {
        @memset(self.back_buffer, .{});
    }

    pub fn clearScreenForce(self: *Canvas) void {
        @memset(self.back_buffer, .{});
        self.renderForce();
    }

    /// Destroy the allocated safe for graceful exit of program and prevent memory leaks.
    pub fn deinit(self: *Canvas, allocator: std.mem.Allocator) void {
        allocator.free(self.back_buffer);
        allocator.free(self.front_buffer);
    }

    pub fn log(self: *const Canvas) void {
        std.log.debug("{d}:{d}\n", .{ self.rows, self.cols });
    }
};
