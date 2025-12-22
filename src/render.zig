const ray = @cImport(@cInclude("raylib.h"));
const std = @import("std");

const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const RotatedPosition = @import("card_locations.zig").RotatedPosition;
const CardLocations = @import("card_locations.zig").CardLocations;
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
    red_corner: ray.struct_Texture,
    black_corner: ray.struct_Texture,
    textures: std.AutoHashMap(Card, ray.RenderTexture2D),
    texture_facedown: ray.RenderTexture2D,

    pub fn init(allocator: std.mem.Allocator, locations: *CardLocations) !Renderer {
        const red_corner = loadPng("red.png");
        const black_corner = loadPng("black.png");

        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                try locations.setLocation(Card.of(rank, suit), STOCK_LOCUS);
            }
        }

        var textures = std.AutoHashMap(Card, ray.RenderTexture2D).init(allocator);
        for (std.meta.tags(Card.Suit)) |suit| {
            for (std.meta.tags(Card.Rank)) |rank| {
                const card = Card.of(rank, suit);
                const texture = prerenderCard(card, red_corner, black_corner);

                try textures.put(card, texture);
            }
        }

        const texture_facedown = prerenderFacedownCard();

        return .{
            .textures = textures,
            .texture_facedown = texture_facedown,
            .red_corner = red_corner,
            .black_corner = black_corner,
        };
    }

    pub fn renderCard(renderer: *Renderer, card: Card, position: RotatedPosition, direction: Direction) void {
        const locus = position.locus;

        const target: ray.RenderTexture2D = switch (direction) {
            .faceup => renderer.textures.get(card) orelse unreachable,
            .facedown => renderer.texture_facedown,
        };

        ray.DrawTexturePro(
            target.texture,
            ray.Rectangle{
                .x = 0,
                .y = 0,
                .width = @floatFromInt(target.texture.width),
                .height = @floatFromInt(-target.texture.height),
            },
            ray.Rectangle{
                .x = locus.x - CARD_STROKE + @as(f32, @floatFromInt(target.texture.width)) / 2.0,
                .y = locus.y - CARD_STROKE + @as(f32, @floatFromInt(target.texture.height)) / 2.0,
                .width = @floatFromInt(target.texture.width),
                .height = @floatFromInt(target.texture.height),
            },
            ray.Vector2{
                .x = @as(f32, @floatFromInt(target.texture.width)) / 2.0,
                .y = @as(f32, @floatFromInt(target.texture.height)) / 2.0,
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

pub fn prerenderCard(card: Card, red_corner: ray.Texture, black_corner: ray.Texture) ray.RenderTexture2D {
    const target: ray.RenderTexture2D = ray.LoadRenderTexture(CARD_STROKE_WIDTH, CARD_STROKE_HEIGHT);

    const roundness = 0.25;
    const segments = 20;

    ray.BeginTextureMode(target);
    defer ray.EndTextureMode();

    ray.ClearBackground(ray.Color{ .a = 0.0, .r = 0.0, .b = 0.0, .g = 0.0 });

    // Draw outline
    {
        const rect: ray.Rectangle = .{
            .x = 0.0,
            .y = 0.0,
            .width = CARD_STROKE_WIDTH,
            .height = CARD_STROKE_HEIGHT,
        };
        const outLineColor: ray.Color = .{
            .a = 255,
            .r = 0,
            .g = 0,
            .b = 0,
        };
        ray.DrawRectangleRounded(rect, roundness, segments, outLineColor);
    }

    // Draw body
    {
        const rect: ray.Rectangle = .{
            .x = CARD_STROKE,
            .y = CARD_STROKE,
            .width = CARD_WIDTH,
            .height = CARD_HEIGHT,
        };
        const bodyColor: ray.Color = .{
            .a = 255,
            .r = 255,
            .g = 255,
            .b = 255,
        };
        ray.DrawRectangleRounded(rect, roundness, segments, bodyColor);
    }

    prerenderDrawCornerRank(card, red_corner, black_corner);
    prerenderDrawCornerSuit(card, red_corner, black_corner);

    return target;
}

pub fn prerenderFacedownCard() ray.RenderTexture2D {
    const target: ray.RenderTexture2D = ray.LoadRenderTexture(CARD_STROKE_WIDTH, CARD_STROKE_HEIGHT);

    const roundness = 0.25;
    const segments = 20;

    ray.BeginTextureMode(target);
    defer ray.EndTextureMode();

    ray.ClearBackground(ray.Color{ .a = 0.0, .r = 0.0, .b = 0.0, .g = 0.0 });

    {
        const rect: ray.Rectangle = .{
            .x = 0.0,
            .y = 0.0,
            .width = CARD_STROKE_WIDTH,
            .height = CARD_STROKE_HEIGHT,
        };
        const outLineColor: ray.Color = .{
            .a = 255,
            .r = 0,
            .g = 0,
            .b = 0,
        };
        ray.DrawRectangleRounded(rect, roundness, segments, outLineColor);
    }

    // Draw body
    {
        const rect: ray.Rectangle = .{
            .x = CARD_STROKE,
            .y = CARD_STROKE,
            .width = CARD_WIDTH,
            .height = CARD_HEIGHT,
        };
        const bodyColor: ray.Color = .{
            .a = 255,
            .r = 255,
            .g = 255,
            .b = 255,
        };
        ray.DrawRectangleRounded(rect, roundness, segments, bodyColor);
    }

    {
        const backRect: ray.Rectangle = .{
            .x = CARD_STROKE + CARD_BACK_GUTTER,
            .y = CARD_STROKE + CARD_BACK_GUTTER,
            .width = CARD_BACK_WIDTH,
            .height = CARD_BACK_HEIGHT,
        };
        const backColor: ray.Color = .{
            .a = 255,
            .r = 225,
            .g = 95,
            .b = 95,
        };
        ray.DrawRectangleRounded(backRect, 0.15, segments, backColor);
    }

    return target;
}

fn prerenderDrawCornerRank(card: Card, red_corner: ray.Texture, black_corner: ray.Texture) void {
    const sprite_width = 12.0;

    const tex = switch (card.suit) {
        .hearts, .diamonds => red_corner,
        .spades, .clubs => black_corner,
    };

    const suit_index: struct { x: f32, y: f32 } = switch (card.rank) {
        .ace => .{ .x = 0, .y = 0 },
        .two => .{ .x = 2, .y = 0 },
        .three => .{ .x = 3, .y = 0 },
        .four => .{ .x = 0, .y = 1 },
        .five => .{ .x = 1, .y = 1 },
        .six => .{ .x = 2, .y = 1 },
        .seven => .{ .x = 3, .y = 1 },
        .eight => .{ .x = 0, .y = 2 },
        .nine => .{ .x = 1, .y = 2 },
        .ten => .{ .x = 2, .y = 2 },
        .jack => .{ .x = 3, .y = 2 },
        .queen => .{ .x = 0, .y = 3 },
        .king => .{ .x = 1, .y = 3 },
    };

    const src: ray.Rectangle = .{
        .x = suit_index.x * sprite_width,
        .y = suit_index.y * sprite_width,
        .width = sprite_width,
        .height = sprite_width,
    };

    const top_left: ray.Rectangle = .{
        .x = CARD_STROKE,
        .y = CARD_STROKE + 2.0,
        .width = 12.0,
        .height = 12.0,
    };
    const top_right: ray.Rectangle = .{
        .x = CARD_STROKE + CARD_WIDTH - 13.0,
        .y = CARD_STROKE + 2.0,
        .width = 12.0,
        .height = 12.0,
    };
    const bottom_left: ray.Rectangle = .{
        .x = CARD_STROKE + 13.0,
        .y = CARD_STROKE + CARD_HEIGHT - 2.0,
        .width = 12.0,
        .height = 12.0,
    };
    const bottom_right: ray.Rectangle = .{
        .x = CARD_STROKE + CARD_WIDTH,
        .y = CARD_STROKE + CARD_HEIGHT - 2.0,
        .width = 12.0,
        .height = 12.0,
    };

    ray.DrawTexturePro(tex, src, top_left, .{ .x = 0.0, .y = 0.0 }, 0.0, ray.WHITE);
    ray.DrawTexturePro(tex, src, top_right, .{ .x = 0.0, .y = 0.0 }, 0.0, ray.WHITE);
    ray.DrawTexturePro(tex, src, bottom_left, .{ .x = 0.0, .y = 0.0 }, 180.0, ray.WHITE);
    ray.DrawTexturePro(tex, src, bottom_right, .{ .x = 0.0, .y = 0.0 }, 180.0, ray.WHITE);
}

fn prerenderDrawCornerSuit(card: Card, red_corner: ray.Texture, black_corner: ray.Texture) void {
    const sprite_width = 12.0;

    const tex = switch (card.suit) {
        .hearts, .diamonds => red_corner,
        .spades, .clubs => black_corner,
    };

    const suit_index: struct { x: f32, y: f32 } = switch (card.suit) {
        .hearts, .clubs => .{ .x = 3, .y = 3 },
        .diamonds, .spades => .{ .x = 2, .y = 3 },
    };

    const src: ray.Rectangle = .{
        .x = suit_index.x * sprite_width,
        .y = suit_index.y * sprite_width,
        .width = sprite_width,
        .height = sprite_width,
    };

    const top_left: ray.Rectangle = .{
        .x = CARD_STROKE,
        .y = CARD_STROKE + sprite_width + 2.0,
        .width = sprite_width,
        .height = sprite_width,
    };
    const top_right: ray.Rectangle = .{
        .x = CARD_STROKE + CARD_WIDTH - sprite_width - 1.0,
        .y = CARD_STROKE + sprite_width + 2.0,
        .width = sprite_width,
        .height = sprite_width,
    };
    const bottom_left: ray.Rectangle = .{
        .x = CARD_STROKE + sprite_width + 1.0,
        .y = CARD_STROKE + CARD_HEIGHT - sprite_width - 2.0,
        .width = sprite_width,
        .height = sprite_width,
    };
    const bottom_right: ray.Rectangle = .{
        .x = CARD_STROKE + CARD_WIDTH,
        .y = CARD_STROKE + CARD_HEIGHT - sprite_width - 2.0,
        .width = sprite_width,
        .height = sprite_width,
    };

    ray.DrawTexturePro(tex, src, top_left, .{ .x = 0.0, .y = 0.0 }, 0.0, ray.WHITE);
    ray.DrawTexturePro(tex, src, top_right, .{ .x = 0.0, .y = 0.0 }, 0.0, ray.WHITE);
    ray.DrawTexturePro(tex, src, bottom_left, .{ .x = 0.0, .y = 0.0 }, 180.0, ray.WHITE);
    ray.DrawTexturePro(tex, src, bottom_right, .{ .x = 0.0, .y = 0.0 }, 180.0, ray.WHITE);
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
