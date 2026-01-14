pub const Unit = u16;
pub const Origin = struct { col: Unit, row: Unit };
pub const Offset = i16;
pub const Delta = struct { col: Offset, row: Offset };
pub const Size = struct {
    lx: Unit = 0,
    ly: Unit = 0,
    ux: Unit,
    uy: Unit,

    // TODO
    // pub fn getCenter() void {}
    // pub fn nearestLeft(bb: []Cell) void {}
    // etc...
};
