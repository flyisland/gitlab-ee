---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Redis 复制与故障转移（提供自有实例）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果你在云提供商上托管极狐GitLab，可以选择为 Redis 使用托管服务。例如，AWS 提供运行 Redis 的 ElastiCache。

或者，你也可以选择在 Linux 软件包之外管理自己的 Redis 实例。

## 需求

<a id="requirements"></a>

提供自有 Redis 实例需要满足以下条件：

- 在[需求页面](../../install/requirements.md)中找到所需的最低 Redis 版本。
- 支持独立 Redis 或带有 Sentinel 的 Redis 高可用。不支持 Redis Cluster。
- 来自云提供商（如 AWS ElastiCache）的托管 Redis 可以正常工作。如果这些服务支持高可用，请确保它 **不是** Redis Cluster 类型。

请记下 Redis 节点的 IP 地址或主机名、端口以及密码（如果需要）。

## 将 Redis 作为云提供商中的托管服务

<a id="redis-as-a-managed-service-in-a-cloud-provider"></a>

1. 根据[需求](#requirements)设置 Redis。
1. 在 `/etc/gitlab/gitlab.rb` 文件中为外部 Redis 服务配置极狐GitLab 应用服务器的相应连接详情：

   使用单个 Redis 实例时：

   ```ruby
   redis['enable'] = false

   gitlab_rails['redis_host'] = '<redis_instance_url>'
   gitlab_rails['redis_port'] = '<redis_instance_port>'

   # 如果 Redis 节点上配置了 Redis 认证，则需要此项
   gitlab_rails['redis_password'] = '<redis_password>'

   # 如果实例使用 Redis SSL，则设置为 true
   gitlab_rails['redis_ssl'] = true
   ```

   使用独立的 Redis 缓存和持久化实例时：

   ```ruby
   redis['enable'] = false

   # 默认 Redis 连接
   gitlab_rails['redis_host'] = '<redis_persistent_instance_url>'
   gitlab_rails['redis_port'] = '<redis_persistent_instance_port>'
   gitlab_rails['redis_password'] = '<redis_persistent_password>'

   # 如果实例使用 Redis SSL，则设置为 true
   gitlab_rails['redis_ssl'] = true

   # Redis 缓存连接
   # 如果使用 SSL，请将 `redis://` 替换为 `rediss://`
   gitlab_rails['redis_cache_instance'] = 'redis://:<redis_cache_password>@<redis_cache_instance_url>:<redis_cache_instance_port>'
   ```

1. 重新配置以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

### 设置淘汰策略

<a id="setting-the-eviction-policy"></a>

运行单个 Redis 实例时，淘汰策略应设置为 `noeviction`。

如果你运行独立的 Redis 缓存和持久化实例，缓存应配置为[最近最少使用缓存](https://redis.io/docs/latest/operate/rs/databases/memory-performance/eviction-policy/)，使用 `allkeys-lru`，而持久化实例应设置为 `noeviction`。

配置方式取决于云提供商或服务，但通常以下设置和值可配置缓存：

- `maxmemory-policy` = `allkeys-lru`
- `maxmemory-samples` = `5`

## 使用自有 Redis 服务器实现 Redis 复制与故障转移

<a id="redis-replication-and-failover-with-your-own-redis-servers"></a>

本文档介绍在你完全自行安装 Redis，而非使用 Linux 软件包自带的 Redis 时，如何配置可扩展的 Redis 设置。不过，我们强烈建议使用 Linux 软件包，因为我们会专门为极狐GitLab 进行优化，并负责将 Redis 升级到最新的受支持版本。

另请注意，你可以根据[配置文件文档](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/README.md)中概述的高级 Redis 设置，决定是否覆盖对 `/home/git/gitlab/config/resque.yml` 的所有引用。

我们必须再三强调阅读 Linux 软件包 Redis HA 的[复制和故障转移](replication_and_failover.md)文档的重要性，因为它为 Redis 的配置提供了一些宝贵的信息。在继续阅读本指南之前，请务必先阅读该文档。

在着手设置新的 Redis 实例之前，需要满足以下条件：

- 本指南中的所有 Redis 服务器都必须配置为使用 TCP 连接，而非套接字。要配置 Redis 使用 TCP 连接，你需要在 Redis 配置文件中同时定义 `bind` 和 `port`。你可以绑定到所有接口（`0.0.0.0`），或指定所需接口的 IP（例如内部网络中的某个 IP）。
- 自 Redis 3.2 起，必须定义密码才能接收外部连接（`requirepass`）。
- 如果你使用带有 Sentinel 的 Redis，还需要在同一个实例中为副本密码定义（`masterauth`）相同的密码。

此外，请阅读[使用 Linux 软件包进行 Redis 复制和故障转移](replication_and_failover.md#requirements)中描述的先决条件。

### 步骤 1. 配置主 Redis 实例

<a id="step-1-configuring-the-primary-redis-instance"></a>

假设 Redis 主实例 IP 为 `10.0.0.1`：

1. [安装 Redis](../../install/self_compiled/_index.md#8-redis)。
1. 编辑 `/etc/redis/redis.conf`：

   ```conf
   ## 定义一个指向本地 IP 的 `bind` 地址，以便其他机器可以访问你。
   ## 如果确实需要绑定到外部可访问的 IP，请确保添加额外的防火墙规则以防止未授权访问：
   bind 10.0.0.1

   ## 定义一个 `port` 以强制 Redis 在 TCP 上侦听，以便其他机器可以连接（默认端口为 `6379`）。
   port 6379

   ## 设置密码认证（在所有节点中使用相同的密码）。
   ## 在使用 Sentinel 设置 Redis 时，`requirepass` 和 `masterauth` 应定义相同的密码。
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   ```

1. 重启 Redis 服务以使更改生效。

### 步骤 2. 配置副本 Redis 实例

<a id="step-2-configuring-the-replica-redis-instances"></a>

假设 Redis 副本实例 IP 为 `10.0.0.2`：

1. [安装 Redis](../../install/self_compiled/_index.md#8-redis)。
1. 编辑 `/etc/redis/redis.conf`：

   ```conf
   ## 定义一个指向本地 IP 的 `bind` 地址，以便其他机器可以访问你。
   ## 如果确实需要绑定到外部可访问的 IP，请确保添加额外的防火墙规则以防止未授权访问：
   bind 10.0.0.2

   ## 定义一个 `port` 以强制 Redis 在 TCP 上侦听，以便其他机器可以连接（默认端口为 `6379`）。
   port 6379

   ## 设置密码认证（在所有节点中使用相同的密码）。
   ## 在使用 Sentinel 设置 Redis 时，`requirepass` 和 `masterauth` 应定义相同的密码。
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here

   ## 定义 `replicaof` 指向 Redis 主实例的 IP 和端口。
   replicaof 10.0.0.1 6379
   ```

1. 重启 Redis 服务以使更改生效。
1. 对所有其他副本节点重复以上步骤。

### 步骤 3. 配置 Redis Sentinel 实例

<a id="step-3-configuring-the-redis-sentinel-instances"></a>

Sentinel 是一种特殊类型的 Redis 服务器。它继承了你在 `redis.conf` 中定义的大部分基本配置选项，同时具有一些以 `sentinel` 前缀开头的特定选项。

假设 Redis Sentinel 与 Redis 主节点安装在同一实例上，IP 为 `10.0.0.1`（某些设置可能与主节点重叠）：

1. [安装 Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/)。
1. 编辑 `/etc/redis/sentinel.conf`：

   ```conf
   ## 定义一个指向本地 IP 的 `bind` 地址，以便其他机器可以访问你。
   ## 如果确实需要绑定到外部可访问的 IP，请确保添加额外的防火墙规则以防止未授权访问：
   bind 10.0.0.1

   ## 定义一个 `port` 以强制 Sentinel 在 TCP 上侦听，以便其他机器可以连接（默认端口为 `6379`）。
   port 26379

   ## 设置密码认证（在所有节点中使用相同的密码）。
   ## 在使用 Sentinel 设置 Redis 时，`requirepass` 和 `masterauth` 应定义相同的密码。
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here

   ## 使用 `sentinel auth-pass` 定义你为 Redis 主节点和副本实例定义的相同共享密码。
   sentinel auth-pass gitlab-redis redis-password-goes-here

   ## 使用 `sentinel monitor` 定义 Redis 主节点的 IP 和端口，以及启动故障转移所需的法定人数。
   sentinel monitor gitlab-redis 10.0.0.1 6379 2

   ## 使用 `sentinel down-after-milliseconds` 定义无响应服务器被视为宕机的时间（以毫秒为单位）。
   sentinel down-after-milliseconds gitlab-redis 10000

   ## 定义 `sentinel failover_timeout` 的值（以毫秒为单位）。此值有多种含义：
   ##
   ## * 对于给定 Sentinel，在上一次针对同一主节点已尝试过故障转移后，重新启动故障转移所需的时间是故障转移超时时间的两倍。
   ##
   ## * 对于根据 Sentinel 当前配置复制到错误主节点的副本，强制其复制到正确主节点所需的时间恰好等于故障转移超时时间（自 Sentinel 检测到配置错误的那一刻起计算）。
   ##
   ## * 取消已在进行中但未产生任何配置更改的故障转移所需的时间（REPLICAOF NO ONE 尚未被提升的副本确认）。
   ##
   ## * 正在进行的故障转移等待所有副本重新配置为新主节点副本的最长时间。但是，即使超过此时间，Sentinel 仍会重新配置副本，但不会按照指定的精确并行同步进度进行。
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。
1. 对所有其他 Sentinel 节点重复以上步骤。

### 步骤 4. 配置极狐GitLab 应用

<a id="step-4-configuring-the-gitlab-application"></a>

你可以随时在新的或现有的安装中启用或禁用 Sentinel 支持。从极狐GitLab 应用的角度来看，它只需要 Sentinel 节点的正确凭据。

虽然它不需要所有 Sentinel 节点的列表，但在发生故障时，它至少需要访问列出的其中一个节点。

以下步骤应在极狐GitLab 应用服务器上执行，理想情况下该服务器不应与 Redis 或 Sentinel 位于同一台机器上：

1. 按照 [`resque.yml.example`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/resque.yml.example) 中的示例编辑 `/home/git/gitlab/config/resque.yml`，并取消注释 Sentinel 行，指向正确的服务器凭据：

   ```yaml
   # resque.yaml
   production:
     url: redis://:redis-password-goes-here@gitlab-redis/
     sentinels:
       -
         host: 10.0.0.1
         port: 26379  # 指向 sentinel，而非 redis 端口
       -
         host: 10.0.0.2
         port: 26379  # 指向 sentinel，而非 redis 端口
       -
         host: 10.0.0.3
         port: 26379  # 指向 sentinel，而非 redis 端口
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

## 包含 1 个主节点、2 个副本和 3 个 Sentinel 的最小配置示例

<a id="example-of-minimal-configuration-with-1-primary-2-replicas-and-3-sentinels"></a>

在此示例中，我们假设所有服务器都有一个内部网络接口，IP 在 `10.0.0.x` 范围内，并且它们可以使用这些 IP 相互连接。

在实际使用中，你还需要设置防火墙规则以防止来自其他机器的未授权访问，并阻止来自外部（[互联网](https://gitlab.com/gitlab-org/gitlab-foss/uploads/c4cc8cd353604bd80315f9384035ff9e/The_Internet_IT_Crowd.png)）的流量。

在此示例中，**Sentinel 1** 配置在与 **Redis 主节点** 相同的机器上，**Sentinel 2** 配置在与 **副本 1** 相同的机器上，**Sentinel 3** 配置在与 **副本 2** 相同的机器上。

以下是每台 **机器** 及其分配的 **IP** 的列表和描述：

- `10.0.0.1`：Redis 主节点 + Sentinel 1
- `10.0.0.2`：Redis 副本 1 + Sentinel 2
- `10.0.0.3`：Redis 副本 2 + Sentinel 3
- `10.0.0.4`：极狐GitLab 应用

初始配置完成后，如果 Sentinel 节点启动故障转移，Redis 节点将被重新配置，**主节点** 会永久性地从一个节点切换到另一个节点（包括 `redis.conf` 中的更改），直到再次启动新的故障转移。

`sentinel.conf` 也是如此，在初始执行、任何新 Sentinel 节点开始监视 **主节点** 或故障转移提升不同的 **主节点** 之后，该文件会被覆盖。

### Redis 主节点和 Sentinel 1 的示例配置

<a id="example-configuration-for-redis-primary-and-sentinel-1"></a>

1. 在 `/etc/redis/redis.conf` 中：

   ```conf
   bind 10.0.0.1
   port 6379
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   ```

1. 在 `/etc/redis/sentinel.conf` 中：

   ```conf
   bind 10.0.0.1
   port 26379
   sentinel auth-pass gitlab-redis redis-password-goes-here
   sentinel monitor gitlab-redis 10.0.0.1 6379 2
   sentinel down-after-milliseconds gitlab-redis 10000
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。

### Redis 副本 1 和 Sentinel 2 的示例配置

<a id="example-configuration-for-redis-replica-1-and-sentinel-2"></a>

1. 在 `/etc/redis/redis.conf` 中：

   ```conf
   bind 10.0.0.2
   port 6379
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   replicaof 10.0.0.1 6379
   ```

1. 在 `/etc/redis/sentinel.conf` 中：

   ```conf
   bind 10.0.0.2
   port 26379
   sentinel auth-pass gitlab-redis redis-password-goes-here
   sentinel monitor gitlab-redis 10.0.0.1 6379 2
   sentinel down-after-milliseconds gitlab-redis 10000
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。

### Redis 副本 2 和 Sentinel 3 的示例配置

<a id="example-configuration-for-redis-replica-2-and-sentinel-3"></a>

1. 在 `/etc/redis/redis.conf` 中：

   ```conf
   bind 10.0.0.3
   port 6379
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   replicaof 10.0.0.1 6379
   ```

1. 在 `/etc/redis/sentinel.conf` 中：

   ```conf
   bind 10.0.0.3
   port 26379
   sentinel auth-pass gitlab-redis redis-password-goes-here
   sentinel monitor gitlab-redis 10.0.0.1 6379 2
   sentinel down-after-milliseconds gitlab-redis 10000
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。

### 极狐GitLab 应用的示例配置

<a id="example-configuration-of-the-gitlab-application"></a>

1. 编辑 `/home/git/gitlab/config/resque.yml`：

   ```yaml
   production:
     url: redis://:redis-password-goes-here@gitlab-redis/
     sentinels:
       -
         host: 10.0.0.1
         port: 26379  # 指向 sentinel，而非 redis 端口
       -
         host: 10.0.0.2
         port: 26379  # 指向 sentinel，而非 redis 端口
       -
         host: 10.0.0.3
         port: 26379  # 指向 sentinel，而非 redis 端口
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

## 故障排除

<a id="troubleshooting"></a>

参见 [Redis 故障排除指南](troubleshooting.md)。