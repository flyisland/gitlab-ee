---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 文件系统性能基准测试
description: 对文件系统性能进行基准测试。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

文件系统性能对极狐GitLab 的整体性能有很大影响，尤其是对代码仓库执行读取或写入的操作。以下信息有助于将文件系统性能与已知良好和糟糕的实际系统进行对比。

谈到文件系统性能，最需要关注的是网络文件系统（NFS）。不过，某些本地磁盘也可能存在 I/O 缓慢的问题。本页面的信息适用于这两种情况。

<a id="executing-benchmarks"></a>

## 执行基准测试

<a id="benchmarking-with-fio"></a>

### 使用 `fio` 进行基准测试

您应使用
[Fio](https://fio.readthedocs.io/en/latest/fio_doc.html) 测试 I/O
性能。此测试应在可能受磁盘性能低下影响的服务器上运行：

- NFS 主机以及挂载 NFS 驱动器的应用节点。
- Gitaly 节点。
- PostgreSQL 节点。

安装方法：

- 在 Ubuntu 上：`apt install fio`。
- 在由 `yum` 管理的环境中：`yum install fio`。

然后运行以下命令：

```shell
file="/path/to/nfs-or-postgres-or-gitaly/fio-benchmark-$(date +%s)"
fio --ioengine=libaio --direct=1 --gtod_reduce=1 --iodepth=64 --randrepeat=1 \
    --readwrite=randrw --name="$file" --filename="$file" \
    --size=4G --rwmixread=75 --bs=4k
```

这会在 NFS、PostgreSQL 或 Gitaly 路径中创建一个 4 GB 的文件。
Fio 按 75%/25% 的比例对该文件执行 4 KB 的读取和写入，同时运行 64 个操作。测试完成后，请务必删除该文件。

输出结果因安装的 `fio` 版本而异。以下是 `fio` v2.2.10 在联网固态硬盘（SSD）上的示例输出：

```plaintext
path/to/nfs-or-postgres-or-gitaly/fio-benchmark-1234567890: (g=0): rw=randrw, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=64
    fio-2.2.10
    Starting 1 process
    test: Laying out IO file(s) (1 file(s) / 1024MB)
    Jobs: 1 (f=1): [m(1)] [100.0% done] [131.4MB/44868KB/0KB /s] [33.7K/11.3K/0 iops] [eta 00m:00s]
    test: (groupid=0, jobs=1): err= 0: pid=10287: Sat Feb  2 17:40:10 2019
      read : io=784996KB, bw=133662KB/s, iops=33415, runt=  5873msec
      write: io=263580KB, bw=44880KB/s, iops=11219, runt=  5873msec
      cpu          : usr=6.56%, sys=23.11%, ctx=266267, majf=0, minf=8
      IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
         submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
         complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
         issued    : total=r=196249/w=65895/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
         latency   : target=0, window=0, percentile=100.00%, depth=64

    Run status group 0 (all jobs):
       READ: io=784996KB, aggrb=133661KB/s, minb=133661KB/s, maxb=133661KB/s, mint=5873msec, maxt=5873msec
      WRITE: io=263580KB, aggrb=44879KB/s, minb=44879KB/s, maxb=44879KB/s, mint=5873msec, maxt=5873msec
```

请注意此输出中的 `iops` 值。在此示例中，该 SSD 每秒执行 33,415 次读取操作和 11,219 次写入操作。机械硬盘每秒可能只有 2,000 次读取和 700 次写入操作。

<a id="simple-benchmarking"></a>

### 简单基准测试

> [!note]
> 此测试较为简单，但如果系统上没有 `fio`，
> 也可以使用。此测试可能得到良好的结果，
> 但由于读取速度及其他各种因素，性能仍可能很差。

以下单行命令可快速对文件系统的写入和读取性能进行基准测试。它会向执行命令的目录写入 1,000 个小文件，然后读取同样的 1,000 个文件。

1. 切换到相应的
   [代码仓库存储路径](../repository_storage_paths.md)的根目录。
1. 为测试创建一个临时目录，以便稍后删除：

   ```shell
   mkdir test; cd test
   ```

1. 运行以下命令：

   ```shell
   time for i in {0..1000}; do echo 'test' > "test${i}.txt"; done
   ```

1. 要对读取性能进行基准测试，请运行以下命令：

   ```shell
   time for i in {0..1000}; do cat "test${i}.txt" > /dev/null; done
   ```

1. 删除测试文件：

   ```shell
   cd ../; rm -rf test
   ```

`time for ...` 命令的输出类似如下。其中重要的指标是 `real` 时间。

```shell
$ time for i in {0..1000}; do echo 'test' > "test${i}.txt"; done

real    0m0.116s
user    0m0.025s
sys     0m0.091s

$ time for i in {0..1000}; do cat "test${i}.txt" > /dev/null; done

real    0m3.118s
user    0m1.267s
sys 0m1.663s
```

根据与多个客户合作的经验，此任务应在 10 秒内完成，才表明文件系统性能良好。
