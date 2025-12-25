const std = @import("std");
const Game = @import("game.zig").Game;
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const shd = @import("cards.glsl.zig");
const Mat4x4 = @import("maths.zig").Mat4x4;

const CARD_STROKE_WIDTH = @import("geom.zig").CARD_STROKE_WIDTH;
const CARD_STROKE_HEIGHT = @import("geom.zig").CARD_STROKE_HEIGHT;
const SCREEN_WIDTH = @import("geom.zig").SCREEN_WIDTH;
const SCREEN_HEIGHT = @import("geom.zig").SCREEN_HEIGHT;

const N = 3;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var debug = false;
    var sloppy = false;
    var seed = std.crypto.random.int(u64);

    var expect_next_seed = false;
    var args = std.process.args();
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--debug")) {
            debug = true;
        }

        if (std.mem.eql(u8, arg, "--seed")) {
            expect_next_seed = true;
        } else if (expect_next_seed) {
            seed = try std.fmt.parseInt(u64, arg, 10);
            expect_next_seed = false;
        }

        if (std.mem.eql(u8, arg, "--sloppy")) {
            sloppy = true;
        }
    }

    if (expect_next_seed) {
        @panic("Expected integer seed");
    }

    var game = try Game.init(allocator, seed, sloppy, debug);
    defer game.deinit(allocator);

    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = SCREEN_WIDTH,
        .height = SCREEN_HEIGHT,
        .icon = .{ .sokol_default = true },
        .window_title = "solitaire",
        .logger = .{ .func = slog.func },
    });
}

const state = struct {
    var bindings: sg.Bindings = .{};
    var pipeline: sg.Pipeline = .{};
    var pass_action: sg.PassAction = .{};
};

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.3, .g = 0.3, .b = 0.3, .a = 1 },
    };

    //   0                          1
    // (0, 0) ----------------- (60, 0)
    //   |                ____/    |
    //   |           ____/         |
    //   |      ____/              |
    //   | ____/                   |
    //   |/                        |
    // (0, 84) ----------------- (60, 84)
    //    3                        2
    const vertex_data = &[_]f32{
        // positions                               | colors           |
        0.0,               0.0,                0.0, 1.0, 0.0, 0.0, 1.0,
        CARD_STROKE_WIDTH, 0.0,                0.0, 0.0, 1.0, 0.0, 1.0,
        CARD_STROKE_WIDTH, CARD_STROKE_HEIGHT, 0.0, 0.0, 0.0, 1.0, 1.0,
        0.0,               CARD_STROKE_HEIGHT, 0.0, 0.0, 0.0, 1.0, 1.0,
    };

    const index_data = &[_]u16{
        0, 1, 3, // First triangle
        3, 1, 2, // Second triangle
    };

    // Make fixed vertex buffer
    state.bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(vertex_data),
    });

    // Make index buffer
    state.bindings.index_buffer = sg.makeBuffer(.{
        .data = sg.asRange(index_data),
        .usage = .{
            .index_buffer = true,
        },
    });

    // Pre-allocate instance data
    state.bindings.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .{ .stream_update = true },
        .size = N * @sizeOf([3]f32), // FIXME: want at least 52 * @sizeOf(...)
    });

    state.pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(shd.cardsShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};

            l.attrs[shd.ATTR_cards_position] = .{ .format = .FLOAT3, .buffer_index = 0 };
            l.attrs[shd.ATTR_cards_colour0] = .{ .format = .FLOAT4, .buffer_index = 0 };
            l.attrs[shd.ATTR_cards_instance_pos] = .{ .format = .FLOAT3, .buffer_index = 1 };

            l.buffers[1].step_func = sg.VertexStep.PER_INSTANCE;

            break :init l;
        },
        .index_type = sg.IndexType.UINT16,
        // Enable depth testing
        .depth = .{
            .compare = sg.CompareFunc.LESS_EQUAL,
            .write_enabled = true,
        },
    });
}

export fn frame() void {
    {
        sg.beginPass(.{
            .action = state.pass_action,
            .swapchain = sglue.swapchain(),
        });
        defer sg.endPass();

        const instance_data = &[_]f32{
            50.0, 50.0, 0.0, //
            100.0, 100.0, -0.5, //
            0.0, 150.0, 0.0, //
        };
        const orth = Mat4x4.ortho(SCREEN_HEIGHT, 0, 0, SCREEN_WIDTH, -100, 100);

        sg.updateBuffer(state.bindings.vertex_buffers[1], sg.asRange(instance_data));

        sg.applyPipeline(state.pipeline);
        sg.applyBindings(state.bindings);
        sg.applyUniforms(shd.UB_vs_params, sg.asRange(&orth.entries));

        sg.draw(0, 6, N);
    }

    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}
