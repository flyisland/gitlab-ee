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

这是极狐GitLab 支持团队整理的 Linux 相关信息，他们在故障排除时有时会用到。此处列出是为了保持透明，也供有 Linux 经验的用户参考。如果您当前遇到极狐GitLab 问题，在尝试使用这些信息之前，建议先查看您的[支持选项](https://gitlab.cn/support)。

> [!warning]
> [协助进行系统管理超出了极狐GitLab 支持的范围](https://gitlab.cn/support)。极狐GitLab 管理员应了解其所选发行版的这些命令。如果您是极狐GitLab 支持工程师，可将此视为一个交叉参考，用于将 `yum` 转换为 `apt-get` 等。

以下大多数命令尚未标注适用于哪个发行版。欢迎贡献以帮助补充。

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

# This will provide a lot more information
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
# change the user:group ownership of a file/dir
chown root:git <file_or_dir>

# make a file executable
chmod u+x <file>
```

<a id="files-and-directories"></a>

### 文件和目录

```shell
# create a new directory and all subdirectories
mkdir -p dir/dir2/dir3

# Send a command's output to file.txt, no STDOUT
ls > file.txt

# Send a command's output to file.txt AND see it in STDOUT
ls | tee /tmp/file.txt

# Search and Replace within a file
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
# search for a file in a filesystem
find . -name 'filename.rb' -print

# locate a file
locate <filename>

# see command history
history

# search CLI history
<Control>-R
```

<a id="file-contents"></a>

### 文件内容

```shell
# -B/A = show 2 lines before/after search_term
grep -B 2 -A 2 search_term <filename>

# -<number> shows both before and after
grep -2 search_term <filename>

# Search on all files in directory (recursively)
grep -r search_term <directory>

# Grep namespace/project/name of a GitLab repository
grep 'fullpath' /var/opt/gitlab/git-data/repositories/@hashed/<repo hash>/.git/config

# search through *.gz files is the same except with zgrep
zgrep search_term <filename>

# Fast grep printing lines containing a string pattern
fgrep -R string_pattern <filename or directory>
```

<a id="cli"></a>

### CLI

```shell
# View command history
history

# Run last command that started with 'his' (3 letters min)
!his

# Search through command history
<Control>-R


# Execute last command with sudo
sudo !!
```

<a id="managing-resources"></a>

## 管理资源

<a id="memory-disk--cpu-usage"></a>

### 内存、磁盘和 CPU 使用情况

```shell
# disk space info. The '-h' gives the data in human-readable values
df -h

# size of each file/dir and its contents in the current dir
du -hd 1

# or alternative
du -h --max-depth=1

# find files greater than certain size(k, M, G) and list them in order
# get rid of the + for exact, - for less than
find / -type f -size +100M -print0 | xargs -0 du -hs | sort -h

# Find free memory on a system
free -m

# Find what processes are using memory/CPU and organize by it
# Load average is 1/CPU for 1, 5, and 15 minutes
top -o %MEM
top -o %CPU
```

<a id="strace"></a>

### Strace

```shell
# strace a process
strace -tt -T -f -y -yy -s 1024 -p <pid>

# -tt   print timestamps with microsecond accuracy

# -T    print the time spent in each syscall

# -f    also trace any child processes that forked

# -y    print the path associated with file handles

# -yy    print socket and device file handle details

# -s    max string length to print for an event

# -o    output file

# run strace on all puma processes
ps auwx | grep puma | awk '{ print " -p " $2}' | xargs strace -tt -T -f -y -yy -s 1024 -o /tmp/puma.txt
```

请注意，strace 运行时可能会对系统性能产生重大影响。

<a id="strace-resources"></a>

#### Strace 资源

- 请参阅 [strace zine](https://wizardzines.com/zines/strace/) 获取快速入门。
- Brendan Gregg 对[如何使用 strace](http://www.brendangregg.com/blog/2014-05-11/strace-wow-much-syscall.html) 有更详细的说明。

<a id="the-strace-parser-tool"></a>

### Strace Parser 工具

我们的 [strace-parser 工具](https://gitlab.com/gitlab-com/support/toolbox/strace-parser)可用于提供 `strace` 输出的高层摘要。它类似于 `strace -C`，但提供更详细的统计信息。

macOS 和 Linux 二进制文件[可在此获取](https://gitlab.com/gitlab-com/support/toolbox/strace-parser/-/tags)，如果您有 Rust 编译器，也可以从源码构建。

<a id="how-to-use-the-tool"></a>

#### 如何使用该工具

首先使用 `summary` 标志运行该工具，以获取按主动执行任务所花费时间排序的顶级进程摘要。您还可以使用`-s` 或`--sort` 标志，根据总时间、系统调用次数、PID 号和子进程数进行排序。结果数量默认为 25 个进程，但可以使用`-c`/`--count` 选项更改。完整详情请参见`--help`。

```shell
$ ./strace-parser sidekiq_trace.txt summary -c15 -s=pid

Top 15 PIDs by PID #
-----------

  pid         actv (ms)     wait (ms)     user (ms)    total (ms)    % of actv     syscalls     children
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

PIDs   93
real   0m12.287s
user   0m1.474s
sys    0m1.686s
```

根据摘要，您随后可以使用`-p`/`--pid` 查看一个或多个进程进行的系统调用详情（针对特定进程），或使用`-s`/`--stats` 标志查看排序列表。`--stats` 采用与 summary 相同的排序和计数选项。

```shell
./strace-parser sidekiq_trace.txt p 16815

PID 16815

  80 syscalls, active time: 2.364ms, user time: 7.669ms, total time: 12050.026ms
  start time: 22:46:14.830267    end time: 22:46:26.880293

  syscall                 count    total (ms)      max (ms)      avg (ms)      min (ms)    errors
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

  Slowest file open times for PID 16815:

    dur (ms)       timestamp            error         filename
  ----------    ---------------    ---------------    ---------
       0.045    22:46:16.771318           -           /opt/gitlab/embedded/service/gitlab-rails/config/database.yml
       0.043    22:46:26.877954           -           /opt/gitlab/embedded/service/gitlab-rails/config/database.yml
       0.038    22:46:22.174610           -           /opt/gitlab/embedded/service/gitlab-rails/config/database.yml
```

在上一个示例中，我们可以看到 `PID 16815` 打开哪些文件耗时更长。

当结果中没有明显异常时，获取更多上下文的一个好方法是在执行客户所执行的操作时，对您自己的极狐GitLab 实例运行 `strace`，然后比较两个结果的摘要并深入分析差异。

<a id="stats-for-the-open-syscall"></a>

#### open 系统调用的统计信息

在各种配置上调用 `open` 和 `openat`（用于访问文件）的大致数值。慢速存储可能导致 Gitaly 中出现令人头疼的 `DeadlineExceeded` 错误。

另请[参阅此条目](../operations/filesystem_benchmarking.md)，了解客户可以执行的快速测试，以检查其文件系统性能。

请记住，来自 `strace`的时间信息通常有些不准确，因此不应将微小差异视为显著差异。

|设置          | 访问时间  |
|:--------------|:--------------|
| EFS           | 10 - 30 ms     |
| 本地存储 | 0.01 - 1 ms    |

<a id="networking"></a>

## 网络

<a id="ports"></a>

### 端口

```shell
# Find the programs that are listening on ports
netstat -plnt
ss -plnt
lsof -i -P | grep <port>
```

<a id="internetdns"></a>

### 互联网/DNS

```shell
# Show domain IP address
dig +short example.com
nslookup example.com

# Check DNS using specific nameserver
# 8.8.8.8 = google, 1.1.1.1 = cloudflare, 208.67.222.222 = opendns
dig @8.8.8.8 example.com
nslookup example.com 1.1.1.1

# Find host provider
whois <ip_address> | grep -i "orgname\|netname"

# Curl headers with redirect
curl --head --location "https://example.com"

# Test if a host is reachable on the network. `ping6` works on IPv6 networks.
ping example.com

# Show the route taken to a host. `traceroute6` works on IPv6 networks.
traceroute example.com
mtr example.com

# List details of network interfaces
ip address

# Check local DNS settings
cat /etc/hosts
cat /etc/resolv.conf
systemd-resolve --status

# Capture traffic to/from a host
sudo tcpdump host www.example.com
```

<a id="package-management"></a>

## 软件包管理

```shell
# Debian/Ubuntu

# List packages
dpkg -l
apt list --installed

# Find an installed package
dpkg -l | grep <package>
apt list --installed | grep <package>

# Install a package
dpkg -i <package_name>.deb
apt-get install <package>
apt install <package>

# CentOS/RedHat

# Install a package
yum install <package>
dnf install <package> # RHEL/CentOS 8+

rpm -ivh <package_name>.rpm

# Find an installed package
rpm -qa | grep <package>
```

<a id="logs"></a>

## 日志

```shell
# Print last lines in log file where 'n'
# is the number of lines to print
tail -n /path/to/log/file
```
