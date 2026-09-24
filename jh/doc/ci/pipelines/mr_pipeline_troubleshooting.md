---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查合并请求流水线问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在使用合并请求流水线时，您可能会遇到以下问题。

<a id="two-pipelines-when-pushing-to-a-branch"></a>

## 推送至分支时出现两条流水线

如果您在合并请求中出现重复流水线，则您的流水线可能配置为同时为分支和合并请求运行。调整您的流水线配置以[避免重复流水线](../jobs/job_rules.md#avoid-duplicate-pipelines)。

您可以添加 `workflow:rules` 以[从分支流水线切换到合并请求流水线](../yaml/workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)。
在分支上打开合并请求后，流水线将切换为合并请求流水线。

<a id="two-pipelines-when-pushing-an-invalid-cicd-configuration-file"></a>

## 推送无效的 CI/CD 配置文件时出现两条流水线

如果您将无效的 CI/CD 配置推送到合并请求的分支，流水线选项卡中会出现两条失败的流水线。一条是失败的分支流水线，另一条是失败的合并请求流水线。

修复配置语法后，不应再出现失败的流水线。要查找并修复配置问题，您可以使用：

- [流水线编辑器](../pipeline_editor/_index.md)。
- [CI Lint 工具](../yaml/lint.md)。

<a id="the-merge-requests-pipeline-is-marked-as-failed-but-the-latest-pipeline-succeeded"></a>

## 合并请求的流水线被标记为失败，但最新流水线成功

单个合并请求的 **流水线** 选项卡中可能同时存在分支流水线和合并请求流水线。这可能是[由于配置](../yaml/workflow.md#switch-between-branch-pipelines-and-merge-request-pipelines)，也可能是[意外](#two-pipelines-when-pushing-to-a-branch)造成的。

当项目启用了 [**流水线必须成功**](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge) 并且存在两种流水线类型时，会检查合并请求流水线，而不是分支流水线。

因此，如果 **合并请求流水线** 失败，无论 **分支流水线** 结果如何，MR 流水线结果都会标记为不成功。

但是：
- 这些条件并未强制执行。
- 竞争条件决定使用哪个流水线的结果来阻止或通过合并请求。

此错误在 [议题 384927](https://jihulab.com/gitlab-cn/gitlab/-/issues/384927) 中跟踪。

<a id="an-error-occurred-while-trying-to-run-a-new-pipeline-for-this-merge-request"></a>

## `尝试为此合并请求运行新流水线时发生错误。`

当您在合并请求中选择 **运行流水线**，但项目已不再启用合并请求流水线时，可能会发生此错误。

此错误消息的一些可能原因：
- 项目未启用合并请求流水线，在 **流水线** 选项卡中未列出任何流水线，而您选择了 **运行流水线**。
- 项目以前启用了合并请求流水线，但配置被删除了。例如：
  1. 在创建合并请求时，项目的 `.gitlab-ci.yml` 配置文件中启用了合并请求流水线。
  1. 合并请求的 **流水线** 选项卡中提供了 **运行流水线** 选项，此时选择 **运行流水线** 可能不会导致任何错误。
  1. 项目的 `.gitlab-ci.yml` 文件被更改，移除了合并请求流水线配置。
  1. 分支被变基，以将更新后的配置带入合并请求。
  1. 现在，流水线配置不再支持合并请求流水线，但您选择了 **运行流水线** 来运行合并请求流水线。

如果 **运行流水线** 可用，但项目未启用合并请求流水线，请勿使用此选项。您可以推送提交或变基分支以触发新的分支流水线。

<a id="merge-blocked-pipeline-must-succeed-push-a-new-commit-that-fixes-the-failure-message"></a>

## `合并被阻止：流水线必须成功。推送一个修复失败的新提交` 消息

如果合并请求流水线、[合并结果流水线](merged_results_pipelines.md) 或 [合并火车流水线](merge_trains.md) 失败或被取消，则会显示此消息。当分支流水线失败时不会发生这种情况。

如果合并请求流水线或合并结果流水线被取消或失败，您可以：
- 通过在合并请求的流水线选项卡中选择 **运行流水线**，重新运行整个流水线。
- [仅重试失败的作业](_index.md#view-pipelines)。如果重新运行整个流水线，则无需执行此操作。
- 推送一个新提交以修复失败。

如果合并火车流水线失败，您可以：
- 检查失败并确定是否可以使用 [`/merge` 快速操作](../../user/project/quick_actions.md#merge) 立即将合并请求再次添加到合并火车。
- 通过在合并请求的流水线选项卡中选择 **运行流水线**，重新运行整个流水线，然后再次将合并请求添加到合并火车。
- 推送一个提交以修复失败，然后再次将合并请求添加到合并火车。

如果合并火车流水线在合并请求合并之前被取消，但没有失败，您可以：
- 再次将其添加到合并火车。
