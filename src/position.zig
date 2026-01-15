pub const Unit = u16;
pub const Offset = i16;
pub const UnitGroup = struct { col: Unit, row: Unit };
pub const OffsetGroup = struct { col: Offset, row: Offset };
pub const OffsetType = enum { reduce, add };

pub const VAlign = enum { top, center, bottom };
pub const HAlign = enum { left, center, right };

pub const Size = struct {
    origin: UnitGroup = .{ .col = 0, .row = 0 },
    cols: Unit,
    rows: Unit,

    /// Get center coords with offset options.
    pub fn getCenter(self: *const Size, offset_col: Unit, offset_row: Unit, offset_type: OffsetType) UnitGroup {
        var point: UnitGroup = undefined;

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
    pub fn getCoords(self: *const Size, h: HAlign, v: VAlign) UnitGroup {
        var point: UnitGroup = undefined;

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
};
