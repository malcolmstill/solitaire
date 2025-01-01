const r = @cImport(@cInclude("raylib.h"));

pub fn main() !void {
    r.InitWindow(600, 400, "");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.GRAY);
    }
}
