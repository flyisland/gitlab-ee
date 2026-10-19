---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少内存使用
---

Sidekiq 内存终止器会自动管理占用过多内存的后台作业进程。此功能会监控工作进程，并在 Linux 内存终止器介入之前重启它们，从而让后台作业在优雅关闭之前运行至完成。通过记录这些事件，可以更容易地识别导致高内存使用的作业。

<a id="how-we-monitor-sidekiq-memory"></a>

## 我们如何监控 Sidekiq 内存

默认情况下，极狐GitLab 仅针对 Linux 软件包或 Docker 安装监控可用的 RSS 限制。原因是极狐GitLab 依赖 runit 在因内存触发的关闭后重启 Sidekiq，而自行编译和 Helm chart 安装不使用 runit 或等效工具。

在默认设置下，Sidekiq 的重启频率不超过每 15 分钟一次，重启会给传入的后台作业带来约一分钟的延迟。

某些后台作业依赖长时间运行的外部进程。为确保在 Sidekiq 重启时这些进程被干净地终止，每个 Sidekiq 进程都应作为进程组组长运行（例如，使用 `chpst -P`）。如果使用 Linux 软件包安装，或在已安装 `runit`的情况下使用 `bin/background_jobs` 脚本，则此操作已为您处理。

<a id="configuring-the-limits"></a>

## 配置限制

Sidekiq 内存限制通过[环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables/#setting-custom-environment-variables)控制。

- `SIDEKIQ_MEMORY_KILLER_MAX_RSS`（KB）：定义 Sidekiq 进程允许的 RSS 软限制。
  如果 Sidekiq 进程 RSS（以千字节表示）超过 `SIDEKIQ_MEMORY_KILLER_MAX_RSS`，
  且持续时间超过 `SIDEKIQ_MEMORY_KILLER_GRACE_TIME`，则触发优雅重启。
  如果未设置 `SIDEKIQ_MEMORY_KILLER_MAX_RSS`，或其值设置为 0，则不监控软限制。
  `SIDEKIQ_MEMORY_KILLER_MAX_RSS` 默认为 `2000000`。
- `SIDEKIQ_MEMORY_KILLER_GRACE_TIME`：定义允许 Sidekiq 进程在超过允许的 RSS 软限制的情况下运行的宽限时间段（以秒为单位）。如果 Sidekiq 进程在 `SIDEKIQ_MEMORY_KILLER_GRACE_TIME` 内降到允许的 RSS（软限制）以下，则中止重启。默认值为 900 秒（15 分钟）。
- `SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS`（KB）：定义 Sidekiq 进程允许的 RSS 硬限制。
  如果 Sidekiq 进程 RSS（以千字节表示）超过 `SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS`，
  则立即触发 Sidekiq 的优雅重启。如果未设置此值，或设置为 0，
  则不监控硬限制。
- `SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL`：定义检查进程 RSS 的频率。默认为 3 秒。
- `SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT`：定义所有 Sidekiq 作业完成所允许的最长时间。
  在此期间不接受新作业。默认为 30 秒。

  如果进程重启不是由 Sidekiq 执行的，则 Sidekiq 进程会在
  [Sidekiq 关闭超时](https://github.com/mperham/sidekiq/wiki/Signals#term)（默认为 25 秒）+2 秒后被强制终止。
  如果作业在此期间未完成，则所有当前正在运行的作业都会被中断，并向 Sidekiq 进程
  发送 `SIGTERM` 信号。

- `GITLAB_MEMORY_WATCHDOG_ENABLED`：默认启用。将 `GITLAB_MEMORY_WATCHDOG_ENABLED` 设置为 false，以禁止 Watchdog 运行。

<a id="monitor-worker-restarts"></a>

### 监控工作进程重启

如果工作进程因内存使用过高而重启，极狐GitLab 会发出日志事件。

以下是 `/var/log/gitlab/sidekiq/current`中此类日志事件的一个示例：

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
  "message": "rss memory limit exceeded",
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
- `running_jobs` 列出在进程超过 RSS 限制并开始优雅重启时正在运行的作业。
