pub const Direction = enum {
    facedown,
    faceup,

    pub fn flip(direction: Direction) Direction {
        return switch (direction) {
            .facedown => .faceup,
            .faceup => .facedown,
        };
    }
};
