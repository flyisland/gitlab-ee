---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查直接迁移问题
description: "使用 Rails 控制台命令、错误解决方案和配置技巧排查 极狐GitLab 直接迁移问题。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在 [Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)中，你可以使用以下命令查找群组导入尝试的失败或错误信息：

```ruby
# 获取相关的导入记录
import = BulkImports::Entity.where(namespace_id: Group.id).map(&:bulk_import).last

# 通过用户进行备选查找
import = BulkImport.where(user_id: User.find(...)).last

# 获取导入实体列表。每个实体代表一个群组或一个项目
entities = import.entities

# 获取实体失败列表
entities.map(&:failures).flatten

# 通过状态进行备选失败查找
entities.where(status: [-1]).pluck(:destination_name, :destination_namespace, :status)
```

你也可以使用 [API 端点](../../../api/bulk_imports.md#list-all-group-or-project-migration-entities)查看所有已迁移的实体及其相关的任何失败信息。

<a id="migrations-are-slow-or-timing-out"></a>

## 迁移缓慢或超时

如果你在迁移过程中遇到迁移非常缓慢或[超时](../../../administration/instance_limits.md#direct-transfer-migration)的情况，请使用以下策略来减少迁移时间。

<a id="add-sidekiq-workers-to-the-destination-instance"></a>

### 向目标实例添加 Sidekiq 工作进程

如果迁移到私有化部署的 极狐GitLab 实例，为了加快迁移速度，你可以向目标实例添加 Sidekiq 工作进程。在增加 Sidekiq 工作进程数量时，你必须考虑到：

- 无论目标实例上有多少可用的 Sidekiq 工作进程，一次直接迁移最多迁移五个群组或项目。
- 目标实例必须具备处理更多并发作业的能力。如果可以，添加更多 Sidekiq 工作进程可以减少导入每个群组或项目所需的时间。

有关如何向目标实例添加 Sidekiq 工作进程的更多信息，请参见 [Sidekiq 导入配置](../../../administration/sidekiq/configuration_for_imports.md)。

<a id="start-separate-migrations"></a>

### 启动单独的迁移

如果源实例没有资源并行导出五个群组，你可能会遇到延迟和潜在的超时。当源实例资源不足时，目标实例必须等待导出数据变为可用。

为了减少并行导出造成的延迟，请为每个群组单独启动迁移，而不是同时迁移所有群组和项目。由于 极狐GitLab UI 只能迁移顶级群组，你可能需要使用 API 来迁移其子群组中的项目。

<a id="stale-imports"></a>

## 过期的导入

由于源实例或目标实例上的问题，迁移可能会停滞或以 `timeout` 状态结束。
要解决这些问题，请检查源实例和目标实例的日志。

<a id="source-instance"></a>

### 源实例

在源实例上，过期的导入通常是由于内存使用过多，这可能导致 Sidekiq 进程重启并中断导出作业。
目标实例可能会一直等待导出文件，直到迁移最终超时。

要检查[群组](../../../api/group_relations_export.md#retrieve-the-status-of-an-export)或[项目](../../../api/project_relations_export.md#retrieve-the-status-of-an-export)关系是否成功导出，请运行以下命令：

```shell
curl --request GET --location "https://example.gitlab.com/api/v4/projects/:ID/export_relations/status" \
--header "PRIVATE-TOKEN: <your_access_token>"
```

如果一个{{< glossary-tooltip text="relation" >}}的状态不是 `1`，则该关系未成功导出，问题出在源实例上。

你也可以运行以下命令来搜索中断的导出作业。
请记住，Sidekiq 日志可能在重启后轮转，因此请务必同时检查轮转后的日志。

```shell
grep `BulkImports::RelationBatchExportWorker` sidekiq.log | grep "interrupted_count"
```

如果 Sidekiq 重启是导致问题的原因：

- 为导出作业配置一个单独的 Sidekiq 进程。
  更多信息，请参见 [Sidekiq 导入配置](../../../administration/sidekiq/configuration_for_imports.md)。
  如果问题仍然存在，请降低 Sidekiq 并发数以限制同时处理的作业数量。
- 增加 Sidekiq 内存限制：
  如果你的实例有可用内存，请[增加 Sidekiq 进程的最大 RSS 限制](../../../administration/sidekiq/sidekiq_memory_killer.md#configuring-the-limits)。
  例如，你可以将限制从 2 GB 增加到 3 GB 以防止频繁重启。
- 增加最大中断次数：
  为了允许作业在失败前有更多的中断次数，你可以增加
  [`BulkImports::RelationBatchExportWorker`](https://gitlab.com/gitlab-org/gitlab/-/blob/b8e11d267cdd4a00807984f98a9d8d8cfa51602e/app/workers/bulk_imports/relation_batch_export_worker.rb#L4) 的最大中断次数：

  1. 添加以下配置将限制增加到 `20`（默认值为 `3`）：

     ```ruby
     sidekiq_options max_retries_after_interruption: 20
     ```

  1. 重启 Sidekiq 使更改生效。

你现在可以触发一个新的迁移，或使用
[项目关系导出 API](../../../api/project_relations_export.md#schedule-a-new-export-for-a-project) 手动触发导出。
检查[导出状态](../../../api/project_relations_export.md#retrieve-the-status-of-an-export)以查看
关系是否成功导出。

例如，要触发特定项目的导出，请运行以下命令：

```shell
curl --request POST --location "https://example.gitlab.com/api/v4/projects/:ID/export_relations" \
--header "PRIVATE-TOKEN: <your_access_token>" \
--form 'batched="true"'
```

<a id="destination-instance"></a>

### 目标实例

在极少数情况下，目标实例可能无法成功迁移群组或项目。
更多信息，请参见 [issue 498720](https://gitlab.com/gitlab-org/gitlab/-/issues/498720)。

要解决此问题，请使用[导入 API](../../../api/import.md) 迁移失败的群组或项目。
使用此 API，你可以单独迁移特定的群组和项目。

<a id="error-404-group-not-found"></a>

## 错误：`404 Group Not Found`

如果你尝试导入一个路径仅由数字组成的群组（例如 `5000`），极狐GitLab 会尝试通过 ID 而不是路径来查找群组。这会在 极狐GitLab 15.4 及更早版本中导致 `404 Group Not Found` 错误。

要解决此问题，你必须使用以下任一方法更改源群组路径以包含非数字字符：

- 极狐GitLab UI：

  1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
  1. 选择 **设置** > **通用**。
  1. 展开 **高级**。
  1. 在 **更改群组 URL** 下，更改群组 URL 以包含非数字字符。

- [Groups API](../../../api/groups.md#update-group-attributes).

<a id="other-404-errors"></a>

## 其他 `404` 错误

在导入群组时，你可能会收到其他 `404` 错误，例如：

```json
"exception_message": "Unsuccessful response 404 from [FILTERED] Bo...",
"exception_class": "BulkImports::NetworkError",
```

此错误表示从源实例传输时出现问题。要解决此问题，请检查你是否满足源实例上的[先决条件](direct_transfer_migrations.md#prerequisites)。

<a id="mismatched-group-or-project-path-names"></a>

## 群组或项目路径名称不匹配

如果源群组或项目路径不符合[命名规则](../../reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)，该路径会被规范化以确保其有效。例如，`Destination-Project-Path` 会被规范化为 `destination-project-path`。

<a id="error-command-exited-with-error-code-15-and-unable-to-save-filtered-into-filtered"></a>

## 错误：`command exited with error code 15 and Unable to save [FILTERED] into [FILTERED]`

在使用直接迁移时，你可能会在日志中收到 `command exited with error code 15 and Unable to save [FILTERED] into [FILTERED]` 错误。如果你收到此错误，可以安全地忽略它。极狐GitLab 会重试已退出的命令。

<a id="error-batch-export-batch_number-from-source-instance-failed"></a>

## 错误：`Batch export [batch_number] from source instance failed`

在目标实例上，你可能会遇到以下错误：

```plaintext
来自源实例的批次导出 [batch_number] 失败：[source instance error]
```

当源实例无法导出某些记录时，会发生此错误。
最常见的原因是：

- 磁盘空间不足
- 由于内存不足导致 Sidekiq 作业多次中断
- 数据库语句超时

要解决此问题：

1. 识别并修复源实例上的问题。
1. 从目标实例删除部分导入的项目或群组，并启动新的导入。

有关导出失败的关系和批次的更多信息，
请在源实例上使用导出状态 API 端点，包括[项目](../../../api/project_relations_export.md#retrieve-the-status-of-an-export)
和[群组](../../../api/group_relations_export.md#retrieve-the-status-of-an-export)。

<a id="error-duplicate-key-value-violates-unique-constraint"></a>

## 错误：`duplicate key value violates unique constraint`

在导入记录时，你可能会收到以下错误：

```plaintext
PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint
```

以下情况可能发生此错误：

- 处理导入的 Sidekiq 工作进程因高内存或 CPU 使用率而重启。
  为了减少导入期间的 Sidekiq 资源问题：
  - 优化 [Sidekiq 导入配置](../../../administration/sidekiq/configuration_for_imports.md)。
  - 在 `bulk_import_concurrent_pipeline_batch_limit` [应用设置](../../../api/settings.md)中限制并发作业的数量。
- 你正在[将来自不同源群组的群组或项目整合到一个目标群组中](_index.md#known-issues)。
  当来自不同源群组的史诗具有相同的内部 ID（这些 ID 仅在单个群组中唯一）时，将它们导入到单个目标群组
  会导致冲突。此冲突会导致 `PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint` 错误，该错误引用了 `index_issues_on_namespace_id_iid_unique` 或 `index_epics_on_group_id_and_iid`。

<a id="error-importbulkimportsfiledownloadstrategyserviceerror-invalid-content-type"></a>

## 错误：`Import::BulkImports::FileDownloadStrategy::ServiceError Invalid content type`

在 极狐GitLab 实例之间使用直接迁移时，你可能会遇到以下错误：

```plaintext
Import::BulkImports::FileDownloadStrategy::ServiceError Invalid content type
```

此错误与实例之间网络流量的路由方式有关。
如果返回的内容类型不是 `application/gzip`，
你的网络请求可能绕过了极狐GitLab Workhorse。

要解决此问题：

- 检查你的 Ingress 是否配置为通过端口 `8181` 上的极狐GitLab Workhorse 路由流量，而不是直接路由到 Puma。
- 考虑为对象存储启用[代理下载](../../../administration/object_storage.md#proxy-download)。

<a id="milestone-titles-appended-with-imported-xx-datetime"></a>

## 里程碑标题附加了 `(imported-xx-datetime)`

在导入群组时，如果任何群组和项目里程碑标题与目标命名空间中的[现有标题冲突](../../project/milestones/_index.md#milestone-title-rules)，导入的里程碑会在其标题后附加一个唯一后缀。例如，`18.0 (imported-3d-1770206299)`。

要识别这些里程碑，请在目标实例的 `log/importer.log` 文件中搜索以下内容：

```plaintext
正在更新里程碑标题 - 源标题已被现有群组或项目里程碑使用
```

日志条目包括：

- `importable_id`：正在导入的群组的 ID。
- `milestone_title`：正在重命名的里程碑的标题。
- `existing_group_id` 或 `existing_project_id`：包含现有里程碑的群组或项目的 ID。

有了这些信息，你可以找到该里程碑并将标题更新为你喜欢的名称。