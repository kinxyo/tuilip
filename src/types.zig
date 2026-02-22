//! Shared Types

// Positioning
pub const Unit = u16;
pub const Offset = i16;
pub const UnitGroup = struct { col: Unit, row: Unit };
pub const OffsetGroup = struct { col: Offset, row: Offset };
pub const OffsetType = enum { reduce, add };

pub const VAlign = enum { top, center, bottom };
pub const HAlign = enum { left, center, right };

// Character
pub const Unicode = u21;

/// Enum for creating shape of box: ┌─┐│└┘
// TODO: rename.
pub const BoxChar = enum(Unicode) {
    TopLeft = '┌',
    TopRight = '┐',
    BottomLeft = '└',
    BottomRight = '┘',
    SideHzn = '─',
    SideVtl = '│',
    None = ' ',
};
