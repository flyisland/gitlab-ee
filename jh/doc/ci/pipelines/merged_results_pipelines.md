---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用合并结果流水线，在合并前测试源分支和目标分支合并后的代码。
title: 合并结果流水线
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

合并结果流水线会测试一个临时合并提交，该提交合并了源分支和目标分支的代码。此提交不存在于任一分支中，但您可以在流水线详情中查看它。

这种方式有助于验证变更能否与最新目标分支中的代码协同工作，在合并前发现集成问题，并确保不同文件中的变更能够协同工作。

当目标分支中的变更与源分支中的变更发生冲突时，合并结果流水线无法运行。在这些情况下，极狐GitLab 会改为运行标准的合并请求流水线。

<a id="enable-merged-results-pipelines"></a>

## 启用合并结果流水线

先决条件：

- 您必须拥有该项目的维护者或所有者角色。
- 您的`.gitlab-ci.yml` 文件必须已针对[合并请求流水线](merge_request_pipelines.md#prerequisites)进行配置。
- 您的项目必须托管在极狐GitLab 上（而不是 GitHub 或 Bitbucket 等外部代码仓库）。

要在项目中启用合并结果流水线：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并选项**下，选择**启用合并结果流水线**。
1. 选择**保存更改**。

> [!warning]
> 如果您启用此设置，但未在
> `.gitlab-ci.yml` 文件中配置合并请求流水线，您的合并请求可能会卡在未解决状态，
> 或者您的流水线可能会被丢弃。

<a id="troubleshooting"></a>

## 故障排除

使用合并结果流水线时，您可能会遇到以下问题。

<a id="jobs-or-pipelines-run-unexpectedly-with-ruleschangescompare_to"></a>

### 作业或流水线在使用 `rules:changes:compare_to` 时意外运行

在将 `rules:changes:compare_to` 与合并请求流水线一起使用时，您可能会遇到作业或流水线意外运行的情况。

出现此问题是因为合并结果流水线使用临时合并提交作为比较基准。该提交包含来自您的合并请求分支和目标分支的变更，这可能导致规则意外触发。

例如，如果您的合并请求添加了 `src/feature.js`，而目标分支包含 `src/utils.js`，则临时合并提交会同时包含这两个文件。带有 `rules:changes:compare_to: main`的规则会检测到这两处变更，而不仅仅是您的功能文件，并可能触发本应仅针对您的变更运行的作业。

要解决此问题：

- 移除 `compare_to` 参数，以使用默认比较行为。
- 在变更规则中使用更具体的文件路径模式。
- 考虑使用不带 `compare_to`的 `rules:changes`。

<a id="successful-merged-results-pipeline-overrides-a-failed-branch-pipeline"></a>

### 成功的合并结果流水线覆盖失败的分支流水线

当[**流水线必须成功**设置](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge)启用时，您可能会遇到失败的分支流水线被忽略的情况。

出现此问题是由于流水线逻辑的优先级排序。相关改进支持已在 [议题 385841](https://gitlab.com/gitlab-org/gitlab/-/issues/385841)中提出。
