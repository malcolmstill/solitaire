const r = @cImport(@cInclude("raylib.h"));

pub fn main() !void {
    r.InitWindow(600, 400, "");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.GRAY);

        drawCard(40.0, 40.0);
    }
}

fn drawCard(x: f32, y: f32) void {
    const width = 100.0;
    const height = 140.0;
    const offset = 5.0;

    const rect = .{ .x = x, .y = y, .width = width, .height = height };
    const shadowRect = .{ .x = x + offset, .y = y + offset, .width = width, .height = height };

    const color = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
    const shadowColor = .{ .a = 120, .r = 76, .g = 76, .b = 76 };

    const roundness = 0.25;
    const segments = 20;

    r.DrawRectangleRounded(shadowRect, roundness, segments, shadowColor);
    r.DrawRectangleRounded(rect, roundness, segments, color);
}
