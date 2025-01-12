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
        for (game.board.stock.slice()) |card| {
            card.draw();
        }

        for (game.board.waste.slice()) |card| {
            card.draw();
        }

        // Rows
        for (game.board.row_1.slice()) |card| {
            card.draw();
        }

        for (game.board.row_2.slice()) |card| {
            card.draw();
        }

        for (game.board.row_3.slice()) |card| {
            card.draw();
        }

        for (game.board.row_4.slice()) |card| {
            card.draw();
        }

        for (game.board.row_5.slice()) |card| {
            card.draw();
        }

        for (game.board.row_6.slice()) |card| {
            card.draw();
        }

        for (game.board.row_7.slice()) |card| {
            card.draw();
        }

        // Suit piles
        for (game.board.spades.slice()) |card| {
            card.draw();
        }

        for (game.board.hearts.slice()) |card| {
            card.draw();
        }

        for (game.board.diamonds.slice()) |card| {
            card.draw();
        }

        for (game.board.clubs.slice()) |card| {
            card.draw();
        }
    }
};
