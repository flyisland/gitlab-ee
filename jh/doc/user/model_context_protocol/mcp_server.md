---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用极狐GitLab MCP 服务器，将 AI 工具连接到您的极狐GitLab 实例。
title: 极狐GitLab MCP 服务器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!warning]
> 要提供有关此功能的反馈，请在 [议题 561564](https://gitlab.com/gitlab-org/gitlab/-/issues/561564) 上留下评论。

借助极狐GitLab [模型上下文协议](https://modelcontextprotocol.io/)（MCP）服务器，
您可以安全地将 AI 工具和应用程序连接到您的极狐GitLab 实例。
Claude Desktop、Claude Code、Cursor 等 AI 助手以及其他兼容 MCP 的工具
随后即可访问您的极狐GitLab 数据并代表您执行操作。

极狐GitLab MCP 服务器为 AI 工具提供了一种标准化方式来：

- 访问极狐GitLab 项目信息。
- 检索议题和合并请求数据。
- 安全地与极狐GitLab API 交互。
- 通过 AI 助手执行极狐GitLab 特定操作。

极狐GitLab MCP 服务器支持 [OAuth 2.0 动态客户端注册](https://tools.ietf.org/html/rfc7591)，
这使得 AI 工具能够在您的极狐GitLab 实例上自行注册。当 AI 工具首次连接到
您的极狐GitLab MCP 服务器时，它会：

1. 将自身注册为 OAuth 应用程序。
1. 请求授权以访问您的极狐GitLab 数据。
1. 接收用于安全 API 访问的访问令牌。

如需点击式演示，请参阅 [极狐GitLab Duo Agent Platform - 极狐GitLab MCP 服务器](https://gitlab.navattic.com/gitlab-mcp-server)。
<!-- Demo published on 2025-09-11 -->

<a id="prerequisites"></a>

## 先决条件

- 将极狐GitLab Duo 可用性设置为 **始终开启** 或 **默认开启**：
  - 在 JihuLab.com 上，[为顶级群组设置](../gitlab_duo/turn_on_off.md#for-a-top-level-group)。
  - 在极狐GitLab 私有化部署上，[为实例设置](../gitlab_duo/turn_on_off.md#for-an-instance)。
- 开启测试版和实验性功能：
  - 在 JihuLab.com 上，[为顶级群组设置](../gitlab_duo/turn_on_off.md#on-gitlabcom-2)。
  - 在极狐GitLab 私有化部署上，[为实例设置](../gitlab_duo/turn_on_off.md#on-gitlab-self-managed-2)。
- 允许访问 MCP 服务器：
  - 在 JihuLab.com 上，[为顶级群组设置](../group/access_and_permissions.md#allow-access-to-the-mcp-server)。
  - 在极狐GitLab 私有化部署上，[为实例设置](../../administration/settings/visibility_and_access_controls.md#allow-access-to-the-mcp-server)。

<a id="connect-a-client-to-the-gitlab-mcp-server"></a>

## 将客户端连接到极狐GitLab MCP 服务器

极狐GitLab MCP 服务器支持两种传输类型：

- **HTTP 传输（推荐）**：直接连接，无需额外依赖。
- **通过 `mcp-remote` 的 stdio 传输**：通过代理连接（需要 Node.js）。

常见的 AI 工具支持 `mcpServers` 键的 JSON 配置格式，
并提供不同的方法来配置极狐GitLab MCP 服务器设置。

<a id="http-transport-recommended"></a>

### HTTP 传输（推荐）

要使用 HTTP 传输配置极狐GitLab MCP 服务器，请使用以下格式：

- 将 `<gitlab.example.com>` 替换为：
  - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
  - 在 JihuLab.com 上，替换为 `gitlab.com`。

```json
{
  "mcpServers": {
    "GitLab": {
      "type": "http",
      "url": "https://<gitlab.example.com>/api/v4/mcp"
    }
  }
}
```

您可以通过配置
`X-Gitlab-Mcp-Server-Tool-Name-Prefix` HTTP 头来为工具名称添加前缀。
添加前缀有助于避免工具名称与您配置中的其他 MCP 服务器
或多个极狐GitLab 实例发生冲突。

如果前缀超过 32 个字符，将被截断为前 32 个字符。

```json
{
  "mcpServers": {
    "GitLab": {
      "type": "http",
      "url": "https://<gitlab.example.com>/api/v4/mcp",
      "headers": {
        "X-Gitlab-Mcp-Server-Tool-Name-Prefix": "gitlab_"
      }
    }
  }
}
```

<a id="stdio-transport-with-mcp-remote"></a>

### 通过 `mcp-remote` 的 stdio 传输

先决条件：

- 安装 Node.js 20 或更高版本。

要使用 stdio 传输配置极狐GitLab MCP 服务器，请使用以下格式：

- 对于 `"command":` 参数，如果 `npx` 是本地安装而非全局安装，请提供 `npx` 的完整路径。
- 将 `<gitlab.example.com>` 替换为：
  - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
  - 在 JihuLab.com 上，替换为 `gitlab.com`。

```json
{
  "mcpServers": {
    "GitLab": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://<gitlab.example.com>/api/v4/mcp"
      ]
    }
  }
}
```

<a id="connect-cursor-to-the-gitlab-mcp-server"></a>

## 将 Cursor 连接到极狐GitLab MCP 服务器

Cursor 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 Cursor 中配置极狐GitLab MCP 服务器：

1. 在 Cursor 中，转到 **设置** > **Cursor 设置** > **工具和 MCP**。
1. 在 **已安装的 MCP 服务器** 下，选择 **新建 MCP 服务器**。
1. 在打开的 `mcp.json` 文件中，将此定义添加到 `mcpServers` 键：
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。

   ```json
   {
     "mcpServers": {
       "GitLab": {
          "type": "http",
          "url": "https://<gitlab.example.com>/api/v4/mcp"
       }
     }
   }
   ```

1. 保存文件，然后等待浏览器打开 OAuth 授权页面。

   如果未发生此情况，请关闭并重新启动 Cursor。
1. 在浏览器中，查看并批准授权请求。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-claude-code-to-the-gitlab-mcp-server"></a>

## 将 Claude Code 连接到极狐GitLab MCP 服务器

Claude Code 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 Claude Code 中配置极狐GitLab MCP 服务器：

1. 在您的终端中，使用 CLI 添加极狐GitLab MCP 服务器：
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。

   ```shell
   claude mcp add --transport http GitLab https://<gitlab.example.com>/api/v4/mcp
   ```

1. 启动 Claude Code：

   ```shell
   claude
   ```

1. 使用极狐GitLab MCP 服务器进行身份验证：
   - 在聊天中，输入 `/mcp`。
   - 从列表中选择您的极狐GitLab 服务器。
   - 在浏览器中，查看并批准授权请求。

1. 可选。要验证连接，请再次输入 `/mcp`。
   您的极狐GitLab 服务器应显示为已连接。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-claude-desktop-to-the-gitlab-mcp-server"></a>

## 将 Claude Desktop 连接到极狐GitLab MCP 服务器

先决条件：

- 安装 Node.js 20 或更高版本。
- 确保 Node.js 在 `PATH` 环境变量中全局可用（`which -a node`）。

要在 Claude Desktop 中配置极狐GitLab MCP 服务器：

1. 打开 Claude Desktop。
1. 编辑配置文件。您可以执行以下任一操作：
   - 在 Claude Desktop 中，转到 **设置** > **开发者** > **编辑配置**。
   - 在 macOS 上，打开 `~/Library/Application Support/Claude/claude_desktop_config.json` 文件。
1. 为极狐GitLab MCP 服务器添加此条目，并根据需要进行编辑：
   - 对于 `"command":` 参数，如果 `npx` 是本地安装而非全局安装，请提供 `npx` 的完整路径。
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `GitLab.com`。

   ```json
   {
     "mcpServers": {
       "GitLab": {
         "command": "npx",
         "args": [
           "-y",
           "mcp-remote",
           "https://<gitlab.example.com>/api/v4/mcp"
         ]
       }
     }
   }
   ```

1. 保存配置并重新启动 Claude Desktop。
1. 首次连接时，Claude Desktop 会打开浏览器窗口进行 OAuth。查看并批准请求。
1. 转到 **设置** > **开发者** 并验证新的极狐GitLab MCP 配置。
1. 转到 **设置** > **连接器** 并检查已连接的极狐GitLab MCP 服务器。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-gemini-code-assist-and-gemini-cli-to-the-gitlab-mcp-server"></a>

## 将 Gemini Code Assist 和 Gemini CLI 连接到极狐GitLab MCP 服务器

Gemini Code Assist 和 Gemini CLI 使用 HTTP 传输
进行直接连接，无需额外依赖。
要在 Gemini Code Assist 或 Gemini CLI 中配置极狐GitLab MCP 服务器：

1. 编辑 `~/.gemini/settings.json` 并添加极狐GitLab MCP 服务器。
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。

   ```json
   {
     "mcpServers": {
       "GitLab": {
         "httpUrl": "https://<gitlab.example.com>/api/v4/mcp"
       }
     }
   }
   ```

1. 在 Gemini Code Assist 或 Gemini CLI 中，运行 `/mcp auth GitLab` 命令。

   应出现 OAuth 授权页面。
   否则，请重新启动 Gemini Code Assist 或 Gemini CLI。

1. 在浏览器中，查看并批准授权请求。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-github-copilot-in-vs-code-to-the-gitlab-mcp-server"></a>

## 将 VS Code 中的 GitHub Copilot 连接到极狐GitLab MCP 服务器

GitHub Copilot 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 VS Code 中的 GitHub Copilot 内配置极狐GitLab MCP 服务器：

1. 在 VS Code 中，打开命令面板：
   - 在 macOS 上，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 在 Windows 或 Linux 上，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 输入 `MCP: Add Server` 并按 <kbd>Enter</kbd>。
1. 对于服务器类型，选择 **HTTP**。
1. 对于服务器 URL，输入 `https://<gitlab.example.com>/api/v4/mcp`。
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。
1. 对于服务器 ID，输入 `GitLab`。
1. 将配置保存到全局或 `vscode/mcp.json` 工作区中。

   应出现 OAuth 授权页面。
   否则，打开命令面板并搜索 **MCP: List Servers**
   以检查状态或重新启动服务器。

1. 在浏览器中，查看并批准授权请求。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-kiro-ide-and-cli-to-the-gitlab-mcp-server"></a>

## 将 Kiro IDE 和 CLI 连接到极狐GitLab MCP 服务器

Kiro IDE 和 CLI 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 Kiro IDE 或 CLI 中配置极狐GitLab MCP 服务器：

1. 编辑 `~/.kiro/settings/mcp.json` 并添加极狐GitLab MCP 服务器。
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。

   ```json
   {
     "mcpServers": {
       "GitLab": {
         "type": "http",
         "url": "https://<gitlab.example.com>/api/v4/mcp"
       }
     }
   }
   ```

1. 保存配置。

   应出现 OAuth 授权页面。
   否则，打开 Kiro CLI 并运行 `/mcp` 命令。

1. 在浏览器中，查看并批准授权请求。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-openai-codex-to-the-gitlab-mcp-server"></a>

## 将 OpenAI Codex 连接到极狐GitLab MCP 服务器

OpenAI Codex 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 OpenAI Codex 中配置极狐GitLab MCP 服务器：

1. 在您的终端中，使用 CLI 添加极狐GitLab MCP 服务器：
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。

   ```shell
   codex mcp add GitLab --url "https://<gitlab.example.com>/api/v4/mcp"
   ```

1. 编辑 `~/.codex/config.toml`，并在 `[features]` 部分
   启用 `rmcp_client` 功能标志。

   ```toml
   [features]
   "rmcp_client" = true

   [mcp_servers.GitLab]
   url = "https://<gitlab.example.com>/api/v4/mcp"
   ```

1. 运行登录流程并使用极狐GitLab 实例进行身份验证。

   ```shell
   codex mcp login GitLab
   ```

1. 在浏览器中，查看并批准授权请求。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="connect-zed-to-the-gitlab-mcp-server"></a>

## 将 Zed 连接到极狐GitLab MCP 服务器

先决条件：

- 安装 Node.js 20 或更高版本。
- 确保 Node.js 在 `PATH` 环境变量中全局可用（`which -a node`）。

要在 Zed 中配置极狐GitLab MCP 服务器：

1. 在 Zed 中，打开命令面板：
   - 在 macOS 上，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 在 Windows 或 Linux 上，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 输入 `agent: open settings` 并按 <kbd>Enter</kbd>。
1. 在 **模型上下文协议（MCP）服务器** 部分，选择 **添加服务器**。
1. 对于 `args` 中的服务器 URL，使用 `https://<gitlab.example.com>/api/v4/mcp`。
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，替换为您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，替换为 `gitlab.com`。

   ```json
   {
     /// The name of your MCP server
     "GitLab": {
       /// The command which runs the MCP server
       "command": "npx",
       /// The arguments to pass to the MCP server
       "args": ["-y","mcp-remote@latest","https://<gitlab.example.com>/api/v4/mcp"],
       /// The environment variables to set
       "env": {}
     }
   }
   ```

1. 保存配置。

   应出现 OAuth 授权页面。
   如果没有，请关闭并重新打开 **GitLab** 开关。

1. 在浏览器中，查看并批准授权请求。

您现在可以开始新会话，并根据 [可用工具](mcp_server_tools.md) 提问。

> [!warning]
> 使用这些工具时，您有责任防范提示注入。
> 请格外谨慎，或仅对您信任的极狐GitLab 对象使用 MCP 工具。

<a id="reuse-a-single-oauth-application"></a>

## 复用单个 OAuth 应用程序

当 MCP 客户端连接到极狐GitLab MCP 服务器时，
它会使用 OAuth 2.0 动态客户端注册（DCR）
在您的极狐GitLab 实例上创建一个新的 OAuth 应用程序。

您是否需要复用单个预注册的 OAuth 应用程序取决于实例：

- 在管理员关闭 DCR 的实例上，您必须复用预注册的 OAuth
  应用程序，因为 MCP 客户端无法自动注册应用程序。更多信息，
  请参阅 [关闭 OAuth 动态客户端注册](../../administration/settings/account_and_limit_settings.md#turn-off-oauth-dynamic-client-registration)。
- 在所有其他实例上，复用预注册的 OAuth 应用程序是可选的。复用它可以
  避免以下 DCR 问题：
  - 在极狐GitLab 私有化部署上，许多用户或重复连接的客户端
    可能会在实例上创建大量 OAuth 应用程序。
  - DCR 请求按 IP 地址进行速率限制，每小时最多 10 次注册。共享
    出口 IP 地址的用户（例如公司网络或 VPN）可能会超过此限制，
    导致无法向 MCP 服务器进行身份验证。

每个用户仍需通过 OAuth 授权，并会收到自己的访问令牌。共享应用程序
是 OAuth 客户端身份，而非共享凭据。

根据谁复用应用程序，为以下范围之一创建 OAuth 应用程序：

- 实例：由实例上的所有用户共享。
- 群组：由群组成员共享。
- 用户：用于用户自己的账户。

先决条件：

- 支持以下功能的 MCP 客户端：
  - 预配置的 OAuth 凭据
  - 其配置中的 `clientId` 字段
- 如果您为实例创建应用程序，则需要管理员访问权限。
- 如果您为群组创建应用程序，则需要该群组的所有者角色。

要创建 OAuth 应用程序：

1. 为 [实例](../../integration/oauth_provider.md#create-an-instance-wide-application)、
   [群组](../../integration/oauth_provider.md#create-a-group-owned-application) 或
   [用户](../../integration/oauth_provider.md#create-a-user-owned-application) 创建 OAuth 应用程序。
1. 对于范围，选择 **mcp** 并清除 **机密** 复选框。
1. 保存应用程序。
1. 使用应用程序 ID 配置您的 MCP 客户端，或将应用程序 ID 提供给复用该
   应用程序的用户。应用程序 ID 即 `clientId`。配置键因
   客户端而异，但在极狐GitLab MCP 服务器的 OAuth 配置中通常命名为
   `clientId` 或 `client_id`，通常位于 `mcp.json` 文件中。

对于实例和用户应用程序，您还可以使用
[REST API](../../api/applications.md#create-an-application) 创建应用程序。
群组拥有的应用程序没有 REST API，因此您必须使用群组 UI。

> [!note]
> OAuth 应用程序上注册的重定向 URI 必须与您的 MCP 客户端在 OAuth 流程中发送的
> 重定向 URI 完全匹配。
> 请查阅客户端文档，了解其使用的重定向 URI。
> 单个共享的 OAuth 应用程序无法服务于使用不同重定向 URI 的 MCP 客户端。
> 如果您的用户使用具有不同重定向 URI 的 MCP 客户端，请为每种客户端类型创建单独的共享 OAuth 应用程序。

<a id="security-considerations"></a>

### 安全注意事项

使用客户端 ID 进行身份验证的用户仍必须使用自己的极狐GitLab 凭据完成 OAuth 授权。
他们只能访问被允许访问的数据。

极狐GitLab 不验证是哪个 MCP 客户端应用程序提供了 `clientId`。
如果您为特定 MCP 客户端创建了 OAuth 应用程序，
任何其他支持预注册的 MCP 客户端都可以使用相同的 `clientId` 进行身份验证。
`clientId` 控制使用哪个 OAuth 应用程序，而非允许使用哪个客户端软件。

使用 REST API 创建的预注册应用程序不强制实施用于代码交换的证明密钥（PKCE）。
PKCE 可防止公共客户端的授权码被拦截。

要强制实施 PKCE，请验证您的 MCP 客户端在 OAuth 流程中发送 `code_challenge` 和 `code_challenge_method` 参数。
极狐GitLab 接受预注册应用程序的 PKCE 参数，但不强制要求。
