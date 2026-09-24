---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Control GitLab Duo Agent Platform availability for groups, projects, and instances.
title: 控制极狐GitLab Duo Agent Platform 可用性
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Duo Agent Platform 默认开启。
Agent Platform 包含 [一组功能](_index.md)。

您可以开启或关闭 Agent Platform：

- 在 JihuLab.com 上：针对顶级群组。
- 在私有化部署实例上：针对实例。

<a id="turn-gitlab-duo-agent-platform-on-or-off"></a>

## 开启或关闭极狐GitLab Duo Agent Platform

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中，基础版层级在 JihuLab.com 上可使用极狐GitLab 积分。

{{< /history >}}

先决条件：

- 顶级群组的所有者角色。

要为顶级群组开启或关闭 Agent Platform：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo Agent Platform** 下，选中或取消选中 **启用极狐GitLab Duo Agentic Chat、agents 和 flows** 复选框。
1. 选择 **保存更改**。

Agent Platform 可用性的更改将应用于所有子群组和项目。

当 Agent Platform 关闭时，flows 和 [基础 agents](agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off) 的相关设置将被隐藏。

<a id="on-gitlab-self-managed"></a>

### 在私有化部署实例上

先决条件：

- 管理员访问权限。

要为实例开启或关闭 Agent Platform：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo Agent Platform** 下，选中或取消选中 **启用极狐GitLab Duo Agentic Chat、agents 和 flows** 复选框。
1. 选择 **保存更改**。

当 Agent Platform 关闭时，flows 和 [基础 agents](agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off) 的相关设置将被隐藏。

<a id="turn-gitlab-duo-on-or-off"></a>

## 开启或关闭极狐GitLab Duo

极狐GitLab Duo 默认开启。
您可以开启或关闭极狐GitLab Duo：

- 在 JihuLab.com 上：针对顶级群组、其他群组或子群组以及项目。
- 在私有化部署实例上：针对实例、群组或子群组以及项目。

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中，基础版层级在 JihuLab.com 上可使用极狐GitLab 积分。

{{< /history >}}

<a id="for-a-top-level-group"></a>

#### 针对顶级群组

先决条件：

- 顶级群组的所有者角色。

要更改顶级群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo 可用性** 下，选择一个选项。
1. 选择 **保存更改**。

极狐GitLab Duo 可用性的更改将应用于所有子群组和项目。

<a id="for-a-group-or-subgroup"></a>

#### 针对群组或子群组

先决条件：

- 群组或子群组的所有者角色。

要更改群组或子群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或子群组。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **极狐GitLab Duo 可用性** 下，选择一个选项。
1. 选择 **保存更改**。

极狐GitLab Duo 可用性的更改将应用于所有子群组和项目。

<a id="for-a-project"></a>

#### 针对项目

先决条件：

- 项目的所有者或维护者角色。

要更改项目的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo**。
1. 开启或关闭 **极狐GitLab Duo** 开关。
1. 选择 **保存更改**。

<a id="on-gitlab-self-managed"></a>

### 在私有化部署实例上

<a id="for-an-instance"></a>

#### 针对实例

先决条件：

- 管理员访问权限。

要更改实例的极狐GitLab Duo 可用性：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo 可用性** 下，选择一个选项。
1. 选择 **保存更改**。

<a id="for-a-group-or-subgroup"></a>

#### 针对群组或子群组

先决条件：

- 群组或子群组的所有者角色。

要更改群组或子群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或子群组。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **极狐GitLab Duo 可用性** 下，选择一个选项。
1. 选择 **保存更改**。

极狐GitLab Duo 可用性的更改将应用于所有子群组和项目。

<a id="for-a-project"></a>

#### 针对项目

先决条件：

- 项目的所有者或维护者角色。

要更改项目的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo**。
1. 开启或关闭 **极狐GitLab Duo** 开关。
1. 选择 **保存更改**。

<a id="turn-gitlab-duo-core-on-or-off"></a>

## 开启或关闭极狐GitLab Duo Core

极狐GitLab Duo Core 包含在专业版和旗舰版订阅中。

- 如果您是极狐GitLab 17.11 或更早版本的现有客户，必须为极狐GitLab Duo Core 启用功能。
- 如果您是极狐GitLab 18.0 或更高版本的新客户，极狐GitLab Duo Core 会自动启用，无需进一步操作。

如果您在 2025 年 5 月 15 日之前是拥有专业版或旗舰版订阅的现有客户，当您升级到极狐GitLab 18.0 或更高版本时，要使用极狐GitLab Duo Core，必须将其启用。

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中，基础版层级在 JihuLab.com 上可使用极狐GitLab 积分。

{{< /history >}}

先决条件：

- 顶级群组的所有者角色。

要更改顶级群组的极狐GitLab Duo Core 可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo 可用性** 下，选择一个选项。
1. 在 **极狐GitLab Duo Core** 下，选中或取消选中 **启用极狐GitLab Duo Agent Platform 访问** 复选框。
   如果您为极狐GitLab Duo 可用性选择了 **始终关闭**，则无法访问此设置。
1. 选择 **保存更改**。

更改可能需要长达 10 分钟才能生效。

<a id="on-gitlab-self-managed"></a>

### 在私有化部署实例上

先决条件：

- 管理员访问权限。

要更改实例的极狐GitLab Duo Core 可用性：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo 可用性** 下，选择一个选项。
1. 在 **极狐GitLab Duo Core** 下，选中或取消选中 **启用极狐GitLab Duo Agent Platform 访问** 复选框。
   如果您为极狐GitLab Duo 可用性选择了 **始终关闭**，则无法访问此设置。
1. 选择 **保存更改**。

<a id="turn-on-beta-and-experimental-features"></a>

## 启用实验性和 Beta 版功能

默认情况下，实验性和 Beta 版极狐GitLab Duo 功能处于关闭状态。
这些功能受 [测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/) 约束。

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中，基础版层级在 JihuLab.com 上可使用极狐GitLab 积分。

{{< /history >}}

先决条件：

- 顶级群组的所有者角色。

要为顶级群组启用极狐GitLab Duo 实验性和 Beta 版功能：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **功能预览** 下，选择 **启用实验性和 Beta 版极狐GitLab Duo 功能**。
1. 选择 **保存更改**。

此设置 [会级联到属于该群组的所有项目](../project/merge_requests/approvals/settings.md#cascade-settings-from-the-instance-or-top-level-group)。

<a id="on-gitlab-self-managed"></a>

### 在私有化部署实例上

{{< tabs >}}

{{< tab title="在 17.4 及更高版本中" >}}

在极狐GitLab 17.4 及更高版本中，按照以下说明为您的私有化部署实例启用极狐GitLab Duo 实验性和 Beta 版功能。

先决条件：

- 管理员访问权限。

要为实例启用极狐GitLab Duo 实验性和 Beta 版功能：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 展开 **更改配置**。
1. 在 **功能预览** 下，选择 **使用实验性和 Beta 版极狐GitLab Duo 功能**。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="在 17.3 及更早版本中" >}}

先决条件：

- 管理员访问权限。
- 已启用 [网络连接](../../administration/gitlab_duo/configure/gitlab_self_managed.md)。
- 已关闭 [静默模式](../../administration/silent_mode/_index.md)。

要为实例启用极狐GitLab Duo 实验性和 Beta 版功能：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 展开 **更改配置**。
1. 在 **功能预览** 下，选择 **使用实验性和 Beta 版极狐GitLab Duo 功能**。
1. 选择 **保存更改**。
1. 要使极狐GitLab Duo Chat 立即生效，请 [手动同步您的订阅](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。

   如果您不手动同步订阅，在您的实例上激活极狐GitLab Duo Chat 可能需要长达 24 小时。

{{< /tab >}}

{{< /tabs >}}