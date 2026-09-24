---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 监控 GitHub 导入
description: "Use Prometheus metrics to monitor GitHub imports into your GitLab Self-Managed instance."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

GitHub 导入器暴露了各种 Prometheus 指标，您可以使用这些指标来监控导入器的健康状况和进度。

## 导入持续时间

| Name                                     | Type      |
|------------------------------------------|-----------|
| `github_importer_total_duration_seconds` | histogram |

该指标跟踪每个导入项目从项目创建到导入过程完成所花费的总时间（以秒为单位）。项目名称以 `namespace/name` 格式存储在 `project` 标签中（例如 `gitlab-org/gitlab`）。

## 导入项目数量

| Name                                | Type    |
|-------------------------------------|---------|
| `github_importer_imported_projects` | counter |

该指标跟踪随时间导入的项目总数。该指标不暴露任何标签。

## GitHub API 调用数量

| Name                            | Type    |
|---------------------------------|---------|
| `github_importer_request_count` | counter |

该指标跟踪所有项目随时间进行的 GitHub API 调用总数。该指标不暴露任何标签。

## 速率限制错误

| Name                              | Type    |
|-----------------------------------|---------|
| `github_importer_rate_limit_hits` | counter |

该指标跟踪所有项目遇到 GitHub 速率限制的次数。该指标不暴露任何标签。

## 导入的议题数量

| Name                              | Type    |
|-----------------------------------|---------|
| `github_importer_imported_issues` | counter |

该指标跟踪所有项目中导入的议题数量。项目名称以 `namespace/name` 格式存储在 `project` 标签中（例如 `gitlab-org/gitlab`）。

## 导入的拉取请求数量

| Name                                     | Type    |
|------------------------------------------|---------|
| `github_importer_imported_pull_requests` | counter |

该指标跟踪所有项目中导入的拉取请求数量。项目名称以 `namespace/name` 格式存储在 `project` 标签中（例如 `gitlab-org/gitlab`）。

## 导入的评论数量

| Name                             | Type    |
|----------------------------------|---------|
| `github_importer_imported_notes` | counter |

该指标跟踪所有项目中导入的评论数量。项目名称以 `namespace/name` 格式存储在 `project` 标签中（例如 `gitlab-org/gitlab`）。

## 导入的拉取请求评审评论数量

| Name                                  | Type    |
|---------------------------------------|---------|
| `github_importer_imported_diff_notes` | counter |

该指标跟踪所有项目中导入的拉取请求评审评论数量。项目名称以 `namespace/name` 格式存储在 `project` 标签中（例如 `gitlab-org/gitlab`）。

## 导入的仓库数量

| Name                                    | Type    |
|-----------------------------------------|---------|
| `github_importer_imported_repositories` | counter |

该指标跟踪所有项目中导入的仓库数量。该指标不暴露任何标签。