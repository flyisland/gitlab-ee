---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect AI tools to your GitLab instance with the GitLab MCP server.
title: 极狐GitLab MCP 服务器
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 作为[实验功能](../../../policy/development_stages_support.md#experiment)在极狐GitLab 18.3 中[引入](../../../administration/feature_flags/_index.md)，使用名为 `mcp_server` 和 `oauth_dynamic_client_registration` 的功能标志。默认禁用。
- 从实验功能变为[测试版](../../../policy/development_stages_support.md#beta)在极狐GitLab 18.6。功能标志 `mcp_server` 和 `oauth_dynamic_client_registration` 已移除。
- 对 `2025-03-26` 和 `2025-06-18` MCP 协议规范的支持已在极狐GitLab 18.7 中添加。

{{< /history >}}

通过极狐GitLab [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) 服务器，你可以安全地将 AI 工具和应用程序连接到你的极狐GitLab 实例。兼容 MCP 的工具的 AI 助手随后可以访问你的极狐GitLab 数据，并代表你执行操作。

极狐GitLab MCP 服务器为 AI 工具提供标准化的方式，以实现以下操作：

- 访问极狐GitLab 项目信息。
- 检索议题和合并请求数据。
- 安全地与极狐GitLab API 交互。
- 通过 AI 助手执行特定于极狐GitLab 的操作。

极狐GitLab MCP 服务器支持 [OAuth 2.0 Dynamic Client Registration](https://tools.ietf.org/html/rfc7591)，这使 AI 工具能够自行在你的极狐GitLab 实例上注册。当 AI 工具首次连接到你的极狐GitLab MCP 服务器时，它会：

1. 将自己注册为一个 OAuth 应用程序。
1. 请求授权以访问你的极狐GitLab 数据。
1. 接收一个用于安全 API 访问的访问令牌。

如需可点击的演示，请参阅 [极狐GitLab Duo Agent Platform - 极狐GitLab MCP 服务器](https://gitlab.navattic.com/gitlab-mcp-server)。
<!-- Demo published on 2025-09-11 -->

<a id="prerequisites"></a>

## 前提条件

- 为实例[开启极狐GitLab Duo](../../duo_agent_platform/turn_on_off.md#for-an-instance)。
- 开启[测试版和实验功能](../../duo_agent_platform/turn_on_off.md#turn-on-beta-and-experimental-features)。

<a id="connect-a-client-to-the-gitlab-mcp-server"></a>

## 将客户端连接到极狐GitLab MCP 服务器

极狐GitLab MCP 服务器支持两种传输类型：

- **HTTP 传输（推荐）**：直接连接，无需额外依赖。
- **使用 `mcp-remote` 的 stdio 传输**：通过代理连接（需要 Node.js）。

常见的 AI 工具支持 JSON 配置格式的 `mcpServers` 键，并提供不同的方法来配置极狐GitLab MCP 服务器设置。

<a id="http-transport-(recommended)"></a>

### HTTP 传输（推荐）

{{< history >}}

- 在极狐GitLab 18.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/577575)。
- 在极狐GitLab 18.11 中[添加](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/230406)了工具前缀。

{{< /history >}}

要使用 HTTP 传输配置极狐GitLab MCP 服务器，请使用以下格式：

- 将 `<gitlab.example.com>` 替换为：
  - 在私有化部署中，使用你的极狐GitLab 实例 URL。
  - 在 JihuLab.com 上，使用 `gitlab.com`。

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

你可以通过配置 `X-Gitlab-Mcp-Server-Tool-Name-Prefix` HTTP 头来为工具名称添加前缀。
添加前缀有助于避免与其他 MCP 服务器或配置中的多个极狐GitLab 实例之间的工具名称冲突。

如果前缀超过 32 个字符，它将被截断为前 32 个字符。

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

### 使用 `mcp-remote` 的 stdio 传输

前提条件：

- 安装 Node.js 20 或更高版本。

要使用 stdio 传输配置极狐GitLab MCP 服务器，请使用以下格式：

- 对于 `"command":` 参数，如果 `npx` 是本地安装而非全局安装，请提供 `npx` 的完整路径。
- 将 `<gitlab.example.com>` 替换为：
  - 在私有化部署中，使用你的极狐GitLab 实例 URL。
  - 在 JihuLab.com 上，使用 `gitlab.com`。

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

<a id="connect-claude-code-to-the-gitlab-mcp-server"></a>

## 将 Claude Code 连接到极狐GitLab MCP 服务器

Claude Code 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 Claude Code 中配置极狐GitLab MCP 服务器：

1. 在终端中，使用 CLI 添加极狐GitLab MCP 服务器：
   - 将 `<gitlab.example.com>` 替换为：
     - 在私有化部署中，使用你的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，使用 `gitlab.com`。

   ```shell
   claude mcp add --transport http GitLab https://<gitlab.example.com>/api/v4/mcp
   ```

1. 启动 Claude Code：

   ```shell
   claude
   ```

1. 使用极狐GitLab MCP 服务器进行认证：
   - 在聊天中，输入 `/mcp`。
   - 从列表中选择你的极狐GitLab 服务器。
   - 在浏览器中，查看并批准授权请求。

1. 可选。要验证连接，请再次输入 `/mcp`。
   你的极狐GitLab 服务器应显示为已连接。

现在，你可以开始一个新会话，并根据[可用工具](mcp_server_tools.md)提出问题。

> [!warning]
> 你有责任在使用这些工具时防范提示注入攻击。
> 请格外谨慎，或仅在受信任的极狐GitLab 对象上使用 MCP 工具。

<a id="connect-claude-desktop-to-the-gitlab-mcp-server"></a>

## 将 Claude Desktop 连接到极狐GitLab MCP 服务器

前提条件：

- 安装 Node.js 20 或更高版本。
- 确保 Node.js 在 `PATH` 环境变量中全局可用（`which -a node`）。

要在 Claude Desktop 中配置极狐GitLab MCP 服务器：

1. 打开 Claude Desktop。
1. 编辑配置文件。你可以执行以下任一操作：
   - 在 Claude Desktop 中，前往 **设置** > **开发者** > **编辑配置**。
   - 在 macOS 上，打开 `~/Library/Application Support/Claude/claude_desktop_config.json` 文件。
1. 添加以下极狐GitLab MCP 服务器条目，并根据需要编辑：
   - 对于 `"command":` 参数，如果 `npx` 是本地安装而非全局安装，请提供 `npx` 的完整路径。
   - 将 `<gitlab.example.com>` 替换为：
     - 在私有化部署中，使用你的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，使用 `GitLab.com`。

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

1. 保存配置并重启 Claude Desktop。
1. 首次连接时，Claude Desktop 会打开浏览器窗口以进行 OAuth 授权。查看并批准该请求。
1. 前往 **设置** > **开发者** 并验证新的极狐GitLab MCP 配置。
1. 前往 **设置** > **连接器** 并检查已连接的极狐GitLab MCP 服务器。

现在，你可以开始一个新会话，并根据[可用工具](mcp_server_tools.md)提出问题。

> [!warning]
> 你有责任在使用这些工具时防范提示注入攻击。
> 请格外谨慎，或仅在受信任的极狐GitLab 对象上使用 MCP 工具。

<a id="connect-gemini-code-assist-and-gemini-cli-to-the-gitlab-mcp-server"></a>

## 将 Gemini Code Assist 和 Gemini CLI 连接到极狐GitLab MCP 服务器

Gemini Code Assist 和 Gemini CLI 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 Gemini Code Assist 或 Gemini CLI 中配置极狐GitLab MCP 服务器：

1. 编辑 `~/.gemini/settings.json` 并添加极狐GitLab MCP 服务器。
   - 将 `<gitlab.example.com>` 替换为：
     - 在私有化部署中，使用你的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，使用 `gitlab.com`。

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

   OAuth 授权页面应会出现。
   否则，重启 Gemini Code Assist 或 Gemini CLI。

1. 在浏览器中，查看并批准授权请求。

现在，你可以开始一个新会话，并根据[可用工具](mcp_server_tools.md)提出问题。

> [!warning]
> 你有责任在使用这些工具时防范提示注入攻击。
> 请格外谨慎，或仅在受信任的极狐GitLab 对象上使用 MCP 工具。

<a id="connect-openai-codex-to-the-gitlab-mcp-server"></a>

## 将 OpenAI Codex 连接到极狐GitLab MCP 服务器

OpenAI Codex 使用 HTTP 传输进行直接连接，无需额外依赖。
要在 OpenAI Codex 中配置极狐GitLab MCP 服务器：

1. 在终端中，使用 CLI 添加极狐GitLab MCP 服务器：
   - 将 `<gitlab.example.com>` 替换为：
     - 在私有化部署中，使用你的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，使用 `gitlab.com`。

   ```shell
   codex mcp add --url "https://<gitlab.example.com>/api/v4/mcp" GitLab
   ```

1. 编辑 `~/.codex/config.toml`，并在 `[features]` 部分中启用 `rmcp_client` 功能标志。

   ```toml
   [features]
   "rmcp_client" = true

   [mcp_servers.GitLab]
   url = "https://<gitlab.example.com>/api/v4/mcp"
   ```

1. 运行登录流程并使用极狐GitLab 实例进行认证。

   ```shell
   codex mcp login GitLab
   ```

1. 在浏览器中，查看并批准授权请求。

现在，你可以开始一个新会话，并根据[可用工具](mcp_server_tools.md)提出问题。

> [!warning]
> 你有责任在使用这些工具时防范提示注入攻击。
> 请格外谨慎，或仅在受信任的极狐GitLab 对象上使用 MCP 工具。

<a id="related-topics"></a>

## 相关主题

- [AI Catalog 中的 MCP 服务器](ai_catalog_mcp_servers.md)