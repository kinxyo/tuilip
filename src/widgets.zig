const std = @import("std");
const t = @import("types.zig");

pub const WidgetTreeError = error{
    MapNotInitialized,
    IdNotFound,
};

pub const WidgetList = struct {
    data: ?std.StringHashMap(t.Widget) = null,

    /// Returns pointer to the Box widget based on the provided Id.
    /// Will panic if no box found.
    pub fn getBox(self: *const WidgetList, id: []const u8) WidgetTreeError!*t.Box {
        var widget = try self.get(id);
        return &widget.box;
    }

    /// Returns pointer to the Box widget based on the provided Id.
    /// Will panic if no box found.
    pub fn getText(self: *const WidgetList, id: []const u8) WidgetTreeError!*t.Text {
        var widget = try self.get(id);
        return &widget.text;
    }

    /// Returns pointer to the widget based on the provided Id.
    fn get(self: *const WidgetList, id: []const u8) WidgetTreeError!*t.Widget {
        if (self.data) |*map| {
            if (map.getPtr(id)) |widget| {
                return widget;
            } else {
                return error.IdNotFound;
            }
        } else {
            return error.MapNotInitialized;
        }
    }

    /// Generic insert function for adding widget to box.
    pub fn add(
        self: *WidgetList,
        allocator: std.mem.Allocator,
        id: []const u8,
        child: t.Widget,
    ) !void {
        if (self.data) |*map| {
            try map.put(id, child);
            return;
        }

        self.data = .init(allocator);
        try self.data.?.put(id, child);
    }

    /// Trigger recursive call to destroy all children widgets.
    pub fn deinit(self: *WidgetList) void {
        if (self.data) |*map| {
            var iter = map.iterator();

            while (iter.next()) |entry| {
                switch (entry.value_ptr.*) {
                    .box => entry.value_ptr.box.deinit(), // triggers deinit for children,
                    .text => {},
                    // else => std.log.err("no such type found to deinit: {any}", .{@TypeOf(entry.value_ptr.*)}),
                }
            }
            map.deinit(); // destroys data (actual deinit happening!)
        }
    }
};
