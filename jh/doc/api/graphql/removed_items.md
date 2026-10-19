---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GraphQL API 已移除项
description: "极狐GitLab GraphQL API 中已弃用和已移除项的列表。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

GraphQL 是不同于 REST API 的无版本 API。有时，必须更新或移除 GraphQL API 中的项目。根据我们的[移除项目的流程](_index.md#deprecation-and-removal-process)，以下是已被移除的项目。

有关弃用信息，请参阅[按版本划分的弃用页面](../../update/deprecations.md)。

<a id="gitlab-170"></a>

## 极狐GitLab 17.0

在极狐GitLab 17.0 中移除的字段。

<a id="graphql-fields"></a>

### GraphQL 字段

| 字段名              | GraphQL 类型 | 弃用于 | 移除 MR   | 替代项                                             |
| -------------------- | ------------ | ------ | --------- | -------------------------------------------------- |
| `architectureName` | `CiRunner`   | 16.2   | !124751   | 请改用 `manager` 对象中的此字段。                  |
| `executorName`     | `CiRunner`   | 16.2   | !124751   | 请改用 `manager` 对象中的此字段。                  |
| `ipAddress`        | `CiRunner`   | 16.2   | !124751   | 请改用 `manager` 对象中的此字段。                  |
| `platformName`     | `CiRunner`   | 16.2   | !124751   | 请改用 `manager` 对象中的此字段。                  |
| `revision`         | `CiRunner`   | 16.2   | !124751   | 请改用 `manager` 对象中的此字段。                  |
| `version`          | `CiRunner`   | 16.2   | !124751   | 请改用 `manager` 对象中的此字段。                  |

<a id="gitlab-160"></a>

## 极狐GitLab 16.0

在极狐GitLab 16.0 中移除的字段。

<a id="graphql-fields-1"></a>

### GraphQL 字段

| 字段名       | GraphQL 类型                 | 弃用于 | 移除 MR   | 替代项                              |
| ------------ | ---------------------------- | ------ | --------- | ----------------------------------- |
| `name`       | `PipelineSecurityReportFinding` | 15.1   | !119055   | `title`                             |
| `external`   | `ReleaseAssetLink`           | 15.9   | !111750   | 无                                   |
| `confidence` | `PipelineSecurityReportFinding` | 15.4   | !118617   | 无                                   |
| `PAUSED`     | `CiRunnerStatus`             | 14.8   | !118635   | `CiRunner.paused: true`             |
| `ACTIVE`     | `CiRunnerStatus`             | 14.8   | !118635   | `CiRunner.paused: false`            |

<a id="graphql-mutations"></a>

### GraphQL 变更

| 参数名 | 变更                           | 弃用于 | 替代项                                                        |
| ------ | ------------------------------ | ------ | ------------------------------------------------------------- |
| -      | `vulnerabilityFindingDismiss`  | 15.5   | `vulnerabilityDismiss` 或 `securityFindingDismiss`             |
| -      | `apiFuzzingCiConfigurationCreate` | 15.1   | `todos`                                                       |
| -      | `CiCdSettingsUpdate`           | 15.0   | `ProjectCiCdSettingsUpdate`                                   |

<a id="gitlab-150"></a>

## 极狐GitLab 15.0

在极狐GitLab 15.0 中移除的字段。

<a id="graphql-mutations-1"></a>

### GraphQL 变更

[于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/85382) 极狐GitLab 15.0 中移除：

| 参数名 | 变更                       | 弃用于 | 替代项                       |
| ------ | -------------------------- | ------ | ---------------------------- |
| -      | `clusterAgentTokenDelete`  | 14.7   | `clusterAgentTokenRevoke`    |

<a id="graphql-fields-2"></a>

### GraphQL 字段

[于](https://gitlab.com/gitlab-org/gitlab/-/issues/342882) 极狐GitLab 15.0 中移除：

| 参数名 | 字段名       | 弃用于 | 替代项 |
| ------ | ------------ | ------ | ------ |
| -      | `pipelines`  | 14.5   | 无      |

<a id="graphql-types"></a>

### GraphQL 类型

| 字段名                                   | GraphQL 类型           | 弃用于 | 替代项                                                                                                             |
| ---------------------------------------- | ---------------------- | ------ | ------------------------------------------------------------------------------------------------------------------ |
| `defaultMergeCommitMessageWithDescription` | `GraphQL::Types::String` | 14.5   | 无。请在您的项目中定义[合并提交模板](../../user/project/merge_requests/commit_templates.md)并使用 `defaultMergeCommitMessage`。 |