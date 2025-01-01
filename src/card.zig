const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");

const Point = @import("point.zig").Point;

pub const Card = struct {
    rank: Rank,
    suit: Suit,

    pub const Rank = enum {
        ace,
        two,
        three,
        four,
        five,
        six,
        seven,
        eight,
        nine,
        jack,
        queen,
        king,

        pub fn order(rank: Rank) u8 {
            return switch (rank) {
                .ace => 1,
                .two => 2,
                .three => 3,
                .four => 4,
                .five => 5,
                .six => 6,
                .seven => 7,
                .eight => 8,
                .nine => 9,
                .jack => 10,
                .queen => 11,
                .king => 12,
            };
        }

        pub fn format(rank: Rank, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;

            const symbol = switch (rank) {
                .ace => "A",
                .two => "2",
                .three => "3",
                .four => "4",
                .five => "5",
                .six => "6",
                .seven => "7",
                .eight => "8",
                .nine => "9",
                .jack => "J",
                .queen => "Q",
                .king => "K",
            };

            try writer.print("{s}", .{symbol});
        }
    };

    pub const Color = enum {
        black,
        red,
    };

    pub const Suit = enum {
        spades,
        hearts,
        diamonds,
        clubs,

        pub fn format(suit: Suit, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;

            const symbol = switch (suit) {
                .spades => "♠",
                .hearts => "♥",
                .diamonds => "♦",
                .clubs => "♣",
            };

            try writer.print("{s}", .{symbol});
        }
    };

    /// Make new card of rank and suit
    pub fn of(rank: Rank, suit: Suit) Card {
        return .{ .rank = rank, .suit = suit };
    }

    pub fn color(card: Card) Color {
        return switch (card.suit) {
            .spades => .black,
            .hearts => .red,
            .diamonds => .red,
            .clubs => .black,
        };
    }

    pub fn order(card: Card) u8 {
        return card.rank.order();
    }

    pub fn format(card: Card, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("{} {}", .{ card.suit, card.rank });
    }
};

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
