---
stage: Data Access
group: Database Frameworks
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查后台迁移问题
description: 后台迁移问题的解决方案。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- Linked from `lib/gitlab/database/migrations/batched_background_migration_helpers.rb` -->

<a id="database-migrations-failing-because-of-batched-background-migration-not-finished"></a>

## 数据库迁移因批处理后台迁移未完成而失败

在更新到极狐GitLab 14.2 或更高版本时，数据库迁移可能会失败，并显示类似以下的消息：

```plaintext
StandardError: 发生错误，所有后续迁移已取消：

期望给定配置的批处理后台迁移被标记为“已完成”，但它是“活动”状态：
  {:job_class_name=>"CopyColumnUsingBackgroundMigrationJob",
   :table_name=>"push_event_payloads",
   :column_name=>"event_id",
   :job_arguments=>[["event_id"],
   ["event_id_convert_to_bigint"]]
  }
```

要解决此错误：

- 如果你遵循了 [14.2 版本特定升级说明](https://archives.gitlab.cn/docs/17.3/ee/update/versions/gitlab_14_changes.html#1420)，请[手动完成批处理后台迁移](background_migrations.md#finish-a-failed-migration-manually)。
- 如果你没有遵循这些说明，你必须执行以下任一操作：
  - [回滚并升级](#roll-back-and-follow-the-required-upgrade-path)，在更新到 14.2+ 之前通过所需的版本之一。
  - [向前滚动](#roll-forward-and-finish-the-migrations-on-the-upgraded-version)，保持在当前版本并手动确保批处理迁移成功完成。

<a id="roll-back-and-follow-the-required-upgrade-path"></a>

### 回滚并遵循所需的升级路径

要回滚并遵循所需的升级路径：

1. [回滚并恢复之前安装的版本](../administration/backup_restore/_index.md)。
1. 在更新到 14.2+ 之前，先更新到 14.0.5 或 14.1。
1. [检查](background_migrations.md#check-the-status-of-batched-background-migrations) 批处理后台迁移的状态，并确保在再次尝试升级之前它们都标记为已完成。如果仍有标记为活动的，请[手动完成它们](background_migrations.md#finish-a-failed-migration-manually)。

<a id="roll-forward-and-finish-the-migrations-on-the-upgraded-version"></a>

### 向前滚动并在升级版本上完成迁移

向前滚动的过程取决于是否需要停机。

<a id="for-a-deployment-with-downtime"></a>

#### 对于需要停机的部署

运行所有批处理后台迁移可能需要大量时间，具体取决于极狐GitLab 安装的大小。

1. [检查](background_migrations.md#check-the-status-of-batched-background-migrations) 数据库中批处理后台迁移的状态，并使用适当的参数[手动运行它们](background_migrations.md#finish-a-failed-migration-manually)，直到状态查询不返回任何行。
1. 当所有迁移的状态都标记为完成时，为你的安装重新运行迁移。
1. 从极狐GitLab 升级中[完成数据库迁移](../administration/raketasks/maintenance.md#run-incomplete-database-migrations)：

   ```plaintext
   sudo gitlab-rake db:migrate
   ```

1. 运行重新配置：

   ```plaintext
   sudo gitlab-ctl reconfigure
   ```

1. 完成安装的升级。

<a id="for-a-no-downtime-deployment"></a>

#### 对于零停机部署

由于失败的迁移是部署后迁移，你可以保持在升级版本的运行实例上，并等待批处理后台迁移完成。

1. 从错误消息中[检查](background_migrations.md#check-the-status-of-batched-background-migrations) 批处理后台迁移的状态，并确保它被列为已完成。如果迁移仍处于活动状态，可以：
   - 等待它完成。
   - [手动完成它](background_migrations.md#finish-a-failed-migration-manually)。
1. 为你的安装重新运行迁移，以便完成剩余的部署后迁移。

<a id="advanced-search-migrations-are-stuck"></a>

## 高级搜索迁移卡住

在极狐GitLab 15.0 中，一个名为 `DeleteOrphanedCommit` 的高级搜索迁移可能会在升级过程中永久卡在待处理状态。此问题[已在极狐GitLab 15.1 中修正](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/89539)。

如果你是在极狐GitLab 15.0 中使用高级搜索的私有化部署客户，你会遇到性能下降。要清理迁移，请升级到 15.1 或更高版本。

对于其他卡在待处理问题中的高级搜索迁移，请[重试已停止的迁移](../integration/advanced_search/elasticsearch.md#retry-a-halted-migration)。

如果在所有待处理的高级搜索迁移完成之前升级极狐GitLab，则新版本中已删除的任何待处理迁移将无法执行或重试。在这种情况下，你必须[从头开始重新创建索引](../integration/elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index)。

<a id="error-elasticsearch-version-not-compatible"></a>

## 错误：`Elasticsearch 版本不兼容`

如果你的 Elasticsearch 或 OpenSearch 版本与极狐GitLab 不兼容，索引会暂停以防止数据丢失，并且此消息会记录到 [`elasticsearch.log`](../administration/logs/_index.md#elasticsearchlog)。

要解决此问题，请[确保你的 Elasticsearch 或 OpenSearch 版本与极狐GitLab 兼容](../integration/advanced_search/elasticsearch.md#version-compatibility)。

如果你使用的是兼容版本，请[恢复索引](../integration/advanced_search/elasticsearch.md#resume-indexing)。