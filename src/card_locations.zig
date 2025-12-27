const std = @import("std");
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;
const Vec2D = @import("point.zig").Vec2D;

// TODO: for my own sanity can we comment some units here
const TRANSLATION_VELOCITY = 25.0;
const ANGULAR_VELOCITY = 10.0;

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

    pub fn iterator(locations: *CardLocations) std.AutoHashMap(Card, Position).Iterator {
        return locations.map.iterator();
    }

    // pub fn randomize(card_locations: *CardLocations, card: Card) void {
    //     const rot = std.crypto.random.float(f32) - 0.5;

    // }

    /// Set card position (immediately) to a fixed position.
    ///
    /// If it was animating this will stop the animation
    pub fn set(card_locations: *CardLocations, card: Card, locus: Point) !void {
        try card_locations.map.put(card, Position.fromPoint(locus));
    }

    /// Start an animation
    pub fn startAnimation(card_locations: *CardLocations, card: Card, end_locus: Point) !void {
        // Read the current location
        const start = card_locations.get(card).currentWithRot();

        // If sloppy mode is on, randomly generate an end angle
        const end: RotatedPosition = .{
            .locus = end_locus,
            .angle = if (card_locations.sloppy) randomAngle() else 0.0,
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

        switch (entry.value_ptr.*) {
            .stopped => |point| return point,
            .motion => |*motion| {
                // Calculate translation update
                const displacement = motion.end.locus.sub(motion.current.locus);
                const translation = Vec2D.new(
                    displacement.x * dt * TRANSLATION_VELOCITY,
                    displacement.y * dt * TRANSLATION_VELOCITY,
                );

                // Calculate angle update
                const angle_diff = shortestRotation(motion.end.angle, motion.current.angle);
                const rotation = angle_diff * dt * ANGULAR_VELOCITY;

                motion.* = Animation{
                    .end = motion.end,
                    .current = motion.current.translate(translation).rotate(rotation),
                };

                return motion.current;
            },
        }
    }
};

const TWO_PI_DEGREES = 360.0;
const PI_DEGREES = 180.0;

/// Calculate the shortest rotation from current to end
fn shortestRotation(angle_end: f32, angle_current: f32) f32 {
    // Clamp end / current to [-360, 360]
    const end = @rem(angle_end, TWO_PI_DEGREES);
    const current = @rem(angle_current, TWO_PI_DEGREES);

    // Let's say end is -360 and current is 360
    // we will get as a raw diff -720, then we clamp back to [-360,360]
    const raw_diff = @rem(end - current, TWO_PI_DEGREES);

    if (raw_diff > PI_DEGREES) {
        return -PI_DEGREES + (raw_diff - PI_DEGREES);
    } else if (raw_diff < -PI_DEGREES) {
        return PI_DEGREES + (raw_diff + PI_DEGREES);
    } else {
        return raw_diff;
    }
}

/// Generate a random card angle
fn randomAngle() f32 {
    // Generate a float in the range [-0.5, 0.5];
    const domain = std.crypto.random.float(f32) - 0.5;

    // How much angular range to allow.
    //
    // If this is e.g. 10.0 degrees then we generate [-5, 5]
    const spread = 10.0;

    return spread * domain;
}

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

    pub fn currentWithRot(position: Position) RotatedPosition {
        return switch (position) {
            .stopped => |point| point,
            .motion => |motion| motion.current,
        };
    }

    /// Convert point (x, y) into static Position (i.e. stopped)
    ///
    /// Assumes no rotation
    pub fn fromPoint(point: Point) Position {
        return .{
            .stopped = .{
                .locus = point,
                // FIXME: the random here was just for testing but actually
                // gives a kinda fun effect where each frame renders the
                // in-hand cards with a different angle giving a jitter.
                //
                // I could imagine us retain this "shake in hand" or doing
                // something like vibrate when close (or closer) to a valid
                // move
                //
                // Also the behaviour when we just make this 0.0 is interesting
                // when otherwise using sloppy mode as we get, a straightening
                // of the cards when picked up (as you might tend to do) and
                // then messed up again when placed back down
                .angle = 0.0 * (std.crypto.random.float(f32) - 0.5),
            },
        };
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

    pub fn translate(p: RotatedPosition, v: Vec2D) RotatedPosition {
        return .{
            .locus = p.locus.addVec2D(v),
            .angle = p.angle,
        };
    }

    pub fn rotate(p: RotatedPosition, angle: f32) RotatedPosition {
        return .{
            .locus = p.locus,
            .angle = p.angle + angle,
        };
    }
};

test "property test finding the shortest angle" {
    var rng = std.Random.DefaultPrng.init(std.testing.random_seed);

    var i: usize = 0;
    while (i < 65_536) : (i += 1) {
        // Generate end and current angles.
        //
        // Intentionally these can exceed 360.0 to check `shortestRotation`
        // appropriately clamps the domain.
        const end = 10.0 * TWO_PI_DEGREES * rng.random().float(f32);
        const current = 10.0 * TWO_PI_DEGREES * rng.random().float(f32);

        const shortest = shortestRotation(end, current);

        // Our rotation should be in range [-180, 180]
        std.testing.expect(shortest <= PI_DEGREES and shortest >= -PI_DEGREES) catch {
            @panic(try std.fmt.allocPrint(
                std.testing.allocator,
                "Expected rotation less thant 180.0; end = {} ({}), current = {} ({}), shortest = {}",
                .{
                    end,
                    @mod(end, TWO_PI_DEGREES),
                    current,
                    @mod(current, TWO_PI_DEGREES),
                    shortest,
                },
            ));
        };
    }
}
