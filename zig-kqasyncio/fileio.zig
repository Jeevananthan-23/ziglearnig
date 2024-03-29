const std = @import("std");
const IO = @import("iofthetiger").IO;


const OUT_FILE = "out.bin";
const BUFFER_SIZE: u64 = 4096;

fn readNBytes(
    allocator: *const std.mem.Allocator,
    filename: []const u8,
    n: usize,
) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var data = try allocator.alloc(u8, n);
    var buf = try allocator.alloc(u8, BUFFER_SIZE);

    var written: usize = 0;
    while (data.len < n) {
        var nwritten = try file.read(buf);
        @memcpy(data[written..], buf[0..nwritten]);
        written += nwritten;
    }

    std.debug.assert(data.len == n);
    return data;
}

fn benchmarkIOUringNEntries(
    allocator: *const std.mem.Allocator,
    data: []const u8,
    nEntries: u13,
) !void {
    const name = try std.fmt.allocPrint(allocator.*, "iouring_{}_entries", .{nEntries});
    defer allocator.free(name);

    var b = try Benchmark.init(allocator, name, data);
    defer b.stop();

    var ring = try std.os.linux.IO_Uring.init(nEntries, 0);
    defer ring.deinit();

    var cqes = try allocator.alloc(std.os.linux.io_uring_cqe, nEntries);
    defer allocator.free(cqes);

    var i: usize = 0;
    while (i < data.len) : (i += BUFFER_SIZE * nEntries) {
        var submittedEntries: u32 = 0;
        var j: usize = 0;
        while (j < nEntries) : (j += 1) {
            const base = i + j * BUFFER_SIZE;
            if (base >= data.len) {
                break;
            }
            submittedEntries += 1;
            const size = @min(BUFFER_SIZE, data.len - base);
            _ = try ring.write(0, b.file.handle, data[base .. base + size], base);
        }

        const submitted = try ring.submit_and_wait(submittedEntries);
        std.debug.assert(submitted == submittedEntries);

        const waited = try ring.copy_cqes(cqes[0..submitted], submitted);
        std.debug.assert(waited == submitted);

        for (cqes[0..submitted]) |*cqe| {
            std.debug.assert(cqe.err() == .SUCCESS);
            std.debug.assert(cqe.res >= 0);
            const n = @as(usize, @intCast(cqe.res));
            std.debug.assert(n <= BUFFER_SIZE);
        }
    }
}

const Benchmark = struct {
    t: std.time.Timer,
    file: std.fs.File,
    data: []const u8,
    allocator: *const std.mem.Allocator,

    fn init(
        allocator: *const std.mem.Allocator,
        name: []const u8,
        data: []const u8,
    ) !Benchmark {
        try std.io.getStdOut().writer().print("{s}", .{name});

        var file = try std.fs.cwd().createFile(OUT_FILE, .{
            .truncate = true,
        });

        return Benchmark{
            .t = try std.time.Timer.start(),
            .file = file,
            .data = data,
            .allocator = allocator,
        };
    }

    fn stop(b: *Benchmark) void {
        const s = @as(f64, @floatFromInt(b.t.read())) / std.time.ns_per_s;
        std.io.getStdOut().writer().print(
            ",{d},{d}\n",
            .{ s, @as(f64, @floatFromInt(b.data.len)) / s },
        ) catch unreachable;

        b.file.close();

        var in = readNBytes(b.allocator, OUT_FILE, b.data.len) catch unreachable;
        std.debug.assert(std.mem.eql(u8, in, b.data));
        b.allocator.free(in);
    }
};

pub fn main() !void {
    var allocator = &std.heap.page_allocator;

    const SIZE = 104857600; // 100MiB
    var data = try readNBytes(allocator, "/dev/random", SIZE);
    defer allocator.free(data);

     // Cross-platform IO setup.
    var io = try IO.init(128, 0);
    defer io.deinit();
    
    const RUNS = 10;
    var run: usize = 0;
    while (run < RUNS) : (run += 1) {
        {
            var b = try Benchmark.init(allocator, "blocking", data);
            defer b.stop();

            var i: usize = 0;
            while (i < data.len) : (i += BUFFER_SIZE) {
                const size = @min(BUFFER_SIZE, data.len - i);
                const n = try b.file.write(data[i .. i + size]);
                std.debug.assert(n == size);
            }
        }

        try benchmarkIOUringNEntries(allocator, data, 1);
        try benchmarkIOUringNEntries(allocator, data, 128);
    }
}

// DataFusion CLI v35.0.0
// ❯ select method, avg(cast(time as double)) ||'s' as avg_time,  CASE
//      WHEN AVG(throughput) >= POWER(1024, 3) THEN ROUND(AVG(throughput) / POWER(1024, 3), 2) || ' GiB'
//      WHEN AVG(throughput) >= POWER(1024, 2) THEN ROUND(AVG(throughput) / POWER(1024, 2), 2) || ' MiB'
//      WHEN AVG(throughput) >= 1024 THEN ROUND(AVG(throughput) / 1024, 2) || ' KiB'
//      ELSE ROUND(AVG(throughput), 2) || ' B'
//      END || '/s' as avg_throughput  from '/home/jeeva/zig.csv' Group by method order by avg_time  asc;
// +---------------------+-------------+----------------+
// | method              | avg_time    | avg_throughput |
// +---------------------+-------------+----------------+
// | blocking            | 0.07809158s | 1.31 GiB/s     |
// | iouring_128_entries | 0.0858811s  | 1.14 GiB/s     |
// | iouring_1_entries   | 1.54154491s | 66.67 MiB/s    |
// +---------------------+-------------+----------------+
// 3 rows in set. Query took 0.140 seconds.
