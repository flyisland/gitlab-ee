---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为 Visual Studio Code、JetBrains IDE、Visual Studio、Eclipse 和 Neovim 配置极狐GitLab 编辑器扩展。
title: 配置编辑器扩展
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为您的极狐GitLab 实例配置编辑器扩展设置。

<a id="create-an-oauth-application"></a>

## 创建 OAuth 应用程序

您可以将编辑器扩展配置为使用 OAuth 应用程序 ID 连接极狐GitLab 并进行身份验证。具体配置步骤因 IDE 而异。

<a id="vs-code"></a>

### VS Code

为 VS Code 创建 OAuth 应用程序：

1. 创建一个[实例级应用程序](../../integration/oauth_provider.md#create-an-instance-wide-application)。
1. 在**重定向 URI**中，输入 `vscode://gitlab.gitlab-workflow/authentication`。
   - 如需指定 Code Insiders 或 Cursor 等其他 IDE，
     请添加多个重定向 URI，以换行符分隔。
1. 选择 `api` 范围。
1. 选择**提交**。
1. 复制**应用程序 ID**。在 VS Code 配置中，将其用于 `gitlab.authentication.oauthClientIds` 设置。

<a id="jetbrains-ides"></a>

### JetBrains IDE

为 JetBrains IDE 创建 OAuth 应用程序：

1. 创建一个[实例级应用程序](../../integration/oauth_provider.md#create-an-instance-wide-application)。
1. 在**重定向 URI**中，输入 `http://127.0.0.1/api/oauth/gitlab/authorization`。
1. 选择 `api` 范围。
1. 选择**提交**。
1. 复制**应用程序 ID**。在 JetBrains IDE 中配置极狐GitLab Duo 插件时使用该 ID。

<a id="require-a-minimum-language-server-version"></a>

## 要求最低语言服务器版本

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](../feature_flags/_index.md) `enforce_language_server_version`。
> 在 JihuLab.com 上，此功能可用，但只能由 JihuLab.com 管理员进行配置。

默认情况下，启用个人访问令牌后，任何版本的 GitLab Language Server 都可以连接到您的极狐GitLab 实例。要阻止旧版本客户端的请求，请配置最低语言服务器版本。低于允许的最低 Language Server 版本的客户端会收到 API 错误。

先决条件：

- 您必须是管理员。

  ```ruby
  # For a specific user
  Feature.enable(:enforce_language_server_version, User.find(1))

  # For this GitLab instance
  Feature.enable(:enforce_language_server_version)
  ```

强制要求最低 GitLab Language Server 版本：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**编辑器扩展**。
1. 勾选**语言服务器限制已启用**。
1. 在 **GitLab Language Server 客户端最低版本**下，输入有效的 GitLab Language Server 版本。

允许任何 GitLab Language Server 客户端：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**编辑器扩展**。
1. 取消勾选**语言服务器限制已启用**。
1. 在 **GitLab Language Server 客户端最低版本**下，输入有效的 GitLab Language Server 版本。

> [!note]
> 不建议允许所有请求。如果您的极狐GitLab 版本高于扩展版本，可能会导致不兼容。
> 您应更新扩展，以获取最新的功能改进、缺陷修复和安全修复。
