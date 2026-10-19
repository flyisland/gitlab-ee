---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GLQL 数据源
---

<a id="glql-data-sources"></a>

# GLQL 数据源

GLQL 可以查询以下数据源：

| 数据源 | `type` 值 | 描述 |
|---|---|---|
| [工作项](work_items.md) | `Issue`, `Incident`, `TestCase`, `Requirement`, `Task`, `Ticket`, `Objective`, `KeyResult`, `Epic` | 议题、史诗和其他工作项类型。省略 `type` 时的默认值。 |
| [合并请求](merge_requests.md) | `MergeRequest` | 代码审查与合并工作流。 |
| [流水线](pipelines.md) | `Pipeline` | CI/CD 流水线。 |
| [作业](jobs.md) | `Job` | 流水线中的 CI/CD 作业。 |
| [项目](projects.md) | `Project` | 命名空间中的项目。 |

每个数据源都有自己的一组支持字段，用于过滤、显示和排序。

在查询中使用 `type` 字段指定数据源。
例如，`type = Issue` 或 `type = MergeRequest`。
对于支持多种类型的数据源，使用 `in` 运算符跨类型查询。
例如，`type in (Issue, Task)`。