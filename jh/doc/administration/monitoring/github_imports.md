---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 监控 GitHub 导入
description: "使用 Prometheus 指标监控导入到您的极狐GitLab 私有化部署实例的 GitHub 导入。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

GitHub 导入器会公开多种 Prometheus 指标，您可以使用这些指标来监控导入器的运行状况和进度。

<a id="import-duration-times"></a>

## 导入耗时

| 名称                                     | 类型      |
|------------------------------------------|-----------|
| `github_importer_total_duration_seconds` | histogram |

该指标记录每个已导入项目的总导入耗时（以秒为单位，从项目创建到导入过程结束）。项目名称存储在 `project` 标签中，格式为 `namespace/name`（例如 `gitlab-org/gitlab`）。

<a id="number-of-imported-projects"></a>

## 已导入项目数

| 名称                                | 类型    |
|-------------------------------------|---------|
| `github_importer_imported_projects` | counter |

该指标记录随时间推移已导入的项目总数。该指标不公开任何标签。

<a id="number-of-github-api-calls"></a>

## GitHub API 调用次数

| 名称                            | 类型    |
|---------------------------------|---------|
| `github_importer_request_count` | counter |

该指标记录所有项目随时间推移执行的 GitHub API 调用总数。该指标不公开任何标签。

<a id="rate-limit-errors"></a>

## 速率限制错误

| 名称                              | 类型    |
|-----------------------------------|---------|
| `github_importer_rate_limit_hits` | counter |

该指标记录所有项目触及 GitHub 速率限制的次数。该指标不公开任何标签。

<a id="number-of-imported-issues"></a>

## 已导入议题数

| 名称                              | 类型    |
|-----------------------------------|---------|
| `github_importer_imported_issues` | counter |

该指标记录所有项目中已导入的议题数。

项目名称存储在 `project` 标签中，格式为 `namespace/name`（例如 `gitlab-org/gitlab`）。

<a id="number-of-imported-pull-requests"></a>

## 已导入合并请求数

| 名称                                     | 类型    |
|------------------------------------------|---------|
| `github_importer_imported_pull_requests` | counter |

该指标记录所有项目中已导入的合并请求数。

项目名称存储在 `project` 标签中，格式为 `namespace/name`（例如 `gitlab-org/gitlab`）。

<a id="number-of-imported-comments"></a>

## 已导入评论数

| 名称                             | 类型    |
|----------------------------------|---------|
| `github_importer_imported_notes` | counter |

该指标记录所有项目中已导入的评论数。

项目名称存储在 `project` 标签中，格式为 `namespace/name`（例如 `gitlab-org/gitlab`）。

<a id="number-of-imported-pull-request-review-comments"></a>

## 已导入合并请求评审评论数

| 名称                                  | 类型    |
|---------------------------------------|---------|
| `github_importer_imported_diff_notes` | counter |

该指标记录所有项目中已导入的评论数。

项目名称存储在 `project` 标签中，格式为 `namespace/name`（例如 `gitlab-org/gitlab`）。

<a id="number-of-imported-repositories"></a>

## 已导入代码仓库数

| 名称                                    | 类型    |
|-----------------------------------------|---------|
| `github_importer_imported_repositories` | counter |

该指标记录所有项目中已导入的代码仓库数。该指标不公开任何标签。
