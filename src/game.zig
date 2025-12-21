// const r = @cImport(@cInclude("raylib.h"));

const std = @import("std");
const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;
const Stack = @import("stack.zig").Stack;
const Point = @import("point.zig").Point;
const Position = @import("card_locations.zig").Position;
const Direction = @import("direction.zig").Direction;
const CardLocations = @import("card_locations.zig").CardLocations;
const rndr = @import("render.zig");
const r = rndr.r;

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
    textures: std.AutoHashMap(Card, r.RenderTexture2D),
    texture_facedown: r.RenderTexture2D,
    card_locations: CardLocations,
    tex: r.struct_Texture,
    red_corner: r.struct_Texture,
    black_corner: r.struct_Texture,
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

        var card_locations = CardLocations.init(allocator, sloppy);

        const tex = r.LoadTexture("src/ace_club.png");

        const red_corner = r.LoadTexture("src/red.png");
        const black_corner = r.LoadTexture("src/black.png");

        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                try card_locations.setLocation(Card.of(rank, suit), STOCK_LOCUS);
            }
        }

        var textures = std.AutoHashMap(Card, r.RenderTexture2D).init(allocator);
        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                const card = Card.of(rank, suit);
                const texture = rndr.prerenderCard(card, red_corner, black_corner);

                try textures.put(card, texture);
            }
        }

        const texture_facedown = rndr.prerenderFacedownCard();

        return .{
            .debug = debug,
            .sloppy = sloppy,
            .board = try Game.deal(seed, &card_locations),
            .history = std.ArrayList(Board){},
            .state = .{},
            .card_locations = card_locations,
            .textures = textures,
            .texture_facedown = texture_facedown,
            .tex = tex,
            .red_corner = red_corner,
            .black_corner = black_corner,
            .stack_locus = .{},
        };
    }

    pub fn deinit(game: *Game, allocator: std.mem.Allocator) void {
        game.history.deinit(allocator);
        game.card_locations.deinit();
    }

    fn deal(seed: u64, card_locations: *CardLocations) !Board {
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

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

            board.row_1.push(card, .facedown);
        }
        for (0..2) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_2_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

            board.row_2.push(card, .facedown);
        }
        for (0..3) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_3_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

            board.row_3.push(card, .facedown);
        }
        for (0..4) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_4_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

            board.row_4.push(card, .facedown);
        }
        for (0..5) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_5_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

            board.row_5.push(card, .facedown);
        }
        for (0..6) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_6_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

            board.row_6.push(card, .facedown);
        }
        for (0..7) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_7_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.setLocation(card, locus);

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

    pub fn update(game: *Game, card: Card, dest: Board.Destination) !void {
        const old_board = game.board;
        const board = old_board.move(card, dest);

        try game.history.append(old_board);

        game.board = board;
    }

    pub fn render(game: *Game, dt: f32) void {
        game.renderStack("stock", dt);
        game.renderStack("waste", dt);

        // Rows
        game.renderStack("row_1", dt);
        game.renderStack("row_2", dt);
        game.renderStack("row_3", dt);
        game.renderStack("row_4", dt);
        game.renderStack("row_5", dt);
        game.renderStack("row_6", dt);
        game.renderStack("row_7", dt);

        // Suit piles
        game.renderStack("spades", dt);
        game.renderStack("hearts", dt);
        game.renderStack("diamonds", dt);
        game.renderStack("clubs", dt);

        // Debug draw dest
        if (game.debug) {
            if (game.state.cards_in_hand) |in_hand| {
                if (game.findDropDest()) |dst| {
                    const stack_locus = dst.locus;
                    const offset = 0;

                    const emptyRect: r.Rectangle = .{
                        .x = stack_locus.x + offset,
                        .y = stack_locus.y + offset,
                        .width = rndr.CARD_WIDTH,
                        .height = rndr.CARD_HEIGHT,
                    };

                    const emptyColour: r.Color = if (game.board.isMoveValid(in_hand.stack, dst.dest))
                        .{
                            .a = 50,
                            .r = 0,
                            .g = 176,
                            .b = 0,
                        }
                    else
                        .{
                            .a = 70,
                            .r = 176,
                            .g = 176,
                            .b = 0,
                        };

                    const roundness = 0.25;
                    const segments = 20;

                    r.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
                }
            }
        }

        if (game.state.cards_in_hand) |*cards_in_hand| {
            // card_in_hand.card.draw();
            for (cards_in_hand.stack.slice()) |entry| {
                game.renderCard(entry.card, entry.direction, dt);
            }
        }
    }

    fn renderStack(game: *Game, comptime stack: []const u8, dt: f32) void {
        //
        const slice = @field(game.board, stack).slice();
        const stack_locus = @field(game.stack_locus, stack);

        // Draw "empty" pile
        {
            const offset = 0;

            const emptyRect: r.Rectangle = .{
                .x = stack_locus.x + offset,
                .y = stack_locus.y + offset,
                .width = rndr.CARD_WIDTH,
                .height = rndr.CARD_HEIGHT,
            };

            const emptyColour: r.Color = .{
                .a = 50,
                .r = 76,
                .g = 76,
                .b = 76,
            };

            const roundness = 0.25;
            const segments = 20;

            r.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
        }

        // Draw the cards
        for (slice) |entry| {
            game.renderCard(entry.card, entry.direction, dt);
        }
    }

    pub fn renderCard(game: *Game, card: Card, direction: Direction, dt: f32) void {
        const position = game.card_locations.update(card, dt);
        const locus = position.locus;

        const target: r.RenderTexture2D = switch (direction) {
            .faceup => game.textures.get(card) orelse unreachable,
            .facedown => game.texture_facedown,
        };

        r.DrawTexturePro(
            target.texture,
            r.Rectangle{
                .x = 0,
                .y = 0,
                .width = @floatFromInt(target.texture.width),
                .height = @floatFromInt(-target.texture.height),
            },
            r.Rectangle{
                .x = locus.x - rndr.CARD_STROKE + @as(f32, @floatFromInt(target.texture.width)) / 2.0,
                .y = locus.y - rndr.CARD_STROKE + @as(f32, @floatFromInt(target.texture.height)) / 2.0,
                .width = @floatFromInt(target.texture.width),
                .height = @floatFromInt(target.texture.height),
            },
            r.Vector2{
                .x = @as(f32, @floatFromInt(target.texture.width)) / 2.0,
                .y = @as(f32, @floatFromInt(target.texture.height)) / 2.0,
            },
            position.angle,
            r.WHITE,
        );
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
                try game.card_locations.setLocation(entry.card, locus);
            } else {
                while (game.board.waste.popOrNull()) |entry| {
                    game.board.stock.push(entry.card, .facedown);

                    const stack_locus = game.stack_locus.stock;

                    const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y };
                    try game.card_locations.setLocation(entry.card, locus);
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
            const locus = game.card_locations.get(card_source.stack.array[0].card).current();

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

                        try game.card_locations.startAnimation(entry.card, locus);
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
                try game.card_locations.startAnimation(entry.card, locus);
            }

            game.state.cards_in_hand = null;
        }
    }

    pub fn stockClicked(game: *Game, mouse_x: f32, mouse_y: f32) bool {
        const locus = game.stack_locus.stock;

        if (mouse_x < locus.x) return false;
        if (mouse_x > locus.x + rndr.CARD_WIDTH) return false;
        if (mouse_y < locus.y) return false;
        if (mouse_y > locus.y + rndr.CARD_HEIGHT) return false;

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
            const card_locus = game.card_locations.get(in_hand.stack.array[0].card).current();
            const pointer: Point = .{
                .x = card_locus.x + rndr.CARD_WIDTH / 2,
                .y = card_locus.y + rndr.CARD_HEIGHT / 2,
            };

            const count = stack.size();

            const locus: Point = if (stack.peek()) |top| game.card_locations.get(top.card).current() else stack_locus;

            if (pointer.x > locus.x and pointer.x < locus.x + rndr.CARD_WIDTH) {
                if (pointer.y > locus.y and pointer.y < locus.y + rndr.CARD_HEIGHT) {
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
                const locus = game.card_locations.get(entry.card).current();

                if (entry.direction == .facedown) {
                    if (x > locus.x and x < locus.x + rndr.CARD_WIDTH) {
                        if (y > locus.y and y < locus.y + rndr.CARD_HEIGHT) {
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
                const locus = game.card_locations.get(entry.card).current();

                if (entry.direction == .faceup) {
                    if (x > locus.x and x < locus.x + rndr.CARD_WIDTH) {
                        if (y > locus.y and y < locus.y + rndr.CARD_HEIGHT) {
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
                try game.card_locations.setLocation(entry.card, .{ .x = new_x, .y = new_y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) });
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

pub const STOCK_LOCUS: Point = .{ .x = 20, .y = 20 };
pub const WASTE_LOCUS: Point = .{ .x = 90, .y = 20 };

const ROW_Y = 120;
const HORIZONTAL_PADDING = 10;

fn stack_x(comptime i: f64) f64 {
    return 2 * HORIZONTAL_PADDING + i * (rndr.CARD_WIDTH + HORIZONTAL_PADDING);
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
