---
stage: GitLab Delivery
group: Operate
info: 要确定与此页面关联的阶段/群组所分配的技术文档工程师，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置极狐GitLab 包中自带的 Puma 实例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Puma 是一款快速、多线程且高并发的 HTTP 1.1 服务器，适用于
Ruby 应用程序。它运行着为极狐GitLab 提供面向用户功能的核心 Rails 应用程序。

<a id="tuning-memory-use"></a>

## 优化内存使用

为了减少内存使用，Puma 会派生（fork）工作进程。每次创建工作进程时，
它会与主进程共享内存。工作进程仅在更改或添加内存页时才会使用额外内存。
随着工作进程处理更多网络请求，这可能导致 Puma 工作进程随时间推移使用更多物理内存。随时间推移所使用的
内存量取决于对极狐GitLab 的使用情况。极狐GitLab 用户使用的功能越多，
随时间推移预期的内存使用就越高。

为阻止内存不受控制地增长，极狐GitLab Rails 应用程序运行一个监控线程，
如果工作进程在特定时间内超出给定的常驻集大小（RSS）阈值，该线程会自动重启它们。

极狐GitLab 将内存限制的默认值设置为 `1500Mb`。要覆盖默认值，
请将 `per_worker_max_memory_mb` 设置为以兆字节为单位的新 RSS 限制：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['per_worker_max_memory_mb'] = 1200 # 1.2 GB
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

当工作进程重启时，极狐GitLab 的运行能力会在短时间内降低。
如果工作进程被替换得过于频繁，请将 `per_worker_max_memory_mb` 设置为更高的值。

工作进程数根据 CPU 核心数量计算。如果工作进程重启过于频繁（每分钟一次或更多），
一个 4-8 个工作进程的小型极狐GitLab 部署可能会遇到性能问题。

如果服务器有空闲内存，较高的 `per_worker_max_memory_mb` 值可能是有益的。

<a id="plan-the-database-connections"></a>

## 规划数据库连接

在增加 Puma 工作进程数或线程数之前，请考虑对 PostgreSQL `max_connections` 设置的数据库连接影响。

有关详细的连接规划和计算，请参见 [优化 PostgreSQL](../postgresql/tune.md) 页面。

<a id="monitor-worker-restarts"></a>

### 监控工作进程重启

如果工作进程因内存使用过高而重启，极狐GitLab 会发出日志事件。

以下是 `/var/log/gitlab/gitlab-rails/application_json.log` 中其中一个日志事件的示例：

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

`memwd_rss_bytes` 是实际消耗的内存量，`memwd_max_rss_bytes` 是
通过 `per_worker_max_memory_mb` 或由
[`DEFAULT_PUMA_WORKER_RSS_LIMIT_MB`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/memory/watchdog/configurator.rb) 定义的 RSS 限制。

<a id="change-the-worker-timeout"></a>

## 更改工作进程超时时间

默认 Puma [超时时间为 60 秒](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/initializers/rack_timeout.rb)。

> [!note]
> `puma['worker_timeout']` 设置不会设置最大请求持续时间。

要将工作进程超时时间更改为 600 秒：

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
> 此功能是一个 [实验](../../policy/development_stages_support.md#experiment)，可能随时更改，恕不另行通知。此功能
> 尚未准备好用于生产环境。如果要使用此功能，应先
> 在生产环境之外进行测试。有关更多详细信息，请参阅 [已知问题](#puma-single-mode-known-issues)。

在可用 RAM 少于 4 GB 的内存受限环境中，考虑禁用 Puma
[集群模式](https://github.com/puma/puma#clustered-mode)。

将 `workers` 数量设置为 `0` 可减少数百 MB 的内存使用量：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['worker_processes'] = 0
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

与默认设置的集群模式不同，只有一个 Puma 进程为应用程序提供服务。
有关 Puma 工作进程和线程设置的详细信息，请参见 [Puma 要求](../../install/requirements.md#puma)。

在此配置下运行 Puma 的缺点是吞吐量降低，这在内存受限环境中可以被视为
一个合理的权衡。

请记住要有足够的交换空间（swap）以避免内存不足（OOM）
的情况。有关详细信息，请查看 [内存要求](../../install/requirements.md#memory)。

<a id="puma-single-mode-known-issues"></a>

### Puma 单模式已知问题

在单模式下运行 Puma 时，不支持以下功能：

- [分阶段重启](https://gitlab.com/gitlab-org/gitlab/-/issues/300665)
- [内存杀手](#tuning-memory-use)

有关更多信息，请参见 [史诗 5303](https://gitlab.com/groups/gitlab-org/-/epics/5303)。

<a id="configuring-puma-to-listen-over-ssl"></a>

## 配置 Puma 以通过 SSL 监听

当通过 Linux 软件包安装进行部署时，Puma 默认通过 Unix 套接字进行监听。要改为配置 Puma 监听 HTTPS 端口，请
按照以下步骤操作：

1. 为 Puma 将要监听的地址生成一个 SSL 证书密钥对。在下面的示例中，该地址为 `127.0.0.1`。

   > [!note]
   > 如果使用的是来自自定义证书颁发机构（CA）的自签名证书，
   > 请遵循 [文档](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)
   > 使其被其他极狐GitLab 组件信任。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   puma['ssl_listen'] = '127.0.0.1'
   puma['ssl_port'] = 9111
   puma['ssl_certificate'] = '<path_to_certificate>'
   puma['ssl_certificate_key'] = '<path_to_key>'

   # 禁用 UNIX 套接字
   puma['socket'] = ""
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

> [!note]
> 除了 Unix 套接字，Puma 还会在端口 8080 上通过 HTTP 监听，以提供
> 供 Prometheus 抓取的指标。无法
> 使 Prometheus 通过 HTTPS 抓取它们，对此的支持讨论
> [在此议题中](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6811)。
> 因此，从技术上讲，在不丢失 Prometheus 指标的情况下关闭此 HTTP 监听器是不可能的。

<a id="using-an-encrypted-ssl-key"></a>

### 使用加密的 SSL 密钥

{{< history >}}

- [在极狐GitLab 16.1 中引入](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7799)。

{{< /history >}}

Puma 支持使用加密的私有 SSL 密钥，该密钥可以在运行时
解密。以下说明阐述了如何
配置此功能：

1. 如果尚未加密，请使用密码加密密钥：

   ```shell
   openssl rsa -aes256 -in /path/to/ssl-key.pem -out /path/to/encrypted-ssl-key.pem
   ```

   输入两次密码以写入加密文件。在此
   示例中，我们使用 `some-password-here`。

1. 创建一个打印密码的脚本或可执行文件。例如，
   在
   `/var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password` 中创建一个基本脚本，
   用于输出密码：

   ```shell
   #!/bin/sh
   echo some-password-here
   ```

   避免将密码存储在磁盘上，而应使用诸如 Vault 之类的安全机制来获取密码。
   例如，脚本可能如下所示：

   ```shell
   #!/bin/sh
   export VAULT_ADDR=http://vault-password-distribution-point:8200
   export VAULT_TOKEN=<some token>

   echo "$(vault kv get -mount=secret puma-ssl-password)"
   ```

1. 确保 Puma 进程具有足够的权限来执行该
   脚本并读取加密的密钥：

   ```shell
   chown git:git /var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password
   chmod 770 /var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password
   chmod 660 /path/to/encrypted-ssl-key.pem
   ```

1. 编辑 `/etc/gitlab/gitlab.rb`，并将 `puma['ssl_certificate_key']` 替换为加密的密钥，并指定
   `puma['ssl_key_password_command]`：

   ```ruby
   puma['ssl_certificate_key'] = '/path/to/encrypted-ssl-key.pem'
   puma['ssl_key_password_command'] = '/var/opt/gitlab/gitlab-rails/etc/puma-ssl-key-password'
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 如果极狐GitLab 成功启动，你应该能够删除
   存储在极狐GitLab 实例上的未加密 SSL 密钥。

<a id="switch-from-unicorn-to-puma"></a>

## 从 Unicorn 切换到 Puma

> [!note]
> 对于基于 Helm 的部署，请参见
> [`webservice` chart 文档](https://gitlab.cn/docs/charts/charts/gitlab/webservice/)。

Puma 是默认的 Web 服务器，Unicorn 已不再受支持。

Puma 拥有多线程架构，比像 Unicorn 这样的多进程
应用服务器使用更少的内存。在 GitLab.com 上，我们看到内存消耗降低了 40%。
大多数 Rails 应用程序请求通常包含一定比例的 I/O 等待时间。

在 I/O 等待时间期间，MRI Ruby 会将 GVL 释放给其他线程。
因此，多线程的 Puma 仍然可以比单个进程处理更多请求。

切换到 Puma 时，由于两个应用服务器之间的差异，任何 Unicorn 服务器配置都不会
自动迁移。

要从 Unicorn 切换到 Puma：

1. 确定合适的 Puma [工作进程和线程设置](../../install/requirements.md#puma)。
1. 在 `/etc/gitlab/gitlab.rb` 中将任何自定义的 Unicorn 设置转换为 Puma 设置。

   下表总结了在使用 Linux 软件包时，哪些 Unicorn 配置键对应于 Puma
   中的键，以及哪些键没有对应的部分。

   | Unicorn                              | Puma                               |
   | ------------------------------------ | ---------------------------------- |
   | `unicorn['enable']`                  | `puma['enable']`                   |
   | `unicorn['worker_timeout']`          | `puma['worker_timeout']`           |
   | `unicorn['worker_processes']`        | `puma['worker_processes']`         |
   | 不适用                               | `puma['ha']`                       |
   | 不适用                               | `puma['min_threads']`              |
   | 不适用                               | `puma['max_threads']`              |
   | `unicorn['listen']`                  | `puma['listen']`                   |
   | `unicorn['port']`                    | `puma['port']`                     |
   | `unicorn['socket']`                  | `puma['socket']`                   |
   | `unicorn['pidfile']`                 | `puma['pidfile']`                  |
   | `unicorn['tcp_nopush']`              | 不适用                             |
   | `unicorn['backlog_socket']`          | 不适用                             |
   | `unicorn['somaxconn']`               | `puma['somaxconn']`                |
   | 不适用                               | `puma['state_path']`               |
   | `unicorn['log_directory']`           | `puma['log_directory']`            |
   | `unicorn['worker_memory_limit_min']` | 不适用                             |
   | `unicorn['worker_memory_limit_max']` | `puma['per_worker_max_memory_mb']` |
   | `unicorn['exporter_enabled']`        | `puma['exporter_enabled']`         |
   | `unicorn['exporter_address']`        | `puma['exporter_address']`         |
   | `unicorn['exporter_port']`           | `puma['exporter_port']`            |

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 可选。对于多节点部署，将负载均衡器配置为使用
   [就绪检查](../load_balancer.md#readiness-check)。

<a id="troubleshooting-puma"></a>

## 排查 Puma 问题

<a id="502-gateway-timeout-after-puma-spins-at-100-cpu"></a>

### Puma 在 100% CPU 旋转后出现 502 网关超时

此错误发生在 Web 服务器在未收到 Puma 工作进程的响应后超时时（默认值：60 秒）。
如果在此过程中 CPU 占用率达到 100%，
则可能存在某些操作耗时过长。

要解决此问题，我们首先必须弄清楚发生了什么。仅当你不介意用户受到
宕机影响时，才建议使用以下提示。否则，请跳至下一部分。

1. 加载有问题的 URL。
1. 运行 `sudo gdb -p <PID>` 以附加到 Puma 进程。
1. 在 GDB 窗口中，输入：

   ```plaintext
   call (void) rb_backtrace()
   ```

1. 这会强制该进程生成 Ruby 回溯。检查
   `/var/log/gitlab/puma/puma_stderr.log` 中的回溯。例如，你可能会看到：

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

1. 使用 `gdb` 完成调试后，务必从进程分离并退出：

   ```plaintext
   detach
   exit
   ```

如果在运行这些命令之前 Puma 进程终止，GDB 会报告错误。
为了争取更多时间，你可以随时提高
Puma 工作进程超时时间。对于 Linux 软件包安装的用户，可以编辑 `/etc/gitlab/gitlab.rb` 并
将其从 60 秒增加到 600 秒：

```ruby
gitlab_rails['env'] = {
        'GITLAB_RAILS_RACK_TIMEOUT' => 600
}
```

对于自编译安装，请设置环境变量。
请参考 [Puma 工作进程超时](puma.md#change-the-worker-timeout)。

[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab 以使更改生效。

<a id="troubleshooting-without-affecting-other-users"></a>

#### 在不影响其他用户的情况下进行排查

上一节附加到了正在运行的 Puma 进程，这可能会
在此期间对尝试访问极狐GitLab 的用户产生不良影响。如果你
担心在生产系统上影响他人，可以运行一个
单独的 Rails 进程来调试问题：

1. 登录你的极狐GitLab 帐户。
1. 复制导致问题的 URL（例如，`https://gitlab.com/ABC`）。
1. 为用户创建一个个人访问令牌（用户设置 -> 访问令牌）。
1. 调出 [极狐GitLab Rails 控制台。](rails_console.md#starting-a-rails-console-session)
1. 在 Rails 控制台中，运行：

   ```ruby
   app.get '<步骤 2 中的 URL>/?private_token=<步骤 3 中的令牌>'
   ```

   例如：

   ```ruby
   app.get 'https://gitlab.com/gitlab-org/gitlab-foss/-/issues/1?private_token=123456'
   ```

1. 在一个新窗口中，运行 `top`。它应该会显示这个 Ruby 进程使用 100% CPU。记下 PID。
1. 按照上一节中关于使用 GDB 的步骤 2 进行操作。

<a id="gitlab-api-is-not-accessible"></a>

### 极狐GitLab：API 无法访问

这通常发生在极狐GitLab Shell 尝试通过
内部 API（例如，`http://localhost:8080/api/v4/internal/allowed`）请求授权，并且
检查中的某些项失败时。此问题可能由以下原因引起：

1. 连接到数据库超时（例如，PostgreSQL 或 Redis）
1. Git 钩子或推送规则中的错误
1. 访问代码仓时出错（例如，陈旧的 NFS 句柄）

要诊断此问题，请尝试重现该问题，然后通过 `top` 查看是否有
某个 Puma 工作进程在高速旋转。尝试使用前面记录的 `gdb`
技术。此外，使用 `strace` 可能有助于隔离问题：

```shell
strace -ttTfyyy -s 1024 -p <puma worker 的 PID> -o /tmp/puma.txt
```

如果你无法隔离出哪个 Puma 工作进程存在问题，请尝试对所有 Puma 工作进程运行 `strace`
以查看
`/internal/allowed` 端点卡在哪里：

```shell
ps auwx | grep puma | awk '{ print " -p " $2}' | xargs  strace -ttTfyyy -s 1024 -o /tmp/puma.txt
```

`/tmp/puma.txt` 中的输出可能有助于诊断根本原因。

<a id="related-topics"></a>

## 相关主题

- [使用专用指标服务器导出 Web 指标](../monitoring/prometheus/web_exporter.md)
```