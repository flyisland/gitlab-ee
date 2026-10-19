---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 灾难恢复（Geo）
description: 使用 Geo 实例从灾难中恢复。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 会复制您的数据库、Git 代码仓库和其他资产。存在一些[已知问题](../_index.md#known-issues)。

> [!warning]
>
> - 多从站点配置需要完全重新同步并重新配置所有未提升的从站点，并且会导致停机。
> - 从站点提升后，主站点会完全脱离。如果您希望恢复主站点，必须将其添加为新的从站点。

<a id="secondary-sites-with-selective-synchronization-enabled"></a>

## 启用了选择性同步的从站点

提升启用了选择性同步的从站点会导致未复制到该从站点的所有数据永久丢失。有关更多信息，请参阅[提升启用了选择性同步的从站点](../replication/selective_synchronization.md#promoting-a-secondary-site-with-selective-synchronization-enabled)。

<a id="the-gitlab-clusterjson-file"></a>

## `gitlab-cluster.json` 文件

当您使用 `gitlab-ctl geo promote` 将从站点提升为主站点时，该命令会在其执行的每个节点上自动创建一个 `/etc/gitlab/gitlab-cluster.json` 文件。在大多数情况下，您无需手动编辑此文件。

`gitlab-cluster.json` 文件使提升命令能够自动完成配置更改，而无需直接修改 `/etc/gitlab/gitlab.rb`。以编程方式编辑 `gitlab.rb` 容易出错，因此 `gitlab-cluster.json` 充当由机器管理的覆盖层。

当两个文件都存在时，在 `gitlab-ctl reconfigure` 执行时，`gitlab-cluster.json`中的值优先于 `gitlab.rb`中的对应值。当您运行此命令时，您会看到类似以下的警告：

```plaintext
The 'geo_primary_role' is defined in /etc/gitlab/gitlab-cluster.json as 'true' and overrides the setting in the /etc/gitlab/gitlab.rb
The 'geo_secondary_role' is defined in /etc/gitlab/gitlab-cluster.json as 'false' and overrides the setting in the /etc/gitlab/gitlab.rb
```

此警告在提升后是预期行为。

<a id="file-structure"></a>

### 文件结构

典型的 `gitlab-cluster.json` 文件如下所示：

```json
{
  "primary": true,
  "secondary": false,
  "geo_secondary": {
    "enable": false
  }
}
```

| 键 | 描述 |
|---|---|
| `primary` | 当为 `true` 时，启用 `geo_primary_role`，从而将该节点配置为 Geo 主节点。 |
| `secondary` | 当为 `true` 时，启用 `geo_secondary_role`，从而将该节点配置为 Geo 从节点。 |
| `geo_secondary` | 包含与 Geo 从节点配置相关的设置，例如跟踪数据库。`"enable": false` 会禁用从节点专属服务。 |

`primary` 和 `secondary` 键分别映射到 `geo_primary_role` 和 `geo_secondary_role`。这些角色为单节点设置提供了便利，但不应用于在 `gitlab.rb`中显式配置各个服务角色的多节点配置。

<a id="remove-the-file"></a>

### 删除该文件

成功提升后，您可以保留 `gitlab-cluster.json`。但是，在以下情况下您应将其删除：

- 如果您[将已降级的主站点恢复](bring_primary_back.md#configure-the-former-primary-site-to-be-a-secondary-site)
  为新的从站点，则必须从每个
  Sidekiq、PostgreSQL、Gitaly 和 Rails 节点删除 `gitlab-cluster.json`。
- 在您更新 `gitlab.rb` 以设置 Geo 角色（例如 `roles(['geo_primary_role'])`）之后，并且您希望
  `gitlab.rb` 成为唯一的配置来源。
- 在您从部分故障转移中恢复之后。

  有关恢复期间手动创建该文件的详细信息，请参阅[从部分故障转移中恢复](failover_troubleshooting.md#recovering-from-a-partial-failover)。

要删除该文件：

- 运行以下命令：

  ```shell
  sudo rm /etc/gitlab/gitlab-cluster.json
  sudo gitlab-ctl reconfigure
  ```

  在多节点设置中，请在该站点的每个节点上重复这些命令。

有关 `gitlab-cluster.json` 如何与重新配置过程交互的技术细节，请参阅
[Omnibus 重新配置文档](https://gitlab.cn/docs/omnibus/development/reconfigure_in_detail/#gitlab-clusterjson-file)。

<a id="promoting-a-secondary-geo-site-in-single-secondary-configurations"></a>

## 在单从站点配置中提升从 Geo 站点

虽然您无法自动提升 Geo 副本并执行故障转移，但如果您拥有该机器的 `root` 访问权限，则可以手动提升它。

此过程将从 Geo 站点提升为主站点。为了尽快恢复地理冗余，您应在遵循这些说明后立即添加一个新的从站点。

<a id="allow-replication-to-finish-if-possible"></a>

### 尽可能允许复制完成

如果从站点仍在从主站点复制数据，请尽可能严格地遵循[计划内故障转移文档](planned_failover.md)，以避免不必要的数据丢失。

<a id="step-1-permanently-disable-the-primary-site"></a>

### 步骤 1. 永久禁用主站点

> [!warning]
> 如果主站点离线，主站点上可能保存有
> 尚未复制到从站点的数据。如果您继续操作，这些数据应被视为
> 已丢失。

如果主站点发生故障，您应尽一切可能避免脑裂情况，即写入可能发生在两个不同的极狐GitLab 实例中，从而使恢复工作复杂化。因此，为故障转移做准备，我们必须禁用主站点。

- 如果您有 SSH 访问权限：

  1. SSH 登录主站点以停止并禁用极狐GitLab：

     ```shell
     sudo gitlab-ctl stop
     ```

  1. 防止极狐GitLab 在服务器意外重启时再次启动：

     ```shell
     sudo systemctl disable gitlab-runsvdir
     ```

- 如果您没有主站点的 SSH 访问权限，请将机器离线，并
  通过您可用的任何方式防止其重启。
  您可能需要：

  - 重新配置负载均衡器。
  - 更改 DNS 记录（例如，将主 DNS 记录指向
    从站点，以停止使用主站点）。
  - 停止虚拟服务器。
  - 通过防火墙阻止流量。
  - 撤销主站点的对象存储权限。
  - 物理断开机器。

  如果您计划[更新主域 DNS 记录](#optional-updating-the-primary-domain-dns-record)，
  您可能希望保持较低的 TTL，以确保 DNS 更改快速传播。

  > [!note]
  > 主站点的 `/etc/gitlab/gitlab.rb` 文件在此过程中不会自动复制到从站点。请确保备份主站点的 `/etc/gitlab/gitlab.rb` 文件，以便稍后可以在从站点上恢复任何所需的值。

<a id="step-2-promoting-a-secondary-site"></a>

### 步骤 2. 提升从站点

提升从站点时请注意以下事项：

- 如果从站点[已暂停](../replication/pause_resume_replication.md)，提升
  会执行时间点恢复至最后已知状态。
  在从站点暂停期间在主站点上创建的数据将丢失。
- 如果从站点[已暂停](../replication/pause_resume_replication.md)，并且您在此过程中遇到 `ActiveRecord::StatementInvalid: PG::ReadOnlySqlTransaction: ERROR:  cannot execute DELETE in a read-only transaction` 错误消息，请参阅此知识库文章：[Geo 提升失败，出现只读事务错误或主站点意外关闭后超时](https://gitlab.cn/support)。
- 此时不应添加新的从站点。如果您想添加新的
  从站点，请在完成将从站点提升
  为主站点的整个过程后再进行。
- 如果您在此过程中遇到 `ActiveRecord::RecordInvalid: Validation failed: Name has already been taken`
  错误消息，有关更多信息，请参阅此
  [故障排除建议](failover_troubleshooting.md#fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site)。
- 如果您使用单独的 URL，应将[主域 DNS 指向新提升的站点](#optional-updating-the-primary-domain-dns-record)。否则，Runner 必须向新提升的站点重新注册，并且所有 Git 远程、书签和外部集成都必须更新。
- 如果您使用[位置感知 DNS](../secondary_proxy/_index.md#configure-location-aware-dns)，在旧主站点从 DNS 条目中移除后，Runner 应自动连接到新的主站点。
- 主站点关闭后，在从站点上运行 `gitlab-ctl promotion-preflight-checks`，以检查 Geo 同步状态并执行最终验证检查。
- 如果您不期望连接到先前主站点的 Runner 恢复，则应将其移除：
  - 通过 UI：
    1. 在右上角，选择**管理员**。
    1. 选择 **CI/CD** > **Runner** 并将其移除。
  - 使用 [Runner API](../../../api/runners.md)。

<a id="promoting-a-secondary-site-running-on-a-single-node"></a>

#### 提升在单节点上运行的从站点

1. SSH 登录您的从站点并执行：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您可以使用先前用于从站点的 URL 连接到新提升的主站点。
1. 如果成功，从站点现已提升为主站点。

当您运行 `gitlab-ctl geo promote` 时，会在该节点上创建一个 [`gitlab-cluster.json`](#the-gitlab-clusterjson-file) 文件。当您重新配置时，该文件会覆盖 `gitlab.rb`中的 Geo 角色设置。

<a id="step-3-removing-the-former-secondarys-tracking-database"></a>

### 步骤 3. 移除原从站点的跟踪数据库

如果您在 `/etc/gitlab/gitlab.rb` 文件中启用了任何 `geo_secondary[]` 配置选项，请将它们注释掉或移除，然后[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

此时，您提升的站点是新的主极狐GitLab 站点。可选地，如果您希望再次将 Geo 设置为新的从站点，可以[将旧站点恢复为从站点](bring_primary_back.md#configure-the-former-primary-site-to-be-a-secondary-site)。

<a id="promoting-a-secondary-site-with-multiple-nodes-and-a-single-secondary-site"></a>

### 提升具有多个节点和单个从站点的从站点

1. SSH 登录从站点中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 将从站点上的节点提升为主节点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. SSH 登录从站点上的每个 Rails 节点，并运行以下命令之一：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您可以使用先前用于从站点的 URL 连接到新提升的主站点。
1. 如果成功，从站点现已提升为主站点。

当您运行 `gitlab-ctl geo promote` 时，会在该节点上创建一个 [`gitlab-cluster.json`](#the-gitlab-clusterjson-file) 文件。当您重新配置时，该文件会覆盖 `gitlab.rb`中的 Geo 角色设置。

<a id="promoting-a-secondary-site-with-a-patroni-standby-cluster"></a>

#### 提升具有 Patroni 备用集群的从站点

1. SSH 登录从站点中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. SSH 登录从站点上的每个 Rails 节点，并运行以下命令之一：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您可以使用先前用于从站点的 URL 连接到新提升的主站点。
1. 如果成功，从站点现已提升为主站点。

<a id="promoting-a-secondary-site-with-an-external-postgresql-database"></a>

#### 提升具有外部 PostgreSQL 数据库的从站点

`gitlab-ctl geo promote` 命令可与外部 PostgreSQL 数据库结合使用。在这种情况下，您必须首先手动提升与从站点关联的副本数据库：

1. 提升与从站点关联的副本数据库。这
   会将数据库设置为读写。具体说明因数据库托管位置而异：
   - [Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Promote)
   - [Azure PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-read-replicas-portal#stop-replication)
   - [Google Cloud SQL](https://cloud.google.com/sql/docs/mysql/replication/manage-replicas#promote-replica)
   - 对于其他外部 PostgreSQL 数据库，请将以下脚本保存在您的
     从站点中，例如 `/tmp/geo_promote.sh`，并修改连接
     参数以匹配您的环境。然后执行它以提升副本：

     ```shell
     #!/bin/bash

     PG_SUPERUSER=postgres

     # The path to your pg_ctl binary. You may need to adjust this path to match
     # your PostgreSQL installation
     PG_CTL_BINARY=/usr/lib/postgresql/16/bin/pg_ctl

     # The path to your PostgreSQL data directory. You may need to adjust this
     # path to match your PostgreSQL installation. You can also run
     # `SHOW data_directory;` from PostgreSQL to find your data directory
     PG_DATA_DIRECTORY=/etc/postgresql/16/main

     # Promote the PostgreSQL database and allow read/write operations
     sudo -u $PG_SUPERUSER $PG_CTL_BINARY -D $PG_DATA_DIRECTORY promote
     ```

1. SSH 登录从站点中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. SSH 登录从站点上的每个 Rails 节点，并运行以下命令之一：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将从站点提升为主站点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您可以使用先前用于从站点的 URL 连接到新提升的主站点。
1. 如果成功，从站点现已提升为主站点。

<a id="optional-updating-the-primary-domain-dns-record"></a>

### （可选）更新主域 DNS 记录

更新主域的 DNS 记录，使其指向从站点。这样便无需更新对主域的所有引用，例如
更改 Git 远程和 API URL。

1. SSH 登录从站点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 更新主域的 DNS 记录。在将主域的
   DNS 记录更新为指向从站点后，编辑从站点上的 `/etc/gitlab/gitlab.rb`
   以反映新的 URL：

   ```ruby
   # Change the existing external_url configuration
   external_url 'https://<new_external_url>'
   ```

   > [!note]
   > 只要从站点 DNS 记录仍然完好，更改 `external_url` 不会阻止通过旧从站点 URL 进行访问。

1. 更新从站点的 SSL 证书：

   - 如果您使用 [Let's Encrypt 集成](https://gitlab.cn/docs/omnibus/settings/ssl/#enable-the-lets-encrypt-integration)，
     证书会自动更新。
   - 如果您[手动设置](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)了
     从站点的证书，请将证书从主站点复制到从站点。
     如果您无法访问主站点，请签发新证书，并确保其在
     主题备用名称中包含主站点和从站点 URL。您可以使用以下命令检查：

     ```shell
     /opt/gitlab/embedded/bin/openssl x509 -noout -dates -subject -issuer \
         -nameopt multiline -ext subjectAltName -in /etc/gitlab/ssl/new-gitlab.new-example.com.crt
     ```

1. 重新配置从站点以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 执行以下命令以更新新提升的主站点 URL：

   ```shell
   gitlab-rake gitlab:geo:update_primary_node_url
   ```

   此命令使用在 `/etc/gitlab/gitlab.rb`中定义的
   已更改的 `external_url` 配置。

1. 验证您可以使用其 URL 连接到新提升的主站点。
   如果您更新了主域的 DNS 记录，这些更改可能
   尚未传播，具体取决于先前的 DNS 记录 TTL。

<a id="optional-add-secondary-geo-site-to-a-promoted-primary-site"></a>

### （可选）将从 Geo 站点添加到已提升的主站点

要使新的从站点上线，请遵循 [Geo 设置说明](../setup/_index.md)。

<a id="promoting-secondary-geo-replica-in-multi-secondary-configurations"></a>

## 在多从站点配置中提升从 Geo 副本

如果您有多个从站点并且需要提升其中一个，我们建议您遵循[在单从站点配置中提升从 Geo 站点](#promoting-a-secondary-geo-site-in-single-secondary-configurations)，之后您还需要两个额外步骤。

<a id="step-1-prepare-the-new-primary-site-to-serve-one-or-more-secondary-sites"></a>

### 步骤 1. 准备新的主站点以服务一个或多个从站点

1. SSH 登录新的主站点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   ## Enable a Geo Primary role (if you haven't yet)
   roles ['geo_primary_role']

   ##
   # Allow PostgreSQL client authentication from the primary and secondary IPs. These IPs may be
   # public or VPC addresses in CIDR format, for example ['198.51.100.1/32', '198.51.100.2/32']
   ##
   postgresql['md5_auth_cidr_addresses'] = ['<primary_site_ip>/32', '<secondary_site_ip>/32']

   # Every secondary site needs to have its own slot so specify the number of secondary sites you're going to have
   # postgresql['max_replication_slots'] = 1 # Set this to be the number of Geo secondary nodes if you have more than one

   ##
   ## Disable automatic database migrations temporarily
   ## (until PostgreSQL is restarted and listening on the private address).
   ##
   gitlab_rails['auto_migrate'] = false
   ```

   （有关这些设置的更多详细信息，您可以阅读[配置主服务器](../setup/database.md#step-1-configure-the-primary-site)）

1. 保存文件并重新配置极狐GitLab，以应用数据库监听更改和
   复制槽更改：

   ```shell
   gitlab-ctl reconfigure
   ```

   重启 PostgreSQL 以使更改生效：

   ```shell
   gitlab-ctl restart postgresql
   ```

1. 现在 PostgreSQL 已重启并在私有地址上监听，重新启用迁移。

   编辑 `/etc/gitlab/gitlab.rb` 并将配置更改为 `true`：

   ```ruby
   gitlab_rails['auto_migrate'] = true
   ```

   保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="step-2-initiate-the-replication-process"></a>

### 步骤 2. 启动复制过程

现在我们需要让每个从站点监听新主站点上的更改。为此，您需要再次[启动复制过程](../setup/database.md#step-3-initiate-the-replication-process)，但这次针对另一个主站点。所有旧的复制设置都会被覆盖。

现有从站点都将拥有已填充的数据库，因此您可能会看到类似以下的消息：

```shell
Found data inside the gitlabhq_production database! If you are sure you are in the secondary server, override with --force
```

在确认您位于适当的从站点后，使用 `--force` 启动复制。

> [!warning]
> 使用 `--force` 会导致该从站点服务器上数据库中的所有现有数据被删除。

<a id="promoting-a-secondary-geo-cluster-in-the-gitlab-helm-chart"></a>

## 在 GitLab Helm chart 中提升从 Geo 集群

在更新云原生 Geo 部署时，更新从 Kubernetes 集群外部的任何节点的过程与非云原生方法没有区别。因此，您始终可以参考[在单从站点配置中提升从 Geo 站点](#promoting-a-secondary-geo-site-in-single-secondary-configurations)以获取更多信息。

以下各节假设您使用 `gitlab` 命名空间。如果您在设置集群时使用了不同的命名空间，还应将 `--namespace gitlab` 替换为您的命名空间。

<a id="step-1-permanently-disable-the-primary-cluster"></a>

### 步骤 1. 永久禁用主集群

> [!warning]
> 如果主站点离线，主站点上可能保存有
> 尚未复制到从站点的数据。如果您继续操作，这些数据应被视为
> 已丢失。

如果主站点发生故障，您应尽一切可能避免脑裂情况，即写入可能发生在两个不同的极狐GitLab 实例中，从而使恢复工作复杂化。因此，为故障转移做准备，您必须禁用主站点：

- 如果您有主 Kubernetes 集群的访问权限，请连接到它并禁用极狐GitLab `webservice` 和 `Sidekiq` Pod：

  ```shell
  kubectl --namespace gitlab scale deploy gitlab-geo-webservice-default --replicas=0
  kubectl --namespace gitlab scale deploy gitlab-geo-sidekiq-all-in-1-v1 --replicas=0
  ```

- 如果您没有主 Kubernetes 集群的访问权限，请将集群离线，并
  通过您可用的任何方式防止其重新上线。
  您可能需要：

  - 重新配置负载均衡器。
  - 更改 DNS 记录（例如，将主 DNS 记录指向
    从站点，以停止使用主站点）。
  - 停止虚拟服务器。
  - 通过防火墙阻止流量。
  - 撤销主站点的对象存储权限。
  - 物理断开机器。

<a id="step-2-promote-all-secondary-site-nodes-external-to-the-cluster"></a>

### 步骤 2. 提升集群外部的所有从站点节点

> [!warning]
> 如果从站点[已暂停](../_index.md#pausing-and-resuming-replication)，这会执行
> 时间点恢复至最后已知状态。
> 在从站点暂停期间在主站点上创建的数据将丢失。

1. 对于使用 Linux 软件包的从 Kubernetes 集群外部的每个节点（例如 PostgreSQL 或 Gitaly），
   SSH 登录该节点并运行以下命令之一：

   - 将 Kubernetes 集群外部的从站点节点提升为主节点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将 Kubernetes 集群外部的从站点节点提升为主节点，无需任何进一步确认：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 找到 `toolbox` Pod：

   ```shell
   kubectl --namespace gitlab get pods -lapp=toolbox
   ```

1. 提升从站点：

   ```shell
   kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- gitlab-rake gitlab:geo:set_secondary_as_primary
   ```

   可以提供环境变量来修改任务的行为。可用的
   变量有：

   | 名称 | 默认值 | 描述 |
   | ---- | ------------- | ------- |
   | `ENABLE_SILENT_MODE` | `false`  | 如果为 `true`，则在提升前启用[静默模式](../../silent_mode/_index.md) |

<a id="step-3-promote-the-secondary-cluster"></a>

### 步骤 3. 提升从集群

1. 更新现有集群配置。

   您可以使用 Helm 检索现有配置：

   ```shell
   helm --namespace gitlab get values gitlab-geo > gitlab.yaml
   ```

   现有配置包含一个 Geo 部分，应类似于：

   ```yaml
   geo:
      enabled: true
      role: secondary
      nodeName: secondary.example.com
      psql:
         host: geo-2.db.example.com
         port: 5431
         password:
            secret: geo
            key: geo-postgresql-password
   ```

   要将从集群提升为主集群，请将 `role: secondary` 更新为 `role: primary`。

   如果集群仍作为主站点，您必须移除 `geo` 下的整个 `psql` 部分；它指的是跟踪数据库。如果保留在原处，应用程序会在启动时将该节点识别为从节点，这会导致路由注册问题，从而在使用统一 URL 添加新从站点时破坏身份验证。

   使用新配置更新集群：

   ```shell
   helm upgrade --install --version <current Chart version> gitlab-geo gitlab/gitlab --namespace gitlab -f gitlab.yaml
   ```

1. 验证您能否使用之前用于从集群的 URL 连接到新提升的主集群。
1. 成功！从集群现已提升为主集群。

<a id="step-4-optional-promote-the-openbao-ha-cluster"></a>

### 步骤 4.（可选）提升 OpenBao HA 集群

如果您启用了极狐GitLab 密钥管理器，请在提升 Kubernetes 集群后完成以下步骤以提升 OpenBao 高可用性（HA）集群。

<a id="restart-openbao-pods"></a>

#### 重启 OpenBao Pod

在 PostgreSQL 副本提升为主节点后，重启 OpenBao Pod，使其
在数据库现在可写的情况下重新连接到数据库：

```shell
kubectl --namespace gitlab rollout restart deployment -l app=openbao
```

<a id="configure-jwt-authentication"></a>

#### 配置 JWT 身份验证

更新 DNS 记录，使主域指向已提升的从站点。OpenBao 不支持故障转移到使用不同域的从站点。有关更多信息，请参阅
[Geo 部署](../../secrets_manager/_index.md#geo-deployment)。

<a id="restore-the-unseal-secret-if-needed"></a>

#### 如需要，恢复解封凭据

从集群上的解封密钥必须与主集群上的解封密钥相同。否则，OpenBao 无法解封从集群上的保管库。

如果存在不匹配，请从您的[密钥备份](https://gitlab.cn/docs/charts/backup-restore/backup/#back-up-the-secrets)中恢复从集群上的 `gitlab-openbao-unseal` 密钥，
然后重启 OpenBao Pod：

```shell
kubectl --namespace gitlab rollout restart deployment -l app=openbao
```

<a id="verify-openbao-is-functional"></a>

#### 验证 OpenBao 功能正常

1. 检查所有 OpenBao Pod 是否正在运行：

   ```shell
   kubectl --namespace gitlab get pods -l app=openbao
   ```

1. 通过运行使用[密钥管理器变量](../../../ci/secrets/secrets_manager/_index.md)的 CI 流水线来测试 OpenBao 集成。

<a id="troubleshooting"></a>

## 故障排除

本节已移至[其他位置](failover_troubleshooting.md#fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site)。
