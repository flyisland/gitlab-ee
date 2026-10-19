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
- 合并列车
- 工作负载流水线（仅适用于极狐GitLab Duo Agent Platform）

这些类型的流水线都会显示在合并请求的**流水线**选项卡上。

<a id="branch-pipeline"></a>

## 分支流水线

每次向分支提交更改时，您的流水线都可以运行。

这种类型的流水线称为*分支流水线*。它们在流水线列表中显示 `branch` 标签。

此类流水线默认运行，无需任何配置。

分支流水线：

- 在您向分支推送新提交时运行。
- 可以访问[部分预定义变量](../variables/predefined_variables.md)。
- 当分支是[受保护分支](../../user/project/repository/branches/protected.md)时，可以访问[受保护变量](../variables/_index.md#protect-a-cicd-variable)
  和[受保护 Runner](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)。

<a id="tag-pipeline"></a>

## 标签流水线

每次创建或推送新[标签](../../user/project/repository/tags/_index.md)时，流水线都可以运行。

这种类型的流水线称为*标签流水线*。它们在流水线列表中显示 `tag` 标签。

此类流水线默认运行，无需任何配置。

标签流水线：

- 在您向代码仓库创建/推送新标签时运行。
- 可以访问[部分预定义变量](../variables/predefined_variables.md)。
- 当标签是[受保护标签](../../user/project/protected_tags.md)时，可以访问[受保护变量](../variables/_index.md#protect-a-cicd-variable)
  和[受保护 Runner](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)。

<a id="merge-request-pipeline"></a>

## 合并请求流水线

您可以将流水线配置为每次更改合并请求的源分支时运行，而不是使用分支流水线。

这种类型的流水线称为*合并请求流水线*。它们在流水线列表中显示 `merge request` 标签。

合并请求流水线默认不运行。您必须在 `.gitlab-ci.yml` 文件中将作业配置为以合并请求流水线方式运行。

更多信息，请参见[合并请求流水线](merge_request_pipelines.md)。

<a id="merged-results-pipeline"></a>

## 合并结果流水线

*合并结果流水线*在源分支和目标分支合并后的结果上运行。它是合并请求流水线的一种类型。

这些流水线默认不运行。您必须在 `.gitlab-ci.yml` 文件中将作业配置为以合并请求流水线方式运行，并启用合并结果流水线。

这些流水线在流水线列表中显示 `merged results` 标签。

更多信息，请参见[合并结果流水线](merged_results_pipelines.md)。

<a id="merge-trains"></a>

## 合并列车

在频繁合并到默认分支的项目中，不同合并请求中的更改可能会相互冲突。使用*合并列车*将合并请求放入队列。每个合并请求都会与其他更早的合并请求进行比较，以确保它们能够协同工作。

合并列车与合并结果流水线不同，因为合并结果流水线确保更改与默认分支中的内容兼容，但不包括其他人同时正在合并的内容。

这些流水线默认不运行。您必须在 `.gitlab-ci.yml` 文件中将作业配置为以合并请求流水线方式运行，启用合并结果流水线，并启用合并列车。

这些流水线在流水线列表中显示 `merge train` 标签。

更多信息，请参见[合并列车](merge_trains.md)。

<a id="workload-pipeline"></a>

## 工作负载流水线

工作负载流水线是极狐GitLab Duo Agent Platform 工作负载的执行环境。

工作负载流水线：

- 在遵循以下命名约定的临时 Git 引用上运行：`refs/workloads/<identifier>`。
- 在流水线列表中的来源为 `duo_workflow`。
- 当流水线作业完成或失败时，工作负载引用会自动移除。

可以从 Agent 或平台会话中获取指向工作负载流水线的链接。
