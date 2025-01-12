const std = @import("std");

const r = @cImport(@cInclude("raylib.h"));

const Point = @import("point.zig").Point;
const CardState = @import("card_state.zig").CardState;

pub fn Stack(comptime N: u16) type {
    return struct {
        stack_array: [N]CardState = undefined,
        position: u8 = 0,
        locus: Point,
        card_index_offset: f32 = 0.0,

        const Self = @This();

        pub fn push(stack: *Self, card_state: CardState) void {
            defer stack.position += 1;

            var repositioned_card_state = card_state;
            repositioned_card_state.locus = stack.locus;

            repositioned_card_state.locus.y = repositioned_card_state.locus.y + @as(f32, @floatFromInt(stack.position)) * stack.card_index_offset;

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

        pub fn flipTop(stack: *Self) void {
            std.debug.assert(stack.position > 0);

            const new_direction = stack.stack_array[stack.position - 1].direction.flip();

            stack.stack_array[stack.position - 1].direction = new_direction;
        }

        pub fn slice(stack: *Self) []CardState {
            return stack.stack_array[0..stack.position];
        }

        pub fn count(stack: Self) usize {
            return stack.position;
        }

        pub fn draw(stack: *Self) void {
            // Draw empty stack
            {
                const height = CardState.CARD_RATIO * CardState.CARD_WIDTH;
                const offset = 0;

                const emptyRect = .{ .x = stack.locus.x + offset, .y = stack.locus.y + offset, .width = CardState.CARD_WIDTH, .height = height };
                const emptyColour = .{ .a = 50, .r = 76, .g = 76, .b = 76 };

                const roundness = 0.25;
                const segments = 20;
                r.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
            }

            // Draw cards in stack
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
