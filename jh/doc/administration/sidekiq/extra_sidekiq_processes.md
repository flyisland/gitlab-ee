---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 运行多个 Sidekiq 进程
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 允许你在单个实例上启动多个 Sidekiq 进程，以更高的速率处理后台作业。默认情况下，Sidekiq 启动一个工作进程，并且仅使用一个 CPU 核心。

> [!note]
> 本页信息仅适用于 Linux 软件包安装。

<a id="start-multiple-processes"></a>

## 启动多个进程

启动多个进程时，进程数量应至多等于（且 **不** 超过）你希望分配给 Sidekiq 的 CPU 核心数。Sidekiq 工作进程最多使用一个 CPU 核心。

要启动多个进程，请使用 `sidekiq['queue_groups']` 数组设置来指定通过 `sidekiq-cluster` 创建多少个进程，以及它们应处理哪些队列。数组中的每一项对应一个额外的 Sidekiq 进程，每一项中的值决定了该进程处理的队列。在绝大多数情况下，所有进程都应监听所有队列（有关更多细节，请参阅[处理特定作业类](processing_specific_job_classes.md)）。

例如，要创建四个 Sidekiq 进程，每个进程监听所有可用队列：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['queue_groups'] = ['*'] * 4
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

要在极狐GitLab 中查看 Sidekiq 进程：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **后台作业**。

<a id="concurrency"></a>

## 并发

默认情况下，`sidekiq` 下定义的每个进程启动的线程数等于队列数加一个备用线程，最多为 50 个。例如，处理所有队列的进程默认使用 50 个线程。

这些线程运行在单个 Ruby 进程中，每个进程只能使用一个 CPU 核心。线程的有用性取决于工作需要等待的外部依赖，例如数据库查询或 HTTP 请求。大多数 Sidekiq 部署都能从这种线程中受益。

<a id="database-connection-planning"></a>

## 数据库连接规划

在增加 Sidekiq 进程或并发之前，请考虑对你的 PostgreSQL `max_connections` 设置的数据库连接影响。

有关详细的连接规划和计算，请参阅[优化 PostgreSQL](../postgresql/tune.md) 页面。

<a id="manage-thread-counts-explicitly"></a>

### 显式管理线程数

正确的最大线程数（也称为并发）取决于工作负载。对于高度 CPU 密集型任务，典型值范围为 `5`；对于混合的低优先级工作，为 `15` 或更高。对于非专用部署，合理的起始范围是 `15` 到 `25`。

数值会根据每个特定 Sidekiq 部署所执行的工作而有所不同。任何其他专用于特定队列的进程的部署，都应根据以下因素调整并发：

- 每种进程类型的 CPU 使用率。
- 实现的吞吐量。

每个线程都需要一个 Redis 连接，因此增加线程可能会增加 Redis 延迟，并可能导致客户端超时。有关更多详细信息，请参阅 [Sidekiq 关于 Redis 的文档](https://github.com/mperham/sidekiq/wiki/Using-Redis)。

<a id="manage-thread-counts-with-concurrency-field"></a>

#### 使用 concurrency 字段管理线程数

{{< history >}}

- 在 极狐GitLab 16.9 引入。

{{< /history >}}

在 极狐GitLab 16.9 及更高版本中，你可以通过设置 `concurrency` 来指定并发。此值将为每个进程显式设置此并发量。

例如，要将并发设置为 `20`：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['concurrency'] = 20
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="modify-the-check-interval"></a>

## 修改检查间隔

要修改其他 Sidekiq 进程的 Sidekiq 健康检查间隔：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['interval'] = 5
   ```

   该值可以是任意整数秒数。

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="troubleshoot-using-the-cli"></a>

## 使用 CLI 进行故障排查

> [!warning]
> 建议使用 `/etc/gitlab/gitlab.rb` 配置 Sidekiq 进程。
> 如果遇到问题，应联系极狐GitLab 支持团队。使用命令行需自行承担风险。

出于调试目的，你可以使用 `/opt/gitlab/embedded/service/gitlab-rails/bin/sidekiq-cluster` 命令启动额外的 Sidekiq 进程。此命令使用以下语法接受参数：

```shell
/opt/gitlab/embedded/service/gitlab-rails/bin/sidekiq-cluster [QUEUE,QUEUE,...] [QUEUE, ...]
```

`--dryrun` 参数允许你查看将要执行的命令，而无需实际启动它。

每个单独的参数表示一组必须由 Sidekiq 进程处理的队列。多个队列可以用逗号而不是空格分隔，由同一个进程处理。

除了队列之外，还可以提供队列命名空间，让进程自动监听该命名空间中的所有队列，而无需显式列出所有队列名称。有关队列命名空间的更多信息，请参阅极狐GitLab 开发文档中 Sidekiq 开发的相应部分。

<a id="monitor-the-sidekiq-cluster-command"></a>

### 监控 `sidekiq-cluster` 命令

`sidekiq-cluster` 命令在启动了所需数量的 Sidekiq 进程后不会终止。相反，该进程会继续运行，并将任何信号转发给子进程。这使你可以通过向 `sidekiq-cluster` 进程发送信号来停止所有 Sidekiq 进程，而无需向各个进程发送信号。

如果 `sidekiq-cluster` 进程崩溃或收到 `SIGKILL` 信号，子进程会在几秒钟后自行终止。这确保你不会留下僵尸 Sidekiq 进程。

这允许你通过将 `sidekiq-cluster` 挂接到你选择的监视程序（例如 runit）来监控进程。

如果子进程死亡，`sidekiq-cluster` 命令会向所有剩余进程发出终止信号，然后自行终止。这样就消除了 `sidekiq-cluster` 需要重新实现复杂的进程监控/重启代码的需求。相反，你应该确保你的监视程序在必要时重启 `sidekiq-cluster` 进程。

<a id="pid-files"></a>

### PID 文件

`sidekiq-cluster` 命令可以将其 PID 存储在文件中。默认情况下不写 PID 文件，但可以通过将 `--pidfile` 选项传递给 `sidekiq-cluster` 来更改。例如：

```shell
/opt/gitlab/embedded/service/gitlab-rails/bin/sidekiq-cluster --pidfile /var/run/gitlab/sidekiq_cluster.pid process_commit
```

请记住，PID 文件包含的是 `sidekiq-cluster` 命令的 PID，而不是已启动的 Sidekiq 进程的 PID。

<a id="environment"></a>

### 环境

可以通过将 `--environment` 标志传递给 `sidekiq-cluster` 命令，或将 `RAILS_ENV` 设置为非空值来设置 Rails 环境。默认值可以在 `/opt/gitlab/etc/gitlab-rails/env/RAILS_ENV` 中找到。