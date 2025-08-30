const std = @import("std");

const project_name: []const u8 = "libschrift";

pub fn build(b: *std.Build) void {
    const check_step = b.step("check", "Check if " ++ project_name ++ " compiles");
    const test_step = b.step("test", "Run unit tests");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // libschrift
    const schrift_mod = b.createModule(.{ .target = target, .optimize = optimize });
    schrift_mod.addCSourceFile(.{ .file = b.path("libschrift/schrift.c") });
    const schrift = b.addLibrary(.{
        .name = "libschrift",
        .linkage = .static,
        .root_module = schrift_mod,
    });
    schrift.installHeadersDirectory(b.path("libschrift/"), "schrift", .{});
    schrift.linkLibC();

    // zig-libschrift
    const lib_mod = b.addModule(project_name, .{
        .root_source_file = b.path("src/schrift.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_mod.linkLibrary(schrift);

    // Check
    const test_check = b.addTest(.{
        .root_module = lib_mod,
    });
    check_step.dependOn(&test_check.step);

    // Unit testing
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    test_step.dependOn(&run_lib_unit_tests.step);
}
