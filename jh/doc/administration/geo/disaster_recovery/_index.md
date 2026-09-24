---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 灾难恢复 (Geo)
description: 使用 Geo 实例从灾难中恢复。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 复制您的数据库、Git 仓库和其他资产。存在一些[已知问题](../_index.md#known-issues)。

> [!warning]
>
> - 多辅助站点配置需要完全重新同步和重新配置所有未提升的辅助站点，并导致停机。
> - 辅助站点提升后，主站点将完全分离。如果您希望恢复主站点，则必须将其添加为新的辅助站点。

<a id="secondary-sites-with-selective-synchronization-enabled"></a>

## 启用选择性同步的辅助站点

提升启用了选择性同步的**辅助**站点会导致所有未复制到该辅助站点的数据**永久丢失**。更多信息，请参见[提升启用了选择性同步的辅助站点](../replication/selective_synchronization.md#promoting-a-secondary-site-with-selective-synchronization-enabled)。

<a id="the-gitlab-clusterjson-file"></a>

## `gitlab-cluster.json` 文件

当您使用 `gitlab-ctl geo promote` 将辅助站点提升为主站点时，该命令会自动在其执行的每个节点上创建 `/etc/gitlab/gitlab-cluster.json` 文件。在大多数情况下，您不需要手动编辑此文件。

`gitlab-cluster.json` 文件允许提升命令自动化配置更改，而无需直接修改 `/etc/gitlab/gitlab.rb`。以编程方式编辑 `gitlab.rb` 容易出错，因此 `gitlab-cluster.json` 充当机器管理的覆盖层。

当两个文件同时存在时，执行 `gitlab-ctl reconfigure` 时，`gitlab-cluster.json` 中的值优先于 `gitlab.rb` 中的相应值。当您运行此命令时，会看到类似以下警告：

```plaintext
'geo_primary_role' 在 /etc/gitlab/gitlab-cluster.json 中被定义为 'true'，并覆盖了 /etc/gitlab/gitlab.rb 中的设置
'geo_secondary_role' 在 /etc/gitlab/gitlab-cluster.json 中被定义为 'false'，并覆盖了 /etc/gitlab/gitlab.rb 中的设置
```

提升后，出现此警告是正常的。

<a id="file-structure"></a>

### 文件结构

一个典型的 `gitlab-cluster.json` 文件如下所示：

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
| `primary` | 当为 `true` 时，启用 `geo_primary_role`，将节点配置为 Geo 主站点。 |
| `secondary` | 当为 `true` 时，启用 `geo_secondary_role`，将节点配置为 Geo 辅助站点。 |
| `geo_secondary` | 包含与 Geo 辅助站点配置相关的设置，例如跟踪数据库。`"enable": false` 禁用辅助站点特定的服务。 |

`primary` 和 `secondary` 键分别映射到 `geo_primary_role` 和 `geo_secondary_role`。这些角色对于单节点设置很方便，不应在已在 `gitlab.rb` 中显式配置了各个服务角色的多节点配置中使用。

<a id="remove-the-file"></a>

### 删除文件

成功提升后，您可以保留 `gitlab-cluster.json` 文件。但是，在以下情况下，您应该将其删除：

- 如果您[将降级的主站点重新作为辅助站点恢复](bring_primary_back.md#configure-the-former-primary-site-to-be-a-secondary-site)，则必须从每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点删除 `gitlab-cluster.json`。
- 当您更新 `gitlab.rb` 以设置 Geo 角色（例如 `roles(['geo_primary_role'])`）后，并希望 `gitlab.rb` 成为唯一的配置源时。
- 从部分故障转移中恢复后。

  有关恢复期间手动创建该文件的详细信息，请参见[从部分故障转移中恢复](failover_troubleshooting.md#recovering-from-a-partial-failover)。

删除文件的步骤：

- 运行以下命令：

  ```shell
  sudo rm /etc/gitlab/gitlab-cluster.json
  sudo gitlab-ctl reconfigure
  ```

  在多节点设置中，对站点中的每个节点重复执行这些命令。

有关 `gitlab-cluster.json` 如何与重新配置过程交互的技术细节，请参见[Omnibus 重新配置文档](https://gitlab.cn/docs/omnibus/development/reconfigure_in_detail/#gitlab-clusterjson-file)。

<a id="promoting-a-secondary-geo-site-in-single-secondary-configurations"></a>

## 在单辅助站点配置中提升辅助 Geo 站点

虽然您无法自动提升 Geo 副本并执行故障转移，但如果您有对机器的 `root` 访问权限，则可以手动提升。

此过程将一个**辅助** Geo 站点提升为**主站点**。为了尽快恢复地理冗余，您应在遵循这些说明后立即添加一个新的**辅助站点**。

<a id="allow-replication-to-finish-if-possible"></a>

### 如果可能，请允许复制完成

如果**辅助站点**仍在从**主站点**复制数据，请尽可能严格遵循[计划的故障转移文档](planned_failover.md)，以避免不必要的数据丢失。

<a id="step-1-permanently-disable-the-primary-site"></a>

### 步骤 1. 永久禁用**主站点**

> [!warning]
> 如果**主站点**离线，**主站点**上可能保存有尚未复制到**辅助站点**的数据。如果您继续，这些数据应被视为已丢失。

如果发生**主站点**中断，您应尽一切可能避免裂脑情况，即写入可能发生在两个不同的极狐GitLab 实例中，从而使恢复工作复杂化。因此，为了准备故障转移，我们必须禁用**主站点**。

- 如果您有 SSH 访问权限：

  1. 通过 SSH 登录**主站点**并停止和禁用极狐GitLab：

     ```shell
     sudo gitlab-ctl stop
     ```

  2. 防止极狐GitLab 在服务器意外重启时再次启动：

     ```shell
     sudo systemctl disable gitlab-runsvdir
     ```

- 如果您没有**主站点**的 SSH 访问权限，请将机器离线并采取任何可用手段阻止其重启。
  您可能需要：

  - 重新配置负载均衡器。
  - 更改 DNS 记录（例如，将主 DNS 记录指向**辅助站点**以停止使用**主站点**）。
  - 停止虚拟服务器。
  - 通过防火墙阻止流量。
  - 撤销**主站点**的对象存储权限。
  - 物理断开机器。

  如果您计划[更新主域 DNS 记录](#optional-updating-the-primary-domain-dns-record)，您可能希望保持较低的 TTL 以确保 DNS 更改快速传播。

  > [!note]
  > 此过程中不会自动将主站点的 `/etc/gitlab/gitlab.rb` 文件复制到辅助站点。请确保备份主站点的 `/etc/gitlab/gitlab.rb` 文件，以便稍后在辅助站点上恢复所需的值。

<a id="step-2-promoting-a-secondary-site"></a>

### 步骤 2. 提升**辅助站点**

提升辅助站点时请注意以下几点：

- 如果辅助站点[已暂停](../replication/pause_resume_replication.md)，则提升会执行到最后一个已知状态的时间点恢复。辅助站点暂停期间在主站点上创建的数据将丢失。
- 如果辅助站点[已暂停](../replication/pause_resume_replication.md)，并且在此过程中遇到 `ActiveRecord::StatementInvalid: PG::ReadOnlySqlTransaction: ERROR: cannot execute DELETE in a read-only transaction` 错误消息，请参阅此知识库文章：[Geo 提升失败并出现只读事务错误或主站点意外关闭后超时](https://support.gitlab.com/hc/en-us/articles/21019042667804-Geo-promotion-fails-with-read-only-transaction-error-or-timeout-after-unexpected-primary-shutdown)。
- 此时不应添加新的**辅助站点**。如果您想添加新的**辅助站点**，请在完成将**辅助站点**提升为**主站点**的整个过程之后进行。
- 如果在此过程中遇到 `ActiveRecord::RecordInvalid: Validation failed: Name has already been taken` 错误消息，请参阅此[故障排除建议](failover_troubleshooting.md#fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site)。
- 如果您使用的是独立 URL，则应将[主域 DNS 指向新提升的站点](#optional-updating-the-primary-domain-dns-record)。否则，必须重新向新提升的站点注册 Runner，并更新所有 Git 远程、书签和外部集成。
- 如果您正在使用[位置感知 DNS](../secondary_proxy/_index.md#configure-location-aware-dns)，则在从 DNS 条目中移除旧主站点后，Runner 应自动连接到新的主站点。
- 在主站点关闭后，在辅助站点上运行 `gitlab-ctl promotion-preflight-checks` 以检查 Geo 同步状态并执行最终验证检查。
- 如果您不期望连接到先前主站点的 Runner 会重新上线，则应将其移除：
  - 通过 UI：
    1. 在右上角，选择 **管理员**。
    2. 选择 **CI/CD** > **Runners** 并将其移除。
  - 使用 [Runners API](../../../api/runners.md)。

<a id="promoting-a-secondary-site-running-on-a-single-node"></a>

#### 提升在单节点上运行的**辅助站点**

1. 通过 SSH 登录**辅助站点**并执行：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

2. 使用先前用于**辅助站点**的 URL 验证您能否连接到新提升的**主站点**。
3. 如果成功，**辅助站点**现已提升为**主站点**。

运行 `gitlab-ctl geo promote` 时，会在节点上创建一个 [`gitlab-cluster.json`](#the-gitlab-clusterjson-file) 文件。该文件在重新配置时会覆盖 `gitlab.rb` 中的 Geo 角色设置。

<a id="step-3-removing-the-former-secondarys-tracking-database"></a>

### 步骤 3. 删除原辅助站点的跟踪数据库

如果您的 `/etc/gitlab/gitlab.rb` 文件中启用了任何 `geo_secondary[]` 配置选项，请将其注释掉或删除，然后[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

此时，您提升后的站点就是新的主极狐GitLab 站点。可选地，如果您希望再次将 Geo 设置为新的辅助站点，可以[将旧站点恢复为辅助站点](bring_primary_back.md#configure-the-former-primary-site-to-be-a-secondary-site)。

<a id="promoting-a-secondary-site-with-multiple-nodes-and-a-single-secondary-site"></a>

### 提升具有多个节点和**单辅助站点**的**辅助站点**

1. 通过 SSH 登录**辅助站点**中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 在辅助站点上将节点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

2. 通过 SSH 登录**辅助站点**上的每个 Rails 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

3. 使用先前用于**辅助站点**的 URL 验证您能否连接到新提升的**主站点**。
4. 如果成功，**辅助站点**现已提升为**主站点**。

运行 `gitlab-ctl geo promote` 时，会在节点上创建一个 [`gitlab-cluster.json`](#the-gitlab-clusterjson-file) 文件。该文件在重新配置时会覆盖 `gitlab.rb` 中的 Geo 角色设置。

<a id="promoting-a-secondary-site-with-a-patroni-standby-cluster"></a>

#### 使用 Patroni 备用集群提升**辅助站点**

1. 通过 SSH 登录**辅助站点**中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

2. 通过 SSH 登录**辅助站点**上的每个 Rails 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

3. 使用先前用于**辅助站点**的 URL 验证您能否连接到新提升的**主站点**。
4. 如果成功，**辅助站点**现已提升为**主站点**。

<a id="promoting-a-secondary-site-with-an-external-postgresql-database"></a>

#### 使用外部 PostgreSQL 数据库提升**辅助站点**

`gitlab-ctl geo promote` 命令可与外部 PostgreSQL 数据库结合使用。在这种情况下，您必须首先手动提升与**辅助站点**关联的副本数据库：

1. 提升与**辅助站点**关联的副本数据库。这会将数据库设置为读写。具体说明因数据库托管位置而异：
   - [Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Promote)
   - [Azure PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-read-replicas-portal#stop-replication)
   - [Google Cloud SQL](https://cloud.google.com/sql/docs/mysql/replication/manage-replicas#promote-replica)
   - 对于其他外部 PostgreSQL 数据库，请在辅助站点上保存以下脚本，例如 `/tmp/geo_promote.sh`，并修改连接参数以匹配您的环境。然后执行它以提升副本：

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

2. 通过 SSH 登录**辅助站点**中的每个 Sidekiq、PostgreSQL 和 Gitaly 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

3. 通过 SSH 登录**辅助站点**上的每个 Rails 节点，并运行以下命令之一：

   - 将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将辅助站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

4. 使用先前用于**辅助站点**的 URL 验证您能否连接到新提升的**主站点**。
5. 如果成功，**辅助站点**现已提升为**主站点**。

<a id="optional-updating-the-primary-domain-dns-record"></a>

### （可选）更新主域 DNS 记录

更新主域的 DNS 记录以指向**辅助站点**。这样就不需要更新所有对主域的引用，例如更改 Git 远程和 API URL。

1. 通过 SSH 登录**辅助站点**并作为 root 登录：

   ```shell
   sudo -i
   ```

2. 更新主域 DNS 记录。将主域的 DNS 记录更新为指向**辅助站点**后，编辑**辅助站点**上的 `/etc/gitlab/gitlab.rb` 以反映新 URL：

   ```ruby
   # Change the existing external_url configuration
   external_url 'https://<new_external_url>'
   ```

   > [!note]
   > 更改 `external_url` 不会阻止通过旧的辅助站点 URL 访问，只要辅助站点 DNS 记录仍然完好。

3. 更新**辅助站点**的 SSL 证书：

   - 如果您使用 [Let's Encrypt 集成](https://docs.gitlab.com/omnibus/settings/ssl/#enable-the-lets-encrypt-integration)，证书会自动更新。
   - 如果您[手动设置了](https://docs.gitlab.com/omnibus/settings/ssl/#configure-https-manually)**辅助站点**的证书，请将证书从**主站点**复制到**辅助站点**。如果您无法访问**主站点**，请颁发新证书，并确保其主题备用名称中包含**主站点**和**辅助站点**的 URL。您可以使用以下命令检查：

     ```shell
     /opt/gitlab/embedded/bin/openssl x509 -noout -dates -subject -issuer \
         -nameopt multiline -ext subjectAltName -in /etc/gitlab/ssl/new-gitlab.new-example.com.crt
     ```

4. 重新配置**辅助站点**以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   ```

5. 执行以下命令以更新新提升的**主站点** URL：

   ```shell
   gitlab-rake geo:update_primary_node_url
   ```

   此命令使用在 `/etc/gitlab/gitlab.rb` 中定义的更改后的 `external_url` 配置。

6. 验证您能否使用其 URL 连接到新提升的**主站点**。如果您更新了主域的 DNS 记录，根据之前的 DNS 记录 TTL，这些更改可能尚未传播。

<a id="optional-add-secondary-geo-site-to-a-promoted-primary-site"></a>

### （可选）将**辅助** Geo 站点添加到已提升的**主站点**

要将新的**辅助站点**上线，请遵循 [Geo 设置说明](../setup/_index.md)。

<a id="promoting-secondary-geo-replica-in-multi-secondary-configurations"></a>

## 在多辅助站点配置中提升辅助 Geo 副本

如果您有多个**辅助站点**，并且需要提升其中一个，我们建议您按照[在单辅助站点配置中提升辅助 Geo 站点](#promoting-a-secondary-geo-site-in-single-secondary-configurations)中的说明操作，之后还需两个额外步骤。

<a id="step-1-prepare-the-new-primary-site-to-serve-one-or-more-secondary-sites"></a>

### 步骤 1. 准备新的**主站点**以服务一个或多个**辅助站点**

1. 通过 SSH 登录新的**主站点**并作为 root 登录：

   ```shell
   sudo -i
   ```

2. 编辑 `/etc/gitlab/gitlab.rb`：

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

   （有关这些设置的更多详细信息，请参阅[配置主服务器](../setup/database.md#step-1-configure-the-primary-site)）

3. 保存文件并重新配置极狐GitLab 以应用数据库监听更改和复制槽更改：

   ```shell
   gitlab-ctl reconfigure
   ```

   重启 PostgreSQL 以使其更改生效：

   ```shell
   gitlab-ctl restart postgresql
   ```

4. 在 PostgreSQL 已重启并在私有地址上监听后，重新启用迁移。

   编辑 `/etc/gitlab/gitlab.rb` 并将配置**更改**为 `true`：

   ```ruby
   gitlab_rails['auto_migrate'] = true
   ```

   保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="step-2-initiate-the-replication-process"></a>

### 步骤 2. 启动复制过程

现在，我们需要使每个**辅助站点**监听新**主站点**上的更改。为此，您需要再次[启动复制过程](../setup/database.md#step-3-initiate-the-replication-process)，但这次是针对另一个**主站点**。所有旧的复制设置都将被覆盖。

现有的辅助站点都有已填充的数据库，因此您可能会看到类似以下消息：

```shell
Found data inside the gitlabhq_production database! If you are sure you are in the secondary server, override with --force
```

确认您位于正确的辅助站点后，使用 `--force` 启动复制。

> [!warning]
> 使用 `--force` 会导致**该辅助服务器上数据库中的所有现有数据被删除**。

<a id="promoting-a-secondary-geo-cluster-in-the-gitlab-helm-chart"></a>

## 在极狐GitLab Helm Chart 中提升辅助 Geo 集群

在更新云原生 Geo 部署时，更新辅助 Kubernetes 集群之外的任何节点的过程与非云原生方法没有区别。因此，您可以随时参考[在单辅助站点配置中提升辅助 Geo 站点](#promoting-a-secondary-geo-site-in-single-secondary-configurations)以获取更多信息。

以下部分假设您使用的是 `gitlab` 命名空间。如果在设置集群时使用了不同的命名空间，则应将 `--namespace gitlab` 替换为您的命名空间。

<a id="step-1-permanently-disable-the-primary-cluster"></a>

### 步骤 1. 永久禁用**主集群**

> [!warning]
> 如果**主站点**离线，**主站点**上可能保存有尚未复制到**辅助站点**的数据。如果您继续，这些数据应被视为已丢失。

如果发生**主站点**中断，您应尽一切可能避免裂脑情况，即写入可能发生在两个不同的极狐GitLab 实例中，从而使恢复工作复杂化。因此，为了准备故障转移，您必须禁用**主站点**：

- 如果您有权访问**主站点** Kubernetes 集群，请连接到它并禁用极狐GitLab `webservice` 和 `Sidekiq` Pod：

  ```shell
  kubectl --namespace gitlab scale deploy gitlab-geo-webservice-default --replicas=0
  kubectl --namespace gitlab scale deploy gitlab-geo-sidekiq-all-in-1-v1 --replicas=0
  ```

- 如果您无权访问**主站点** Kubernetes 集群，请将该集群离线并采取任何可用手段阻止其重新上线。
  您可能需要：

  - 重新配置负载均衡器。
  - 更改 DNS 记录（例如，将主 DNS 记录指向**辅助站点**以停止使用**主站点**）。
  - 停止虚拟服务器。
  - 通过防火墙阻止流量。
  - 撤销**主站点**的对象存储权限。
  - 物理断开机器。

<a id="step-2-promote-all-secondary-site-nodes-external-to-the-cluster"></a>

### 步骤 2. 提升集群外部的所有**辅助站点**节点

> [!warning]
> 如果辅助站点[已暂停](../_index.md#pausing-and-resuming-replication)，此操作将执行到最后一个已知状态的时间点恢复。辅助站点暂停期间在主站点上创建的数据将丢失。

1. 对于使用 Linux 软件包的**辅助站点** Kubernetes 集群外部的每个节点（例如 PostgreSQL 或 Gitaly），通过 SSH 登录该节点并运行以下命令之一：

   - 将 Kubernetes 集群外部的**辅助站点**节点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在不进一步确认的情况下将 Kubernetes 集群外部的**辅助站点**节点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

2. 找到 `toolbox` Pod：

   ```shell
   kubectl --namespace gitlab get pods -lapp=toolbox
   ```

3. 提升辅助站点：

   ```shell
   kubectl --namespace gitlab exec -ti gitlab-geo-toolbox-XXX -- gitlab-rake geo:set_secondary_as_primary
   ```

   可以提供环境变量来修改任务的行为。可用变量如下：

   | 名称 | 默认值 | 描述 |
   | ---- | ------------- | ------- |
   | `ENABLE_SILENT_MODE` | `false`  | 如果为 `true`，则在提升前启用[静默模式](../../silent_mode/_index.md)（极狐GitLab 16.4 及更高版本） |

<a id="step-3-promote-the-secondary-cluster"></a>

### 步骤 3. 提升**辅助集群**

1. 更新现有集群配置。

   您可以使用 Helm 检索现有配置：

   ```shell
   helm --namespace gitlab get values gitlab-geo > gitlab.yaml
   ```

   现有配置中包含一个 Geo 部分，应类似于：
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

要将 **次要** 集群提升为 **主要** 集群，请将 `role: secondary` 更新为 `role: primary`。

如果该集群已成为主要站点，则必须删除 `geo` 下的整个 `psql` 部分；它指向跟踪数据库。如果保留该配置，应用程序在启动时会将节点识别为次要节点，导致路由注册问题，当使用统一 URL 添加新次要节点时会破坏身份验证。

使用新配置更新集群：

```shell
helm upgrade --install --version <current Chart version> gitlab-geo gitlab/gitlab --namespace gitlab -f gitlab.yaml
```

1. 验证您可以使用之前次要节点所用的 URL 连接到新提升的主要节点。
1. 成功！次要节点现已提升为主要节点。

### 步骤 4.（可选）提升 OpenBao HA 集群

如果您启用了极狐GitLab 密钥管理器，请在提升 Kubernetes 集群后完成以下步骤以提升 OpenBao 高可用 (HA) 集群。

#### 重启 OpenBao Pod

在 PostgreSQL 副本提升为主要节点后，重启 OpenBao Pod，使其重新连接到现在的可写数据库：

```shell
kubectl --namespace gitlab rollout restart deployment -l app=openbao
```

#### （可选）配置 JWT 认证

如果您已将主域名的 DNS 记录更新为指向次要站点，请跳过此步骤。

要重新配置 JWT 认证，您需要一个 root 令牌。使用恢复密钥生成一个。更多信息，请参阅
[从恢复密钥生成 root 令牌](../../secrets_manager/recovery_key.md#generate-a-root-token-from-the-recovery-key)。

获得 root 令牌后，重新配置 JWT 认证挂载以指向次要域名。
配置详情请参阅
[Geo 配置](https://gitlab.cn/docs/charts/charts/openbao/#geo-configuration)。

#### 如有需要，恢复解封密钥

次要集群上的解封密钥必须与主密钥上的相同，否则 OpenBao 将无法在次要集群上解封存储库。

如果不匹配，请从您的[密钥备份](https://gitlab.cn/docs/charts/backup-restore/backup/#back-up-the-secrets)中恢复次要集群上的 `gitlab-openbao-unseal` 密钥，然后重启 OpenBao Pod：

```shell
kubectl --namespace gitlab rollout restart deployment -l app=openbao
```

#### 验证 OpenBao 是否正常工作

1. 检查所有 OpenBao Pod 是否正在运行：

   ```shell
   kubectl --namespace gitlab get pods -l app=openbao
   ```

1. 通过运行使用[密钥管理器变量](../../../ci/secrets/secrets_manager/_index.md)的 CI 流水线来测试 OpenBao 集成。

## 故障排除

本节内容已移至[另一位置](failover_troubleshooting.md#fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site)。