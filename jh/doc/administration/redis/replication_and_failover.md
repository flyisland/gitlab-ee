---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Linux 软件包实现 Redis 复制和故障转移
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档适用于 Linux 软件包。若要使用自己的非内置 Redis，请参阅[使用自有实例实现 Redis 复制和故障转移](replication_and_failover_external.md)。

在 Redis 术语中，`primary` 被称为 `master`。在本文档中，除了一些要求使用 `master` 的设置项外，我们使用 `primary` 来代替 `master`。

在可扩展的环境中，可以使用 **主节点** x **从节点** 拓扑，并借助 [Redis 哨兵](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 服务来监控并自动启动故障转移过程。

如果使用哨兵，Redis 需要认证。更多信息请参见 [Redis 安全](https://redis.io/docs/latest/operate/rc/security/) 文档。我们建议结合使用 Redis 密码和严格的防火墙规则来保护你的 Redis 服务。
强烈建议在将 Redis 配置到极狐GitLab 之前，阅读 [Redis 哨兵](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 文档，以充分理解拓扑和架构。

在深入配置用于复制拓扑的 Redis 和 Redis 哨兵之前，请务必通读本文档，以更好地理解各组件如何协同工作。

你至少需要 `3` 台独立机器：物理机，或者是运行在不同物理机上的虚拟机。所有主节点和从节点 Redis 实例必须运行在不同的机器上，这一点至关重要。如果你未能按照这种特定方式准备机器，共享环境中的任何问题都可能导致整个设置宕机。

在一个哨兵与一个主节点或从节点 Redis 实例运行在同一台机器上是允许的。不过，同一台机器上不应该有超过一个哨兵。

你还需要考虑底层网络拓扑，确保 Redis / 哨兵与极狐GitLab 实例之间具有冗余连接，否则网络将成为单点故障。

在伸缩环境中运行 Redis 需要满足以下几点：

- 多个 Redis 实例
- 以 **主节点** x **从节点** 拓扑运行 Redis
- 多个哨兵实例
- 应用程序支持并能够看到所有哨兵和 Redis 实例

Redis 哨兵可以处理高可用环境中的最重要任务，帮助服务器以最少甚至零停机时间保持在线。Redis 哨兵可以：

- 监控 **主节点** 和 **从节点** 实例，查看它们是否可用
- 当 **主节点** 发生故障时，将一个 **从节点** 提升为新的 **主节点**
- 当故障的 **主节点** 重新上线时，将其降级为 **从节点**（防止数据分区）
- 可被应用程序查询，以便始终连接到当前的 **主节点** 服务器

当 **主节点** 无法响应时，应用程序（在我们的例子中是极狐GitLab）有责任处理超时并重新连接（向 **哨兵** 查询新的 **主节点**）。

为了更好地理解如何正确设置哨兵，请先阅读 [Redis 哨兵](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/) 文档，因为配置错误可能导致数据丢失或整个集群宕机，使故障转移努力失效。

<a id="recommended-setup"></a>

## 推荐设置

对于最小设置，你需要在 `3` 台 **独立** 机器上安装 Linux 软件包，每台都同时运行 **Redis** 和 **哨兵**：

- Redis 主节点 + 哨兵
- Redis 从节点 + 哨兵
- Redis 从节点 + 哨兵

如果你不确定或不理解为何需要这些节点数量，请阅读 [Redis 设置概览](#redis-setup-overview) 和 [哨兵设置概览](#sentinel-setup-overview)。

对于能够抵御更多故障的推荐设置，你需要在 `5` 台 **独立** 机器上安装 Linux 软件包，每台都同时运行 **Redis** 和 **哨兵**：

- Redis 主节点 + 哨兵
- Redis 从节点 + 哨兵
- Redis 从节点 + 哨兵
- Redis 从节点 + 哨兵
- Redis 从节点 + 哨兵

<a id="redis-setup-overview"></a>

### Redis 设置概览

你必须至少拥有 `3` 台 Redis 服务器：`1` 个主节点，`2` 个从节点，并且它们需要各自位于独立的机器上。

你可以拥有额外的 Redis 节点，这有助于在更多节点宕机的情况下存活。只要在线节点只有 `2` 个，就不会启动故障转移。

举例来说，如果你有 `6` 个 Redis 节点，那么最多可以有 `3` 个同时宕机。

哨兵节点有不同的要求。如果你将它们部署在相同的 Redis 机器上，那么在计算要配置的节点数量时，可能需要考虑这些限制。更多信息请参见 [哨兵设置概览](#sentinel-setup-overview) 文档。

所有 Redis 节点应该以相同方式配置，并具有相似的服务器规格，因为在故障转移情况下，任何 **从节点** 都可能被哨兵服务器提升为新的 **主节点**。

复制需要认证，因此你需要定义一个密码来保护所有 Redis 节点和哨兵。它们都共享相同的密码，并且所有实例必须能够通过网络相互通信。

<a id="sentinel-setup-overview"></a>

### 哨兵设置概览

哨兵同时监控其他哨兵和 Redis 节点。每当一个哨兵检测到某个 Redis 节点没有响应时，它会将该节点的状态通知给其他哨兵。哨兵必须达到 _法定数量_（同意某个节点宕机的最少哨兵数量）才能启动故障转移。

当满足 **法定数量** 时，所有已知哨兵节点中的 **多数** 必须可用且可访问，以便它们选举出哨兵 **领导者**，由其做出所有决策来恢复服务可用性，具体包括：

- 提升一个新的 **主节点**
- 重新配置其他 **从节点**，使其指向新的 **主节点**
- 向所有其他哨兵对等节点通告新的 **主节点**
- 当旧的 **主节点** 重新上线时，重新配置并将其降级为 **从节点**

你必须至少拥有 `3` 个 Redis 哨兵服务器，并且每个都需要位于独立的机器上（这些机器被认为会独立故障），理想情况下应在不同的地理区域。

你可以将它们配置在也运行其他 Redis 服务器的同一台机器上，但要明白，如果整台机器宕机，你将同时失去一个哨兵和一个 Redis 实例。

哨兵的数量理想情况下应始终为 **奇数**，以便共识算法在故障时能够有效发挥作用。

在 `3` 个节点的拓扑中，你只能承受 `1` 个哨兵节点宕机。当哨兵的 **多数** 宕机时，网络分区保护将阻止破坏性操作，并且故障转移 **不会启动**。

以下是一些示例：

- 在 `5` 或 `6` 个哨兵的情况下，最多允许 `2` 个宕机才能开始故障转移。
- 在 `7` 个哨兵的情况下，最多允许 `3` 个节点宕机。

当无法达成 **共识** 时，**领导者** 选举有时可能会在投票轮次中失败。在这种情况下，将在 `sentinel['failover_timeout']`（以毫秒为单位）定义的时间后再次尝试。

> [!note]
> 我们可以在后面看到 `sentinel['failover_timeout']` 的定义位置。

`failover_timeout` 变量有许多不同的用途。根据官方文档：

- 在给定哨兵已经对同一主节点尝试过前一次故障转移之后，重新启动故障转移所需的时间是故障转移超时时间的两倍。

- 根据哨兵当前配置，一个从节点正在复制错误的主节点时，强制其复制正确主节点所需的时间，恰好是故障转移超时时间（从哨兵检测到错误配置的那一刻开始计算）。

- 取消已经在进行但尚未产生任何配置更改（尚未执行 `REPLICAOF NO ONE` 并且未被提升的从节点确认）的故障转移所需的时间。

- 进行中的故障转移等待所有从节点重新配置为新主节点的从节点的最长时间。然而，即使超过这个时间，哨兵仍然会重新配置这些从节点，但不会按照指定的精准并行同步进度进行。

<a id="configuring-redis"></a>

## 配置 Redis

本节介绍如何安装并设置新的 Redis 实例。

假设你已从头开始安装了极狐GitLab 及其所有组件。如果你已经安装并运行了 Redis，请阅读如何[从单机安装切换](#switching-from-an-existing-single-machine-installation)。

> [!note]
> Redis 节点（包括主节点和从节点）需要在 `redis['password']` 中定义相同的密码。在故障转移期间的任何时刻，哨兵都可以重新配置节点，并将其状态从主节点切换为从节点，反之亦然。

<a id="requirements"></a>

### 前提条件

Redis 设置的前提条件如下：

1. 按照[推荐设置](#recommended-setup) 部分的规定，准备最低数量的实例。
1. 我们**不建议**将 Redis 或 Redis 哨兵安装在运行极狐GitLab 应用程序的同一台机器上，因为这会削弱你的高可用配置。但是，你也可以选择将 Redis 和哨兵安装在同一台机器上。
1. 所有 Redis 节点必须能够相互通信，并接受通过 Redis（`6379`）和哨兵（`26379`）端口的入站连接（除非你更改了默认端口）。
1. 托管极狐GitLab 应用程序的服务器必须能够访问 Redis 节点。
1. 使用防火墙保护节点免受外部网络（[互联网](https://jihulab.com/gitlab-org/gitlab-foss/uploads/c4cc8cd353604bd80315f9384035ff9e/The_Internet_IT_Crowd.png)）的访问。

<a id="switching-from-an-existing-single-machine-installation"></a>

### 从现有单机安装切换

如果你已经有一个运行中的单机极狐GitLab 安装，则需要首先从这台机器进行复制，然后再停用其中的 Redis 实例。

你的单机安装是初始的 **主节点**，其他 `3` 个应配置为指向这台机器的 **从节点**。

在复制追上进度后，你需要停止单机安装中的服务，将 **主节点** 切换到其中一个新节点。

在配置中进行必要的更改，然后重新启动新节点。

要在单机安装中禁用 Redis，请编辑 `/etc/gitlab/gitlab.rb`：

```ruby
redis['enable'] = false
```

如果你未能先进行复制，可能会丢失数据（未处理的后台作业）。

<a id="step-1-configuring-the-primary-redis-instance"></a>

### 步骤 1. 配置主节点 Redis 实例

1. SSH 登录到 **主节点** Redis 服务器。
1. 使用极狐GitLab 下载页面上的 **步骤 1 和 2** [下载并安装](https://gitlab.cn/install/) 你需要的 Linux 软件包。
   - 确保选择正确的 Linux 软件包，其版本和类型（基础版、企业版）与你当前的安装相同。
   - 不要完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   # 将服务器角色指定为 'redis_master_role'
   roles ['redis_master_role']

   # 指向一个其他机器可以访问的本地 IP 地址。
   # 你也可以将 bind 设置为 '0.0.0.0'，使其监听所有接口。
   # 如果你确实需要绑定到一个外部可访问的 IP，请确保添加额外的防火墙规则以防止未授权访问。
   redis['bind'] = '10.0.0.1'

   # 定义一个端口，以便 Redis 可以监听 TCP 请求，从而允许其他机器连接到它。
   redis['port'] = 6379

   # 为 Redis 设置密码认证（在所有节点中使用相同的密码）。
   redis['password'] = 'redis-password-goes-here'
   ```

1. 只有主极狐GitLab 应用程序服务器才应处理数据库迁移。为防止在升级时运行数据库迁移，请将以下配置添加到你的 `/etc/gitlab/gitlab.rb` 文件中：

   ```ruby
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

> [!note]
> 你可以指定多个角色，如哨兵和 Redis，例如： `roles ['redis_sentinel_role', 'redis_master_role']`。 阅读更多关于 [角色](https://gitlab.cn/docs/omnibus/roles/) 的信息。

<a id="step-2-configuring-the-replica-redis-instances"></a>

### 步骤 2. 配置从节点 Redis 实例

1. SSH 登录到 **从节点** Redis 服务器。
1. 使用极狐GitLab 下载页面上的 **步骤 1 和 2** [下载并安装](https://gitlab.cn/install/) 你需要的 Linux 软件包。
   - 确保选择正确的 Linux 软件包，其版本和类型（基础版、企业版）与你当前的安装相同。
   - 不要完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   # 将服务器角色指定为 'redis_replica_role'
   roles ['redis_replica_role']

   # 指向一个其他机器可以访问的本地 IP 地址。
   # 你也可以将 bind 设置为 '0.0.0.0'，使其监听所有接口。
   # 如果你确实需要绑定到一个外部可访问的 IP，请确保添加额外的防火墙规则以防止未授权访问。
   redis['bind'] = '10.0.0.2'

   # 定义一个端口，以便 Redis 可以监听 TCP 请求，从而允许其他机器连接到它。
   redis['port'] = 6379

   # 你为主节点设置的 Redis 认证密码。
   redis['password'] = 'redis-password-goes-here'

   # 主节点 Redis 的 IP 地址。
   redis['master_ip'] = '10.0.0.1'

   # 主节点 Redis 服务器的端口，取消注释以更改为非默认值。默认为 `6379`。
   #redis['master_port'] = 6379
   ```

1. 为防止在升级时自动运行重新配置，请运行：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

1. 只有主极狐GitLab 应用程序服务器才应处理数据库迁移。为防止在升级时运行数据库迁移，请将以下配置添加到你的 `/etc/gitlab/gitlab.rb` 文件中：

   ```ruby
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 对所有其他从节点重复上述步骤。

> [!note]
> 你可以指定多个角色，如哨兵和 Redis，例如： `roles ['redis_sentinel_role', 'redis_master_role']`。 阅读更多关于 [角色](https://gitlab.cn/docs/omnibus/roles/) 的信息。

这些值在故障转移后无需在 `/etc/gitlab/gitlab.rb` 中再次更改，因为节点由哨兵管理，即使在执行 `gitlab-ctl reconfigure` 之后，它们的配置也会由相同的哨兵恢复。

<a id="step-3-configuring-the-redis-sentinel-instances"></a>

### 步骤 3. 配置 Redis 哨兵实例

{{< history >}}

- 在 极狐GitLab 16.1 中引入了对哨兵密码认证的支持。

{{< /history >}}

现在 Redis 服务器都已设置完成，我们来配置哨兵服务器。

如果你不确定 Redis 服务器是否正常工作并正确复制，请阅读[故障排除复制](troubleshooting.md#troubleshooting-redis-replication)，并在继续设置哨兵之前修复问题。

你必须至少拥有 `3` 个 Redis 哨兵服务器，并且每个都需要位于独立的机器上。你可以将它们配置在也运行其他 Redis 服务器的同一台机器上。

使用极狐GitLab 企业版，你可以利用 Linux 软件包在多台机器上设置哨兵守护进程。

1. SSH 登录到托管 Redis 哨兵的服务器。
1. **如果哨兵与其他 Redis 实例部署在同一节点，可以跳过此步骤**。

   使用极狐GitLab 下载页面上的 **步骤 1 和 2** [下载并安装](https://gitlab.cn/install/) Linux 企业版软件包。
   - 确保选择正确的 Linux 软件包，其版本与正在运行的极狐GitLab 应用程序相同。
   - 不要完成下载页面上的任何其他步骤。

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容（如果哨兵与其他 Redis 实例部署在同一节点，下面的某些值可能会重复）：

   ```ruby
   roles ['redis_sentinel_role']

   # 在每个哨兵节点中必须相同
   redis['master_name'] = 'gitlab-redis'

   # 你为主节点设置的 Redis 认证密码。
   redis['master_password'] = 'redis-password-goes-here'

   # 主节点 Redis 的 IP 地址。
   redis['master_ip'] = '10.0.0.1'

   # 定义一个端口，以便 Redis 可以监听 TCP 请求，从而允许其他机器连接到它。
   redis['port'] = 6379

   # 主节点 Redis 服务器的端口，取消注释以更改为非默认值。默认为 `6379`。
   #redis['master_port'] = 6379

   ## 配置哨兵
   sentinel['bind'] = '10.0.0.1'

   ## 可选的哨兵认证密码。默认不要求密码。
   # sentinel['password'] = 'sentinel-password-goes here'

   # 哨兵监听的端口，取消注释以更改为非默认值。默认为 `26379`。
   # sentinel['port'] = 26379

   ## 法定数量必须反映启动故障转移所需的投票哨兵数量。
   ## 该值不得大于哨兵的数量。
   ##
   ## 法定数量可以通过两种方式调整哨兵：
   ## 1. 如果将法定数量设置为小于我们部署的哨兵多数的值，我们基本上使哨兵对主节点故障更加敏感，
   ##    即使只有少数哨兵无法与主节点通信，也会触发故障转移。
   ## 1. 如果将法定数量设置为大于哨兵多数的值，我们使得哨兵只有在有非常大量（超过多数）连接良好、
   ##    且一致认为主节点宕机的哨兵时才能执行故障转移。
   sentinel['quorum'] = 2

   ## 在指定的毫秒数后，将无响应的服务器视为宕机。
   # sentinel['down_after_milliseconds'] = 10000

   ## 指定故障转移超时时间，以毫秒为单位。该值有多种用途：
   ##
   ## - 在给定哨兵已经对同一主节点尝试过前一次故障转移之后，重新启动故障转移所需的时间是故障转移超时时间的两倍。
   ##
   ## - 根据哨兵当前配置，一个从节点正在复制错误的主节点时，强制其复制正确主节点所需的时间，
   ##   恰好是故障转移超时时间（从哨兵检测到错误配置的那一刻开始计算）。
   ##
   ## - 取消已经在进行但尚未产生任何配置更改（尚未执行 `REPLICAOF NO ONE` 并且未被提升的从节点确认）的故障转移所需的时间。
   ##
   ## - 进行中的故障转移等待所有从节点重新配置为新主节点的从节点的最长时间。然而，即使超过这个时间，
   ##   哨兵仍然会重新配置这些从节点，但不会按照指定的精准并行同步进度进行。
   # sentinel['failover_timeout'] = 60000
   ```

1. 为防止在升级时运行数据库迁移，请运行：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

   只有主极狐GitLab 应用程序服务器才应处理数据库迁移。

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 对所有其他哨兵节点重复上述步骤。

<a id="step-4-configuring-the-gitlab-application"></a>

### 步骤 4. 配置极狐GitLab 应用程序

最后一步是将 Redis 哨兵服务器和认证凭证告知主极狐GitLab 应用程序服务器。

你可以在新的或现有安装中随时启用或禁用哨兵支持。从极狐GitLab 应用程序的角度来看，它只需要正确的哨兵节点凭证。

虽然它不需要所有哨兵节点的列表，但在发生故障时，它需要能够访问列表中至少一个哨兵。

> [!note]
> 以下步骤应在极狐GitLab 应用程序服务器上执行，理想情况下，该服务器上不应为高可用设置而运行 Redis 或哨兵。

1. SSH 登录到安装极狐GitLab 应用程序的服务器。
1. 编辑 `/etc/gitlab/gitlab.rb` 并添加/更改以下行：

   ```ruby
   ## 在每个哨兵节点中必须相同
   redis['master_name'] = 'gitlab-redis'

   ## 你为主节点设置的 Redis 认证密码。
   redis['master_password'] = 'redis-password-goes-here'

   ## 哨兵列表，包含 `host` 和 `port`
   gitlab_rails['redis_sentinels'] = [
     {'host' => '10.0.0.1', 'port' => 26379},
     {'host' => '10.0.0.2', 'port' => 26379},
     {'host' => '10.0.0.3', 'port' => 26379}
   ]
   # gitlab_rails['redis_sentinels_password'] = 'sentinel-password-goes-here' # 取消注释并设置与 sentinel['password'] 相同的值
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="step-5-enable-monitoring"></a>

### 步骤 5. 启用监控

如果启用监控，则必须在 **所有** Redis 服务器上启用。

1. 确保收集 [`CONSUL_SERVER_NODES`](../postgresql/replication_and_failover.md#consul-information)，即 Consul 服务器节点的 IP 地址或 DNS 记录，以备下一步使用。请注意，它们通常呈现为 `Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z`。
1. 创建/编辑 `/etc/gitlab/gitlab.rb` 并添加以下配置：

   ```ruby
   # 为 Prometheus 启用服务发现
   consul['enable'] = true
   consul['monitoring_service_discovery'] =  true

   # 替换占位符
   # Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z
   # 为 Consul 服务器节点的地址
   consul['configuration'] = {
      retry_join: %w(Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z),
   }

   # 设置导出器监听的网络地址
   node_exporter['listen_address'] = '0.0.0.0:9100'
   redis_exporter['listen_address'] = '0.0.0.0:9121'
   ```

1. 运行 `sudo gitlab-ctl reconfigure` 以编译配置。

<a id="example-of-a-minimal-configuration-with-1-primary-2-replicas-and-3-sentinels"></a>

## 1 主节点、2 从节点和 3 哨兵的最小配置示例

在本示例中，我们假设所有服务器都有一个内部网络接口，IP 范围在 `10.0.0.x` 内，并且它们可以使用这些 IP 相互连接。

在实际使用中，你还需要设置防火墙规则，以防止来自其他机器的未授权访问，并阻止来自外部（互联网）的流量。

我们使用与 [Redis 设置概览](#redis-setup-overview) 和 [哨兵设置概览](#sentinel-setup-overview) 文档中讨论的相同的 `3` 节点 **Redis** + **哨兵** 拓扑。

以下是每台 **机器** 及其分配的 **IP** 的列表和描述：

- `10.0.0.1`：Redis 主节点 + 哨兵 1
- `10.0.0.2`：Redis 从节点 1 + 哨兵 2
- `10.0.0.3`：Redis 从节点 2 + 哨兵 3
- `10.0.0.4`：极狐GitLab 应用程序

在初始配置之后，如果哨兵节点启动故障转移，Redis 节点将被重新配置，并且 **主节点** 会永久更改（包括在 `redis.conf` 中），从一个节点切换到另一个节点，直到再次启动新的故障转移。

`sentinel.conf` 同样会在初始执行后被覆盖，无论何时有新的哨兵节点开始监控 **主节点**，或者是故障转移提升了不同的 **主节点** 节点。

<a id="example-configuration-for-redis-primary-and-sentinel-1"></a>

### Redis 主节点和哨兵 1 的示例配置

在 `/etc/gitlab/gitlab.rb` 中：

```ruby
roles ['redis_sentinel_role', 'redis_master_role']
redis['bind'] = '10.0.0.1'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'
redis['master_name'] = 'gitlab-redis' # 在每个哨兵节点中必须相同
redis['master_password'] = 'redis-password-goes-here' # 与主节点实例中 redis['password'] 定义的值相同
redis['master_ip'] = '10.0.0.1' # 初始主节点 Redis 实例的 IP
#redis['master_port'] = 6379 # 初始主节点 Redis 实例的端口，取消注释以更改为非默认值
sentinel['bind'] = '10.0.0.1'
# sentinel['password'] = 'sentinel-password-goes-here' # 在每个哨兵节点中必须相同，取消注释以设置密码
# sentinel['port'] = 26379 # 取消注释以更改默认端口
sentinel['quorum'] = 2
# sentinel['down_after_milliseconds'] = 10000
# sentinel['failover_timeout'] = 60000
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="example-configuration-for-redis-replica-1-and-sentinel-2"></a>

### Redis 从节点 1 和哨兵 2 的示例配置

在 `/etc/gitlab/gitlab.rb` 中：
```ruby
roles ['redis_sentinel_role', 'redis_replica_role']
redis['bind'] = '10.0.0.2'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'
redis['master_password'] = 'redis-password-goes-here'
redis['master_ip'] = '10.0.0.1' # 主 Redis 服务器的 IP
#redis['master_port'] = 6379 # 主 Redis 服务器的端口，取消注释可更改为非默认值
redis['master_name'] = 'gitlab-redis' # 必须在每个 sentinel 节点中保持一致
sentinel['bind'] = '10.0.0.2'
# sentinel['password'] = 'sentinel-password-goes-here' # 必须在每个 sentinel 节点中保持一致，取消注释以设置密码
# sentinel['port'] = 26379 # 取消注释以更改默认端口
sentinel['quorum'] = 2
# sentinel['down_after_milliseconds'] = 10000
# sentinel['failover_timeout'] = 60000
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="example-configuration-for-redis-replica-2-and-sentinel-3"></a>

### Redis 副本 2 和 Sentinel 3 的示例配置

在 `/etc/gitlab/gitlab.rb` 中：

```ruby
roles ['redis_sentinel_role', 'redis_replica_role']
redis['bind'] = '10.0.0.3'
redis['port'] = 6379
redis['password'] = 'redis-password-goes-here'
redis['master_password'] = 'redis-password-goes-here'
redis['master_ip'] = '10.0.0.1' # 主 Redis 服务器的 IP
#redis['master_port'] = 6379 # 主 Redis 服务器的端口，取消注释可更改为非默认值
redis['master_name'] = 'gitlab-redis' # 必须在每个 sentinel 节点中保持一致
sentinel['bind'] = '10.0.0.3'
# sentinel['password'] = 'sentinel-password-goes-here' # 必须在每个 sentinel 节点中保持一致，取消注释以设置密码
# sentinel['port'] = 26379 # 取消注释以更改默认端口
sentinel['quorum'] = 2
# sentinel['down_after_milliseconds'] = 10000
# sentinel['failover_timeout'] = 60000
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="example-configuration-for-the-gitlab-application"></a>

### 极狐GitLab 应用程序的示例配置

在 `/etc/gitlab/gitlab.rb` 中：

```ruby
redis['master_name'] = 'gitlab-redis'
redis['master_password'] = 'redis-password-goes-here'
gitlab_rails['redis_sentinels'] = [
  {'host' => '10.0.0.1', 'port' => 26379},
  {'host' => '10.0.0.2', 'port' => 26379},
  {'host' => '10.0.0.3', 'port' => 26379}
]
# gitlab_rails['redis_sentinels_password'] = 'sentinel-password-goes-here' # 取消注释并将其设置为与 sentinel['password'] 相同的值
```

[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="advanced-configuration"></a>

## 高级配置

本节涵盖了超越推荐和最小配置的配置选项。

<a id="running-multiple-redis-clusters"></a>

### 运行多个 Redis 集群

Linux 软件包支持为不同的持久化类运行单独的 Redis 和 Sentinel 实例。

| 类                | 用途                                    |
| ----------------- | --------------------------------------- |
| `缓存`            | 存储缓存数据。                          |
| `队列`            | 存储 Sidekiq 后台作业。                 |
| `共享状态`        | 存储会话相关和其他持久性数据。          |
| `actioncable`     | ActionCable 的发布/订阅队列后端。       |
| `跟踪分块`        | 存储 [CI 跟踪分块](../cicd/job_logs.md#incremental-logging) 数据。 |
| `速率限制`        | 存储 [速率限制](../settings/user_and_ip_rate_limits.md) 状态。 |
| `会话`            | 存储会话。                              |
| `仓库缓存`        | 存储特定于仓库的缓存数据。              |

要使此功能与 Sentinel 配合使用：

1. 根据你的需求[配置不同的 Redis/Sentinel](#configuring-redis) 实例。
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

   # 配置 Sentinels
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

   - Redis URL 的格式应为：`redis://:PASSWORD@SENTINEL_PRIMARY_NAME`，其中：
     - `PASSWORD` 是 Redis 实例的明文密码。
     - `SENTINEL_PRIMARY_NAME` 是通过 `redis['master_name']` 设置的 Sentinel 主节点名称，
       例如 `gitlab-redis-cache`。

1. 保存文件并重新配置极狐GitLab 以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

> [!note]
> 对于每个持久化类，极狐GitLab 默认使用 `gitlab_rails['redis_sentinels']` 中指定的配置，
> 除非被上述设置覆盖。

<a id="control-running-services"></a>

### 控制运行中的服务

在之前的示例中，我们使用了 `redis_sentinel_role` 和
`redis_master_role`，这简化了配置更改的数量。

如果你需要更精细的控制，以下是启用后它们各自自动为你设置的内容：

```ruby
## Redis Sentinel 角色
redis_sentinel_role['enable'] = true

# 当 Sentinel 角色启用时，以下服务也会启用
sentinel['enable'] = true

# 以下服务将被禁用
redis['enable'] = false
bootstrap['enable'] = false
nginx['enable'] = false
postgresql['enable'] = false
gitlab_rails['enable'] = false
mailroom['enable'] = false

-------

## Redis 主/副本角色
redis_master_role['enable'] = true # 仅启用其中一个
redis_replica_role['enable'] = true # 仅启用其中一个

# 当 Redis 主或副本角色启用时，以下服务
# 将启用/禁用。如果 Redis 和 Sentinel 角色结合使用，则两个服务
# 都会启用。

# 以下服务将被禁用
sentinel['enable'] = false
bootstrap['enable'] = false
nginx['enable'] = false
postgresql['enable'] = false
gitlab_rails['enable'] = false
mailroom['enable'] = false

# 对于 Redis 副本角色，还需将此设置从默认的 'true' 更改为 'false'：
redis['master'] = false
```

你可以在 [`gitlab_rails.rb`](https://jihulab.com/gitlab-cn/omnibus-gitlab/blob/master/files/gitlab-cookbooks/gitlab/libraries/gitlab_rails.rb) 中找到相关的属性定义。

<a id="control-startup-behavior"></a>

### 控制启动行为

{{< history >}}

- 引入于极狐GitLab 15.10。

{{< /history >}}

要防止捆绑的 Redis 服务在启动时运行或在更改其配置后重新启动：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['start_down'] = true
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

如果你需要测试一个新的副本节点，可以将 `start_down` 设置为
`true` 并手动启动该节点。待新的副本节点在 Redis 集群中确认正常后，
将 `start_down` 设置为 `false` 并重新配置极狐GitLab，
以确保该节点在运行期间能如预期那样启动和重启。

<a id="control-replica-configuration"></a>

### 控制副本配置

{{< history >}}

- 引入于极狐GitLab 15.10。

{{< /history >}}

要防止在 Redis 配置文件中渲染 `replicaof` 行：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['set_replicaof'] = false
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

此设置可用于独立于其他 Redis 设置来阻止 Redis 节点的复制。

<a id="use-valkey-instead-of-redis"></a>

## 使用 Valkey 替代 Redis

{{< history >}}

- 在极狐GitLab 18.9 中作为 [beta](../../policy/development_stages_support.md#beta) 引入。
- 在极狐GitLab 19.0 中正式发布（GA）。

{{< /history >}}

你可以在复制和故障转移设置中使用 [Valkey](https://valkey.io/) 作为 Redis 的直接替代品。Valkey 使用与 Redis 相同的角色和配置选项。

<a id="configure-valkey-primary-and-replica-nodes"></a>

### 配置 Valkey 主节点和副本节点

在每个节点（主节点和副本节点）上，将以下内容添加到 `/etc/gitlab/gitlab.rb` 以从 Redis 切换至 Valkey：

```ruby
# 使用相同的 Redis 角色
roles ['redis_master_role']  # 或对副本节点使用 'redis_replica_role'

# 切换至 Valkey
redis['backend'] = 'valkey'

# 使用与 Redis 相同的配置选项
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

# 将 Redis 后端切换为 Valkey
# 然后 Sentinel 将使用相同的后端
redis['backend'] = 'valkey'

# Sentinel 配置（与 Redis 相同）
redis['master_name'] = 'gitlab-redis'
redis['master_password'] = 'redis-password-goes-here'
redis['master_ip'] = '10.0.0.1'
redis['port'] = 6379

sentinel['bind'] = '10.0.0.1'
sentinel['quorum'] = 2
```

所有其他 Sentinel 配置选项与 [配置 Redis Sentinel 实例](#step-3-configuring-the-redis-sentinel-instances) 中记录的保持相同。

<a id="known-issues"></a>

### 已知问题

- 由于已知 [议题 589642](https://gitlab.com/gitlab-org/gitlab/-/issues/589642)，管理区域错误地报告了 Valkey 版本。此问题
  不影响已安装的 Valkey 版本或其功能。

<a id="secure-redis-and-sentinel-with-tls"></a>

## 使用 TLS 保护 Redis 和 Sentinel

有关使用 TLS 保护 Redis 和 Sentinel 通信的全面信息，请参阅 [使用 TLS 保护 Redis 和 Sentinel](tls.md)。

<a id="troubleshooting"></a>

## 故障排查

参见 [Redis 故障排查指南](troubleshooting.md)。

<a id="further-reading"></a>

## 延伸阅读

了解更多：

1. [参考架构](../reference_architectures/_index.md)
1. [配置数据库](../postgresql/replication_and_failover.md)
1. [配置 NFS](../nfs.md)
1. [配置负载均衡器](../load_balancer.md)