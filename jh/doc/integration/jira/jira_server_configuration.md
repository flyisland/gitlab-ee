---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create a Jira user, group, and permission scheme to authenticate the Jira issues integration in GitLab.
title: '教程：创建 Jira 凭据'
---

在本教程中，您将设置一个专用的 Jira 用户，并授予其 Jira 议题集成所需的权限。所有步骤均在 Jira 中执行，而非在极狐GitLab 中。

完成本教程后，使用您在此创建的 Jira 用户名和密码，在极狐GitLab 中配置 Jira 议题集成。

创建 Jira 凭据的步骤：

1. [创建一个 Jira 用户](#create-a-jira-user)。
1. [为该用户创建一个 Jira 群组](#create-a-jira-group-for-the-user)。
1. [为该群组创建一个权限方案](#create-a-permission-scheme-for-the-group)。
1. [将权限方案分配到您的项目](#assign-the-permission-scheme-to-your-projects)。

<a id="before-you-begin"></a>

## 准备工作

- 您必须拥有 **Jira 管理员** 或 **Jira 系统管理员**
  [全局权限](https://confluence.atlassian.com/adminjiraserver/managing-global-permissions-938847142.html)。

<a id="create-a-jira-user"></a>

## 创建 Jira 用户

要创建 Jira 用户：

1. 在右上角，选择 **管理员** > **用户管理**。
1. [创建一个新用户账户](https://confluence.atlassian.com/adminjiraserver/create-edit-or-remove-a-user-938847025.html#Create,edit,orremoveauser-CreateusersmanuallyinJira)，并授予其对 Jira 项目的写入权限：

   - 在 **电子邮件地址** 中，输入一个有效的电子邮件地址。
   - 在 **用户名** 中，输入 `gitlab`。
   - 在 **密码** 中，输入一个密码。
     Jira 议题集成不支持 SSO（如 SAML）。

1. 选择 **创建用户**。

您也可以使用已有的用户账户，只要该用户属于具备所需权限的群组即可。

现在您已经创建了一个名为 `gitlab` 的用户，接下来为该用户创建一个群组。

<a id="create-a-jira-group-for-the-user"></a>

## 为用户创建 Jira 群组

为用户创建 Jira 群组的步骤：

1. 在右上角，选择 **管理员** > **用户管理**。
1. 在左侧边栏中，选择 **群组**。
1. 在 **添加群组** 部分，输入群组名称（例如 `gitlab-developers`），
   然后选择 **添加群组**。
1. 要将 `gitlab` 用户添加到 `gitlab-developers` 群组，请选择 **编辑成员**。
   `gitlab-developers` 群组将显示为已选群组。
   <!-- vale gitlab_base.BadPlurals = NO -->
1. 在 **添加成员到已选群组** 部分，输入 `gitlab`。
   <!-- vale gitlab_base.BadPlurals = YES -->
1. 选择 **添加已选用户**。
   `gitlab` 用户将显示为群组成员。

现在您已将 `gitlab` 用户添加到 `gitlab-developers` 群组，接下来为该群组创建权限方案。

<a id="create-a-permission-scheme-for-the-group"></a>

## 为群组创建权限方案

Jira 议题集成需要浏览项目、创建和编辑议题以及添加评论的权限。请仅授予执行这些操作所需的权限。

创建权限方案的步骤：

1. 在右上角，选择 **管理员** > **议题**。
1. 在左侧边栏中，选择 **权限方案**。
1. 选择 **添加权限方案**。
1. 在 **添加权限方案** 对话框中，填写相关字段。
1. 选择 **添加**。
1. 在 **权限方案** 页面，在 **操作** 列中，为新方案选择 **权限**。
1. 对于以下每个权限，选择 **编辑**，将权限授予 `gitlab-developers` 群组，然后选择 **授予**：

   - **浏览项目**
   - **创建议题**
   - **编辑议题**
   - **添加评论**

现在您已配置了权限方案，接下来将其分配到您的 Jira 项目。

<a id="assign-the-permission-scheme-to-your-projects"></a>

## 将权限方案分配到项目

权限方案只有在与至少一个项目关联后才会生效。
请对您希望 Jira 议题集成访问的每个 Jira 项目重复这些步骤。

将权限方案分配到项目的步骤：

1. 在右上角，选择 **管理员** > **项目**。
1. 选择您要配置的项目。
1. 在 **项目设置** 中，选择 **权限**。
1. 选择 **操作** > **使用不同方案**。
1. 选择您创建的方案，然后选择 **关联**。

大功告成！现在前往极狐GitLab，使用您在此创建的 `gitlab` 用户名和密码[配置 Jira 议题集成](configure.md)。