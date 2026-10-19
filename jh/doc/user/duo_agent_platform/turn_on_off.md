---
stage: Security Governance
Group: AI Control Plane
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 控制群组、项目和实例的极狐GitLab Duo Agent Platform 可用性。
title: 控制极狐GitLab Duo Agent Platform 可用性
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Duo Agent Platform 默认开启。
Agent Platform 包含[一组功能](_index.md)。

要使用 Agent Platform，需要[极狐GitLab Credits](../../subscriptions/gitlab_credits.md)。

您可以开启或关闭 Agent Platform：

- 在 JihuLab.com 上：针对顶级群组。
- 在极狐GitLab 私有化部署上：针对实例。

要配置 Agent Platform 的工具治理，请参阅 [Agent 工具治理](../ai-governance/tool-governance.md)。

<a id="turn-gitlab-duo-agent-platform-on-or-off"></a>

## 开启或关闭极狐GitLab Duo Agent Platform

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版

{{< /details >}}

先决条件：

- 拥有顶级群组的所有者角色。

要为顶级群组开启或关闭 Agent Platform：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo Agent Platform** 下，选中或清除**开启极狐GitLab Duo Agentic Chat、Agent 和任务流**复选框。
1. 选择**保存更改**。

Agent Platform 可用性变更会应用于所有子群组和项目。

当 Agent Platform 关闭时，以下功能将被隐藏：

- 任务流和
  [内置 Agent](agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off)的相关设置。
- AI 目录。

<a id="on-gitlab-self-managed"></a>

### 在极狐GitLab 私有化部署上

先决条件：

- 管理员访问权限。
- 实例满足以下条件之一：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要为实例开启或关闭 Agent Platform：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo Agent Platform** 下，选中或清除**开启极狐GitLab Duo Agentic Chat、Agent 和任务流**复选框。
1. 选择**保存更改**。

当 Agent Platform 关闭时，以下功能将被隐藏：

- 任务流、
  [内置 Agent](agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off)
  和极狐GitLab Duo CLI 的相关设置。
- AI 目录。

<a id="lock-gitlab-duo-on"></a>

## 锁定极狐GitLab Duo 为开启状态

为所有用户开启极狐GitLab Duo，无论群组或项目设置如何。

当您将极狐GitLab Duo 可用性设置为**始终开启**时，实验功能和测试版功能不会自动开启。要使用实验功能和测试版功能，您必须[单独开启它们](#turn-on-beta-and-experimental-features)。

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 拥有顶级群组的所有者角色。

要为顶级群组锁定极狐GitLab Duo 为开启状态：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择**始终开启**。
1. 选择**保存更改**。

极狐GitLab Duo 已为所有子群组和项目锁定为开启状态。
拥有子群组或项目所有者角色的用户无法关闭极狐GitLab Duo。

{{< /tab >}}

{{< tab title="私有化部署" >}}

先决条件：

- 管理员访问权限。
- 实例满足以下条件之一：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要为实例锁定极狐GitLab Duo 为开启状态：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择**始终开启**。
1. 选择**保存更改**。

极狐GitLab Duo 已为所有群组、子群组和项目锁定为开启状态。
拥有群组、子群组或项目所有者角色的用户无法关闭极狐GitLab Duo。

{{< /tab >}}

{{< /tabs >}}

<a id="turn-gitlab-duo-on-or-off"></a>

## 开启或关闭极狐GitLab Duo

极狐GitLab Duo 默认开启。
您可以开启或关闭极狐GitLab Duo：

- 在 JihuLab.com 上：针对顶级群组、其他群组或子群组以及项目。
- 在极狐GitLab 私有化部署上：针对实例、群组或子群组以及项目。

<a id="on-gitlabcom-1"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版

{{< /details >}}

<a id="for-a-top-level-group"></a>

#### 针对顶级群组

先决条件：

- 拥有顶级群组的所有者角色。

要更改顶级群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

极狐GitLab Duo 可用性变更会应用于所有子群组和项目。

<a id="for-a-group-or-subgroup"></a>

#### 针对群组或子群组

先决条件：

- 拥有群组或子群组的所有者角色。

要更改群组或子群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组或子群组。
1. 选择**设置** > **通用**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

极狐GitLab Duo 可用性变更会应用于所有子群组和项目。

<a id="for-a-project"></a>

#### 针对项目

先决条件：

- 拥有项目的维护者或所有者角色。

要更改项目的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**极狐GitLab Duo**。
1. 打开或关闭**极狐GitLab Duo** 开关。
1. 选择**保存更改**。

<a id="on-gitlab-self-managed-1"></a>

### 在极狐GitLab 私有化部署上

<a id="for-an-instance"></a>

#### 针对实例

先决条件：

- 管理员访问权限。
- 实例满足以下条件之一：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要更改实例的极狐GitLab Duo 可用性：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

<a id="for-a-group-or-subgroup-1"></a>

#### 针对群组或子群组

先决条件：

- 拥有群组或子群组的所有者角色。

要更改群组或子群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组或子群组。
1. 选择**设置** > **通用**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

极狐GitLab Duo 可用性变更会应用于所有子群组和项目。

<a id="for-a-project-1"></a>

#### 针对项目

先决条件：

- 拥有项目的维护者或所有者角色。

要更改项目的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**极狐GitLab Duo**。
1. 打开或关闭**极狐GitLab Duo** 开关。
1. 选择**保存更改**。

<a id="turn-gitlab-duo-core-on-or-off"></a>

## 开启或关闭极狐GitLab Duo Core

极狐GitLab Duo Core 包含在专业版和旗舰版订阅中。

- 如果您是极狐GitLab 17.11 或更早版本的现有客户，则必须为极狐GitLab Duo Core 开启功能。
- 如果您是极狐GitLab 18.0 或更高版本的新客户，极狐GitLab Duo Core 会自动开启，无需进一步操作。

如果您在 2025 年 5 月 15 日之前已是拥有专业版或旗舰版订阅的现有客户，当您升级到极狐GitLab 18.0 或更高版本时，要使用极狐GitLab Duo Core，您必须将其开启。

<a id="on-gitlabcom-2"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版

{{< /details >}}

先决条件：

- 拥有顶级群组的所有者角色。

要更改顶级群组的极狐GitLab Duo Core 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 在**极狐GitLab Duo Core** 下，选中或清除**为极狐GitLab Duo Core 开启功能**复选框。
   如果您为极狐GitLab Duo 可用性选择了**始终关闭**，则无法访问
   此设置。
1. 选择**保存更改**。

更改生效可能需要最多 10 分钟。

<a id="on-gitlab-self-managed-2"></a>

### 在极狐GitLab 私有化部署上

先决条件：

- 管理员访问权限。
- 实例满足以下条件之一：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要更改实例的极狐GitLab Duo Core 可用性：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 在**极狐GitLab Duo Core** 下，选中或清除**为极狐GitLab Duo Core 开启功能**复选框。
   如果您为极狐GitLab Duo 可用性选择了**始终关闭**，则无法访问
   此设置。
1. 选择**保存更改**。

<a id="turn-on-beta-and-experimental-features"></a>

## 开启测试版和实验性功能

实验性和测试版的极狐GitLab Duo 功能默认关闭。这些功能受[测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)约束。

<a id="on-gitlabcom-3"></a>

### 在 JihuLab.com 上

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版

{{< /details >}}

先决条件：

- 拥有顶级群组的所有者角色。

要为顶级群组开启极狐GitLab Duo 实验功能和测试版功能：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**功能预览**下，选择**开启实验性和测试版极狐GitLab Duo 功能**。
1. 选择**保存更改**。

此设置会[级联到属于该群组的所有项目](../project/merge_requests/approvals/settings.md#cascade-settings-from-the-instance-or-top-level-group)。

<a id="on-gitlab-self-managed-3"></a>

### 在极狐GitLab 私有化部署上

{{< tabs >}}

{{< tab title="在 17.4 及更高版本中" >}}

在极狐GitLab 17.4 及更高版本中，请按照以下说明为您的极狐GitLab 私有化部署实例开启极狐GitLab Duo
实验功能和测试版功能。

先决条件：

- 管理员访问权限。
- 实例满足以下条件之一：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要为实例开启极狐GitLab Duo 实验功能和测试版功能：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 展开**更改配置**。
1. 在**功能预览**下，选择**使用实验性和测试版极狐GitLab Duo 功能**。
1. 选择**保存更改**。

{{< /tab >}}

{{< tab title="在 17.3 及更早版本中" >}}

先决条件：

- 管理员访问权限。
- 实例满足以下条件之一：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。
- 已启用[网络连接](../../administration/gitlab_duo/configure/_index.md)。
- 已关闭[静默模式](../../administration/silent_mode/_index.md)。

要为实例开启极狐GitLab Duo 实验功能和测试版功能：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 展开**更改配置**。
1. 在**功能预览**下，选择**使用实验性和测试版极狐GitLab Duo 功能**。
1. 选择**保存更改**。
1. 要使极狐GitLab Duo Chat 立即生效，
   [手动同步您的订阅](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。

   如果您不手动同步订阅，则可能需要最多 24
   小时才能在您的实例上激活极狐GitLab Duo Chat。

{{< /tab >}}

{{< /tabs >}}
