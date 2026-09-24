---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linux 速查表
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是极狐GitLab 支持团队收集的关于 Linux 的信息，他们在进行故障排查时偶尔会用到。在此列出是为了增加透明度，也为有 Linux 经验的用户提供参考。如果你目前遇到了极狐GitLab 的问题，建议先查看你的[支持选项](https://gitlab.cn/support/)，而不是直接使用这些信息。

> [!warning]
> 协助进行系统管理[超出了极狐GitLab 支持的范围](https://gitlab.cn/support/statement-of-support/#training)。极狐GitLab 管理员应了解所选发行版的相关命令。如果你是极狐GitLab 支持工程师，可以将此内容作为对照参考，以便在 `yum`、`apt-get` 等命令之间进行转换。

以下大部分命令未标注适用的 Linux 发行版，欢迎贡献者添加相关信息。

<a id="system-commands"></a>

## 系统命令

<a id="distribution-information"></a>

### 发行版信息

```shell
# Debian/Ubuntu
uname -a
lsb_release -a

# CentOS/RedHat
cat /etc/centos-release
cat /etc/redhat-release

# 这将提供更多信息
cat /etc/os-release
```

<a id="shut-down-or-reboot"></a>

### 关机或重启

```shell
shutdown -h now
reboot
```

<a id="permissions"></a>

### 权限

```shell
# 更改文件/目录的用户和组所有权
chown root:git <file_or_dir>

# 使文件可执行
chmod u+x <file>
```

<a id="files-and-directories"></a>

### 文件和目录

```shell
# 创建目录及所有必要的子目录
mkdir -p dir/dir2/dir3

# 将命令输出发送到 file.txt，不在标准输出显示
ls > file.txt

# 将命令输出发送到 file.txt 并同时显示在标准输出中
ls | tee /tmp/file.txt

# 在文件中搜索并替换
sed -i 's/original-text/new-text/g' <filename>
```

<a id="see-all-set-environment-variables"></a>

### 查看所有已设置的环境变量

```shell
env
```

<a id="searching"></a>

## 搜索

<a id="filenames"></a>

### 文件名

```shell
# 在文件系统中搜索文件
find . -name 'filename.rb' -print

# 定位文件
locate <filename>

# 查看命令历史
history

# 搜索命令行历史
<Control>-R
```

<a id="file-contents"></a>

### 文件内容

```shell
# -B/A 显示搜索词前后 2 行
grep -B 2 -A 2 search_term <filename>

# -<number> 同时显示前后指定行数
grep -2 search_term <filename>

# 递归搜索目录下所有文件
grep -r search_term <directory>

# 搜索极狐GitLab 仓库的命名空间/项目/名称
grep 'fullpath' /var/opt/gitlab/git-data/repositories/@hashed/<repo hash>/.git/config

# 搜索 *.gz 文件的用法类似，只需使用 zgrep
zgrep search_term <filename>

# 快速 grep，打印包含字符串模式的行
fgrep -R string_pattern <filename or directory>
```

<a id="cli"></a>

### 命令行

```shell
# 查看命令历史
history

# 运行上一个以 'his' 开头的命令（至少 3 个字母）
!his

# 搜索命令历史
<Control>-R

# 以 sudo 执行上一条命令
sudo !!
```

<a id="managing-resources"></a>

## 资源管理

<a id="memory-disk-cpu-usage"></a>

### 内存、磁盘和 CPU 使用情况

```shell
# 磁盘空间信息。'-h' 以人类可读的格式显示数据
df -h

# 当前目录下每个文件/目录及其内容占用的空间
du -hd 1

# 或使用另一种写法
du -h --max-depth=1

# 查找大于指定大小（k, M, G）的文件并按大小排序
# 去掉 + 号可查找精确大小，- 号表示小于
find / -type f -size +100M -print0 | xargs -0 du -hs | sort -h

# 查看系统可用内存
free -m

# 查看占用内存/CPU 的进程，并按相应资源排序
# 1、5、15 分钟的负载平均值分别为每个 CPU 的负载
top -o %MEM
top -o %CPU
```

<a id="strace"></a>

### Strace

```shell
# 跟踪进程
strace -tt -T -f -y -yy -s 1024 -p <pid>

# -tt   以微秒精度打印时间戳

# -T    打印每个系统调用花费的时间

# -f    同时跟踪所有由该进程派生的子进程

# -y    打印与文件句柄关联的路径

# -yy   打印套接字和设备文件句柄的详细信息

# -s    打印事件的最大字符串长度

# -o    指定输出文件

# 跟踪所有 puma 进程
ps auwx | grep puma | awk '{ print " -p " $2}' | xargs strace -tt -T -f -y -yy -s 1024 -o /tmp/puma.txt
```

请注意，在运行 strace 时可能会对系统性能产生重大影响。

<a id="strace-resources"></a>

#### Strace 资源

- 参阅 [strace zine](https://wizardzines.com/zines/strace/) 快速入门。
- Brendan Gregg 对[如何使用 strace](http://www.brendangregg.com/blog/2014-05-11/strace-wow-much-syscall.html) 给出了更详细的说明。

<a id="the-strace-parser-tool"></a>

### Strace 解析工具

我们的 [strace-parser 工具](https://jihulab.com/wchandler/strace-parser)可用于对 `strace` 输出进行高层次总结。它类似于 `strace -C`，但提供了更详细的统计信息。

macOS 和 Linux 可执行文件[已提供](https://jihulab.com/gitlab-com/support/toolbox/strace-parser/-/tags)，你也可以在安装了 Rust 编译器的情况下从源代码构建。

<a id="how-to-use-the-tool"></a>

#### 如何使用该工具

首先使用 `summary` 标志运行工具，获取按活跃任务时间排序的进程摘要。你还可以使用 `-s` 或 `--sort` 标志根据总时间、系统调用次数、PID 或子进程数量进行排序。默认显示 25 个进程，但可以通过 `-c`/`--count` 选项调整结果数量。更多详情请查看 `--help`。

```shell
$ ./strace-parser sidekiq_trace.txt summary -c15 -s=pid

按 PID 排序的前 15 个 PID
-----------

  pid         活跃 (ms)     等待 (ms)     用户 (ms)    总时间 (ms)    活跃占比 %     系统调用     子进程
  -------    ----------    ----------    ----------    ----------    ---------    ---------    ---------
  16706           0.000         0.000         0.000         0.000        0.00%            0            0
  16708           0.000         0.000         0.000         0.000        0.00%            0            0
  16716           0.000         0.000         0.000         0.000        0.00%            0            0
  16717           0.000         0.000         0.000         0.000        0.00%            0            0
  16718           0.000         0.000         0.000         0.000        0.00%            0            0
  16719           0.000         0.000         0.000         0.000        0.00%            0            0
  16720           0.389      9796.434         1.090      9797.912        0.02%           16            0
  16721           0.000         0.000         0.000         0.000        0.00%            0            0
  16722           0.000         0.000         0.000         0.000        0.00%            0            0
  16723           0.000         0.000         0.000         0.000        0.00%            0            0
  16804           0.218     11099.535         1.881     11101.634        0.01%           36            0
  16813           0.000         0.000         0.000         0.000        0.00%            0            0
  16814           1.740     11825.640         4.616     11831.996        0.10%           57            0
  16815           2.364     12039.993         7.669     12050.026        0.14%           80            0
  16816           0.000         0.000         0.000         0.000        0.00%            0            0

PID 总数   93
实际用时   0m12.287s
用户时间   0m1.474s
系统时间   0m1.686s
```

根据摘要，你可以查看一个或多个进程的系统调用详情，针对特定进程使用 `-p`/`--pid` 标志，或使用 `-s`/`--stats` 标志获取排序列表。`--stats` 接受的排序与计数选项与 summary 相同。

```shell
./strace-parser sidekiq_trace.txt p 16815

PID 16815

  80 次系统调用, 活跃时间: 2.364ms, 用户时间: 7.669ms, 总时间: 12050.026ms
  开始时间: 22:46:14.830267    结束时间: 22:46:26.880293

  系统调用                  次数    总计 (ms)      最大 (ms)      平均 (ms)      最小 (ms)    错误
  -----------------    --------    ----------    ----------    ----------    ----------    --------
  futex                       5     10100.229      5400.106      2020.046         0.022    ETIMEDOUT: 2
  restart_syscall             1      1939.764      1939.764      1939.764      1939.764    ETIMEDOUT: 1
  getpid                     33         1.020         0.046         0.031         0.018
  clock_gettime              14         0.420         0.038         0.030         0.021
  stat                        6         0.277         0.072         0.046         0.031
  read                        6         0.170         0.036         0.028         0.020
  openat                      3         0.126         0.045         0.042         0.038
  close                       3         0.099         0.034         0.033         0.031
  lseek                       3         0.089         0.035         0.030         0.021
  ioctl                       3         0.082         0.033         0.027         0.023    ENOTTY: 3
  fstat                       3         0.081         0.034         0.027         0.022
  ---------------

  PID 16815 最慢的文件打开时间：

    耗时 (ms)       时间戳            错误         文件名
  ----------    ---------------    ---------------    ---------
       0.045    22:46:16.771318           -           /opt/gitlab/embedded/service/gitlab-rails/config/database.yml
       0.043    22:46:26.877954           -           /opt/gitlab/embedded/service/gitlab-rails/config/database.yml
       0.038    22:46:22.174610           -           /opt/gitlab/embedded/service/gitlab-rails/config/database.yml
```

在上面的示例中，我们可以看出 PID 16815 打开哪些文件耗时较长。

如果结果中没有发现明显问题，一个好的做法是在你自己的极狐GitLab 实例上执行客户所进行的操作时运行 `strace`，然后对比两边的摘要并深入分析差异。

<a id="stats-for-the-open-syscall"></a>

#### 关于 open 系统调用的统计数据

各种配置下 `open` 和 `openat`（用于访问文件）调用的大致耗时。存储速度慢可能导致 Gitaly 出现 `DeadlineExceeded` 错误。

另请参阅手册中的[此条目](../operations/filesystem_benchmarking.md)，其中包含客户可以执行以检查文件系统性能的快速测试。

请记住，`strace` 的计时信息通常存在一定的不准确性，因此微小的差异不应视为显著。

| 配置          | 访问时间  |
|:--------------|:--------------|
| EFS           | 10 - 30 ms     |
| 本地存储 | 0.01 - 1 ms    |

<a id="networking"></a>

## 网络

<a id="ports"></a>

### 端口

```shell
# 查找正在监听端口的程序
netstat -plnt
ss -plnt
lsof -i -P | grep <port>
```

<a id="internet-dns"></a>

### 互联网/DNS

```shell
# 显示域名的 IP 地址
dig +short example.com
nslookup example.com

# 使用指定 DNS 服务器检查 DNS
# 8.8.8.8 = google, 1.1.1.1 = cloudflare, 208.67.222.222 = opendns
dig @8.8.8.8 example.com
nslookup example.com 1.1.1.1

# 查找主机服务商
whois <ip_address> | grep -i "orgname\|netname"

# 跟踪重定向的 curl header
curl --head --location "https://example.com"

# 测试主机是否可达。`ping6` 用于 IPv6 网络。
ping example.com

# 显示到主机的路由追踪。`traceroute6` 用于 IPv6 网络。
traceroute example.com
mtr example.com

# 列出网络接口详情
ip address

# 检查本地 DNS 设置
cat /etc/hosts
cat /etc/resolv.conf
systemd-resolve --status

# 捕获发往/来自主机的流量
sudo tcpdump host www.example.com
```

<a id="package-management"></a>

## 软件包管理

```shell
# Debian/Ubuntu

# 列出软件包
dpkg -l
apt list --installed

# 查找已安装的软件包
dpkg -l | grep <package>
apt list --installed | grep <package>

# 安装软件包
dpkg -i <package_name>.deb
apt-get install <package>
apt install <package>

# CentOS/RedHat

# 安装软件包
yum install <package>
dnf install <package> # RHEL/CentOS 8+

rpm -ivh <package_name>.rpm

# 查找已安装的软件包
rpm -qa | grep <package>
```

<a id="logs"></a>

## 日志

```shell
# 打印日志文件最后 n 行
tail -n /path/to/log/file
```