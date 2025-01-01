const std = @import("std");
const Card = @import("card.zig").Card;
const Stack = @import("stack.zig").Stack;

const Board = struct {
    stock: Stack(52) = .{},
    waste: Stack(24) = .{},

    row_1: Stack(12) = .{},
    row_2: Stack(12) = .{},
    row_3: Stack(12) = .{},
    row_4: Stack(12) = .{},
    row_5: Stack(12) = .{},
    row_6: Stack(12) = .{},
    row_7: Stack(12) = .{},

    spades: Stack(12) = .{},
    hearts: Stack(12) = .{},
    diamonds: Stack(12) = .{},
    clubs: Stack(12) = .{},

    pub const Source = enum {
        waste,
        row_1,
        row_2,
        row_3,
        row_4,
        row_5,
        row_6,
        row_7,
        spades,
        hearts,
        diamonds,
        clubs,
    };

    pub const Destination = enum {
        row_1,
        row_2,
        row_3,
        row_4,
        row_5,
        row_6,
        row_7,
        spades,
        hearts,
        diamonds,
        clubs,
    };

    pub fn deal(seed: u64) Board {
        var board: Board = .{};

        // Generate deck
        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                board.stock.push(Card.of(rank, suit));
            }
        }

        var rnd = std.rand.DefaultPrng.init(seed);

        // Shuffle the deck
        std.Random.shuffle(rnd.random(), Card, board.stock.slice());

        for (0..1) |_| board.row_1.push(board.stock.pop());
        for (0..2) |_| board.row_2.push(board.stock.pop());
        for (0..3) |_| board.row_3.push(board.stock.pop());
        for (0..4) |_| board.row_4.push(board.stock.pop());
        for (0..5) |_| board.row_5.push(board.stock.pop());
        for (0..6) |_| board.row_6.push(board.stock.pop());
        for (0..7) |_| board.row_7.push(board.stock.pop());

        return board;
    }

    /// Return the card on top of place (without popping)
    fn peekSource(board: *Board, source: Source) ?Card {
        return switch (source) {
            .waste => board.waste.peek(),
            .row_1 => board.row_1.peek(),
            .row_2 => board.row_2.peek(),
            .row_3 => board.row_3.peek(),
            .row_4 => board.row_4.peek(),
            .row_5 => board.row_5.peek(),
            .row_6 => board.row_6.peek(),
            .row_7 => board.row_7.peek(),
            .spades => board.spades.peek(),
            .hearts => board.hearts.peek(),
            .diamonds => board.diamonds.peek(),
            .clubs => board.clubs.peek(),
        };
    }

    fn peekDestination(board: *Board, destination: Destination) ?Card {
        return switch (destination) {
            .row_1 => board.row_1.peek(),
            .row_2 => board.row_2.peek(),
            .row_3 => board.row_3.peek(),
            .row_4 => board.row_4.peek(),
            .row_5 => board.row_5.peek(),
            .row_6 => board.row_6.peek(),
            .row_7 => board.row_7.peek(),
            .spades => board.spades.peek(),
            .hearts => board.hearts.peek(),
            .diamonds => board.diamonds.peek(),
            .clubs => board.clubs.peek(),
        };
    }

    /// Check if move is valid
    ///
    /// Panics if `from` is empty.
    pub fn isMoveValid(board: *Board, move: struct { from: Source, to: Destination }) bool {
        const from = board.peekSource(move.from) orelse unreachable;
        const maybe_to = board.peekDestination(move.to);

        switch (move.to) {
            .row_1, .row_2, .row_3, .row_4, .row_5, .row_6, .row_7 => {
                if (maybe_to) |to| {
                    // We can place our from card on the to row stack if the colours are different and
                    // the from card is one less than the row stack top
                    if (to.color() != from.color() and from.order() == to.order() - 1) return true;
                } else {
                    // We can move a king onto a blank row stack
                    if (from.rank == .king) return true;
                }

                return false;
            },
            .spades,
            .hearts,
            .diamonds,
            .clubs,
            => {
                const dest_suit: Card.Suit = switch (move.to) {
                    .spades => .spades,
                    .hearts => .hearts,
                    .diamonds => .diamonds,
                    .clubs => .clubs,
                    else => unreachable,
                };

                if (maybe_to) |to| {
                    // Our stack is blank, we only allow ace
                    if (from.suit == dest_suit and from.order() == to.order() - 1) return true;
                } else {
                    // Our stack is blank, we only allow ace
                    if (from.suit == dest_suit and from.rank == .ace) return true;
                }

                return false;
            },
        }
    }

    pub fn format(board: Board, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("board:\n", .{});
        try writer.print("stock: {}\n", .{board.stock});
        try writer.print("waste: {}\n", .{board.waste});
        try writer.print("\n", .{});

        try writer.print("row 1: {}\n", .{board.row_1});
        try writer.print("row 2: {}\n", .{board.row_2});
        try writer.print("row 3: {}\n", .{board.row_3});
        try writer.print("row 4: {}\n", .{board.row_4});
        try writer.print("row 5: {}\n", .{board.row_5});
        try writer.print("row 6: {}\n", .{board.row_6});
        try writer.print("row 7: {}\n", .{board.row_7});
        try writer.print("\n", .{});

        try writer.print("spades: {}\n", .{board.spades});
        try writer.print("hearts: {}\n", .{board.hearts});
        try writer.print("diamonds: {}\n", .{board.diamonds});
        try writer.print("clubs: {}\n", .{board.clubs});
    }
};

test "Board" {
    var board = Board.deal(std.crypto.random.int(u64));

    board.waste.push(Card.of(.ace, .hearts));
    board.waste.push(Card.of(.ace, .spades));

    std.debug.print("board = {any}\n", .{board});

    try std.testing.expectEqual(true, board.isMoveValid(.{ .from = .waste, .to = .spades }));
    try std.testing.expectEqual(false, board.isMoveValid(.{ .from = .waste, .to = .hearts }));
    try std.testing.expectEqual(false, board.isMoveValid(.{ .from = .waste, .to = .diamonds }));
    try std.testing.expectEqual(false, board.isMoveValid(.{ .from = .waste, .to = .clubs }));
}
