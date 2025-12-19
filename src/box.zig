const t = @import("types.zig");

/// Struct representing Box (underlying definition for various shapes and classes).
pub const Box = struct {
    origin: t.Point,
    height: t.Unit = 1,
    width: t.Unit = 1,
    zindex: usize = 1,
};
