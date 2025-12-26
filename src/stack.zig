const std = @import("std");

const Point = @import("point.zig").Point;
const Card = @import("card.zig").Card;
const Direction = @import("direction.zig").Direction;

pub fn Stack(comptime N: u16) type {
    return struct {
        array: [N]StackEntry = undefined,
        count: u8 = 0,

        pub const StackEntry = struct {
            card: Card,
            direction: Direction,

            pub fn format(entry: StackEntry, writer: *std.Io.Writer) !void {
                try writer.print("{f} {}", .{ entry.card, entry.direction });
            }
        };

        const Self = @This();

        pub fn push(stack: *Self, card: Card, direction: Direction) void {
            defer stack.count += 1;

            stack.array[stack.count] = .{ .card = card, .direction = direction };
        }

        pub fn pushCards(stack: *Self, cards: Stack(52)) void {
            defer stack.count += cards.size();

            for (stack.count..stack.count + cards.size(), 0..) |i, j| {
                stack.array[i] = cards.array[j];
            }
        }

        pub fn pop(stack: *Self) StackEntry {
            defer stack.count -= 1;

            return stack.array[stack.count - 1];
        }

        pub fn popOrNull(stack: *Self) ?StackEntry {
            if (stack.count == 0) return null;

            defer stack.count -= 1;

            return stack.array[stack.count - 1];
        }

        pub fn peek(stack: Self) ?StackEntry {
            if (stack.count == 0) return null;

            return stack.array[stack.count - 1];
        }

        pub fn flipTop(stack: *Self) void {
            std.debug.assert(stack.count > 0);

            stack.array[stack.count - 1].direction = stack.array[stack.count - 1].direction.flip();
        }

        pub fn slice(stack: *Self) []StackEntry {
            return stack.array[0..stack.count];
        }

        pub fn size(stack: Self) u8 {
            return stack.count;
        }

        pub fn take(stack: *Self, n: u8) Self {
            std.debug.assert(n <= stack.count);

            const start = stack.count - n;
            const end = stack.count;

            var new_stack: Self = .{};

            for (start..end, 0..) |i, j| {
                new_stack.array[j] = stack.array[i];
            }

            new_stack.count = n;
            stack.count -= n;

            return new_stack;
        }

        pub const ForwardIterator = struct {
            stack: *const Self,
            position: usize,

            pub fn next(it: *ForwardIterator) ?StackEntry {
                // std.debug.print("next it.position = {} and it.stack.count = {}\n", .{ it.position, it.stack.count });
                if (it.position == it.stack.count) return null;

                defer it.position += 1;

                return it.stack.array[it.position];
            }
        };

        pub fn forwardIterator(stack: *const Self) ForwardIterator {
            // std.debug.print("forwardIterator stack.position = {}, stack = {}\n", .{ stack.count, stack });
            return .{ .stack = stack, .position = 0 };
        }

        pub const StackIterator = struct {
            stack: *Self,
            position: usize,

            pub fn next(it: *StackIterator) ?StackEntry {
                if (it.position == 0) return null;

                defer it.position -= 1;

                return it.stack.array[it.position - 1];
            }
        };

        pub fn iterator(stack: *Self) StackIterator {
            return .{ .stack = stack, .position = stack.count };
        }

        pub fn format(stack: Self, writer: *std.Io.Writer) !void {
            try writer.print("[", .{});
            for (stack.array[0..stack.count], 0..) |card_state, i| {
                if (i > 0) try writer.print(", ", .{});

                try writer.print("{f}", .{card_state.card});
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

    std.debug.print("card = {f}\n", .{top});
    const bottom = it.next() orelse unreachable;
    std.debug.print("card = {f}\n", .{bottom});

    try std.testing.expectEqual(null, it.next());
}

test "take" {
    var stack: Stack(3) = .{};

    stack.push(Card.of(.ace, .spades), .faceup);
    stack.push(Card.of(.two, .spades), .faceup);
    stack.push(Card.of(.three, .spades), .faceup);

    const stack_2 = stack.take(2);

    std.debug.print("stack = {f}, stack 2 = {f}\n", .{ stack, stack_2 });
}

test "forward iterator" {
    var stack: Stack(3) = .{};

    stack.push(Card.of(.ace, .spades), .faceup);
    stack.push(Card.of(.two, .spades), .faceup);

    var it = stack.forwardIterator();

    const top = it.next() orelse unreachable;

    std.debug.print("card = {f}\n", .{top});
    const bottom = it.next() orelse unreachable;
    std.debug.print("card = {f}\n", .{bottom});

    try std.testing.expectEqual(null, it.next());
}
