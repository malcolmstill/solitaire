const std = @import("std");
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const CardState = @import("card_state.zig").CardState;
const Stack = @import("stack.zig").Stack;

pub const STOCK_LOCUS: Point = .{ .x = 20, .y = 20 };
pub const WASTE_LOCUS: Point = .{ .x = 90, .y = 20 };

const ROW_Y = 120;
const HORIZONTAL_PADDING = 10;
const CARD_WIDTH = 60;

fn stack_x(comptime i: f64) f64 {
    return 2 * HORIZONTAL_PADDING + i * (CARD_WIDTH + HORIZONTAL_PADDING);
}

pub const ROW_1_LOCUS: Point = .{ .x = stack_x(0), .y = ROW_Y };
pub const ROW_2_LOCUS: Point = .{ .x = stack_x(1), .y = ROW_Y };
pub const ROW_3_LOCUS: Point = .{ .x = stack_x(2), .y = ROW_Y };
pub const ROW_4_LOCUS: Point = .{ .x = stack_x(3), .y = ROW_Y };
pub const ROW_5_LOCUS: Point = .{ .x = stack_x(4), .y = ROW_Y };
pub const ROW_6_LOCUS: Point = .{ .x = stack_x(5), .y = ROW_Y };
pub const ROW_7_LOCUS: Point = .{ .x = stack_x(6), .y = ROW_Y };

pub const SPADES_LOCUS: Point = .{ .x = stack_x(4), .y = 20 };
pub const HEARTS_LOCUS: Point = .{ .x = stack_x(5), .y = 20 };
pub const DIAMONDS_LOCUS: Point = .{ .x = stack_x(6), .y = 20 };
pub const CLUBS_LOCUS: Point = .{ .x = stack_x(7), .y = 20 };

pub const CARD_STACK_OFFSET = 8.0;

pub const Board = struct {
    stock: Stack(52) = .{ .locus = STOCK_LOCUS },
    waste: Stack(24) = .{ .locus = WASTE_LOCUS },

    row_1: Stack(12) = .{ .locus = ROW_1_LOCUS, .card_index_offset = CARD_STACK_OFFSET },
    row_2: Stack(12) = .{ .locus = ROW_2_LOCUS, .card_index_offset = CARD_STACK_OFFSET },
    row_3: Stack(12) = .{ .locus = ROW_3_LOCUS, .card_index_offset = CARD_STACK_OFFSET },
    row_4: Stack(12) = .{ .locus = ROW_4_LOCUS, .card_index_offset = CARD_STACK_OFFSET },
    row_5: Stack(12) = .{ .locus = ROW_5_LOCUS, .card_index_offset = CARD_STACK_OFFSET },
    row_6: Stack(12) = .{ .locus = ROW_6_LOCUS, .card_index_offset = CARD_STACK_OFFSET },
    row_7: Stack(12) = .{ .locus = ROW_7_LOCUS, .card_index_offset = CARD_STACK_OFFSET },

    spades: Stack(12) = .{ .locus = SPADES_LOCUS },
    hearts: Stack(12) = .{ .locus = HEARTS_LOCUS },
    diamonds: Stack(12) = .{ .locus = DIAMONDS_LOCUS },
    clubs: Stack(12) = .{ .locus = CLUBS_LOCUS },

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
                board.stock.push(CardState.of(rank, suit, .facedown, .{ .x = 20, .y = 20 }));
            }
        }

        var rnd = std.rand.DefaultPrng.init(seed);

        // Shuffle the deck
        std.Random.shuffle(rnd.random(), CardState, board.stock.slice());

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

    fn peekDestination(board: Board, destination: Destination) ?Card {
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

    pub fn move(board: Board, card: Card, dest: Destination) !Board {
        if (!board.isMoveValid(card, dest)) return error.InvalidMove;

        var new_board = board;

        // TODO: reinstate this
        // defer std.debug.assert(new_board.count() == 54);

        switch (dest) {
            .row_1 => new_board.row_1.push(card),
            .row_2 => new_board.row_2.push(card),
            .row_3 => new_board.row_3.push(card),
            .row_4 => new_board.row_4.push(card),
            .row_5 => new_board.row_5.push(card),
            .row_6 => new_board.row_6.push(card),
            .row_7 => new_board.row_7.push(card),
            .spades => new_board.spades.push(card),
            .hearts => new_board.hearts.push(card),
            .diamonds => new_board.diamonds.push(card),
            .clubs => new_board.clubs.push(card),
        }

        return new_board;
    }

    /// Check if move is valid
    ///
    /// Panics if `from` is empty.
    pub fn isMoveValid(board: Board, card: Card, dest: Destination) bool {
        const dest_top = board.peekDestination(dest);

        switch (dest) {
            .row_1, .row_2, .row_3, .row_4, .row_5, .row_6, .row_7 => {
                if (dest_top) |top| {
                    // We can place our from card on the to row stack if the colours are different and
                    // the from card is one less than the row stack top
                    if (top.color() != card.color() and card.order() == top.order() - 1) return true;
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
                    if (card.suit == dest_suit and card.order() == to.order() - 1) return true;
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

        n += board.stock.count();
        n += board.waste.count();

        n += board.row_1.count();
        n += board.row_2.count();
        n += board.row_3.count();
        n += board.row_4.count();
        n += board.row_5.count();
        n += board.row_6.count();
        n += board.row_7.count();

        n += board.spades.count();
        n += board.hearts.count();
        n += board.diamonds.count();
        n += board.clubs.count();

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

test "Board" {
    var board = Board.deal(std.crypto.random.int(u64));

    board.waste.push(Card.of(.ace, .hearts));
    board.waste.push(Card.of(.ace, .spades));

    std.debug.print("board = {any}\n", .{board});

    try std.testing.expectEqual(true, board.isMoveValid(Card.of(.ace, .spades), .spades));
    try std.testing.expectEqual(false, board.isMoveValid(Card.of(.ace, .hearts), .spades));

    const new_board = board.move(Card.of(.ace, .spades), .spades);
    std.debug.print("new board = {any}\n", .{new_board});
}
