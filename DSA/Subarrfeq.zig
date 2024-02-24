const std = @import("std");

fn midRange(arr: []u8, n: usize, k: u8) !void {
    var start: usize = 0;
    var end = n;

    var map = std.AutoHashMap(u8, u8).init(std.heap.page_allocator);
    defer map.deinit();

    var i: u8 = 0;
    var j: u8 = 0;

    while (j < n): (j += 1) {
        var kv = try map.getOrPutValue(arr[j], 0);
        try map.put(arr[j], kv.value_ptr.* + 1);
        if (map.count() < k) continue;

        while (map.count() == k) : (i += 1) { // move the starting index of window
            // as considering the (j-1)th and i-th index
            var windowLen = (j - 1) - i + 1;
            var subArrayLen = end - start + 1;

            if (windowLen < subArrayLen) {
                start = i;
                end = j - 1;
            }

            // Remove elements from left

            // If freq == 1 then totally erase
            if (map.get(arr[i]) == 1) {
                _ = map.remove(arr[i]);
            }

            // decrease freq by 1
            else {
                try map.put(arr[i], map.get(arr[i]).? - 1);
            }

            std.debug.print("map: {any}\n", .{map.getEntry(arr[i])});
        }
    }
    if (start == 0 and end == n) {
        std.debug.print("Invaild k:{}\n", .{k});
    } else {
        std.debug.print("start: {}  end:{}\n", .{ start, end });
    }
}

pub fn main() !void {
    var arr = [_]u8{ 1, 2, 1, 3, 4 };
    const n = arr.len;
    const k = 3;

    try midRange(&arr, n, k);
}
