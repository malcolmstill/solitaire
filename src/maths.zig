const std = @import("std");

pub const Mat4 = [16]f32;

pub const Mat4x4 = struct {
    entries: Mat4,

    pub fn ortho(top: f32, bottom: f32, left: f32, right: f32, near: f32, far: f32) Mat4x4 {
        return .{
            .entries = Mat4{
                2 / (right - left), 0, 0, -(right + left) / (right - left), //
                0, 2 / (top - bottom), 0, -(top + bottom) / (top - bottom), //
                0, 0, 2 / (far - near), -(far + near) / (far - near), //
                0, 0, 0, 1, //
            },
        };
    }

    pub fn prod(mat: Mat4x4, vec: Vec4) Vec4 {
        const m = mat.entries;
        const v = vec.entries;

        return .{
            .entries = [4]f32{
                m[0] * v[0] + m[1] * v[1] + m[2] * v[2] + m[3] * v[3],
                m[4] * v[0] + m[5] * v[1] + m[6] * v[2] + m[7] * v[3],
                m[8] * v[0] + m[9] * v[1] + m[10] * v[2] + m[11] * v[3],
                m[12] * v[0] + m[13] * v[1] + m[14] * v[2] + m[15] * v[3],
            },
        };
    }
};

pub const Vec4 = struct {
    entries: [4]f32,

    pub fn new(a: f32, b: f32, c: f32, d: f32) Vec4 {
        return .{ .entries = [4]f32{ a, b, c, d } };
    }
};

test "orthographic projection" {
    const mat = Mat4x4.ortho(480, 0, 0, 640, -1, 1);

    {
        const vec = Vec4.new(640, 480, 0, 1);

        const result = mat.prod(vec);

        try std.testing.expectEqual(1.0, result.entries[0]);
        try std.testing.expectEqual(1.0, result.entries[1]);
    }

    {
        const vec = Vec4.new(640, 0, 0, 1);

        const result = mat.prod(vec);

        try std.testing.expectEqual(1.0, result.entries[0]);
        try std.testing.expectEqual(-1.0, result.entries[1]);
    }

    {
        const vec = Vec4.new(0, 0, 0, 1);

        const result = mat.prod(vec);

        try std.testing.expectEqual(-1.0, result.entries[0]);
        try std.testing.expectEqual(-1.0, result.entries[1]);
    }

    {
        const vec = Vec4.new(0, 480, 0, 1);

        const result = mat.prod(vec);

        try std.testing.expectEqual(-1.0, result.entries[0]);
        try std.testing.expectEqual(1.0, result.entries[1]);
    }
}
