pub const r = @cImport(@cInclude("raylib.h"));

const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;
const Stack = @import("stack.zig").Stack;
const Point = @import("point.zig").Point;
const Position = @import("card_locations.zig").Position;
const Direction = @import("direction.zig").Direction;
const CardLocations = @import("card_locations.zig").CardLocations;

pub const CARD_WIDTH = 60.0;
pub const CARD_HEIGHT = CARD_WIDTH * CARD_RATIO;
pub const CARD_STROKE = 1.0;

const CARD_RATIO = 1.4;
const CARD_BACK_GUTTER = 6.0;
const CARD_BACK_WIDTH = CARD_WIDTH - 2 * CARD_BACK_GUTTER;
const CARD_BACK_HEIGHT = CARD_HEIGHT - 2 * CARD_BACK_GUTTER;
const CARD_STROKE_WIDTH = CARD_WIDTH + 2.0 * CARD_STROKE;
const CARD_STROKE_HEIGHT = CARD_HEIGHT + 2.0 * CARD_STROKE;

pub fn prerenderCard(card: Card, red_corner: r.Texture, black_corner: r.Texture) r.RenderTexture2D {
    const target: r.RenderTexture2D = r.LoadRenderTexture(CARD_STROKE_WIDTH, CARD_STROKE_HEIGHT);

    const roundness = 0.25;
    const segments = 20;

    r.BeginTextureMode(target);
    defer r.EndTextureMode();

    r.ClearBackground(r.Color{ .a = 0.0, .r = 0.0, .b = 0.0, .g = 0.0 });

    // Draw outline
    {
        const rect: r.Rectangle = .{ .x = 0.0, .y = 0.0, .width = CARD_STROKE_WIDTH, .height = CARD_STROKE_HEIGHT };
        const outLineColor: r.Color = .{ .a = 255, .r = 0, .g = 0, .b = 0 };
        r.DrawRectangleRounded(rect, roundness, segments, outLineColor);
    }

    // Draw body
    {
        const rect: r.Rectangle = .{ .x = CARD_STROKE, .y = CARD_STROKE, .width = CARD_WIDTH, .height = CARD_HEIGHT };
        const bodyColor: r.Color = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
        r.DrawRectangleRounded(rect, roundness, segments, bodyColor);
    }

    prerenderDrawCornerRank(card, red_corner, black_corner);
    prerenderDrawCornerSuit(card, red_corner, black_corner);

    return target;
}

pub fn prerenderFacedownCard() r.RenderTexture2D {
    const target: r.RenderTexture2D = r.LoadRenderTexture(CARD_STROKE_WIDTH, CARD_STROKE_HEIGHT);

    const roundness = 0.25;
    const segments = 20;

    r.BeginTextureMode(target);
    defer r.EndTextureMode();

    r.ClearBackground(r.Color{ .a = 0.0, .r = 0.0, .b = 0.0, .g = 0.0 });

    {
        const rect: r.Rectangle = .{ .x = 0.0, .y = 0.0, .width = CARD_STROKE_WIDTH, .height = CARD_STROKE_HEIGHT };
        const outLineColor: r.Color = .{ .a = 255, .r = 0, .g = 0, .b = 0 };
        r.DrawRectangleRounded(rect, roundness, segments, outLineColor);
    }

    // Draw body
    {
        const rect: r.Rectangle = .{ .x = CARD_STROKE, .y = CARD_STROKE, .width = CARD_WIDTH, .height = CARD_HEIGHT };
        const bodyColor: r.Color = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
        r.DrawRectangleRounded(rect, roundness, segments, bodyColor);
    }

    {
        const backRect: r.Rectangle = .{ .x = CARD_STROKE + CARD_BACK_GUTTER, .y = CARD_STROKE + CARD_BACK_GUTTER, .width = CARD_BACK_WIDTH, .height = CARD_BACK_HEIGHT };
        const backColor: r.Color = .{ .a = 255, .r = 225, .g = 95, .b = 95 };
        r.DrawRectangleRounded(backRect, 0.15, segments, backColor);
    }

    return target;
}

fn prerenderDrawCornerRank(card: Card, red_corner: r.Texture, black_corner: r.Texture) void {
    const sprite_width = 12.0;

    const tex = switch (card.suit) {
        .hearts, .diamonds => red_corner,
        .spades, .clubs => black_corner,
    };

    const suit_index: struct { x: f32, y: f32 } = switch (card.rank) {
        .ace => .{ .x = 0, .y = 0 },
        .two => .{ .x = 2, .y = 0 },
        .three => .{ .x = 3, .y = 0 },
        .four => .{ .x = 0, .y = 1 },
        .five => .{ .x = 1, .y = 1 },
        .six => .{ .x = 2, .y = 1 },
        .seven => .{ .x = 3, .y = 1 },
        .eight => .{ .x = 0, .y = 2 },
        .nine => .{ .x = 1, .y = 2 },
        .ten => .{ .x = 2, .y = 2 },
        .jack => .{ .x = 3, .y = 2 },
        .queen => .{ .x = 0, .y = 3 },
        .king => .{ .x = 1, .y = 3 },
    };

    const src: r.Rectangle = .{
        .x = suit_index.x * sprite_width,
        .y = suit_index.y * sprite_width,
        .width = sprite_width,
        .height = sprite_width,
    };

    const top_left: r.Rectangle = .{ .x = CARD_STROKE, .y = CARD_STROKE + 2.0, .width = 12.0, .height = 12.0 };
    const top_right: r.Rectangle = .{ .x = CARD_STROKE + CARD_WIDTH - 13.0, .y = CARD_STROKE + 2.0, .width = 12.0, .height = 12.0 };
    const bottom_left: r.Rectangle = .{ .x = CARD_STROKE + 13.0, .y = CARD_STROKE + CARD_HEIGHT - 2.0, .width = 12.0, .height = 12.0 };
    const bottom_right: r.Rectangle = .{ .x = CARD_STROKE + CARD_WIDTH, .y = CARD_STROKE + CARD_HEIGHT - 2.0, .width = 12.0, .height = 12.0 };

    r.DrawTexturePro(tex, src, top_left, .{ .x = 0.0, .y = 0.0 }, 0.0, r.WHITE);
    r.DrawTexturePro(tex, src, top_right, .{ .x = 0.0, .y = 0.0 }, 0.0, r.WHITE);
    r.DrawTexturePro(tex, src, bottom_left, .{ .x = 0.0, .y = 0.0 }, 180.0, r.WHITE);
    r.DrawTexturePro(tex, src, bottom_right, .{ .x = 0.0, .y = 0.0 }, 180.0, r.WHITE);
}

fn prerenderDrawCornerSuit(card: Card, red_corner: r.Texture, black_corner: r.Texture) void {
    const sprite_width = 12.0;

    const tex = switch (card.suit) {
        .hearts, .diamonds => red_corner,
        .spades, .clubs => black_corner,
    };

    const suit_index: struct { x: f32, y: f32 } = switch (card.suit) {
        .hearts, .clubs => .{ .x = 3, .y = 3 },
        .diamonds, .spades => .{ .x = 2, .y = 3 },
    };

    const src: r.Rectangle = .{
        .x = suit_index.x * sprite_width,
        .y = suit_index.y * sprite_width,
        .width = sprite_width,
        .height = sprite_width,
    };

    const top_left: r.Rectangle = .{ .x = CARD_STROKE, .y = CARD_STROKE + sprite_width + 2.0, .width = sprite_width, .height = sprite_width };
    const top_right: r.Rectangle = .{ .x = CARD_STROKE + CARD_WIDTH - sprite_width - 1.0, .y = CARD_STROKE + sprite_width + 2.0, .width = sprite_width, .height = sprite_width };
    const bottom_left: r.Rectangle = .{ .x = CARD_STROKE + sprite_width + 1.0, .y = CARD_STROKE + CARD_HEIGHT - sprite_width - 2.0, .width = sprite_width, .height = sprite_width };
    const bottom_right: r.Rectangle = .{ .x = CARD_STROKE + CARD_WIDTH, .y = CARD_STROKE + CARD_HEIGHT - sprite_width - 2.0, .width = sprite_width, .height = sprite_width };

    r.DrawTexturePro(tex, src, top_left, .{ .x = 0.0, .y = 0.0 }, 0.0, r.WHITE);
    r.DrawTexturePro(tex, src, top_right, .{ .x = 0.0, .y = 0.0 }, 0.0, r.WHITE);
    r.DrawTexturePro(tex, src, bottom_left, .{ .x = 0.0, .y = 0.0 }, 180.0, r.WHITE);
    r.DrawTexturePro(tex, src, bottom_right, .{ .x = 0.0, .y = 0.0 }, 180.0, r.WHITE);
}
