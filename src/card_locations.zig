const std = @import("std");
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const Vec2D = @import("point.zig").Vec2D;

pub const CardLocations = struct {
    map: std.AutoHashMap(Card, Position),
    sloppy: bool,

    pub fn init(allocator: std.mem.Allocator, sloppy: bool) CardLocations {
        return .{
            .map = std.AutoHashMap(Card, Position).init(allocator),
            .sloppy = sloppy,
        };
    }

    pub fn deinit(card_locations: *CardLocations) void {
        card_locations.map.deinit();
    }

    pub fn get(card_locations: *CardLocations, card: Card) Position {
        return card_locations.map.get(card) orelse unreachable;
    }

    // pub fn randomize(card_locations: *CardLocations, card: Card) void {
    //     const rot = std.crypto.random.float(f32) - 0.5;

    // }

    /// Set card position (immediately) to a fixed position.
    ///
    /// If it was animating this will stop the animation
    pub fn set_location(card_locations: *CardLocations, card: Card, locus: Point) !void {
        try card_locations.map.put(card, Position.from_point(locus));
    }

    /// Start an animation
    pub fn start_animation(card_locations: *CardLocations, card: Card, end_locus: Point) !void {
        // Read the current location
        const start = card_locations.get(card).current_with_rot();

        // If sloppy mode is on, randomly generate an end angle
        const end: RotatedPosition = if (card_locations.sloppy) .{
            .locus = end_locus,
            .angle = std.crypto.random.float(f32) - 0.5,
        } else .{
            .locus = end_locus,
            .angle = 0.0,
        };

        const position: Position = .{
            .motion = .{
                .end = end,
                .current = start,
            },
        };

        try card_locations.map.put(card, position);
    }

    /// Update (i.e. animate) the location of a card based upon a dt
    ///
    /// TODO: detect animation is finished and replace motion with stopped.
    pub fn update(card_locations: *CardLocations, card: Card, dt: f32) RotatedPosition {
        const entry = card_locations.map.getEntry(card) orelse unreachable;

        const speed = 25.0;

        switch (entry.value_ptr.*) {
            .stopped => |point| return point,
            .motion => |*motion| {
                const dir = motion.end.locus.sub(motion.current.locus);

                const shift = Vec2D.new(dir.x * dt * speed, dir.y * dt * speed);

                motion.* = Animation{
                    .end = motion.end,
                    .current = motion.current.translate(shift),
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
    stopped: RotatedPosition,
    motion: Animation,

    /// Return locus of position (no rotation information)
    pub fn current(position: Position) Point {
        return switch (position) {
            .stopped => |point| point.locus,
            .motion => |motion| motion.current.locus,
        };
    }

    pub fn current_with_rot(position: Position) RotatedPosition {
        return switch (position) {
            .stopped => |point| point,
            .motion => |motion| motion.current,
        };
    }

    /// Convert point (x, y) into static Position (i.e. stopped)
    ///
    /// Assumes no rotation
    pub fn from_point(point: Point) Position {
        return .{ .stopped = .{ .locus = point, .angle = 0.0 } };
    }
};

pub const Animation = struct {
    // start: RotatedPosition,
    end: RotatedPosition,

    current: RotatedPosition,
};

// Objects with area can be at a location and rotated
// (around, say, the center)
pub const RotatedPosition = struct {
    locus: Point,
    angle: f32,

    pub fn translate(p: RotatedPosition, v: Point) RotatedPosition {
        return .{
            .locus = p.locus.add(v),
            .angle = p.angle,
        };
    }
};
