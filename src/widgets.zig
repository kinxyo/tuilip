//! Widget Management
const Cell = @import("cell.zig");
const Text = @import("text.zig");

// NOT BEING USED RN.

// ===
pub const Widget = union(enum) {
    cell: Cell,
    text: Text,
};
