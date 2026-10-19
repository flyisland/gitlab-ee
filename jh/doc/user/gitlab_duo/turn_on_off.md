---
stage: Security Governance
group: AI Control Plane
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 关闭实例、群组和项目的极狐GitLab Duo 功能。
title: 控制极狐GitLab Duo 的可用性
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Duo 默认开启。
极狐GitLab Duo 包含一组[功能](feature_summary.md)。

您可以开启或关闭极狐GitLab Duo：

- 在 JihuLab.com 上：针对顶级群组、其他群组或子群组以及项目。
- 在极狐GitLab 私有化部署上：针对实例、群组或子群组以及项目。
<a id="lock-gitlab-duo-on"></a>

## 锁定极狐GitLab Duo 为开启状态

为所有用户开启极狐GitLab Duo，无论群组或项目设置如何。

当您将极狐GitLab Duo 可用性设置为**始终开启**时，
实验和测试版功能不会自动开启。
要使用实验和测试版功能，您必须
[单独开启它们](#turn-on-beta-and-experimental-features)。

{{< tabs >}}

{{< tab title="On GitLab.com" >}}

先决条件：

- 顶级群组的所有者角色。

要为顶级群组锁定极狐GitLab Duo 为开启状态：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择**始终开启**。
1. 选择**保存更改**。

极狐GitLab Duo 已为所有子群组和项目锁定为开启状态。
具有子群组或项目所有者角色的用户无法关闭极狐GitLab Duo。

{{< /tab >}}

{{< tab title="On GitLab Self-Managed" >}}

先决条件：

- 管理员访问权限。
- 满足以下条件之一的实例：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要为实例锁定极狐GitLab Duo 为开启状态：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择**始终开启**。
1. 选择**保存更改**。

极狐GitLab Duo 已为所有群组、子群组和项目锁定为开启状态。
具有群组、子群组或项目所有者角色的用户无法关闭极狐GitLab Duo。

{{< /tab >}}

{{< /tabs >}}

<a id="lock-gitlab-duo-off-for-selected-subgroups"></a>

## 为选定的子群组锁定极狐GitLab Duo 为关闭状态

{{< details >}}

- Tier: 旗舰版
{{< /details >}}

管理员可以将特定子群组锁定为**始终关闭**。
这些子群组中具有所有者角色的用户无法启用极狐GitLab Duo，而其他子群组仍由所有者控制。

该锁定适用于该子群组及其所有后代群组和项目。
具有该子群组或其后代所有者角色的用户无法更改此设置。
受影响的所有者会看到一条消息，提示极狐GitLab Duo 已被父群组锁定。

在任何祖先和后代群组链中只能存在一个锁定。
当您锁定一个子群组时：

- 如果祖先群组已有锁定，则该锁定不会生效。
  您必须先从祖先群组[清除锁定](#clear-the-lock-for-a-subgroup)。
- 如果一个或多个后代子群组已有管理员锁定，系统会提示您确认。
  当您确认时，这些后代子群组上的锁定将被清除，
  并且锁定将应用于您选择的子群组。

<a id="lock-a-subgroup"></a>

### 锁定子群组

先决条件：

要为子群组锁定极狐GitLab Duo 为关闭状态：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 在**命名空间可用性覆盖**部分，找到该子群组。
1. 在该子群组的行中，在**极狐GitLab Duo 可用性**下，选择**始终关闭**。

<a id="clear-the-lock-for-a-subgroup"></a>

### 清除子群组的锁定

先决条件：

要清除子群组的管理员锁定：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 在**命名空间可用性覆盖**部分，找到该子群组。
1. 在该子群组的行中，选择**重置覆盖**。

该子群组将恢复为实例默认设置。
具有该子群组所有者角色的用户现在可以控制极狐GitLab Duo 的可用性。

<a id="turn-gitlab-duo-on-or-off"></a>

## 开启或关闭极狐GitLab Duo

在 JihuLab.com 上，极狐GitLab Duo 席位属于其分配到的用户，而非
分配它的群组。为群组关闭极狐GitLab Duo 可防止成员
在该群组的项目中使用极狐GitLab Duo 功能，但不会撤销他们的
席位。成员仍可在其他已开启极狐GitLab Duo 的群组项目中使用它。

对于 IDE 中的代码建议，当代码仓库无法解析为极狐GitLab
项目时，极狐GitLab 会改用用户的默认命名空间来使用极狐GitLab Duo。如果
该命名空间的极狐GitLab Duo 已关闭，则代码建议不可用。

<a id="on-gitlabcom"></a>

### 在 JihuLab.com 上

<a id="for-a-top-level-group"></a>

#### 针对顶级群组

先决条件：

- 顶级群组的所有者角色。

要更改顶级群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

极狐GitLab Duo 可用性更改将应用于所有子群组和项目。

<a id="for-a-group-or-subgroup"></a>

#### 针对群组或子群组

先决条件：

- 群组或子群组的所有者角色。

要更改群组或子群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组或子群组。
1. 选择**设置** > **常规**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

极狐GitLab Duo 可用性更改将应用于所有子群组和项目。

<a id="for-a-project"></a>

#### 针对项目

先决条件：

- 项目的维护者或所有者角色。

要更改项目的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **常规**。
1. 展开**极狐GitLab Duo**。
1. 开启或关闭**极狐GitLab Duo**开关。
1. 选择**保存更改**。

<a id="on-gitlab-self-managed"></a>

### 在极狐GitLab 私有化部署上

<a id="for-an-instance"></a>

#### 针对实例

先决条件：

- 管理员访问权限。
- 满足以下条件之一的实例：
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

- 群组或子群组的所有者角色。

要更改群组或子群组的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组或子群组。
1. 选择**设置** > **常规**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 选择**保存更改**。

极狐GitLab Duo 可用性更改将应用于所有子群组和项目。

<a id="for-a-project-1"></a>

#### 针对项目

先决条件：

- 项目的维护者或所有者角色。

要更改项目的极狐GitLab Duo 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **常规**。
1. 展开**极狐GitLab Duo**。
1. 开启或关闭**极狐GitLab Duo**开关。
1. 选择**保存更改**。

<a id="for-earlier-gitlab-versions"></a>

### 针对早期极狐GitLab 版本

有关如何在早期极狐GitLab 版本中开启或关闭极狐GitLab Duo 的信息，请参阅
[控制早期极狐GitLab 版本的极狐GitLab Duo 可用性](turn_on_off_earlier.md)。

<a id="turn-gitlab-duo-core-on-or-off"></a>

## 开启或关闭极狐GitLab Duo Core

极狐GitLab Duo Core 包含在专业版和旗舰版订阅中。

- 如果您是极狐GitLab 17.11 或更早版本的现有客户，您必须为极狐GitLab Duo Core 开启功能。
- 如果您是极狐GitLab 18.0 或更高版本的新客户，极狐GitLab Duo Core 会自动开启，无需进一步操作。

如果您是在 2025 年 5 月 15 日之前拥有专业版或旗舰版订阅的现有客户，
那么当您升级到极狐GitLab 18.0 或更高版本时，要使用极狐GitLab Duo Core，您必须将其开启。

<a id="on-gitlabcom-1"></a>

### 在 JihuLab.com 上

先决条件：

- 顶级群组的所有者角色。

要更改顶级群组的极狐GitLab Duo Core 可用性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 在**极狐GitLab Duo Core**下，选中或清除**为极狐GitLab Duo Core 开启功能**复选框。
   如果您为极狐GitLab Duo 可用性选择了**始终关闭**，则无法访问
   此设置。
1. 选择**保存更改**。

更改生效可能需要最多 10 分钟。

<a id="on-gitlab-self-managed-1"></a>

### 在极狐GitLab 私有化部署上

先决条件：

- 管理员访问权限。
- 满足以下条件之一的实例：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要更改实例的极狐GitLab Duo Core 可用性：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo 可用性**下，选择一个选项。
1. 在**极狐GitLab Duo Core**下，选中或清除**为极狐GitLab Duo Core 开启功能**复选框。
   如果您为极狐GitLab Duo 可用性选择了**始终关闭**，则无法访问
   此设置。
1. 选择**保存更改**。

<a id="turn-on-beta-and-experimental-features"></a>

## 开启实验和测试版功能

极狐GitLab Duo 的实验和测试版功能默认关闭。
这些功能受[测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)约束。

<a id="on-gitlabcom-2"></a>

### 在 JihuLab.com 上

先决条件：

- 顶级群组的所有者角色。

要为顶级群组开启极狐GitLab Duo 实验和测试版功能：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**功能预览**下，选择**开启实验和测试版极狐GitLab Duo 功能**。
1. 选择**保存更改**。

此设置会[级联到属于该群组的所有项目](../project/merge_requests/approvals/settings.md#cascade-settings-from-the-instance-or-top-level-group)。

<a id="on-gitlab-self-managed-2"></a>

### 在极狐GitLab 私有化部署上

{{< tabs >}}

{{< tab title="In 17.4 and later" >}}

在极狐GitLab 17.4 及更高版本中，请按照以下说明为您的极狐GitLab 私有化部署实例开启极狐GitLab Duo
实验和测试版功能。

先决条件：

- 管理员访问权限。
- 满足以下条件之一的实例：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。

要为实例开启极狐GitLab Duo 实验和测试版功能：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 展开**更改配置**。
1. 在**功能预览**下，选择**使用实验和测试版极狐GitLab Duo 功能**。
1. 选择**保存更改**。

{{< /tab >}}

{{< tab title="In 17.3 and earlier" >}}

先决条件：

- 管理员访问权限。
- 满足以下条件之一的实例：
  - 具有付费许可证的有效极狐GitLab Duo Pro、Enterprise 或 Self-Hosted 附加组件。
  - 有效的极狐GitLab Credits。
- 已启用[网络连接](../../administration/gitlab_duo/configure/_index.md)。
- 已关闭[静默模式](../../administration/silent_mode/_index.md)。

要为实例开启极狐GitLab Duo 实验和测试版功能：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 展开**更改配置**。
1. 在**功能预览**下，选择**使用实验和测试版极狐GitLab Duo 功能**。
1. 选择**保存更改**。
1. 要使极狐GitLab Duo Chat 立即生效，
   [手动同步您的订阅](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。

   如果您不手动同步订阅，则可能需要最多 24
   小时才能在您的实例上激活极狐GitLab Duo Chat。

{{< /tab >}}

{{< /tabs >}}
