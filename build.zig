const std = @import("std");

pub fn build(b: *std.Build) void {
    const check_step = b.step("check", "Check if zig-libschrift compiles");
    const test_step = b.step("test", "Run unit tests");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // libschrift
    const libschrift_dep = b.dependency("libschrift", .{ .target = target, .optimize = optimize });
    const libschrift_artifact = libschrift_dep.artifact("libschrift");

    // zig-libschrift
    const schrift_mod = b.addModule("schrift", .{
        .root_source_file = b.path("src/schrift.zig"),
        .target = target,
        .optimize = optimize,
    });
    schrift_mod.linkLibrary(libschrift_artifact);

    // Check
    const test_check = b.addTest(.{
        .root_module = schrift_mod,
    });
    check_step.dependOn(&test_check.step);

    // Unit testing
    const lib_unit_tests = b.addTest(.{
        .root_module = schrift_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    test_step.dependOn(&run_lib_unit_tests.step);
}
