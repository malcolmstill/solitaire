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
    card_in_hand: ?CardState = null,
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
    }
};
