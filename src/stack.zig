const std = @import("std");

const Point = @import("point.zig").Point;
const Card = @import("card.zig").Card;
const Direction = @import("direction.zig").Direction;

pub fn Stack(comptime N: u16) type {
    return struct {
        card_array: [N]Card = undefined,
        direction_array: [N]Direction = undefined,
        count: u8 = 0,

        pub const StackEntry = struct { card: Card, direction: Direction };

        const Self = @This();

        pub fn push(stack: *Self, card: Card, direction: Direction) void {
            defer stack.count += 1;

            stack.card_array[stack.count] = card;
            stack.direction_array[stack.count] = direction;
        }

        pub fn pop(stack: *Self) StackEntry {
            defer stack.count -= 1;

            const card = stack.card_array[stack.count - 1];
            const direction = stack.direction_array[stack.count - 1];

            return .{ .card = card, .direction = direction };
        }

        pub fn peek(stack: Self) ?StackEntry {
            if (stack.count == 0) return null;

            const card = stack.card_array[stack.count - 1];
            const direction = stack.direction_array[stack.count - 1];

            return .{ .card = card, .direction = direction };
        }

        pub fn flipTop(stack: *Self) void {
            std.debug.assert(stack.count > 0);

            const new_direction = stack.direction_array[stack.count - 1].flip();

            stack.direction_array[stack.count - 1] = new_direction;
        }

        pub fn slice(stack: *Self) struct { cards: []Card, directions: []Direction } {
            const cards = stack.card_array[0..stack.count];
            const directions = stack.direction_array[0..stack.count];

            return .{ .cards = cards, .directions = directions };
        }

        pub fn size(stack: Self) usize {
            return stack.count;
        }

        const StackIterator = struct {
            stack: *const Self,
            position: usize,

            pub fn next(it: *StackIterator) ?StackEntry {
                if (it.position == 0) return null;

                defer it.position -= 1;

                const card = it.stack.card_array[it.position - 1];
                const direction = it.stack.direction_array[it.position - 1];

                return .{ .card = card, .direction = direction };
            }
        };

        pub fn iterator(stack: *Self) StackIterator {
            return .{ .stack = stack, .position = stack.count };
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
            for (stack.card_array[0..stack.count], 0..) |card_state, i| {
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
    stack.push(Card.of(.two, .spades), .faceup);

    var it = stack.iterator();

    const top = it.next() orelse unreachable;

    std.debug.print("card = {}\n", .{top});
    const bottom = it.next() orelse unreachable;
    std.debug.print("card = {}\n", .{bottom});

    try std.testing.expectEqual(null, it.next());
}
