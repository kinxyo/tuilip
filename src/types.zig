/// position
pub const Unit = u16;

/// Percentage unit for specifying position
pub const RelativePositionalUnit = f32;

/// character type (pixel size)
pub const Unicode = u21;

/// Orientation for `stackAll` fn.
pub const Orientation = enum {
    HORIZONTAL,
    VERTICAL,
};

/// Direction specifying for box/container.
pub const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

/// Direction specifying for box/container.
pub const Position = struct {
    top: RelativePositionalUnit,
    left: RelativePositionalUnit,
    // bottom: Unit,
    // right: Unit,
};

/// Foreground color enums (ansi codes)
pub const FG = enum(u8) {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,

    default = 39,

    bright_black = 90,
    bright_red = 91,
    bright_green = 92,
    bright_yellow = 93,
    bright_blue = 94,
    bright_magenta = 95,
    bright_cyan = 96,
    bright_white = 97,

    pub fn isSet(self: FG) bool {
        return self != .default;
    }
};

/// Background color enums (ansi codes)
pub const BG = enum(u8) {
    black = 40,
    red = 41,
    green = 42,
    yellow = 43,
    blue = 44,
    magenta = 45,
    cyan = 46,
    white = 47,

    default = 39,

    bright_black = 100,
    bright_red = 101,
    bright_green = 102,
    bright_yellow = 103,
    bright_blue = 104,
    bright_magenta = 105,
    bright_cyan = 106,
    bright_white = 107,

    pub fn isSet(self: BG) bool {
        return self != .default;
    }
};
