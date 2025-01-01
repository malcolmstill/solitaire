const Board = struct {};

test "Board" {
    const std = @import("std");
    const board = Board{};

    std.debug.print("board = {any}\n", .{board});
}
