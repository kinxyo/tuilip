# Tuilip

TUI library/framework in Zig.

---

## Example usage:

```zig
const std = @import("std");
const tui = @import("tuilip");

const SIZE = 1024 * 4;

pub fn main() !void {
    //  BOILER PLATE
    // ...

    // APP LOGIC
    var world = cv.createBox(allocator, 10, 20, .center, .center);
    defer world.deinit();

    const character = try world.addBox(
        "char",
        .{ .height = 2, .width = 2 },
        .{ .row = 1, .col = 1 },
    );

    // RENDER LOOP
    while (true) {
        cv.clearScreen();
        try cv.onScreen(world, .draw);

        cv.render();
        if (try poll_events(&cv, character)) break;
    }
}

// EVENTS
fn poll_events(cv: *tui.Canvas, character: *tui.Box) !bool {
    const key = try cv.fmt.reader.takeByte();
    if (key == 'q') return true;
    if (key == 'w') character.origin.row -= 1;
    if (key == 'a') character.origin.col -= 1;
    if (key == 's') character.origin.row += 1;
    if (key == 'd') character.origin.col += 1;
    return false;
}
```

## Learnt:

- [x] Setting terminal flags
- [x] Buffer management
- [x] Implemented double buffer prototype.
- [x] Event loops (including input handling)
- [x] Creating a controllable and movable string
- [x] Drawing lines and rectangle (and width is 2 * length);
- [x] Clearing only the dynamic part
- [x] Animations (sliding on both axis)
- [x] Architecture for such a library
- [x] Stacking Logic (for both axis)
- [x] Relative positioning of child elements of a box/container.
- [ ] Creating Grid
- [ ] Moving an item on the grid.
- [ ] Calculating spaces
- [ ] Creating `wordle` game in one of the demos.
- [ ] Finish layout engine.
- [ ] Merge Layout/Grid struct to Canvas.
