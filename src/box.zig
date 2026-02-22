//! Container-type widget `Box`.

const t = @import("types.zig");

const Box = @This();

origin: t.UnitGroup = .{ .col = 0, .row = 0 },
cols: t.Unit,
rows: t.Unit,

/// Get center coords with offset options.
pub fn getCenter(self: *const Box, offset_col: t.Unit, offset_row: t.Unit, offset_type: t.OffsetType) t.UnitGroup {
    var point: t.UnitGroup = undefined;

    switch (offset_type) {
        .reduce => {
            point.col = self.cols / 2 - offset_col;
            point.row = self.rows / 2 - offset_row;
        },
        .add => {
            point.col = self.cols / 2 + offset_col;
            point.row = self.rows / 2 + offset_row;
        },
    }

    return point;
}

/// Get coords based on alignment enum.
pub fn getCoords(self: *const Box, h: t.HAlign, v: t.VAlign) t.UnitGroup {
    var point: t.UnitGroup = undefined;

    // TODO: THIS NEEDS TO ACCOUNT FOR COLLISION DETECTION (NOT OVERWRITING ON EXISTING DRAWING THERE).
    switch (v) {
        .top => point.row = self.origin.row,
        .bottom => point.row = self.rows - 1,
        .center => point.row = self.rows / 2,
    }
    switch (h) {
        .left => point.col = self.origin.col,
        .right => point.col = self.cols,
        .center => point.col = self.cols / 2,
    }

    return point;
}

pub fn new(rows: t.Unit, cols: t.Unit) Box {
    return .{ .size = .{ .cols = cols, .rows = rows } };
}
