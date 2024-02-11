const std = @import("std");

/// Thread-safe stack, guarded by a Mutex,
/// `push`, `pop` and 'print'  can be called concurrently from the mulitple threads.
fn ConcurrentStack(comptime T: type) type {
    return struct {
        const Node = struct {
            value: T,
            next: ?*Node,
        };
        const Self = @This();

        length: usize,
        head: ?*Node,
        mutex: std.Thread.Mutex,
        allocator: std.mem.Allocator,

        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .length = 0,
                .head = null,
                .allocator = alloc,
                .mutex = .{},
            };
        }

        pub fn push(self: *Self, value: T) !void {
            self.mutex.lock();
            defer self.mutex.unlock();
            var node = try self.allocator.create(Node);
            node.value = value;
            self.length += 1;
            var head = self.head;
            node.next = head;
            self.head = node;
        }

        pub fn pop(self: *Self) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();
            var head = self.head orelse return null;
            defer self.allocator.destroy(head);
            self.length -= 1;
            self.head = head.next;
            return head.value;
        }

        pub fn print(self: *Self) void {
            self.mutex.lock();
            defer self.mutex.unlock();
            var curr = self.head;
            std.log.info("Stack {}", .{self.length});
            while (curr) |current| : (curr = current.next) {
                std.log.info("   ->{}", .{current.value});
            }
        }
    };
}

const IntStack = ConcurrentStack(i32);
const put_thread_count = 10;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    // free the memory on exit
    defer arena.deinit();

    // initialize the allocator
    var concurrentStack = IntStack.init(arena.allocator());

    var concurrentStack2 = IntStack.init(arena.allocator());

    var putters: [put_thread_count]std.Thread = undefined;
    for (&putters, 0..10) |*t, i| {
        t.* = try std.Thread.spawn(.{}, IntStack.push, .{ &concurrentStack, @as(i32, @intCast(i)) * 10 });
    }

    var getters: [put_thread_count]std.Thread = undefined;
    for (&getters) |*t| {
        t.* = try std.Thread.spawn(.{}, IntStack.print, .{&concurrentStack});
        _ = concurrentStack.pop();
    }

    var putters2: [put_thread_count]std.Thread = undefined;
    for (&putters2, 0..10) |*t, i| {
        t.* = try std.Thread.spawn(.{}, IntStack.push, .{ &concurrentStack2, @as(i32, @intCast(i)) * 100 });
    }

    var getters2: [put_thread_count]std.Thread = undefined;
    for (&getters2) |*t| {
        t.* = try std.Thread.spawn(.{}, IntStack.print, .{&concurrentStack2});
        _ = concurrentStack2.pop();
    }

    for (putters) |t|
        t.join();
    for (putters2) |t|
        t.join();
    for (getters) |t|
        t.join();
    for (getters2) |t|
        t.join();
}
