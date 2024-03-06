// const std = @import("std");

// pub fn recursive(x: u32) void {
//     if (x == 0) {
//         return;
//     }
//     const stuff = @Vector(50_000, u32);

//     for (0..x) |i| {
//         stuff[i] = i;
//     }

//     recursive(x - 1);
// }

// pub fn main() void {
//     recursive(50_000);
// }

const std = @import("std");

pub fn recursive(x: u32) !void {
    if (x == 0 or x == 1) return;
    var stuff = try std.ArrayList(u32).initCapacity(std.heap.page_allocator, x);
    defer stuff.deinit();

    for (0..x) |i| {
         try stuff.append(@as(u32, @intCast(i)));
    }
    try recursive(x - 1);
}

pub fn main() !void {
    try recursive(50_00);
}
