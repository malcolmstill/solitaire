const ray = @cImport(@cInclude("raylib.h"));
const std = @import("std");

const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const RotatedPosition = @import("card_locations.zig").RotatedPosition;
const Direction = @import("direction.zig").Direction;
const STOCK_LOCUS = @import("geom.zig").STOCK_LOCUS;
const CARD_STROKE = @import("geom.zig").CARD_STROKE;
const CARD_WIDTH = @import("geom.zig").CARD_WIDTH;
const CARD_HEIGHT = @import("geom.zig").CARD_HEIGHT;
const CARD_STROKE_WIDTH = @import("geom.zig").CARD_STROKE_WIDTH;
const CARD_STROKE_HEIGHT = @import("geom.zig").CARD_STROKE_HEIGHT;
const CARD_BACK_GUTTER = @import("geom.zig").CARD_BACK_GUTTER;
const CARD_BACK_WIDTH = @import("geom.zig").CARD_BACK_WIDTH;
const CARD_BACK_HEIGHT = @import("geom.zig").CARD_BACK_HEIGHT;

pub const Renderer = struct {
    cards: ray.Texture,

    pub fn init() !Renderer {
        const cards = loadPng("cards.png");

        return .{
            .cards = cards,
        };
    }

    pub fn renderCard(renderer: *Renderer, card: Card, position: RotatedPosition, direction: Direction) void {
        const locus = position.locus;

        const target = renderer.cards;

        const TexCoords = struct { x: f32, y: f32 };

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

        ray.DrawTexturePro(
            target,
            ray.Rectangle{
                .x = tex_coords.x,
                .y = tex_coords.y,
                .width = CARD_STROKE_WIDTH,
                .height = CARD_STROKE_HEIGHT,
            },
            ray.Rectangle{
                .x = locus.x - CARD_STROKE + CARD_STROKE_WIDTH / 2.0,
                .y = locus.y - CARD_STROKE + CARD_STROKE_HEIGHT / 2.0,
                .width = CARD_STROKE_WIDTH,
                .height = CARD_STROKE_HEIGHT,
            },
            ray.Vector2{
                .x = CARD_STROKE_WIDTH / 2.0,
                .y = CARD_STROKE_HEIGHT / 2.0,
            },
            position.angle,
            ray.WHITE,
        );
    }
};

fn loadPng(comptime path: []const u8) ray.Texture {
    const data = @embedFile(path);
    const image = ray.LoadImageFromMemory(".png", data, data.len);

    return ray.LoadTextureFromImage(image);
}

/// Render debug overlay
pub fn renderDebug(stack_locus: Point, is_move_valid: bool) void {
    const offset = 0.0;

    const emptyRect: ray.Rectangle = .{
        .x = stack_locus.x + offset,
        .y = stack_locus.y + offset,
        .width = CARD_WIDTH,
        .height = CARD_HEIGHT,
    };

    const emptyColour: ray.Color = if (is_move_valid)
        .{ .a = 50, .r = 0, .g = 176, .b = 0 }
    else
        .{ .a = 70, .r = 176, .g = 176, .b = 0 };

    const roundness = 0.25;
    const segments = 20;

    ray.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
}

pub fn renderEmpty(stack_locus: Point) void {
    const offset = 0;

    const emptyRect: ray.Rectangle = .{
        .x = stack_locus.x + offset,
        .y = stack_locus.y + offset,
        .width = CARD_WIDTH,
        .height = CARD_HEIGHT,
    };

    const emptyColour: ray.Color = .{ .a = 50, .r = 76, .g = 76, .b = 76 };

    const roundness = 0.25;
    const segments = 20;

    ray.DrawRectangleRounded(emptyRect, roundness, segments, emptyColour);
}
