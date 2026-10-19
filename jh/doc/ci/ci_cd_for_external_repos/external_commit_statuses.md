---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部提交状态
description: 外部 CI/CD 系统如何使用提交状态与极狐GitLab 流水线集成。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

外部提交状态允许 Jenkins、CircleCI 或自定义部署工具等外部 CI/CD 系统与极狐GitLab 流水线集成。外部系统将提交状态回传到极狐GitLab，状态结果会与 CI/CD 作业一起显示在合并请求和提交视图中。

当外部系统使用[提交 API](../../api/commits.md#set-commit-pipeline-status) 发布提交状态时，极狐GitLab 会将这些状态添加到现有流水线中，或创建新的流水线来容纳它们。

<a id="pipeline-selection"></a>

## 流水线选择

当您从外部系统发布提交状态时，会采用查找或创建的方式：

1. 极狐GitLab 会针对给定的提交 SHA 和 ref 搜索最近的 `non-archived` CI 流水线。您也可以通过包含 `pipeline_id` 参数直接搜索流水线。
1. 如果极狐GitLab 找到合适的流水线，它会将新的作业状态追加到该流水线。对于追加到现有流水线的作业，`CI_PIPELINE_SOURCE` 与流水线来源匹配（例如 `push` 或 `merge_request_event`）。
1. 如果不存在合适的流水线，极狐GitLab 会创建一个新的流水线来容纳该作业。对于新流水线，`CI_PIPELINE_SOURCE` 为 `external`。

外部作业状态会显示在流水线中的 `external` 阶段，与其他极狐GitLab CI/CD 阶段分开。

> [!warning]
> 当同一提交存在重复的流水线时，外部状态的放置会变得不明确。极狐GitLab 使用 `newest_first` 选择最新的流水线，但在并发创建流水线的情况下，这可能导致外部状态出现在意料之外的流水线中，或在合并请求视图中不可见。
>
> 配置[工作流规则](../yaml/workflow.md)以避免重复的流水线，或使用 `pipeline_id` 直接指定流水线。

<a id="job-updates-and-retries"></a>

## 作业更新与重试

当您从外部系统发布提交状态时：

- 如果目标流水线中已存在具有相同 `name`、`user` 和 `sha`的 `running` 或 `pending` 作业，极狐GitLab 会更新其状态。
  - 如果其他用户更新了具有相同 `name`的作业，该作业会被重试。这会创建一个新作业，并从当前流水线中隐藏旧作业。
- 您可以重试一个不是 `running` 或 `pending`的作业，只要它具有相同的 `name` 但不同的 `status`（例如，为标记为 `failed`的作业发送 `success`）。这会创建一个新作业，并从当前流水线中隐藏旧作业。
- 不同的外部服务可以通过使用唯一的作业 `name`，将作业添加到相同的 SHA 和流水线。

如果针对某个 SHA/ref 组合的更新已在进行中，则会返回 `409` 错误。请重试该请求以处理此错误。

<a id="troubleshooting"></a>

## 故障排除

<a id="external-statuses-not-visible-in-merge-requests"></a>

### 合并请求中看不到外部状态

如果外部 CI 状态未出现在合并请求流水线中：

1. 检查您是否针对同一提交同时运行了合并请求和分支流水线。
1. 验证您的[工作流规则](../yaml/workflow.md)可防止重复的流水线。
1. 确认外部系统提交到正确的 ref。
1. 如果该提交与某个合并请求关联，请确保 API 调用指向该合并请求源分支中的提交。

更多信息，请参阅[避免重复的流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。
