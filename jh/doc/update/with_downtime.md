---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用停机方式升级多节点实例
description: Upgrade a multi-node Linux package-based or cloud-native instance with downtime.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要使用停机方式升级多节点极狐GitLab 实例：

1. 关闭极狐GitLab 应用。
1. 升级 Consul 服务器。
1. 以任意顺序升级 Gitaly、Rails、PostgreSQL、Redis 和 PgBouncer。如果您使用云平台提供的 PostgreSQL 或 Redis 且需要升级，请使用云服务商的说明替代以下步骤。
1. 升级极狐GitLab 应用（Sidekiq、Puma）并启动应用。

在开始停机升级之前，请[考虑您的停机选项](downtime_options.md)。

<a id="shut-down-the-gitlab-application"></a>

## 关闭极狐GitLab 应用

升级前，必须通过关闭极狐GitLab 应用来停止对数据库的写入。具体步骤取决于您的[安装方式](../administration/reference_architectures/_index.md)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

在所有运行 Puma 和 Sidekiq 的服务器上关闭这些进程：

```shell
sudo gitlab-ctl stop sidekiq
sudo gitlab-ctl stop puma
```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

对于 [Helm Chart](../administration/reference_architectures/_index.md#cloud-native-hybrid) 实例：

1. 记录数据库客户端的当前副本数，以便后续重启：

```shell
kubectl get deploy -n <namespace> -l release=<helm release name> -l 'app in (prometheus,webservice,sidekiq)' -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.replicas}{"\n"}{end}'
```

1. 停止数据库客户端：

```shell
kubectl scale deploy -n <namespace> -l release=<helm release name> -l 'app in (prometheus,webservice,sidekiq)' --replicas=0
```

{{< /tab >}}

{{< /tabs >}}

<a id="upgrade-the-consul-nodes"></a>

## 升级 Consul 节点

按照[升级 Consul 节点](../administration/consul.md#upgrade-the-consul-nodes)的说明操作。概括如下：

1. 检查所有 Consul 节点是否健康。
1. 通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级所有 Consul 服务器。
1. **一次一个节点地**重启所有极狐GitLab 服务：

   ```shell
   sudo gitlab-ctl restart
   ```

您的 Consul 集群进程可能并不在独立的服务器上，而是与 Redis HA 或 Patroni 等其他服务共享。在这种情况下，升级这些服务器时：

- 一次只在一台服务器上重启服务。
- 在升级或重启服务前，确保 Consul 集群健康。

<a id="upgrade-gitaly-and-gitaly-cluster-praefect"></a>

## 升级 Gitaly 和 Gitaly 集群（Praefect）

对于不属于 Gitaly 集群（Praefect）的 Gitaly 服务器，通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级服务器。如果您有多个 Gitaly 分片，可以按任意顺序升级 Gitaly 服务器。

如果您正在运行 Gitaly 集群（Praefect），请遵循[Gitaly 集群（Praefect）的零停机升级流程](zero_downtime.md#upgrade-gitaly-cluster-praefect-nodes)。

<a id="when-using-amazon-machine-images"></a>

### 使用 Amazon Machine Images 时

如果您在 AWS 上使用 Amazon Machine Images (AMI)，可以通过 AMI 重新部署流程来升级 Gitaly 节点。要使用此流程，您必须使用[弹性网络接口 (ENI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)。Gitaly 集群（Praefect）通过服务器主机名跟踪 Git 仓库的副本。ENI 可以确保实例重新部署时私有 DNS 名称保持不变。如果节点以新的主机名重新部署，即使存储相同，Gitaly 集群（Praefect）也无法正常工作。

如果您未使用 ENI，则必须使用 Linux 软件包升级 Gitaly 节点。

要通过 AMI 重新部署流程升级 Gitaly 集群（Praefect）节点：

1. AMI 重新部署流程必须包含 `gitlab-ctl reconfigure`。在 AMI 上设置 `praefect['auto_migrate'] = false`，以便所有节点都获得此设置。此设置可防止 `reconfigure` 自动运行数据库迁移。
1. 第一个使用升级镜像重新部署的节点应是您的部署节点。
1. 部署后，在 `gitlab.rb` 中设置 `praefect['auto_migrate'] = true`，并执行 `gitlab-ctl reconfigure` 应用更改。
1. 此命令会运行数据库迁移。
1. 重新部署其他 Gitaly 集群（Praefect）节点。

<a id="upgrade-the-postgresql-nodes"></a>

## 升级 PostgreSQL 节点

对于非集群化的 PostgreSQL 服务器：

1. 通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级服务器。
1. 由于升级过程在二进制文件升级后不会重启 PostgreSQL，因此需要重启以加载新版本：

   ```shell
   sudo gitlab-ctl restart
   ```

<a id="upgrade-patroni-nodes"></a>

### 升级 Patroni 节点

Patroni 用于实现 PostgreSQL 的高可用性。

如果需要升级 PostgreSQL 主版本，请[遵循主版本升级流程](../administration/postgresql/replication_and_failover.md#upgrading-postgresql-major-version-in-a-patroni-cluster)。

所有其他版本的升级流程均先在所有副本上执行。副本升级完成后，集群会从主节点故障转移到其中一个已升级的副本。此流程确保仅需一次故障转移，且完成后新的主节点也已升级。

要升级 Patroni 节点：

1. 识别主节点和副本节点，并[验证集群是否健康](../administration/postgresql/replication_and_failover.md#check-replication-status)。在数据库节点上运行：

   ```shell
   sudo gitlab-ctl patroni members
   ```

1. 通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级一个副本节点。
1. 重启以加载新版本：

   ```shell
   sudo gitlab-ctl restart
   ```

1. [验证集群是否健康](../administration/postgresql/replication_and_failover.md#check-replication-status)。
1. 对其他副本重复升级、重启和健康检查步骤。
1. 按照与副本相同的 Linux 软件包升级方式升级主节点。
1. 在主节点上重启所有服务以加载新版本，并触发集群故障转移：

   ```shell
   sudo gitlab-ctl restart
   ```

1. [检查集群是否健康](../administration/postgresql/replication_and_failover.md#check-replication-status)

<a id="upgrade-the-pgbouncer-nodes"></a>

## 升级 PgBouncer 节点

如果您在极狐GitLab 应用（Rails）节点上运行 PgBouncer，则 PgBouncer 会作为应用服务器升级的一部分进行升级。否则，请通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级 PgBouncer 节点。

<a id="upgrade-the-redis-node"></a>

## 升级 Redis 节点

要升级独立的 Redis 服务器，请[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)。

<a id="upgrade-redis-ha-using-sentinel"></a>

### 升级 Redis HA（使用 Sentinel）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您使用 Redis HA，请遵循[零停机升级说明](zero_downtime.md)来升级 Redis HA 集群。

<a id="upgrade-the-gitlab-application-components"></a>

## 升级极狐GitLab 应用组件

升级极狐GitLab 应用的流程取决于您的安装方式。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

所有 Puma 和 Sidekiq 进程之前已关闭。在每个极狐GitLab 应用节点上：

1. 确保 `/etc/gitlab/skip-auto-reconfigure` 文件不存在。
1. 检查 Puma 和 Sidekiq 是否已关闭：

   ```shell
   ps -ef | egrep 'puma: | puma | sidekiq '
   ```

选择一个运行 Puma 的节点作为部署节点，负责运行所有数据库迁移。在部署节点上：

1. 确保服务器配置允许常规迁移。检查 `/etc/gitlab/gitlab.rb` 中不包含 `gitlab_rails['auto_migrate'] = false`。可以显式设置为 `gitlab_rails['auto_migrate'] = true`，或省略该设置以使用默认行为（`true`）。
1. 如果您使用 PgBouncer，则必须在运行迁移前绕过 PgBouncer 并直接连接到 PostgreSQL。

   Rails 在尝试运行迁移时会使用咨询锁，以防止并发迁移在同一数据库上运行。这些锁不会跨事务共享，因此在事务池模式下使用 PgBouncer 运行数据库迁移时，会导致 `ActiveRecord::ConcurrentMigrationError` 错误和其他问题。

   1. 如果您正在运行 Patroni，请找到主节点。在数据库节点上运行：

      ```shell
      sudo gitlab-ctl patroni members
      ```

   1. 更新部署节点上的 `gitlab.rb`。将 `gitlab_rails['db_host']` 和 `gitlab_rails['db_port']` 更改为以下之一：

      - 数据库服务器的主机和端口（非集群化 PostgreSQL）。
      - 如果运行 Patroni，则为集群主节点的主机和端口。

   1. 应用更改：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

1. 通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级极狐GitLab。
1. 如果您修改了部署节点上的 `gitlab.rb` 以绕过 PgBouncer：
   1. 更新部署节点上的 `gitlab.rb`。将 `gitlab_rails['db_host']` 和 `gitlab_rails['db_port']` 改回您的 PgBouncer 设置。
   1. 应用更改：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

1. 为确保所有服务运行升级后的版本，并且（如果适用）通过 PgBouncer 访问数据库，请重启部署节点上的所有服务：

   ```shell
   sudo gitlab-ctl restart
   ```

接下来，升级所有其他 Puma 和 Sidekiq 节点。这些节点的 `gitlab.rb` 中 `gitlab_rails['auto_migrate']` 可以设置为任意值。

它们可以并行升级：

1. 通过[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)来升级极狐GitLab。
1. 确保所有服务已重启：

   ```shell
   sudo gitlab-ctl restart
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

在所有有状态组件升级完成后，按照[极狐GitLab Chart 升级步骤](https://gitlab.cn/docs/charts/installation/upgrade/)升级无状态组件（Webservice、Sidekiq 及其他支持服务）。

执行极狐GitLab Chart 升级后，恢复数据库客户端：

```shell
kubectl scale deploy -lapp=sidekiq,release=<helm release name> -n <namespace> --replicas=<value>
kubectl scale deploy -lapp=webservice,release=<helm release name> -n <namespace> --replicas=<value>
kubectl scale deploy -lapp=prometheus,release=<helm release name> -n <namespace> --replicas=<value>
```

{{< /tab >}}

{{< /tabs >}}

<a id="upgrade-the-monitor-node"></a>

## 升级监控节点

您可能已将 Prometheus 配置为独立的监控节点。例如，作为[配置 60 RPS 或 3,000 用户参考架构](../administration/reference_architectures/3k_users.md#configure-prometheus)的一部分。

要升级监控节点，请[使用 Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)。