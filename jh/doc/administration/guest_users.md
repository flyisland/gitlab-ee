---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 访客用户
description: 作为入门级用户角色，分配具有有限权限的基本访问权限。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

访客角色的用户与其他用户角色相比，访问权限和功能有限。他们的[权限](../user/permissions.md)受到限制，旨在仅提供基本的可见性和交互，而不会危及敏感项目数据。

访客角色的用户可以：

- 访问公开群组和项目。
- 查看项目计划、阻碍项和进度指示器。
- 创建并链接新的项目工作项。
- 查看高级项目信息，例如：
  - 分析
  - 事件报告
  - 议题和史诗
  - 许可证
- 无法在其个人命名空间中创建项目、群组和代码片段。
- 无法修改其未创建的现有数据。
- 无法查看项目中的代码。

<a id="seat-usage"></a>

## 席位使用

- 在极狐GitLab 基础版和专业版中，访客角色用户计为计费用户并消耗许可证席位。
- 在极狐GitLab 旗舰版中，访客角色用户不计为计费用户，也不消耗许可证席位。

> [!note]
> 虽然访客角色通常提供有限的访问权限，但创建一个具有[`查看仓库代码`](../user/custom_roles/abilities.md#source-code-management)权限的[自定义角色](../user/custom_roles/_index.md)，可让你在无需消耗许可证席位的情况下提供对代码仓库中代码的访问。添加任何其他权限都会导致该角色占用一个计费席位。

<a id="assign-guest-role-to-users"></a>

## 向用户分配访客角色

先决条件：

- 你必须具有维护者或所有者角色。

你可以将访客角色分配给群组或项目的当前成员，或在创建新成员时分配此角色。你可以通过 API（针对[群组](../api/group_members.md#add-a-group-member)或[项目](../api/project_members.md#add-a-member-to-a-project)）或极狐GitLab UI 来执行此操作。

要将访客角色分配给当前群组或项目成员：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组或项目。
1. 选择 **管理** > **成员**。
1. 在你要为其分配访客角色的群组或项目成员的 **角色** 列中，选择其当前角色（例如，**开发者**）。
1. 在 **角色详情** 抽屉中，将角色更改为 **访客**。
1. 选择 **更新角色**。

如果你要分配访客角色的用户还不是群组或项目的成员：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组或项目。
1. 选择 **管理** > **成员**。
1. 选择 **邀请成员**。
1. 在 **用户名、姓名或电子邮件地址** 中，选择相关用户。
1. 在 **选择角色** 中，选择 **访客**。
1. 可选。在 **访问到期日期** 中，输入一个日期。
1. 选择 **邀请**。