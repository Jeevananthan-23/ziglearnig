const std = @import("std");

pub fn main() !void {
    var arr = [_]i8{ 1, 2, 3, 4, 5 };
    const target: i8 = 1;
    const result = binarysearch(&arr, target);
    std.debug.print("binarysearch for given arr: {any} and target: {} and result: {} \n", .{ arr, target, result });
}

fn binarysearch(arr: []i8, target: i8) i8 {
    var start: usize = 0;
    var end = arr.len-1;

    while (start <= end) {
        const mid = start + ((end - start) / 2);

        if (arr[mid] == target) {
            return arr[mid];
        }
        else if (arr[mid] > target) {
            end = mid - 1;
        } else {
            start = mid + 1;
        }
    }
    return -1;
}
