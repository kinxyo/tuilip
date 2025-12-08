const std = @import("std");
const t = @import("types.zig");
const shapes = @import("shapes.zig");
const Canvas = @import("canvas.zig").Canvas;

pub const Orientation = enum {
    HORIZONTAL,
    VERTICAL,
};

pub fn autoBoxes(cv: *const Canvas, count: usize, grow_point: t.Unit, static_point: t.Unit, margin: t.Unit, orientation: Orientation) !void {
    if (count <= 0) return;
    if (count == 1) {
        return switch (orientation) {
            .HORIZONTAL => try drawBoxDirect(cv, static_point, grow_point, margin),
            .VERTICAL => try drawBoxDirect(cv, grow_point, static_point, margin),
        };
    }
    const grow_line = (grow_point - ((count + 1) * margin)) / count;
    const static_line = static_point - 2 * margin;
    for (0..count) |idx| {
        switch (orientation) {
            .HORIZONTAL => {
                const origin_x = if (idx == 0) margin else (margin + (idx * (margin + grow_line)));
                const origin_y = margin;

                try shapes.drawRect(
                    cv,
                    .{
                        .x = @intCast(origin_x),
                        .y = @intCast(origin_y),
                    },
                    @intCast(static_line),
                    @intCast(grow_line),
                );
            },
            .VERTICAL => {
                const origin_y = if (idx == 0) margin else (margin + (idx * (margin + grow_line)));
                const origin_x = margin;

                try shapes.drawRect(
                    cv,
                    .{
                        .x = @intCast(origin_x),
                        .y = @intCast(origin_y),
                    },
                    @intCast(grow_line),
                    @intCast(static_line),
                );
            },
        }
    }
}

fn drawBoxDirect(cv: *const Canvas, full_height: t.Unit, full_width: t.Unit, margin: t.Unit) !void {
    try shapes.drawRect(
        cv,
        .{
            .x = margin,
            .y = margin,
        },
        full_height - (margin * 2),
        full_width - (margin * 2),
    );
}
