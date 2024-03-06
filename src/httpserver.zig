const std = @import("std");

const Server = std.http.Server;

var server_gpa = std.heap.GeneralPurposeAllocator(.{}){};
const server_allocator = server_gpa.allocator();

pub fn main() !void {
    const address = try std.net.Address.parseIp("127.0.0.1", 252501);
    var server = try address.listen(.{ .reuse_port = true });

    const num_threads = 4; //try std.Thread.getCpuCount();
    const threads = try server_allocator.alloc(std.Thread, num_threads);

    for (threads) |*t| {
        t.* = try std.Thread.spawn(.{}, worker, .{&server});
    }

    std.debug.print("listening on http://{}\n", .{server.listen_address});

    for (threads) |t| {
        t.join();
    }
}

fn worker(server: *std.net.Server) !void {
    var header_buf: [8192]u8 = undefined;

    outer: while (true) {
        const connection = try server.accept();
        defer connection.stream.close();

        var http_server = Server.init(connection, &header_buf);

        var kept_alive: u8 = 0;
        while (http_server.state == .ready) {
            var request = http_server.receiveHead() catch |err| switch (err) {
                error.HttpConnectionClosing => continue :outer,
                else => |e| return e,
            };

            handler(&request, kept_alive <= 128) catch |err| {
                if (err == error.ConnectionResetByPeer) {
                    break;
                }

                std.debug.print("handler error {}\n", .{err});
                if (@errorReturnTrace()) |trace| {
                    std.debug.dumpStackTrace(trace.*);
                }

                break;
            };

            kept_alive += 1;
        }
    }
}

fn handler(request: *Server.Request, keep_alive: bool) !void {
    if (request.head.method != .GET) {
        try request.respond("", .{
            .status = .method_not_allowed,
            .keep_alive = keep_alive,
        });

        return;
    }

    if (std.mem.eql(u8, request.head.target, "/")) {
        try request.respond("Hello, World!\n", .{
            .status = .ok,
            .keep_alive = keep_alive,
        });

        return;
    }

    try request.respond("", .{
        .status = .not_found,
        .keep_alive = keep_alive,
    });
}
