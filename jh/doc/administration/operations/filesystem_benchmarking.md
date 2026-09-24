---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 文件系统性能基准测试
description: 基准测试文件系统性能。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

文件系统性能对极狐GitLab 整体性能有重大影响，尤其是对于读取或写入 Git 仓库的操作。以下信息有助于将文件系统性能与已知的良好和较差的实际系统进行基准对比。

在讨论文件系统性能时，最大的关注点是网络文件系统（NFS）。然而，即使是一些本地磁盘也可能具有较慢的 I/O。本页信息适用于这两种情况。

<a id="executing-benchmarks"></a>

## 执行基准测试

<a id="benchmarking-with-fio"></a>

### 使用 `fio` 进行基准测试

你应该使用 [Fio](https://fio.readthedocs.io/en/latest/fio_doc.html) 来测试 I/O 性能。此测试应在可能受低磁盘性能影响的服务器上运行：

- NFS 主机以及挂载 NFS 驱动器的应用节点。
- Gitaly 节点。
- PostgreSQL 节点。

安装方式：

- 在 Ubuntu 上：`apt install fio`。
- 在 `yum` 管理的环境中：`yum install fio`。

然后运行以下命令：

```shell
file="/path/to/nfs-or-postgres-or-gitaly/fio-benchmark-$(date +%s)"
fio --ioengine=libaio --direct=1 --gtod_reduce=1 --iodepth=64 --randrepeat=1 \
    --readwrite=randrw --name="$file" --filename="$file" \
    --size=4G --rwmixread=75 --bs=4k
```

这会在 NFS、PostgreSQL 或 Gitaly 路径中创建一个 4 GB 的文件。Fio 在文件中执行 4 KB 的读取和写入，读写比例为 75%/25%，同时运行 64 个操作。测试完成后，请务必删除该文件。

输出取决于安装的 `fio` 版本。以下是来自 `fio` v2.2.10 在网络固态硬盘（SSD）上的示例输出：

```plaintext
path/to/nfs-or-postgres-or-gitaly/fio-benchmark-1234567890: (g=0): rw=randrw, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=64
    fio-2.2.10
    启动 1 个进程
    测试：正在布局 IO 文件（1 个文件 / 1024MB）
    任务：1 (f=1): [m(1)] [100.0% 完成] [131.4MB/44868KB/0KB /s] [33.7K/11.3K/0 iops] [eta 00m:00s]
    测试：(groupid=0, jobs=1): err= 0: pid=10287: Sat Feb  2 17:40:10 2019
      读取：io=784996KB, bw=133662KB/s, iops=33415, runt=  5873msec
      写入：io=263580KB, bw=44880KB/s, iops=11219, runt=  5873msec
      CPU          : usr=6.56%, sys=23.11%, ctx=266267, majf=0, minf=8
      IO 深度    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
         提交    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
         完成  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
         已发出    : total=r=196249/w=65895/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
         延迟   : target=0, window=0, percentile=100.00%, depth=64

    运行状态组 0（所有任务）：
       读取：io=784996KB, aggrb=133661KB/s, minb=133661KB/s, maxb=133661KB/s, mint=5873msec, maxt=5873msec
       写入：io=263580KB, aggrb=44879KB/s, minb=44879KB/s, maxb=44879KB/s, mint=5873msec, maxt=5873msec
```

注意输出中的 `iops` 值。在此示例中，SSD 每秒执行 33,415 次读取操作和 11,219 次写入操作。而机械磁盘可能分别产生 2,000 和 700 次读写操作。

<a id="simple-benchmarking"></a>

### 简单基准测试

> [!note]
> 此测试较为简单，但如果系统上不可用 `fio`，则可以使用。在此测试中可能获得良好结果，但由于读取速度和其他各种因素，性能仍然可能较差。

以下单行命令可快速基准测试文件系统的写入和读取性能。这会在执行命令的目录中写入 1,000 个小文件，然后读取相同的 1,000 个文件。

1. 切换到相应的 [仓库存储路径](../repository_storage_paths.md) 的根目录。
1. 为测试创建一个临时目录，以便稍后删除：

   ```shell
   mkdir test; cd test
   ```

1. 运行命令：

   ```shell
   time for i in {0..1000}; do echo 'test' > "test${i}.txt"; done
   ```

1. 要基准测试读取性能，运行命令：

   ```shell
   time for i in {0..1000}; do cat "test${i}.txt" > /dev/null; done
   ```

1. 删除测试文件：

   ```shell
   cd ../; rm -rf test
   ```

`time for ...` 命令的输出类似于以下内容。重要的指标是 `实际` 时间。

```shell
$ time for i in {0..1000}; do echo 'test' > "test${i}.txt"; done

实际    0m0.116s
用户    0m0.025s
系统     0m0.091s

$ time for i in {0..1000}; do cat "test${i}.txt" > /dev/null; done

实际    0m3.118s
用户    0m1.267s
系统 0m1.663s
```

根据与多个客户打交道的经验，此任务应在 10 秒内完成，以表明文件系统性能良好。