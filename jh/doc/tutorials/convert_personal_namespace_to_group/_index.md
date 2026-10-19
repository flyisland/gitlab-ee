---
stage: Tenant Scale
group: Organizations
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：将个人命名空间转换为群组'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

如果您最初使用的是个人[命名空间](../../user/namespace/_index.md)，但发现其功能已无法满足需求，可以改用群组命名空间。使用群组命名空间，您可以创建多个子群组，并管理其成员和权限。

您不必从头开始。您可以创建一个新群组，并将现有项目移动到该群组，以获得这些额外优势。具体方法请参见[教程：将个人项目移动到群组](../move_personal_project_to_group/_index.md)。

您还可以更进一步，将个人命名空间转换为群组命名空间。转换命名空间后，您可以保留现有的用户名和 URL。例如，如果您的用户名为 `alex`，您可以继续为群组使用 `https://gitlab.example.com/alex` URL。

本教程介绍如何通过以下步骤将个人命名空间转换为群组命名空间：

1. [创建群组](#create-a-group)。
1. [将项目从个人命名空间转移到群组](#transfer-projects-from-the-personal-namespace-to-the-group)。
1. [重命名原用户名](#rename-the-original-username)。
1. [将新群组命名空间重命名为原用户名](#rename-the-new-group-namespace-to-the-original-username)。

例如，如果您的个人命名空间用户名为 `alex`，请先创建一个名为 `alex-group`的群组命名空间。然后，将所有项目从 `alex` 移动到 `alex-group` 命名空间。最后，将 `alex` 命名空间重命名为 `alex-user`，并将 `alex-group` 命名空间重命名为现在可用的 `alex` 用户名。

<a id="create-a-group"></a>

## 创建群组

1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建群组**。
1. 在**群组名称**中，输入群组的名称。
1. 在**群组 URL**中，输入群组的路径，该路径将用作命名空间。
   不必担心实际路径，这只是临时的。您将在[最后一步](#rename-the-new-group-namespace-to-the-original-username)中将此 URL 更改为个人命名空间的用户名。
1. 选择[可见性级别](../../user/public_access.md)。
1. 可选。填写信息以个性化您的体验。
1. 选择**创建群组**。

<a id="transfer-projects-from-the-personal-namespace-to-the-group"></a>

## 将项目从个人命名空间转移到群组

接下来，您必须将项目从个人命名空间转移到新群组。一次只能转移一个项目。如果要转移多个项目，则必须为每个项目执行以下步骤。

开始转移过程之前，请确保您：

- 拥有该项目的所有者角色。
- 移除[容器镜像](../../user/packages/container_registry/_index.md#move-or-rename-container-registry-repositories)。
  您无法转移包含容器镜像的项目。
- 移除 npm 软件包。您无法更新包含 npm 软件包的项目的根命名空间。

要将项目转移到群组：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**高级**。
1. 在**转移项目**下，选择要将项目转移到的群组。
1. 选择**转移项目**。
1. 输入项目名称并选择**确认**。

<a id="rename-the-original-username"></a>

## 重命名原用户名

接下来，重命名个人命名空间的原用户名，以便该用户名可供新群组命名空间使用。您可以继续将个人命名空间用于其他个人项目，或者[删除该用户账号](../../user/profile/account/delete_account.md)

从您重命名个人命名空间的那一刻起，该用户名就变为可用状态，因此其他人可能会用它注册账号。为避免这种情况，您应尽快[重命名新群组](#rename-the-new-group-namespace-to-the-original-username)。

要[更改用户名](../../user/profile/_index.md#change-your-username)：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**帐户**。
1. 在**更改用户名**部分，输入新的用户名作为路径。
1. 选择**更新用户名**。

<a id="rename-the-new-group-namespace-to-the-original-username"></a>

## 将新群组命名空间重命名为原用户名

最后，将新群组的 URL 重命名为原个人命名空间的用户名。

要[更改群组路径](../../user/group/manage.md#change-a-groups-path)（群组 URL）：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**高级**部分。
1. 在**更改群组URL** 下，输入用户的原始用户名。
1. 选择**更改群组URL**。

就是这样！您现在已经将个人命名空间转换为群组，这为在项目中开展工作以及与更多成员协作开辟了新的可能性。
