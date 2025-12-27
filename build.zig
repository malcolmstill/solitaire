const std = @import("std");
const sokol = @import("sokol");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    if (target.result.cpu.arch.isWasm()) {
        try buildWebSokol(b, target, optimize);
    } else {
        try buildNativeRaylib(b, target, optimize);
        try buildNativeSokol(b, target, optimize);
    }

    const exe_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main_raylib.zig"), // FIXME: test.zig
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

fn buildNativeRaylib(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const raylib = b.dependency("raylib", .{});
    const raylib_lib = raylib.artifact("raylib");

    const exe = b.addExecutable(.{
        .name = "game-raylib",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main_raylib.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });
    exe.linkLibrary(raylib_lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-raylib", "Run the game (raylib)");
    run_step.dependOn(&run_cmd.step);
}

fn buildNativeSokol(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const zstbi = b.dependency("zstbi", .{});
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const dep_shdc = dep_sokol.builder.dependency("shdc", .{});

    const shdc_step = try sokol.shdc.createSourceFile(b, .{
        .shdc_dep = dep_shdc,
        .input = "src/shaders/cards.glsl",
        .output = "src/cards.glsl.zig",
        .slang = .{
            .glsl410 = true,
            .glsl300es = true,
            .hlsl4 = true,
            .metal_macos = true,
            .wgsl = true,
        },
    });

    const exe = b.addExecutable(.{
        .name = "game-sokol",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main_sokol.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "sokol", .module = dep_sokol.module("sokol") },
                .{ .name = "zstbi", .module = zstbi.module("root") },
            },
        }),
    });
    exe.step.dependOn(shdc_step);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-sokol", "Run the game (sokol)");
    run_step.dependOn(&run_cmd.step);
}

fn buildWebSokol(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const zstbi = b.dependency("zstbi", .{});
    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const dep_shdc = dep_sokol.builder.dependency("shdc", .{});

    const shdc_step = try sokol.shdc.createSourceFile(b, .{
        .shdc_dep = dep_shdc,
        .input = "src/shaders/cards.glsl",
        .output = "src/cards.glsl.zig",
        .slang = .{
            .glsl410 = true,
            .glsl300es = true,
            .hlsl4 = true,
            .metal_macos = true,
            .wgsl = true,
        },
    });

    b.getInstallStep().dependOn(shdc_step);

    const emsdk = dep_sokol.builder.dependency("emsdk", .{});
    const emsdk_incl_path = emsdk.path("upstream/emscripten/cache/sysroot/include");

    const mod_zstbi = zstbi.module("root");
    mod_zstbi.addSystemIncludePath(emsdk_incl_path);

    const mod = b.createModule(.{
        .root_source_file = b.path("src/main_sokol.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sokol", .module = dep_sokol.module("sokol") },
            .{ .name = "zstbi", .module = mod_zstbi },
        },
    });

    const lib = b.addLibrary(.{
        .name = "solitaire",
        .root_module = mod,
    });

    const link_step = try sokol.emLinkStep(b, .{
        .lib_main = lib,
        .target = target,
        .optimize = optimize,
        .emsdk = emsdk,
        .use_webgl2 = true,
        .use_emmalloc = true,
        .use_filesystem = false,
        .shell_file_path = b.path("src/solitaire.html"),
    });

    b.getInstallStep().dependOn(&link_step.step);

    const run = sokol.emRunStep(b, .{ .name = "solitaire", .emsdk = emsdk });
    run.step.dependOn(&link_step.step);

    b.step("run", "Run solitaire").dependOn(&run.step);
}
