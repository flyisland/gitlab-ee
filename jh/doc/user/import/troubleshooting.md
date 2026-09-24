---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在迁移到极狐GitLab时，你可能会遇到以下问题。

<a id="imported-repository-is-missing-branches"></a>

## 导入的仓库缺少分支

如果导入的仓库不包含源仓库的所有分支：

1. 设置 [环境变量](../../administration/logs/_index.md#override-default-log-level) `IMPORT_DEBUG=true`。
1. 使用[不同的群组、子群组或项目名称](https://gitlab.cn/releases/2023/02/22/gitlab-15-9-released/#re-import-projects-from-external-providers)重新导入。
1. 如果仍然缺少某些分支，请检查 [`importer.log`](../../administration/logs/_index.md#importerlog)（例如，使用 [`jq`](../../administration/logs/log_parsing.md#parsing-gitlab-railsimporterlog)）。

<a id="exception-error-importing-repository-no-such-file-or-directory-rb_sysopen-filename"></a>

## 异常：`导入仓库时出错 - 没有这样的文件或目录 @ rb_sysopen - (文件名)`

当你尝试导入一个仓库源代码的 `tar.gz` 文件下载时，会发生此错误。

导入需要一个 [极狐GitLab 导出](../project/settings/import_export.md#export-a-project-and-its-data) 文件，而不仅仅是仓库下载文件。

<a id="diagnosing-prolonged-or-failed-imports"></a>

## 诊断长时间运行或失败的导入

如果你遇到基于文件的导入长时间延迟或失败，尤其是使用 S3 的导入，以下内容可能有助于确定问题的根本原因：

- [检查导入步骤](#check-import-status)
- [查看日志](#review-logs)
- [识别常见问题](#identify-common-issues)

<a id="check-import-status"></a>

### 检查导入状态

检查导入状态：

1. 使用极狐GitLab API 检查受影响项目的[导入状态](../../api/project_import_export.md#retrieve-the-status-of-a-project-import)。
1. 查看响应中的任何错误消息或状态信息，特别是 `status` 和 `import_error` 值。
1. 记下响应中的 `correlation_id`，它对进一步故障排除至关重要。

<a id="review-logs"></a>

### 查看日志

搜索日志以获取相关信息：

对于私有化部署实例：

1. 检查 [Sidekiq 日志](../../administration/logs/_index.md#sidekiqlog) 和 [`exceptions_json` 日志](../../administration/logs/_index.md#exceptions_jsonlog)。
1. 搜索与 `RepositoryImportWorker` 相关的条目以及来自[检查导入状态](#check-import-status)的关联 ID。
1. 查找 `job_status`、`interrupted_count` 和 `exception` 等字段。

对于 JihuLab.com（仅限极狐GitLab团队成员）：

1. 使用 [Kibana](https://log.gprd.gitlab.net/) 通过类似以下查询来搜索 Sidekiq 日志：

   目标：`pubsub-sidekiq-inf-gprd*`

   ```plaintext
   json.class: "RepositoryImportWorker" 且 json.correlation_id.keyword: "<CORRELATION_ID>"
   ```

   或

   ```plaintext
   json.class: "RepositoryImportWorker" 且 json.meta.project: "<project.full_path>"
   ```

1. 查找与私有化部署实例相同的字段。

<a id="identify-common-issues"></a>

### 识别常见问题

将[查看日志](#review-logs)中收集的信息与以下常见问题对照检查：

- 中断的作业：如果你看到很高的 `interrupted_count` 或表示失败的 `job_status`，则导入作业可能已多次中断并被放入死信队列。
- S3 连接：对于使用 S3 的导入，检查日志中是否有与 S3 相关的错误消息。
- 大型仓库：如果仓库非常大，导入可能会超时。这种情况下，请考虑使用[直接迁移](../group/import/_index.md)。

<a id="support-knowledge-base"></a>

## 支持知识库

如果仍有问题，请参阅 [极狐GitLab 支持知识库](https://support.gitlab.com/hc/en-us/)。