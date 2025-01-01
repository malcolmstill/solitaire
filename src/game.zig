const std = @import("std");
const Board = @import("board.zig").Board;
const Card = @import("card.zig").Card;

const Game = struct {
    board: Board,
    history: std.ArrayList(Board),

    pub fn init(allocator: std.mem.Allocator) Game {
        return .{
            .board = Board.deal(),
            .history = std.ArrayList(Board).init(allocator),
        };
    }

    pub fn update(game: *Game, card: Card, dest: Board.Destination) !void {
        const old_board = game.board;
        const board = old_board.move(card, dest);

        try game.history.append(old_board);

        game.board = board;
    }
};
