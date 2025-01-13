const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");

const CardVisual = @import("card.zig").CardVisual;
const Game = @import("game.zig").Game;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    r.InitWindow(600, 400, "");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var game = Game.init(allocator);
    defer game.deinit();

    // Ideally we'd turn this on:
    //
    // r.EnableEventWaiting();
    //
    // This basically goes 100% to sleep until there is some event.
    //
    // Unfortunately, as it stands with the raylib library this does
    // not count a vsync as an event, nor does it, I believe, allow
    // for creating some timer that also counts as an event.
    //
    // Moreover, raylib only seems to allow querying what the current state
    // of inputs is, not really getting those events in some sort of queue.
    // Whilst I think it is possible to build that queue by doing a state
    // query and looking for changes to turn into events, the library does
    // not directly support this.
    //
    // I'm going to make an assertion: the most flexible API for a graphics
    // windowing library is one that provides an iterator to pull events
    // out of a queue. This puts all of the control into the consumer of the
    // library.
    //
    // Second assertion: it's likely possible on all platforms to get vsync
    // information and so that should be available as an event.
    //
    // So having written all this, we're just going to go with the busy
    // loop, because we're not trying to solve window libraries here.
    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.GRAY);

        const x = r.GetMousePosition().x;
        const y = r.GetMousePosition().y;
        game.handleMove(x, y);

        if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT)) {
            game.handleButtonDown(x, y);
        } else {
            game.handleButtonUp(x, y);
        }

        game.draw();
    }
}

test {
    _ = @import("card.zig");
    _ = @import("board.zig");
    _ = @import("point.zig");
    _ = @import("stack.zig");
}
