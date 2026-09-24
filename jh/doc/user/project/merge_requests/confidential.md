---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: How to create a merge request for a confidential issue without leaking information publicly.
title: 机密议题的合并请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在公开仓库中创建合并请求时，即使是为[机密议题](../issues/confidential_issues.md)创建的合并请求，该合并请求也是公开的。为了避免在处理机密议题时泄露机密信息，请在同命名空间的私有派生仓库中创建合并请求。

角色从父群组继承。如果您在与原始（公开）仓库相同的命名空间（相同群组或子群组）中创建私有派生仓库，开发者将在您的派生仓库中获得相同的权限。这种继承确保了：

- 开发者用户拥有查看机密议题并解决它们所需的权限。
- 您无需单独授权用户访问您的派生仓库。

更多信息，请参阅[极狐GitLab 工程师的补丁发布 Runbook](https://jihulab.com/gitlab-cn/release/docs/blob/master/general/security/engineer.md)。

<a id="create-a-confidential-merge-request"></a>

## 创建机密合并请求

分支默认是公开的。为了保护您工作的机密性，您必须在相同命名空间但在作为下游的私有派生仓库中创建分支和合并请求。如果您在与公开仓库相同的命名空间中创建私有派生仓库，您的派生仓库将继承上游公开仓库的权限。拥有上游公开仓库开发者角色的用户无需您额外操作，即可在您的下游私有派生仓库中自动继承这些上游权限。这些用户可以立即向您的私有派生仓库中的分支推送代码，以帮助修复机密议题。

> [!warning]
> 如果您在与上游仓库不同的命名空间中创建私有派生仓库，可能会暴露机密信息。两个命名空间可能不包含相同的用户。

先决条件：

- 您拥有公开仓库的所有者或维护者角色，因为需要这些角色之一才能[创建子群组](../../group/subgroups/_index.md)。
- 您已经[派生](../repository/forking_workflow.md)了该公开仓库。
- 您的派生仓库的**可见性级别**为**私有**。

创建机密合并请求的步骤：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**计划** > **工作项**，然后按**类型** = **议题**进行筛选，并选择您的议题。
1. 在议题描述下方滚动，然后选择**创建机密合并请求**。
1. 选择满足您需求的选项：
   - 要同时创建分支和合并请求，请选择**创建机密合并请求和分支**。您的合并请求将针对派生仓库的默认分支，而不是公开上游项目的默认分支。
   - 如果只创建分支，请选择**创建分支**。
1. 选择要使用的**项目**。这些项目已启用合并请求，并且您在其中具有开发者角色（或更高权限）。
1. 提供**分支名称**，并选择**源（分支或标记）**。极狐GitLab 会检查这些分支在您的私有派生仓库中是否可用，因为两个分支都必须存在于您选择的派生仓库中。
1. 选择**创建**。

此合并请求针对的是您的私有派生仓库，而不是公开上游项目。您的分支、合并请求和提交都保留在您的私有派生仓库中。这可以防止过早泄露机密信息。

当满足以下条件时，开放一个[从您的派生仓库到上游仓库的合并请求](../repository/forking_workflow.md#merge-changes-back-upstream)：

- 您认为问题已在私有派生仓库中得到解决。
- 您准备将机密提交公开。

<a id="related-topics"></a>

## 相关主题

- [机密议题](../issues/confidential_issues.md)
- [将史诗设为机密](../../group/epics/manage_epics.md#make-an-epic-confidential)
- [添加内部备注](../../discussions/_index.md#add-an-internal-note)
- [机密合并请求的安全实践](https://jihulab.com/gitlab-cn/release/docs/blob/master/general/security/engineer.md#security-releases-critical-non-critical-as-a-developer) 在极狐GitLab