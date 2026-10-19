---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置极狐GitLab 软件包内置的 Puma 实例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Puma 是一款面向 Ruby 应用的快速、多线程且高并发的 HTTP 1.1 服务器。它运行核心 Rails 应用，提供极狐GitLab 面向用户的功能。

<a id="tuning-memory-use"></a>

## 调整内存使用

为减少内存使用，Puma 会派生工作进程。每次创建工作进程时，它会与主进程共享内存。只有当工作进程更改或增加其内存页时，才会使用额外内存。随着工作进程处理更多 Web 请求，Puma 工作进程随时间推移可能会使用更多物理内存。随时间推移使用的内存量取决于极狐GitLab 的使用情况。极狐GitLab 用户使用的功能越多，预期内存使用量随时间推移就越高。

为阻止内存不受控增长，GitLab Rails 应用会运行一个监督线程，当工作进程超过给定的常驻集大小（RSS）阈值并持续一定时间时，自动重启这些工作进程。

极狐GitLab 将内存限制的默认值设为 `1500Mb`。要覆盖默认值，请将 `per_worker_max_memory_mb` 设置为新的 RSS 限制（以 MB 为单位）：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['per_worker_max_memory_mb'] = 1200 # 1.2 GB
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

工作进程重启时，运行极狐GitLab 的容量会在短时间内降低。如果工作进程被替换得过于频繁，请将 `per_worker_max_memory_mb` 设置为更高的值。

工作进程数量会自动计算为以下两者的最小值：

- 进程可用的 CPU 数量，通过 `nproc` 检测。
  这会遵循 cgroup CPU 限制，因此 LXC 或 Docker 等容器中的部署会使用容器的 CPU 配额，而不是宿主机的物理核心数。
- 可用 RAM 能容纳的工作进程数量，为其他进程预留 1.5 GB，并允许每个 Puma 工作进程大约 1 GB。

如果自动计算的结果小于 2，则工作进程数量会设为 2，这是 Web 编辑器所必需的。如果自动检测产生的结果不正确，请在 `/etc/gitlab/gitlab.rb`中显式设置 `puma['worker_processes']`。

对于只有 4-8 个工作进程的小型极狐GitLab 部署，如果工作进程被过于频繁地重启（每分钟一次或更多），可能会遇到性能问题。

如果服务器有空闲内存，较高的 `per_worker_max_memory_mb` 值可能会带来好处。

<a id="worker-and-thread-sizing"></a>

## 工作进程和线程规模

在规划容量或验证自动检测的值时，可将以下内容作为指南。

一个节点绝不能少于两个 Puma 工作进程。例如，一个节点应具有：

- 2 个 CPU 核心和 8 GB 内存时，使用两个工作进程。
- 4 个 CPU 核心和 4 GB 内存时，使用两个工作进程。
- 4 个 CPU 核心和 8 GB 内存时，使用四个工作进程。
- 8 个 CPU 核心和 8 GB 内存时，使用六个工作进程。
- 8 个 CPU 核心和 16 GB 内存时，使用八个工作进程。

如果有足够的 CPU 和内存容量，您也可以增加 Puma 工作进程的数量。更多工作进程可缩短响应时间，并提高处理并行请求的能力。请运行测试以验证适合您安装环境的最佳工作进程数量。

<a id="threads"></a>

### 线程

推荐的 Puma 线程数量取决于系统总内存。一个节点应使用：

- 内存最多为 2 GB 的操作系统使用一个线程。
- 内存超过 2 GB 的操作系统使用四个线程。

更多线程会导致过度交换并降低性能。

<a id="plan-the-database-connections"></a>

## 规划数据库连接

在增加 Puma 工作进程或线程之前，请考虑对数据库连接的影响。[调优 PostgreSQL](../postgresql/tune.md) 页面上的连接需求公式会计算应用的前端连接需求：Rails 向数据库或 PgBouncer 打开的连接数。该值与 PostgreSQL 的 `max_connections` 不同，后者受数据库主机可提供的服务能力限制。有关调整 `max_connections` 大小的指导，请参阅[确定数据库主机容量](../postgresql/tune.md#determine-your-database-host-capacity-max_connections)。

有关详细的连接规划和计算，请参阅 [调优 PostgreSQL](../postgresql/tune.md) 页面。

<a id="monitor-worker-restarts"></a>

### 监控工作进程重启

如果工作进程因内存使用过高而重启，极狐GitLab 会发出日志事件。

以下是 `/var/log/gitlab/gitlab-rails/application_json.log`中此类日志事件的一个示例：

```json
{
  "severity": "WARN",
  "time": "2023-01-04T09:45:16.173Z",
  "correlation_id": null,
  "pid": 2725,
  "worker_id": "puma_0",
  "memwd_handler_class": "Gitlab::Memory::Watchdog::PumaHandler",
  "memwd_sleep_time_s": 5,
  "memwd_rss_bytes": 1077682176,
  "memwd_max_rss_bytes": 629145600,
  "memwd_max_strikes": 5,
  "memwd_cur_strikes": 6,
  "message": "rss memory limit exceeded"
}
```

`memwd_rss_bytes` 是实际消耗的内存量，而 `memwd_max_rss_bytes` 是通过 `per_worker_max_memory_mb` 设置的 RSS 限制，或由 [`DEFAULT_PUMA_WORKER_RSS_LIMIT_MB`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/memory/watchdog/configurator.rb) 定义。

<a id="change-the-worker-timeout"></a>

## 更改工作进程超时

Puma 的默认[超时为 60 秒](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/initializers/rack_timeout.rb)。

> [!note]
> `puma['worker_timeout']` 设置不会设置最大请求时长。

要将工作进程超时更改为 600 秒：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['env'] = {
      'GITLAB_RAILS_RACK_TIMEOUT' => 600
    }
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="disable-puma-clustered-mode-in-memory-constrained-environments"></a>

## 在内存受限环境中禁用 Puma 集群模式

> [!warning]
> 此功能是一项[实验](../../policy/development_stages_support.md#experiment)，可能会在不另行通知的情况下发生变化。此功能
> 尚未准备好用于生产环境。如果您想使用此功能，应先在非生产环境中进行测试。有关更多详细信息，请参阅[已知问题](#puma-single-mode-known-issues)。

在可用 RAM 少于 4 GB 的内存受限环境中，请考虑禁用 Puma 的[集群模式](https://github.com/puma/puma#clustered-mode)。

将 `workers`的数量设置为 `0`，以减少数百 MB 的内存使用：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['worker_processes'] = 0
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

与默认设置的集群模式不同，此时只有一个 Puma 进程为应用提供服务。有关 Puma 工作进程和线程设置的详细信息，请参阅 [Puma 要求](../../install/requirements.md#puma)。

以这种配置运行 Puma 的缺点是吞吐量降低，在内存受限环境中可以认为这是合理的权衡。

请记住保留足够的交换空间，以避免内存不足（OOM）情况。有关详细信息，请参阅[内存要求](../../install/requirements.md#memory)。

<a id="puma-single-mode-known-issues"></a>

### Puma 单模式已知问题

以单模式运行 Puma 时，不支持某些功能：

- [分阶段重启](https://gitlab.com/gitlab-org/gitlab/-/issues/300665)
- [内存终止机制](#tuning-memory-use)

有关更多信息，请参阅[史诗 5303](https://gitlab.com/groups/gitlab-org/-/work_items/5303)。

<a id="configuring-puma-to-listen-over-ssl"></a>

## 配置 Puma 通过 SSL 监听

使用 Linux 软件包安装进行部署时，Puma 默认通过 Unix socket 监听。要将 Puma 配置为改为通过 HTTPS 端口监听，请按照以下步骤操作：

1. 为 Puma 将监听的地址生成 SSL 证书密钥对。在下面的示例中，该地址为 `127.0.0.1`。

   > [!note]
   > 如果使用来自自定义证书颁发机构（CA）的自签名证书，
   > 请按照[文档](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)
   > 使其受到其他极狐GitLab 组件的信任。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['ssl_listen'] = '127.0.0.1'
   puma['ssl_port'] = 9111
   puma['ssl_certificate'] = '<path_to_certificate>'
   puma['ssl_certificate_key'] = '<path_to_key>'

   # Disable UNIX socket
   puma['socket'] = ""
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

> [!note]
> 除 Unix socket 外，Puma 还会通过端口 8080 上的 HTTP 进行监听，
> 以提供供 Prometheus 抓取的指标。无法让 Prometheus 通过 HTTPS 抓取这些指标，
> 相关支持正在[此议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6811)中讨论。
> 因此，从技术上讲，无法在不丢失 Prometheus 指标的情况下关闭此 HTTP 监听器。

<a id="using-an-encrypted-ssl-key"></a>

### 使用加密的 SSL 密钥

Puma 支持使用加密的私有 SSL 密钥，并可在运行时解密。以下说明展示了如何配置：

1. 如果密钥尚未加密，请使用密码对其进行加密：

   ```shell
   openssl rsa -aes256 -in /path/to/ssl-key.pem -out /path/to/encrypted-ssl-key.pem
   ```

   输入两次密码以写入加密文件。在此示例中，我们使用 `some-password-here`。

1. 创建一个打印密码的脚本或可执行文件。例如，在
   `/var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password`中创建一个基本脚本，用于回显
   密码：

   ```shell
   #!/bin/sh
   echo some-password-here
   ```

   避免将密码存储在磁盘上，并使用安全机制来获取密码，例如
   Vault。例如，该脚本可能如下所示：

   ```shell
   #!/bin/sh
   export VAULT_ADDR=http://vault-password-distribution-point:8200
   export VAULT_TOKEN=<some token>

   echo "$(vault kv get -mount=secret puma-ssl-password)"
   ```

1. 确保 Puma 进程具有执行该脚本和读取加密密钥的足够权限：

   ```shell
   chown git:git /var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password
   chmod 770 /var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password
   chmod 660 /path/to/encrypted-ssl-key.pem
   ```

1. 编辑 `/etc/gitlab/gitlab.rb`，将 `puma['ssl_certificate_key']` 替换为加密密钥，并指定
   `puma['ssl_key_password_command]`：

   ```ruby
   puma['ssl_certificate_key'] = '/path/to/encrypted-ssl-key.pem'
   puma['ssl_key_password_command'] = '/var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password'
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 如果极狐GitLab 成功启动，您应该能够移除存储在极狐GitLab 实例上的未加密 SSL 密钥。

<a id="switch-from-unicorn-to-puma"></a>

## 从 Unicorn 切换到 Puma

> [!note]
> 对于基于 Helm 的部署，请参阅
> [`webservice` chart 文档](https://gitlab.cn/docs/charts/charts/gitlab/webservice/)。

Puma 是默认的 Web 服务器，Unicorn 已不再受支持。

Puma 采用多线程架构，比 Unicorn 这类多进程应用服务器使用更少内存。在 GitLab.com 上，我们看到内存消耗减少了 40%。大多数 Rails 应用请求通常包含一定比例的 I/O 等待时间。

在 I/O 等待期间，MRI Ruby 会将 GVL 释放给其他线程。因此，多线程 Puma 仍可比单个进程处理更多请求。

切换到 Puma 时，由于两个应用服务器之间存在差异，任何 Unicorn 服务器配置都不会自动沿用。

要从 Unicorn 切换到 Puma：

1. 确定合适的 Puma [工作进程和线程设置](../../install/requirements.md#puma)。
1. 在 `/etc/gitlab/gitlab.rb`中将任何自定义 Unicorn 设置转换为 Puma 设置。

   下表总结了使用 Linux 软件包时，哪些 Unicorn 配置键对应 Puma 中的配置键，以及哪些没有对应项。

   | Unicorn                              | Puma                               |
   | ------------------------------------ | ---------------------------------- |
   | `unicorn['enable']`                  | `puma['enable']`                   |
   | `unicorn['worker_timeout']`          | `puma['worker_timeout']`           |
   | `unicorn['worker_processes']`        | `puma['worker_processes']`         |
   | 不适用                       | `puma['ha']`                       |
   | 不适用                       | `puma['min_threads']`              |
   | 不适用                       | `puma['max_threads']`              |
   | `unicorn['listen']`                  | `puma['listen']`                   |
   | `unicorn['port']`                    | `puma['port']`                     |
   | `unicorn['socket']`                  | `puma['socket']`                   |
   | `unicorn['pidfile']`                 | `puma['pidfile']`                  |
   | `unicorn['tcp_nopush']`              | 不适用                     |
   | `unicorn['backlog_socket']`          | 不适用                     |
   | `unicorn['somaxconn']`               | `puma['somaxconn']`                |
   | 不适用                       | `puma['state_path']`               |
   | `unicorn['log_directory']`           | `puma['log_directory']`            |
   | `unicorn['worker_memory_limit_min']` | 不适用                     |
   | `unicorn['worker_memory_limit_max']` | `puma['per_worker_max_memory_mb']` |
   | `unicorn['exporter_enabled']`        | `puma['exporter_enabled']`         |
   | `unicorn['exporter_address']`        | `puma['exporter_address']`         |
   | `unicorn['exporter_port']`           | `puma['exporter_port']`            |

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 可选。对于多节点部署，请将负载均衡器配置为使用[就绪检查](../load_balancer.md#readiness-check)。

<a id="troubleshooting-puma"></a>

## 故障排除 Puma

<a id="502-gateway-timeout-after-puma-spins-at-100-cpu"></a>

### Puma 占用 100% CPU 后出现 502 Gateway Timeout

当 Web 服务器在未收到 Puma 工作进程响应后超时（默认：60 秒）时，会出现此错误。如果在此过程中 CPU 占用达到 100%，则可能有某些操作耗时过长。

要修复此问题，首先必须弄清楚发生了什么。只有在您不介意用户受到停机影响时，才建议使用以下提示。否则，请跳到下一节。

1. 加载有问题的 URL
1. 运行 `sudo gdb -p <PID>` 以附加到 Puma 进程。
1. 在 GDB 窗口中，输入：

   ```plaintext
   call (void) rb_backtrace()
   ```

1. 这会强制进程生成 Ruby 回溯。请在
   `/var/log/gitlab/puma/puma_stderr.log`中查看回溯。例如，您可能会看到：

   ```plaintext
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:33:in `block in start'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:33:in `loop'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:36:in `block (2 levels) in start'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:44:in `sample'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:68:in `sample_objects'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:68:in `each_with_object'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:68:in `each'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:69:in `block in sample_objects'
   from /opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/metrics/sampler.rb:69:in `name'
   ```

1. 要查看当前线程，请运行：

   ```plaintext
   thread apply all bt
   ```

1. 使用 `gdb` 完成调试后，请务必从进程分离并退出：

   ```plaintext
   detach
   exit
   ```

如果 Puma 进程在您运行这些命令之前终止，GDB 会报告错误。为争取更多时间，您可以随时提高 Puma 工作进程超时。对于 Linux 软件包安装用户，您可以编辑 `/etc/gitlab/gitlab.rb`，将其从 60 秒增加到 600：

```ruby
gitlab_rails['env'] = {
        'GITLAB_RAILS_RACK_TIMEOUT' => 600
}
```

对于自行编译的安装，请设置环境变量。请参阅 [Puma 工作进程超时](#change-the-worker-timeout)。

[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

<a id="troubleshooting-without-affecting-other-users"></a>

#### 故障排除而不影响其他用户

上一节附加到了正在运行的 Puma 进程，这可能会对在此期间尝试访问极狐GitLab 的用户产生不良影响。如果您担心在生产系统上影响他人，可以运行一个单独的 Rails 进程来调试该问题：

1. 登录您的极狐GitLab 账号。
1. 复制导致问题的 URL（例如 `https://gitlab.com/ABC`）。
1. 为您的用户创建个人访问令牌（用户设置 -> 访问令牌）。
1. 启动 [GitLab Rails 控制台。](rails_console.md#starting-a-rails-console-session)
1. 在 Rails 控制台中，运行：

   ```ruby
   app.get '<URL FROM STEP 2>/?private_token=<TOKEN FROM STEP 3>'
   ```

   例如：

   ```ruby
   app.get 'https://gitlab.com/gitlab-org/gitlab-foss/-/issues/1?private_token=123456'
   ```

1. 在新窗口中，运行 `top`。它应显示此 Ruby 进程占用 100% CPU。记下 PID。
1. 按照上一节中关于使用 GDB 的第 2 步操作。

<a id="gitlab-api-is-not-accessible"></a>

### 极狐GitLab：API 无法访问

这通常发生在 GitLab Shell 尝试通过内部 API（例如 `http://localhost:8080/api/v4/internal/allowed`）请求授权，而检查中的某些环节失败时。此问题可能由以下原因导致：

1. 连接数据库超时（例如 PostgreSQL 或 Redis）
1. Git 钩子或推送规则出错
1. 访问代码仓库出错（例如 NFS 句柄过期）

要诊断此问题，请尝试复现该问题，然后通过 `top` 查看是否有 Puma 工作进程占用过高。请尝试使用前面记录的 `gdb` 方法。此外，使用 `strace` 可能有助于隔离问题：

```shell
strace -ttTfyyy -s 1024 -p <PID of puma worker> -o /tmp/puma.txt
```

如果无法确定是哪个 Puma 工作进程有问题，请尝试对所有 Puma 工作进程运行 `strace`，以查看 `/internal/allowed` 端点卡在哪里：

```shell
ps auwx | grep puma | awk '{ print " -p " $2}' | xargs  strace -ttTfyyy -s 1024 -o /tmp/puma.txt
```

`/tmp/puma.txt`中的输出可能有助于诊断根本原因。
