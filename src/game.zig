const std = @import("std");
const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;
const CardState = @import("card_state.zig").CardState;

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
    card: CardState,
    initial_x: f32,
    initial_y: f32,
    initial_mouse_x: f32,
    initial_mouse_y: f32,
};

pub const Game = struct {
    board: Board,
    history: std.ArrayList(Board),
    state: GameState,

    pub fn init(allocator: std.mem.Allocator) Game {
        return .{
            .board = Board.deal(0),
            .history = std.ArrayList(Board).init(allocator),
            .state = .{},
        };
    }

    pub fn deinit(game: *Game) void {
        game.history.deinit();
    }

    pub fn update(game: *Game, card: Card, dest: Board.Destination) !void {
        const old_board = game.board;
        const board = old_board.move(card, dest);

        try game.history.append(old_board);

        game.board = board;
    }

    pub fn draw(game: *Game) void {
        game.board.stock.draw();

        game.board.waste.draw();

        // Rows
        game.board.row_1.draw();
        game.board.row_2.draw();
        game.board.row_3.draw();
        game.board.row_4.draw();
        game.board.row_5.draw();
        game.board.row_6.draw();
        game.board.row_7.draw();

        // Suit piles
        game.board.spades.draw();
        game.board.hearts.draw();
        game.board.diamonds.draw();
        game.board.clubs.draw();

        if (game.state.card_in_hand) |card_in_hand| {
            card_in_hand.card.draw();
        }
    }

    pub fn handleButtonDown(game: *Game, x: f32, y: f32) void {
        // If we have a card in hand our button was already done
        if (game.state.card_in_hand) |_| return;

        // Find card

        if (game.findCard(x, y)) |card| {
            game.state.card_in_hand = .{
                .card = card,
                .initial_x = card.locus.x,
                .initial_y = card.locus.y,
                .initial_mouse_x = x,
                .initial_mouse_y = y,
            };
        }
    }

    pub fn handleButtonUp(game: *Game, x: f32, y: f32) void {
        _ = x; // autofix
        _ = y; // autofix

        // If we have a card in our hand, place it where our
        // mouse is over, if the move is valid
        if (game.state.card_in_hand) |card_in_hand| {
            const dest = undefined;

            if (game.board.isMoveValid(card_in_hand.card, dest)) {
                //
            } else {
                //
            }
        }
    }

    pub fn findCard(game: *Game, x: f32, y: f32) ?CardState {
        std.debug.print("Todo find card ({}, {})\n", .{ x, y });

        if (game.board.row_1.peek()) |card| {
            if (x < card.locus.x) return null;
            if (x > card.locus.x + CardState.CARD_WIDTH) return null;

            if (y < card.locus.y) return null;
            if (y > card.locus.y + CardState.CARD_HEIGHT) return null;

            std.debug.print("found card = {}\n", .{card.card});

            return game.board.row_1.pop();
        }

        return null;
    }

    pub fn handleMove(game: *Game, mouse_x: f32, mouse_y: f32) void {
        if (game.state.card_in_hand) |*card_in_hand| {
            card_in_hand.card.locus.x = card_in_hand.initial_x + mouse_x - card_in_hand.initial_mouse_x;
            card_in_hand.card.locus.y = card_in_hand.initial_y + mouse_y - card_in_hand.initial_mouse_y;
        }
    }
};
