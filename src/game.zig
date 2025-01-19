const r = @cImport(@cInclude("raylib.h"));

const std = @import("std");
const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const Direction = @import("direction.zig").Direction;

// We need some sort of game state that at a minimum tells
// us if we have a card in hand.
//
// Maybe it also needs to contain the board. And we need to distinguish
// I think from a a temporary change, i.e. picking up a card, with a complete
// move that changes the state of the board.
const GameState = struct {
    card_in_hand: ?CardInHand = null,
};

const CardInHand = struct {
    card: Card,
    source: Board.Source,
    initial_card_locus: Point,
    initial_mouse: Point,
};

pub const Game = struct {
    board: Board,
    history: std.ArrayList(Board),
    state: GameState,
    card_locations: CardLocations,
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

    pub fn init(allocator: std.mem.Allocator) !Game {
        var card_locations = CardLocations.init(allocator);

        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                try card_locations.set_location(Card.of(rank, suit), STOCK_LOCUS);
            }
        }

        return .{
            .board = try Game.deal(0, &card_locations),
            .history = std.ArrayList(Board).init(allocator),
            .state = .{},
            .card_locations = card_locations,
            .stack_locus = .{},
        };
    }

    pub fn deinit(game: *Game) void {
        game.history.deinit();
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

        var rnd = std.rand.DefaultPrng.init(seed);

        // Shuffle the deck
        std.Random.shuffle(rnd.random(), Card, board.stock.slice().cards);

        for (0..1) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_1_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

            board.row_1.push(card, .facedown);
        }
        for (0..2) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_2_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

            board.row_2.push(card, .facedown);
        }
        for (0..3) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_3_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

            board.row_3.push(card, .facedown);
        }
        for (0..4) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_4_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

            board.row_4.push(card, .facedown);
        }
        for (0..5) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_5_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

            board.row_5.push(card, .facedown);
        }
        for (0..6) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_6_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

            board.row_6.push(card, .facedown);
        }
        for (0..7) |i| {
            const card = board.stock.pop().card;
            const stack_locus = ROW_7_LOCUS;

            const locus: Point = .{ .x = stack_locus.x, .y = stack_locus.y + CARD_STACK_OFFSET * @as(f32, @floatFromInt(i)) };

            try card_locations.set_location(card, locus);

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

    pub fn render(game: *Game) void {
        game.renderStack("stock");
        game.renderStack("waste");

        // Rows
        game.renderStack("row_1");
        game.renderStack("row_2");
        game.renderStack("row_3");
        game.renderStack("row_4");
        game.renderStack("row_5");
        game.renderStack("row_6");
        game.renderStack("row_7");

        // Suit piles
        game.renderStack("spades");
        game.renderStack("hearts");
        game.renderStack("diamonds");
        game.renderStack("clubs");

        if (game.state.card_in_hand) |card_in_hand| {
            // card_in_hand.card.draw();
            game.renderCard(card_in_hand.card, .faceup);
        }
    }

    fn renderStack(game: *Game, comptime stack: []const u8) void {
        //
        const slice = @field(game.board, stack).slice();
        const stack_locus = @field(game.stack_locus, stack);

        {
            const offset = 0;

            const emptyRect = .{ .x = stack_locus.x + offset, .y = stack_locus.y + offset, .width = CARD_WIDTH, .height = CARD_HEIGHT };
            const emptyColour = .{ .a = 50, .r = 76, .g = 76, .b = 76 };

            const roundness = 0.25;
            const segments = 20;
            r.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
        }

        for (slice.cards, slice.directions) |card, direction| {
            game.renderCard(card, direction);
        }
    }

    pub fn renderCard(game: *Game, card: Card, direction: Direction) void {
        const locus = game.card_locations.get(card);

        const roundness = 0.25;
        const segments = 20;

        // Draw shadow
        {
            const offset = CARD_WIDTH * 0.05;
            const shadowRect = .{ .x = locus.x + offset, .y = locus.y + offset, .width = CARD_WIDTH, .height = CARD_HEIGHT };
            const shadowColor = .{ .a = 120, .r = 76, .g = 76, .b = 76 };
            r.DrawRectangleRounded(shadowRect, roundness, segments, shadowColor);
        }

        // TODO: draw outline
        {
            const rect = .{ .x = locus.x - CARD_STROKE, .y = locus.y - CARD_STROKE, .width = CARD_STROKE_WIDTH, .height = CARD_STROKE_HEIGHT };
            const outLineColor = .{ .a = 255, .r = 0, .g = 0, .b = 0 };
            r.DrawRectangleRounded(rect, roundness, segments, outLineColor);
        }

        // Draw body
        {
            const rect = .{ .x = locus.x, .y = locus.y, .width = CARD_WIDTH, .height = CARD_HEIGHT };
            const bodyColor = .{ .a = 255, .r = 255, .g = 255, .b = 255 };
            r.DrawRectangleRounded(rect, roundness, segments, bodyColor);
        }

        // Conditionally draw card back
        switch (direction) {
            .facedown => {
                const backRect = .{ .x = locus.x + CARD_BACK_GUTTER, .y = locus.y + CARD_BACK_GUTTER, .width = CARD_BACK_WIDTH, .height = CARD_BACK_HEIGHT };
                const backColor = .{ .a = 200, .r = 220, .g = 50, .b = 50 };
                r.DrawRectangleRounded(backRect, 0.15, segments, backColor);
            },
            .faceup => {},
        }
    }

    pub fn handleButtonDown(game: *Game, mouse_x: f32, mouse_y: f32) void {
        // If we have a card in hand our button was already done
        if (game.state.card_in_hand) |_| return;

        // Find card

        if (game.findCard(mouse_x, mouse_y)) |card_source| {
            const locus = game.card_locations.get(card_source.card);

            game.state.card_in_hand = .{
                .card = card_source.card,
                .source = card_source.source,
                .initial_card_locus = .{ .x = locus.x, .y = locus.y },
                .initial_mouse = .{ .x = mouse_x, .y = mouse_y },
            };
        }
    }

    pub fn handleButtonUp(game: *Game, x: f32, y: f32) !void {
        _ = x; // autofix
        _ = y; // autofix

        // If we have a card in our hand, place it where our
        // mouse is over, if the move is valid
        if (game.state.card_in_hand) |card_in_hand| {
            const card = card_in_hand.card;
            const dest = .spades; // FIXME: get destination from mouse position

            if (game.board.isMoveValid(card_in_hand.card, dest)) {
                //
            } else {
                const source = card_in_hand.source;

                game.board = switch (source) {
                    .waste => game.board.returnCard(card, .waste),
                    .row_1 => game.board.returnCard(card, .row_1),
                    .row_2 => game.board.returnCard(card, .row_2),
                    .row_3 => game.board.returnCard(card, .row_3),
                    .row_4 => game.board.returnCard(card, .row_4),
                    .row_5 => game.board.returnCard(card, .row_5),
                    .row_6 => game.board.returnCard(card, .row_6),
                    .row_7 => game.board.returnCard(card, .row_7),
                    .spades => game.board.returnCard(card, .spades),
                    .hearts => game.board.returnCard(card, .hearts),
                    .diamonds => game.board.returnCard(card, .diamonds),
                    .clubs => game.board.returnCard(card, .clubs),
                };

                try game.card_locations.set_location(card, card_in_hand.initial_card_locus);
                game.state.card_in_hand = null;
            }
        }
    }

    pub fn findCard(game: *Game, x: f32, y: f32) ?struct { card: Card, source: Board.Source } {
        std.debug.print("Todo find card ({}, {})\n", .{ x, y });

        if (game.board.row_1.peek()) |entry| {
            const locus = game.card_locations.get(entry.card);

            if (x < locus.x) return null;
            if (x > locus.x + CARD_WIDTH) return null;

            if (y < locus.y) return null;
            if (y > locus.y + CARD_HEIGHT) return null;

            std.debug.print("found card = {} in {}\n", .{ entry.card, .row_1 });

            return .{ .card = game.board.row_1.pop().card, .source = .row_1 };
        }

        return null;
    }

    pub fn handleMove(game: *Game, mouse_x: f32, mouse_y: f32) !void {
        if (game.state.card_in_hand) |card_in_hand| {
            const new_x = card_in_hand.initial_card_locus.x + mouse_x - card_in_hand.initial_mouse.x;
            const new_y = card_in_hand.initial_card_locus.y + mouse_y - card_in_hand.initial_mouse.y;

            try game.card_locations.set_location(card_in_hand.card, .{ .x = new_x, .y = new_y });
        }
    }
};

const CardLocations = struct {
    map: std.AutoHashMap(Card, Point),

    pub fn init(allocator: std.mem.Allocator) CardLocations {
        return .{ .map = std.AutoHashMap(Card, Point).init(allocator) };
    }

    pub fn deinit(card_locations: *CardLocations) void {
        card_locations.map.deinit();
    }

    pub fn get(card_locations: *CardLocations, card: Card) Point {
        return card_locations.map.get(card) orelse unreachable;
    }

    pub fn set_location(card_locations: *CardLocations, card: Card, locus: Point) !void {
        try card_locations.map.put(card, locus);
    }
};

const CARD_WIDTH = 60.0;
const CARD_RATIO = 1.4;
const CARD_HEIGHT = CARD_WIDTH * CARD_RATIO;
const CARD_BACK_GUTTER = 6.0;
const CARD_BACK_WIDTH = CARD_WIDTH - 2 * CARD_BACK_GUTTER;
const CARD_BACK_HEIGHT = CARD_HEIGHT - 2 * CARD_BACK_GUTTER;
const CARD_STROKE = 1.0;
const CARD_STROKE_WIDTH = CARD_WIDTH + 2.0 * CARD_STROKE;
const CARD_STROKE_HEIGHT = CARD_HEIGHT + 2.0 * CARD_STROKE;

pub const STOCK_LOCUS: Point = .{ .x = 20, .y = 20 };
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

pub const CARD_STACK_OFFSET = 12.0;
