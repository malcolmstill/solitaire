const std = @import("std");
const Card = @import("card.zig").Card;

pub fn Stack(comptime N: u16) type {
    return struct {
        stack_array: [N]Card = undefined,
        position: u8 = 0,

        const Self = @This();

        pub fn push(stack: *Self, card: Card) void {
            defer stack.position += 1;

            stack.stack_array[stack.position] = card;
        }

        pub fn pop(stack: *Self) Card {
            defer stack.position -= 1;

            return stack.stack_array[stack.position - 1];
        }

        pub fn peek(stack: Self) ?Card {
            if (stack.position == 0) return null;

            return stack.stack_array[stack.position - 1];
        }

        pub fn slice(stack: *Self) []Card {
            return stack.stack_array[0..stack.position];
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
            for (stack.stack_array[0..stack.position], 0..) |card, i| {
                if (i > 0) try writer.print(", ", .{});

                try writer.print("{}", .{card});
            }
            try writer.print("]", .{});
        }
    };
}

test {
    var stack: Stack(3) = .{};

    stack.push(Card.of(.ace, .spades));
}
