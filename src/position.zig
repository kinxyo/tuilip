pub const Unit = u16;
pub const Offset = i16;
pub const UnitGroup = struct { col: Unit, row: Unit };
pub const OffsetGroup = struct { col: Offset, row: Offset };
const OffsetType = enum { reduce, add };

pub const Align = enum {
    TopLeft,
    TopCenter,
    TopRight,
    BottomLeft,
    BottomCenter,
    BottomRight,
};

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
                point.col = self.cols / 2 - offset_col;
                point.row = self.rows / 2 - offset_row;
            },
        }

        return point;
    }

    // TODO
    // pub fn nearestLeft(bb: []Cell) void {}
    // etc...
};
