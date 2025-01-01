const r = @cImport(@cInclude("raylib.h"));

const Point = @import("point.zig").Point;

pub const CardVisual = struct {
    locus: Point,
    width: f32 = 60.0,
    ratio: f32 = 1.4,

    pub fn draw(card: CardVisual) void {
        const height = card.ratio * card.width;
        const offset = card.width * 0.05;

        const rect = .{ .x = card.locus.x, .y = card.locus.y, .width = card.width, .height = height };
        const shadowRect = .{ .x = card.locus.x + offset, .y = card.locus.y + offset, .width = card.width, .height = height };

        const color = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
        const shadowColor = .{ .a = 120, .r = 76, .g = 76, .b = 76 };

        const roundness = 0.25;
        const segments = 20;

        r.DrawRectangleRounded(shadowRect, roundness, segments, shadowColor);
        r.DrawRectangleRounded(rect, roundness, segments, color);
    }
};
