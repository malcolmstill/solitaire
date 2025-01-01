const r = @cImport(@cInclude("raylib.h"));

const CardVisual = @import("card.zig").CardVisual;

pub fn main() !void {
    r.InitWindow(600, 400, "");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.GRAY);

        const card: CardVisual = .{
            .locus = .{
                .x = 40.0,
                .y = 40.0,
            },
        };

        card.draw();
    }
}

test {
    _ = @import("card.zig");
    _ = @import("board.zig");
    _ = @import("point.zig");
    _ = @import("stack.zig");
}
