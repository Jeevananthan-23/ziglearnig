const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        const Node = struct {
            value: T,
            next: ?*Node,
        };
        const Self = @This();

        length: usize,
        head: ?*Node,
        allocator: std.mem.Allocator,
        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .length = 0,
                .head = null,
                .allocator = alloc,
            };
        }

        pub fn push(self: *Self, value: T) !void {
            var node = try self.allocator.create(Node);
            node.value = value;
            self.length += 1;
            var head = self.head;
            node.next = head;
            self.head = node;
        }

        pub fn pop(self: *Self) ?T {
            var head = self.head orelse return null;
            defer self.allocator.destroy(head);
            self.length -= 1;
            self.head = head.next;
            return head.value;
        }

        pub fn top(self: *Self) ?T {
            if (self.length == 0) {
                return null;
            }
            return self.head.?.value;
        }

        pub fn count(self: *Self) usize {
            return self.length;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.count() == 0;
        }

        pub fn print(self: *Self) void {
            var curr = self.head;
            std.log.info("Stack {}", .{self.length});
            while (curr) |current| : (curr = current.next) {
                std.log.info("   ->{}", .{current.value});
            }
        }
    };
}

const IntStack = Stack(i32);

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // var stack = IntStack.init(gpa.allocator());

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    // free the memory on exit
    defer arena.deinit();

    // initialize the allocator
    var stack = IntStack.init(arena.allocator());

    try stack.push(20);
    stack.print();
    try stack.push(60);
    try stack.push(100);
    stack.print();
    std.log.info("Top of Stack {any}", .{stack.top()});
    std.log.info("Pop from stack value {?}", .{stack.pop()});
    stack.print();
    try stack.push(140);
    stack.print();
    std.log.info("Top of Stack {any}", .{stack.top()});
    std.log.info("Pop from stack value {?}", .{stack.pop()});
    std.log.info("Pop from stack value {?}", .{stack.pop()});
    std.log.info("Count of Stack {}", .{stack.count()});
    std.log.info("Top of Stack {any}", .{stack.top()});
    _ = stack.pop();
    stack.print();
    std.log.info("Is Stack Empty: {}", .{stack.isEmpty()});
}
