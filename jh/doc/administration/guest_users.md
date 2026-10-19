---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 访客用户
description: 分配具有有限权限的基础访问权限，作为入门级用户角色。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

与其他用户角色相比，拥有访客角色的用户访问权限和可用功能都受到限制。他们的[权限](../user/permissions.md)受到限制，仅提供基本的可见性和交互能力，而不会泄露敏感的项目数据。

拥有访客角色的用户：

- 可以访问公开群组和项目。
- 可以查看项目计划、阻塞项和进度指示器。
- 可以创建并关联新的项目工作项。
- 可以查看高层级的项目信息，例如：
  - 分析
  - 事件报告
  - 议题和史诗
  - 许可证
- 无法在其个人命名空间中创建项目、群组和代码片段。
- 无法修改并非由他们创建的现有数据。
- 无法查看项目中的代码。

<a id="seat-usage"></a>

## 席位使用

- 在极狐GitLab 基础版和专业版中，拥有访客角色的用户计为计费用户，并占用一个许可证席位。
- 在极狐GitLab 旗舰版中，拥有访客角色的用户不计为计费用户，也不占用许可证席位。

> [!note]
> 虽然访客角色通常只提供有限的访问权限，但创建具有 [`View repository code`](../user/custom_roles/abilities.md#source-code-management) 权限的[自定义角色](../user/custom_roles/_index.md)，可以让您在不占用许可证席位的情况下授予对代码仓库中代码的访问权限。添加任何其他权限都会导致该角色占用一个计费席位。

<a id="assign-guest-role-to-users"></a>

## 为用户分配访客角色

先决条件：

- 您必须拥有维护者或所有者角色。

您可以为群组或项目的现有成员分配访客角色，也可以在创建新成员时分配此角色。您可以通过 API（针对[群组](../api/group_members.md#add-a-group-member)或[项目](../api/project_members.md#add-a-member-to-a-project)）或极狐GitLab UI 来完成此操作。

要为群组或项目的现有成员分配访客角色：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组或项目。
1. 选择**管理** > **成员**。
1. 在要为其分配访客角色的群组或项目成员的**角色**列中，选择其当前角色（例如**开发者**）。
1. 在**角色详情**抽屉中，将角色更改为**访客**。
1. 选择**更新角色**。

如果要分配访客角色的用户还不是群组或项目的成员：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组或项目。
1. 选择**管理** > **成员**。
1. 选择**邀请成员**。
1. 在**用户名、姓名或电子邮件地址**中，选择相关用户。
1. 在**选择角色**中，选择**访客**。
1. 可选。在**访问到期日期**中，输入一个日期。
1. 选择**邀请**。
