const Point = @import("point.zig").Point;

pub const STOCK_LOCUS: Point = .{ .x = 20, .y = 20, .z = 0 };

pub const CARD_WIDTH = 60.0;
pub const CARD_HEIGHT = CARD_WIDTH * CARD_RATIO;
pub const CARD_STROKE = 1.0;

pub const CARD_RATIO = 1.4;
pub const CARD_BACK_GUTTER = 6.0;
pub const CARD_BACK_WIDTH = CARD_WIDTH - 2 * CARD_BACK_GUTTER;
pub const CARD_BACK_HEIGHT = CARD_HEIGHT - 2 * CARD_BACK_GUTTER;
pub const CARD_STROKE_WIDTH = CARD_WIDTH + 2.0 * CARD_STROKE;
pub const CARD_STROKE_HEIGHT = CARD_HEIGHT + 2.0 * CARD_STROKE;

pub const SCREEN_WIDTH = 600;
pub const SCREEN_HEIGHT = 400;
