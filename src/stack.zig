const std = @import("std");
const Point = @import("point.zig").Point;
const CardState = @import("card_state.zig").CardState;

pub fn Stack(comptime N: u16) type {
    return struct {
        stack_array: [N]CardState = undefined,
        position: u8 = 0,
        locus: Point,

        const Self = @This();

        pub fn push(stack: *Self, card_state: CardState) void {
            defer stack.position += 1;

            var repositioned_card_state = card_state;
            repositioned_card_state.locus = stack.locus;

            stack.stack_array[stack.position] = repositioned_card_state;
        }

        pub fn pop(stack: *Self) CardState {
            defer stack.position -= 1;

            return stack.stack_array[stack.position - 1];
        }

        pub fn peek(stack: Self) ?CardState {
            if (stack.position == 0) return null;

            return stack.stack_array[stack.position - 1];
        }

        pub fn slice(stack: *Self) []CardState {
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
            for (stack.stack_array[0..stack.position], 0..) |card_state, i| {
                if (i > 0) try writer.print(", ", .{});

                try writer.print("{}", .{card_state});
            }
            try writer.print("]", .{});
        }
    };
}

test {
    var stack: Stack(3) = .{};

    stack.push(CardState.of(.ace, .spades));
}
