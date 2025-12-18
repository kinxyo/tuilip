// const t = @import("types.zig");
// const cv = @import("canvas.zig");

// /// Container (Div element)
// pub const Div = struct {
//     row: t.Unit,
//     col: t.Unit,
//     length: t.Unit = 1,
//     breadth: t.Unit = 1,
//     zindex: usize = 1,

//     /// Container (Equvialent to `Div` element from html).
//     pub fn new(row: t.Unit, col: t.Unit, length: t.Unit, breadth: t.Unit) !Div {
//         const box: Div = .{ .row = row, .col = col, .length = length, .breadth = breadth };
//         for (box.row..(box.row + box.length)) |y| {
//             for (box.col..(box.col + box.breadth)) |x| {
//                 var is_border: bool = false;
//                 if (y == box.row) is_border = true;
//                 if (y == (box.row + box.length - 1)) is_border = true;
//                 if (x == box.col) is_border = true;
//                 if (x == (box.col + box.breadth - 1)) is_border = true;

//                 if (is_border) {
//                     try cv.draw(x, y, '.');
//                 }
//             }
//         }
//         return box;
//     }

//     pub fn insert(self: *Div) void {
//         _ = self;
//         return void;
//     }
// };
