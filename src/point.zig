pub const Point = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Point {
        return .{
            .x = x,
            .y = y,
        };
    }

    pub fn add(a: Point, b: Point) Point {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
        };
    }

    pub fn addVec2D(a: Point, b: Vec2D) Point {
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

    pub fn fromVec2D(v: Vec2D) Point {
        return .{
            .x = v.x,
            .y = v.y,
        };
    }
};

pub const Vec3D = Point;

pub const Vec2D = struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Vec2D {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Point, b: Point) Vec2D {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
        };
    }

    pub fn sub(a: Point, b: Point) Vec2D {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
        };
    }
};
