const std = @import("std");
const t = @import("types.zig");
const f = @import("fmt.zig");

pub const CanvasError = error{
    RowOutOfBounds,
    ColOutOfBounds,
};

pub const Canvas = struct {
    fmt: *f.Fmt,
    rows: t.Unit,
    cols: t.Unit,
    back_buffer: []t.Cell,
    front_buffer: []t.Cell,
    margin: t.Unit,

    // ======== Drawing (primitives) ========

    /// Draw directly on canvas by passing buffers and other configurations.
    pub fn directDraw(self: *const Canvas, x: usize, y: usize, comptime char: t.Unicode) void {
        self.fmt.printf("\x1b[{d};{d}H{u}", .{ y + 1, x + 1, char });
    }

    /// Draw a pixel on specified coordinates on canvas by updating back buffer.
    pub fn draw(self: *const Canvas, col: usize, row: usize, char: t.Unicode) CanvasError!void {
        if (col >= self.cols) return error.ColOutOfBounds;
        if (row >= self.rows) return error.RowOutOfBounds;

        const index = row * self.getCol() + col;
        self.back_buffer[index].char = char;
    }

    /// Clear a pixel on specified coordinates by updating back buffer.
    /// Will require `.flush()` to render on canvas.
    pub fn clear(self: *Canvas, col: usize, row: usize) CanvasError!void {
        if (col >= self.cols) return error.ColOutOfBounds;
        if (row >= self.rows) return error.RowOutOfBounds;

        const index = row * self.cols + col;
        self.back_buffer[index].char = ' ';
    }

    /// Draw on canvas by updating back buffer along with Color & style configuration.
    pub fn drawC(self: *Canvas, col: usize, row: usize, cell: t.Cell) CanvasError!void {
        if (col >= self.cols) return error.ColOutOfBounds;
        if (row >= self.rows) return error.RowOutOfBounds;

        const index = row * self.cols + col;
        self.back_buffer[index] = cell;
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

    // ======== Drawing (advance) ========

    /// Container (Equvialent to `Div` element from html).
    pub fn div(self: *Canvas, point: ?t.Point, length: t.Unit, breadth: t.Unit) !void {
        // TODO: get space (origin points).
        const p: t.Point = point orelse .{ .row = 1, .col = 1 };
        const box: t.Box = .{ .row = p.row, .col = p.col, .length = length, .breadth = breadth };
        for (box.row..(box.row + box.length)) |y| {
            for (box.col..(box.col + box.breadth)) |x| {
                const is_border: bool = (y == box.row or y == (box.row + box.length - 1)) or (x == box.col or x == (box.col + box.breadth - 1));

                if (is_border) {
                    try self.draw(x, y, '.');
                }
            }
        }
    }

    // pub fn flexBox(self: *Canvas, count: usize, ori: t.Orientation) !void {}

    // ======== Config ========

    /// Create a canvas instance that contains terminal size and allows draw operations.
    /// Needs to pass a `fmt` instance for drawing and event polling.
    pub fn init(fmt: *f.Fmt, allocator: std.mem.Allocator, margin: t.Unit) Canvas {
        var size: std.posix.winsize = undefined;
        const ret = std.posix.system.ioctl(fmt.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&size));

        // NOT HANDLING ERROR BUT CREATING ARBITRARY CANVAS
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

    /// Destroy the allocated safe for graceful exit of program and prevent memory leaks.
    pub fn deinit(self: *Canvas, allocator: std.mem.Allocator) void {
        allocator.free(self.back_buffer);
        allocator.free(self.front_buffer);
    }
};
