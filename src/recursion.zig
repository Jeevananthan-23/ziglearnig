// const std = @import("std");

// pub fn recursive(x: usize) void {
//     if (x == 0) {
//         return;
//     }
//     var stuff = @Vector(x, usize);

//     for (0..x) |i|{
//         stuff+=i;
//     }

//      recursive(x - 1);
// }

// pub fn main() void {
//  recursive(50_000);
// }




const std = @import("std");

pub fn recursive(x: u32) !void {
    if (x == 0 or x == 1) return;
    var stuff = try std.ArrayList(u32).initCapacity(std.heap.page_allocator, x);
    stuff.deinit();

    for (0..x) |i| {
         try stuff.append(@as(u32, @intCast(i)));
    }
    try recursive(x - 1);
}

pub fn main() !void {
    try recursive(50_000);
}
