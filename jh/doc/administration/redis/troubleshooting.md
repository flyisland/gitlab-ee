---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Redis 问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在 HA 设置中，有许多需要仔细关注的动态组件，以确保其按预期工作。

在进行以下排查之前，请检查你的防火墙规则：

- Redis 机器
  - 接受 `6379` 端口的 TCP 连接
  - 通过 TCP 在 `6379` 端口连接到其他 Redis 机器
- Sentinel 机器
  - 接受 `26379` 端口的 TCP 连接
  - 通过 TCP 在 `26379` 端口连接到其他 Sentinel 机器
  - 通过 TCP 在 `6379` 端口连接到 Redis 机器

<a id="basic-redis-activity-check"></a>

## 基本 Redis 活动检查

通过基本 Redis 活动检查开始 Redis 排查：

1. 在你的极狐GitLab 服务器上打开终端。
1. 运行 `gitlab-redis-cli --stat` 并观察运行时的输出。
1. 进入你的极狐GitLab UI，浏览一些页面。任何页面都可以，例如群组或项目概览、议题或仓库中的文件。
1. 再次查看 `stat` 输出，验证随着你的浏览，`keys`、`clients`、`requests` 和 `connections` 的值会增加。如果数字上升，说明基本 Redis 功能正常工作，极狐GitLab 可以连接到它。

<a id="troubleshooting-redis-replication"></a>

## 排查 Redis 复制

你可以通过使用 `redis-cli` 应用程序连接到每个服务器，并发送如下 `info replication` 命令来检查一切是否正常。

```shell
/opt/gitlab/embedded/bin/redis-cli -h <redis-host-or-ip> -a '<redis-password>' info replication
```

当连接到 `主` Redis 时，你会看到已连接的 `副本` 数量，以及每个副本的连接详情列表：

```plaintext
# Replication
role:master
connected_replicas:1
replica0:ip=10.133.5.21,port=6379,state=online,offset=208037514,lag=1
master_repl_offset:208037658
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:206989083
repl_backlog_histlen:1048576
```

当它是 `副本` 时，你会看到主连接的详情以及它是 `up` 还是 `down`：

```plaintext
# Replication
role:replica
master_host:10.133.1.58
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
replica_repl_offset:208096498
replica_priority:100
replica_read_only:1
connected_replicas:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

<a id="high-cpu-usage-on-redis-instance"></a>

## Redis 实例的 CPU 使用率过高

默认情况下，极狐GitLab 使用超过 600 个 Sidekiq 队列，每个队列存储为 Redis 列表。每个 Sidekiq 线程都会发出一个 `BRPOP` 命令，将所有这些队列列在一个长字符串中。随着队列数量和 `BRPOP` 调用速率的增加，Redis CPU 使用率会增长。如果你的极狐GitLab 实例有很多 Sidekiq 进程，这可能导致 Redis CPU 使用率接近 100%。高 CPU 使用率会显著降低极狐GitLab 性能。

要减少由 Sidekiq 引起的 Redis CPU 使用率，你可以同时采取以下措施：

- 使用[路由规则](../sidekiq/processing_specific_job_classes.md#routing-rules)来减少 Sidekiq 队列的数量。
- 如果你使用的是极狐GitLab 16.6 及更早版本，请增加 [`SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT` 环境变量](../environment_variables.md) 以改善 Redis 的 CPU 使用率。
  在极狐GitLab 16.7 及更高版本中，[默认值为 5](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/139583)，这应该足够了。

`SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT` 选项减少了断开和连接所造成的开销，但会增加 Sidekiq 的关闭延迟。

<a id="troubleshooting-sentinel"></a>

## 排查 Sentinel

如果你收到类似 `Redis::CannotConnectError: No sentinels available.` 的错误，可能是你的配置文件有问题，或者可能与[这个问题](https://github.com/redis/redis-rb/issues/531)有关。

你必须确保你在 `redis['master_name']` 和 `redis['master_password']` 中定义的值与你在 Sentinel 节点中定义的相同。

Redis 连接器 `redis-rb` 与 Sentinel 的协作方式有点反直觉。我们试图在 Linux 软件包中隐藏复杂性，但它仍需要一些额外的配置。

为确保你的配置正确：

1. SSH 到你的极狐GitLab 应用服务器
1. 进入 Rails 控制台：

   ```shell
   # 对于 Omnibus 安装
   sudo gitlab-rails console

   # 对于源码安装
   sudo -u git rails console -e production
   ```

1. 在控制台中运行：

   ```ruby
   redis = Gitlab::Redis::SharedState.redis
   redis.info
   ```

   保持此屏幕打开，然后按照下面的描述触发故障转移。

1. 要触发主 Redis 上的故障转移，SSH 到 Redis 服务器并运行：

   ```shell
   # 端口必须匹配你的主 Redis 端口，并且休眠时间必须比定义的时间长几秒
    redis-cli -h localhost -p 6379 DEBUG sleep 20
   ```

   > [!warning]
   > 此操作会影响服务，并会使实例宕机长达 20 秒。如果成功，之后它应该会恢复。

1. 然后回到第一步打开的 Rails 控制台，运行：

   ```ruby
   redis.info
   ```

   几秒钟延迟后，你应该会看到不同的端口（故障转移/重连时间）。

<a id="troubleshooting-a-non-bundled-redis-with-a-self-compiled-installation"></a>

## 排查使用自行编译安装的非捆绑 Redis

如果你在极狐GitLab 中收到类似 `Redis::CannotConnectError: No sentinels available.` 的错误，可能是你的配置文件有问题，或者可能与[这个上游问题](https://github.com/redis/redis-rb/issues/531)有关。

你必须确保 `resque.yml` 和 `sentinel.conf` 配置正确，否则 `redis-rb` 无法正常工作。

在 `sentinel.conf` 中定义的 `master-group-name`（`gitlab-redis`）**必须** 用作极狐GitLab (`resque.yml`) 中的主机名：

```conf
# sentinel.conf:
sentinel monitor gitlab-redis 10.0.0.1 6379 2
sentinel down-after-milliseconds gitlab-redis 10000
sentinel config-epoch gitlab-redis 0
sentinel leader-epoch gitlab-redis 0
```

```yaml
# resque.yaml
production:
  url: redis://:myredispassword@gitlab-redis/
  sentinels:
    -
      host: 10.0.0.1
      port: 26379  # 指向 Sentinel，而不是 Redis 端口
    -
      host: 10.0.0.2
      port: 26379  # 指向 Sentinel，而不是 Redis 端口
    -
      host: 10.0.0.3
      port: 26379  # 指向 Sentinel，而不是 Redis 端口
```

如有疑问，请阅读 [Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 文档。

