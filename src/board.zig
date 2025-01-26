const std = @import("std");
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const Stack = @import("stack.zig").Stack;
const Direction = @import("direction.zig").Direction;

pub const Board = struct {
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

    fn peekDestination(board: Board, destination: Destination) ?Stack(12).StackEntry {
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

    pub fn move(board: *Board, card: Card, dest: Destination) !void {
        if (!board.isMoveValid(card, dest)) return error.InvalidMove;

        switch (dest) {
            .row_1 => board.row_1.push(card, .faceup),
            .row_2 => board.row_2.push(card, .faceup),
            .row_3 => board.row_3.push(card, .faceup),
            .row_4 => board.row_4.push(card, .faceup),
            .row_5 => board.row_5.push(card, .faceup),
            .row_6 => board.row_6.push(card, .faceup),
            .row_7 => board.row_7.push(card, .faceup),
            .spades => board.spades.push(card, .faceup),
            .hearts => board.hearts.push(card, .faceup),
            .diamonds => board.diamonds.push(card, .faceup),
            .clubs => board.clubs.push(card, .faceup),
        }

        // return new_board;
    }

    // Return a card to its source where a move is invalid
    pub fn returnCard(board: *Board, card: Card, src: Source) void {
        switch (src) {
            .waste => board.waste.push(card, .faceup),
            .row_1 => board.row_1.push(card, .faceup),
            .row_2 => board.row_2.push(card, .faceup),
            .row_3 => board.row_3.push(card, .faceup),
            .row_4 => board.row_4.push(card, .faceup),
            .row_5 => board.row_5.push(card, .faceup),
            .row_6 => board.row_6.push(card, .faceup),
            .row_7 => board.row_7.push(card, .faceup),
            .spades => board.spades.push(card, .faceup),
            .hearts => board.hearts.push(card, .faceup),
            .diamonds => board.diamonds.push(card, .faceup),
            .clubs => board.clubs.push(card, .faceup),
        }

        // return new_board;
    }

    /// Check if move is valid
    ///
    /// Panics if `from` is empty.
    ///
    /// I think this needs to take into account faceupedness / facedownedness
    pub fn isMoveValid(board: Board, card: Card, dest: Destination) bool {
        const dest_top = board.peekDestination(dest);
        std.debug.print("isMoveValid: {}, {}, dest top = {any}", .{ card, dest, dest_top });

        switch (dest) {
            .row_1, .row_2, .row_3, .row_4, .row_5, .row_6, .row_7 => {
                if (dest_top) |top| {
                    // We can place our from card on the to row stack if the colours are different and
                    // the from card is one less than the row stack top
                    if (top.card.color() != card.color() and card.order() == top.card.order() - 1) return true;
                } else {
                    // We can move a king onto a blank row stack
                    if (card.rank == .king) return true;
                }

                return false;
            },
            .spades,
            .hearts,
            .diamonds,
            .clubs,
            => {
                const dest_suit: Card.Suit = switch (dest) {
                    .spades => .spades,
                    .hearts => .hearts,
                    .diamonds => .diamonds,
                    .clubs => .clubs,
                    else => unreachable,
                };

                if (dest_top) |to| {
                    // Our stack is blank, we only allow ace
                    if (card.suit == dest_suit and card.order() == to.card.order() + 1) return true;
                } else {
                    // Our stack is blank, we only allow ace
                    if (card.suit == dest_suit and card.rank == .ace) return true;
                }

                return false;
            },
        }
    }

    /// Return number of cards on board
    pub fn count(board: Board) usize {
        var n: usize = 0;

        n += board.stock.size();
        n += board.waste.size();

        n += board.row_1.size();
        n += board.row_2.size();
        n += board.row_3.size();
        n += board.row_4.size();
        n += board.row_5.size();
        n += board.row_6.size();
        n += board.row_7.size();

        n += board.spades.size();
        n += board.hearts.size();
        n += board.diamonds.size();
        n += board.clubs.size();

        return n;
    }

    pub fn format(board: Board, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("board ({} cards):\n", .{board.count()});
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
