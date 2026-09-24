---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线类型
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

一个项目中可以运行多种类型的流水线，包括：

- 分支流水线
- 标签流水线
- 合并请求流水线
- 合并结果流水线
- 合并队列
- 工作负载流水线（仅限极狐GitLab Duo Agent Platform）

这些类型的流水线都会出现在合并请求的 **流水线** 标签页上。

<a id="branch-pipeline"></a>

## 分支流水线

每次向分支提交更改时，您的流水线都可以运行。

这种类型的流水线被称为 *分支流水线*。
它们在流水线列表中显示 `branch` 标签。

此流水线默认运行。无需任何配置。

分支流水线：

- 当您向分支推送新的提交时运行。
- 可以访问[一些预定义变量](../variables/predefined_variables.md)。
- 当分支是[受保护分支](../../user/project/repository/branches/protected.md)时，可以访问[受保护变量](../variables/_index.md#protect-a-cicd-variable)
  和[受保护的 Runner](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)。

<a id="tag-pipeline"></a>

## 标签流水线

每次创建或推送一个新的[标签](../../user/project/repository/tags/_index.md)时，流水线都可以运行。

这种类型的流水线被称为 *标签流水线*。
它们在流水线列表中显示 `tag` 标签。

此流水线默认运行。无需任何配置。

标签流水线：

- 当您向仓库创建/推送新标签时运行。
- 可以访问[一些预定义变量](../variables/predefined_variables.md)。
- 当标签是[受保护标签](../../user/project/protected_tags.md)时，可以访问[受保护变量](../variables/_index.md#protect-a-cicd-variable)
  和[受保护的 Runner](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)。

<a id="merge-request-pipeline"></a>

## 合并请求流水线

您可以配置流水线，使其在每次对合并请求的源分支进行更改时运行，而不是使用分支流水线。

这种类型的流水线被称为 *合并请求流水线*。
它们在流水线列表中显示 `merge request` 标签。

合并请求流水线默认不运行。您必须配置
`.gitlab-ci.yml` 文件中的作业，使其作为合并请求流水线运行。

更多信息，请参阅[合并请求流水线](merge_request_pipelines.md)。

<a id="merged-results-pipeline"></a>

## 合并结果流水线

{{< history >}}

- `merged results` 标签在极狐GitLab 16.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/132975)。

{{< /history >}}

*合并结果流水线* 在源分支和目标分支合并后的结果上运行。
它是合并请求流水线的一种。

这些流水线默认不运行。您必须在 `.gitlab-ci.yml` 文件中配置作业
以使其作为合并请求流水线运行，并启用合并结果流水线。

这些流水线在流水线列表中显示 `merged results` 标签。

更多信息，请参阅[合并结果流水线](merged_results_pipelines.md)。

<a id="merge-trains"></a>

## 合并队列

在频繁合并到默认分支的项目中，不同合并请求中的更改
可能会相互冲突。使用 *合并队列* 将合并请求放入队列。
每个合并请求都会与之前较早的合并请求进行比较，以确保它们都能协同工作。

合并队列不同于合并结果流水线，因为合并结果流水线
确保更改与默认分支中的内容协同工作，
而不是与其他正在同时合并的内容协同工作。

这些流水线默认不运行。您必须在 `.gitlab-ci.yml` 文件中配置作业
以使其作为合并请求流水线运行，启用合并结果流水线，并启用合并队列。

这些流水线在流水线列表中显示 `merge train` 标签。

更多信息，请参阅[合并队列](merge_trains.md)。

<a id="workload-pipeline"></a>

## 工作负载流水线

工作负载流水线是极狐GitLab Duo Agent Platform 工作负载的执行环境。

工作负载流水线：

- 运行在遵循此命名约定的临时 Git 引用上：`refs/workloads/<identifier>`。
- 在流水线列表中源为 `duo_workflow`。
- 工作负载引用会在流水线作业完成或失败时自动删除。

可以通过 Agent 或平台会话访问指向工作负载流水线的链接。

---