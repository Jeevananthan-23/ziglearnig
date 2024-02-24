const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "fileio", // "networkio"
        .root_source_file = .{ .path = "fileio.zig" }, // "networkio.zig"
        .target = target,
        .optimize = optimize,
    });


// using iofthetiger as a dependency
    const iofthetiger = b.dependency("iofthetiger", .{
        .target = target,
        .optimize = optimize,
    });
    // io has exported itself as io 
    // now you are re-exporting io
    // as a module in your project with the name io
    exe.addModule("iofthetiger", iofthetiger.module("io"));
    // you need to link to the output of the build process
    // that was done by the io package
    // in this case, io is outputting a library
    // to which your project need to link as well
   // exe.linkLibrary(iofthetiger.artifact("iofthetiger"));

    b.installArtifact(exe);
    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
