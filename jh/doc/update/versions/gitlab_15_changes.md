---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 15 升级说明
---

<!-- vale gitlab_base.OutdatedVersions = NO-->

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页包含极狐GitLab 15 次要版本和补丁版本的升级信息。请务必针对以下情况查看这些说明：

- 您的安装类型。
- 您当前版本与目标版本之间的所有版本。

有关 Helm chart 安装的更多信息，请参阅
[Helm chart 升级说明](https://gitlab.cn/docs/charts/releases/)。

<a id="15111"></a>

## 15.11.1

- 许多[群组和项目导入器](../../user/import/_index.md)现在要求具有维护者角色，而不再仅要求开发者角色。有关更多信息，请参阅您使用的任何导入器的文档。

<a id="15110"></a>

## 15.11.0

- 升级到补丁版本 15.11.3 或更高版本。这可以避免从 15.5.0 及更早版本升级时出现[议题 408304](https://gitlab.com/gitlab-org/gitlab/-/issues/408304)。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 会通过 PgBouncer 使用常规数据库连接，而不是覆盖配置中定义的直接连接，从而导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复于 |
  | ----------------------- | ----------------------- | -------- |
  | 15.11                   |  全部                    | 无     |
  | 16.0                    |  全部                    | 无     |
  | 16.1                    |  全部                    | 无     |
  | 16.2                    |  全部                    | 无     |
  | 16.3                    |  全部                    | 无     |
  | 16.4                    |  全部                    | 无     |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.6        | 16.7.7   |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |

<a id="linux-package-installations"></a>

### Linux 软件包安装

在极狐GitLab 15.11 中，PostgreSQL 将自动升级到 13.x，但以下情况除外：

- 您使用 Patroni 以高可用方式运行数据库。
- 您的数据库节点是极狐GitLab Geo 配置的一部分。
- 您已明确[选择退出](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades) PostgreSQL 的自动升级。
- 您在 `/etc/gitlab/gitlab.rb`中设置了 `postgresql['version'] = 12`。

容错和 Geo 安装支持手动升级到 PostgreSQL 13，
请参阅[在 HA/Geo 集群中部署的打包 PostgreSQL](https://gitlab.cn/docs/omnibus/settings/database/#packaged-postgresql-deployed-in-an-hageo-cluster)。

<a id="geo-installations"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 某些项目导入在创建项目时不会初始化 Wiki 代码仓库。请参阅
  [详细信息和变通方法](gitlab_16_changes.md#wiki-repositories-not-initialized-on-project-creation)。
- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。

<a id="pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13"></a>

#### `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13

| 受影响的次要版本 | 受影响的补丁版本 | 修复于 |
|-------------------------|-------------------------|----------|
| 15.2 - 15.10            | 全部                     | 无     |
| 15.11                   | 15.11.0 - 15.11.11      | 15.11.12 及更高版本 |

内置的 `pg-upgrade` 工具中存在一个[缺陷](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7841)，导致无法将内置的 PostgreSQL 数据库升级到版本 13。这会使从站点处于损坏状态，并阻止
将 Geo 安装升级到极狐GitLab 16.x
（[PostgreSQL 12 支持已在 16.0 中移除](../deprecations.md#postgresql-12-deprecated)及更高版本）。此问题发生在使用内置 PostgreSQL 软件的从站点上，这些站点在同一节点上运行从站点主 Rails 数据库和跟踪数据库。如果您无法升级到 15.11.12 及更高版本，可以使用手动[变通方法](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7841#workaround)。

<a id="1511x"></a>

## 15.11.x

- 一个[缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/411604)可能导致首次登录的新 LDAP 用户被分配基于其电子邮件地址而非其 LDAP 用户名属性的用户名。手动变通方法是设置 `gitlab_rails['omniauth_auto_link_ldap_user'] = true`，或升级到已修复该缺陷的极狐GitLab 16.1 或更高版本。

<a id="15105"></a>

## 15.10.5

- [Elastic Indexer Cron Workers 的缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/408214)可能导致 Sidekiq 饱和。
  - 出现此问题时，合并请求合并、流水线、Slack 通知和其他事件不会被创建，或需要很长时间才会发生。
  - 此问题可能不会立即显现，因为 Sidekiq 可能需要长达一周的时间才会饱和到足够程度。
  - 无需启用 Elasticsearch 也会发生此问题。
  - 要解决此问题，请升级到 15.11 或使用该议题中的变通方法。
- 许多[群组和项目导入器](../../user/import/_index.md)现在
  要求具有维护者角色，而不再仅要求开发者角色。有关更多信息，请参阅您使用的任何导入器的文档。

<a id="15100"></a>

## 15.10.0

- [Elastic Indexer Cron Workers 的缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/408214)可能导致 Sidekiq 饱和。
  - 出现此问题时，合并请求合并、流水线、Slack 通知和其他事件不会被创建，或需要很长时间才会发生。
  - 此问题可能不会立即显现，因为 Sidekiq 可能需要长达一周的时间才会饱和到足够程度。
  - 无需启用 Elasticsearch 也会发生此问题。
  - 要解决此问题，请升级到 15.11 或使用该议题中的变通方法。
- [零停机重新索引的缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/422938)可能导致重新索引时出现 `Couldn't load task status` 错误。您还可能在 Elasticsearch 主机上收到 `sliceId must be greater than 0 but was [-1]` 错误。作为变通方法，请考虑[从头重新索引](../../integration/elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index)或升级到极狐GitLab 16.3。
- 在极狐GitLab 16.0 中，Linux 软件包实例的 Gitaly 配置发生了重大变化。您可以在极狐GitLab 15.10 中开始迁移到新结构，同时在极狐GitLab 16.0 之前保持向后兼容。[详细了解此变更](gitlab_16_changes.md#gitaly-configuration-structure-change)。
- 升级到极狐GitLab 15.10 或更高版本时，您可能会遇到以下错误：

  ```shell
  STDOUT: rake aborted!
  StandardError: An error has occurred, all later migrations canceled:
  PG::CheckViolation: ERROR:  check constraint "check_70f294ef54" is violated by some row
  ```

  此错误是由于[极狐GitLab 15.8 中引入的批处理后台迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107701)
  在极狐GitLab 15.10 之前未完成而导致的。要解决此错误：

  1. 使用数据库控制台（对于 Linux 软件包安装，使用 `sudo gitlab-psql`）执行以下 SQL 语句：

     ```sql
     UPDATE oauth_access_tokens SET expires_in = '7200' WHERE expires_in IS NULL;
     ```

  1. [重新运行数据库迁移](../../administration/raketasks/maintenance.md#run-incomplete-database-migrations)。
- 升级到极狐GitLab 15.10 或更高版本时，您还可能会遇到以下错误：

  ```shell
  "exception.class": "ActiveRecord::StatementInvalid",
  "exception.message": "PG::SyntaxError: ERROR:  zero-length delimited identifier at or near \"\"\"\"\nLINE 1: ...COALESCE(\"lock_version\", 0) + 1 WHERE \"ci_builds\".\"\" IN (SEL...\n
  ```

  此错误是由于[极狐GitLab 14.9 中引入的批处理后台迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/81410)
  在升级到极狐GitLab 15.10 或更高版本之前未完成而导致的。要解决此错误，可以安全地[将该迁移标记为已完成](../background_migrations.md#mark-a-failed-migration-finished)：

  ```ruby
  # Start the rails console

  connection = Ci::ApplicationRecord.connection

  Gitlab::Database::SharedModel.using_connection(connection) do
    migration = Gitlab::Database::BackgroundMigration::BatchedMigration.find_for_configuration(
      Gitlab::Database.gitlab_schemas_for_connection(connection), 'NullifyOrphanRunnerIdOnCiBuilds', :ci_builds, :id, [])

    # mark all jobs completed
    migration.batched_jobs.update_all(status: Gitlab::Database::BackgroundMigration::BatchedJob.state_machine.states[:succeeded].value)
    migration.update_attribute(:status, Gitlab::Database::BackgroundMigration::BatchedMigration.state_machine.states[:finished].value)
  end
  ```

  有关更多信息，请参阅[议题 415724](https://gitlab.com/gitlab-org/gitlab/-/issues/415724)。

- 一个 [Terraform 配置缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/348453)导致即使 `gitlab.rb` 配置文件中将 `gitlab_rails['terraform_state_enabled']` 设置为 `false`，Terraform 状态仍保持启用。由于此缺陷已在极狐GitLab 15.10 中修复，如果在 `gitlab.rb` 配置中禁用了 [Terraform 状态](../../administration/terraform_state.md)功能，升级到极狐GitLab 15.10 可能会破坏使用该功能的项目。
  如果您在 `gitlab.rb`中配置了 `gitlab_rails['terraform_state_enabled'] = false`，请检查是否有任何项目
  正在使用 Terraform 状态功能。检查方法：
  1. 阅读 [Rails 控制台](../../administration/operations/rails_console.md)警告。
  1. 启动 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。
  1. 运行命令 `Terraform::State.pluck(:project_id)`。此命令返回所有具有
     Terraform 状态的项目 ID 数组。
  1. 导航到每个项目，并根据需要与相关方合作，确定 Terraform 状态功能是否
     仍在使用。如果不再需要 Terraform 状态，您可以按照步骤[移除状态文件](../../user/infrastructure/iac/terraform_state.md#remove-a-state-file)。

<a id="geo-installations-1"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1590"></a>

## 15.9.0

- [Elastic Indexer Cron Workers 的缺陷](https://gitlab.com/gitlab-org/gitlab/-/issues/408214)可能导致 Sidekiq 饱和。
  - 出现此问题时，合并请求合并、流水线、Slack 通知和其他事件不会被创建，或需要很长时间才会发生。
  - 此问题可能不会立即显现，因为 Sidekiq 可能需要长达一周的时间才会饱和到足够程度。
  - 无需启用 Elasticsearch 也会发生此问题。
  - 要解决此问题，请升级到 15.11 或使用该议题中的变通方法。
- [`BackfillTraversalIdsToBlobsAndWikiBlobs` 高级搜索迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107730)中的缺陷可能导致 Elasticsearch 集群饱和。
  - 出现此问题时，搜索可能会变慢，并且对 Elasticsearch 集群的更新可能需要很长时间才能完成。
  - 要解决此问题，请升级到极狐GitLab 15.10 以[减小迁移批次大小](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/113719)。
- 升级到补丁版本 15.9.3 或更高版本。这修复了两个数据库迁移缺陷：
  - 补丁版本 15.9.0、15.9.1、15.9.2 存在一个缺陷，可能导致用户个人资料字段 `linkedin`、`twitter`、`skype`、`website_url`、
    `location` 和 `organization`中的数据丢失。有关更多信息，请参阅
    [议题 393216](https://gitlab.com/gitlab-org/gitlab/-/issues/393216)。
  - 第二个[缺陷修复](https://gitlab.com/gitlab-org/gitlab/-/issues/394760)确保可以从 15.4.x 直接升级。
- 作为 [CI 分区工作](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/ci_data_decay/pipeline_partitioning/)的一部分，`ci_builds_needs` 上添加了一个[新的外键](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107547)。在具有大型 CI 表的极狐GitLab 实例上，添加此约束可能需要比平时更长的时间。
- Praefect 的元数据验证器[无效元数据删除行为](../../administration/gitaly/praefect/configure.md#enable-deletions)现已默认启用。

  元数据验证器处理 Praefect 数据库中的副本记录，并验证副本确实存在于 Gitaly 节点上。如果副本不存在，其
  元数据记录将被删除。这使 Praefect 能够修复以下情况：副本的元数据记录表明其状态正常，但实际上磁盘上并不存在该副本。
  删除元数据记录后，Praefect 的协调器会安排一个复制作业来重新创建该副本。

  由于过去状态管理逻辑的问题，数据库中可能存在无效的元数据记录。例如，这些记录可能由于代码仓库删除不完整
  或重命名部分完成而存在。验证器会删除受影响代码仓库的这些陈旧副本记录。由于副本记录被移除，这些代码仓库可能会在指标和 `praefect dataloss` 子命令中显示为
  不可用的代码仓库。如果您遇到此类代码仓库，请使用 `praefect remove-repository` 移除
  该代码仓库的剩余记录。

  您可以在极狐GitLab 15.0 及更高版本中通过搜索验证器输出的日志记录来查找先前存在无效元数据记录的代码仓库。[详细了解代码仓库验证，并查看示例日志条目](../../administration/gitaly/praefect/configure.md#repository-verification)。
- 在极狐GitLab 16.0 中，Linux 软件包实例的 Praefect 配置发生了重大变化。您可以在极狐GitLab 15.9 中开始迁移到新结构，同时在极狐GitLab 16.0 之前保持向后兼容。[详细了解此变更](gitlab_16_changes.md#praefect-configuration-structure-change)。

<a id="self-compiled-installations"></a>

### 自编译安装

- 对于**自编译（源码）安装**，随着 `gitlab-sshd`的加入，构建 GitLab Shell 需要 Kerberos 头文件。

  ```shell
  sudo apt install libkrb5-dev
  ```

<a id="geo-installations-2"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1582"></a>

## 15.8.2

<a id="geo-installations-3"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1581"></a>

## 15.8.1

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-4"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1580"></a>

## 15.8.0

- Gitaly 要求 Git 2.38.0 及更高版本。对于自编译安装，您应使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-5"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1576"></a>

## 15.7.6

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-6"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1575"></a>

## 15.7.5

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-7"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1574"></a>

## 15.7.4

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-8"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1573"></a>

## 15.7.3

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-9"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1572"></a>

## 15.7.2

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-10"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1571"></a>

## 15.7.1

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-11"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1570"></a>

## 15.7.0

- 此版本会验证 `issues.work_item_type_id` 列上的 `NOT NULL DB` 约束。
  要升级到此版本，`issues` 表上不应存在 `NULL` `work_item_type_id`的记录。
  有多个 `BackfillWorkItemTypeIdForIssues` 后台迁移，将通过
  `EnsureWorkItemTypeBackfillMigrationFinished` 部署后迁移完成。
- 极狐GitLab 15.4.0 引入了一个[批处理后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，
  用于[回填议题表上的 `namespace_id` 值](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/91921)。在较大的极狐GitLab 实例上，此
  迁移可能需要数小时或数天才能完成。在升级到 15.7.0 之前，请确保该迁移
  已成功完成。
- 添加了一个数据库约束，规定议题表上的
   `namespace_id` 列没有 `NULL` 值。

  - 如果来自 15.4 的 `namespace_id` 批处理后台迁移失败（参见上一项），那么 15.7 升级
    会因数据库迁移错误而失败。

  - 在议题表较大的极狐GitLab 实例上，验证此约束会导致升级耗时
    比平时更长。所有数据库变更需要在一小时限制内完成：

    ```plaintext
    FATAL: Mixlib::ShellOut::CommandTimeout: rails_migration[gitlab-rails]
    [..]
    Mixlib::ShellOut::CommandTimeout: Command timed out after 3600s:
    ```

    存在一种变通方法，可以[手动完成数据变更和升级](../package/package_troubleshooting.md#error-command-timed-out-after-3600s)。
- 默认的 Sidekiq `max_concurrency` 已更改为 20。现在这与我们的文档和产品默认值
  保持一致。

  例如，之前：

  - Linux 软件包安装默认值（`sidekiq['max_concurrency']`）：50
  - 自编译安装默认值：50
  - Helm chart 默认值（`gitlab.sidekiq.concurrency`）：25

  参考架构仍使用默认值 10，因为这是专门
  为这些配置设置的。

  已配置 `max_concurrency`的站点不会受此变更影响。
  [详细了解 Sidekiq 并发设置](../../administration/sidekiq/extra_sidekiq_processes.md#concurrency)。
- 极狐GitLab Runner 15.7.0 引入了一个影响 CI/CD 作业的破坏性变更：[正确处理作业文件变量的展开](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/3613)。
  此前，引用
  [文件类型变量](../../ci/variables/_index.md#use-file-type-cicd-variables)
  的作业定义变量会被展开为文件变量的值（其内容）。此行为不符合
  shell 变量展开的典型规则。此外，如果文件变量及其
  内容被打印，还可能存在密钥或敏感信息泄露的风险。例如，如果它们被打印在 echo 输出中。有关更多信息，
  请参阅[了解极狐GitLab 15.7 中文件类型变量展开的变更](https://about.gitlab.com/blog/impact-of-the-file-type-variable-change-15-7/)。
- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="geo-installations-12"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1567"></a>

## 15.6.7

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-13"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1566"></a>

## 15.6.6

- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-14"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="1565"></a>

## 15.6.5

<a id="geo-installations-15"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1564"></a>

## 15.6.4

<a id="geo-installations-16"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1563"></a>

## 15.6.3

<a id="geo-installations-17"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1562"></a>

## 15.6.2

<a id="geo-installations-18"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1561"></a>

## 15.6.1

<a id="geo-installations-19"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1560"></a>

## 15.6.0

- 您应使用[官方支持的 PostgreSQL 版本](../../administration/package_information/postgresql_versions.md)之一。某些数据库迁移可能导致旧版 PostgreSQL 出现稳定性和性能问题。
- Gitaly 要求 Git 2.37.0 及更高版本。对于自编译安装，您应使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- 一项修改四个索引行为的数据库变更在不存在这些索引的实例上会失败：

  ```plaintext
  Caused by:
  PG::UndefinedTable: ERROR:  relation "index_issues_on_title_trigram" does not exist
  ```

  其他三个索引是：`index_merge_requests_on_title_trigram`、`index_merge_requests_on_description_trigram`
  和 `index_issues_on_description_trigram`。

  此问题已在[极狐GitLab 15.7 中修复](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/105375)并向后移植
  到极狐GitLab 15.6.2。此问题也可以变通解决：
  [了解如何创建这些索引](https://gitlab.com/gitlab-org/gitlab/-/issues/378343#note_1199863087)。

<a id="linux-package-installations-1"></a>

### Linux 软件包安装

在极狐GitLab 15.6 中，[`omnibus-gitlab` 软件包附带的 PostgreSQL 版本](../../administration/package_information/postgresql_versions.md)
已升级到 12.12 和 13.8。除非[明确选择退出](https://gitlab.cn/docs/omnibus/settings/database/#automatic-restart-when-the-postgresql-version-changes)，否则这可能导致 PostgreSQL 服务自动重启，并可能造成停机。

<a id="geo-installations-20"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- [容器镜像仓库推送事件被拒绝](https://gitlab.com/gitlab-org/gitlab/-/issues/386389)，由 `/api/v4/container_registry_event/events` 端点导致，这使 Geo 从站点无法感知容器镜像仓库镜像的更新，因而无法复制这些更新。因此，故障转移后从站点可能包含过期的容器镜像。这影响版本 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2。如果您将 Geo 与容器仓库一起使用，建议升级到极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，可避免故障转移后可能的数据丢失。
- 我们发现了一个问题：在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能受到影响。这可能导致故障转移后数据丢失。
  - 受影响版本：极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1555"></a>

## 15.5.5

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1554"></a>

## 15.5.4

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，这是由于极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题导致所有通配符域名（如 `.example.com`）都被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中还原该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。有关更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1553"></a>

## 15.5.3

- 极狐GitLab 15.4.0 引入了默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用[队列选择器](https://archives.docs.gitlab.com/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated)的实例，这会导致[性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为部分 Sidekiq 进程会处于空闲状态。
  - 默认路由规则已在 15.5.4 中回退，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果极狐GitLab 实例现在仅监听 `default` 队列（目前不推荐这样做），则需要在 `/etc/gitlab/gitlab.rb`中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题会导致所有通配符域名（如 `.example.com`）被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1552"></a>

## 15.5.2

- 极狐GitLab 15.4.0 引入了默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用[队列选择器](https://archives.docs.gitlab.com/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated)的实例，这会导致[性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为部分 Sidekiq 进程会处于空闲状态。
  - 默认路由规则已在 15.5.4 中回退，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果极狐GitLab 实例现在仅监听 `default` 队列（目前不推荐这样做），则需要在 `/etc/gitlab/gitlab.rb`中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题会导致所有通配符域名（如 `.example.com`）被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1551"></a>

## 15.5.1

- 极狐GitLab 15.4.0 引入了默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用[队列选择器](https://archives.docs.gitlab.com/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated)的实例，这会导致[性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为部分 Sidekiq 进程会处于空闲状态。
  - 默认路由规则已在 15.5.4 中回退，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果极狐GitLab 实例现在仅监听 `default` 队列（目前不推荐这样做），则需要在 `/etc/gitlab/gitlab.rb`中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题会导致所有通配符域名（如 `.example.com`）被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1550"></a>

## 15.5.0

- 极狐GitLab 15.4.0 引入了默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用[队列选择器](https://archives.docs.gitlab.com/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queueselectors-deprecated)的实例，这会导致[性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为部分 Sidekiq 进程会处于空闲状态。
  - 默认路由规则已在 15.5.4 中回退，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果极狐GitLab 实例现在仅监听 `default` 队列（目前不推荐这样做），则需要在 `/etc/gitlab/gitlab.rb`中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题会导致所有通配符域名（如 `.example.com`）被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="geo-installations-21"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1546"></a>

## 15.4.6

- Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://docs.gitlab.com/omnibus/settings/environment-variables.md)
  可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在缺陷。
  此问题会导致所有通配符域名（如 `.example.com`）被忽略，只有 `no_proxy` 变量中列出的最后一个除外。
  要变通解决此问题，您可以将通配符域名移到列表末尾，或升级到[包含修复后 cURL 的更高版本](https://about.gitlab.com/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1545"></a>

## 15.4.5

- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1544"></a>

## 15.4.4

- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1543"></a>

## 15.4.3

- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1542"></a>

## 15.4.2

- 如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：
  - 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
  - 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
    - 15.2.5 --> 15.3.5
    - 15.3.0 - 15.3.4 --> 15.3.5
    - 15.4.1 --> 15.4.3
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1541"></a>

## 15.4.1

- 如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：
  - 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
  - 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
    - 15.2.5 --> 15.3.5
    - 15.3.0 - 15.3.4 --> 15.3.5
    - 15.4.1 --> 15.4.3
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。

<a id="1540"></a>

## 15.4.0

- 极狐GitLab 15.4.0 包含一个[批处理后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于[从 `expire_at`中移除 `ci_job_artifacts` 表中的错误值](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/89318)。
  在较大的极狐GitLab 实例上，此迁移可能需要数小时或数天才能完成。
- 默认情况下，Gitaly 和 Praefect 节点使用 `pool.ntp.org` 上的时间服务器。如果您的实例无法连接到 `pool.ntp.org`，
  请改为[配置 `NTP_HOST` 变量](../../administration/gitaly/praefect/configure.md#customize-time-server-setting)，否则日志和 `gitlab-rake gitlab:gitaly:check`的输出中可能会出现 `ntp: read udp ... i/o timeout` 错误。不过，如果 Gitaly 主机的时间已同步，则可以忽略这些错误。
- 极狐GitLab 15.4.0 引入了默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用[队列选择器](https://archives.docs.gitlab.com/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated)的实例，这会导致[性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为部分 Sidekiq 进程会处于空闲状态。
  - 默认路由规则已在 15.4.5 中回退，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果极狐GitLab 实例现在仅监听 `default` 队列（目前不推荐这样做），则需要在 `/etc/gitlab/gitlab.rb`中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- `/etc/gitlab/gitlab-secrets.json`的结构在 [极狐GitLab 15.4](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/6310)中已修改，
  并且向 `gitlab_pages`、`grafana` 和 `mattermost` 部分添加了新配置。
  在高可用或极狐GitLab Geo 环境中，所有节点上的密钥必须相同。
  如果您手动在节点之间同步密钥文件，或在
  `/etc/gitlab/gitlab.rb`中手动指定密钥，请确保所有节点上的 `/etc/gitlab/gitlab-secrets.json` 相同。
- 极狐GitLab 15.4.0 引入了一个[批处理后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于
  [回填议题表上的 `namespace_id` 值](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/91921)。在较大的极狐GitLab 实例上，此
  迁移可能需要数小时或数天才能完成。在升级到 15.7.0 或更高版本之前，请确保该迁移
  已成功完成。
- 由于 [极狐GitLab 15.4 中引入的缺陷](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)，如果 Gitaly 集群 (Praefect)中的一个或多个 Git 代码仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么[代码仓库检查](../../administration/repository_checks.md)和 [Geo 复制与验证](../../administration/geo/_index.md)将停止对受影响的 Gitaly 集群 (Praefect)中的所有项目或项目 Wiki 代码仓库运行。该缺陷已通过[在极狐GitLab 15.9.0 中回退该变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓库。更多信息，请参阅[该缺陷议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/390155)。
- 极狐GitLab 15.4 及更高版本默认启用重新设计的登录页面，后续版本中还会带来更多改进。更多信息，请参阅[史诗 8557](https://gitlab.com/groups/gitlab-org/-/work_items/8557)。
  可以通过功能标志禁用它。启动 [Rails 控制台](../../administration/operations/rails_console.md)并运行：

  ```ruby
  Feature.disable(:restyle_login_page)
  ```

<a id="geo-installations-22"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1534"></a>

## 15.3.4

如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：

- 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
- 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
  - 15.2.5 --> 15.3.5
  - 15.3.0 - 15.3.4 --> 15.3.5
  - 15.4.1 --> 15.4.3

<a id="1533"></a>

## 15.3.3

- 在极狐GitLab 15.3.3 中，[SAML 群组链接](../../api/saml.md#saml-group-links) API 的 `access_level` 属性类型已更改为 `integer`。请参阅
  [API 文档](../../api/group_members.md)。
- 如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：

  - 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
  - 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
    - 15.2.5 --> 15.3.5
    - 15.3.0 - 15.3.4 --> 15.3.5
    - 15.4.1 --> 15.4.3

<a id="1532"></a>

## 15.3.2

如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：

- 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
- 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
  - 15.2.5 --> 15.3.5
  - 15.3.0 - 15.3.4 --> 15.3.5
  - 15.4.1 --> 15.4.3

<a id="1531"></a>

## 15.3.1

如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：

- 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
- 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
  - 15.2.5 --> 15.3.5
  - 15.3.0 - 15.3.4 --> 15.3.5
  - 15.4.1 --> 15.4.3

<a id="1530"></a>

## 15.3.0

- 在 Gitaly 集群 (Praefect)中新建的 Git 代码仓库不再使用 `@hashed`
  存储路径。新代码仓库的服务器钩子必须复制到
  其他位置。Praefect 现在会生成供 Gitaly
  集群使用的副本路径。此变更是 Gitaly 集群 (Praefect)原子性地
  创建、删除和重命名 Git 代码仓库的先决条件。

  要识别副本路径，
  请[查询 Praefect 代码仓库元数据](../../administration/gitaly/praefect/troubleshooting.md#view-repository-metadata)
  并将 `@hashed` 存储路径传递给 `-relative-path`。

  有了这些信息，您就可以正确安装
  [服务器钩子](../../administration/server_hooks.md)。

- 如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：

  - 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
  - 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
    - 15.2.5 --> 15.3.5
    - 15.3.0 - 15.3.4 --> 15.3.5
    - 15.4.1 --> 15.4.3

<a id="geo-installations-23"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- LFS 传输可能会在会话中途从从站点重定向到主站点。请参阅
  [详细信息和变通方法](#lfs-transfers-redirect-to-primary-from-secondary-site-mid-session)。
- Geo 从站点上对象存储 LFS 文件被错误删除。请参阅
  [详细信息和变通方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。

<a id="lfs-transfers-redirect-to-primary-from-secondary-site-mid-session"></a>

#### LFS 传输在会话中途从从站点重定向到主站点

| 受影响的小版本 | 受影响的补丁版本 | 修复于 |
|-------------------------|-------------------------|----------|
| 15.1                    | 全部                     | 无     |
| 15.2                    | 全部                     | 无     |
| 15.3                    | 15.3.0 - 15.3.2         | 15.3.3 及更高版本 |

在极狐GitLab 15.1.0 至 15.3.2 中，当启用 [Geo 代理](../../administration/geo/secondary_proxy/_index.md)时，LFS 传输可能会[在会话中途从从站点重定向到主站点](https://gitlab.com/gitlab-org/gitlab/-/issues/371571)，导致拉取和克隆请求失败。Geo 代理在极狐GitLab 15.1 及更高版本中默认启用。

此问题已在极狐GitLab 15.3.3 中解决，因此具有以下配置的客户应升级到 15.3.3 或更高版本：

- 已启用 LFS。
- LFS 对象正在跨 Geo 站点复制。
- 正在使用 Geo 从站点拉取代码仓库。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="incorrect-object-storage-lfs-file-deletion-on-secondary-sites"></a>

#### Geo 从站点上对象存储 LFS 文件被错误删除

| 受影响的小版本 | 受影响的补丁版本 | 修复于 |
|-------------------------|-------------------------|----------|
| 15.0                    | 全部                     | 无     |
| 15.1                    | 全部                     | 无     |
| 15.2                    | 全部                     | 无     |
| 15.3                    | 15.3.0 - 15.3.2         | 15.3.3 及更高版本 |

在极狐GitLab 15.0.0 至 15.3.2 中，以下情况下可能会发生 [Geo 从站点上对象存储文件被错误删除](https://gitlab.com/gitlab-org/gitlab/-/issues/371397)：

- 极狐GitLab 管理的对象存储复制已禁用，并且在启用对象存储的情况下导入项目时创建了 LFS 对象。
- 用于同步对象存储的极狐GitLab 管理复制已启用，随后又被禁用。

此问题已在 15.3.3 中解决。同时启用 LFS 且 LFS 对象正在跨 Geo 站点复制的客户应直接升级到 15.3.3，以降低从站点上数据丢失的风险。

<a id="1525"></a>

## 15.2.5

如果您添加新许可证，[许可证缓存问题](https://gitlab.com/gitlab-org/gitlab/-/issues/376706)会导致极狐GitLab 的部分专业版功能无法正常工作。此问题的变通方法：

- 应用新许可证后，重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关的许可证缓存，使所有专业版功能正常运行。
- 升级到不受此问题影响的版本。受影响的版本可使用以下升级路径：
  - 15.2.5 --> 15.3.5
  - 15.3.0 - 15.3.4 --> 15.3.5
  - 15.4.1 --> 15.4.3

<a id="1520"></a>

## 15.2.0

- 具有多个 Web 节点的极狐GitLab 安装实例应先
  [升级到 15.1](#1510)，然后再升级到 15.2（及更高版本），因为
  Rails 中的配置变更可能导致 ETag 键生成不一致。
- 此版本中重命名了一些 Sidekiq 工作进程。为避免任何中断，请在开始升级到极狐GitLab 15.2.0 之前，[运行 Rake 任务以迁移任何待处理的作业](../../administration/sidekiq/sidekiq_job_migration.md#migrate-queued-and-future-jobs)。
- Gitaly 现在会在[运行时位置](https://gitlab.com/gitlab-org/gitaly/-/merge_requests/4670)执行其二进制文件。在 Linux 软件包实例上，默认情况下
  此路径为 `/var/opt/gitlab/gitaly/run/`。如果此位置以 `noexec` 挂载，合并请求会生成以下错误：

  ```plaintext
  fork/exec /var/opt/gitlab/gitaly/run/gitaly-<nnnn>/gitaly-git2go-v15: permission denied
  ```

  要解决此问题，请从文件系统挂载中移除 `noexec` 选项。另一种方法是更改 Gitaly 运行时目录：

  1. 将 `gitaly['runtime_dir'] = '<PATH_WITH_EXEC_PERM>'` 添加到 `/etc/gitlab/gitlab.rb`，并指定一个未设置 `noexec`的位置。
  1. 运行 `sudo gitlab-ctl reconfigure`。

<a id="geo-installations-24"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置的 PostregSQL 数据库升级到版本 13。请参阅
  [详细信息和变通方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- LFS 传输可能会在会话中途从从站点重定向到主站点。请参阅
  [详细信息和变通方法](#lfs-transfers-redirect-to-primary-from-secondary-site-mid-session)。
- Geo 从站点上对象存储 LFS 文件被错误删除。请参阅
  [详细信息和变通方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1510"></a>

## 15.1.0

- 在极狐GitLab 15.1.0 中，我们将 Rails `ActiveSupport::Digest` 切换为使用 SHA256 而非 MD5。
  这会影响诸如原始代码片段文件下载等资源的 ETag 键生成。为确保升级时多个
  Web 节点之间的 ETag 键生成一致，所有服务器必须先升级到 15.1.6，然后
  再升级到 15.2.0 或更高版本：

  1. 确保所有极狐GitLab Web 节点都运行极狐GitLab 15.1.6。
  1. 如果您通过 cloud native GitLab Helm chart [在 Kubernetes 上运行极狐GitLab](https://gitlab.cn/docs/charts/installation/)，请确保所有
     Webservice pod 都运行极狐GitLab 15.1.Z：

     ```shell
     kubectl get pods -l app=webservice -o custom-columns=webservice-image:{.spec.containers[0].image},workhorse-image:{.spec.containers[1].image}
     ```

  1. [启用 `active_support_hash_digest_sha256` 功能标志](../../administration/feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags)，将 `ActiveSupport::Digest` 切换为使用 SHA256：

     1. [启动 Rails 控制台](../../administration/operations/rails_console.md)
     1. 启用功能标志：

        ```ruby
        Feature.enable(:active_support_hash_digest_sha256)
        ```

  1. 只有完成上述步骤后，才能继续升级到更高版本的极狐GitLab。
- 不再支持对 [`ciConfig` GraphQL 字段](../../api/graphql/reference/_index.md#queryciconfig)进行未经身份验证的请求。
  在升级到极狐GitLab 15.1 之前，请向您的请求添加[访问令牌](../../api/rest/authentication.md)。
  创建令牌的用户必须具有在项目中创建流水线的[权限](../../user/permissions.md)。

<a id="geo-installations-25"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [Geo 代理](../../administration/geo/secondary_proxy/_index.md)在 15.1 中[针对不同 URL 默认启用](https://gitlab.com/gitlab-org/gitlab/-/issues/346112)。这可能是一项破坏性变更。如有需要，您可以[禁用 Geo 代理](../../administration/geo/secondary_proxy/_index.md#disable-secondary-site-http-proxying)。如果您对不同 URL 使用 SAML，则必须修改 SAML 配置和身份提供商配置。更多信息，请参阅 [Geo 与单点登录 (SSO) 文档](../../administration/geo/replication/single_sign_on.md)。
- LFS 传输可能会在会话中途从从站点重定向到主站点。请参阅
  [详细信息和变通方法](#lfs-transfers-redirect-to-primary-from-secondary-site-mid-session)。
- Geo 从站点上对象存储 LFS 文件被错误删除。请参阅
  [详细信息和变通方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象时仍会从主站点下载。请参阅[详细信息和变通方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="1500"></a>

## 15.0.0

- Elasticsearch 6.8 [不再受支持](../../integration/advanced_search/elasticsearch.md#version-compatibility)。在升级到极狐GitLab 15.0 之前，请[将 Elasticsearch 更新到任意 7.x 版本](../../integration/advanced_search/elasticsearch.md#upgrade-to-a-new-elasticsearch-version)。
- 如果您将极狐GitLab 与外部 PostgreSQL（尤其是 AWS RDS）一起运行，请确保
  在升级到极狐GitLab 14.8 或更高版本之前，将 PostgreSQL 升级到最低 12.7 或 13.3 的补丁级别。

  [在 14.8 中](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/75511)
  针对极狐GitLab 企业版，以及[在 15.0 中](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/87983)
  针对极狐GitLab 基础版，启用了一项名为 Loose Foreign Keys 的极狐GitLab 功能。

  启用后，我们收到了由数据库引擎缺陷导致段错误而引发的意外 PostgreSQL 重启报告。

  更多信息，请参阅[议题 364763](https://gitlab.com/gitlab-org/gitlab/-/issues/364763)。

- 在[移除对使用 `background_upload`的支持](../deprecations.md#background-upload-for-object-storage)后，不再支持使用带存储特定配置的加密 S3 存储桶。
- [基于证书的 Kubernetes 集成（已弃用）](../../user/infrastructure/clusters/_index.md#certificate-based-kubernetes-integration-deprecated)默认禁用，但您可以在极狐GitLab 16.0 之前通过 [`certificate_based_clusters` 功能标志](../../administration/feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags)重新启用它。
- 当您将 GitLab Helm Chart 项目与自定义 `serviceAccount` 一起使用时，请确保它对 `serviceAccount` 和 `secret` 资源具有 `get` 和 `list` 权限。
- `FF_GITLAB_REGISTRY_HELPER_IMAGE` [功能标志](../../administration/feature_flags/_index.md#enable-or-disable-the-feature)已移除，辅助镜像始终从极狐GitLab 镜像仓库拉取。

<a id="linux-package-installations-2"></a>

### Linux 软件包安装

- 用于配置全局服务器钩子的 [`custom_hooks_dir`](../../administration/server_hooks.md#create-global-server-hooks-for-all-repositories) 设置现在在
  Gitaly 中配置。GitLab Shell 中的先前实现已在极狐GitLab 15.0 中移除。通过此变更，全局服务器钩子仅存储在
  以钩子类型命名的子目录中。全局服务器钩子不再能是自定义钩子目录根目录中的单个钩子文件。例如，您必须使用 `<custom_hooks_dir>/<hook_name>.d/*`，而
  不是 `<custom_hooks_dir>/<hook_name>`。
  - 对于 Linux 软件包实例，请在 `gitlab.rb`中使用 `gitaly['custom_hooks_dir']`。这将取代 `gitlab_shell['custom_hooks_dir']`。
- PostgreSQL 13.6 作为全新安装的默认版本提供，
  升级则使用 12.10。您可以按照
  [升级文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)手动升级到 PostgreSQL 13.6：

  ```shell
  sudo gitlab-ctl pg-upgrade -V 13
  ```

  在 PostgreSQL 12 被移除之前，如有兼容性或测试环境方面的需要，您可以
  [固定 PostgreSQL 版本](https://gitlab.cn/docs/omnibus/settings/database/#pin-the-packaged-postgresql-version-fresh-installs-only)。

  [容错和 Geo 安装需要额外的步骤和规划](../../administration/postgresql/replication_and_failover.md#upgrading-postgresql-major-version-in-a-patroni-cluster)。

  由于底层的结构性变更，在运行数据库
  迁移之前升级时，必须重启正在运行的 PostgreSQL 进程。如果跳过了自动重启，您必须在运行迁移之前
  运行以下命令：

  ```shell
  # If using PostgreSQL
  sudo gitlab-ctl restart postgresql

  # If using Patroni for Database replication
  sudo gitlab-ctl restart patroni
  ```

  如果未重启 PostgreSQL，您可能会遇到
  [与加载库相关的错误](https://gitlab.cn/docs/omnibus/settings/database/#could-not-load-library-plpgsqlso)。

- 从极狐GitLab 15.0 开始，当 PostgreSQL 版本发生变化时，`postgresql` 和 `geo-postgresql` 服务
  会自动重启。重启
  PostgreSQL 服务会因数据库暂时无法用于操作而导致停机。虽然此重启对于
  数据库服务的正常运行是必需的，但您可能希望对 PostgreSQL
  重启的时机有更多控制。为此，您可以选择在 `gitlab-ctl reconfigure` 过程中跳过自动重启，并手动重启服务。

  要在极狐GitLab 15.0 升级过程中跳过自动重启，请在升级前执行以下
  步骤：

  1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

     ```ruby
     # For PostgreSQL/Patroni
     postgresql['auto_restart_on_version_change'] = false

     # For Geo PostgreSQL
     geo_postgresql['auto_restart_on_version_change'] = false
     ```

  1. 重新配置极狐GitLab：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

  > [!note]
  > 当底层版本发生变化时，必须重启 PostgreSQL，以避免
  > 诸如[与加载必要库相关的错误](https://gitlab.cn/docs/omnibus/settings/database/#could-not-load-library-plpgsqlso)
  > 而导致停机。因此，如果您使用上述方法跳过了自动重启，
  > 请确保在升级到极狐GitLab
  > 15.0 之前手动重启服务。

- 从极狐GitLab 15.0 开始，NGINX 默认不允许 `AES256-GCM-SHA384` SSL 密码算法。
  如果您使用
  [AWS 经典负载均衡器](https://docs.aws.amazon.com/en_en/elasticloadbalancing/latest/classic/elb-ssl-security-policy.html#ssl-ciphers)并且需要该密码算法，
  可以将其重新添加到允许名单。要将该 SSL 密码算法添加到允许名单：

  1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

     ```ruby
     nginx['ssl_ciphers'] = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:AES256-GCM-SHA384"
     ```

  1. 重新配置极狐GitLab：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

- 移除了对 Gitaly 内部套接字路径的支持。
  在极狐GitLab 14.10 中，Gitaly 引入了一个新目录，用于存放 Gitaly 正常运行所需的
  所有运行时数据。此新目录取代了
  旧的内部套接字目录，因此 `gitaly['internal_socket_dir']` 的使用已被弃用，改用
  `gitaly['runtime_dir']`。

  旧的 `gitaly['internal_socket_dir']` 配置已在此版本中移除。

- 移除了对象存储的后台上传设置。
  对象存储现在优先使用直接上传。

  `/etc/gitlab/gitlab.rb`中不再支持以下键：

  - `gitlab_rails['artifacts_object_store_direct_upload']`
  - `gitlab_rails['artifacts_object_store_background_upload']`
  - `gitlab_rails['external_diffs_object_store_direct_upload']`
  - `gitlab_rails['external_diffs_object_store_background_upload']`
  - `gitlab_rails['lfs_object_store_direct_upload']`
  - `gitlab_rails['lfs_object_store_background_upload']`
  - `gitlab_rails['uploads_object_store_direct_upload']`
  - `gitlab_rails['uploads_object_store_background_upload']`
  - `gitlab_rails['packages_object_store_direct_upload']`
  - `gitlab_rails['packages_object_store_background_upload']`
  - `gitlab_rails['dependency_proxy_object_store_direct_upload']`
  - `gitlab_rails['dependency_proxy_object_store_background_upload']`

<a id="self-compiled-installations-1"></a>

### 自编译安装

- 极狐GitLab 已添加对多个数据库的支持。对于**自编译（源码）安装**，
  `config/database.yml` 必须在数据库配置中包含数据库名称。
  `main: database` 必须放在首位。如果使用了无效或已弃用的语法，应用启动时会生成错误：

  ```plaintext
  ERROR: This installation of GitLab uses unsupported 'config/database.yml'.
  The main: database needs to be defined as a first configuration item instead of primary. (RuntimeError)
  ```

  此前，`config/database.yml` 文件如下所示：

  ```yaml
  production:
    adapter: postgresql
    encoding: unicode
    database: gitlabhq_production
    ...
  ```

  从极狐GitLab 15.0 开始，它必须首先定义一个 `main` 数据库：

  ```yaml
  production:
    main:
      adapter: postgresql
      encoding: unicode
      database: gitlabhq_production
      ...
  ```

<a id="geo-installations-26"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- Geo 从站点上对象存储 LFS 文件被错误删除。请参阅
  [详细信息和变通方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。
