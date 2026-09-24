---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use merged results pipelines to test code from source and target branches combined before merging.
title: 合并结果流水线
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

合并结果流水线会测试一个临时合并提交，该提交结合了源分支和目标分支的代码。此提交不存在于任一分支中，但你可以在流水线详情中查看它。

这种方法有助于验证更改与最新目标分支中的代码协同工作，在合并前发现集成问题，并确保不同文件中的更改能一起正常工作。

当目标分支的更改与源分支的更改发生冲突时，合并结果流水线无法运行。在这些情况下，极狐GitLab 会改为运行标准的合并请求流水线。

<a id="enable-merged-results-pipelines"></a>

## 启用合并结果流水线

先决条件：

- 你必须具有项目的维护者或所有者角色。
- 你的 `.gitlab-ci.yml` 文件必须配置了 [合并请求流水线](merge_request_pipelines.md#prerequisites)。
- 你的项目必须托管在 极狐GitLab 上（而不是像 GitHub 或 Bitbucket 这样的外部仓库）。

要在项目中启用合并结果流水线：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并选项** 下，选择 **启用合并结果流水线**。
1. 选择 **保存更改**。

> [!warning]
> 如果你在没有在 `.gitlab-ci.yml` 文件中配置合并请求流水线的情况下启用此设置，你的合并请求可能会陷入未解决状态，或者你的流水线可能会被丢弃。

<a id="troubleshooting"></a>

## 故障排除

在使用合并结果流水线时，你可能会遇到以下问题。

<a id="jobs-or-pipelines-run-unexpectedly-with-ruleschangescompare_to"></a>

### 使用 `rules:changes:compare_to` 时作业或流水线意外运行

当在合并请求流水线中使用 `rules:changes:compare_to` 时，你可能会遇到作业或流水线意外运行的情况。

出现此问题的原因是合并结果流水线使用临时合并提交作为比较的基础。此提交包含来自你的合并请求分支和目标分支的更改，这可能导致规则意外触发。

例如，如果你的合并请求添加了 `src/feature.js`，而目标分支包含 `src/utils.js`，则临时合并提交会包含这两个文件。使用 `rules:changes:compare_to: main` 的规则会检测到这两个更改，而不仅仅是你的功能文件，并且可能会触发本应仅针对你的更改运行的作业。

要解决此问题：

- 移除 `compare_to` 参数以使用默认的比较行为。
- 在更改规则中使用更具体的文件路径模式。
- 考虑使用不带 `compare_to` 的 `rules:changes`。

<a id="successful-merged-results-pipeline-overrides-a-failed-branch-pipeline"></a>

### 成功的合并结果流水线覆盖失败的分支流水线

你可能会遇到这样的情况：当 [**流水线必须成功** 设置](../../user/project/merge_requests/auto_merge.md#require-a-successful-pipeline-for-merge) 被激活时，失败的分支流水线被忽略。

出现此问题是由于流水线逻辑的优先级所致。改进支持已在 [议题 385841](https://jihulab.com/gitlab-cn/gitlab/-/issues/385841) 中提出。