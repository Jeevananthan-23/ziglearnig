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
              ELSE ROUND(AVG(throughput), 2) || ' B' 
            END || '/s' as avg_throughput
            from 'zig.csv' Group by method order by avg_time  asc;
        +---------------------+-------------+----------------+
        | method              | avg_time    | avg_throughput |
        +---------------------+-------------+----------------+
        | blocking            | 0.07809158s | 1.31 GiB/s     |
        | iouring_128_entries | 0.0858811s  | 1.14 GiB/s     |
        | iouring_1_entries   | 1.54154491s | 66.67 MiB/s    |
        +---------------------+-------------+----------------+
        3 rows in set. Query took 0.008 seconds.
          ```
  - [networkio.zig](https://github.com/Jeevananthan-23/ziglearnig/blob/main/zig-kqasyncio/networkio.zig)


```mermaid
gantt
    method,time,throughput
    dateFormat x
    axisFormat %S s
    section random

blocking,0.0841397,1246232159
iouring_1_entries,1.3397952,78263901.83
iouring_128_entries,0.0893614,1173410443
blocking,0.0662435,1582911531
iouring_1_entries,1.3441057,78012912.23
iouring_128_entries,0.0757876,1383571983
blocking,0.0651298,1609978842
iouring_1_entries,1.4067092,74541063.64
iouring_128_entries,0.0787227,1331986835
blocking,0.064894,1615828890
iouring_1_entries,1.3778989,76099632.56
iouring_128_entries,0.0915011,1145970923
blocking,0.0699105,1499883422
iouring_1_entries,1.3549854,77386516.49
iouring_128_entries,0.0877142,1195446119
blocking,0.065341,1604774950
iouring_1_entries,2.3245167,45109419.95
iouring_128_entries,0.0840157,1248071491
blocking,0.077727,1349049880
iouring_1_entries,1.7584846,59629524.19
iouring_128_entries,0.0832028,1260265280
blocking,0.1377761,761072493.7
iouring_1_entries,1.5205997,68958056.48
iouring_128_entries,0.0985813,1063666233
blocking,0.0703455,1490608497
iouring_1_entries,1.6014589,65476297.89
iouring_128_entries,0.0800825,1309369712
blocking,0.0794087,1320479998
iouring_1_entries,1.3868948,75606022.89
iouring_128_entries,0.0898417,1167137309
```