const r = @cImport(@cInclude("raylib.h"));

const Point = @import("point.zig").Point;
const Card = @import("card.zig").Card;

pub const CardState = struct {
    locus: Point,
    card: Card,
    direction: Direction,

    width: f32 = CARD_WIDTH,
    ratio: f32 = CARD_RATIO,

    pub const CARD_WIDTH = 60.0;
    pub const CARD_RATIO = 1.4;
    pub const CARD_HEIGHT = CARD_WIDTH * CARD_RATIO;
    pub const CARD_BACK_GUTTER = 6.0;
    pub const CARD_BACK_WIDTH = CARD_WIDTH - 2 * CARD_BACK_GUTTER;
    pub const CARD_BACK_HEIGHT = CARD_HEIGHT - 2 * CARD_BACK_GUTTER;

    const Direction = enum {
        facedown,
        faceup,
    };

    pub fn of(
        rank: Card.Rank,
        suit: Card.Suit,
        direction: Direction,
        locus: Point,
    ) CardState {
        return .{ .card = Card.of(rank, suit), .locus = locus, .direction = direction };
    }

    pub fn draw(card: CardState) void {
        const height = card.ratio * card.width;
        const offset = card.width * 0.05;

        const rect = .{ .x = card.locus.x, .y = card.locus.y, .width = card.width, .height = height };
        const shadowRect = .{ .x = card.locus.x + offset, .y = card.locus.y + offset, .width = card.width, .height = height };

        const color = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
        const shadowColor = .{ .a = 120, .r = 76, .g = 76, .b = 76 };

        const roundness = 0.25;
        const segments = 20;

        // Draw shadow
        r.DrawRectangleRounded(shadowRect, roundness, segments, shadowColor);

        // Draw body
        r.DrawRectangleRounded(rect, roundness, segments, color);

        // Conditionally draw card back
        switch (card.direction) {
            .facedown => {
                const backRect = .{ .x = card.locus.x + CARD_BACK_GUTTER, .y = card.locus.y + CARD_BACK_GUTTER, .width = CARD_BACK_WIDTH, .height = CARD_BACK_HEIGHT };
                const backColor = .{ .a = 200, .r = 220, .g = 50, .b = 50 };
                r.DrawRectangleRounded(backRect, 0.15, segments, backColor);
            },
            .faceup => {},
        }

        // TODO: draw outline
    }
};
