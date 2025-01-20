const std = @import("std");

const r = @cImport(@cInclude("raylib.h"));

const Point = @import("point.zig").Point;
const Card = @import("card.zig").Card;
const Direction = @import("direction.zig").Direction;

pub fn Stack(comptime N: u16) type {
    return struct {
        card_array: [N]Card = undefined,
        direction_array: [N]Direction = undefined,
        position: u8 = 0,

        pub const StackEntry = struct { card: Card, direction: Direction };

        const Self = @This();

        pub fn push(stack: *Self, card: Card, direction: Direction) void {
            defer stack.position += 1;

            stack.card_array[stack.position] = card;
            stack.direction_array[stack.position] = direction;
        }

        pub fn pop(stack: *Self) StackEntry {
            defer stack.position -= 1;

            const card = stack.card_array[stack.position - 1];
            const direction = stack.direction_array[stack.position - 1];

            return .{ .card = card, .direction = direction };
        }

        pub fn peek(stack: Self) ?StackEntry {
            if (stack.position == 0) return null;

            const card = stack.card_array[stack.position - 1];
            const direction = stack.direction_array[stack.position - 1];

            return .{ .card = card, .direction = direction };
        }

        pub fn flipTop(stack: *Self) void {
            std.debug.assert(stack.position > 0);

            const new_direction = stack.direction_array[stack.position - 1].flip();

            stack.direction_array[stack.position - 1] = new_direction;
        }

        pub fn slice(stack: *Self) struct { cards: []Card, directions: []Direction } {
            const cards = stack.card_array[0..stack.position];
            const directions = stack.direction_array[0..stack.position];

            return .{ .cards = cards, .directions = directions };
        }

        pub fn count(stack: Self) usize {
            return stack.position;
        }

        pub fn format(
            stack: Self,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;

            try writer.print("[", .{});
            for (stack.card_array[0..stack.position], 0..) |card_state, i| {
                if (i > 0) try writer.print(", ", .{});

                try writer.print("{}", .{card_state});
            }
            try writer.print("]", .{});
        }
    };
}

test {
    var stack: Stack(3) = .{};

    stack.push(Card.of(.ace, .spades), .faceup);
}
