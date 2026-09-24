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

如果你从个人[命名空间](../../user/namespace/_index.md)开始，但发现它已无法满足你的需求，你可以切换到群组命名空间。
通过群组命名空间，你可以创建多个子群组并管理其成员与权限。

你无需从零开始。你可以创建一个新群组并将现有项目移至该群组，以获得额外的好处。
了解具体方法，请参阅[教程：将个人项目移至群组](../move_personal_project_to_group/_index.md)。

你还可以更进一步，将个人命名空间转换为群组命名空间。
转换命名空间可以让你保留现有的用户名和 URL。例如，如果你的用户名是 `alex`，你可以继续使用 `https://gitlab.example.com/alex` 作为你的群组 URL。

本教程将指导你通过以下步骤将个人命名空间转换为群组命名空间：

1. [创建群组](#create-a-group)。
1. [将项目从个人命名空间转移到群组](#transfer-projects-from-the-personal-namespace-to-the-group)。
1. [重命名原始用户名](#rename-the-original-username)。
1. [将新群组命名空间重命名为原始用户名](#rename-the-new-group-namespace-to-the-original-username)。

例如，如果你的个人命名空间用户名为 `alex`，首先创建一个名为 `alex-group` 的群组命名空间。然后将所有项目从 `alex` 移至 `alex-group` 命名空间。最后，将 `alex` 命名空间重命名为 `alex-user`，并将 `alex-group` 命名空间重命名为现在可用的 `alex` 用户名。

<a id="create-a-group"></a>

## 创建群组

1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新群组**。
1. 在 **群组名称** 中，输入群组的名称。
1. 在 **群组 URL** 中，输入群组的路径，该路径用作命名空间。
   请不要担心实际路径，这只是临时的。你将在[最后一步](#rename-the-new-group-namespace-to-the-original-username)中将此 URL 更改为个人命名空间的用户名。
1. 选择[可见性级别](../../user/public_access.md)。
1. 可选。填写信息以个性化你的体验。
1. 选择 **创建群组**。

<a id="transfer-projects-from-the-personal-namespace-to-the-group"></a>

## 将项目从个人命名空间转移到群组

接下来，你必须将项目从个人命名空间转移到新群组。
你一次只能转移一个项目。如果需要转移多个项目，就必须针对每个项目执行以下步骤。

在开始转移过程之前，请确保你：

- 拥有该项目的所有者角色。
- 移除[容器镜像](../../user/packages/container_registry/_index.md#move-or-rename-container-registry-repositories)。你不能转移包含容器镜像的项目。
- 移除 npm 软件包。你不能更新包含 npm 软件包的项目的根命名空间。

要将项目转移至群组：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 在 **转移项目** 下，选择要将项目转移到的群组。
1. 选择 **转移项目**。
1. 输入项目名称并选择 **确认**。

<a id="rename-the-original-username"></a>

## 重命名原始用户名

接下来，重命名个人命名空间的原始用户名，以便该用户名可供新群组命名空间使用。
你可以继续使用个人命名空间处理其他个人项目，或者[删除该用户账户](../../user/profile/account/delete_account.md)。

从你重命名个人命名空间的那一刻起，该用户名就已可用，因此其他人有可能用它注册账户。为了避免这种情况，你应该尽快[重命名新群组](#rename-the-new-group-namespace-to-the-original-username)。

要[更改用户的用户名](../../user/profile/_index.md#change-your-username)：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **账户**。
1. 在 **更改用户名** 部分，输入一个新用户名作为路径。
1. 选择 **更新用户名**。

<a id="rename-the-new-group-namespace-to-the-original-username"></a>

## 将新群组命名空间重命名为原始用户名

最后，将新群组的 URL 重命名为原始个人命名空间的用户名。

要[更改群组路径](../../user/group/manage.md#change-a-groups-path)（群组 URL）：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级** 部分。
1. 在 **更改群组 URL** 下，输入用户的原始用户名。
1. 选择 **更改群组 URL**。

就是这样！你现在已经将个人命名空间转换为群组，这为项目协作和更多成员参与带来了新的可能。

