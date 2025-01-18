const std = @import("std");

const r = @cImport(@cInclude("raylib.h"));

const Point = @import("point.zig").Point;
const CardState = @import("card_state.zig").CardState;
const Card = @import("card.zig").Card;
const Direction = @import("direction.zig").Direction;

pub fn Stack(comptime N: u16) type {
    return struct {
        // stack_array: [N]CardState = undefined,
        card_array: [N]Card = undefined,
        direction_array: [N]Direction = undefined,
        position: u8 = 0,
        // locus: Point,
        // card_index_offset: f32 = 0.0,

        pub const StackEntry = struct { card: Card, direction: Direction };

        const Self = @This();

        pub fn push(stack: *Self, card: Card, direction: Direction) void {
            defer stack.position += 1;

            // var repositioned_card_state = card_state;
            // repositioned_card_state.locus = stack.locus;

            // repositioned_card_state.locus.y = repositioned_card_state.locus.y + @as(f32, @floatFromInt(stack.position)) * stack.card_index_offset;

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

        // pub fn draw(stack: *Self) void {
        //     // Draw empty stack
        //     {
        //         const height = CardState.CARD_RATIO * CardState.CARD_WIDTH;
        //         const offset = 0;

        //         const emptyRect = .{ .x = stack.locus.x + offset, .y = stack.locus.y + offset, .width = CardState.CARD_WIDTH, .height = height };
        //         const emptyColour = .{ .a = 50, .r = 76, .g = 76, .b = 76 };

        //         const roundness = 0.25;
        //         const segments = 20;
        //         r.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
        //     }

        //     // Draw cards in stack
        //     for (stack.slice()) |card| {
        //         card.draw();
        //     }
        // }

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

    stack.push(Card.of(.ace, .spades), .faceup);
}
