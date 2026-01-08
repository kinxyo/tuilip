pub const colors = @import("color_types.zig");
pub const Box = @import("box.zig").Box;
pub const WidgetList = @import("widgets.zig").WidgetList;

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

/// Struct representing Size (width x height)
pub const Size = struct {
    width: Unit,
    height: Unit,
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
pub const YAxis = enum {
    up,
    center,
    down,
};

/// Direction specifying for box/container.
pub const XAxis = enum {
    left,
    center,
    right,
};

const PositionalUnit = f32;

pub const Position = struct {
    top: PositionalUnit = 0,
    left: PositionalUnit = 0,
    // bottom: PositionalUnit = 0,
    // right: PositionalUnit = 0,
};

pub const Widget = union(enum) {
    text: Text,
    box: Box,
};

pub const Text = struct {
    value: []const u8,
    origin: Point,
};
