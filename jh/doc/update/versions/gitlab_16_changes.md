---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 16 升级说明
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页包含极狐GitLab 16 的次要版本和补丁版本的升级信息。请务必查看以下说明：

- 您的安装类型。
- 从当前版本到目标版本之间的所有版本。

有关 Helm chart 安装的更多信息，请参阅
[Helm chart 升级说明](https://gitlab.cn/docs/charts/releases/)。

<a id="issues-to-be-aware-of-when-upgrading-from-1511"></a>

## 从 15.11 升级时需要注意的问题

- [从极狐GitLab 16 开始不再支持 PostgreSQL 12](../deprecations.md#postgresql-12-deprecated)。在升级到极狐GitLab 16.0 或更高版本之前，请将 PostgreSQL 升级到至少 13.6 版本。
- 如果您的极狐GitLab 实例首先升级到 15.11.0、15.11.1 或 15.11.2，则数据库模式不正确。
  在升级到 16.x 之前，请执行[变通方法](#undefined-column-error-upgrading-to-162-or-later)。
- 从 16.0 开始，极狐GitLab 私有化部署安装默认有两个数据库连接，而不是一个。此更改使 PostgreSQL 连接数增加一倍。它使极狐GitLab 私有化部署版本的行为与 JihuLab.com 类似，并且是为极狐GitLab 私有化部署版本的 CI 功能启用独立数据库迈出的一步。在升级到 16.0 之前，请确定是否需要[增加 PostgreSQL 的最大连接数](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。
  - 此更改适用于使用 Linux 软件包（Omnibus）、GitLab Helm chart、GitLab Operator、极狐GitLab Docker 镜像以及自编译安装的安装方法。
  - [可以禁用第二个数据库连接](#disable-the-second-database-connection)。
- 大多数安装可以跳过 16.0、16.1 和 16.2，因为升级路径上的第一个必需停靠点是 16.3。
  在任何情况下，您都应查看这些中间版本的说明。

  某些极狐GitLab 安装必须停在这些中间版本，具体取决于使用的功能和环境大小：

  - 16.0.8：`users` 表中有大量记录的实例。
    更多信息，请参阅[长时间运行的用户类型数据更改](#long-running-user-type-data-change)。
  - [16.1.5](#1610)：使用 NPM 软件包仓库的实例。
  - [16.2.8](#1620)：有大量流水线变量（包括历史流水线）的实例。

  如果您的实例受到影响并且您跳过了这些停靠点：

  - 升级可能需要数小时才能完成。
  - 实例会生成 500 错误，直到所有数据库更改完成，之后
    Puma 和 Sidekiq 必须重启。
  - 对于 Linux 软件包安装，会发生超时，并且需要
    [手动变通方法来完成迁移](../package/package_troubleshooting.md#error-command-timed-out-after-3600s)。
- 极狐GitLab 16.0 引入了关于强制执行项目大小限制的更改。在私有化部署中，如果您使用
  这些限制，当向同一群组中未受影响的 Git 代码仓库推送时，已达到限制的项目会导致错误消息。这些错误通常涉及超过零字节的限制 (`limit of 0 B`)。

  推送会成功，但错误消息暗示相反，并可能导致自动化问题。
  [在议题中了解更多信息](https://gitlab.com/gitlab-org/gitlab/-/issues/416646)。
  [该错误已在极狐GitLab 16.5 及更高版本中修复](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/131122)。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

- 在升级到极狐GitLab 16 之前，必须更改 Gitaly 和 Praefect 的配置结构。
  为避免数据丢失，请先重新配置 Praefect，并在新配置中禁用元数据验证。
  了解更多：

  - [Praefect 配置结构更改](#praefect-configuration-structure-change)。
  - [Gitaly 配置结构更改](#gitaly-configuration-structure-change)。
- 如果您将 Gitaly 重新配置为将 Git 数据存储在 `/var/opt/gitlab/git-data/repositories` 以外的位置，
  则打包的极狐GitLab 16.0 及更高版本不会自动创建目录结构。
  [阅读议题以了解更多详情和变通方法](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8320)。

<a id="16110"></a>

## 16.11.0

- 在 [JSON Web 令牌（ID 令牌）](../../ci/secrets/id_token_authentication.md) 中[添加了一个 `groups_direct` 字段](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/146881)。
  - 如果您使用极狐GitLab CI/CD ID 令牌向第三方服务进行身份验证，
    此更改可能导致 HTTP 请求头大小增加。如果请求头过大，代理服务器可能会拒绝该请求。
  - 如果可能，请增加接收系统的请求头限制。
  - 有关更多详细信息，请参阅[议题 467253](https://gitlab.com/gitlab-org/gitlab/-/issues/467253)。
- 升级到极狐GitLab 16.11 后，一些拥有大型环境和数据库的用户在 Web UI 中加载源代码页面时会遇到超时。
  这些超时是由于对流水线数据的 PostgreSQL 查询缓慢，超过了内部 60 秒超时。
  - 您仍然可以克隆 Git 代码仓库，其他代码仓库数据请求也可以正常工作。
  - 有关确认您是否受影响以及如何在 PostgreSQL 中运行维护以立即修复数据库的步骤，请参阅[议题 472420](https://gitlab.com/gitlab-org/gitlab/-/issues/472420)。
  - [已在极狐GitLab 17.4.0 中修复](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/162894)，该版本不再运行导致这些超时的查询。

<a id="linux-package-installations-1"></a>

### Linux 软件包安装

在极狐GitLab 16.11 中，PostgreSQL 会自动升级到 14.x，但以下情况除外：

- 您使用 Patroni 以高可用性方式运行数据库。
- 您的数据库节点是极狐GitLab Geo 配置的一部分。
- 您已明确[选择退出](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades)自动升级 PostgreSQL。
- 您的 `/etc/gitlab/gitlab.rb` 中有 `postgresql['version'] = 13`。

容错和 Geo 安装支持手动升级到 PostgreSQL 14，
请参阅[在 HA/Geo 集群中部署的打包 PostgreSQL](https://gitlab.cn/docs/omnibus/settings/database/#packaged-postgresql-deployed-in-an-hageo-cluster)。

<a id="geo-installations"></a>

### Geo 安装

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

- 在极狐GitLab 16.11 到极狐GitLab 17.2 中，缺少 PostgreSQL 索引可能导致高 CPU 使用率、作业产物验证进度缓慢以及 Geo 指标状态更新缓慢或超时。该索引已在极狐GitLab 17.3 中添加。要手动添加索引，请参阅 [Geo 故障排除 - 作业产物验证期间主站点 CPU 使用率高](../../administration/geo/replication/troubleshooting/common.md#high-cpu-usage-on-primary-during-object-verification)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.11                   |  全部                    | 无     |
  | 17.0                    |  全部                    | 无     |
  | 17.1                    |  全部                    | 无     |
  | 17.2                    |  全部                    | 无     |

- 即使 Geo 复制正常工作，从站点的 Geo 复制详细信息也可能显示为空。请参阅[议题 468509](https://gitlab.com/gitlab-org/gitlab/-/issues/468509)。目前没有已知的变通方法。该错误已在极狐GitLab 17.4 中修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.11                   |  16.11.5 - 16.11.10     | 无     |
  | 17.0                    |  全部                    | 17.0.7   |
  | 17.1                    |  全部                    | 17.1.7   |
  | 17.2                    |  全部                    | 17.2.5   |
  | 17.3                    |  全部                    | 17.3.1   |

<a id="16100"></a>

## 16.10.0

升级到极狐GitLab 16.10 或更高版本时，您可能会遇到以下错误：

```plaintext
PG::UndefinedColumn: ERROR:  column namespace_settings.delayed_project_removal does not exist
```

当删除列的迁移在引用现已删除列的后续迁移之前运行时，可能会出现此错误。此错误的[修复](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/148135)计划在 16.11 中发布。

要变通解决此问题：

1. 临时重新创建该列。使用 `gitlab-psql` 或手动连接到数据库，运行：

   ```sql
   ALTER TABLE namespace_settings ADD COLUMN delayed_project_removal BOOLEAN DEFAULT NULL;
   ```

1. 应用待处理的迁移：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 完成检查：

   ```shell
   gitlab-ctl upgrade-check
   ```

1. 删除该列。使用 `gitlab-psql` 或手动连接到数据库，运行：

   ```sql
   ALTER TABLE namespace_settings DROP COLUMN delayed_project_removal;
   ```

<a id="linux-package-installations-2"></a>

### Linux 软件包安装

极狐GitLab 16.10 的 Linux 软件包安装包括升级到 Patroni 的新主要版本，从 2.1.0 版本升级到 3.0.1 版本。

如果您使用的是启用[高可用性 (HA)](../../administration/reference_architectures/_index.md#high-availability-ha) 的[参考架构](../../administration/reference_architectures/_index.md)之一（3k 用户或更多），则您使用的是[适用于 Linux 软件包安装的 PostgreSQL 复制和故障转移](../../administration/postgresql/replication_and_failover.md)，该功能使用 Patroni。

如果这是您的情况，请阅读[多节点升级（有停机时间）](../with_downtime.md)，了解如何升级您的多节点实例。

有关 2.1.0 版本和 3.0.1 版本之间引入的更改的更多信息，请参阅 [Patroni 发布说明](https://patroni.readthedocs.io/en/latest/releases.html)。

<a id="geo-installations-1"></a>

### Geo 安装

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

<a id="1690"></a>

## 16.9.0

升级到极狐GitLab 16.9.0 时，您可能会遇到以下错误：

```plaintext
PG::UndefinedTable: ERROR:  relation "p_ci_pipeline_variables" does not exist
```

确保所有迁移都完成，并重启所有 Rails 和 Sidekiq 节点。
此错误的[修复](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/144952)计划在 16.9.1 中发布。

<a id="geo-installations-2"></a>

### Geo 安装

- 由于[容器复制中的错误](https://gitlab.com/gitlab-org/gitlab/-/issues/431944)，配置错误的从站点可能将失败的容器复制标记为成功。随后的验证会因校验和不匹配而将该容器标记为失败。变通方法是修复从站点的配置。
  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 全部                     |  全部                    | 16.10.2  |

- 由于极狐GitLab 16.5 中引入的错误，[个人代码片段](../../user/snippets.md) 未复制到 Geo 从站点。这可能导致在 Geo 故障转移时丢失个人代码片段数据。
  有关问题和变通方法的详细信息，请参阅[议题 439933](https://gitlab.com/gitlab-org/gitlab/-/issues/439933)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  全部                    | 无     |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于主站点和从站点之间的校验和不匹配，您可能会在部分容器镜像仓库镜像上遇到验证失败。[议题 442667](https://gitlab.com/gitlab-org/gitlab/-/issues/442667) 描述了详细信息。虽然数据被正确复制到从站点，没有直接的数据丢失风险，但数据未成功验证。目前没有已知的变通方法。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

<a id="linux-package-installations-3"></a>

### Linux 软件包安装

- Sidekiq 的 `min_concurrency` 和 `max_concurrency` 选项在极狐GitLab 16.9.0 中已弃用，并计划在极狐GitLab 17.0.0 中移除。在极狐GitLab 16.9.0 及更高版本中，为避免极狐GitLab 17.0.0 中的破坏性更改，请设置新的 [`concurrency`](../../administration/sidekiq/extra_sidekiq_processes.md#manage-thread-counts-with-concurrency-field) 选项并移除 `min_concurrency` 和 `max_concurrency` 选项。

<a id="1680"></a>

## 16.8.0

- 极狐GitLab 16.8.0 和 16.8.1 暂时要求 Redis 6.2。极狐GitLab 16.8.2 恢复了[与 Redis 6.0 的兼容性](https://gitlab.com/gitlab-org/gitlab/-/issues/439418)。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="geo-installations-3"></a>

### Geo 安装

- PostgreSQL 14 是极狐GitLab 16.7 及更高版本全新安装的默认版本。由于一个已知问题，现有的 Geo 从站点无法升级到 PostgreSQL 14。更多信息，请参阅[议题 7768](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7768#note_1652076255)。
  所有 Geo 站点必须运行相同版本的 PostgreSQL。要在极狐GitLab 16.7 到 16.8.1 上添加新的 Geo 从站点，
  您必须根据您的配置执行以下操作之一：

  - 要添加您的第一个 Geo 从站点：在设置新的 Geo 从站点之前，[将主站点升级到 PostgreSQL 14](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。如果您的主站点已运行 PostgreSQL 14，则无需特殊操作。
  - 要向已有至少一个 Geo 从站点的部署添加新的 Geo 从站点：
    - 如果所有现有站点都运行 PostgreSQL 13，请使用[固定 PostgreSQL 13 版本](https://gitlab.cn/docs/omnibus/settings/database/#pin-the-packaged-postgresql-version-fresh-installs-only)安装新的 Geo 从站点。
    - 如果所有现有站点都运行 PostgreSQL 14：无需特殊操作。
    - 在向部署添加新的 Geo 从站点之前，将所有现有站点升级到极狐GitLab 16.8.2 或更高版本以及 PostgreSQL 14。
- 由于极狐GitLab 16.5 中引入的错误，[个人代码片段](../../user/snippets.md) 未复制到 Geo 从站点。这可能导致在 Geo 故障转移时丢失个人代码片段数据。
  有关问题和变通方法的详细信息，请参阅[议题 439933](https://gitlab.com/gitlab-org/gitlab/-/issues/439933)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  全部                    | 无     |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于主站点和从站点之间的校验和不匹配，您可能会在部分容器镜像仓库镜像上遇到验证失败。[议题 442667](https://gitlab.com/gitlab-org/gitlab/-/issues/442667) 描述了详细信息。虽然数据被正确复制到从站点，没有直接的数据丢失风险，但数据未成功验证。目前没有已知的变通方法。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

<a id="1670"></a>

## 16.7.0

- 极狐GitLab 16.7 是必需的升级停靠点。这确保了极狐GitLab 16.7 及更早版本中引入的所有数据库更改都已在所有私有化部署实例上实施。然后可以在极狐GitLab 16.8 及更高版本中发布依赖的更改。[议题 429611](https://gitlab.com/gitlab-org/gitlab/-/issues/429611) 提供了更多详细信息。

  - 如果您在升级路径中跳过 16.6，则在升级到 16.7 后，当您的实例处理极狐GitLab 16.6 版本中的后台数据库迁移时，可能会遇到性能问题。
    在 [16.6.0 升级说明](#1660) 中阅读有关 `ci_builds` 迁移的更多信息。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="linux-package-installations-4"></a>

### Linux 软件包安装

特定信息适用于 Linux 软件包安装：

- 从极狐GitLab 16.7 开始，PostgreSQL 14 是 Linux 软件包安装的默认版本。
  在软件包升级期间，数据库不会升级到 PostgreSQL 14。
  如果您想升级到 PostgreSQL 14，[您必须手动升级](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

  如果您想使用 PostgreSQL 13，则必须在 `/etc/gitlab/gitlab.rb` 中设置 `postgresql['version'] = 13`。

<a id="geo-installations-4"></a>

### Geo 安装

- PostgreSQL 14 是极狐GitLab 16.7 及更高版本全新安装的默认版本。由于一个已知问题，现有的 Geo 从站点无法升级到 PostgreSQL 14。更多信息，请参阅[议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/7768#note_1652076255)。
  所有 Geo 站点必须运行相同版本的 PostgreSQL。要添加基于极狐GitLab 16.7 到 16.8.1 的新 Geo 从站点，您必须根据您的配置执行以下操作之一：

  - 您正在添加您的第一个 Geo 从站点：在设置新的 Geo 从站点之前，[将主站点升级到 PostgreSQL 14](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。如果您的主站点已运行 PostgreSQL 14，则无需特殊操作。
  - 您正在向已有至少一个 Geo 从站点的部署添加新的 Geo 从站点：
    - 如果所有现有站点都运行 PostgreSQL 13：使用[固定 PostgreSQL 13 版本](https://gitlab.cn/docs/omnibus/settings/database/#pin-the-packaged-postgresql-version-fresh-installs-only)安装新的 Geo 从站点。
    - 如果所有现有站点都运行 PostgreSQL 14：无需特殊操作。
    - 在向部署添加新的 Geo 从站点之前，将所有现有站点升级到极狐GitLab 16.8.2 或更高版本以及 PostgreSQL 14。
- 由于主站点和从站点之间的校验和不匹配，您可能会在部分项目上遇到验证失败。详细信息在此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427493)中跟踪。由于数据被正确复制到从站点，因此没有数据丢失的风险。从 Geo 从站点克隆受影响项目的用户将始终被重定向到主站点。目前没有已知的变通方法。我们正在积极修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.3                    |  全部                    | 无     |
  | 16.4                    |  全部                    | 无     |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  16.6.0 - 16.6.5        | 16.6.6   |
  | 16.7                    |  16.7.0 - 16.7.3        | 16.7.4   |

- 由于极狐GitLab 16.5 中引入的错误，[个人代码片段](../../user/snippets.md) 未复制到 Geo 从站点。这可能导致在 Geo 故障转移时丢失个人代码片段数据。
  有关问题和变通方法的详细信息，请参阅[议题 439933](https://gitlab.com/gitlab-org/gitlab/-/issues/439933)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  全部                    | 无     |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

<a id="1660"></a>

## 16.6.0

- 极狐GitLab 16.6 引入了一个后台迁移，该迁移会重写 CI 作业表 (`ci_builds`) 中的每一行，作为将主键升级到 64 位的一部分。
  `ci_builds` 是大多数极狐GitLab 实例上最大的表之一，因此此迁移的运行比平时更激进，以确保在合理的时间内完成。
  后台迁移通常在批次行之间暂停，但此迁移不会。

  这可能会导致私有化部署环境中的性能问题：

  - 磁盘 I/O 将高于平时。对于磁盘 I/O 受限的云提供商托管的实例，这将是一个特别的问题。
  - Autovacuum 可能会更频繁地在后台运行，以确保删除旧行（死元组），并执行其他相关的维护工作。
  - 查询可能会暂时变慢，因为 PostgreSQL 选择了低效的查询计划。这可能是由表上的更改量触发的。

  变通方法：

  - 在 [**管理员** 区域](../background_migrations.md#from-the-gitlab-ui) 中暂停正在运行的迁移。
  - 在[数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)上手动重新创建表统计信息，以确保选择正确的查询计划：

    ```sql
    SET statement_timeout = 0;
    VACUUM FREEZE VERBOSE ANALYZE public.ci_builds;
    ```

- 升级到极狐GitLab 16.6 后，可能会生成旧的 [CI 环境销毁作业](https://gitlab.com/gitlab-org/gitlab/-/issues/433264#)。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="geo-installations-5"></a>

### Geo 安装

- 由于主站点和从站点之间的校验和不匹配，您可能会在部分项目上遇到验证失败。详细信息在此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427493)中跟踪。由于数据被正确复制到从站点，因此没有数据丢失的风险。从 Geo 从站点克隆受影响项目的用户将始终被重定向到主站点。目前没有已知的变通方法。我们正在积极修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.3                    |  全部                    | 无     |
  | 16.4                    |  全部                    | 无     |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  16.6.0 - 16.6.5        | 16.6.6   |
  | 16.7                    |  16.7.0 - 16.7.3        | 16.7.4   |

- 由于极狐GitLab 16.5 中引入的错误，[个人代码片段](../../user/snippets.md) 未复制到 Geo 从站点。这可能导致在 Geo 故障转移时丢失个人代码片段数据。
  有关问题和变通方法的详细信息，请参阅[议题 439933](https://gitlab.com/gitlab-org/gitlab/-/issues/439933)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  全部                    | 无     |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

<a id="1650"></a>

## 16.5.0

- Gitaly 需要 Git 2.42.0 及更高版本。对于自编译安装，您应使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。
- 一个回归问题有时可能导致[导航群组时出现 HTTP 500 错误](https://gitlab.com/gitlab-org/gitlab/-/issues/431659)。升级到极狐GitLab 16.6 或更高版本可解决此问题。
- 一个回归问题可能导致[未选择的高级搜索筛选器无法加载](https://gitlab.com/gitlab-org/gitlab/-/issues/428246)。升级到 16.6 或更高版本可解决此问题。
- `unique_batched_background_migrations_queued_migration_version` 索引是在 16.5 中引入的，部署后迁移
  `DeleteOrphansScanFindingLicenseScanningApprovalRules2`
  有可能在进行零停机升级时破坏此唯一约束。
  [议题 #437291](https://gitlab.com/gitlab-org/gitlab/-/issues/437291#to-unblock) 中提供了变通方法，可修复以下错误：

  ```plaintext
  PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint
  "unique_batched_background_migrations_queued_migration_version"
  DETAIL:  Key (queued_migration_version)=(20230721095222) already exists.
  ```

- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="linux-package-installations-5"></a>

### Linux 软件包安装

- 可以通过在 `/etc/gitlab/gitlab.rb` 中设置 `gitlab_rails['gitlab_ssh_host']` 来自定义 SSH 克隆 URL。此设置现在必须是[有效的主机名](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/132238)。
  以前，它可以是用于在代码仓库克隆 URL 中显示自定义主机名和端口的任意字符串。

  例如，在极狐GitLab 16.5 之前，以下设置有效：

  ```ruby
  gitlab_rails['gitlab_ssh_host'] = "gitlab.example.com:2222"
  ```

  从极狐GitLab 16.5 开始，必须分别指定主机名和端口：

  ```ruby
  gitlab_rails['gitlab_ssh_host'] = "gitlab.example.com"
  gitlab_rails['gitlab_shell_ssh_port'] = 2222
  ```

  更改设置后，请确保重新配置极狐GitLab：

  ```shell
  sudo gitlab-ctl reconfigure
  ```

<a id="geo-installations-6"></a>

### Geo 安装

特定信息适用于使用 Geo 的安装：

- 一些 Prometheus 指标在 16.3.0 中被错误移除，这可能会破坏仪表板和告警：

  | 受影响的指标                          | 在 16.5.2 及更高版本中恢复的指标  | 16.3+ 中可用的替代指标                 |
  | ---------------------------------------- | ------------------------------------ | ---------------------------------------------- |
  | `geo_repositories_synced`                | 是                                  | `geo_project_repositories_synced`              |
  | `geo_repositories_failed`                | 是                                  | `geo_project_repositories_failed`              |
  | `geo_repositories_checksummed`           | 是                                  | `geo_project_repositories_checksummed`         |
  | `geo_repositories_checksum_failed`       | 是                                  | `geo_project_repositories_checksum_failed`     |
  | `geo_repositories_verified`              | 是                                  | `geo_project_repositories_verified`            |
  | `geo_repositories_verification_failed`   | 是                                  | `geo_project_repositories_verification_failed` |
  | `geo_repositories_checksum_mismatch`     | 否                                   | 无可用                                 |
  | `geo_repositories_retrying_verification` | 否                                   | 无可用                                 |

  - 受影响的版本：
    - 16.3.0 到 16.5.1
  - 包含修复的版本：
    - 16.5.2 及更高版本

  更多信息，请参阅[议题 429617](https://gitlab.com/gitlab-org/gitlab/-/issues/429617)。

- [对象存储验证](https://about.gitlab.com/releases/2023/09/22/gitlab-16-4-released/#geo-verifies-object-storage) 在极狐GitLab 16.4 中添加。由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429242)，一些 Geo 安装报告了高内存使用率，这可能导致主站点上的极狐GitLab 应用程序无响应。

  如果您已配置使用[对象存储](../../administration/object_storage.md)并启用了 [极狐GitLab 管理的对象存储复制](../../administration/geo/replication/object_storage.md#enabling-gitlab-managed-object-storage-replication)，则您的安装可能会受到影响。

  在修复之前，变通方法是禁用对象存储验证。
  在主站点的一个 Rails 节点上运行以下命令：

  ```shell
  sudo gitlab-rails runner 'Feature.disable(:geo_object_storage_verification)'
  ```

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.4                    | 16.4.0 - 16.4.2         | 16.4.3   |
  | 16.5                    | 16.5.0 - 16.5.1         | 16.5.2   |

- 在极狐GitLab 16.3 中添加[群组 Wiki](../../user/project/wiki/group.md) 验证后，缺失的群组 Wiki 代码仓库被错误标记为验证失败。此问题并非实际的复制/验证失败，而是 Geo 内部这些缺失代码仓库的无效内部状态，导致日志中出现错误，并且验证进度报告这些群组 Wiki 代码仓库处于失败状态。

  有关问题和变通方法的详细信息，请参阅[议题 426571](https://gitlab.com/gitlab-org/gitlab/-/issues/426571)

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ------ | ------ | ------ |
  | 16.3   | 全部    | 无   |
  | 16.4   | 全部    | 无   |
  | 16.5   | 16.5.0 - 16.5.1    | 16.5.2   |

- 由于主站点和从站点之间的校验和不匹配，您可能会在部分项目上遇到验证失败。详细信息在此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427493)中跟踪。由于数据被正确复制到从站点，因此没有数据丢失的风险。从 Geo 从站点克隆受影响项目的用户将始终被重定向到主站点。目前没有已知的变通方法。我们正在积极修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.3                    |  全部                    | 无     |
  | 16.4                    |  全部                    | 无     |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  16.6.0 - 16.6.5        | 16.6.6   |
  | 16.7                    |  16.7.0 - 16.7.3        | 16.7.4   |

- 由于极狐GitLab 16.5 中引入的错误，[个人代码片段](../../user/snippets.md) 未复制到 Geo 从站点。这可能导致在 Geo 故障转移时丢失个人代码片段数据。
  有关问题和变通方法的详细信息，请参阅[议题 439933](https://gitlab.com/gitlab-org/gitlab/-/issues/439933)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  全部                    | 无     |
  | 16.8                    |  16.8.0 - 16.8.3        | 16.8.4   |
  | 16.9                    |  16.9.0 - 16.9.1        | 16.9.2   |

- 由于极狐GitLab 16.5 中引入并在 17.0 中修复的错误，[GitLab Pages](../../administration/pages/_index.md) 部署文件在 Geo 从站点上成为孤立文件。如果 Pages 部署存储在本地，则可能导致剩余存储空间为零，进而在故障转移时导致数据丢失。
  有关问题和变通方法的详细信息，请参阅[议题 457159](https://gitlab.com/gitlab-org/gitlab/-/issues/457159)。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  全部                    | 无     |
  | 16.7                    |  16.7.0 - 16.7.7        | 16.7.8   |
  | 16.8                    |  16.8.0 - 16.8.7        | 16.8.8   |
  | 16.9                    |  16.9.0 - 16.9.8        | 16.9.9   |
  | 16.10                   |  16.10.0 - 16.10.6      | 16.10.7  |
  | 16.11                   |  16.11.0 - 16.11.3      | 16.11.4  |

<a id="1640"></a>

## 16.4.0

- 更新群组路径[获得了一个错误修复](https://gitlab.com/gitlab-org/gitlab/-/issues/419289)，该修复使用了 16.3 中引入的数据库索引。

  如果您从低于 16.3 的版本升级到 16.4，则必须在使用前在数据库中执行 `ANALYZE packages_packages;`。
- 升级到极狐GitLab 16.4 或更高版本时，您可能会遇到以下错误：

  ```plaintext
  main: == 20230830084959 ValidatePushRulesConstraints: migrating =====================
  main: -- execute("SET statement_timeout TO 0")
  main:    -> 0.0002s
  main: -- execute("ALTER TABLE push_rules VALIDATE CONSTRAINT force_push_regex_size_constraint;")
  main:    -> 0.0004s
  main: -- execute("RESET statement_timeout")
  main:    -> 0.0003s
  main: -- execute("ALTER TABLE push_rules VALIDATE CONSTRAINT delete_branch_regex_size_constraint;")
  rails aborted!
  StandardError: An error has occurred, all later migrations canceled:

  PG::CheckViolation: ERROR:  check constraint "delete_branch_regex_size_constraint" of relation "push_rules" is violated by some row
  ```

  这些约束可能会返回错误：

  - `author_email_regex_size_constraint`
  - `branch_name_regex_size_constraint`
  - `commit_message_negative_regex_size_constraint`
  - `commit_message_regex_size_constraint`
  - `delete_branch_regex_size_constraint`
  - `file_name_regex_size_constraint`
  - `force_push_regex_size_constraint`

  要修复此错误，请查找 `push_rules` 表中超过 511 个字符限制的记录。

  ```sql
  -- replace `delete_branch_regex` with a name of the field used in constraint
  SELECT id FROM push_rules WHERE LENGTH(delete_branch_regex) > 511;
  ```

  要确定推送规则属于项目、群组还是实例，请在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中运行此脚本：

  ```ruby
  # replace `delete_branch_regex` with a name of the field used in constraint
  long_rules = PushRule.where("length(delete_branch_regex) > 511")

  array = long_rules.map do |lr|
    if lr.project
      "Push rule with ID #{lr.id} is configured in a project #{lr.project.full_name}"
    elsif lr.group
      "Push rule with ID #{lr.id} is configured in a group #{lr.group.full_name}"
    else
      "Push rule with ID #{lr.id} is configured on the instance level"
    end
  end

  puts "Total long rules: #{array.count}"
  puts array.join("\n")
  ```

  减少受影响推送规则记录的正则表达式字段的值长度，然后重试迁移。

  如果您有太多受影响的推送规则，并且无法通过极狐GitLab UI 更新它们，请联系 [极狐GitLab 支持](https://support.gitlab.com/)。

- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="self-compiled-installations"></a>

### 自编译安装

- 在极狐GitLab 16.4 及更高版本中，推荐使用一种新的方法来配置极狐GitLab 密钥和自定义钩子的路径：
  1. 更新您的配置 `[gitlab] secret_file` 以配置极狐GitLab 密钥令牌的路径。
  1. 如果您有自定义钩子，请更新您的配置 `[hooks] custom_hooks_dir` 以配置服务端自定义钩子的路径。
  1. 移除 `[gitlab-shell] dir` 配置。

<a id="geo-installations-7"></a>

### Geo 安装

特定信息适用于使用 Geo 的安装：

- 一些 Prometheus 指标在 16.3.0 中被错误移除，这可能会破坏仪表板和告警：

  | 受影响的指标                          | 在 16.5.2 及更高版本中恢复的指标  | 16.3+ 中可用的替代指标                 |
  | ---------------------------------------- | ------------------------------------ | ---------------------------------------------- |
  | `geo_repositories_synced`                | 是                                  | `geo_project_repositories_synced`              |
  | `geo_repositories_failed`                | 是                                  | `geo_project_repositories_failed`              |
  | `geo_repositories_checksummed`           | 是                                  | `geo_project_repositories_checksummed`         |
  | `geo_repositories_checksum_failed`       | 是                                  | `geo_project_repositories_checksum_failed`     |
  | `geo_repositories_verified`              | 是                                  | `geo_project_repositories_verified`            |
  | `geo_repositories_verification_failed`   | 是                                  | `geo_project_repositories_verification_failed` |
  | `geo_repositories_checksum_mismatch`     | 否                                   | 无可用                                 |
  | `geo_repositories_retrying_verification` | 否                                   | 无可用                                 |

  - 受影响的版本：
    - 16.3.0 到 16.5.1
  - 包含修复的版本：
    - 16.5.2 及更高版本

  更多信息，请参阅[议题 429617](https://gitlab.com/gitlab-org/gitlab/-/issues/429617)。

- [对象存储验证](https://about.gitlab.com/releases/2023/09/22/gitlab-16-4-released/#geo-verifies-object-storage) 在极狐GitLab 16.4 中添加。由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429242)，一些 Geo 安装报告了高内存使用率，这可能导致主站点上的极狐GitLab 应用程序无响应。

  如果您已配置使用[对象存储](../../administration/object_storage.md)并启用了 [极狐GitLab 管理的对象存储复制](../../administration/geo/replication/object_storage.md#enabling-gitlab-managed-object-storage-replication)，则您的安装可能会受到影响。

  在修复之前，变通方法是禁用对象存储验证。
  在主站点的一个 Rails 节点上运行以下命令：

  ```shell
  sudo gitlab-rails runner 'Feature.disable(:geo_object_storage_verification)'
  ```

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.4                    | 16.4.0 - 16.4.2         | 16.4.3   |
  | 16.5                    | 16.5.0 - 16.5.1         | 16.5.2   |

- 一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419370)导致同步状态卡在待处理状态，从而使受影响条目的复制无限期卡住，进而在故障转移时有数据丢失的风险。这主要影响代码仓库同步，但也可能影响容器镜像仓库同步。建议您升级到包含修复的版本以避免数据丢失风险。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ------ | ------ | ------ |
  | 16.3   | 16.3.0 - 16.3.5    | 16.3.6   |
  | 16.4   | 16.4.0 - 16.4.1    | 16.4.2   |

- 在极狐GitLab 16.3 中添加[群组 Wiki](../../user/project/wiki/group.md) 验证后，缺失的群组 Wiki 代码仓库被错误标记为验证失败。此问题并非实际的复制/验证失败，而是 Geo 内部这些缺失代码仓库的无效内部状态，导致日志中出现错误，并且验证进度报告这些群组 Wiki 代码仓库处于失败状态。

  有关问题和变通方法的详细信息，请参阅[议题 426571](https://gitlab.com/gitlab-org/gitlab/-/issues/426571)

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ------ | ------ | ------ |
  | 16.3   | 全部    | 无   |
  | 16.4   | 全部    | 无   |
  | 16.5   | 16.5.0 - 16.5.1    | 16.5.2   |

- 由于主站点和从站点之间的校验和不匹配，您可能会在部分项目上遇到验证失败。详细信息在此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427493)中跟踪。由于数据被正确复制到从站点，因此没有数据丢失的风险。从 Geo 从站点克隆受影响项目的用户将始终被重定向到主站点。目前没有已知的变通方法。我们正在积极修复。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.3                    |  全部                    | 无     |
  | 16.4                    |  全部                    | 无     |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  16.6.0 - 16.6.5        | 16.6.6   |
  | 16.7                    |  16.7.0 - 16.7.3        | 16.7.4   |

<a id="1630"></a>

## 16.3.0

- 更新到极狐GitLab 16.3.5 或更高版本。这可以避免[议题 425971](https://gitlab.com/gitlab-org/gitlab/-/issues/425971)，该议题会导致极狐GitLab 16.3.3 和 16.3.4 过度使用数据库磁盘空间。
- 添加了一个唯一索引以确保数据库中不存在重复的 NPM 软件包。如果您有重复的 NPM 软件包，则需要先升级到 16.1，否则您可能会遇到以下错误：`PG::UniqueViolation: ERROR:  could not create unique index "idx_packages_on_project_id_name_version_unique_when_npm"`。
- 对于 Go 应用程序，[`crypto/tls`：验证包含大 RSA 密钥的证书链很慢（CVE-2023-29409）](https://github.com/golang/go/issues/61460)
  引入了 RSA 密钥 8192 位的硬限制。在极狐GitLab 的 Go 应用程序上下文中，可以为以下项配置 RSA 密钥：

  - [容器镜像仓库](../../administration/packages/container_registry.md)
  - [Gitaly](../../administration/gitaly/tls_support.md)
  - [GitLab Pages](../../user/project/pages/custom_domains_ssl_tls_certification/_index.md#manually-add-ssltls-certificates)
  - Workhorse

  在升级之前，您应检查上述任何应用程序的 RSA 密钥大小 (`openssl rsa -in <your-key-file> -text -noout | grep "Key:"`)。

- 一个 `BackfillCiPipelineVariablesForPipelineIdBigintConversion` 后台迁移通过 `EnsureAgainBackfillForCiPipelineVariablesPipelineIdIsFinished` 部署后迁移完成。
  极狐GitLab 16.2.0 引入了一个[批量后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)来[在 `ci_pipeline_variables` 表上回填 `bigint` `pipeline_id` 值](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/123132)。在较大的极狐GitLab 实例上，此迁移可能需要很长时间才能完成（一个案例报告处理 5000 万行需要 4 小时）。
  为避免长时间升级停机，请确保在升级到 16.3 之前迁移已成功完成。

  您可以在[数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)中检查 `ci_pipeline_variables` 表的大小：

  ```sql
  select count(*) from ci_pipeline_variables;
  ```

- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="linux-package-installations-6"></a>

### Linux 软件包安装

特定信息适用于 Linux 软件包安装：

- 在极狐GitLab 16.0 中，我们[宣布](https://about.gitlab.com/releases/2023/05/22/gitlab-16-0-released/#omnibus-improvements)了升级的基础 Docker 镜像，其中包含新版本的 OpenSSH 服务器。新版本的一个意外后果是默认禁用接受 SSH RSA SHA-1 签名。此问题应仅影响使用非常过时的 SSH 客户端的用户。

  为避免 SHA-1 签名不可用的问题，用户应更新其 SSH 客户端，因为出于安全原因，上游库不鼓励使用 SHA-1 签名。

  为了允许用户无法立即升级其 SSH 客户端的过渡期，极狐GitLab 16.3 及更高版本支持在 `Dockerfile` 中设置 `GITLAB_ALLOW_SHA1_RSA` 环境变量。如果将 `GITLAB_ALLOW_SHA1_RSA` 设置为 `true`，则会重新激活此已弃用的支持。

  因为我们希望促进安全最佳实践并遵循上游建议，此环境变量将仅可用到极狐GitLab 17.0，届时我们计划放弃对它的支持。

  更多信息，请参阅：

  - [OpenSSH 8.8 发布说明](https://www.openssh.com/txt/release-8.8)。
  - [非正式解释](https://gitlab.com/gitlab-org/gitlab/-/issues/416714#note_1482388504)。
  - `omnibus-gitlab` [合并请求 7035](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/7035)，其中引入了该环境变量。

<a id="geo-installations-8"></a>

### Geo 安装

特定信息适用于使用 Geo 的安装：

- 即使 Geo 从站点是最新的，针对 Geo 从站点的 Git 拉取也会被代理到 Geo 主站点。如果您使用 Geo 来加速对 Geo 从站点发起 Git 拉取请求的远程用户，您将受到影响。

  - 受影响的版本：
    - 16.3.0 到 16.3.3
  - 包含修复的版本：
    - 16.3.4 及更高版本

  更多信息，请参阅[议题 425224](https://gitlab.com/gitlab-org/gitlab/-/issues/425224)。

- 一些 Prometheus 指标在 16.3.0 中被错误移除，这可能会破坏仪表板和告警：

  | 受影响的指标                          | 在 16.5.2 及更高版本中恢复的指标  | 16.3+ 中可用的替代指标                 |
  | ---------------------------------------- | ------------------------------------ | ---------------------------------------------- |
  | `geo_repositories_synced`                | 是                                  | `geo_project_repositories_synced`              |
  | `geo_repositories_failed`                | 是                                  | `geo_project_repositories_failed`              |
  | `geo_repositories_checksummed`           | 是                                  | `geo_project_repositories_checksummed`         |
  | `geo_repositories_checksum_failed`       | 是                                  | `geo_project_repositories_checksum_failed`     |
  | `geo_repositories_verified`              | 是                                  | `geo_project_repositories_verified`            |
  | `geo_repositories_verification_failed`   | 是                                  | `geo_project_repositories_verification_failed` |
  | `geo_repositories_checksum_mismatch`     | 否                                   | 无可用                                 |
  | `geo_repositories_retrying_verification` | 否                                   | 无可用                                 |

  - 受影响的版本：
    - 16.3.0 到 16.5.1
  - 包含修复的版本：
    - 16.5.2 及更高版本

  更多信息，请参阅[议题 429617](https://gitlab.com/gitlab-org/gitlab/-/issues/429617)。

- 一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/419370)导致同步状态卡在待处理状态，从而使受影响条目的复制无限期卡住，进而在故障转移时有数据丢失的风险。这主要影响代码仓库同步，但也可能影响容器镜像仓库同步。建议您升级到包含修复的版本以避免数据丢失风险。
- 由于主站点和从站点之间的校验和不匹配，您可能会在部分项目上遇到验证失败。详细信息在[议题 427493](https://gitlab.com/gitlab-org/gitlab/-/issues/427493)中跟踪。由于数据被正确复制到从站点，因此没有数据丢失的风险。从 Geo 从站点克隆受影响项目的用户将始终被重定向到主站点。没有已知的变通方法，您应升级到包含修复的版本。

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ----------------------- | ----------------------- | -------- |
  | 16.3                    |  全部                    | 无     |
  | 16.4                    |  全部                    | 无     |
  | 16.5                    |  全部                    | 无     |
  | 16.6                    |  16.6.0 - 16.6.5        | 16.6.6   |
  | 16.7                    |  16.7.0 - 16.7.3        | 16.7.4   |

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ------ | ------ | ------ |
  | 16.3   | 16.3.0 - 16.3.5    | 16.3.6   |
  | 16.4   | 16.4.0 - 16.4.1    | 16.4.2   |

- 在极狐GitLab 16.3 中添加[群组 Wiki](../../user/project/wiki/group.md) 验证后，缺失的群组 Wiki 代码仓库被错误标记为验证失败。此问题并非实际的复制/验证失败，而是 Geo 内部这些缺失代码仓库的无效内部状态，导致日志中出现错误，并且验证进度报告这些群组 Wiki 代码仓库处于失败状态。

  有关问题和变通方法的详细信息，请参阅[议题 426571](https://gitlab.com/gitlab-org/gitlab/-/issues/426571)

  **受影响的版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
  | ------ | ------ | ------ |
  | 16.3   | 全部    | 无   |
  | 16.4   | 全部    | 无   |
  | 16.5   | 16.5.0 - 16.5.1    | 16.5.2   |

<a id="1620"></a>

## 16.2.0

- 旧版 LDAP 配置设置可能导致
  [`NoMethodError: undefined method 'devise' for User:Class` 错误](https://gitlab.com/gitlab-org/gitlab/-/issues/419485)。
  如果您有 TLS 选项（例如 `ca_file`）未在
  `tls_options` 哈希中指定，或使用旧版 `gitlab_rails['ldap_host']` 选项，则会出现此错误。
  有关更多详细信息，请参阅[配置变通方法](https://gitlab.com/gitlab-org/gitlab/-/issues/419485#workarounds)。
- 如果您的极狐GitLab 数据库是由 15.11.0 - 15.11.2（含）版本创建或升级的，则升级到极狐GitLab 16.2 将失败，并显示：

  ```plaintext
  PG::UndefinedColumn: ERROR:  column "id_convert_to_bigint" of relation "ci_build_needs" does not exist
  LINE 1: ...db_config_name:main*/ UPDATE "ci_build_needs" SET "id_conver...
  ```

  请参阅[详细信息和变通方法](#undefined-column-error-upgrading-to-162-or-later)。
- 升级到极狐GitLab 16.2 或更高版本时，您可能会遇到以下错误：

  ```plaintext
  main: == 20230620134708 ValidateUserTypeConstraint: migrating =======================
  main: -- execute("ALTER TABLE users VALIDATE CONSTRAINT check_0dd5948e38;")
  rake aborted!
  StandardError: An error has occurred, all later migrations canceled:
  PG::CheckViolation: ERROR:  check constraint "check_0dd5948e38" of relation "users" is violated by some row
  ```

  有关更多信息，请参阅[议题 421629](https://gitlab.com/gitlab-org/gitlab/-/issues/421629)。
- 升级到极狐GitLab 16.2 或更高版本后，您可能会遇到以下错误：

  ```plaintext
  PG::NotNullViolation: ERROR:  null value in column "source_partition_id" of relation "ci_sources_pipelines" violates not-null constraint
  ```

  必须重启 Sidekiq 和 Puma 进程才能解决此问题。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="linux-package-installations-7"></a>

### Linux 软件包安装

特定信息适用于 Linux 软件包安装：

- 自极狐GitLab 16.2 起，Linux 软件包同时附带 PostgreSQL 13.11 和 14.8。
  在软件包升级期间，数据库不会升级到 PostgreSQL 14。如果您
  想升级到 PostgreSQL 14，则必须手动执行：

  ```shell
  sudo gitlab-ctl pg-upgrade -V 14
  ```

  PostgreSQL 14 在 Geo 部署上不受支持，并[计划](https://gitlab.com/groups/gitlab-org/-/work_items/9065)
  在未来的版本中支持。
- 在 16.2 中，我们将 Redis 从 6.2.11 升级到 7.0.12。此升级预计完全向后兼容。

  Redis 不会作为 `gitlab-ctl reconfigure` 的一部分自动重启。
  因此，用户需要在重新配置运行后手动运行 `sudo gitlab-ctl restart redis`，
  以便使用新的 Redis 版本。在重新配置运行结束时，会显示一条警告，提示已安装的 Redis 版本与正在运行的版本不同，直到执行重启。

  请遵循[零停机说明](../zero_downtime.md)升级您的 Redis HA 集群。

<a id="self-compiled-installations-1"></a>

### 自编译安装

- Gitaly 需要 Git 2.41.0 或更高版本。您应使用 [Gitaly 提供的 Git 版本](../../install/self_compiled/_index.md#git)。

<a id="geo-installations-9"></a>

### Geo 安装

特定信息适用于使用 Geo 的安装：

- 如果作业产物配置为存储在对象存储中且启用了 `direct_upload`，则 Geo 不会复制新的作业产物。此错误已在极狐GitLab 16.1.4、16.2.3、16.3.0 及更高版本中修复。
  - 受影响版本：极狐GitLab 16.1.0 - 16.1.3 和 16.2.0 - 16.2.2。
  - 在运行受影响版本时，看似已同步的产物实际上可能在从站点上缺失。
    升级到 16.1.5、16.2.5、16.3.1、16.4.0 或更高版本后，受影响的产物会自动重新同步。
    如有需要，您可以[手动重新同步受影响的作业产物](https://gitlab.com/gitlab-org/gitlab/-/issues/419742#to-fix-data)。

<a id="cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site"></a>

#### 从从站点克隆 LFS 对象会从主站点下载

Geo 对 LFS 对象的代理逻辑中存在一个[错误](https://gitlab.com/gitlab-org/gitlab/-/issues/410413)，导致对从站点的所有 LFS 克隆请求都被代理到主站点，即使从站点是最新的。这可能导致主站点负载增加，并增加从从站点克隆的用户访问 LFS 对象的时间。

在极狐GitLab 15.1 中，代理默认启用。

以下情况您不受影响：

- 如果您的安装未配置为使用 LFS 对象
- 如果您不使用 Geo 来加速远程用户
- 如果您使用 Geo 加速远程用户但已禁用代理

| 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
|-------------------------|-------------------------|----------|
| 15.1 - 16.2             | 全部                     | 16.3 及更高版本    |

变通方法：一种可能的变通方法是[禁用代理](../../administration/geo/secondary_proxy/_index.md#disable-secondary-site-http-proxying)。从站点将无法提供克隆时尚未复制的 LFS 文件。

<a id="1610"></a>

## 16.1.0

- 一个 `BackfillPreparedAtMergeRequests` 后台迁移通过
  `FinalizeBackFillPreparedAtMergeRequests` 部署后迁移完成。
  极狐GitLab 15.10.0 引入了一个[批量后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于
  [在 `merge_requests` 表上回填 `prepared_at` 值](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/111865)。此
  迁移在较大的极狐GitLab 实例上可能需要数天才能完成。在升级到 16.1.0 之前，请确保迁移已成功完成。
- 极狐GitLab 16.1.0 包含一个[批量后台迁移](../background_migrations.md#check-for-pending-database-background-migrations) `MarkDuplicateNpmPackagesForDestruction`，用于标记重复的 NPM 软件包以进行销毁。在升级到 16.3.0 或更高版本之前，请确保迁移已成功完成。
- 一个 `BackfillCiPipelineVariablesForBigintConversion` 后台迁移通过
  `EnsureBackfillBigintIdIsCompleted` 部署后迁移完成。
  极狐GitLab 16.0.0 引入了一个[批量后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于
  [在 `ci_pipeline_variables` 表上回填 `bigint` `id` 值](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/118878)。此
  迁移在较大的极狐GitLab 实例上可能需要很长时间才能完成（据报道，在一个案例中处理 5000 万行需要 4 小时）。
  为避免长时间升级停机，请在升级到 16.1 之前确保迁移已成功完成。

  您可以在[数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)中检查 `ci_pipeline_variables` 表的大小：

  ```sql
  select count(*) from ci_pipeline_variables;
  ```

<a id="self-compiled-installations-2"></a>

### 自编译安装

- 您必须从 `puma.rb` 配置文件中删除与 Puma worker killer 相关的任何设置，因为这些设置已被
  [移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/118645)。有关更多信息，请参阅
  [`puma.rb.example`](https://gitlab.com/gitlab-org/gitlab/-/blob/16-0-stable-ee/config/puma.rb.example) 文件。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="geo-installations-10"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

特定信息适用于使用 Geo 的安装：

- 某些项目导入在创建项目时不会初始化 Wiki 代码仓库。请参阅
  [详细信息和变通方法](#wiki-repositories-not-initialized-on-project-creation)。
- 由于项目设计迁移到 SSF，[缺失的设计代码仓库被错误地标记为验证失败](https://gitlab.com/gitlab-org/gitlab/-/issues/414279)。
  此问题并非实际的复制/验证失败，而是 Geo 内部这些缺失代码仓库的无效状态，导致日志中出现错误，并且验证进度报告这些设计代码仓库处于失败状态。即使您没有导入项目，也可能受到此问题的影响。
  - 受影响版本：极狐GitLab 16.1.0 - 16.1.2
  - 包含修复的版本：极狐GitLab 16.1.3 及更高版本。
- 如果作业产物配置为存储在对象存储中且启用了 `direct_upload`，则 Geo 不会复制新的作业产物。此错误已在极狐GitLab 16.1.4、16.2.3、16.3.0 及更高版本中修复。
  - 受影响版本：极狐GitLab 16.1.0 - 16.1.3 和 16.2.0 - 16.2.2。
  - 在运行受影响版本时，看似已同步的产物实际上可能在从站点上缺失。
    升级到 16.1.5、16.2.5、16.3.1、16.4.0 或更高版本后，受影响的产物会自动重新同步。
    如有需要，您可以[手动重新同步受影响的作业产物](https://gitlab.com/gitlab-org/gitlab/-/issues/419742#to-fix-data)。
  - 即使从站点已完全同步，从从站点克隆 LFS 对象也会从主站点下载。请参阅[详细信息和变通方法](#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="wiki-repositories-not-initialized-on-project-creation"></a>

#### 创建项目时未初始化 Wiki 代码仓库

| 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
|-------------------------|-------------------------|----------|
| 15.11                   | 全部                     | 无     |
| 16.0                    | 全部                     | 无     |
| 16.1                    | 16.1.0 - 16.1.2         | 16.1.3 及更高版本 |

某些项目导入在创建项目时不会初始化 Wiki 代码仓库。自项目 Wiki 迁移到 SSF 以来，
[缺失的 Wiki 代码仓库被错误地标记为验证失败](https://gitlab.com/gitlab-org/gitlab/-/issues/409704)。
这并非实际的复制/验证失败，而是 Geo 内部这些缺失代码仓库的无效状态，导致日志中出现错误，并且验证进度报告这些 Wiki 代码仓库处于失败状态。如果您没有导入项目，则不受此问题影响。

<a id="1600"></a>

## 16.0.0

- 如果 `/etc/gitlab/gitlab.rb` 文件中存在非 ASCII 字符，Sidekiq 会崩溃。您可以通过遵循 [议题 412767](https://gitlab.com/gitlab-org/gitlab/-/issues/412767#note_1404507549) 中的变通方法来解决此问题。
- 默认情况下，Sidekiq 作业仅路由到 `default` 和 `mailers` 队列，因此，每个 Sidekiq 进程也会监听这些队列，以确保所有作业在所有队列中得到处理。如果您已配置[路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)，则此行为不适用。
- 运行极狐GitLab Docker 镜像需要 Docker 20.10.10 或更高版本。旧版本
  [在启动时抛出错误](../../install/docker/troubleshooting.md#threaderror-cant-create-thread-operation-not-permitted)。
- 使用 Azure 存储的容器镜像仓库可能为空且没有标签。您可以通过遵循[重大变更说明](../deprecations.md#azure-storage-driver-defaults-to-the-correct-root-prefix)来解决此问题。
- 通常，在具有 PgBouncer 的环境中，备份必须[通过设置以 `GITLAB_BACKUP_` 为前缀的变量来绕过 PgBouncer](../../administration/backup_restore/backup_gitlab.md#bypassing-pgbouncer)。但是，由于一个[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422163)，`gitlab-backup` 使用通过 PgBouncer 的常规数据库连接，而不是覆盖中定义的直接连接，导致数据库备份失败。变通方法是直接使用 `pg_dump`。

  **受影响版本**：

  | 受影响的次要版本 | 受影响的补丁版本 | 修复版本 |
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

<a id="linux-package-installations-8"></a>

### Linux 软件包安装

特定信息适用于 Linux 软件包安装：

- PostgreSQL 12 的二进制文件已被移除。

  升级前，Linux 软件包安装的管理员必须确保安装使用的是
  [PostgreSQL 13](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。
- 随极狐GitLab 捆绑的 Grafana 已弃用，不再受支持。
  它将在极狐GitLab 16.3 中移除。
- 此升级将 `openssh-server` 升级到 `1:8.9p1-3`。

  由于 [OpenSSH 8.7 发行说明](https://www.openssh.com/txt/release-8.7)中列出的弃用项，使用较旧的 OpenSSH 客户端执行 `ssh-keyscan -t rsa` 获取公钥信息不再可行。

  变通方法是使用不同的密钥类型，或将客户端 OpenSSH 升级到 >= 8.7 的版本。
- [将您的 Praefect 配置迁移到新结构](#praefect-configuration-structure-change)
  以确保您的所有 `praefect['..']` 设置在极狐GitLab 16.0 及更高版本中继续有效。
- [将您的 Gitaly 配置迁移到新结构](#gitaly-configuration-structure-change)
  以确保您的所有 `gitaly['..']` 设置在极狐GitLab 16.0 及更高版本中继续有效。

<a id="non-expiring-access-tokens"></a>

### 不过期的访问令牌

没有过期日期的访问令牌无限期有效，如果访问令牌泄露，这会构成安全风险。

当您升级到极狐GitLab 16.0 及更高版本时，任何没有过期日期的[个人](../../user/profile/personal_access_tokens.md)、
[项目](../../user/project/settings/project_access_tokens.md)或
[群组](../../user/group/settings/group_access_tokens.md)访问令牌都会自动设置一个过期日期，即升级之日起一年。

在系统自动设置此过期日期之前，您应执行以下操作以最大程度地减少中断：

1. [识别任何没有过期日期的访问令牌](../../administration/raketasks/tokens/_index.md#find-tokens-the-rake-tasks-do-not-report)。
1. [为这些令牌设置过期日期](../../administration/raketasks/tokens/_index.md#extend-expiration-dates)。

有关更多信息，请参阅：

- [弃用和移除文档](../deprecations.md#non-expiring-access-tokens)。
- [弃用议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369122)。

<a id="geo-installations-11"></a>

### Geo 安装

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

特定信息适用于使用 Geo 的安装：

- 某些项目导入在创建项目时不会初始化 Wiki 代码仓库。请参阅
  [详细信息和变通方法](#wiki-repositories-not-initialized-on-project-creation)。
- 即使从站点已完全同步，从从站点克隆 LFS 对象也会从主站点下载。请参阅[详细信息和变通方法](#cloning-lfs-objects-from-secondary-site-downloads-from-the-primary-site)。

<a id="gitaly-configuration-structure-change"></a>

### Gitaly 配置结构变更

Linux 软件包中的 Gitaly 配置结构在极狐GitLab 16.0 中
[更改](https://gitlab.com/gitlab-org/gitaly/-/issues/4467)，
以与自编译安装中使用的 Gitaly 配置结构保持一致。

此更改导致 `gitaly['configuration']` 下的单个哈希包含大部分 Gitaly 配置。极狐GitLab 16.0 及更高版本继续使用一些 `gitaly['..']` 配置选项：

- `enable`
- `dir`
- `bin_path`
- `env_directory`
- `env`
- `open_files_ulimit`
- `consul_service_name`
- `consul_service_meta`

通过将现有配置移动到新结构下进行迁移。`git_data_dirs` 受支持[直到极狐GitLab 18.0](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8786)。新结构自极狐GitLab 15.10 起受支持。

**迁移到新结构**

> [!warning]
> 如果您正在运行 Gitaly 集群 (Praefect)，请[先将 Praefect 迁移到新的配置结构](#praefect-configuration-structure-change)。
> 测试此更改后，再继续处理您的 Gitaly 节点。
> 如果在配置结构更改期间 Gitaly 配置错误，[代码仓库验证](../../administration/gitaly/praefect/configure.md#repository-verification)
> 将[删除 Gitaly 集群 (Praefect)工作所需的元数据](https://gitlab.com/gitlab-org/gitaly/-/issues/5529)。
> 为防止配置错误，请暂时禁用 Praefect 中的代码仓库验证。

1. 如果您正在运行 Gitaly 集群 (Praefect)，请确保所有 Praefect 节点上的代码仓库验证均已禁用。
   配置 `verification_interval: 0`，并使用 `gitlab-ctl reconfigure` 应用。
1. 要将新结构应用于您的配置：
   1. 将 `...` 替换为旧键的值。
   1. 配置 `storage` 以替换 `git_data_dirs` 时，**按照以下脚本中的说明，将 `/repositories` 附加到 `path` 的值**。如果
      您未完成此步骤，您的 Git 代码仓库将无法访问，直到配置修复。此
      错误配置可能导致元数据删除。
   1. 跳过您之前未配置值的任何键。
   1. 建议。为所有哈希键包含尾随逗号，以便在键重新排序或添加其他键时哈希保持有效。
1. 使用 `gitlab-ctl reconfigure` 应用更改。
1. 在极狐GitLab 中测试 Git 代码仓库功能。
1. 迁移后从配置中删除旧键，然后重新运行 `gitlab-ctl reconfigure`。
1. 建议，如果您正在运行 Gitaly 集群 (Praefect)。通过删除 `verification_interval: 0` 恢复 Praefect [代码仓库验证](../../administration/gitaly/praefect/configure.md#repository-verification)。

新结构在以下脚本中记录，旧键在新键上方的注释中描述。

> [!warning]
> 仔细检查您对 `storage` 的更新。您必须将 `/repositories` 附加到 `path` 的值。

```ruby
gitaly['configuration'] = {
  # gitaly['socket_path']
  socket_path: ...,
  # gitaly['runtime_dir']
  runtime_dir: ...,
  # gitaly['listen_addr']
  listen_addr: ...,
  # gitaly['prometheus_listen_addr']
  prometheus_listen_addr: ...,
  # gitaly['tls_listen_addr']
  tls_listen_addr: ...,
  tls: {
    # gitaly['certificate_path']
    certificate_path: ...,
    # gitaly['key_path']
    key_path: ...,
  },
  # gitaly['graceful_restart_timeout']
  graceful_restart_timeout: ...,
  logging: {
    # gitaly['logging_level']
    level: ...,
    # gitaly['logging_format']
    format: ...,
    # gitaly['logging_sentry_dsn']
    sentry_dsn: ...,
    # gitaly['logging_ruby_sentry_dsn']
    ruby_sentry_dsn: ...,
    # gitaly['logging_sentry_environment']
    sentry_environment: ...,
    # gitaly['log_directory']
    dir: ...,
  },
  prometheus: {
    # gitaly['prometheus_grpc_latency_buckets']. The old value was configured as a string
    # such as '[0, 1, 2]'. The new value must be an array like [0, 1, 2].
    grpc_latency_buckets: ...,
  },
  auth: {
    # gitaly['auth_token']
    token: ...,
    # gitaly['auth_transitioning']
    transitioning: ...,
  },
  git: {
    # gitaly['git_catfile_cache_size']
    catfile_cache_size: ...,
    # gitaly['git_bin_path']
    bin_path: ...,
    # gitaly['use_bundled_git']
    use_bundled_binaries: ...,
    # gitaly['gpg_signing_key_path']
    signing_key: ...,
    # gitaly['gitconfig']. This is still an array but the type of the elements have changed.
    config: [
      {
        # Previously the elements contained 'section', and 'subsection' in addition to 'key'. Now
        # these all should be concatenated into just 'key', separated by dots. For example,
        # {section: 'first', subsection: 'middle', key: 'last', value: 'value'}, should become
        # {key: 'first.middle.last', value: 'value'}.
        key: ...,
        value: ...,
      },
    ],
  },
  # Storage was previously configured with the gitaly['storage'] or 'git_data_dirs' parameters. Use
  # the following instructions to migrate. For 'git_data_dirs', migrate only the 'path' to the
  # gitaly['configuration'] and leave the rest untouched.
  storage: [
    {
      # gitaly['storage'][<index>]['name']
      #
      # git_data_dirs[<name>]. The storage name was configured as a key in the map.
      name: ...,
      # gitaly['storage'][<index>]['path']
      #
      # git_data_dirs[<name>]['path']. Use the value from git_data_dirs[<name>]['path'] and append '/repositories' to it.
      #
      # For example, if the path in 'git_data_dirs' was '/var/opt/gitlab/git-data', use
      # '/var/opt/gitlab/git-data/repositories'. The '/repositories' extension was automatically
      # appended to the path configured in `git_data_dirs`.
      path: ...,
    },
  ],
  hooks: {
    # gitaly['custom_hooks_dir']
    custom_hooks_dir: ...,
  },
  daily_maintenance: {
    # gitaly['daily_maintenance_disabled']
    disabled: ...,
    # gitaly['daily_maintenance_start_hour']
    start_hour: ...,
    # gitaly['daily_maintenance_start_minute']
    start_minute: ...,
    # gitaly['daily_maintenance_duration']
    duration: ...,
    # gitaly['daily_maintenance_storages']
    storages: ...,
  },
  cgroups: {
    # gitaly['cgroups_mountpoint']
    mountpoint: ...,
    # gitaly['cgroups_hierarchy_root']
    hierarchy_root: ...,
    # gitaly['cgroups_memory_bytes']
    memory_bytes: ...,
    # gitaly['cgroups_cpu_shares']
    cpu_shares: ...,
    repositories: {
      # gitaly['cgroups_repositories_count']
      count: ...,
      # gitaly['cgroups_repositories_memory_bytes']
      memory_bytes: ...,
      # gitaly['cgroups_repositories_cpu_shares']
      cpu_shares: ...,
    }
  },
  # gitaly['concurrency']. While the structure is the same, the string keys in the array elements
  # should be replaced by symbols as elsewhere. {'key' => 'value'}, should become {key: 'value'}.
  concurrency: ...,
  # gitaly['rate_limiting']. While the structure is the same, the string keys in the array elements
  # should be replaced by symbols as elsewhere. {'key' => 'value'}, should become {key: 'value'}.
  rate_limiting: ...,
  pack_objects_cache: {
    # gitaly['pack_objects_cache_enabled']
    enabled: ...,
    # gitaly['pack_objects_cache_dir']
    dir: ...,
    # gitaly['pack_objects_cache_max_age']
    max_age: ...,
  }
}
```

<a id="praefect-configuration-structure-change"></a>

### Praefect 配置结构变更

Linux 软件包中的 Praefect 配置结构在极狐GitLab 16.0 中
[更改](https://gitlab.com/gitlab-org/gitaly/-/issues/4467)，
以与自编译安装中使用的 Praefect 配置结构保持一致。

此更改导致 `praefect['configuration']` 下的单个哈希包含大部分 Praefect 配置。极狐GitLab 16.0 及更高版本继续使用一些 `praefect['..']` 配置选项：

- `enable`
- `dir`
- `log_directory`
- `env_directory`
- `env`
- `wrapper_path`
- `auto_migrate`
- `consul_service_name`

通过将现有配置移动到新结构下进行迁移。新结构自极狐GitLab 15.9 起受支持。

**迁移到新结构**

> [!warning]
> 先将 Praefect 迁移到新的配置结构。
> 测试此更改后，[继续处理您的 Gitaly 节点](#gitaly-configuration-structure-change)。
> 如果在配置结构更改期间 Gitaly 配置错误，[代码仓库验证](../../administration/gitaly/praefect/configure.md#repository-verification)
> 将[删除 Gitaly 集群 (Praefect)工作所需的元数据](https://gitlab.com/gitlab-org/gitaly/-/issues/5529)。
> 为防止配置错误，请暂时禁用 Praefect 中的代码仓库验证。

1. 将新结构应用于您的配置时：
   - 将 `...` 替换为旧键的值。
   - 使用 `verification_interval: 0` 禁用代码仓库验证，如下面的脚本所示。
   - 跳过您之前未配置值的任何键。
   - 建议。为所有哈希键包含尾随逗号，以便在键重新排序或添加其他键时哈希保持有效。
1. 使用 `gitlab-ctl reconfigure` 应用更改。
1. 在极狐GitLab 中测试 Git 代码仓库功能。
1. 迁移后从配置中删除旧键，然后重新运行 `gitlab-ctl reconfigure`。

新结构在以下脚本中记录，旧键在新键上方的注释中描述。

```ruby
praefect['configuration'] = {
  # praefect['listen_addr']
  listen_addr: ...,
  # praefect['socket_path']
  socket_path: ...,
  # praefect['prometheus_listen_addr']
  prometheus_listen_addr: ...,
  # praefect['tls_listen_addr']
  tls_listen_addr: ...,
  # praefect['separate_database_metrics']
  prometheus_exclude_database_from_default_metrics: ...,
  auth: {
    # praefect['auth_token']
    token: ...,
    # praefect['auth_transitioning']
    transitioning: ...,
  },
  logging: {
    # praefect['logging_format']
    format: ...,
    # praefect['logging_level']
    level: ...,
  },
  failover: {
    # praefect['failover_enabled']
    enabled: ...,
  },
  background_verification: {
    # praefect['background_verification_delete_invalid_records']
    delete_invalid_records: ...,
    # praefect['background_verification_verification_interval']
    #
    # IMPORTANT:
    # As part of reconfiguring Praefect, disable this feature.
    # Read about this as described previously.
    #
    verification_interval: 0,
  },
  reconciliation: {
    # praefect['reconciliation_scheduling_interval']
    scheduling_interval: ...,
    # praefect['reconciliation_histogram_buckets']. The old value was configured as a string
    # such as '[0, 1, 2]'. The new value must be an array like [0, 1, 2].
    histogram_buckets: ...,
  },
  tls: {
    # praefect['certificate_path']
    certificate_path: ...,
   # praefect['key_path']
    key_path: ...,
  },
  database: {
    # praefect['database_host']
    host: ...,
    # praefect['database_port']
    port: ...,
    # praefect['database_user']
    user: ...,
    # praefect['database_password']
    password: ...,
    # praefect['database_dbname']
    dbname: ...,
    # praefect['database_sslmode']
    sslmode: ...,
    # praefect['database_sslcert']
    sslcert: ...,
    # praefect['database_sslkey']
    sslkey: ...,
    # praefect['database_sslrootcert']
    sslrootcert: ...,
    session_pooled: {
      # praefect['database_direct_host']
      host: ...,
      # praefect['database_direct_port']
      port: ...,
      # praefect['database_direct_user']
      user: ...,
      # praefect['database_direct_password']
      password: ...,
      # praefect['database_direct_dbname']
      dbname: ...,
      # praefect['database_direct_sslmode']
      sslmode: ...,
      # praefect['database_direct_sslcert']
      sslcert: ...,
      # praefect['database_direct_sslkey']
      sslkey: ...,
      # praefect['database_direct_sslrootcert']
      sslrootcert: ...,
    }
  },
  sentry: {
    # praefect['sentry_dsn']
    sentry_dsn: ...,
    # praefect['sentry_environment']
    sentry_environment: ...,
  },
  prometheus: {
    # praefect['prometheus_grpc_latency_buckets']. The old value was configured as a string
    # such as '[0, 1, 2]'. The new value must be an array like [0, 1, 2].
    grpc_latency_buckets: ...,
  },
  # praefect['graceful_stop_timeout']
  graceful_stop_timeout: ...,
  # praefect['virtual_storages']. The old value was a hash map but the new value is an array.
  virtual_storage: [
    {
      # praefect['virtual_storages'][VIRTUAL_STORAGE_NAME]. The name was previously the key in
      # the 'virtual_storages' hash.
      name: ...,
      # praefect['virtual_storages'][VIRTUAL_STORAGE_NAME]['nodes'][NODE_NAME]. The old value was a hash map
      # but the new value is an array.
      node: [
        {
          # praefect['virtual_storages'][VIRTUAL_STORAGE_NAME]['nodes'][NODE_NAME]. Use NODE_NAME key as the
          # storage.
          storage: ...,
          # praefect['virtual_storages'][VIRTUAL_STORAGE_NAME]['nodes'][NODE_NAME]['address'].
          address: ...,
          # praefect['virtual_storages'][VIRTUAL_STORAGE_NAME]['nodes'][NODE_NAME]['token'].
          token: ...,
        },
      ],
    }
  ]
}
```

<a id="disable-the-second-database-connection"></a>

### 禁用第二个数据库连接

在极狐GitLab 16.0 中，极狐GitLab 默认使用两个指向同一 PostgreSQL 数据库的数据库连接。

PostgreSQL 可能需要为 `max_connections` 配置更大的值。
[有一个 Rake 任务用于检查是否需要这样做](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections)。

如果您部署了 PgBouncer：

- 您的 PgBouncer 服务器上的前端连接池（包括文件句柄限制和 `max_client_conn`）[可能需要更大](../../administration/postgresql/pgbouncer.md#fine-tuning)。
- PgBouncer 是单线程的。额外的连接可能会使单个 PgBouncer 守护进程完全饱和。
  [我们建议为所有扩展的极狐GitLab 部署运行三个负载均衡的 PgBouncer 服务器](../../administration/reference_architectures/5k_users.md#configure-pgbouncer)，部分原因是为了解决此问题。

按照您的安装类型的说明切换回单个数据库连接：

{{< tabs >}}

{{< tab title="Linux 软件包和 Docker" >}}

1. 将此设置添加到 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['databases']['ci']['enable'] = false
   ```

1. 运行 `gitlab-ctl reconfigure`。

在多节点环境中，应在所有 Rails 和 Sidekiq 节点上更新此设置。

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

将 `ci.enabled` 键设置为 `false`：

```yaml
global:
  psql:
    ci:
      enabled: false
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

从 `config/database.yml` 中删除 `ci:` 部分。

{{< /tab >}}

{{< /tabs >}}

<a id="long-running-user-type-data-change"></a>

## 长时间运行的用户类型数据更改

对于在 `users` 表中有大量记录的大型极狐GitLab 实例，极狐GitLab 16.0 是必需的升级停靠点。

阈值是 **30,000 个用户**，包括：

- 任何状态的开发人员和其他用户，包括活跃、已阻止和待批准。
- 项目和群组访问令牌的机器人账户。

极狐GitLab 16.0 引入了一个[批量后台迁移](../background_migrations.md#check-for-pending-database-background-migrations)，用于
[将 `user_type` 值从 `NULL` 迁移到 `0`](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/115849)。此
迁移在较大的极狐GitLab 实例上可能需要数天才能完成。在升级到 16.1.0 或更高版本之前，请确保迁移已成功完成。

极狐GitLab 16.1 引入了 `FinalizeUserTypeMigration` 迁移，该迁移确保 16.0 的 `MigrateHumanUserType` 后台迁移完成，如果未完成，则在升级期间同步执行 16.0 的更改。

极狐GitLab 16.2 [实现了 `NOT NULL` 数据库约束](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/122454)，
如果 16.0 迁移未完成，该约束将失败。

如果跳过了 16.0（或 16.0 迁移未完成），后续的 Linux 软件包 (Omnibus) 和 Docker 升级可能会在一小时后失败：

```plaintext
FATAL: Mixlib::ShellOut::CommandTimeout: rails_migration[gitlab-rails]
[..]
Mixlib::ShellOut::CommandTimeout: Command timed out after 3600s:
```

[此问题有一种通过继续完成升级来修复的变通方法](../package/package_troubleshooting.md#error-command-timed-out-after-3600s)。

在变通方法完成数据库更改期间，极狐GitLab 很可能处于不可用状态，生成 `500` 错误。这些错误是由于 Sidekiq 和 Puma 运行的应用程序代码与数据库模式不兼容所致。

在变通方法过程结束时，Sidekiq 和 Puma 会重启以解决该问题。

<a id="undefined-column-error-upgrading-to-162-or-later"></a>

## 升级到 16.2 或更高版本时出现未定义列错误

极狐GitLab 15.11 中的一个错误错误地禁用了私有化部署实例上的数据库更改。有关更多信息，请参阅[议题 408835](https://gitlab.com/gitlab-org/gitlab/-/issues/408835)。

如果您的极狐GitLab 实例首先升级到 15.11.0、15.11.1 或 15.11.2，则数据库模式不正确，升级到极狐GitLab 16.2 或更高版本将失败并显示错误。数据库更改需要先前的修改到位：

```plaintext
PG::UndefinedColumn: ERROR:  column "id_convert_to_bigint" of relation "ci_build_needs" does not exist
LINE 1: ...db_config_name:main*/ UPDATE "ci_build_needs" SET "id_conver...
```

极狐GitLab 15.11.3 为此错误提供了修复，但不会纠正已在运行早期 15.11 版本的实例上的问题。

如果您不确定实例是否受影响，请在[数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)中检查该列：

```sql
select pg_typeof (id_convert_to_bigint) from public.ci_build_needs limit 1;
```

如果您需要变通方法，此查询将失败：

```plaintext
ERROR:  column "id_convert_to_bigintd" does not exist
LINE 1: select pg_typeof (id_convert_to_bigintd) from public.ci_buil...
```

未受影响的实例返回：

```plaintext
 pg_typeof
-----------
 bigint
```

如果您的极狐GitLab 实例的数据库模式是最近创建的，则此问题的变通方法会有所不同：

| 安装版本 | 变通方法 |
| -------------------- | ---------- |
| 15.9 或更早版本      | [15.9](#workaround-instance-created-with-159-or-earlier) |
| 15.10                | [15.10](#workaround-instance-created-with-1510) |
| 15.11                | [15.11](#workaround-instance-created-with-1511) |

大多数实例应使用 15.9 过程。只有非常新的实例才需要 15.10 或 15.11 过程。如果您使用备份和恢复迁移了极狐GitLab，则数据库模式来自原始实例。根据源实例选择变通方法。

以下部分中的命令适用于 Linux 软件包安装，其他安装类型会有所不同：

{{< tabs >}}

{{< tab title="Docker" >}}

- 省略 `sudo`
- 进入极狐GitLab 容器并运行相同的命令：

  ```shell
  docker exec -it <container-id> bash
  ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

- 使用 `sudo -u git -H bundle exec rake RAILS_ENV=production` 而不是 `sudo gitlab-rake`
- 在[您的 PostgreSQL 数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)上运行 SQL

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

- 省略 `sudo`。
- 进入 `toolbox` pod 以运行 Rake 命令：如果无法通过 `PATH` 找到 `gitlab-rake`，可在 `/usr/local/bin` 中找到它。
  - 有关详细信息，请参阅我们的 [Kubernetes 速查表](https://gitlab.cn/docs/charts/troubleshooting/kubernetes_cheat_sheet/#gitlab-specific-kubernetes-information)。
- 在[您的 PostgreSQL 数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)上运行 SQL

{{< /tab >}}

{{< /tabs >}}

<a id="workaround-instance-created-with-159-or-earlier"></a>

### 变通方法：使用 15.9 或更早版本创建的实例

```shell
# Restore schema
sudo gitlab-psql -c "DELETE FROM schema_migrations WHERE version IN ('20230130175512', '20230130104819');"
sudo gitlab-rake db:migrate:up VERSION=20230130175512
sudo gitlab-rake db:migrate:up VERSION=20230130104819

# Re-schedule background migrations
sudo gitlab-rake db:migrate:down VERSION=20230130202201
sudo gitlab-rake db:migrate:down VERSION=20230130110855
sudo gitlab-rake db:migrate:up VERSION=20230130202201
sudo gitlab-rake db:migrate:up VERSION=20230130110855
```

<a id="workaround-instance-created-with-1510"></a>

### 变通方法：使用 15.10 创建的实例

```shell
# Restore schema for sent_notifications
sudo gitlab-psql -c "DELETE FROM schema_migrations WHERE version = '20230130175512';"
sudo gitlab-rake db:migrate:up VERSION=20230130175512

# Re-schedule background migration for sent_notifications
sudo gitlab-rake db:migrate:down VERSION=20230130202201
sudo gitlab-rake db:migrate:up VERSION=20230130202201

# Restore schema for ci_build_needs
sudo gitlab-rake db:migrate:down VERSION=20230321163547
sudo gitlab-psql -c "INSERT INTO schema_migrations (version) VALUES ('20230321163547');"
```

<a id="workaround-instance-created-with-1511"></a>

### 变通方法：使用 15.11 创建的实例

```shell
# Restore schema for sent_notifications
sudo gitlab-rake db:migrate:down VERSION=20230411153310
sudo gitlab-psql -c "INSERT INTO schema_migrations (version) VALUES ('20230411153310');"

# Restore schema for ci_build_needs
sudo gitlab-rake db:migrate:down VERSION=20230321163547
sudo gitlab-psql -c "INSERT INTO schema_migrations (version) VALUES ('20230321163547');"
```
