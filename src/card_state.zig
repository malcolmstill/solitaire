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
    pub const CARD_STROKE = 1.0;
    pub const CARD_STROKE_WIDTH = CARD_WIDTH + 2.0 * CARD_STROKE;
    pub const CARD_STROKE_HEIGHT = CARD_HEIGHT + 2.0 * CARD_STROKE;

    const Direction = enum {
        facedown,
        faceup,

        pub fn flip(direction: Direction) Direction {
            return switch (direction) {
                .facedown => .faceup,
                .faceup => .facedown,
            };
        }
    };

    pub fn of(
        rnk: Card.Rank,
        sut: Card.Suit,
        direction: Direction,
        locus: Point,
    ) CardState {
        return .{ .card = Card.of(rnk, sut), .locus = locus, .direction = direction };
    }

    pub fn color(card: CardState) Card.Color {
        return card.card.color();
    }

    pub fn order(card: CardState) u8 {
        return card.card.order();
    }

    pub fn rank(card: CardState) Card.Rank {
        return card.card.rank;
    }

    pub fn suit(card: CardState) Card.Suit {
        return card.card.suit;
    }

    pub fn draw(card: CardState) void {
        const height = card.ratio * card.width;

        const roundness = 0.25;
        const segments = 20;

        // Draw shadow
        {
            const offset = card.width * 0.05;
            const shadowRect = .{ .x = card.locus.x + offset, .y = card.locus.y + offset, .width = card.width, .height = height };
            const shadowColor = .{ .a = 120, .r = 76, .g = 76, .b = 76 };
            r.DrawRectangleRounded(shadowRect, roundness, segments, shadowColor);
        }

        // TODO: draw outline
        {
            const rect = .{ .x = card.locus.x - CARD_STROKE, .y = card.locus.y - CARD_STROKE, .width = CARD_STROKE_WIDTH, .height = CARD_STROKE_HEIGHT };
            const outLineColor = .{ .a = 255, .r = 0, .g = 0, .b = 0 };
            r.DrawRectangleRounded(rect, roundness, segments, outLineColor);
        }

        // Draw body
        {
            const rect = .{ .x = card.locus.x, .y = card.locus.y, .width = card.width, .height = height };
            const bodyColor = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
            r.DrawRectangleRounded(rect, roundness, segments, bodyColor);
        }

        // Conditionally draw card back
        switch (card.direction) {
            .facedown => {
                const backRect = .{ .x = card.locus.x + CARD_BACK_GUTTER, .y = card.locus.y + CARD_BACK_GUTTER, .width = CARD_BACK_WIDTH, .height = CARD_BACK_HEIGHT };
                const backColor = .{ .a = 200, .r = 220, .g = 50, .b = 50 };
                r.DrawRectangleRounded(backRect, 0.15, segments, backColor);
            },
            .faceup => {},
        }
    }
};
