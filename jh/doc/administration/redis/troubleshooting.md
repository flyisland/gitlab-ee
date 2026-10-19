---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Redis 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要让高可用（HA）设置按预期工作，需要仔细处理许多动态组件。

在继续进行下面的故障排除之前，请检查您的防火墙规则：

- Redis 机器
  - 接受 `6379` 上的 TCP 连接
  - 通过 `6379` 上的 TCP 连接到其他 Redis 机器
- Sentinel 机器
  - 接受 `26379` 上的 TCP 连接
  - 通过 `26379` 上的 TCP 连接到其他 Sentinel 机器
  - 通过 `6379` 上的 TCP 连接到 Redis 机器

<a id="basic-redis-activity-check"></a>

## 基本 Redis 活动检查

从基本的 Redis 活动检查开始进行 Redis 故障排除：

1. 在极狐GitLab 服务器上打开终端。
1. 运行 `gitlab-redis-cli --stat` 并在其运行时观察输出。
1. 转到极狐GitLab UI 并浏览几个页面。任何页面都可以，例如
   群组或项目概览、议题或代码仓库中的文件。
1. 再次检查 `stat` 输出，并验证 `keys`、`clients`、
   `requests` 和 `connections`的值在您浏览时是否增加。如果这些数字上升，
   说明基本 Redis 功能正常，并且极狐GitLab 可以连接到它。

<a id="troubleshooting-redis-replication"></a>

## Redis 复制故障排除

您可以通过使用 `redis-cli` 应用程序连接到每个服务器，并发送如下所示的 `info replication` 命令，来检查一切是否正确。

```shell
/opt/gitlab/embedded/bin/redis-cli -h <redis-host-or-ip> -a '<redis-password>' info replication
```

当连接到 `Primary` Redis 时，您会看到已连接的 `replicas` 数量，以及每个副本及其连接详情的列表：

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

当它是 `replica` 时，您会看到主连接详情，以及它是 `up` 还是 `down`：

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

## Redis 实例上的高 CPU 使用率

默认情况下，极狐GitLab 使用超过 600 个 Sidekiq 队列，每个队列都存储为一个 Redis 列表。每个 Sidekiq 线程都会发出一个 `BRPOP` 命令，并在一个长字符串中列出所有队列。Redis CPU 使用率会随着队列数量和 `BRPOP` 调用频率的增加而增长。如果您的极狐GitLab 实例有许多 Sidekiq 进程，这可能导致 Redis CPU 使用率接近 100%。高 CPU 使用率会显著降低极狐GitLab 性能。

要减少 Sidekiq 导致的 Redis CPU 使用率，您可以同时采取以下措施：

- 使用[路由规则](../sidekiq/processing_specific_job_classes.md#routing-rules)来减少 Sidekiq 队列的数量。
- 如果您使用的是极狐GitLab 16.6 及更早版本，请增大 [`SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT` 环境变量](../environment_variables.md)以改善 Redis 上的 CPU 使用率。
  在极狐GitLab 16.7 及更高版本中，[默认值为 5](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/139583)，这应该足够了。

`SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT` 选项可减少拆除和连接带来的开销，但会增加 Sidekiq 的关闭延迟。

<a id="troubleshooting-sentinel"></a>

## Sentinel 故障排除

如果您遇到类似这样的错误：`Redis::CannotConnectError: No sentinels available.`，可能是您的配置文件有问题，也可能与[此议题](https://github.com/redis/redis-rb/issues/531)有关。

您必须确保在 `redis['master_name']` 和 `redis['master_password']` 中定义的值与您为 sentinel 节点定义的值相同。

Redis 连接器 `redis-rb` 与 sentinel 协同工作的方式有点不直观。我们尝试在 Linux 软件包中隐藏这种复杂性，但它仍然需要一些额外的配置。

要确保您的配置正确：

1. 通过 SSH 登录到您的极狐GitLab 应用服务器
1. 进入 Rails 控制台：

   ```shell
   # For Omnibus installations
   sudo gitlab-rails console

   # For source installations
   sudo -u git rails console -e production
   ```

1. 在控制台中运行：

   ```ruby
   redis = Gitlab::Redis::SharedState.redis
   redis.info
   ```

   保持此屏幕打开，并继续按下面所述触发故障转移。

1. 要在主 Redis 上触发故障转移，请通过 SSH 登录到 Redis 服务器并运行：

   ```shell
   # port must match your primary redis port, and the sleep time must be a few seconds bigger than defined one
    redis-cli -h localhost -p 6379 DEBUG sleep 20
   ```

   > [!warning]
   > 此操作会影响服务，并使实例停机最多 20 秒。如果成功，
   > 之后它应该会恢复。

1. 然后回到第一步中的 Rails 控制台，运行：

   ```ruby
   redis.info
   ```

   在几秒钟延迟后（故障转移/重新连接时间），您应该会看到不同的端口。

<a id="troubleshooting-a-non-bundled-redis-with-a-self-compiled-installation"></a>

## 自行编译安装中非捆绑 Redis 的故障排除

如果您在极狐GitLab 中遇到类似 `Redis::CannotConnectError: No sentinels available.` 的错误，可能是您的配置文件有问题，也可能与[此上游议题](https://github.com/redis/redis-rb/issues/531)有关。

您必须确保 `resque.yml` 和 `sentinel.conf` 配置正确，否则 `redis-rb` 无法正常工作。

在 `sentinel.conf` 中定义的 `master-group-name`（`gitlab-redis`）必须用作极狐GitLab（`resque.yml`）中的主机名：

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
      port: 26379  # point to sentinel, not to redis port
    -
      host: 10.0.0.2
      port: 26379  # point to sentinel, not to redis port
    -
      host: 10.0.0.3
      port: 26379  # point to sentinel, not to redis port
```

如有疑问，请阅读 [Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 文档。
