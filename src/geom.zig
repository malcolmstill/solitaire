const Point = @import("point.zig").Point;
const Card = @import("card.zig").Card;
const Direction = @import("direction.zig").Direction;
const std = @import("std");

pub const STOCK_LOCUS: Point = .{ .x = 20, .y = 20 };

pub const CARD_WIDTH = 60.0;
pub const CARD_HEIGHT = CARD_WIDTH * CARD_RATIO;
pub const CARD_STROKE = 1.0;

pub const CARD_RATIO = 1.4;
pub const CARD_BACK_GUTTER = 6.0;
pub const CARD_BACK_WIDTH = CARD_WIDTH - 2 * CARD_BACK_GUTTER;
pub const CARD_BACK_HEIGHT = CARD_HEIGHT - 2 * CARD_BACK_GUTTER;
pub const CARD_STROKE_WIDTH = CARD_WIDTH + 2.0 * CARD_STROKE;
pub const CARD_STROKE_HEIGHT = CARD_HEIGHT + 2.0 * CARD_STROKE;

pub const SCREEN_WIDTH = 600;
pub const SCREEN_HEIGHT = 400;

pub const TexCoords = struct { x: f32, y: f32 };
pub const TexCoordsU16 = struct { x: f32, y: f32 };

pub fn texcoords(card: Card, direction: Direction) TexCoords {
    const tex_coords: TexCoords = switch (direction) {
        .faceup => block: {
            const vertical_index: f32 = switch (card.suit) {
                .spades => 0.0,
                .hearts => 1.0,
                .diamonds => 2.0,
                .clubs => 3.0,
            };

            const x: f32 = @as(f32, @floatFromInt((card.rank.order() - 1))) * CARD_STROKE_WIDTH;
            const y: f32 = vertical_index * CARD_STROKE_HEIGHT;

            const coords: TexCoords = .{ .x = x, .y = y };

            break :block coords;
        },
        .facedown => .{ .x = 0.0, .y = 4 * CARD_STROKE_HEIGHT },
    };

    return tex_coords;
}

pub fn texcoordsU16(card: Card, direction: Direction) TexCoordsU16 {
    const tex_coords: TexCoordsU16 = switch (direction) {
        .faceup => block: {
            const vertical_index: u16 = switch (card.suit) {
                .spades => 0,
                .hearts => 1,
                .diamonds => 2,
                .clubs => 3,
            };

            // FIXME: think about intFromFloat here
            // const x: u16 = (card.rank.order() - 1) * @as(u16, @intFromFloat(CARD_STROKE_WIDTH));
            // const y: u16 = vertical_index * @as(u16, @intFromFloat(CARD_STROKE_HEIGHT));

            const x: u16 = (card.rank.order() - 1);
            const y: u16 = vertical_index;

            const coords: TexCoordsU16 = .{
                .x = @floatFromInt(x),
                .y = @floatFromInt(y),
            };

            // std.debug.print("coords = {any}\n", .{coords});

            break :block coords;
        },
        .facedown => .{ .x = 0.0, .y = 4 * CARD_STROKE_HEIGHT },
    };

    return tex_coords;
}
