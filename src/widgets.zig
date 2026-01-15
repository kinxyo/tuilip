//! Widget Management
const Cell = @import("cell.zig");
const Text = @import("text.zig");
const Box = @import("box.zig");

// NOT BEING USED RN.

const Widget = @This();

// ===
const WidgetTypes = union(enum) {
    cell: Cell,
    text: Text,
    box: Box,
};

// ~~ Widget Interface ~~

// len() int
