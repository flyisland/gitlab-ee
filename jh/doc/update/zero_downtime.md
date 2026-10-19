---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 零停机升级多节点实例
description: 使用 Linux 软件包零停机升级多节点环境。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级多节点极狐GitLab 环境并实现零停机的过程，涉及按照[升级顺序](#upgrade-order)依次处理每个节点。负载均衡器和 HA 机制会相应地处理每个节点下线的情况。

在开始零停机升级之前，请[考虑您的停机选项](downtime_options.md)。

## 开始之前

对于任何分布式应用程序来说，在升级过程中实现零停机都相当困难。我们已经根据我们的 HA [参考架构](../administration/reference_architectures/_index.md)对文档进行了测试，结果表明实际上没有可观察到的停机时间。但请注意，您的实际结果可能会因特定的系统构成而异。

为了更加确信，一些客户通过使用特定的负载均衡器或基础设施功能（例如手动排空节点）等技术取得了成功。这些技术在很大程度上取决于底层基础设施的功能。

如需更多信息，请联系您的极狐GitLab 代表或[支持团队](https://about.gitlab.com/support/)。

### 要求

零停机升级过程要求使用 Linux 软件包构建的多节点极狐GitLab 环境，该环境需配置负载均衡和可用的 HA 机制，具体如下：

- 为极狐GitLab 应用节点配置外部负载均衡器，并针对[就绪](../administration/monitoring/health_check.md#readiness) (`/-/readiness`) 端点启用健康检查。
- 为所有 PgBouncer 和 Praefect 组件配置内部负载均衡器，并启用 TCP 健康检查。
- 为 Consul、Postgres 和 Redis 组件（如果存在）配置 HA 机制。
  - 任何未以 HA 方式部署的此类组件，必须单独进行升级，这期间会有停机时间。
  - 对于数据库，[Linux 软件包仅支持主极狐GitLab 数据库的 HA](https://gitlab.com/groups/gitlab-org/-/epics/7814)。对于任何其他数据库，例如 [Praefect 数据库](#upgrade-gitaly-cluster-praefect-nodes)，需要第三方数据库解决方案来实现 HA，从而避免停机。

对于零停机升级，您必须：

- **一次只升级一个小版本**。即从 `16.1` 升级到 `16.2`，而不是直接到 `16.3`。如果您跳过版本，数据库修改可能会以错误的顺序运行，[并导致数据库 schema 处于损坏状态](https://gitlab.com/gitlab-org/gitlab/-/issues/321542)。
- 使用部署后迁移。

### 注意事项

在考虑零停机升级时，请注意：

- 在大多数情况下，如果补丁版本不是最新的，您可以安全地从补丁版本升级到下一个次要版本。例如，即使 `16.3.3` 已发布，从 `16.3.2` 升级到 `16.4.1` 也应该是安全的。您应确认与您的[升级路径](upgrade_paths.md)相关的[特定于版本的升级注意事项](versions/_index.md)，并了解任何必需的升级停止点：
  - [极狐GitLab 18 升级注意事项](versions/gitlab_18_changes.md)
  - [极狐GitLab 17 升级注意事项](versions/gitlab_17_changes.md)
  - [极狐GitLab 16 升级注意事项](versions/gitlab_16_changes.md)
  - [极狐GitLab 15 升级注意事项](versions/gitlab_15_changes.md)
- 某些版本可能包含后台迁移。这些迁移由 Sidekiq 在后台执行，通常用于数据迁移。后台迁移只会在月度发布中添加。
  - 某些主要或次要版本可能要求完成一组后台迁移。虽然这不需要停机（如果满足前述条件），但您必须在每次主要或次要版本升级之间等待后台迁移完成。
  - 可以通过增加能够处理 `background_migration` 队列中作业的 Sidekiq 工作进程数量，来缩短完成这些迁移所需的时间。要查看此队列的大小，请[在升级前检查后台迁移](background_migrations.md)。
- 由于存在优雅重载机制，因此可以对 [Gitaly](#upgrade-gitaly-nodes) 执行零停机升级。[Gitaly Cluster (Praefect)](#upgrade-gitaly-cluster-praefect-nodes) 组件也可以直接升级而无需停机。但是，Linux 软件包不为 Praefect 数据库提供 HA 或零停机支持。需要第三方数据库解决方案来避免停机。
- [PostgreSQL 主要版本升级](../administration/postgresql/replication_and_failover.md#near-zero-downtime-upgrade-of-postgresql-in-a-patroni-cluster)是一个单独的过程，不在零停机升级的覆盖范围内。更小规模的升级则在此范围内。
- 零停机升级支持您使用 Linux 软件包部署的上述极狐GitLab 组件。如果您通过受支持的第三方服务（例如 AWS RDS 上的 PostgreSQL 或 GCP Memorystore 上的 Redis）部署了特定组件，这些服务的升级必须分别按照其标准流程单独执行。
- 作为一般准则，您拥有的数据量越大，升级完成所需的时间就越长。在测试中，任何小于 10 GB 的数据库通常不会花费超过一小时的时间，但您的实际结果可能有所不同。

### 升级顺序

对于零停机升级组件的顺序，您应该采用从后到前的方法：

1. 有状态后端
1. 后端依赖项
1. 前端

尽管您可以更改部署顺序，但应将运行极狐GitLab 应用程序代码的组件（例如 Rails 和 Sidekiq）一起部署。如果可能，请分别升级支持性基础设施，因为这些组件不依赖于主要版本升级中引入的变更。

您应按以下顺序升级极狐GitLab 组件：

1. Consul
1. PostgreSQL
1. PgBouncer
1. Redis
1. Gitaly
1. Praefect
1. Rails
1. Sidekiq

## 升级 Consul、PostgreSQL、PgBouncer 和 Redis 节点

[Consul](../administration/consul.md)、[PostgreSQL](../administration/postgresql/replication_and_failover.md)、[PgBouncer](../administration/postgresql/pgbouncer.md) 和 [Redis](../administration/redis/replication_and_failover.md) 组件都遵循相同的底层流程以实现在不中断的情况下进行升级。

在要执行升级的每个组件节点上：

1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)节点。
1. 重新配置并重新启动以使最新代码生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

   {{< tabs >}}

   {{< tab title="仅限 PostgreSQL 节点" >}}

   首先重新启动 Consul 客户端，然后重新启动所有其他服务，以确保 PostgreSQL 故障转移顺利进行：

   ```shell
   sudo gitlab-ctl restart consul
   sudo gitlab-ctl restart-except consul
   ```

   {{< /tab >}}

   {{< tab title="对于所有其他组件节点" >}}

   ```shell
   sudo gitlab-ctl restart
   ```

   {{< /tab >}}

   {{< /tabs >}}

## 升级 Gitaly 节点

[Gitaly](../administration/gitaly/_index.md) 在升级方面遵循相同的核心流程，但有一个关键区别：Gitaly 进程本身不会重新启动，因为它具有内置机制，可以在最早的机会优雅地重载。其他组件则必须重新启动。

此流程适用于 Gitaly 分片和集群设置。在每个 Gitaly 节点上按顺序执行以下步骤以进行升级：

1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)节点。
1. 运行 `reconfigure` 命令以使最新代码生效，并指示 Gitaly 在下一个机会优雅地重载：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 最后，当 Gitaly 优雅地重载时，任何已部署的其他组件仍然需要重新启动：

   ```shell
   # 获取除 Gitaly 之外已部署了哪些其他组件的列表
   sudo gitlab-ctl status

   # 重新启动除 Gitaly 之外的每个组件。以 Consul、Node Exporter 和 Logrotate 为例
   sudo gitlab-ctl restart consul node-exporter logrotate
   ```

### 升级 Gitaly Cluster (Praefect) 节点

> [!note]
> 本节仅关注 Praefect 组件，而非其[必需的 PostgreSQL 数据库](../administration/gitaly/praefect/configure.md#postgresql)。
> [极狐GitLab Linux 软件包不提供 HA](https://gitlab.com/groups/gitlab-org/-/epics/7814) 以及随后对 Praefect 数据库的零停机支持。
> 需要第三方数据库解决方案来避免停机。

对于 Gitaly Cluster (Praefect) 设置，您必须使用优雅重载以类似的方式部署和升级 Praefect。

> [!note]
> 升级过程会尝试优雅地移交到新的 Praefect 进程。
> 在升级开始前已启动的现有长时间 Git 请求，可能会在此移交过程中最终被丢弃。
> 未来此功能可能会改变，[请参考该史诗以获取更多信息](https://gitlab.com/groups/gitlab-org/-/epics/10328)。

Praefect 还必须执行数据库迁移以升级任何现有数据。为避免冲突，迁移应仅在一个 Praefect 节点上运行。为此，请指定一个 **Praefect 部署节点**来运行迁移：

1. 在 **Praefect 部署节点**上：

   1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

      ```shell
      sudo touch /etc/gitlab/skip-auto-reconfigure
      ```

   1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)节点。
   1. 确保在 `/etc/gitlab/gitlab.rb` 中设置了 `praefect['auto_migrate'] = true`，以便运行数据库迁移。
   1. 运行 `reconfigure` 命令以使最新代码生效，应用 Praefect 数据库迁移并优雅地重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

1. 在所有**剩余的 Praefect 节点**上：

   1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

      ```shell
      sudo touch /etc/gitlab/skip-auto-reconfigure
      ```

   1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)节点。
   1. 确保在 `/etc/gitlab/gitlab.rb` 中设置了 `praefect['auto_migrate'] = false`，以防止 `reconfigure` 自动运行数据库迁移。
   1. 运行 `reconfigure` 命令以使最新代码生效并优雅地重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

1. 最后，当 Praefect 优雅地重新加载时，任何已部署的其他组件仍然需要重新启动。
   在所有 **Praefect 节点**上：

   ```shell
   # 获取除 Praefect 之外已部署了哪些其他组件的列表
   sudo gitlab-ctl status

   # 重新启动除 Praefect 之外的每个组件。以 Consul、Node Exporter 和 Logrotate 为例
   sudo gitlab-ctl restart consul node-exporter logrotate
   ```

## 升级极狐GitLab 应用 (Rails) 节点

作为 Web 服务器的 Rails 主要由 [Puma](../administration/operations/puma.md)、Workhorse 和 NGINX 组成。

这些组件中的每一个在进行实时升级时都有不同的行为。虽然 Puma 可以允许优雅重载，但 Workhorse 不行。最佳方法是通过其他方式（例如使用负载均衡器）优雅地排空节点。您也可以使用节点上的 NGINX，通过其优雅关闭功能来实现。本节介绍 NGINX 方法。

除此之外，Rails 还需要执行主要的数据库迁移。与 Praefect 一样，最佳方法是使用部署节点。如果当前正在使用 PgBouncer，也需要绕过它，因为 Rails 在尝试运行迁移以阻止并发迁移在同一数据库上运行时，会使用 advisory lock。这些锁不跨事务共享，在事务池模式下使用 PgBouncer 运行数据库迁移时，会导致 `ActiveRecord::ConcurrentMigrationError` 和其他问题。

1. 在 **Rails 部署节点**上：

   1. 优雅地排空节点流量。您可以通过多种方式做到这一点，但一种方法是使用 NGINX，向它发送一个 `QUIT` 信号，然后停止服务。
      例如，您可以使用以下 shell 脚本来执行此操作：

      ```shell
      # 向 NGINX 主进程发送 QUIT 信号以使其排空并退出
      NGINX_PID=$(cat /var/opt/gitlab/nginx/nginx.pid)
      kill -QUIT $NGINX_PID

      # 等待排空完成
      while kill -0 $NGINX_PID 2>/dev/null; do sleep 1; done

      # 停止 NGINX 服务以防止自动重新启动
      gitlab-ctl stop nginx
      ```

   1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

      ```shell
      sudo touch /etc/gitlab/skip-auto-reconfigure
      ```

   1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)极狐GitLab。
   1. 通过在 `/etc/gitlab/gitlab.rb` 配置文件中设置 `gitlab_rails['auto_migrate'] = true` 来配置常规迁移的运行。
      - 如果部署节点通过 PgBouncer 连接到数据库，您必须[绕过它](../administration/postgresql/pgbouncer.md#procedure-for-bypassing-pgbouncer)并直接连接到数据库主节点，然后再运行迁移。
      - 要查找数据库主节点，您可以在任何数据库节点上运行以下命令 - `sudo gitlab-ctl patroni members`。

   1. 运行常规迁移并使最新代码生效：

      ```shell
      sudo SKIP_POST_DEPLOYMENT_MIGRATIONS=true gitlab-ctl reconfigure
      ```

   1. 现在先保持此节点不变，稍后您将返回来运行部署后迁移。

1. 依次在每个**其他 Rails 节点**上：

   1. 优雅地排空节点流量。您可以通过多种方式做到这一点，但一种方法是使用 NGINX，向它发送一个 `QUIT` 信号，然后停止服务。
      例如，您可以使用以下 shell 脚本来执行此操作：

      ```shell
      # 向 NGINX 主进程发送 QUIT 信号以使其排空并退出
      NGINX_PID=$(cat /var/opt/gitlab/nginx/nginx.pid)
      kill -QUIT $NGINX_PID

      # 等待排空完成
      while kill -0 $NGINX_PID 2>/dev/null; do sleep 1; done

      # 停止 NGINX 服务以防止自动重新启动
      gitlab-ctl stop nginx
      ```

   1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

      ```shell
      sudo touch /etc/gitlab/skip-auto-reconfigure
      ```

   1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)极狐GitLab。
   1. 确保在 `/etc/gitlab/gitlab.rb` 中设置了 `gitlab_rails['auto_migrate'] = false`，以防止 `reconfigure` 自动运行数据库迁移。
   1. 运行 `reconfigure` 命令以使最新代码生效并重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      sudo gitlab-ctl restart
      ```

1. 在 **Rails 部署节点**上运行部署后迁移：

   1. 确保部署节点仍然直接指向数据库主节点。如果该节点通过 PgBouncer 连接到数据库，您必须[绕过它](../administration/postgresql/pgbouncer.md#procedure-for-bypassing-pgbouncer)并直接连接到数据库主节点，然后再运行迁移。
      - 要查找数据库主节点，您可以在任何数据库节点上运行以下命令 - `sudo gitlab-ctl patroni members`。

   1. 运行部署后迁移：

      ```shell
      sudo gitlab-rake gitlab:db:configure
      ```

      此任务还会运行 ClickHouse 迁移，并通过加载 schema 根据数据库状态配置数据库。

   1. 通过在 `/etc/gitlab/gitlab.rb` 配置文件中设置 `gitlab_rails['auto_migrate'] = false`，将配置恢复正常。
      - 如果正在使用 PgBouncer，请确保将数据库配置重新指向它。

   1. 再次运行 reconfigure 以重新应用正常配置并重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      sudo gitlab-ctl restart
      ```

## 升级 Sidekiq 节点

[Sidekiq](../administration/sidekiq/_index.md) 在升级时遵循与其他节点相同的底层流程，以实现无停机升级。

在每个组件节点上顺序执行以下步骤以进行升级：

1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

   ```shell
   sudo touch /etc/gitlab/skip-auto-reconfigure
   ```

1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)节点。
1. 运行 `reconfigure` 命令以使最新代码生效并重新启动：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```

## 升级多节点 Geo 实例

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本节介绍了升级包含 Geo 的实时极狐GitLab 环境部署所需的步骤。

总体而言，该方法与正常流程大致相同，但需要为每个辅助站点执行一些额外步骤。必需的顺序是先升级主站点，然后升级辅助站点。您还必须在所有辅助站点都更新后，在主站点上运行任何部署后迁移。

> [!note]
> 升级包含 Geo 的实时极狐GitLab 环境时，同样适用[要求](#requirements)和[注意事项](#considerations)。

### 主站点

主站点的升级过程与正常过程相同，但有一个例外：在所有辅助站点都更新之前，不要运行部署后迁移。

按照所述为主站点执行相同的步骤，但在运行部署后迁移的 Rails 节点步骤处停止。

### 辅助站点

任何辅助站点的升级过程，除了 Rails 节点外，都遵循与正常过程相同的步骤。
主站点和辅助站点的升级过程相同。但是，您必须对辅助站点上的 Rails 节点执行以下附加步骤。

#### Rails

1. 在 **Rails 部署节点**上：

   1. 优雅地排空节点流量。您可以通过多种方式做到这一点，但一种方法是使用 NGINX，向它发送一个 `QUIT` 信号，然后停止服务。
      例如，您可以使用以下 shell 脚本来执行此操作：

      ```shell
      # 向 NGINX 主进程发送 QUIT 信号以使其排空并退出
      NGINX_PID=$(cat /var/opt/gitlab/nginx/nginx.pid)
      kill -QUIT $NGINX_PID

      # 等待排空完成
      while kill -0 $NGINX_PID 2>/dev/null; do sleep 1; done

      # 停止 NGINX 服务以防止自动重新启动
      gitlab-ctl stop nginx
      ```

   1. 停止 Geo Log Cursor 进程以确保它故障转移到另一个节点：

      ```shell
      gitlab-ctl stop geo-logcursor
      ```

   1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

      ```shell
      sudo touch /etc/gitlab/skip-auto-reconfigure
      ```

   1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)极狐GitLab。
   1. 如果主站点 Rails 节点和辅助站点 Rails 节点上的 `/etc/gitlab/gitlab-secrets.json` 文件不同，请将该文件从主站点 Rails 节点复制到辅助站点 Rails 节点。该文件在站点中的所有节点上必须相同。
   1. 通过在 `/etc/gitlab/gitlab.rb` 配置文件中设置 `gitlab_rails['auto_migrate'] = false` 和 `geo_secondary['auto_migrate'] = false`，确保没有配置为自动运行的迁移。
   1. 运行 `reconfigure` 命令以使最新代码生效并重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      sudo gitlab-ctl restart
      ```

   1. 运行常规 Geo Tracking 迁移并使最新代码生效：

      ```shell
      sudo SKIP_POST_DEPLOYMENT_MIGRATIONS=true gitlab-rake db:migrate:geo
      ```

1. 依次在每个**其他 Rails 节点**上：

   1. 优雅地排空节点流量。您可以通过多种方式做到这一点，但一种方法是使用 NGINX，向它发送一个 `QUIT` 信号，然后停止服务。
      例如，您可以使用以下 shell 脚本来执行此操作：

      ```shell
      # 向 NGINX 主进程发送 QUIT 信号以使其排空并退出
      NGINX_PID=$(cat /var/opt/gitlab/nginx/nginx.pid)
      kill -QUIT $NGINX_PID

      # 等待排空完成
      while kill -0 $NGINX_PID 2>/dev/null; do sleep 1; done

      # 停止 NGINX 服务以防止自动重新启动
      gitlab-ctl stop nginx
      ```

   1. 停止 Geo Log Cursor 进程以确保它故障转移到另一个节点：

      ```shell
      gitlab-ctl stop geo-logcursor
      ```

   1. 在 `/etc/gitlab/skip-auto-reconfigure` 处创建一个空文件。这可以防止升级运行 `gitlab-ctl reconfigure`，该命令默认会自动停止极狐GitLab、运行所有数据库迁移并重新启动极狐GitLab：

      ```shell
      sudo touch /etc/gitlab/skip-auto-reconfigure
      ```

   1. 使用[Linux 软件包升级](package/_index.md#upgrade-with-the-linux-package)极狐GitLab。
   1. 通过在 `/etc/gitlab/gitlab.rb` 配置文件中设置 `gitlab_rails['auto_migrate'] = false` 和 `geo_secondary['auto_migrate'] = false`，确保没有配置为自动运行的迁移。
   1. 运行 `reconfigure` 命令以使最新代码生效并重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      sudo gitlab-ctl restart
      ```

#### Sidekiq

完成主要流程后，现在剩下的就是升级 Sidekiq。

按照[主章节中描述的相同方式](#升级-sidekiq-节点)升级 Sidekiq。

### 部署后迁移

最后，返回主站点并通过运行部署后迁移来完成升级：

1. 在主站点的 **Rails 部署节点**上运行部署后迁移：

   1. 确保部署节点仍然直接指向数据库主节点。如果该节点通过 PgBouncer 连接到数据库，您必须[绕过它](../administration/postgresql/pgbouncer.md#procedure-for-bypassing-pgbouncer)并直接连接到数据库主节点，然后再运行迁移。
      - 要查找数据库主节点，您可以在任何数据库节点上运行以下命令 - `sudo gitlab-ctl patroni members`。

   1. 运行部署后迁移：

      ```shell
      sudo gitlab-rake gitlab:db:configure
      ```

   1. 验证 Geo 配置和依赖项：

      ```shell
      sudo gitlab-rake gitlab:geo:check
      ```

   1. 通过在 `/etc/gitlab/gitlab.rb` 配置文件中设置 `gitlab_rails['auto_migrate'] = false`，将配置恢复正常。
      - 如果正在使用 PgBouncer，请确保将数据库配置重新指向它。

   1. 再次运行 reconfigure 以重新应用正常配置并重新启动：

      ```shell
      sudo gitlab-ctl reconfigure
      sudo gitlab-ctl restart
      ```

   1. 在所有**辅助站点**上运行**极狐GitLab 应用程序节点**步骤，从[常规 Rails 步骤](#rails-1)开始，但跳过 `db:migrate:geo` 步骤。
1. 再次运行 reconfigure 以重新应用常规配置并重启：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```

1. 在次要站点的 **Rails 部署节点** 上运行部署后 Geo 跟踪迁移：

   1. 运行部署后 Geo 跟踪迁移：

      ```shell
      sudo gitlab-rake db:migrate:geo
      ```

   1. 验证 Geo 状态：

      ```shell
      sudo gitlab-rake geo:status
      ```