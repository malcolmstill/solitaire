const std = @import("std");
const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;
const Stack = @import("stack.zig").Stack;
const Point = @import("point.zig").Point;
const Position = @import("card_locations.zig").Position;
const Direction = @import("direction.zig").Direction;
const CardLocations = @import("card_locations.zig").CardLocations;
const CARD_WIDTH = @import("geom.zig").CARD_WIDTH;
const CARD_HEIGHT = @import("geom.zig").CARD_HEIGHT;
const CARD_STROKE = @import("geom.zig").CARD_STROKE;
const STOCK_LOCUS = @import("geom.zig").STOCK_LOCUS;
const Renderer = @import("render.zig").Renderer;
const renderDebug = @import("render.zig").renderDebug;
const renderEmpty = @import("render.zig").renderEmpty;

// We need some sort of game state that at a minimum tells
// us if we have a card in hand.
//
// Maybe it also needs to contain the board. And we need to distinguish
// I think from a a temporary change, i.e. picking up a card, with a complete
// move that changes the state of the board.
const GameState = struct {
    cards_in_hand: ?CardsInHand = null,
};

const CardsInHand = struct {
    stack: Stack(24),
    source: Board.Source,
    initial_card_locus: Point,
    initial_mouse: Point,
};

pub const Game = struct {
    debug: bool,
    // With sloppy mode cards dropped may have some slight random rotation / offset
    sloppy: bool,
    board: Board,
    history: std.ArrayList(Board),
    state: GameState,
    locations: CardLocations,
    renderer: Renderer,
    stack_locus: struct {
        stock: Point = STOCK_LOCUS,
        waste: Point = WASTE_LOCUS,
        row_1: Point = ROW_1_LOCUS,
        row_2: Point = ROW_2_LOCUS,
        row_3: Point = ROW_3_LOCUS,
        row_4: Point = ROW_4_LOCUS,
        row_5: Point = ROW_5_LOCUS,
        row_6: Point = ROW_6_LOCUS,
        row_7: Point = ROW_7_LOCUS,
        spades: Point = SPADES_LOCUS,
        hearts: Point = HEARTS_LOCUS,
        diamonds: Point = DIAMONDS_LOCUS,
        clubs: Point = CLUBS_LOCUS,
    },

    pub fn init(allocator: std.mem.Allocator, seed: u64, sloppy: bool, debug: bool) !Game {
        std.debug.print("Initialising game with seed {}\n", .{seed});

        var locations = CardLocations.init(allocator, sloppy);

        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                try locations.set(Card.of(rank, suit), STOCK_LOCUS);
            }
        }

        const renderer = try Renderer.init();

        return .{
            .debug = debug,
            .sloppy = sloppy,
            .board = try Game.deal(seed, &locations),
            .renderer = renderer,
            .history = std.ArrayList(Board){},
            .state = .{},
            .locations = locations,
            .stack_locus = .{},
        };
    }

    pub fn deinit(game: *Game, allocator: std.mem.Allocator) void {
        game.history.deinit(allocator);
        game.locations.deinit();
    }

    fn deal(seed: u64, locations: *CardLocations) !Board {
        var board: Board = .{};

        // Generate deck
        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                board.stock.push(Card.of(rank, suit), .facedown);
            }
        }

        var rnd = std.Random.DefaultPrng.init(seed);

        // Shuffle the deck
        std.Random.shuffle(rnd.random(), Stack(52).StackEntry, board.stock.slice());

        for (0..1) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_1_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_1.push(card, .facedown);
        }
        for (0..2) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_2_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_2.push(card, .facedown);
        }
        for (0..3) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_3_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_3.push(card, .facedown);
        }
        for (0..4) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_4_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_4.push(card, .facedown);
        }
        for (0..5) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_5_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_5.push(card, .facedown);
        }
        for (0..6) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_6_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_6.push(card, .facedown);
        }
        for (0..7) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_7_LOCUS;

            const locus: Point = .{
                .x = stack_locus.x,
                .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)),
            };

            try locations.set(card, locus);

            board.row_7.push(card, .facedown);
        }

        board.row_1.flipTop();
        board.row_2.flipTop();
        board.row_3.flipTop();
        board.row_4.flipTop();
        board.row_5.flipTop();
        board.row_6.flipTop();
        board.row_7.flipTop();

        return board;
    }

    pub fn draw(game: *Game) void {
        game.drawStack("stock");
        game.drawStack("waste");

        // Rows
        game.drawStack("row_1");
        game.drawStack("row_2");
        game.drawStack("row_3");
        game.drawStack("row_4");
        game.drawStack("row_5");
        game.drawStack("row_6");
        game.drawStack("row_7");

        // Suit piles
        game.drawStack("spades");
        game.drawStack("hearts");
        game.drawStack("diamonds");
        game.drawStack("clubs");

        // Debug draw dest
        if (game.debug) {
            if (game.state.cards_in_hand) |in_hand| {
                if (game.findDropDest()) |dst| {
                    renderDebug(dst.locus, game.board.isMoveValid(in_hand.stack, dst.dest));
                }
            }
        }

        if (game.state.cards_in_hand) |*cards_in_hand| {
            // card_in_hand.card.draw();
            for (cards_in_hand.stack.slice()) |entry| {
                game.drawCard(entry.card, entry.direction);
            }
        }
    }

    fn drawStack(game: *Game, comptime stack: []const u8) void {
        //
        const slice = @field(game.board, stack).slice();
        const stack_locus = @field(game.stack_locus, stack);

        // Draw "empty" pile
        renderEmpty(stack_locus);

        // Draw the cards
        for (slice) |entry| {
            game.drawCard(entry.card, entry.direction);
        }
    }

    pub fn drawCard(game: *Game, card: Card, direction: Direction) void {
        const position = game.locations.get(card).currentWithRot();

        game.renderer.renderCard(card, position, direction);
    }

    /// Update the game state based upon dt
    ///
    /// At the moment this only updates card positions for animation
    pub fn update(game: *Game, dt: f32) void {
        var it = game.locations.iterator();

        while (it.next()) |entry| {
            const card = entry.key_ptr.*;
            _ = game.locations.update(card, dt);
        }
    }

    pub fn handleButtonDown(game: *Game, mouse_x: f32, mouse_y: f32) !void {
        // If we have a card in hand our button was already done
        if (game.state.cards_in_hand) |_| return;

        // If we click on the stock, deal from it
        if (game.stockClicked(mouse_x, mouse_y)) {
            if (game.board.stock.size() > 0) {
                const entry = game.board.stock.pop();
                game.board.waste.push(entry.card, .faceup);

                const stack_locus = game.stack_locus.waste;

                const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y };

                try game.locations.set(entry.card, locus);
            } else {
                while (game.board.waste.popOrNull()) |entry| {
                    game.board.stock.push(entry.card, .facedown);

                    const stack_locus = game.stack_locus.stock;

                    const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y };

                    try game.locations.set(entry.card, locus);
                }
            }

            return;
        }

        // Check if we are flipping a card
        if (game.findCardToFlip(mouse_x, mouse_y)) {
            return;
        }

        // Otherwise try and pick up one or more face up cards
        if (game.findCardsToPickUp(mouse_x, mouse_y)) |card_source| {
            const locus = game.locations.get(card_source.stack.array[0].card).current();

            game.state.cards_in_hand = .{
                .stack = card_source.stack,
                .source = card_source.source,
                .initial_card_locus = .{ .x = locus.x, .y = locus.y },
                .initial_mouse = .{ .x = mouse_x, .y = mouse_y },
            };
        }
    }

    pub fn handleButtonUp(game: *Game) !void {
        // If we have a card in our hand, place it where our
        // mouse is over, if the move is valid
        if (game.state.cards_in_hand) |cards_in_hand| {
            const in_hand_stack = cards_in_hand.stack;

            const dest = game.findDropDest();

            // For a move to be valid we must be over some destiantion
            // and the move must otherwise be valid. If both of these
            // conditions are met we move the cards and empty our hand.
            if (dest) |dst| {
                if (game.board.isMoveValid(in_hand_stack, dst.dest)) {
                    try game.board.move(in_hand_stack, dst.dest);

                    const offset: f32 = switch (dst.dest) {
                        .spades, .hearts, .diamonds, .clubs => 0.0,
                        else => CARD_STACK_OFFSET,
                    };

                    // If we're placing on an empty destination we need to correct
                    // the shift that we otherwise get from offset.
                    const empty = if (dst.count == 0) offset else 0.0;

                    var it = in_hand_stack.forwardIterator();
                    var i: usize = 1;
                    while (it.next()) |entry| {
                        defer i += 1;

                        // Shift each card down a little
                        var locus = dst.locus;
                        locus.y = locus.y + offset * @as(f32, @floatFromInt(i)) - empty;

                        try game.locations.startAnimation(entry.card, locus);
                    }

                    game.state.cards_in_hand = null;

                    return;
                }
            } else {
                std.debug.print("No destination...returning cards", .{});
            }

            // Otherwise the move was not valid and the cards are returned to
            // their source.
            const source = cards_in_hand.source;

            game.board.returnCards(in_hand_stack, source);

            // Put cards back in correct location
            var it = in_hand_stack.forwardIterator();
            var i: usize = 0;
            while (it.next()) |entry| {
                defer i += 1;
                var locus = cards_in_hand.initial_card_locus;
                locus.y += CARD_STACK_OFFSET * @as(f32, @floatFromInt(i));
                try game.locations.startAnimation(entry.card, locus);
            }

            game.state.cards_in_hand = null;
        }
    }

    pub fn stockClicked(game: *Game, mouse_x: f32, mouse_y: f32) bool {
        const locus = game.stack_locus.stock;

        if (mouse_x < locus.x) return false;
        if (mouse_x > locus.x + CARD_WIDTH) return false;
        if (mouse_y < locus.y) return false;
        if (mouse_y > locus.y + CARD_HEIGHT) return false;

        return true;
    }

    /// Get destination over which we may drop if such a destination exists.
    ///
    /// Panics if no cards in hand (caller must ensure only called with cards in hand)
    ///
    /// Returns (optionally):
    /// - destination tag, e.g. .aces, .row1 etc
    /// - the (stack) locus
    /// - count of cards in the destination stack
    pub fn findDropDest(game: *Game) ?struct { dest: Board.Destination, locus: Point, count: usize } {
        const in_hand = game.state.cards_in_hand orelse @panic("findDropDest only makes sense with cards in hand");

        // Look at each valid destination pile (everything but stock and waste)
        inline for (comptime std.meta.tags(Board.Destination)) |dst| {
            const stack_locus: Point = @field(game.stack_locus, @tagName(dst));
            const stack: Stack(24) = @field(game.board, @tagName(dst));

            // Use centre of card to decide if enough card is covering destination
            const card_locus = game.locations.get(in_hand.stack.array[0].card).current();
            const pointer: Point = .{
                .x = card_locus.x + CARD_WIDTH / 2,
                .y = card_locus.y + CARD_HEIGHT / 2,
            };

            const count = stack.size();

            const locus: Point = if (stack.peek()) |top| game.locations.get(top.card).current() else stack_locus;

            if (pointer.x > locus.x and pointer.x < locus.x + CARD_WIDTH) {
                if (pointer.y > locus.y and pointer.y < locus.y + CARD_HEIGHT) {
                    return .{ .dest = dst, .locus = locus, .count = count };
                }
            }
        }

        return null;
    }

    /// Find facedown card that we've clicked on and flip it
    ///
    /// Returns true if such a card was found otherwise returns false
    pub fn findCardToFlip(game: *Game, x: f32, y: f32) bool {
        inline for (comptime std.meta.tags(Board.Rows)) |src| {
            var it = @field(game.board, @tagName(src)).iterator();

            if (it.next()) |entry| {
                const locus = game.locations.get(entry.card).current();

                if (entry.direction == .facedown) {
                    if (x > locus.x and x < locus.x + CARD_WIDTH) {
                        if (y > locus.y and y < locus.y + CARD_HEIGHT) {
                            @field(game.board, @tagName(src)).flipTop();

                            return true;
                        }
                    }
                }
            }
        }

        return false;
    }

    // FIXME: we need to check to more than just the top of a stack, as we need to be able to move
    //        more than one card at a time.
    /// Find card under cusror
    pub fn findCardsToPickUp(game: *Game, x: f32, y: f32) ?struct { stack: Stack(24), source: Board.Source } {
        inline for (comptime std.meta.tags(Board.Source)) |src| {
            var it = @field(game.board, @tagName(src)).iterator();

            var i: u8 = 0;
            while (it.next()) |entry| {
                defer i += 1;
                const locus = game.locations.get(entry.card).current();

                if (entry.direction == .faceup) {
                    if (x > locus.x and x < locus.x + CARD_WIDTH) {
                        if (y > locus.y and y < locus.y + CARD_HEIGHT) {
                            std.debug.print("found card = {f} in {t}\n", .{ entry.card, src });

                            defer std.debug.print("board = {f}\n", .{game.board});

                            const picked_stack = @field(game.board, @tagName(src)).take(i + 1);
                            defer std.debug.print("picked_stack = {f}\n", .{picked_stack});

                            return .{ .stack = picked_stack, .source = src };
                        }
                    }
                }
            }
        }

        return null;
    }

    pub fn handleMove(game: *Game, mouse_x: f32, mouse_y: f32) !void {
        if (game.state.cards_in_hand) |*cards_in_hand| {
            const new_x = cards_in_hand.initial_card_locus.x + mouse_x - cards_in_hand.initial_mouse.x;
            const new_y = cards_in_hand.initial_card_locus.y + mouse_y - cards_in_hand.initial_mouse.y;

            for (cards_in_hand.stack.slice(), 0..) |entry, i| {
                try game.locations.set(entry.card, .{ .x = new_x, .y = new_y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) });
            }
        }
    }

    /// Check the game is in a consistent state
    pub fn assert_consistent(game: *Game) void {
        // Count all cards
        const in_hand = if (game.state.cards_in_hand) |in_hand| in_hand.stack.size() else 0;

        std.debug.assert(in_hand + game.board.count() == 52);

        // TODO: all face up cards in rows must alternate red / black and be plus-one of card beneath
        // TODO: all cards in ace, hearts, spades, clubs piles are same suit and are ascending order
    }
};

pub const WASTE_LOCUS: Point = .{ .x = 90, .y = 20 };

const ROW_Y = 120;
const HORIZONTAL_PADDING = 10;

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

pub const CARD_STACK_OFFSET = 16.0;
