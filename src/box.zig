const std = @import("std");
const t = @import("types.zig");
const Canvas = @import("canvas.zig").Canvas;

/// Container
pub const Box = struct {
    height: t.Unit = 1,
    width: t.Unit = 1,
    fill: bool = true,
    direction: t.Direction = .RIGHT,
    zindex: usize = 1,
};
