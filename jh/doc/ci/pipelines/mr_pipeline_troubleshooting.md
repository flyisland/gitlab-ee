---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除合并请求流水线
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用合并请求流水线时，您可能会遇到以下问题。

<a id="two-pipelines-when-pushing-to-a-branch"></a>

## 推送到分支时出现两条流水线

如果合并请求中出现重复的流水线，您的流水线可能被配置为同时针对分支和合并请求运行。请调整流水线配置以[避免重复的流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。

您可以添加 `workflow:rules` 来[从分支流水线切换为合并请求流水线](../yaml/workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)。分支上打开合并请求后，流水线会切换为合并请求流水线。

<a id="two-pipelines-when-pushing-an-invalid-cicd-configuration-file"></a>

## 推送无效的 CI/CD 配置文件时出现两条流水线

如果您将无效的 CI/CD 配置推送到合并请求的分支，流水线标签页中会出现两条失败的流水线。一条流水线是失败的分支流水线，另一条是失败的合并请求流水线。

修复配置语法后，不应再出现失败的流水线。要查找并修复配置问题，您可以使用：

- [流水线编辑器](../pipeline_editor/_index.md)。
- [CI lint 工具](../yaml/lint.md)。

<a id="the-merge-requests-pipeline-is-marked-as-failed-but-the-latest-pipeline-succeeded"></a>

## 合并请求的流水线被标记为失败，但最新的流水线已成功

单个合并请求的**流水线**标签页中可能同时存在分支流水线和合并请求流水线。这可能是[由配置导致的](../yaml/workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)，也可能是[意外出现的](#two-pipelines-when-pushing-to-a-branch)。

当项目启用了[**流水线必须成功**](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)且两种流水线类型同时存在时，会检查合并请求流水线，而不是分支流水线。

因此，如果合并请求流水线失败，合并请求流水线结果会被标记为不成功，这与分支流水线的结果无关。

但是：

- 这些条件不会被强制执行。
- 由竞态条件决定使用哪条流水线的结果来阻止或通过合并请求。

此缺陷记录在[议题 384927](https://gitlab.com/gitlab-org/gitlab/-/issues/384927)中。

<a id="an-error-occurred-while-trying-to-run-a-new-pipeline-for-this-merge-request"></a>

## `An error occurred while trying to run a new pipeline for this merge request.`

当您在合并请求中选择**运行流水线**，但项目不再启用合并请求流水线时，可能会出现此错误。

此错误消息的一些可能原因：

- 项目未启用合并请求流水线，**流水线**标签页中未列出任何流水线，
  而您选择了**运行流水线**。
- 项目过去启用了合并请求流水线，但该配置
  已被移除。例如：

  1. 创建合并请求时，项目在`.gitlab-ci.yml` 配置
     文件中启用了合并请求流水线。
  1. 合并请求的**流水线**标签页中提供**运行流水线**选项，
     此时选择**运行流水线**可能不会导致任何错误。
  1. 项目的`.gitlab-ci.yml` 文件被修改，移除了合并请求流水线配置。
  1. 对分支进行变基，将更新后的配置引入合并请求。
  1. 现在流水线配置不再支持合并请求流水线，
     但您选择**运行流水线**来运行合并请求流水线。

如果**运行流水线**可用，但项目未启用合并请求流水线，请不要使用此选项。您可以推送提交或对分支进行变基，以触发新的分支流水线。

<a id="merge-blocked-pipeline-must-succeed-push-a-new-commit-that-fixes-the-failure-message"></a>

## `Merge blocked: pipeline must succeed. Push a new commit that fixes the failure` 消息

如果合并请求流水线、[合并结果流水线](merged_results_pipelines.md)或[合并列车流水线](merge_trains.md)失败或被取消，则会显示此消息。分支流水线失败时不会出现此消息。

如果合并请求流水线或合并结果流水线被取消或失败，您可以：

- 在合并请求的流水线标签页中选择**运行流水线**，重新运行整个流水线。
- [仅重试失败的作业](_index.md#view-pipelines)。如果您重新运行整个流水线，则无需这样做。
- 推送新提交以修复失败。

如果合并列车流水线失败，您可以：

- 检查失败情况，确定是否可以使用[`/merge` 快速操作](../../user/project/quick_actions.md#merge)立即将合并请求再次添加到合并列车。
- 在合并请求的流水线标签页中选择**运行流水线**，重新运行整个流水线，然后再次将合并请求添加到合并列车。
- 推送提交以修复失败，然后再次将合并请求添加到合并列车。

如果合并列车流水线在合并请求合并前被取消，且没有失败，您可以：

- 再次将其添加到合并列车。
