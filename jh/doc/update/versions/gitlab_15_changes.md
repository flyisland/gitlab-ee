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

本页面包含极狐GitLab 15 次要版本和补丁版本的升级信息。
请确保根据以下内容查阅相关说明：

- 您的安装类型。
- 您当前版本与目标版本之间的所有版本。

有关 Helm Chart 安装的更多信息，请参阅
[Helm chart 6.0 升级说明](https://gitlab.cn/docs/charts/releases/6_0/)。

<a id="15.11.1"></a>

## 15.11.1

- 许多 [群组与项目导入器](../../user/import/_index.md) 现在需要维护者角色，而不再仅需开发者角色。更多信息，请参阅您所使用的任何导入器的文档。

<a id="15.11.0"></a>

## 15.11.0

- **升级到补丁版本 15.11.3 或更高版本**。这可以避免从 15.5.0 及更早版本升级时遇到 [问题 408304](https://gitlab.com/gitlab-org/gitlab/-/issues/408304)。
- 通常，在具有 PgBouncer 的环境中，备份必须 [通过设置带有 `GITLAB_BACKUP_` 前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。然而，由于一个 [问题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 会通过 PgBouncer 使用常规数据库连接，而不是覆盖中定义直连，导致数据库备份失败。解决方法是直接使用 `pg_dump`。

  **受影响的版本**:

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 15.11                   |  所有                    | 无     |
  | 16.0                    |  所有                    | 无     |
  | 16.1                    |  所有                    | 无     |
  | 16.2                    |  所有                    | 无     |
  | 16.3                    |  所有                    | 无     |
  | 16.4                    |  所有                    | 无     |
  | 16.5                    |  所有                    | 无     |
  | 16.6                    |  所有                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.6        | 16.7.7   |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |

### Linux 软件包安装

在极狐GitLab 15.11 中，PostgreSQL 将自动升级到 13.x，但以下情况除外：

- 您正在使用 Patroni 运行高可用性数据库。
- 您的数据库节点是极狐GitLab Geo 配置的一部分。
- 您已明确 [选择退出](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades) 自动升级 PostgreSQL。
- 您在 `/etc/gitlab/gitlab.rb` 中配置了 `postgresql['version'] = 12`。

容错和 Geo 安装支持手动升级到 PostgreSQL 13，
请参阅 [在 HA/Geo 集群中部署的打包 PostgreSQL](https://gitlab.cn/docs/omnibus/settings/database/#packaged-postgresql-deployed-in-an-hageo-cluster)。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 某些项目导入在项目创建时不会初始化 wiki 代码仓。请参阅
  [详细信息和解决方法](gitlab_16_changes.md#wiki-repositories-not-initialized-on-project-creation)。
- `pg_upgrade` 无法将捆绑的 PostgreSQL 数据库升级到版本 13。请参阅
  [详细信息和解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。

<a id="pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13"></a>

#### `pg_upgrade` 无法将捆绑的 PostgreSQL 数据库升级到版本 13

| 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
|-------------------------|-------------------------|----------|
| 15.2 - 15.10            | 所有                     | 无     |
| 15.11                   | 15.11.0 - 15.11.11      | 15.11.12 及更高版本 |

内置 `pg-upgrade` 工具中的一个 [错误](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7841) 阻止了将捆绑的 PostgreSQL 数据库升级到版本 13。这会使次要站点处于损坏状态，并阻止将 Geo 安装升级到极狐GitLab 16.x
（[PostgreSQL 12 支持已在 16.0 中移除](../deprecations.md#postgresql-12-deprecated) 及更高版本）。
此问题发生在使用捆绑 PostgreSQL 软件的次要站点上，这些站点在同一节点上同时运行辅助 Rails 主数据库和跟踪数据库。
如果您无法升级到 15.11.12 及更高版本，可以使用手动
[解决方法](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7841#workaround)。

<a id="15.11.x"></a>

## 15.11.x

- 一个 [错误](https://gitlab.com/gitlab-org/gitlab/-/issues/411604) 可能导致新的 LDAP 用户在首次登录时被分配一个基于其电子邮件地址的用户名，而不是基于其 LDAP 用户名属性。手动解决方法是将 `gitlab_rails['omniauth_auto_link_ldap_user']` 设置为 `true`，或者升级到已修复此错误的极狐GitLab 16.1 或更高版本。

<a id="15.10.5"></a>

## 15.10.5

- [Elastic Indexer Cron Worker 的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/408214) 可能导致 Sidekiq 饱和。
  - 当此问题发生时，合并请求的合并、流水线、Slack 通知和其他事件不会被创建，或者需要很长时间才能发生。
  - 此问题可能不会立即显现，因为它可能需要长达一周的时间才能使 Sidekiq 达到足够饱和。
  - 即使未启用 Elasticsearch，也会发生此问题。
  - 要解决此问题，请升级到 15.11 或使用问题中的解决方法。
- 许多 [群组与项目导入器](../../user/import/_index.md) 现在需要维护者角色，而不再仅需开发者角色。更多信息，请参阅您所使用的任何导入器的文档。

<a id="15.10.0"></a>

## 15.10.0

- [Elastic Indexer Cron Worker 的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/408214) 可能导致 Sidekiq 饱和。
  - 当此问题发生时，合并请求的合并、流水线、Slack 通知和其他事件不会被创建，或者需要很长时间才能发生。
  - 此问题可能不会立即显现，因为它可能需要长达一周的时间才能使 Sidekiq 达到足够饱和。
  - 即使未启用 Elasticsearch，也会发生此问题。
  - 要解决此问题，请升级到 15.11 或使用问题中的解决方法。
- [零停机时间重新索引的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/422938) 可能导致重新索引时出现 `Couldn't load task status` 错误。您还可能在 Elasticsearch 主机上遇到 `sliceId must be greater than 0 but was [-1]` 错误。作为解决方法，请考虑 [从头开始重新索引](../../integration/elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index) 或升级到极狐GitLab 16.3。
- 对于 Linux 软件包实例，Gitaly 配置在极狐GitLab 16.0 中发生了显著变化。您可以从极狐GitLab 15.10 开始迁移到新结构，同时保持向后兼容性，直至极狐GitLab 16.0。[阅读更多关于此变更的信息](gitlab_16_changes.md#gitaly-configuration-structure-change)。
- 升级到极狐GitLab 15.10 或更高版本时，您可能会遇到以下错误：

  ```shell
  STDOUT: rake aborted!
  StandardError: An error has occurred, all later migrations canceled:
  PG::CheckViolation: ERROR:  check constraint "check_70f294ef54" is violated by some row
  ```

  此错误是由于 [极狐GitLab 15.8 中引入的批量后台迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107701) 在极狐GitLab 15.10 之前未能完成所致。要解决此错误：

  1. 使用数据库控制台（对于 Linux 软件包安装，使用 `sudo gitlab-psql`）执行以下 SQL 语句：

     ```sql
     UPDATE oauth_access_tokens SET expires_in = '7200' WHERE expires_in IS NULL;
     ```

  1. [重新运行数据库迁移](../../administration/raketasks/maintenance.md#run-incomplete-database-migrations)。

- 升级到极狐GitLab 15.10 或更高版本时，您也可能会遇到以下错误：

  ```shell
  "exception.class": "ActiveRecord::StatementInvalid",
  "exception.message": "PG::SyntaxError: ERROR:  zero-length delimited identifier at or near \"\"\"\"\nLINE 1: ...COALESCE(\"lock_version\", 0) + 1 WHERE \"ci_builds\".\"\" IN (SEL...\n
  ```

  此错误是由于 [极狐GitLab 14.9 中引入的批量后台迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/81410) 在升级到极狐GitLab 15.10 或更高版本之前未能完成所致。要解决此错误，可以安全地 [将该迁移标记为已完成](../background_migrations.md#mark-a-failed-migration-finished)：

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

  更多信息，请参阅 [问题 415724](https://gitlab.com/gitlab-org/gitlab/-/issues/415724)。

- [Terraform 配置的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/348453) 导致即使 `gitlab.rb` 配置文件中将 `gitlab_rails['terraform_state_enabled']` 设置为 `false`，Terraform 状态仍保持启用状态。由于此错误已在极狐GitLab 15.10 中修复，如果 `gitlab.rb` 配置中禁用了 [Terraform 状态](../../administration/terraform_state.md) 功能，升级到极狐GitLab 15.10 可能会破坏使用该功能的项目。
  如果您在 `gitlab.rb` 中配置了 `gitlab_rails['terraform_state_enabled'] = false`，请检查是否有项目正在使用 Terraform 状态功能。要检查：
  1. 阅读 [Rails 控制台](../../administration/operations/rails_console.md) 警告。
  1. 启动 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。
  1. 运行命令 `Terraform::State.pluck(:project_id)`。此命令返回一个包含所有拥有 Terraform 状态的项目 ID 的数组。
  1. 导航到每个项目，并根据需要与相关方合作，以确定 Terraform 状态功能是否正在被积极使用。如果不再需要 Terraform 状态，您可以按照 [移除状态文件](../../user/infrastructure/iac/terraform_state.md#remove-a-state-file) 的步骤进行操作。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将捆绑的 PostgreSQL 数据库升级到版本 13。请参阅
  [详细信息和解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 从次要站点克隆 LFS 对象时，即使次要站点已完全同步，仍会从主站点下载。请参阅 [详细信息和解决方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.9.0"></a>

## 15.9.0

- [Elastic Indexer Cron Worker 的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/408214) 可能导致 Sidekiq 饱和。
  - 当此问题发生时，合并请求的合并、流水线、Slack 通知和其他事件不会被创建，或者需要很长时间才能发生。
  - 此问题可能不会立即显现，因为它可能需要长达一周的时间才能使 Sidekiq 达到足够饱和。
  - 即使未启用 Elasticsearch，也会发生此问题。
  - 要解决此问题，请升级到 15.11 或使用问题中的解决方法。
- [`BackfillTraversalIdsToBlobsAndWikiBlobs` 高级搜索迁移的一个错误](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107730) 可能导致 Elasticsearch 集群变得饱和。
  - 当此问题发生时，搜索可能会变慢，并且对 Elasticsearch 集群的更新可能需要很长时间才能完成。
  - 要解决此问题，请升级到极狐GitLab 15.10 以 [减少迁移批次大小](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/113719)。
- **升级到补丁版本 15.9.3 或更高版本**。这提供了两个数据库迁移错误的修复：
  - 补丁版本 15.9.0、15.9.1、15.9.2 存在一个可能导致用户资料字段 `linkedin`、`twitter`、`skype`、`website_url`、`location` 和 `organization` 数据丢失的错误。更多信息，请参阅 [问题 393216](https://gitlab.com/gitlab-org/gitlab/-/issues/393216)。
  - 第二个 [错误修复](https://gitlab.com/gitlab-org/gitlab/-/issues/394760) 确保可以直接从 15.4.x 升级。
- 作为 [CI 分区工作](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/ci_data_decay/pipeline_partitioning/) 的一部分，一个新的 [外键](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/107547) 被添加到 `ci_builds_needs`。在具有大型 CI 表的极狐GitLab 实例上，添加此约束可能需要比平时更长的时间。
- Praefect 的元数据验证器 [无效元数据删除行为](../../administration/gitaly/praefect/configure.md#enable-deletions) 现在默认启用。

  元数据验证器处理 Praefect 数据库中的副本记录，并验证副本是否实际存在于 Gitaly 节点上。如果副本不存在，其元数据记录将被删除。这使得 Praefect 能够修复副本元数据记录显示正常但实际上在磁盘上不存在的情况。
  元数据记录被删除后，Praefect 的协调器会调度复制任务来重新创建该副本。

  由于状态管理逻辑的过往问题，数据库中可能存在无效的元数据记录。例如，这可能由于代码仓删除不完整或重命名部分完成而产生。验证器会删除受影响代码仓的这些过时副本记录。由于副本记录被移除，这些代码仓可能会在指标和 `praefect dataloss` 子命令中显示为不可用代码仓。如果遇到此类代码仓，请使用 `praefect remove-repository` 移除该代码仓的剩余记录。

  您可以在极狐GitLab 15.0 及更高版本中，通过搜索验证器输出的日志记录来提前找到具有无效元数据记录的代码仓。[阅读更多关于代码仓验证的信息，并查看示例日志条目](../../administration/gitaly/praefect/configure.md#repository-verification)。
- 对于 Linux 软件包实例，Praefect 配置在极狐GitLab 16.0 中发生了显著变化。您可以从极狐GitLab 15.9 开始迁移到新结构，同时保持向后兼容性，直至极狐GitLab 16.0。[阅读更多关于此变更的信息](gitlab_16_changes.md#praefect-configuration-structure-change)。

### 自编译安装

- 对于**自编译（源代码）安装**，随着 `gitlab-sshd` 的加入，需要 Kerberos 头文件来构建极狐GitLab Shell。

  ```shell
  sudo apt install libkrb5-dev
  ```

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将捆绑的 PostgreSQL 数据库升级到版本 13。请参阅
  [详细信息和解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 从次要站点克隆 LFS 对象时，即使次要站点已完全同步，仍会从主站点下载。请参阅 [详细信息和解决方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.8.2"></a>

## 15.8.2

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上进度](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您在验证中看到某些项目或 Wiki 持续处于“排队”状态，您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本: 极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本: 极狐GitLab 15.8.3 及更高版本。

<a id="15.8.1"></a>

## 15.8.1

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中有一个或多个 Git 代码仓 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 代码仓的 [代码仓检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都将停止运行。该错误已通过 [在极狐GitLab 15.9.0 中回退更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓。更多信息，请参阅 [该错误问题](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上进度](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您在验证中看到某些项目或 Wiki 持续处于“排队”状态，您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本: 极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本: 极狐GitLab 15.8.3 及更高版本。

<a id="15.8.0"></a>

## 15.8.0

- Gitaly 需要 Git 2.38.0 及更高版本。对于自编译安装，您应使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中有一个或多个 Git 代码仓 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 代码仓的 [代码仓检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都将停止运行。该错误已通过 [在极狐GitLab 15.9.0 中回退更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓。更多信息，请参阅 [该错误问题](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将捆绑的 PostgreSQL 数据库升级到版本 13。请参阅
  [详细信息和解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 我们发现一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上进度](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您在验证中看到某些项目或 Wiki 持续处于“排队”状态，您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本: 极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本: 极狐GitLab 15.8.3 及更高版本。
- 从次要站点克隆 LFS 对象时，即使次要站点已完全同步，仍会从主站点下载。请参阅 [详细信息和解决方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.7.6"></a>

## 15.7.6

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中有一个或多个 Git 代码仓 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 代码仓的 [代码仓检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都将停止运行。该错误已通过 [在极狐GitLab 15.9.0 中回退更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓。更多信息，请参阅 [该错误问题](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上进度](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您在验证中看到某些项目或 Wiki 持续处于“排队”状态，您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本: 极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本: 极狐GitLab 15.8.3 及更高版本。

<a id="15.7.5"></a>

## 15.7.5

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中有一个或多个 Git 代码仓 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 代码仓的 [代码仓检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都将停止运行。该错误已通过 [在极狐GitLab 15.9.0 中回退更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓。更多信息，请参阅 [该错误问题](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上进度](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您在验证中看到某些项目或 Wiki 持续处于“排队”状态，您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本: 极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本: 极狐GitLab 15.8.3 及更高版本。

<a id="15.7.4"></a>

## 15.7.4

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中有一个或多个 Git 代码仓 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 代码仓的 [代码仓检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都将停止运行。该错误已通过 [在极狐GitLab 15.9.0 中回退更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查您是否有任何“不可用”的代码仓。更多信息，请参阅 [该错误问题](https://gitlab.com/gitlab-org/gitlab/-/issues/390155)。

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上进度](https://gitlab.com/gitlab-org/gitlab/-/issues/387980)。如果您在验证中看到某些项目或 Wiki 持续处于“排队”状态，您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本: 极狐GitLab 版本 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本: 极狐GitLab 15.8.3 及更高版本。

<a id="15.7.3"></a>

## 15.7.3
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="geo-installations"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="15.7.2"></a>

## 15.7.2

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="geo-installations-1"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="15.7.1"></a>

## 15.7.1

- Linux 软件包 (Omnibus) 中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md)可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在错误。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，您可以将通配符域移至列表末尾，或升级到[修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="geo-installations-2"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="15.7.0"></a>

## 15.7.0

- 此版本验证了 `issues.work_item_type_id` 列上的 `NOT NULL DB` 约束。要升级到此版本，`issues` 表中不应存在 `work_item_type_id` 为 `NULL` 的记录。有多个 `BackfillWorkItemTypeIdForIssues` 后台迁移，将通过 `EnsureWorkItemTypeBackfillMigrationFinished` 部署后迁移完成。
- 极狐GitLab 15.4.0 引入了一个[批量后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于[回填 `issues` 表上的 `namespace_id` 值](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/91921)。在较大的极狐GitLab 实例上，此迁移可能需要数小时或数天才能完成。在升级到 15.7.0 之前，请确保迁移已成功完成。
- 添加了一个数据库约束，指定 `issues` 表上的 `namespace_id` 列没有 `NULL` 值。

  - 如果来自 15.4 的 `namespace_id` 批量后台迁移失败（请参阅上一项），则 15.7 升级将因数据库迁移错误而失败。

  - 在具有大型 `issues` 表的极狐GitLab 实例上，验证此约束会导致升级时间比平时更长。所有数据库更改需要在一小时内完成：

    ```plaintext
    致命：Mixlib::ShellOut::CommandTimeout: rails_migration[gitlab-rails]
    [..]
    Mixlib::ShellOut::CommandTimeout: 命令在 3600 秒后超时：
    ```

    存在一种解决方法，可以[手动完成数据更改和升级](../package/package_troubleshooting.md#error-command-timed-out-after-3600s)。
- 默认的 Sidekiq `max_concurrency` 已更改为 20。现在，这在我们的文档和产品默认值中是一致的。

  例如，以前：

  - Linux 软件包安装默认值 (`sidekiq['max_concurrency']`)：50
  - 自编译安装默认值：50
  - Helm chart 默认值 (`gitlab.sidekiq.concurrency`)：25

  参考架构仍然使用默认值 10，因为这是专门为这些配置设置的。

  已配置 `max_concurrency` 的站点不会受此更改影响。
  [阅读有关 Sidekiq 并发设置的更多信息](../../administration/sidekiq/extra_sidekiq_processes.md#concurrency)。
- 极狐GitLab Runner 15.7.0 引入了一个影响 CI/CD 作业的破坏性变更：[正确处理作业文件变量的扩展](https://jihulab.com/gitlab-cn/gitlab-runner/-/merge_requests/3613)。以前，引用[文件类型变量](../../ci/variables/_index.md#use-file-type-cicd-variables)的作业定义变量会扩展为文件变量的值（其内容）。此行为不符合 shell 变量扩展的典型规则。如果文件变量及其内容被打印出来，也存在密钥或敏感信息泄露的可能性。例如，如果它们在 echo 输出中打印出来。有关更多信息，请参阅[了解极狐GitLab 15.7 中的文件类型变量扩展变更](https://gitlab.cn/blog/impact-of-the-file-type-variable-change-15-7/)。
- Linux 软件包 (Omnibus) 中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md)可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在错误。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，您可以将通配符域移至列表末尾，或升级到[修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。
- 即使辅助站点已完全同步，从辅助站点克隆 LFS 对象仍会从主站点下载。请参阅[详细信息和解决方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="geo-installations-3"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将捆绑的 PostgreSQL 数据库升级到版本 13。请参阅[详细信息和解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="15.6.7"></a>

## 15.6.7

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="geo-installations-4"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="15.6.6"></a>

## 15.6.6

- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="geo-installations-5"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。

<a id="15.6.5"></a>

## 15.6.5

<a id="geo-installations-6"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.6.4"></a>

## 15.6.4

<a id="geo-installations-7"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.6.3"></a>

## 15.6.3

<a id="geo-installations-8"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝](https://jihulab.com/gitlab-cn/gitlab/-/issues/386389)，导致 Geo 辅助站点无法感知容器镜像仓库镜像的更新，进而无法复制更新。因此，故障转移后辅助站点可能包含过时的容器镜像。这会影响 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您将 Geo 与容器仓库一起使用，建议升级到包含此问题修复的极狐GitLab 15.6.7、15.7.3 或 15.8.0，以避免故障转移后潜在的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制和验证跟不上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果您看到某些项目或 Wiki 在验证时持续处于“排队”状态，则您的安装可能会受到影响。这可能导致故障转移后数据丢失。
  - 受影响的版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- Linux 软件包 (Omnibus) 中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md)可能无法正常工作，原因是极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122)存在错误。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，您可以将通配符域移至列表末尾，或升级到[修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群 (Praefect) 中的一个或多个 Git 仓库[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响的 Gitaly 集群 (Praefect) 中的所有项目或项目 Wiki 仓库的[仓库检查](../../administration/repository_checks.md)和 [Geo 复制和验证](../../administration/geo/_index.md)将停止运行。该错误已通过[在极狐GitLab 15.9.0 中还原更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823)修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅[错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.6.2"></a>

## 15.6.2

<a id="geo-installations-9"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}
- 容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝，导致 Geo 辅助站点无法感知容器镜像仓库的更新，从而无法复制这些更新。因此，在故障转移后，辅助站点可能包含过时的容器镜像。这影响了 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您正在使用带有容器代码仓的 Geo，建议升级到 极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，并可以避免故障转移后可能的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能会受到影响。这可能导致故障转移后的数据丢失。
  - 受影响版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.6.1"></a>

## 15.6.1

<a id="geo-installations-15.6.1"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- 容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝，导致 Geo 辅助站点无法感知容器镜像仓库的更新，从而无法复制这些更新。因此，在故障转移后，辅助站点可能包含过时的容器镜像。这影响了 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您正在使用带有容器代码仓的 Geo，建议升级到 极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，并可以避免故障转移后可能的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能会受到影响。这可能导致故障转移后的数据丢失。
  - 受影响版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.6.0"></a>

## 15.6.0

- 您应该使用 [官方支持的 PostgreSQL 版本](../../administration/package_information/postgresql_versions.md) 之一。某些数据库迁移可能会导致较旧 PostgreSQL 版本出现稳定性和性能问题。
- Gitaly 需要 Git 2.37.0 或更高版本。对于自编译安装，您应该使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- 一个用于修改四个索引行为的数据库更改，在不存在这些索引的实例上会失败：

  ```plaintext
  引起：
  PG::UndefinedTable: 错误：关系 "index_issues_on_title_trigram" 不存在
  ```

  其他三个索引是：`index_merge_requests_on_title_trigram`、`index_merge_requests_on_description_trigram` 和 `index_issues_on_description_trigram`。

  此问题已 [在 极狐GitLab 15.7 中修复](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/105375)，并已向后移植到 极狐GitLab 15.6.2。该问题也可以绕过：[了解如何创建这些索引](https://jihulab.com/gitlab-cn/gitlab/-/issues/378343#note_1199863087)。

<a id="linux-package-installations"></a>

### Linux 软件包安装

在 极狐GitLab 15.6 中，[`omnibus-gitlab` 软件包附带的 PostgreSQL 版本](../../administration/package_information/postgresql_versions.md) 已升级至 12.12 和 13.8。除非 [明确选择退出](https://gitlab.cn/docs/omnibus/settings/database/#automatic-restart-when-the-postgresql-version-changes)，否则这可能导致 PostgreSQL 服务自动重启，并可能造成停机。

<a id="geo-installations-15.6.0"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将捆绑的 PostreSQL 数据库升级到版本 13。请参阅 [详细信息及解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 容器镜像仓库推送事件被 `/api/v4/container_registry_event/events` 端点拒绝，导致 Geo 辅助站点无法感知容器镜像仓库的更新，从而无法复制这些更新。因此，在故障转移后，辅助站点可能包含过时的容器镜像。这影响了 15.6.0 - 15.6.6 和 15.7.0 - 15.7.2 版本。如果您正在使用带有容器代码仓的 Geo，建议升级到 极狐GitLab 15.6.7、15.7.3 或 15.8.0，这些版本包含此问题的修复，并可以避免故障转移后可能的数据丢失。
- 我们发现了一个问题，在少数 Geo 安装中，[项目和 Wiki 的复制与验证未能跟上](https://jihulab.com/gitlab-cn/gitlab/-/issues/387980)。如果看到某些项目或 Wiki 持续处于“排队”验证状态，您的安装可能会受到影响。这可能导致故障转移后的数据丢失。
  - 受影响版本：极狐GitLab 15.6.x、15.7.x 和 15.8.0 - 15.8.2。
  - 包含修复的版本：极狐GitLab 15.8.3 及更高版本。
- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。
- 从辅助站点克隆 LFS 对象时，即使辅助站点已完全同步，仍会从主站点下载。请参阅 [详细信息及解决方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.5.5"></a>

## 15.5.5

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.5.4"></a>

## 15.5.4

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.5.3"></a>

## 15.5.3

- 极狐GitLab 15.4.0 引入了一条默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用 [队列选择器](https://archives.gitlab.cn/docs/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated) 的实例，这会导致 [性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为某些 Sidekiq 进程将处于空闲状态。
  - 该默认路由规则已在 15.5.4 中回滚，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果 极狐GitLab 实例现在只监听 `default` 队列（目前不推荐），则需要在 `/etc/gitlab/gitlab.rb` 中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.5.2"></a>

## 15.5.2

- 极狐GitLab 15.4.0 引入了一条默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用 [队列选择器](https://archives.gitlab.cn/docs/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated) 的实例，这会导致 [性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为某些 Sidekiq 进程将处于空闲状态。
  - 该默认路由规则已在 15.5.4 中回滚，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果 极狐GitLab 实例现在只监听 `default` 队列（目前不推荐），则需要在 `/etc/gitlab/gitlab.rb` 中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.5.1"></a>

## 15.5.1

- 极狐GitLab 15.4.0 引入了一条默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用 [队列选择器](https://archives.gitlab.cn/docs/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated) 的实例，这会导致 [性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为某些 Sidekiq 进程将处于空闲状态。
  - 该默认路由规则已在 15.5.4 中回滚，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果 极狐GitLab 实例现在只监听 `default` 队列（目前不推荐），则需要在 `/etc/gitlab/gitlab.rb` 中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.5.0"></a>

## 15.5.0

- 极狐GitLab 15.4.0 引入了一条默认的 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由到 `default` 队列。对于使用 [队列选择器](https://archives.gitlab.cn/docs/17.0/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated) 的实例，这会导致 [性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，因为某些 Sidekiq 进程将处于空闲状态。
  - 该默认路由规则已在 15.5.4 中回滚，因此升级到该版本或更高版本将恢复之前的行为。
  - 如果 极狐GitLab 实例现在只监听 `default` 队列（目前不推荐），则需要在 `/etc/gitlab/gitlab.rb` 中重新添加此路由规则：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="geo-installations-15.5.0"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将捆绑的 PostreSQL 数据库升级到版本 13。请参阅 [详细信息及解决方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 从辅助站点克隆 LFS 对象时，即使辅助站点已完全同步，仍会从主站点下载。请参阅 [详细信息及解决方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.4.6"></a>

## 15.4.6

- 由于 极狐GitLab 15.4.6 中包含的 [cURL 版本](https://github.com/curl/curl/issues/10122) 存在错误，Linux 软件包（Omnibus）中的 `no_proxy` [自定义环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.md) 可能无法正常工作。此问题导致除 `no_proxy` 变量中列出的最后一个通配符域外，所有通配符域（如 `.example.com`）均被忽略。要解决此问题，可以将通配符域移至列表末尾，或升级到 [修复了 cURL 的更高版本](https://gitlab.cn/releases/2023/01/09/security-release-gitlab-15-7-2-released/)。
- 由于 [极狐GitLab 15.4 中引入的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中的一个或多个 Git 仓库 [不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)，那么受影响 Gitaly 集群（Praefect）中所有项目或项目 Wiki 仓库的 [仓库检查](../../administration/repository_checks.md) 和 [Geo 复制与验证](../../administration/geo/_index.md) 都会停止运行。该错误已通过 [在 极狐GitLab 15.9.0 中回滚更改](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 修复。在升级到此版本之前，请检查是否有任何“不可用”的仓库。有关更多信息，请参阅 [错误议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.4.5"></a>

## 15.4.5
<a id="15.4.4"></a>

## 15.4.4

- 由于 [极狐GitLab 15.4 中引入的一个 bug](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中有一个或多个 Git 仓库存为[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)状态，则受影响 Gitaly 集群（Praefect）中的所有项目或项目 Wiki 代码仓的[代码仓检查](../../administration/repository_checks.md)以及 [Geo 复制与验证](../../administration/geo/_index.md)都将停止运行。该 bug 已通过在 [极狐GitLab 15.9.0 中回滚变更](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查是否存在“不可用”的代码仓库。更多信息请参见 [该 bug 议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.4.3"></a>

## 15.4.3

- 由于 [极狐GitLab 15.4 中引入的一个 bug](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中有一个或多个 Git 代码仓库为[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)状态，则受影响 Gitaly 集群（Praefect）中的所有项目或项目 Wiki 代码仓的[代码仓检查](../../administration/repository_checks.md)以及 [Geo 复制与验证](../../administration/geo/_index.md)都将停止运行。该 bug 已通过在 [极狐GitLab 15.9.0 中回滚变更](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查是否存在“不可用”的代码仓库。更多信息请参见 [该 bug 议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.4.2"></a>

## 15.4.2

- 一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：
  - 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
  - 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
    - 15.2.5 → 15.3.5
    - 15.3.0 - 15.3.4 → 15.3.5
    - 15.4.1 → 15.4.3
- 由于 [极狐GitLab 15.4 中引入的一个 bug](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中有一个或多个 Git 代码仓库为[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)状态，则受影响 Gitaly 集群（Praefect）中的所有项目或项目 Wiki 代码仓的[代码仓检查](../../administration/repository_checks.md)以及 [Geo 复制与验证](../../administration/geo/_index.md)都将停止运行。该 bug 已通过在 [极狐GitLab 15.9.0 中回滚变更](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查是否存在“不可用”的代码仓库。更多信息请参见 [该 bug 议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.4.1"></a>

## 15.4.1

- 一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：
  - 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
  - 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
    - 15.2.5 → 15.3.5
    - 15.3.0 - 15.3.4 → 15.3.5
    - 15.4.1 → 15.4.3
- 由于 [极狐GitLab 15.4 中引入的一个 bug](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中有一个或多个 Git 代码仓库为[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)状态，则受影响 Gitaly 集群（Praefect）中的所有项目或项目 Wiki 代码仓的[代码仓检查](../../administration/repository_checks.md)以及 [Geo 复制与验证](../../administration/geo/_index.md)都将停止运行。该 bug 已通过在 [极狐GitLab 15.9.0 中回滚变更](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查是否存在“不可用”的代码仓库。更多信息请参见 [该 bug 议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。

<a id="15.4.0"></a>

## 15.4.0

- 极狐GitLab 15.4.0 包含一个[批处理后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于[移除 `ci_job_artifacts` 表中 `expire_at` 的不正确值](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/89318)。此迁移在大型极狐GitLab 实例上可能需要数小时甚至数天才能完成。
- 默认情况下，Gitaly 和 Praefect 节点使用 `pool.ntp.org` 的时间服务器。如果您的实例无法连接到 `pool.ntp.org`，请[配置 `NTP_HOST` 变量](../../administration/gitaly/praefect/configure.md#customize-time-server-setting)，否则日志中可能出现 `ntp: read udp ... i/o timeout` 错误，且 `gitlab-rake gitlab:gitaly:check` 的输出也可能报错。不过，如果 Gitaly 主机的时间已同步，这些错误可以忽略。
- 极狐GitLab 15.4.0 引入了一条默认 [Sidekiq 路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，将所有作业路由至 `default` 队列。对于使用[队列选择器](https://gitlab.cn/docs/ee/administration/sidekiq/processing_specific_job_classes.html#queue-selectors-deprecated)的实例，这会导致[性能问题](https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1991)，部分 Sidekiq 进程会处于空闲状态。
  - 该默认路由规则已在 15.4.5 中回滚，因此升级至该版本或更高版本将恢复之前的行为。
  - 如果极狐GitLab 实例现在仅监听 `default` 队列（当前不推荐），则需要将以下路由规则添加回 `/etc/gitlab/gitlab.rb`：

    ```ruby
    sidekiq['routing_rules'] = [['*', 'default']]
    ```

- `/etc/gitlab/gitlab-secrets.json` 的结构已在 [极狐GitLab 15.4](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/merge_requests/6310) 中修改，并在 `gitlab_pages`、`grafana` 和 `mattermost` 部分添加了新配置。在高可用或极狐GitLab Geo 环境中，所有节点上的密钥必须保持一致。如果您正在手动跨节点同步密钥文件，或在 `/etc/gitlab/gitlab.rb` 中手动指定密钥，请确保所有节点上的 `/etc/gitlab/gitlab-secrets.json` 完全相同。
- 极狐GitLab 15.4.0 引入了一个[批处理后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于[回填议题表上的 `namespace_id` 值](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/91921)。此迁移在大型极狐GitLab 实例上可能需要数小时甚至数天才能完成。在升级到 15.7.0 或更高版本之前，请确保迁移已成功完成。
- 由于 [极狐GitLab 15.4 中引入的一个 bug](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)，如果 Gitaly 集群（Praefect）中有一个或多个 Git 代码仓库为[不可用](../../administration/gitaly/praefect/recovery.md#unavailable-repositories)状态，则受影响 Gitaly 集群（Praefect）中的所有项目或项目 Wiki 代码仓的[代码仓检查](../../administration/repository_checks.md)以及 [Geo 复制与验证](../../administration/geo/_index.md)都将停止运行。该 bug 已通过在 [极狐GitLab 15.9.0 中回滚变更](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/110823) 得到修复。在升级到此版本之前，请检查是否存在“不可用”的代码仓库。更多信息请参见 [该 bug 议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390155)。
- 重新设计的登录页面在极狐GitLab 15.4 及更高版本中默认启用，并在后续版本中持续改进。更多信息请参见 [史诗 8557](https://jihulab.com/groups/gitlab-cn/-/epics/8557)。可以通过功能标志禁用该页面。启动 [Rails 控制台](../../administration/operations/rails_console.md) 并运行：

  ```ruby
  Feature.disable(:restyle_login_page)
  ```

<a id="geo-installations"></a>

### Geo 环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置 PostgreSQL 数据库升级至版本 13。详见[详情和应对方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- 从辅助节点克隆 LFS 对象时仍会从主节点下载，即使辅助节点已完全同步。详见[详情和应对方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.3.4"></a>

## 15.3.4

一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：

- 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
- 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
  - 15.2.5 → 15.3.5
  - 15.3.0 - 15.3.4 → 15.3.5
  - 15.4.1 → 15.4.3

<a id="15.3.3"></a>

## 15.3.3

- 在极狐GitLab 15.3.3 中，[SAML 群组链接](../../api/saml.md#saml-group-links) API 的 `access_level` 属性类型已更改为 `integer`。请参阅 [API 文档](../../api/group_members.md)。
- 一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：

  - 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
  - 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
    - 15.2.5 → 15.3.5
    - 15.3.0 - 15.3.4 → 15.3.5
    - 15.4.1 → 15.4.3

<a id="15.3.2"></a>

## 15.3.2

一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：

- 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
- 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
  - 15.2.5 → 15.3.5
  - 15.3.0 - 15.3.4 → 15.3.5
  - 15.4.1 → 15.4.3

<a id="15.3.1"></a>

## 15.3.1

一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：

- 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
- 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
  - 15.2.5 → 15.3.5
  - 15.3.0 - 15.3.4 → 15.3.5
  - 15.4.1 → 15.4.3

<a id="15.3.0"></a>

## 15.3.0

- 在 Gitaly 集群（Praefect）中新建的 Git 代码仓库不再使用 `@hashed` 存储路径。新仓库的服务器钩子必须复制到其他位置。Praefect 现在会生成副本路径供 Gitaly 集群使用。此变更是 Gitaly 集群（Praefect）原子化创建、删除和重命名 Git 代码仓库的先决条件。

  要确定副本路径，请[查询 Praefect 仓库元数据](../../administration/gitaly/praefect/troubleshooting.md#view-repository-metadata)并将 `@hashed` 存储路径传递给 `-relative-path`。

  据此信息，您可以正确安装[服务器钩子](../../administration/server_hooks.md)。

- 一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：

  - 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
  - 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
    - 15.2.5 → 15.3.5
    - 15.3.0 - 15.3.4 → 15.3.5
    - 15.4.1 → 15.4.3

<a id="geo-installations-1"></a>

### Geo 环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置 PostgreSQL 数据库升级至版本 13。详见[详情和应对方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- LFS 传输可能在会话中从辅助节点重定向至主节点。详见[详情和应对方法](#lfs-transfers-redirect-to-primary-from-secondary-site-mid-session)。
- 辅助节点上的对象存储 LFS 文件可能被错误删除。详见[详情和应对方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。

<a id="lfs-transfers-redirect-to-primary-from-secondary-site-mid-session"></a>

#### LFS 传输可能在会话中从辅助节点重定向至主节点

| 受影响的小版本 | 受影响的补丁版本 | 修复版本 |
|-------------------------|-------------------------|----------|
| 15.1                    | 全部                     | 无     |
| 15.2                    | 全部                     | 无     |
| 15.3                    | 15.3.0 - 15.3.2         | 15.3.3 及更高版本 |

在启用 [Geo 代理](../../administration/geo/secondary_proxy/_index.md) 的情况下，极狐GitLab 15.1.0 至 15.3.2 中，LFS 传输可能[在会话中从辅助节点重定向至主节点](https://jihulab.com/gitlab-cn/gitlab/-/issues/371571)，导致拉取和克隆请求失败。Geo 代理在极狐GitLab 15.1 及更高版本中默认启用。

此问题已在极狐GitLab 15.3.3 中解决，因此具有以下配置的客户应升级至 15.3.3 或更高版本：

- LFS 已启用。
- LFS 对象正在各 Geo 节点间复制。
- 代码仓库通过 Geo 辅助节点拉取。
- 从辅助节点克隆 LFS 对象时仍会从主节点下载，即使辅助节点已完全同步。详见[详情和应对方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="incorrect-object-storage-lfs-file-deletion-on-secondary-sites"></a>

#### 辅助节点上对象存储 LFS 文件的错误删除

| 受影响的小版本 | 受影响的补丁版本 | 修复版本 |
|-------------------------|-------------------------|----------|
| 15.0                    | 全部                     | 无     |
| 15.1                    | 全部                     | 无     |
| 15.2                    | 全部                     | 无     |
| 15.3                    | 15.3.0 - 15.3.2         | 15.3.3 及更高版本 |

在 GitLab 15.0.0 至 15.3.2 中，以下情况可能发生[辅助节点上对象存储文件的错误删除](https://jihulab.com/gitlab-cn/gitlab/-/issues/371397)：

- 已禁用极狐GitLab 管理的对象存储复制，并在导入启用了对象存储的项目时创建了 LFS 对象。
- 先启用了极狐GitLab 管理的对象存储同步复制，随后又将其禁用。

此问题已在 15.3.3 中解决。同时启用了 LFS 且 LFS 对象在各 Geo 节点间复制的客户，应直接升级至 15.3.3，以降低辅助节点数据丢失的风险。

<a id="15.2.5"></a>

## 15.2.5

一个[许可证缓存问题](https://jihulab.com/gitlab-cn/gitlab/-/issues/376706) 会导致极狐GitLab 部分专业版功能在添加新许可证后无法正常工作。此问题的应对方法：

- 在应用新许可证后重启所有 Rails、Sidekiq 和 Gitaly 节点。这会清除相关许可证缓存，使所有专业版功能恢复正常。
- 升级至不受此问题影响的版本。以下升级路径适用于受影响的版本：
  - 15.2.5 → 15.3.5
  - 15.3.0 - 15.3.4 → 15.3.5
  - 15.4.1 → 15.4.3

<a id="15.2.0"></a>

## 15.2.0

- 拥有多个 Web 节点的极狐GitLab 实例应先[升级至 15.1](#1510)，然后再升级至 15.2（及更高版本），因为 Rails 中的配置变更可能导致 ETag 键生成不一致。
- 此版本中部分 Sidekiq 工作器已重命名。为避免中断，在开始升级至极狐GitLab 15.2.0 之前，请[运行 Rake 任务迁移所有待处理作业](../../administration/sidekiq/sidekiq_job_migration.md#migrate-queued-and-future-jobs)。
- Gitaly 现在在一个[运行目录](https://jihulab.com/gitlab-cn/gitaly/-/merge_requests/4670)中执行其二进制文件。在 Linux 软件包实例上，默认路径为 `/var/opt/gitlab/gitaly/run/`。如果此挂载点设置了 `noexec`，合并请求会产生以下错误：

  ```plaintext
  fork/exec /var/opt/gitlab/gitaly/run/gitaly-<nnnn>/gitaly-git2go-v15: permission denied
  ```

  要解决此问题，请从文件系统挂载中移除 `noexec` 选项。另一种方法是更改 Gitaly 运行目录：

  1. 将 `gitaly['runtime_dir'] = '<有执行权限的路径>'` 添加到 `/etc/gitlab/gitlab.rb` 并指定未设置 `noexec` 的位置。
  1. 运行 `sudo gitlab-ctl reconfigure`。

<a id="geo-installations-2"></a>

### Geo 环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- `pg_upgrade` 无法将内置 PostgreSQL 数据库升级至版本 13。详见[详情和应对方法](#pg_upgrade-fails-to-upgrade-the-bundled-postregsql-database-to-version-13)。
- LFS 传输可能在会话中从辅助节点重定向至主节点。详见[详情和应对方法](#lfs-transfers-redirect-to-primary-from-secondary-site-mid-session)。
- 辅助节点上的对象存储 LFS 文件可能被错误删除。详见[详情和应对方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。
- 从辅助节点克隆 LFS 对象时仍会从主节点下载，即使辅助节点已完全同步。详见[详情和应对方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.1.0"></a>

## 15.1.0

- 在极狐GitLab 15.1.0 中，我们将 Rails `ActiveSupport::Digest` 切换为使用 SHA256 而非 MD5。这会影响原始 Snippet 文件下载等资源的 ETag 键生成。为确保升级时多个 Web 节点间 ETag 键生成一致，所有服务器必须先升级至 15.1.6，然后再升级至 15.2.0 或更高版本：

  1. 确保所有极狐GitLab Web 节点均运行极狐GitLab 15.1.6。
  1. 如果您在 Kubernetes 上通过云原生极狐GitLab Helm Chart 运行[极狐GitLab](https://gitlab.cn/docs/charts/installation/)，请确保所有 Webservice Pod 均运行极狐GitLab 15.1.Z：

     ```shell
     kubectl get pods -l app=webservice -o custom-columns=webservice-image:{.spec.containers[0].image},workhorse-image:{.spec.containers[1].image}
     ```

  1. [启用 `active_support_hash_digest_sha256` 功能标志](../../administration/feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags)，以将 `ActiveSupport::Digest` 切换为使用 SHA256：

     1. [启动 Rails 控制台](../../administration/operations/rails_console.md)
     1. 启用功能标志：

        ```ruby
        Feature.enable(:active_support_hash_digest_sha256)
        ```

  1. 然后，继续升级至更高版本的极狐GitLab。
- 不再支持对 [`ciConfig` GraphQL 字段](../../api/graphql/reference/_index.md#queryciconfig)的未认证请求。在升级至极狐GitLab 15.1 之前，请为您的请求添加[访问令牌](../../api/rest/authentication.md)。创建令牌的用户必须具有在该项目中[创建流水线的权限](../../user/permissions.md)。

<a id="geo-installations-3"></a>

### Geo 环境

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- [Geo 代理](../../administration/geo/secondary_proxy/_index.md) 在 15.1 中[默认针对不同 URL 启用](https://jihulab.com/gitlab-cn/gitlab/-/issues/346112)。这可能是一个重大变更。如有需要，您可以[禁用 Geo 代理](../../administration/geo/secondary_proxy/_index.md#disable-secondary-site-http-proxying)。如果您使用 SAML 且 URL 不同，则必须修改 SAML 配置和身份提供方配置。更多信息请参见 [Geo 与单点登录 (SSO) 文档](../../administration/geo/replication/single_sign_on.md)。
- LFS 传输可能在会话中从辅助节点重定向至主节点。详见[详情和应对方法](#lfs-transfers-redirect-to-primary-from-secondary-site-mid-session)。
- 辅助节点上的对象存储 LFS 文件可能被错误删除。详见[详情和应对方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。
- 从辅助节点克隆 LFS 对象时仍会从主节点下载，即使辅助节点已完全同步。详见[详情和应对方法](gitlab_16_changes.md#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="15.0.0"></a>

## 15.0.0

- Elasticsearch 6.8 [不再支持](../../integration/advanced_search/elasticsearch.md#version-compatibility)。在升级至极狐GitLab 15.0 之前，请[将 Elasticsearch 升级至任意 7.x 版本](../../integration/advanced_search/elasticsearch.md#upgrade-to-a-new-elasticsearch-version)。
- 如果您在外部 PostgreSQL（尤其是 AWS RDS）上运行极狐GitLab，请在升级至极狐GitLab 14.8 或更高版本之前，确保将 PostgreSQL 补丁级别升级至最低 12.7 或 13.3。

  在极狐GitLab 旗舰版的 [14.8](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/75511) 和基础版的 [15.0](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/87983) 中，一项名为松散外键的极狐GitLab 功能被启用。

  启用后，我们收到了因数据库引擎 bug 导致段错误，进而引发计划外 PostgreSQL 重启的报告。

  更多信息请参见 [议题 364763](https://jihulab.com/gitlab-cn/gitlab/-/issues/364763)。

- 在[移除对 `background_upload` 的支持](../deprecations.md#background-upload-for-object-storage)后，不再支持使用存储特定配置的加密 S3 存储桶。
- [基于证书的 Kubernetes 集成（已弃用）](../../user/infrastructure/clusters/_index.md#certificate-based-kubernetes-integration-deprecated) 默认禁用，但您可以在极狐GitLab 16.0 之前通过 [`certificate_based_clusters` 功能标志](../../administration/feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags) 重新启用。
- 当您使用自定义 `serviceAccount` 的极狐GitLab Helm Chart 项目时，请确保其具有对 `serviceAccount` 和 `secret` 资源的 `get` 和 `list` 权限。
- `FF_GITLAB_REGISTRY_HELPER_IMAGE` [功能标志](../../administration/feature_flags/_index.md#enable-or-disable-the-feature) 已被移除，辅助镜像将始终从极狐GitLab 镜像仓库拉取。

<a id="linux-package-installations"></a>

### Linux 软件包安装


- [`custom_hooks_dir`](../../administration/server_hooks.md#create-global-server-hooks-for-all-repositories) 设置用于配置全局服务器钩子，现在在 Gitaly 中配置。之前在 GitLab Shell 中的实现在极狐GitLab 15.0 中已移除。此变更后，全局服务器钩子仅存储在以其钩子类型命名的子目录中。全局服务器钩子不能再是自定义钩子目录根目录下的单个钩子文件。例如，你必须使用 `<custom_hooks_dir>/<hook_name>.d/*` 而非 `<custom_hooks_dir>/<hook_name>`。
  - 对于 Linux 软件包实例，请在 `gitlab.rb` 中使用 `gitaly['custom_hooks_dir']`。这将替换 `gitlab_shell['custom_hooks_dir']`。
- 全新安装的默认 PostgreSQL 版本为 13.6，升级安装则为 12.10。你可以按照[升级文档](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)手动升级到 PostgreSQL 13.6，使用以下命令：

  ```shell
  sudo gitlab-ctl pg-upgrade -V 13
  ```

  在 PostgreSQL 12 被移除之前，如果需要兼容性或测试环境原因，你可以[锁定 PostgreSQL 版本](https://gitlab.cn/docs/omnibus/settings/database/#pin-the-packaged-postgresql-version-fresh-installs-only)。

  [容错和 Geo 安装需要额外的步骤和规划](../../administration/postgresql/replication_and_failover.md#upgrading-postgresql-major-version-in-a-patroni-cluster)。

  由于底层结构变更，在运行数据库迁移之前，升级 PostgreSQL 时必须重启正在运行的 PostgreSQL 进程。如果跳过了自动重启，你必须在迁移运行前执行以下命令：

  ```shell
  # 如果使用 PostgreSQL
  sudo gitlab-ctl restart postgresql

  # 如果使用 Patroni 进行数据库复制
  sudo gitlab-ctl restart patroni
  ```

  如果未重启 PostgreSQL，你可能会遇到[与加载库相关的错误](https://gitlab.cn/docs/omnibus/settings/database/#could-not-load-library-plpgsqlso)。

- 从极狐GitLab 15.0 开始，当 PostgreSQL 版本变更时，`postgresql` 和 `geo-postgresql` 服务会自动重启。重启 PostgreSQL 服务会导致停机，因为数据库暂时不可用于操作。虽然此重启对于数据库服务的正常运行是强制性的，但你可能希望对 PostgreSQL 何时重启有更多控制。为此，你可以选择在 `gitlab-ctl reconfigure` 过程中跳过自动重启，并手动重启服务。

  要在极狐GitLab 15.0 升级过程中跳过自动重启，请在升级前执行以下步骤：

  1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

     ```ruby
     # 对于 PostgreSQL/Patroni
     postgresql['auto_restart_on_version_change'] = false

     # 对于 Geo PostgreSQL
     geo_postgresql['auto_restart_on_version_change'] = false
     ```

  1. 重新配置极狐GitLab：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

  > [!note]
  > 当底层版本变更时，必须重启 PostgreSQL，以避免[与加载必要库相关的错误](https://gitlab.cn/docs/omnibus/settings/database/#could-not-load-library-plpgsqlso)等可能导致停机的问题。因此，如果你使用上述方法跳过自动重启，请确保在升级到极狐GitLab 15.0 之前手动重启服务。

- 从极狐GitLab 15.0 开始，NGINX 默认不再允许 `AES256-GCM-SHA384` SSL 加密套件。如果你使用 [AWS Classic Load Balancer](https://docs.aws.amazon.com/en_en/elasticloadbalancing/latest/classic/elb-ssl-security-policy.html#ssl-ciphers) 并需要该加密套件，可以将其重新添加到允许列表中。要将该 SSL 加密套件添加到允许列表：

  1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

     ```ruby
     nginx['ssl_ciphers'] = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:AES256-GCM-SHA384"
     ```

  1. 重新配置极狐GitLab：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

- 已移除对 Gitaly 内部套接字路径的支持。
  在极狐GitLab 14.10 中，Gitaly 引入了一个新目录，用于存放 Gitaly 正常运行所需的所有运行时数据。此新目录替换了旧的内部套接字目录，因此 `gitaly['internal_socket_dir']` 的使用已被弃用，取而代之的是 `gitaly['runtime_dir']`。

  旧的 `gitaly['internal_socket_dir']` 配置在此版本中已移除。

- 对象存储的后台上传设置已移除。
  对象存储现在优先使用直接上传。

  `/etc/gitlab/gitlab.rb` 中不再支持以下键：

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

### 自行编译安装

- 极狐GitLab 已添加对多个数据库的支持。对于**自行编译（源代码）安装**，
  `config/database.yml` 必须在数据库配置中包含数据库名称。
  `main: database` 必须排在首位。如果使用了无效或已弃用的语法，应用程序启动时会产生错误：

  ```plaintext
  错误：此极狐GitLab 安装使用了不受支持的 'config/database.yml'。
  main: 数据库需要被定义为第一个配置项，而不是 primary。(RuntimeError)
  ```

  以前，`config/database.yml` 文件如下所示：

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

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

- Geo 辅助站点上不正确的对象存储 LFS 文件删除。请参阅[详细信息和解决方法](#incorrect-object-storage-lfs-file-deletion-on-secondary-sites)。