const std = @import("std");
const os = std.os;
const linux = os.linux;
const allocator = std.heap.page_allocator;
const log = std.log.scoped(.server);

const State = enum { accept, recv, send };
const Socket = struct {
    handle: os.socket_t,
    buffer: [1024]u8,
    state: State,
};

pub fn main() !void {
    const entries = 32;
    const flags = 0;
    var ring = try linux.IO_Uring.init(entries, flags);
    defer ring.deinit();

    var server: Socket = undefined;
    server.handle = try os.socket(os.AF.INET, os.SOCK.STREAM, os.IPPROTO.TCP);
    defer os.closeSocket(server.handle);

    const port = 12345;
    var addr = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, port);
    var addr_len: os.socklen_t = addr.getOsSockLen();

    try os.setsockopt(server.handle, os.SOL.SOCKET, os.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try os.bind(server.handle, &addr.any, addr_len);
    const backlog = 128;
    try os.listen(server.handle, backlog);

    log.info("server listening on IP {s} port {}. CTRL+C to shutdown.", .{ "127.0.0.1", port });

    server.state = .accept;
    _ = try ring.accept(@intFromPtr(&server), server.handle, &addr.any, &addr_len, 0);

    while (true) {
        _ = try ring.submit_and_wait(1);

        while (ring.cq_ready() > 0) {
            const cqe = try ring.copy_cqe();
            var client = @as(*Socket, @ptrFromInt(@as(usize, @intCast(cqe.user_data))));

            if (cqe.res < 0) log.err("{}({}): {}", .{
                client.state,
                client.handle,
                @as(os.E, @enumFromInt(-cqe.res)),
            });

            switch (client.state) {
                .accept => {
                    client = try allocator.create(Socket);
                    client.handle = @as(os.socket_t, @intCast(cqe.res));
                    client.state = .recv;
                    _ = try ring.recv(@intFromPtr(client), client.handle, .{ .buffer = &client.buffer }, 0);
                    log.debug("{}: Received {s} bytes from {}", .{ client.state, &client.buffer.len, client.handle });
                    _ = try ring.accept(@intFromPtr(&server), server.handle, &addr.any, &addr_len, 0);
                },
                .recv => {
                    const read =
                        \\HTTP/1.1 200 OK
                        \\Connection: Keep-Alive
                        \\Keep-Alive: timeout=1
                        \\Content-Type: text/plain
                        \\Content-Length: 6
                        \\Server: server/0.1.0
                        \\
                        \\Hello
                        \\
                    ;
                    client.state = .send;
                    _ = try ring.send(@intFromPtr(client), client.handle, read, 0);
                },
                .send => {
                    os.closeSocket(client.handle);
                    allocator.destroy(client);
                },
            }
        }
    }
}
