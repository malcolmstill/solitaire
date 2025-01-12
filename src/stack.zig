const std = @import("std");

const r = @cImport(@cInclude("raylib.h"));

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

        pub fn draw(stack: *Self) void {
            const height = CardState.CARD_RATIO * CardState.CARD_WIDTH;
            const offset = 0;

            const emptyRect = .{ .x = stack.locus.x + offset, .y = stack.locus.y + offset, .width = CardState.CARD_WIDTH, .height = height };
            const emptyColour = .{ .a = 50, .r = 76, .g = 76, .b = 76 };

            const roundness = 0.25;
            const segments = 20;
            r.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);

            for (stack.slice()) |card| {
                card.draw();
            }
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
