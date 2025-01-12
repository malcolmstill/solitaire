const std = @import("std");
const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;

pub const Game = struct {
    board: Board,
    history: std.ArrayList(Board),

    pub fn init(allocator: std.mem.Allocator) Game {
        return .{
            .board = Board.deal(0),
            .history = std.ArrayList(Board).init(allocator),
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
