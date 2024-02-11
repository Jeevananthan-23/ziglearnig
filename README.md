# ziglearnig
Repo for learning and ziglang  
- [Src(basic zig implementation)](https://github.com/Jeevananthan-23/ziglearnig/tree/main/src)

  - [hello_world.zig](https://github.com/Jeevananthan-23/ziglearnig/blob/main/src/hello_world.zig)
  - [stack.zig](https://github.com/Jeevananthan-23/ziglearnig/blob/main/src/stack.zig)
  - [concurrentstack.zig](https://github.com/Jeevananthan-23/ziglearnig/blob/main/src/concurrentstack.zig)

- [Zig-kqasyncio](https://github.com/Jeevananthan-23/ziglearnig/tree/main/zig-kqasyncio)

  linux based kernel queue asyncio with io_uring
   - [fileio.zig](https://github.com/Jeevananthan-23/ziglearnig/blob/main/zig-kqasyncio/fileio.zig)

     * implementation for fileio both blocking and nonblocking and [zig.csv](https://github.com/Jeevananthan-23/ziglearnig/blob/main/zig-kqasyncio/zig.csv)
          ``` console
            DataFusion CLI v35.0.0
           ❯ select method, avg(cast(time as double)) ||'s' as avg_time,  CASE
              WHEN AVG(throughput) >= POWER(1024, 3) THEN ROUND(AVG(throughput) / POWER(1024, 3), 2) || ' GiB'
              WHEN AVG(throughput) >= POWER(1024, 2) THEN ROUND(AVG(throughput) / POWER(1024, 2), 2) || ' MiB'
        WHEN AVG(throughput) >= 1024 THEN ROUND(AVG(throughput) / 1024, 2) || ' KiB'
        ELSE ROUND(AVG(throughput), 2) || ' B'  END || '/s' as avg_throughput
        from '/home/jeeva/zig.csv' Group by method order by avg_time  asc;
         +---------------------+-------------+----------------+
           | method              | avg_time    | avg_throughput |
           +---------------------+-------------+----------------+
           | blocking            | 0.07809158s | 1.31 GiB/s     |
          | iouring_128_entries | 0.0858811s  | 1.14 GiB/s     |
           | iouring_1_entries   | 1.54154491s | 66.67 MiB/s    |
           +---------------------+-------------+----------------+
          3 rows in set. Query took 0.140 seconds.
          ```
  - [networkio.zig](https://github.com/Jeevananthan-23/ziglearnig/blob/main/zig-kqasyncio/networkio.zig)
