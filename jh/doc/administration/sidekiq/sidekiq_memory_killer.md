---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少内存使用
---

Sidekiq 内存杀手自动管理消耗过多内存的后台作业进程。此功能监控 worker 进程并在 Linux 内存杀手介入之前重启它们，从而允许后台作业在优雅关闭之前运行完成。通过记录这些事件，我们可以更容易地识别导致高内存使用的作业。

<a id="how-we-monitor-sidekiq-memory"></a>

## 我们如何监控 Sidekiq 内存

极狐GitLab 默认仅针对 Linux 软件包或 Docker 安装监控可用的 RSS 限制。原因是极狐GitLab 依赖 runit 在内存引发的关闭后重启 Sidekiq，而自编译和 Helm Chart 安装不使用 runit 或等效工具。

使用默认设置，Sidekiq 重启的频率不超过每 15 分钟一次，重启会导致传入的后台作业大约延迟一分钟。

某些后台作业依赖长时间运行的外部进程。为了确保在 Sidekiq 重启时这些进程被干净地终止，每个 Sidekiq 进程应作为进程组领导者运行（例如，使用 `chpst -P`）。如果使用 Linux 软件包安装或安装了 `runit` 的 `bin/background_jobs` 脚本，则会自动处理。

<a id="configuring-the-limits"></a>

## 配置限制

Sidekiq 内存限制通过[环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables/#setting-custom-environment-variables)进行控制。

- `SIDEKIQ_MEMORY_KILLER_MAX_RSS` (KB)：定义 Sidekiq 进程允许的 RSS 软限制。如果 Sidekiq 进程的 RSS（以千字节为单位）超过 `SIDEKIQ_MEMORY_KILLER_MAX_RSS`，且持续时间超过 `SIDEKIQ_MEMORY_KILLER_GRACE_TIME`，则会触发优雅重启。如果未设置 `SIDEKIQ_MEMORY_KILLER_MAX_RSS`，或将其值设置为 0，则不监控软限制。`SIDEKIQ_MEMORY_KILLER_MAX_RSS` 默认为 `2000000`。
- `SIDEKIQ_MEMORY_KILLER_GRACE_TIME`：定义 Sidekiq 进程允许在超出 RSS 软限制的情况下运行的宽限期（以秒为单位）。如果 Sidekiq 进程在 `SIDEKIQ_MEMORY_KILLER_GRACE_TIME` 内降至允许的 RSS（软限制）以下，则中止重启。默认值为 900 秒（15 分钟）。
- `SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS` (KB)：定义 Sidekiq 进程允许的 RSS 硬限制。如果 Sidekiq 进程的 RSS（以千字节为单位）超过 `SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS`，则会立即触发 Sidekiq 的优雅重启。如果未设置此值或设置为 0，则不监控硬限制。
- `SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL`：定义检查进程 RSS 的频率。默认为 3 秒。
- `SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT`：定义所有 Sidekiq 作业完成所允许的最长时间。在此期间不接受新作业。默认为 30 秒。

  如果进程重启不是由 Sidekiq 执行的，则在 [Sidekiq 关闭超时](https://github.com/mperham/sidekiq/wiki/Signals#term)（默认为 25 秒）+2 秒后，Sidekiq 进程将被强制终止。如果作业在该时间内未完成，则所有当前正在运行的作业都会收到发送到 Sidekiq 进程的 `SIGTERM` 信号而中断。

- `GITLAB_MEMORY_WATCHDOG_ENABLED`：默认启用。将 `GITLAB_MEMORY_WATCHDOG_ENABLED` 设置为 false 以禁用 Watchdog 运行。

<a id="monitor-worker-restarts"></a>

### 监控 worker 重启

如果 worker 因高内存使用而重启，极狐GitLab 会发出日志事件。

以下是 `/var/log/gitlab/gitlab-rails/sidekiq_client.log` 中此类日志事件的示例：

```json
{
  "severity": "WARN",
  "time": "2023-02-04T09:45:16.173Z",
  "correlation_id": null,
  "pid": 2725,
  "worker_id": "sidekiq_1",
  "memwd_handler_class": "Gitlab::Memory::Watchdog::SidekiqHandler",
  "memwd_sleep_time_s": 3,
  "memwd_rss_bytes": 1079683247,
  "memwd_max_rss_bytes": 629145600,
  "memwd_max_strikes": 5,
  "memwd_cur_strikes": 6,
  "message": "rss 内存限制超出",
  "running_jobs": [
    {
      jid: "83efb701c59547ee42ff7068",
      worker_class: "Ci::DeleteObjectsWorker"
    },
    {
      jid: "c3a74503dc2637f8f9445dd3",
      worker_class: "Ci::ArchiveTraceWorker"
    }
  ]
}
```

其中：

- `memwd_rss_bytes` 是实际消耗的内存量。
- `memwd_max_rss_bytes` 是通过 `per_worker_max_memory_mb` 设置的 RSS 限制。
- `running jobs` 列出了进程超出 RSS 限制并开始优雅重启时正在运行的作业。