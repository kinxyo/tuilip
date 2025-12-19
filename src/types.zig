const colors = @import("color_types.zig");

/// Type assertion for measuring unit of position.
pub const Unit = u16;

/// Type assertion for encoding string.
pub const Unicode = u21;

/// Enum for creating shape of box: ┌─┐│└┘
pub const Side = enum(Unicode) {
    TopLeft = '┌',
    TopRight = '┐',
    BottomLeft = '└',
    BottomRight = '┘',
    SideHzn = '─',
    SideVtl = '│',
    None = ' ',
};

/// Struct `Cell` represents buffer for each pixel.
pub const Cell = struct {
    bg: colors.BackgroundColor = .default,
    fg: colors.ForegroundColor = .default,
    char: Unicode = ' ',
};

/// Struct representing Point (row x col)
pub const Point = struct {
    row: Unit,
    col: Unit,
};

/// Enum for Orientation:
/// `H` for horizontal.
/// `V` for vertical.
pub const Orientation = enum {
    /// Horizontal
    H,
    /// Vertical
    V,
};

/// Direction specifying for box/container.
pub const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};
