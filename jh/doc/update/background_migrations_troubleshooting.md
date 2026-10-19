---
stage: Data Access
group: Database Frameworks
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 后台迁移故障排除
description: 后台迁移相关问题的解决方案。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- Linked from `lib/gitlab/database/migrations/batched_background_migration_helpers.rb` -->

<a id="database-migrations-failing-because-of-batched-background-migration-not-finished"></a>

## 数据库迁移失败，原因是批处理后台迁移未完成

更新到极狐GitLab 14.2 或更高版本时，数据库迁移可能会失败，并显示类似以下的消息：

```plaintext
StandardError: An error has occurred, all later migrations canceled:

Expected batched background migration for the given configuration to be marked as 'finished', but it is 'active':
  {:job_class_name=>"CopyColumnUsingBackgroundMigrationJob",
   :table_name=>"push_event_payloads",
   :column_name=>"event_id",
   :job_arguments=>[["event_id"],
   ["event_id_convert_to_bigint"]]
  }
```

要解决此错误：

- 如果您遵循了 [14.2 的版本特定升级说明](https://archives.docs.gitlab.com/17.3/ee/update/versions/gitlab_14_changes.html#1420)，
  [手动完成批处理后台迁移](background_migrations.md#finish-a-failed-migration-manually)。
- 如果您没有遵循这些说明，则必须执行以下任一操作：
  - 在更新到 14.2+ 之前，[回滚并升级](#roll-back-and-follow-the-required-upgrade-path)经过某个必需的
    版本。
  - [前滚](#roll-forward-and-finish-the-migrations-on-the-upgraded-version)，保持当前
    版本，并手动确保批处理迁移成功完成。

<a id="roll-back-and-follow-the-required-upgrade-path"></a>

### 回滚并遵循必需的升级路径

要回滚并遵循必需的升级路径：

1. [回滚并恢复之前安装的版本](../administration/backup_restore/_index.md)。
1. 在更新到 14.2+ 之前，先更新到 14.0.5 或 14.1。
1. [检查状态](background_migrations.md#check-the-status-of-batched-background-migrations)，确认批处理后台迁移全部标记为已完成，然后再尝试升级。如果仍有任何迁移标记为活动状态，请[手动完成它们](background_migrations.md#finish-a-failed-migration-manually)。

<a id="roll-forward-and-finish-the-migrations-on-the-upgraded-version"></a>

### 前滚并在升级后的版本上完成迁移

前滚的流程取决于是否需要零停机。

<a id="for-a-deployment-with-downtime"></a>

#### 对于需要停机的部署

运行所有批处理后台迁移可能需要大量时间，具体取决于您的极狐GitLab 安装规模。

1. [检查状态](background_migrations.md#check-the-status-of-batched-background-migrations)，查看数据库中
   批处理后台迁移的状态，并使用适当的
   参数[手动运行它们](background_migrations.md#finish-a-failed-migration-manually)，直到状态查询不返回任何行。
1. 当所有迁移的状态都标记为完成时，为您的安装重新运行迁移。
1. 从您的极狐GitLab 升级中[完成数据库迁移](../administration/raketasks/maintenance.md#run-incomplete-database-migrations)：

   ```plaintext
   sudo gitlab-rake db:migrate
   ```

1. 运行重新配置：

   ```plaintext
   sudo gitlab-ctl reconfigure
   ```

1. 完成您的安装升级。

<a id="for-a-no-downtime-deployment"></a>

#### 对于零停机部署

由于失败的迁移是部署后迁移，您可以保持升级后版本的实例继续运行，并等待批处理后台迁移完成。

1. [检查状态](background_migrations.md#check-the-status-of-batched-background-migrations)，查看错误消息中提到的
   批处理后台迁移，并确保它已列为已完成。如果该迁移仍处于活动状态，
   则执行以下任一操作：
   - 等待其完成。
   - [手动完成它](background_migrations.md#finish-a-failed-migration-manually)。
1. 为您的安装重新运行迁移，以便剩余的部署后迁移完成。

<a id="advanced-search-migrations-are-stuck"></a>

## 高级搜索迁移卡住

对于卡在待处理问题中的高级搜索迁移，请[重试已停止的迁移](../integration/advanced_search/elasticsearch.md#retry-a-halted-migration)。

如果在所有待处理的高级搜索迁移完成之前升级极狐GitLab，那么在新版本中已移除的任何待处理迁移都无法执行或重试。在这种情况下，您必须[从头重新创建索引](../integration/elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index)。

<a id="error-elasticsearch-version-not-compatible"></a>

## 错误：`Elasticsearch version not compatible`

如果您的 Elasticsearch 或 OpenSearch 版本与极狐GitLab 不兼容，
索引会暂停以防止数据丢失，并将此消息记录到 [`elasticsearch.log`](../administration/logs/_index.md#elasticsearchlog)。

要解决此问题，请[确保您的 Elasticsearch 或 OpenSearch 版本与极狐GitLab 兼容](../integration/advanced_search/elasticsearch.md#version-compatibility)。

如果您使用的是兼容版本，请[恢复索引](../integration/advanced_search/elasticsearch.md#resume-indexing)。
