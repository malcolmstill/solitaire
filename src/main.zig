const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const Game = @import("game.zig").Game;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var debug = false;
    var sloppy = false;
    var seed = std.crypto.random.int(u64);

    var expect_next_seed = false;
    var args = std.process.args();
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--debug")) {
            debug = true;
        }

        if (std.mem.eql(u8, arg, "--seed")) {
            expect_next_seed = true;
        } else if (expect_next_seed) {
            seed = try std.fmt.parseInt(u64, arg, 10);
            expect_next_seed = false;
        }

        if (std.mem.eql(u8, arg, "--sloppy")) {
            sloppy = true;
        }
    }

    if (expect_next_seed) {
        @panic("Expected integer seed");
    }

    r.InitWindow(600, 400, "");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var game = try Game.init(allocator, seed, sloppy, debug);
    defer game.deinit(allocator);

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
        defer {
            r.EndDrawing();

            // Wait as long as we can to try for same-frame input latency
            // TODO: check if this makes sense...I think we want that delay
            // but we don't want to actually sleep. Rather we'd do some
            // epoll stuff.
            // const delay = 0.60 * r.GetFrameTime() * 1000.0 * 1000.0 * 1000.0;
            // std.Thread.sleep(@intFromFloat(delay));
        }

        r.ClearBackground(r.GRAY);

        const x = r.GetMousePosition().x;
        const y = r.GetMousePosition().y;
        try game.handleMove(x, y);

        if (r.IsMouseButtonPressed(r.MOUSE_BUTTON_LEFT)) {
            try game.handleButtonDown(x, y);
        }

        if (r.IsMouseButtonReleased(r.MOUSE_BUTTON_LEFT)) {
            try game.handleButtonUp();
        }

        game.assert_consistent();

        const dt = r.GetFrameTime();

        game.update(dt);

        game.draw();
    }
}

test {
    _ = @import("card.zig");
    _ = @import("card_locations.zig");
    _ = @import("board.zig");
    _ = @import("maths.zig");
    _ = @import("point.zig");
    _ = @import("stack.zig");
}
