---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Redis 复制和故障转移：使用您自己的实例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您在云服务商上托管极狐GitLab，可以选择为 Redis 使用托管服务。例如，AWS 提供的 ElastiCache 可以运行 Redis。

或者，您也可以选择管理独立于 Linux 软件包的自己的 Redis 实例。

<a id="requirements"></a>

## 要求

以下是提供您自己的 Redis 实例的要求：

- 在[要求页面](../../install/requirements.md)中查找所需的最低 Redis 版本。
- 支持独立 Redis 或使用 Sentinel 的 Redis 高可用性。不支持 Redis Cluster。
- 来自云服务商（如 AWS ElastiCache）的托管 Redis 可以正常使用。如果这些服务支持高可用性，请确保它不是 Redis Cluster 类型。

记下 Redis 节点的 IP 地址或主机名、端口和密码（如需要）。

<a id="redis-as-a-managed-service-in-a-cloud-provider"></a>

## 在云服务商中将 Redis 作为托管服务

1. 根据[要求](#requirements)设置 Redis。
1. 在 `/etc/gitlab/gitlab.rb` 文件中，使用外部 Redis 服务的相应连接详细信息配置极狐GitLab 应用服务器：

   使用单个 Redis 实例时：

   ```ruby
   redis['enable'] = false

   gitlab_rails['redis_host'] = '<redis_instance_url>'
   gitlab_rails['redis_port'] = '<redis_instance_port>'

   # Required if Redis authentication is configured on the Redis node
   gitlab_rails['redis_password'] = '<redis_password>'

   # Set to true if instance is using Redis SSL
   gitlab_rails['redis_ssl'] = true
   ```

   使用单独的 Redis Cache 和 Persistent 实例时：

   ```ruby
   redis['enable'] = false

   # Default Redis connection
   gitlab_rails['redis_host'] = '<redis_persistent_instance_url>'
   gitlab_rails['redis_port'] = '<redis_persistent_instance_port>'
   gitlab_rails['redis_password'] = '<redis_persistent_password>'

   # Set to true if instance is using Redis SSL
   gitlab_rails['redis_ssl'] = true

   # Redis Cache connection
   # Replace `redis://` with `rediss://` if using SSL
   gitlab_rails['redis_cache_instance'] = 'redis://:<redis_cache_password>@<redis_cache_instance_url>:<redis_cache_instance_port>'
   ```

1. 重新配置以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="setting-the-eviction-policy"></a>

### 设置逐出策略

运行单个 Redis 实例时，逐出策略应设置为 `noeviction`。

如果您运行单独的 Redis Cache 和 Persistent 实例，Cache 应配置为[最近最少使用缓存](https://redis.io/docs/latest/operate/rs/databases/memory-performance/eviction-policy/)（LRU），使用 `allkeys-lru`，而 Persistent 应设置为 `noeviction`。

如何配置取决于云服务商或服务，但通常以下设置和值可配置缓存：

- `maxmemory-policy` = `allkeys-lru`
- `maxmemory-samples` = `5`

<a id="redis-replication-and-failover-with-your-own-redis-servers"></a>

## 使用您自己的 Redis 服务器进行 Redis 复制和故障转移

本文档介绍当您自行安装 Redis 且不使用 Linux 软件包附带的内置 Redis 时，如何配置可扩展的 Redis 设置。不过强烈建议使用 Linux 软件包，因为针对极狐GitLab 进行了专门优化，并且会负责将 Redis 升级到最新支持的版本。

另请注意，您可以选择根据[配置文件文档](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/README.md)中概述的高级 Redis 设置，覆盖对 `/home/git/gitlab/config/resque.yml`的所有引用。

我们怎么强调阅读 Linux 软件包 Redis HA 的[复制和故障转移](replication_and_failover.md)文档的重要性都不为过，因为它提供了有关 Redis 配置的一些宝贵信息。在继续本指南之前，请先阅读该文档。

在开始设置新的 Redis 实例之前，以下是一些要求：

- 本指南中的所有 Redis 服务器都必须配置为使用 TCP 连接而不是套接字。要将 Redis 配置为使用 TCP 连接，您需要在 Redis 配置文件中同时定义 `bind` 和 `port`。您可以绑定到所有接口（`0.0.0.0`）或指定所需接口的 IP（例如，来自内部网络的 IP）。
- 从 Redis 3.2 开始，您必须定义密码才能接收外部连接（`requirepass`）。
- 如果您将 Redis 与 Sentinel 一起使用，还需要在同一实例中为副本密码（`masterauth`）设置相同的密码。

此外，请阅读[使用 Linux 软件包进行 Redis 复制和故障转移](replication_and_failover.md#requirements)中描述的先决条件。

<a id="step-1-configuring-the-primary-redis-instance"></a>

### 步骤 1. 配置主 Redis 实例

假设 Redis 主实例 IP 为 `10.0.0.1`：

1. [安装 Redis](../../install/self_compiled/_index.md#8-redis)。
1. 编辑 `/etc/redis/redis.conf`：

   ```conf
   ## Define a `bind` address pointing to a local IP that your other machines
   ## can reach you. If you really need to bind to an external accessible IP, make
   ## sure you add extra firewall rules to prevent unauthorized access:
   bind 10.0.0.1

   ## Define a `port` to force redis to listen on TCP so other machines can
   ## connect to it (default port is `6379`).
   port 6379

   ## Set up password authentication (use the same password in all nodes).
   ## The password should be defined equal for both `requirepass` and `masterauth`
   ## when setting up Redis to use with Sentinel.
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   ```

1. 重启 Redis 服务以使更改生效。

<a id="step-2-configuring-the-replica-redis-instances"></a>

### 步骤 2. 配置副本 Redis 实例

假设 Redis 副本实例 IP 为 `10.0.0.2`：

1. [安装 Redis](../../install/self_compiled/_index.md#8-redis)。
1. 编辑 `/etc/redis/redis.conf`：

   ```conf
   ## Define a `bind` address pointing to a local IP that your other machines
   ## can reach you. If you really need to bind to an external accessible IP, make
   ## sure you add extra firewall rules to prevent unauthorized access:
   bind 10.0.0.2

   ## Define a `port` to force redis to listen on TCP so other machines can
   ## connect to it (default port is `6379`).
   port 6379

   ## Set up password authentication (use the same password in all nodes).
   ## The password should be defined equal for both `requirepass` and `masterauth`
   ## when setting up Redis to use with Sentinel.
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here

   ## Define `replicaof` pointing to the Redis primary instance with IP and port.
   replicaof 10.0.0.1 6379
   ```

1. 重启 Redis 服务以使更改生效。
1. 对所有其他副本节点重复这些步骤。

<a id="step-3-configuring-the-redis-sentinel-instances"></a>

### 步骤 3. 配置 Redis Sentinel 实例

Sentinel 是一种特殊类型的 Redis 服务器。它继承了您可以在 `redis.conf`中定义的大部分基本配置选项，其中特定选项以 `sentinel` 前缀开头。

假设 Redis Sentinel 与 Redis 主实例安装在同一实例上，IP 为 `10.0.0.1`（某些设置可能与主实例重叠）：

1. [安装 Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/)。
1. 编辑 `/etc/redis/sentinel.conf`：

   ```conf
   ## Define a `bind` address pointing to a local IP that your other machines
   ## can reach you. If you really need to bind to an external accessible IP, make
   ## sure you add extra firewall rules to prevent unauthorized access:
   bind 10.0.0.1

   ## Define a `port` to force Sentinel to listen on TCP so other machines can
   ## connect to it (default port is `6379`).
   port 26379

   ## Set up password authentication (use the same password in all nodes).
   ## The password should be defined equal for both `requirepass` and `masterauth`
   ## when setting up Redis to use with Sentinel.
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here

   ## Define with `sentinel auth-pass` the same shared password you have
   ## defined for both Redis primary and replicas instances.
   sentinel auth-pass gitlab-redis redis-password-goes-here

   ## Define with `sentinel monitor` the IP and port of the Redis
   ## primary node, and the quorum required to start a failover.
   sentinel monitor gitlab-redis 10.0.0.1 6379 2

   ## Define with `sentinel down-after-milliseconds` the time in `ms`
   ## that an unresponsive server is considered down.
   sentinel down-after-milliseconds gitlab-redis 10000

   ## Define a value for `sentinel failover_timeout` in `ms`. This has multiple
   ## meanings:
   ##
   ## * The time needed to re-start a failover after a previous failover was
   ##   already tried against the same primary by a given Sentinel, is two
   ##   times the failover timeout.
   ##
   ## * The time needed for a replica replicating to a wrong primary according
   ##   to a Sentinel current configuration, to be forced to replicate
   ##   with the right primary, is exactly the failover timeout (counting since
   ##   the moment a Sentinel detected the misconfiguration).
   ##
   ## * The time needed to cancel a failover that is already in progress but
   ##   did not produce any configuration change (REPLICAOF NO ONE yet not
   ##   acknowledged by the promoted replica).
   ##
   ## * The maximum time a failover in progress waits for all the replicas to be
   ##   reconfigured as replicas of the new primary. However even after this time
   ##   the replicas are reconfigured by the Sentinels anyway, but not with
   ##   the exact parallel-syncs progression as specified.
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。
1. 对所有其他 Sentinel 节点重复这些步骤。

<a id="step-4-configuring-the-gitlab-application"></a>

### 步骤 4. 配置极狐GitLab 应用

您可以在新安装或现有安装中随时启用或禁用 Sentinel 支持。从极狐GitLab 应用的角度来看，它只需要 Sentinel 节点的正确凭据。

虽然它不需要所有 Sentinel 节点的列表，但在发生故障时，它需要访问所列节点中的至少一个。

以下步骤应在极狐GitLab 应用服务器上执行，理想情况下该服务器不应在同一台机器上运行 Redis 或 Sentinel：

1. 按照 [`resque.yml.example`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/resque.yml.example)中的示例编辑 `/home/git/gitlab/config/resque.yml`，并取消注释 Sentinel 行，指向正确的服务器凭据：

   ```yaml
   # resque.yaml
   production:
     url: redis://:redis-password-goes-here@gitlab-redis/
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

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="example-of-minimal-configuration-with-1-primary-2-replicas-and-3-sentinels"></a>

## 1 个主实例、2 个副本和 3 个 Sentinel 的最小配置示例

在此示例中，我们假设所有服务器都有一个内部网络接口，IP 在 `10.0.0.x` 范围内，并且它们可以使用这些 IP 相互连接。

在实际使用中，您还应设置防火墙规则以防止来自其他机器的未授权访问，并阻止来自外部（[互联网](https://gitlab.com/gitlab-org/gitlab-foss/uploads/c4cc8cd353604bd80315f9384035ff9e/The_Internet_IT_Crowd.png)）的流量。

在此示例中，**Sentinel 1** 配置在与 **Redis 主实例**相同的机器上，**Sentinel 2** 配置在与**副本 1** 相同的机器上，**Sentinel 3** 配置在与**副本 2** 相同的机器上。

以下是每台**机器**及其分配的 **IP**的列表和描述：

- `10.0.0.1`：Redis 主实例 + Sentinel 1
- `10.0.0.2`：Redis 副本 1 + Sentinel 2
- `10.0.0.3`：Redis 副本 2 + Sentinel 3
- `10.0.0.4`：极狐GitLab 应用

初始配置后，如果 Sentinel 节点发起故障转移，Redis 节点将被重新配置，**主实例**会从一个节点永久更改为另一个节点（包括在 `redis.conf`中），直到再次发起新的故障转移。

`sentinel.conf` 也是如此：在初始执行之后、任何新的 Sentinel 节点开始监视**主实例**之后，或故障转移提升了不同的**主实例**节点之后，该文件都会被覆盖。

<a id="example-configuration-for-redis-primary-and-sentinel-1"></a>

### Redis 主实例和 Sentinel 1 的示例配置

1. 在 `/etc/redis/redis.conf`中：

   ```conf
   bind 10.0.0.1
   port 6379
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   ```

1. 在 `/etc/redis/sentinel.conf`中：

   ```conf
   bind 10.0.0.1
   port 26379
   sentinel auth-pass gitlab-redis redis-password-goes-here
   sentinel monitor gitlab-redis 10.0.0.1 6379 2
   sentinel down-after-milliseconds gitlab-redis 10000
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。

<a id="example-configuration-for-redis-replica-1-and-sentinel-2"></a>

### Redis 副本 1 和 Sentinel 2 的示例配置

1. 在 `/etc/redis/redis.conf`中：

   ```conf
   bind 10.0.0.2
   port 6379
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   replicaof 10.0.0.1 6379
   ```

1. 在 `/etc/redis/sentinel.conf`中：

   ```conf
   bind 10.0.0.2
   port 26379
   sentinel auth-pass gitlab-redis redis-password-goes-here
   sentinel monitor gitlab-redis 10.0.0.1 6379 2
   sentinel down-after-milliseconds gitlab-redis 10000
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。

<a id="example-configuration-for-redis-replica-2-and-sentinel-3"></a>

### Redis 副本 2 和 Sentinel 3 的示例配置

1. 在 `/etc/redis/redis.conf`中：

   ```conf
   bind 10.0.0.3
   port 6379
   requirepass redis-password-goes-here
   masterauth redis-password-goes-here
   replicaof 10.0.0.1 6379
   ```

1. 在 `/etc/redis/sentinel.conf`中：

   ```conf
   bind 10.0.0.3
   port 26379
   sentinel auth-pass gitlab-redis redis-password-goes-here
   sentinel monitor gitlab-redis 10.0.0.1 6379 2
   sentinel down-after-milliseconds gitlab-redis 10000
   sentinel failover_timeout 30000
   ```

1. 重启 Redis 服务以使更改生效。

<a id="example-configuration-of-the-gitlab-application"></a>

### 极狐GitLab 应用的示例配置

1. 编辑 `/home/git/gitlab/config/resque.yml`：

   ```yaml
   production:
     url: redis://:redis-password-goes-here@gitlab-redis/
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

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="troubleshooting"></a>

## 故障排除

请参阅 [Redis 故障排除指南](troubleshooting.md)。
