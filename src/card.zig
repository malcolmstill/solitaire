const std = @import("std");

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
        ten,
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
                .ten => 10,
                .jack => 11,
                .queen => 12,
                .king => 13,
            };
        }

        pub fn format(rank: Rank, writer: *std.Io.Writer) !void {
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
                .ten => "10",
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

        pub fn format(suit: Suit, writer: anytype) !void {
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

    pub fn format(card: Card, writer: *std.Io.Writer) !void {
        try writer.print("{f} {f}", .{ card.suit, card.rank });
    }
};

pub var CARDS: [52]Card = generateDeck();

fn generateDeck() [52]Card {
    const arr: [52]Card = undefined;

    for (std.meta.tags(Card.Suit)) |suit| {
        for (std.meta.tags(Card.Rank)) |rank| {
            arr.* = Card.of(suit, rank);
        }
    }

    return arr;
}

test "hash + eql" {
    const testing = std.testing;

    var map = std.AutoHashMap(Card, usize).init(testing.allocator);
    defer map.deinit();

    const card = Card.of(.ace, .hearts);
    try map.put(card, 22);

    try testing.expectEqual(22, map.get(card));
}
