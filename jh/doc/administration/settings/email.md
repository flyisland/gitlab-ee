---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 自定义电子邮件通知内容，包括徽标、作者姓名显示和多部分格式。
title: 电子邮件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以自定义从极狐GitLab 实例发送的电子邮件中的部分内容。

<a id="custom-logo"></a>

## 自定义徽标

某些电子邮件页眉中的徽标可以自定义。请参阅[徽标自定义部分](../appearance.md#customize-your-homepage-button)。

<a id="include-author-name-in-email-notification-email-body"></a>

## 在电子邮件通知正文中包含作者姓名

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，极狐GitLab 会使用议题、合并请求或评论作者的电子邮件地址来覆盖通知电子邮件中的发件人地址。启用此设置后，作者的电子邮件地址将包含在电子邮件正文中。

先决条件：

- 管理员访问权限。

要在电子邮件正文中包含作者的电子邮件地址：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 选中 **在电子邮件通知正文中包含作者姓名** 复选框。
1. 选择 **保存更改**。

<a id="enable-multipart-email"></a>

## 启用多部分电子邮件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可以发送多部分格式（HTML 和纯文本）的电子邮件，也可以仅发送纯文本电子邮件。

要启用多部分电子邮件：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 选中 **启用多部分电子邮件** 复选框。
1. 选择 **保存更改**。

<a id="custom-hostname-for-private-commit-emails"></a>

## 私有提交电子邮件的自定义主机名

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此配置选项设置[私有提交电子邮件](../../user/profile/_index.md#use-an-automatically-generated-private-commit-email)的电子邮件主机名。默认情况下，它设置为 `users.noreply.YOUR_CONFIGURED_HOSTNAME`。

要更改私有提交电子邮件中使用的主机名：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 在 **自定义主机名（用于私有提交电子邮件）** 文本框中输入所需的主机名。
1. 选择 **保存更改**。

> [!note]
> 配置主机名后，使用先前主机名的每个私有提交电子邮件将不再被极狐GitLab 识别。这可能会与某些[推送规则](../../user/project/repository/push_rules.md)（例如 `Check whether author is a GitLab user` 和 `Check whether committer is the current authenticated user`）直接冲突。

<a id="custom-additional-text"></a>

## 自定义附加文本

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以在极狐GitLab 发送的任何电子邮件的底部添加附加文本。例如，此附加文本可用于法律、审计或合规目的。

要向电子邮件添加附加文本：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 在 **附加文本** 中，输入您的消息。
1. 选择 **保存更改**。

<a id="user-deactivation-emails"></a>

## 用户停用电子邮件

当用户的账户被停用时，极狐GitLab 会向用户发送电子邮件通知。

要关闭这些通知：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 清除 **启用用户停用电子邮件** 复选框。
1. 选择 **保存更改**。

<a id="custom-additional-text-in-deactivation-emails"></a>

### 停用电子邮件中的自定义附加文本

您可以在极狐GitLab 在用户账户被停用时发送给用户的电子邮件底部添加附加文本。此电子邮件文本与[自定义附加文本](#custom-additional-text)设置是分开的。

要向停用电子邮件添加附加文本：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 在 **停用电子邮件的附加文本** 文本框中，输入您的消息。
1. 选择 **保存更改**。

<a id="group-and-project-access-token-expiry-emails-to-inherited-members"></a>

## 向继承成员发送群组和项目访问令牌过期电子邮件

在极狐GitLab 17.7 及更高版本中，以下继承的群组和项目成员除了直接群组和项目成员外，还可以收到关于即将过期的群组和项目访问令牌的电子邮件：

- 对于群组，继承这些群组的所有者角色的成员。
- 对于项目，继承属于这些群组的项目的维护者或所有者角色的项目成员。

要启用向继承的群组和项目成员发送令牌过期电子邮件：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **电子邮件**。
1. 在 **应将群组和项目访问令牌的过期通知电子邮件发送给** 下，选择 **群组或项目的所有直接和继承成员**。
1. 选中 **对此实例上的所有群组强制执行此设置** 复选框。
1. 选择 **保存更改**。

有关令牌过期电子邮件的更多信息，请参阅：

- 对于群组，请参阅[群组访问令牌过期电子邮件文档](../../user/group/settings/group_access_tokens.md#group-access-token-expiry-emails)。
- 对于项目，请参阅[项目访问令牌过期电子邮件文档](../../user/project/settings/project_access_tokens.md#project-access-token-expiry-emails)。
