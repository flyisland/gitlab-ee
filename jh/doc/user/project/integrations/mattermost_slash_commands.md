---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Mattermost 斜杠命令
description: "配置 Mattermost 斜杠命令，以便在 Mattermost 聊天环境中运行常见的极狐GitLab 操作。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用[斜杠命令](gitlab_slack_application.md#slash-commands)，在 [Mattermost](https://mattermost.com/) 聊天环境中运行常见的极狐GitLab 操作，例如创建议题。

极狐GitLab 还可以将事件（例如 `issue created`）作为单独配置的 [Mattermost 通知](mattermost.md)的一部分发送到 Mattermost。

有关可用斜杠命令的列表，请参见[斜杠命令](gitlab_slack_application.md#slash-commands)。

<a id="configure-slash-commands"></a>

## 配置斜杠命令

要在 Mattermost 中配置斜杠命令，您必须执行以下步骤。

<a id="enable-custom-slash-commands-in-mattermost"></a>

### 在 Mattermost 中启用自定义斜杠命令

要从 Mattermost 管理员控制台开启自定义斜杠命令：

1. 以具有管理员权限的用户身份登录 Mattermost。
1. 在左上角，选择 Mattermost 标志，然后选择 **系统控制台**。
1. 选择 **集成管理**，并将以下值设置为 `True`：
   - **启用自定义斜杠命令**
   - **启用集成以覆盖用户名**
   - **启用集成以覆盖个人资料图片图标**
1. 选择 **保存**，但不要关闭此浏览器标签页。后续步骤中还需要使用它。

<a id="get-configuration-values-from-gitlab"></a>

### 从极狐GitLab 获取配置值

要从极狐GitLab 获取配置值：

1. 在另一个浏览器标签页中，以具有管理员访问权限的用户身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Mattermost 斜杠命令**。极狐GitLab 会显示 Mattermost 设置的可用值。
1. 复制 **请求 URL** 值。其他所有值均为建议值。
1. 不要关闭此浏览器标签页。后续步骤中还需要使用它。

<a id="create-a-slash-command-in-mattermost"></a>

### 在 Mattermost 中创建斜杠命令

要在 Mattermost 中创建斜杠命令：

1. [在 Mattermost 浏览器标签页中](#enable-custom-slash-commands-in-mattermost)，转到您的团队页面。
1. 在左上角，选择 Mattermost 标志，然后选择 **集成**。
1. 在左侧边栏中，选择 **斜杠命令**。
1. 选择 **添加斜杠命令**。
1. 为您的新命令提供 **显示名称** 和 **描述**。
1. 根据您的应用程序配置提供 **命令触发词**：

   - 如果您只打算将一个项目连接到您的 Mattermost 团队，请使用 `/gitlab` 作为触发词。
   - 如果您打算连接多个项目，请使用与您的项目相关的触发词，例如 `/project-name` 或 `/gitlab-project-name`。
1. 对于 **请求 URL**，[粘贴您从极狐GitLab 复制的值](#get-configuration-values-from-gitlab)。
1. 对于其他所有值，您可以使用极狐GitLab 提供的建议值或您偏好的值。
1. 复制 **令牌** 值，然后选择 **完成**。

<a id="provide-the-mattermost-token-to-gitlab"></a>

### 将 Mattermost 令牌提供给极狐GitLab

在 Mattermost 中创建斜杠命令会生成一个令牌，您必须将其提供给极狐GitLab：

1. [在极狐GitLab 浏览器标签页中](#get-configuration-values-from-gitlab)，选中**活跃**复选框。
1. 在 **令牌** 文本框中，[粘贴您从 Mattermost 复制的令牌](#create-a-slash-command-in-mattermost)。
1. 选择 **保存更改**。

您的斜杠命令现在可以与您的极狐GitLab 项目通信了。

<a id="connect-your-gitlab-account-to-mattermost"></a>

## 将您的极狐GitLab 账号连接到 Mattermost

先决条件：

- 要运行[斜杠命令](gitlab_slack_application.md#slash-commands)，您必须拥有在极狐GitLab 项目中执行该操作的[权限](../../permissions.md#project-permissions)。

要使用 Mattermost 斜杠命令与极狐GitLab 交互：

1. 在 Mattermost 聊天环境中，运行您的新斜杠命令。
1. 选择 **连接您的极狐GitLab 账号** 以授权访问。

您可以在 Mattermost 个人资料页面的 **聊天** 下查看所有已授权的聊天账号。

<a id="troubleshooting"></a>

## 故障排除

当 Mattermost 斜杠命令未在极狐GitLab 中触发事件时：

- 确保您使用的是公开频道。Mattermost webhook 无法访问私有频道。
- 如果您需要私有频道，请编辑 webhook 频道，并选择一个私有频道。所有事件都会发送到指定的频道。
