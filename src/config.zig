const std = @import("std");
const t = @import("types.zig");
const io = @import("io.zig");

const TerminalSize = struct {
    rows: t.Unit,
    cols: t.Unit,
};

/// Fetch terminal size
pub fn getSize() TerminalSize {
    // TODO: Review appraoch: NOT HANDLING ERROR BUT CREATING ARBITRARY CANVAS
    var size: std.posix.winsize = undefined;
    const ret = std.posix.system.ioctl(io.getHandle(), std.posix.T.IOCGWINSZ, @intFromPtr(&size));
    const term_r: t.Unit = if (ret != 0) 10 else size.row;
    const term_c: t.Unit = if (ret != 0) 10 else size.col;

    return .{ .rows = term_r, .cols = term_c };
}

pub fn enableRaw() std.posix.termios {
    const hn = io.getHandle();
    const original = std.posix.tcgetattr(hn) catch {
        // TODO: properly log error
        std.log.err("Failed to set terminal flags.", .{});
        std.process.exit(1);
    };

    var raw = original;
    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;

    std.posix.tcsetattr(hn, .FLUSH, raw) catch {
        // TODO: properly log error
        std.log.err("Failed to set terminal flags.", .{});
        std.process.exit(1);
    };
    return original;
}

/// Panics on failure
pub fn disableRaw(original: std.posix.termios) void {
    std.posix.tcsetattr(io.getHandle(), .FLUSH, original) catch {
        std.log.err("Failed to disable the raw mode.", .{});
        std.process.exit(1);
    };
}

// TODO: Gotta rename.
/// Enables relevant flag for terminal, clears terminal and hides the cursor.
/// Returns terminal state. Follow it up with `defer Canvas.end_prod(term_state)`.
/// Function panics on failure.
pub fn prod() std.posix.termios {
    io.clear_screen();
    io.cursor_hide();
    io.flush();
    return enableRaw();
}

/// Reset terminal back to original state.
/// Use with defer after `.prod()`;
/// Function panics on failure.
pub fn end_prod(terminal_state: std.posix.termios) void {
    disableRaw(terminal_state);
    io.cursor_hide();
    io.clear_screen();
    io.flush();
}
