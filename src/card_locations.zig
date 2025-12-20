const std = @import("std");
const Card = @import("card.zig").Card;
const Point = @import("point.zig").Point;

pub const CardLocations = struct {
    map: std.AutoHashMap(Card, Point),

    pub fn init(allocator: std.mem.Allocator) CardLocations {
        return .{ .map = std.AutoHashMap(Card, Point).init(allocator) };
    }

    pub fn deinit(card_locations: *CardLocations) void {
        card_locations.map.deinit();
    }

    pub fn get(card_locations: *CardLocations, card: Card) Point {
        return card_locations.map.get(card) orelse unreachable;
    }

    pub fn set_location(card_locations: *CardLocations, card: Card, locus: Point) !void {
        try card_locations.map.put(card, locus);
    }
};
