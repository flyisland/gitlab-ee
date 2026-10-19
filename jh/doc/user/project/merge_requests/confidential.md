---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 如何为机密议题创建合并请求，同时避免公开泄露信息。
title: 机密议题的合并请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

公共代码仓库中的合并请求也是公开的，即使您为[机密议题](../issues/confidential_issues.md)创建了合并请求。为避免在处理机密议题时泄露机密信息，请在同一命名空间中的私有 fork 中创建您的合并请求。

角色会从父群组继承。如果您在与原始（公共）代码仓库相同的命名空间（同一群组或子群组）中创建私有 fork，开发者将在您的 fork 中获得相同的权限。这种继承可确保：

- 开发者用户拥有查看机密议题并解决它们所需的权限。
- 您无需向单个用户授予对您的 fork 的访问权限。

更多信息，请参见[面向 GitLab 工程师的补丁版本 runbook](https://gitlab.com/gitlab-org/release/docs/blob/master/general/security/engineer.md)。

<a id="create-a-confidential-merge-request"></a>

## 创建机密合并请求

分支默认是公开的。为保护您工作的机密性，您必须在同一命名空间中创建分支和合并请求，但要在下游的私有 fork 中进行。如果您在与公共代码仓库相同的命名空间中创建私有 fork，您的 fork 会继承上游公共代码仓库的权限。对上游公共代码仓库拥有开发者角色的用户，无需您采取任何操作，即可在您的下游私有 fork 中继承这些上游权限。这些用户可以立即将代码推送到您私有 fork 中的分支，以帮助修复机密议题。

> [!warning]
> 如果您在与上游代码仓库不同的命名空间中创建私有 fork，您的私有 fork 可能会泄露机密信息。这两个命名空间可能不包含相同的用户。

先决条件：

- 您对公共代码仓库拥有维护者或所有者角色，因为您需要其中一种角色才能[创建子群组](../../group/subgroups/_index.md)。
- 您已 [forked](../repository/forking_workflow.md) 该公共代码仓库。
- 您的 fork 的**可见性级别**为**私有**。

要创建机密合并请求：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**计划** > **工作项**，然后按**类型** = **议题**进行筛选并选择您的议题。
1. 向下滚动到议题描述下方，然后选择**创建机密合并请求**。
1. 选择符合您需求的项：
   - 要同时创建分支和合并请求，请选择
     **创建机密合并请求和分支**。您的合并请求
     以您的 fork 的默认分支为目标，而不是公共上游项目的默认分支。
   - 要仅创建分支，请选择**创建分支**。
1. 选择要使用的**项目**。这些项目已启用合并请求，并且您在其中拥有开发者角色（或更高角色）。
1. 提供**分支名称**，并选择**源（分支或标签）**。极狐GitLab
   会检查这些分支在您的私有 fork 中是否可用，因为两个分支都必须在您选择的 fork 中可用。
1. 选择**创建**。

此合并请求以您的私有 fork 为目标，而不是公共上游项目。您的分支、合并请求和提交都保留在您的私有 fork 中。这可以防止过早泄露机密信息。

在以下情况下，[从您的 fork 向上游代码仓库](../repository/forking_workflow.md#merge-changes-back-upstream)发起合并请求：

- 您认为问题已在您的私有 fork 中得到解决。
- 您已准备好公开这些机密提交。
