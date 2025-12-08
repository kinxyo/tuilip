/// position
pub const Unit = u16;

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
