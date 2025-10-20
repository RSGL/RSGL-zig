const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cRSGL_gl = b.addTranslateC(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("renderers/RSGL_gl.h")
    });
    cRSGL_gl.addIncludePath(b.path("."));
    cRSGL_gl.defineCMacro("RSGL_IMPLEMENTATION", "");

    const cRSGL_gl1 = b.addTranslateC(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("renderers/RSGL_gl1.h")
    });
    cRSGL_gl1.addIncludePath(b.path("."));
    cRSGL_gl1.defineCMacro("RSGL_IMPLEMENTATION", "");

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .root_source_file = b.path("root.zig"),
        .imports = &.{
            .{ .name = "gl", .module = cRSGL_gl.createModule() },
            .{ .name = "gl1", .module = cRSGL_gl1.createModule() },
        }
    });

    switch (target.result.os.tag) {
        .linux, .freebsd, .openbsd, .dragonfly => {
            mod.linkSystemLibrary("GL", .{.needed = true});
        },
        .macos => {
            mod.linkFramework("OpenGL", .{.needed = true});
        },
        .windows => {
            mod.linkSystemLibrary("opengl32", .{.needed = true});
        },
        else => {}
    }
}
