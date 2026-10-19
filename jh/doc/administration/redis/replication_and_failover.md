---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Linux 软件包进行 Redis 复制和故障转移
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档适用于 Linux 软件包。如需使用您自己的非内置 Redis，请参阅[提供您自己的实例的 Redis 复制和故障转移](replication_and_failover_external.md)。

在 Redis 术语中，`primary` 被称为 `master`。本文档中使用 `primary` 而非 `master`，但需要 `master`的设置除外。

在可扩展环境中使用 [Redis](https://redis.io/) 时，可以采用**主节点** x **从节点**拓扑，并配合 [Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 服务来监视并自动启动故障转移流程。

Redis 与 Sentinel 一起使用时需要身份验证。更多信息请参阅 [Redis 安全](https://redis.io/docs/latest/operate/rc/security/)文档。建议结合使用 Redis 密码和严格的防火墙规则来保护您的 Redis 服务。
强烈建议您在将 Redis 与极狐GitLab 一起配置之前，先阅读 [Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 文档，
以充分理解其拓扑和架构。

在深入了解为复制拓扑设置 Redis 和 Redis Sentinel 的细节之前，请先完整阅读本文档一遍，以便更好地理解各组件之间是如何关联的。

您至少需要 `3` 台独立机器：物理机，或运行在不同物理机上的虚拟机。所有 Redis 主节点和从节点必须运行在不同的机器上，这一点至关重要。如果您未能按此特定方式预配机器，共享环境中的任何问题都可能导致您的整个设置瘫痪。

在 Redis 主节点或从节点上同时运行 Sentinel 是可以的。但同一台机器上不应有多个 Sentinel。

您还需要考虑底层网络拓扑，
确保 Redis / Sentinel 与
极狐GitLab 实例之间具有冗余连接，否则网络会成为单点故障。

在扩展环境中运行 Redis 需要满足以下几点：

- 多个 Redis 实例
- 以**主节点** x **从节点**拓扑运行 Redis
- 多个 Sentinel 实例
- 应用程序能够支持并感知所有 Sentinel 和 Redis 实例

Redis Sentinel 可以处理 HA 环境中最重要的任务，即
帮助保持服务器在线，并将停机时间降至最低甚至为零。Redis Sentinel：

- 监视**主节点**和**从节点**以确认它们是否可用
- 当**主节点**发生故障时，将**从节点**提升为**主节点**
- 当发生故障的**主节点**重新上线时，将**主节点**降级为**从节点**
  （以防止数据分区）
- 可被应用程序查询，以便始终连接到当前的**主节点**
  服务器

当**主节点**无法响应时，应用程序（在我们的场景中即极狐GitLab）有责任处理超时并重新连接（查询 **Sentinel** 以获取新的**主节点**）。

要更好地理解如何正确设置 Sentinel，请先阅读
[Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 文档，因为
配置不当可能导致数据丢失，或使您的整个集群瘫痪，从而使故障转移工作失去意义。

<a id="recommended-setup"></a>

## 推荐设置

对于最小设置，您需要在 `3` 台
**独立**机器上安装 Linux 软件包，每台都包含 **Redis** 和 **Sentinel**：

- Redis 主节点 + Sentinel
- Redis 从节点 + Sentinel
- Redis 从节点 + Sentinel

如果您不确定或不理解节点数量为何如此以及从何而来，请阅读 [Redis 设置概览](#redis-setup-overview)和
[Sentinel 设置概览](#sentinel-setup-overview)。

对于能够抵御更多故障的推荐设置，您需要在 `5` 台**独立**机器上安装 Linux 软件包，每台都包含
**Redis** 和 **Sentinel**：

- Redis 主节点 + Sentinel
- Redis 从节点 + Sentinel
- Redis 从节点 + Sentinel
- Redis 从节点 + Sentinel
- Redis 从节点 + Sentinel

<a id="redis-setup-overview"></a>

### Redis 设置概览

您必须至少有 `3` 台 Redis 服务器：`1` 个主节点、`2` 个从节点，并且它们需要各自位于独立的机器上。

您可以拥有额外的 Redis 节点，这有助于在更多节点宕机的情况下存活。只要只有 `2` 个节点在线，就不会启动故障转移。

例如，如果您有 `6` 个 Redis 节点，最多可以有 `3` 个同时宕机。

Sentinel 节点有不同的要求。如果您将它们托管在相同的 Redis 机器上，在计算要预配的节点数量时，可能需要考虑这些限制。更多信息请参阅
[Sentinel 设置概览](#sentinel-setup-overview)
文档。

所有 Redis 节点都应以相同方式配置，并使用相似的服务器规格，因为在故障转移情况下，任何**从节点**都可能被 Sentinel 服务器提升为新的**主节点**。

复制需要身份验证，因此您需要定义一个密码来保护所有 Redis 节点和 Sentinel。它们都共享同一个密码，并且所有实例都必须能够通过网络相互通信。

<a id="sentinel-setup-overview"></a>

### Sentinel 设置概览

Sentinel 同时监视其他 Sentinel 和 Redis 节点。每当一个 Sentinel
检测到某个 Redis 节点无响应时，它会将该节点的状态通告给
其他 Sentinel。Sentinel 必须达到 _quorum_（即同意某节点已宕机的
最少 Sentinel 数量）才能启动故障转移。

每当达到 **quorum** 时，所有已知 Sentinel 节点中的**多数**必须可用且可达，以便它们能够选举出 Sentinel **leader**，由其做出所有决策，通过以下方式恢复服务可用性：

- 提升一个新的**主节点**
- 重新配置其他**从节点**，使其指向新的**主节点**
- 将新的**主节点**通告给所有其他 Sentinel 对等节点
- 当旧的**主节点**重新上线时，重新配置它并降级为**从节点**

您必须至少有 `3` 台 Redis Sentinel 服务器，并且它们需要各自位于独立的机器上（这些机器被认为会独立发生故障），最好位于不同的地理区域。

您可以将它们配置在已配置其他 Redis 服务器的同一批机器上，但请理解，如果整个节点宕机，您会同时失去
一个 Sentinel 和一个 Redis 实例。

Sentinel 的数量最好始终为**奇数**，以便共识算法在发生故障时能够有效运作。

在 `3` 个节点的拓扑中，您只能承受 `1` 个 Sentinel 节点宕机。每当 Sentinel 的**多数**宕机时，网络分区保护会阻止破坏性操作，并且**不会启动**故障转移。

以下是一些示例：

- 使用 `5` 或 `6` 个 Sentinel 时，最多可以有 `2` 个宕机才能开始故障转移。
- 使用 `7` 个 Sentinel 时，最多可以有 `3` 个节点宕机。

当未达成**共识**时，**Leader** 选举有时会在投票轮次中失败。在这种情况下，会在 `sentinel['failover_timeout']` 定义的时间（以毫秒为单位）之后进行新的尝试。

> [!note]
> 我们可以在后文看到 `sentinel['failover_timeout']` 是在哪里定义的。

`failover_timeout` 变量有很多不同的用途。根据官方文档：

- 在某个给定 Sentinel 已针对同一主节点尝试过一次故障转移后，
  重新启动故障转移所需的时间，是故障转移超时的
  两倍。

- 根据 Sentinel 当前配置，某个从节点正在复制到错误的主节点时，
  强制其改为复制到正确的主节点所需的时间，恰好是故障转移超时（从
  Sentinel 检测到错误配置的那一刻起计算）。

- 取消一个已在进行中但
  未产生任何配置更改的故障转移所需的时间（REPLICAOF NO ONE 尚未
  被提升的从节点确认）。

- 进行中的故障转移等待所有从节点被
  重新配置为新主节点的从节点的最长时间。然而即使超过此时间，
  从节点仍会被 Sentinel 重新配置，只是不会
  按指定的精确并行同步进度进行。

<a id="configuring-redis"></a>

## 配置 Redis

本节将安装并设置新的 Redis 实例。

假设您已从零开始安装极狐GitLab 及其所有组件。如果您已经安装并运行了 Redis，请阅读如何[从单机安装切换](#switching-from-an-existing-single-machine-installation)。

> [!note]
> Redis 节点（主节点和从节点）需要在
> `redis['password']` 中定义相同的密码。在故障转移期间的任何时候，Sentinel 都可以
> 重新配置某个节点，并将其状态从主节点更改为从节点，反之亦然。

<a id="requirements"></a>

### 要求

Redis 设置的要求如下：

1. 按照
   [推荐设置](#recommended-setup)部分中的规定，预配最少所需数量的实例。
1. 我们**不**建议将 Redis 或 Redis Sentinel 安装在运行极狐GitLab 应用程序的同一批机器上，
   因为这会削弱您的 HA 配置。不过，您可以选择将 Redis
   和 Sentinel 安装在同一台机器上。
1. 所有 Redis 节点必须能够相互通信，并接受通过 Redis（`6379`）和 Sentinel（`26379`）端口的传入
   连接（除非您更改了默认端口）。
1. 托管极狐GitLab 应用程序的服务器必须能够访问
   Redis 节点。
1. 使用防火墙保护节点，防止来自外部网络（[互联网](https://gitlab.com/gitlab-org/gitlab-foss/uploads/c4cc8cd353604bd80315f9384035ff9e/The_Internet_IT_Crowd.png)）的
   访问。

<a id="switching-from-an-existing-single-machine-installation"></a>

### 从现有的单机安装切换

如果您已经运行了单机极狐GitLab 安装，则需要先从此机器进行复制，然后再停用其中的 Redis 实例。

您的单机安装是初始的**主节点**，其他 `3` 个应配置为指向此机器的**从节点**。

在复制跟上之后，您需要停止单机安装中的服务，以将**主节点**轮换到其中一个新节点。

在配置中进行所需的更改，然后再次重启新节点。

要禁用单机安装中的 Redis，请编辑 `/etc/gitlab/gitlab.rb`：

```ruby
redis['enable'] = false
```

如果您未能先进行复制，可能会丢失数据（未处理的后台作业）。

<a id="step-1-configuring-the-primary-redis-instance"></a>

### 步骤 1. 配置 Redis 主节点

1. SSH 登录到 Redis **主节点**。
1. 使用极狐GitLab 下载页面中的**步骤 1 和 2**，[下载并安装](https://gitlab.cn/install)您想要的 Linux
   软件包。
   - 确保选择正确的 Linux 软件包，其版本
     和类型（基础版、企业版）与您当前的安装一致。
   - 不要完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   # Specify server role as 'redis_master_role'
   roles ['redis_master_role']

   # IP address pointing to a local IP that the other machines can reach to.
   # You can also set bind to '0.0.0.0' which listen in all interfaces.
   # If you really need to bind to an external accessible IP, make
   # sure you add extra firewall rules to prevent unauthorized access.
   redis['bind'] = '10.0.0.1'

   # Define a port so Redis can listen for TCP requests which allows other
   # machines to connect to it.
   redis['port'] = 6379

   # Set up password authentication for Redis (use the same password in all nodes).
   redis['password'] = 'redis-password-goes-here'
   ```

1. 只有主极狐GitLab 应用程序服务器应处理迁移。要
   防止在升级时运行数据库迁移，请将以下
   配置添加到您的 `/etc/gitlab/gitlab.rb` 文件中：

   ```ruby
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

> [!note]
> 您可以指定多个角色，例如 sentinel 和 Redis：
> `roles ['redis_sentinel_role', 'redis_master_role']`。
> 阅读更多关于[角色](https://gitlab.cn/docs/omnibus/roles/)的信息。

<a id="step-2-configuring-the-replica-redis-instances"></a>

### 步骤 2. 配置 Redis 从节点

1. SSH 登录到 Redis **从节点**。
1. 使用极狐GitLab 下载页面中的**步骤 1 和 2**，[下载并安装](https://gitlab.cn/install)您想要的 Linux
   软件包。
   - 确保选择正确的 Linux 软件包，其版本
     和类型（基础版、企业版）与您当前的安装一致。
   - 不要完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   # Specify server role as 'redis_replica_role'
   roles ['redis_replica_role']

   # IP address pointing to a local IP that the other machines can reach to.
   # You can also set bind to '0.0.0.0' which listen in all interfaces.
   # If you really need to bind to an external accessible IP, make
   # sure you add extra firewall rules to prevent unauthorized access.
   redis['bind'] = '10.0.0.2'

   # Define a port so Redis can listen for TCP requests which allows other
   # machines to connect to it.
   redis['port'] = 6379

   # The same password for Redis authentication you set up for the primary node.
   redis['password'] = 'redis-password-goes-here'

   # The IP of the primary Redis node.
   redis['master_ip'] = '10.0.0.1'

   # Port of primary Redis server, uncomment to change to non default. Defaults
   # to `6379`.
   #redis['master_port'] = 6379
   ```

1. 要防止在升级时自动运行重新配置，请运行：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

1. 只有主极狐GitLab 应用程序服务器应处理迁移。要
   防止在升级时运行数据库迁移，请将以下
   配置添加到您的 `/etc/gitlab/gitlab.rb` 文件中：

   ```ruby
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 对所有其他从节点再次执行这些步骤。

> [!note]
> 您可以指定多个角色，例如 sentinel 和 Redis：
> `roles ['redis_sentinel_role', 'redis_master_role']`。
> 阅读更多关于[角色](https://gitlab.cn/docs/omnibus/roles/)的信息。

故障转移后，这些值无需在 `/etc/gitlab/gitlab.rb`中再次更改，因为这些节点由 Sentinel 管理，即使在 `gitlab-ctl reconfigure` 之后，它们的配置也会由
同一个 Sentinel 恢复。

<a id="step-3-configuring-the-redis-sentinel-instances"></a>

### 步骤 3. 配置 Redis Sentinel 实例

现在 Redis 服务器都已设置完毕，让我们来配置 Sentinel 服务器。

如果您不确定您的 Redis 服务器是否正常工作并正确复制，请阅读[故障排除复制](troubleshooting.md#troubleshooting-redis-replication)并在继续 Sentinel 设置之前修复它。

您必须至少有 `3` 台 Redis Sentinel 服务器，并且它们需要各自位于独立的机器上。您可以将它们配置在已配置其他 Redis 服务器的同一批机器上。

使用极狐GitLab 企业版，您可以使用 Linux 软件包来设置多台带有 Sentinel 守护进程的机器。

1. SSH 登录到托管 Redis Sentinel 的服务器。
1. **如果 Sentinel 与其他 Redis 实例托管在同一节点上，您可以省略此步骤**。

   使用极狐GitLab 下载页面中的**步骤 1 和 2**，
   [下载并安装](https://gitlab.cn/install)
   Linux 企业版软件包。
   - 确保选择正确的 Linux 软件包，其版本
     与极狐GitLab 应用程序正在运行的版本一致。
   - 不要完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容（如果您将
   Sentinel 安装在其他 Redis 实例所在的同一节点上，下面某些值可能
   会重复）：

   ```ruby
   roles ['redis_sentinel_role']

   # Must be the same in every sentinel node
   redis['master_name'] = 'gitlab-redis'

   # The same password for Redis authentication you set up for the primary node.
   redis['master_password'] = 'redis-password-goes-here'

   # The IP of the primary Redis node.
   redis['master_ip'] = '10.0.0.1'

   # Define a port so Redis can listen for TCP requests which allows other
   # machines to connect to it.
   redis['port'] = 6379

   # Port of primary Redis server, uncomment to change to non default. Defaults
   # to `6379`.
   #redis['master_port'] = 6379

   ## Configure Sentinel
   sentinel['bind'] = '10.0.0.1'

   ## Optional password for Sentinel authentication. Defaults to no password required.
   # sentinel['password'] = 'sentinel-password-goes here'

   # Port that Sentinel listens on, uncomment to change to non default. Defaults
   # to `26379`.
   # sentinel['port'] = 26379

   ## Quorum must reflect the amount of voting sentinels it take to start a failover.
   ## Value must NOT be greater than the amount of sentinels.
   ##
   ## The quorum can be used to tune Sentinel in two ways:
   ## 1. If the quorum is set to a value smaller than the majority of Sentinels
   ##    we deploy, we are basically making Sentinel more sensible to primary failures,
   ##    triggering a failover as soon as even just a minority of Sentinels is no longer
   ##    able to talk with the primary.
   ## 1. If a quorum is set to a value greater than the majority of Sentinels, we are
   ##    making Sentinel able to failover only when there are a very large number (larger
   ##    than majority) of well connected Sentinels which agree about the primary being down.
   sentinel['quorum'] = 2

   ## Consider unresponsive server down after x amount of ms.
   # sentinel['down_after_milliseconds'] = 10000

   ## Specifies the failover timeout in milliseconds. It is used in many ways:
   ##
   ## - The time needed to re-start a failover after a previous failover was
   ##   already tried against the same primary by a given Sentinel, is two
   ##   times the failover timeout.
   ##
   ## - The time needed for a replica replicating to a wrong primary according
   ##   to a Sentinel current configuration, to be forced to replicate
   ##   with the right primary, is exactly the failover timeout (counting since
   ##   the moment a Sentinel detected the misconfiguration).
   ##
   ## - The time needed to cancel a failover that is already in progress but
   ##   did not produce any configuration change (REPLICAOF NO ONE yet not
   ##   acknowledged by the promoted replica).
   ##
   ## - The maximum time a failover in progress waits for all the replica to be
   ##   reconfigured as replicas of the new primary. However even after this time
   ##   the replicas are reconfigured by the Sentinels anyway, but not with
   ##   the exact parallel-syncs progression as specified.
   # sentinel['failover_timeout'] = 60000
   ```

1. 要防止在升级时运行数据库迁移，请运行：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

   只有主极狐GitLab 应用程序服务器应处理迁移。

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 对所有其他 Sentinel 节点再次执行这些步骤。

<a id="step-4-configuring-the-gitlab-application"></a>

### 步骤 4. 配置极狐GitLab 应用程序

最后一步是告知主极狐GitLab 应用程序服务器 Redis Sentinel 服务器和身份验证凭据。

您可以在新的或现有的安装中随时启用或禁用 Sentinel 支持。从极狐GitLab 应用程序的角度来看，它所需要的只是
Sentinel 节点的正确凭据。

虽然它不需要所有 Sentinel 节点的列表，但在发生故障时，它需要能够访问所列节点中的至少一个。

> [!note]
> 以下步骤应在极狐GitLab 应用程序服务器上执行，
> 对于 HA 设置，该服务器最好不应安装 Redis 或 Sentinel。

1. SSH 登录到安装了极狐GitLab 应用程序的服务器。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加/更改以下行：

   ```ruby
   ## Must be the same in every sentinel node
   redis['master_name'] = 'gitlab-redis'

   ## The same password for Redis authentication you set up for the primary node.
   redis['master_password'] = 'redis-password-goes-here'

   ## A list of sentinels with `host` and `port`
   gitlab_rails['redis_sentinels'] = [
     {'host' => '10.0.0.1', 'port' => 26379},
     {'host' => '10.0.0.2', 'port' => 26379},
     {'host' => '10.0.0.3', 'port' => 26379}
   ]
   # gitlab_rails['redis_sentinels_password'] = 'sentinel-password-goes-here' # uncomment and set it to the same value as in sentinel['password']
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="step-5-enable-monitoring"></a>

### 步骤 5. 启用监控

如果您启用监控，则必须在**所有** Redis 服务器上启用。

1. 确保收集 [`CONSUL_SERVER_NODES`](../postgresql/replication_and_failover.md#consul-information)，即 Consul 服务器节点的 IP 地址或 DNS 记录，以供下一步使用。请注意它们呈现为 `Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z`
1. 创建/编辑 `/etc/gitlab/gitlab.rb` 并添加以下配置：

   ```ruby
   # Enable service discovery for Prometheus
   consul['enable'] = true
   consul['monitoring_service_discovery'] =  true

   # Replace placeholders
   # Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z
   # with the addresses of the Consul server nodes
   consul['configuration'] = {
      retry_join: %w(Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z),
   }

   # Set the network addresses that the exporters listen on
   node_exporter['listen_address'] = '0.0.0.0:9100'
   redis_exporter['listen_address'] = '0.0.0.0:9121'
   ```

1. 运行 `sudo gitlab-ctl reconfigure` 以编译配置。

<a id="example-of-a-minimal-configuration-with-1-primary-2-replicas-and-3-sentinels"></a>

## 包含 1 个主节点、2 个从节点和 3 个 Sentinel 的最小配置示例

在此示例中，我们假设所有服务器都有一个内部网络接口，其 IP 位于 `10.0.0.x` 范围内，并且它们可以使用这些 IP 相互连接。

在实际使用中，您还会设置防火墙规则以防止来自其他机器的未授权访问，并阻止来自外部（互联网）的流量。

我们使用与 [Redis 设置概览](#redis-setup-overview)和 [Sentinel 设置概览](#sentinel-setup-overview)文档中讨论的相同的 `3` 个节点
**Redis** + **Sentinel** 拓扑。

以下是每台**机器**及其分配的 **IP**的列表和描述：

- `10.0.0.1`：Redis 主节点 + Sentinel 1
- `10.0.0.2`：Redis 从节点 1 + Sentinel 2
- `10.0.0.3`：Redis 从节点 2 + Sentinel 3
- `10.0.0.4`：极狐GitLab 应用程序

在初始配置之后，如果由 Sentinel 节点发起故障转移，Redis 节点会被重新配置，**主节点**会从一个节点永久更改为另一个节点（包括在 `redis.conf`中），直到再次发起新的故障转移。

`sentinel.conf` 也会发生同样的情况，它会在初始执行后被覆盖，之后任何新的 sentinel 节点开始监视**主节点**，或故障转移提升了不同的**主节点**时也是如此。

> [!note]
> 极狐GitLab 仅在您第一次运行 `gitlab-ctl reconfigure` 时（在 `sentinel.conf` 存在之前）使用 `gitlab.rb`中的 `redis['master_ip']` 值。
> 在后续重新配置时，极狐GitLab 会直接从 `sentinel.conf` 读取当前的主节点 IP，以保留 Sentinel 故障转移后的状态。
> 要提升不同的节点作为主节点，请勿编辑 `redis['master_ip']`。
> 而应使用 Sentinel `FAILOVER` 命令：
>
> ```shell
> /opt/gitlab/embedded/bin/redis-cli -p 26379 SENTINEL failover gitlab-redis
> ```

<a id="example-configuration-for-redis-primary-and-sentinel-1"></a>

### Redis 主节点和 Sentinel 1 的示例配置

在 `/etc/gitlab/gitlab.rb`中：

```ruby
roles ['redis_sentinel_role', 'redis_master_role']
redis['bind'] = '10.0.0.1'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'
redis['master_name'] = 'gitlab-redis' # must be the same in every sentinel node
redis['master_password'] = 'redis-password-goes-here' # the same value defined in redis['password'] in the primary instance
redis['master_ip'] = '10.0.0.1' # ip of the initial primary redis instance
#redis['master_port'] = 6379 # port of the initial primary redis instance, uncomment to change to non default
sentinel['bind'] = '10.0.0.1'
# sentinel['password'] = 'sentinel-password-goes-here' # must be the same in every sentinel node, uncomment to set a password
# sentinel['port'] = 26379 # uncomment to change default port
sentinel['quorum'] = 2
# sentinel['down_after_milliseconds'] = 10000
# sentinel['failover_timeout'] = 60000
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="example-configuration-for-redis-replica-1-and-sentinel-2"></a>

### Redis 从节点 1 和 Sentinel 2 的示例配置

在 `/etc/gitlab/gitlab.rb`中：

```ruby
roles ['redis_sentinel_role', 'redis_replica_role']
redis['bind'] = '10.0.0.2'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'
redis['master_password'] = 'redis-password-goes-here'
redis['master_ip'] = '10.0.0.1' # IP of primary Redis server
#redis['master_port'] = 6379 # Port of primary Redis server, uncomment to change to non default
redis['master_name'] = 'gitlab-redis' # must be the same in every sentinel node
sentinel['bind'] = '10.0.0.2'
# sentinel['password'] = 'sentinel-password-goes-here' # must be the same in every sentinel node, uncomment to set a password
# sentinel['port'] = 26379 # uncomment to change default port
sentinel['quorum'] = 2
# sentinel['down_after_milliseconds'] = 10000
# sentinel['failover_timeout'] = 60000
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="example-configuration-for-redis-replica-2-and-sentinel-3"></a>

### Redis 从节点 2 和 Sentinel 3 的示例配置

在 `/etc/gitlab/gitlab.rb`中：

```ruby
roles ['redis_sentinel_role', 'redis_replica_role']
redis['bind'] = '10.0.0.3'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'
redis['master_password'] = 'redis-password-goes-here'
redis['master_ip'] = '10.0.0.1' # IP of primary Redis server
#redis['master_port'] = 6379 # Port of primary Redis server, uncomment to change to non default
redis['master_name'] = 'gitlab-redis' # must be the same in every sentinel node
sentinel['bind'] = '10.0.0.3'
# sentinel['password'] = 'sentinel-password-goes-here' # must be the same in every sentinel node, uncomment to set a password
# sentinel['port'] = 26379 # uncomment to change default port
sentinel['quorum'] = 2
# sentinel['down_after_milliseconds'] = 10000
# sentinel['failover_timeout'] = 60000
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="example-configuration-for-the-gitlab-application"></a>

### 极狐GitLab 应用程序的示例配置

在 `/etc/gitlab/gitlab.rb`中：

```ruby
redis['master_name'] = 'gitlab-redis'
redis['master_password'] = 'redis-password-goes-here'
gitlab_rails['redis_sentinels'] = [
  {'host' => '10.0.0.1', 'port' => 26379},
  {'host' => '10.0.0.2', 'port' => 26379},
  {'host' => '10.0.0.3', 'port' => 26379}
]
# gitlab_rails['redis_sentinels_password'] = 'sentinel-password-goes-here' # uncomment and set it to the same value as in sentinel['password']
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="advanced-configuration"></a>

## 高级配置

本节介绍超出推荐配置和最小配置范围的配置选项。

<a id="running-multiple-redis-clusters"></a>

### 运行多个 Redis 集群

Linux 软件包支持为不同的持久化类别运行单独的 Redis 和 Sentinel 实例。

| 类别              | 用途 |
|--------------------|---------|
| `cache`            | 存储缓存数据。 |
| `queues`           | 存储 Sidekiq 后台作业。 |
| `shared_state`     | 存储会话相关数据和其他持久化数据。 |
| `actioncable`      | ActionCable 的发布/订阅队列后端。 |
| `trace_chunks`     | 存储 [CI 跟踪块](../cicd/job_logs.md#incremental-logging)数据。 |
| `concurrency_limit` | 存储用于 Sidekiq 并发限制的延迟作业。 |
| `rate_limiting`    | 存储[速率限制](../settings/user_and_ip_rate_limits.md)状态。 |
| `sessions`         | 存储会话。 |
| `repository_cache` | 存储特定于代码仓库的缓存数据。 |

要使其与 Sentinel 配合工作：

1. 根据您的需求[配置不同的 Redis/Sentinel](#configuring-redis) 实例。
1. 对于每个 Rails 应用程序实例，编辑其 `/etc/gitlab/gitlab.rb` 文件：

   ```ruby
   gitlab_rails['redis_cache_instance'] = REDIS_CACHE_URL
   gitlab_rails['redis_queues_instance'] = REDIS_QUEUES_URL
   gitlab_rails['redis_shared_state_instance'] = REDIS_SHARED_STATE_URL
   gitlab_rails['redis_actioncable_instance'] = REDIS_ACTIONCABLE_URL
   gitlab_rails['redis_trace_chunks_instance'] = REDIS_TRACE_CHUNKS_URL
   gitlab_rails['redis_rate_limiting_instance'] = REDIS_RATE_LIMITING_URL
   gitlab_rails['redis_sessions_instance'] = REDIS_SESSIONS_URL
   gitlab_rails['redis_repository_cache_instance'] = REDIS_REPOSITORY_CACHE_URL

   # Configure the Sentinels
   gitlab_rails['redis_cache_sentinels'] = [
     { host: REDIS_CACHE_SENTINEL_HOST, port: 26379 },
     { host: REDIS_CACHE_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_queues_sentinels'] = [
     { host: REDIS_QUEUES_SENTINEL_HOST, port: 26379 },
     { host: REDIS_QUEUES_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_shared_state_sentinels'] = [
     { host: SHARED_STATE_SENTINEL_HOST, port: 26379 },
     { host: SHARED_STATE_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_actioncable_sentinels'] = [
     { host: ACTIONCABLE_SENTINEL_HOST, port: 26379 },
     { host: ACTIONCABLE_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_trace_chunks_sentinels'] = [
     { host: TRACE_CHUNKS_SENTINEL_HOST, port: 26379 },
     { host: TRACE_CHUNKS_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_rate_limiting_sentinels'] = [
     { host: RATE_LIMITING_SENTINEL_HOST, port: 26379 },
     { host: RATE_LIMITING_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_sessions_sentinels'] = [
     { host: SESSIONS_SENTINEL_HOST, port: 26379 },
     { host: SESSIONS_SENTINEL_HOST2, port: 26379 }
   ]
   gitlab_rails['redis_repository_cache_sentinels'] = [
     { host: REPOSITORY_CACHE_SENTINEL_HOST, port: 26379 },
     { host: REPOSITORY_CACHE_SENTINEL_HOST2, port: 26379 }
   ]

   # gitlab_rails['redis_cache_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_queues_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_shared_state_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_actioncable_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_trace_chunks_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_rate_limiting_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_sessions_sentinels_password'] = 'sentinel-password-goes-here'
   # gitlab_rails['redis_repository_cache_sentinels_password'] = 'sentinel-password-goes-here'
   ```

   - Redis URL 应采用以下格式：`redis://:PASSWORD@SENTINEL_PRIMARY_NAME`，其中：
     - `PASSWORD` 是 Redis 实例的明文密码。
     - `SENTINEL_PRIMARY_NAME` 是使用 `redis['master_name']` 设置的 Sentinel 主节点名称，
       例如 `gitlab-redis-cache`。

1. 保存文件并重新配置极狐GitLab 以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

> [!note]
> 对于每个持久化类别，除非被前述设置覆盖，
> 极狐GitLab 默认使用 `gitlab_rails['redis_sentinels']` 中指定的
> 配置。

<a id="control-running-services"></a>

### 控制运行的服务

在前面的示例中，我们使用了 `redis_sentinel_role` 和 `redis_master_role`，这简化了配置更改的数量。

如果您想要更多控制，以下是启用时每个角色自动为您设置的内容：

```ruby
## Redis Sentinel Role
redis_sentinel_role['enable'] = true

# When Sentinel Role is enabled, the following services are also enabled
sentinel['enable'] = true

# The following services are disabled
redis['enable'] = false
bootstrap['enable'] = false
nginx['enable'] = false
postgresql['enable'] = false
gitlab_rails['enable'] = false
mailroom['enable'] = false

-------

## Redis primary/replica Role
redis_master_role['enable'] = true # enable only one of them
redis_replica_role['enable'] = true # enable only one of them

# When Redis primary or Replica role are enabled, the following services are
# enabled/disabled. If Redis and Sentinel roles are combined, both
# services are enabled.

# The following services are disabled
sentinel['enable'] = false
bootstrap['enable'] = false
nginx['enable'] = false
postgresql['enable'] = false
gitlab_rails['enable'] = false
mailroom['enable'] = false

# For Redis Replica role, also change this setting from default 'true' to 'false':
redis['master'] = false
```

您可以在 [`gitlab_rails.rb`](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/files/gitlab-cookbooks/gitlab/libraries/gitlab_rails.rb)中找到定义的相关属性。

<a id="control-startup-behavior"></a>

### 控制启动行为

要防止内置 Redis 服务在启动时启动，或在更改其配置后重启：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['start_down'] = true
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

如果您需要测试新的从节点，可以将 `start_down` 设置为 `true` 并手动启动该节点。在确认新的从节点在 Redis 集群中正常工作后，将 `start_down` 设置为 `false` 并重新配置极狐GitLab，以确保该节点在运行期间按预期启动和重启。

<a id="control-replica-configuration"></a>

### 控制从节点配置

要防止 `replicaof` 行出现在 Redis 配置文件中：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['set_replicaof'] = false
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

此设置可用于独立于其他 Redis 设置来阻止某个 Redis 节点的复制。

<a id="use-valkey-instead-of-redis"></a>

## 使用 Valkey 代替 Redis

您可以使用 [Valkey](https://valkey.io/) 作为 Redis 在复制
和故障转移设置中的直接替代品。Valkey 使用与 Redis 相同的角色和配置选项。

<a id="configure-valkey-primary-and-replica-nodes"></a>

### 配置 Valkey 主节点和从节点

在每个节点（主节点和从节点）上，将以下内容添加到 `/etc/gitlab/gitlab.rb` 以从 Redis 切换到 Valkey：

```ruby
# Use the same Redis roles
roles ['redis_master_role']  # or 'redis_replica_role' for replicas

# Switch to Valkey
redis['backend'] = 'valkey'

# Use the same configuration options as for Redis
redis['bind'] = '10.0.0.1'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'

gitlab_rails['auto_migrate'] = false
```

<a id="configure-sentinel-for-valkey"></a>

### 为 Valkey 配置 Sentinel

在每个 Sentinel 节点上，将以下内容添加到 `/etc/gitlab/gitlab.rb`：

```ruby
roles ['redis_sentinel_role']

# Switch redis backend to Valkey
# Then Sentinel will use the same backend
redis['backend'] = 'valkey'

# Sentinel configuration (same as for Redis)
redis['master_name'] = 'gitlab-redis'
redis['master_password'] = 'redis-password-goes-here'
redis['master_ip'] = '10.0.0.1'
redis['port'] = 6379

sentinel['bind'] = '10.0.0.1'
sentinel['quorum'] = 2
```

所有其他 Sentinel 配置选项与
[配置 Redis Sentinel 实例](#step-3-configuring-the-redis-sentinel-instances)中记录的相同。

<a id="known-issues"></a>

### 已知问题

- 由于已知的[议题 589642](https://gitlab.com/gitlab-org/gitlab/-/issues/589642)，管理区域会错误地报告 Valkey 版本。此问题
  不影响所安装的 Valkey 版本或其运行方式。

<a id="secure-redis-and-sentinel-with-tls"></a>

## 使用 TLS 保护 Redis 和 Sentinel

有关使用 TLS 保护 Redis 和 Sentinel
通信的全面信息，请参阅[使用 TLS 保护 Redis 和 Sentinel](tls.md)。

<a id="troubleshooting"></a>

## 故障排除

请参阅 [Redis 故障排除指南](troubleshooting.md)。

<a id="further-reading"></a>

## 延伸阅读

阅读更多：

1. [参考架构](../reference_architectures/_index.md)
1. [配置数据库](../postgresql/replication_and_failover.md)
1. [配置 NFS](../nfs.md)
1. [配置负载均衡器](../load_balancer.md)
