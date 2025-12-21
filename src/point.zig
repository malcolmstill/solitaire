pub const Point = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Point {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Point, b: Point) Point {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
        };
    }

    pub fn sub(a: Point, b: Point) Point {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
        };
    }
};

pub const Vec2D = Point;
