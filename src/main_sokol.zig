const std = @import("std");
const Game = @import("game.zig").Game;
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const shd = @import("cards.glsl.zig");
const Mat4x4 = @import("maths.zig").Mat4x4;
const zstbi = @import("zstbi");
const texcoordsU16 = @import("geom.zig").texcoordsU16;

const CARD_STROKE_WIDTH = @import("geom.zig").CARD_STROKE_WIDTH;
const CARD_STROKE_HEIGHT = @import("geom.zig").CARD_STROKE_HEIGHT;
const SCREEN_WIDTH = @import("geom.zig").SCREEN_WIDTH;
const SCREEN_HEIGHT = @import("geom.zig").SCREEN_HEIGHT;

const N = 52;

const Vertex = extern struct { x: f32, y: f32, u: f32, v: f32 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    zstbi.init(allocator);
    defer zstbi.deinit();

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
        .user_data = @ptrCast(&game),
        .init_cb = init,
        .event_userdata_cb = event,
        .frame_userdata_cb = frame,
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
        .clear_value = .{ .r = 0.5, .g = 0.5, .b = 0.5, .a = 1.0 },
    };

    var image = zstbi.Image.loadFromMemory(@embedFile("cards.png"), 4) catch @panic("Failed to load card.png");
    defer image.deinit();

    state.bindings.views[shd.VIEW_tex] = sg.makeView(.{
        .texture = .{
            .image = sg.makeImage(.{
                .width = std.math.cast(i32, image.width) orelse @panic("width too larger"),
                .height = std.math.cast(i32, image.height) orelse @panic("height too larger"),
                .pixel_format = sg.PixelFormat.RGBA8,
                .data = init: {
                    var data = sg.ImageData{};
                    data.mip_levels[0] = sg.asRange(image.data);
                    break :init data;
                },
            }),
        },
    });

    state.bindings.samplers[shd.SMP_samp] = sg.makeSampler(.{
        .min_filter = sg.Filter.NEAREST,
        .mag_filter = sg.Filter.NEAREST,
    });

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
    std.debug.assert(@sizeOf(Vertex) == 16);
    state.bindings.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .{ .stream_update = true },
        .size = N * @sizeOf(Vertex),
    });

    state.pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(shd.cardsShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};

            l.attrs[shd.ATTR_cards_position] = .{ .format = .FLOAT3, .buffer_index = 0 };
            l.attrs[shd.ATTR_cards_colour0] = .{ .format = .FLOAT4, .buffer_index = 0 };
            l.attrs[shd.ATTR_cards_instance_pos] = .{ .format = .FLOAT2, .buffer_index = 1 };
            l.attrs[shd.ATTR_cards_instance_texcoord] = .{ .format = .FLOAT2, .buffer_index = 1 };

            l.buffers[1].step_func = sg.VertexStep.PER_INSTANCE;

            break :init l;
        },
        .index_type = sg.IndexType.UINT16,
        // Blending
        .colors = init: {
            var c: [sg.max_color_attachments]sg.ColorTargetState = @splat(.{});

            c[0].blend = .{
                .enabled = true,
                .src_factor_rgb = sg.BlendFactor.SRC_ALPHA,
                .dst_factor_rgb = sg.BlendFactor.ONE_MINUS_SRC_ALPHA,
            };

            break :init c;
        },
    });
}

export fn event(ev: [*c]const sapp.Event, userdata: ?*anyopaque) void {
    var game: *Game = @ptrCast(@alignCast(userdata orelse unreachable));

    // FIXME: we are ignoring errors from handle*
    //
    // Let's make those functions not error...we should be preallocating
    // enough data such that our try's, which are probably due to allocation,
    // are not required.

    if (ev.*.type == .MOUSE_DOWN) {
        game.handleButtonDown(ev.*.mouse_x, ev.*.mouse_y) catch {};
    } else if (ev.*.type == .MOUSE_UP) {
        game.handleButtonUp() catch {};
    } else if (ev.*.type == .MOUSE_MOVE) {
        game.handleMove(ev.*.mouse_x, ev.*.mouse_y) catch {};
    }
}

export fn frame(userdata: ?*anyopaque) void {
    var game: *Game = @ptrCast(@alignCast(userdata orelse unreachable));

    const dt: f32 = @floatCast(sapp.frameDuration());
    game.update(dt);

    {
        sg.beginPass(.{
            .action = state.pass_action,
            .swapchain = sglue.swapchain(),
        });
        defer sg.endPass();

        var instance_data: [N]Vertex = undefined;

        var i: usize = 0;
        {
            var it = game.iterator();
            while (it.next()) |entry| {
                defer i += 1;

                const card = entry.card;
                const direction = entry.direction;

                const position = game.locations.get(card).currentWithRot();
                const uv = texcoordsU16(card, direction);

                instance_data[i] = .{
                    .x = position.locus.x,
                    .y = position.locus.y,
                    .u = uv.x,
                    .v = uv.y,
                };
            }
        }

        // FIXME: get this stuff into the game.iterator()
        if (game.state.cards_in_hand) |*cards_in_hand| {
            var it = cards_in_hand.stack.forwardIterator();
            while (it.next()) |entry| {
                defer i += 1;

                const card = entry.card;
                const direction = entry.direction;

                const position = game.locations.get(card).currentWithRot();
                const uv = texcoordsU16(card, direction);

                instance_data[i] = .{
                    .x = position.locus.x,
                    .y = position.locus.y,
                    .u = uv.x,
                    .v = uv.y,
                };
            }
        }

        // We should have iterated over all cards
        std.debug.assert(i == 52);

        // Add data to buffer
        sg.updateBuffer(state.bindings.vertex_buffers[1], sg.asRange(&instance_data));

        const orth = Mat4x4.ortho(0, SCREEN_HEIGHT, 0, SCREEN_WIDTH, 1000, -1);
        sg.applyPipeline(state.pipeline);
        sg.applyBindings(state.bindings);
        sg.applyUniforms(shd.UB_vs_params, sg.asRange(&orth.entries));

        // Draw all the cards
        sg.draw(0, 6, N);
    }

    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}
