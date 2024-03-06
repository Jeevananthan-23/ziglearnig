const builtin = @import("builtin");
const std = @import("std");
const fmt = std.fmt;
const io = std.io;

const Op = enum {
    Sum,
    Mul,
    Sub,
};

fn ask_user() !i64 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [10]u8 = undefined;
    
    try stdout.print("A number please: ", .{});

    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return std.fmt.parseInt(i64, user_input, 10);
    } else {
        return @as(i64, 0);
    }
}

fn apply_ops(comptime operations: []const Op, num: i64) i64 {
    var acc: i64 = 0;
    inline for (operations) |op| {
        switch (op) {
            .Sum => acc +%= num,
            .Mul => acc *%= num,
            .Sub => acc -%= num,
        }
    }
    return acc;
}

pub fn main() !void {
    const user_num = try ask_user();
    const ops = [4]Op{ .Sum, .Mul, .Sub, .Sub };
    const x = apply_ops(ops[0..], user_num);
    std.debug.print("Result: {}\n", .{x});
}
