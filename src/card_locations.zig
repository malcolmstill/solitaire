const std = @import("std");
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;

pub const CardLocations = struct {
    map: std.AutoHashMap(Card, Position),

    pub fn init(allocator: std.mem.Allocator) CardLocations {
        return .{ .map = std.AutoHashMap(Card, Position).init(allocator) };
    }

    pub fn deinit(card_locations: *CardLocations) void {
        card_locations.map.deinit();
    }

    pub fn get(card_locations: *CardLocations, card: Card) Position {
        return card_locations.map.get(card) orelse unreachable;
    }

    /// Set card position (immediately) to a fixed position.
    ///
    /// If it was animating this will stop the animation
    pub fn set_location(card_locations: *CardLocations, card: Card, locus: Point) !void {
        try card_locations.map.put(card, Position.from_point(locus));
    }

    /// Start an animation
    pub fn start_animation(card_locations: *CardLocations, card: Card, end: Point) !void {
        // Read the current location
        const start = card_locations.get(card).current();

        const position: Position = .{ .motion = .{ .start = start, .end = end, .current = start } };

        try card_locations.map.put(card, position);
    }

    pub fn update(card_locations: *CardLocations, card: Card, dt: f32) Point {
        const entry = card_locations.map.getEntry(card) orelse unreachable;

        const speed = 25.0;

        switch (entry.value_ptr.*) {
            .stopped => |point| return point,
            .motion => |*motion| {
                const dir = motion.end.sub(motion.current);

                motion.* = Animation{
                    .start = motion.start,
                    .end = motion.end,
                    .current = Point{
                        .x = motion.current.x + dir.x * dt * speed,
                        .y = motion.current.y + dir.y * dt * speed,
                    },
                };

                return motion.current;
            },
        }
    }
};

pub const PositionKind = enum {
    stopped,
    motion,
};

pub const Position = union(PositionKind) {
    stopped: Point,
    motion: Animation,

    pub fn current(position: Position) Point {
        return switch (position) {
            .stopped => |point| point,
            .motion => |motion| motion.current,
        };
    }

    pub fn from_point(point: Point) Position {
        return .{ .stopped = point };
    }
};

pub const Animation = struct {
    start: Point,
    end: Point,

    current: Point,
};
