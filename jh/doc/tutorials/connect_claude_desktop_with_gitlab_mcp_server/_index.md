---
stage: none
group: Tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect Claude Desktop to the GitLab MCP server and create an issue.
title: "教程：连接兼容 MCP 的 AI 客户端到 极狐 GitLab MCP 服务器"
---

通过 [极狐 GitLab 模型上下文协议 (MCP) 服务器](../../user/gitlab_duo/model_context_protocol/mcp_server.md)，
您可以将外部 AI 工具和应用程序连接到您的 极狐 GitLab 实例。在本教程中，
您将配置 极狐 GitLab MCP 服务器以连接到兼容 MCP 的 AI 客户端。成功
将兼容 MCP 的 AI 客户端与 MCP 服务器集成后，您将
指示 AI 助手在您的 极狐 GitLab 实例中创建议题。

<a id="before-you-begin"></a>

## 开始之前

- 开启 [极狐 GitLab Duo](../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-on-or-off) 和 [测试版和实验性功能](../../user/duo_agent_platform/turn_on_off.md#turn-on-beta-and-experimental-features)。
- 为您的操作系统安装兼容 MCP 的 AI 客户端。
- 安装 Node.js 版本 20 或更高版本。
  在 `PATH` 环境变量中全局可用 Node.js (`which -a node`)。
- 拥有至少一个可以创建议题的活跃项目。

<a id="connect-claude-desktop-to-the-gitlab-mcp-server"></a>

## 连接兼容 MCP 的 AI 客户端到 极狐 GitLab MCP 服务器

1. 打开兼容 MCP 的 AI 客户端。
1. 编辑配置文件。您可以执行以下任一操作：
   - 在兼容 MCP 的 AI 客户端中，选择 **设置** > **开发者** > **编辑配置**。
   - 在文件系统中，转到 `claude_desktop_config.json` 并打开文件。例如：
     - 在 macOS 上：`~/Library/Application Support/Claude/claude_desktop_config.json`。
     - 在 Windows 上：`%APPDATA%\Claude\claude_desktop_config.json`。
1. 添加以下 极狐 GitLab MCP 服务器条目，按需编辑：
   - 对于 `"command":` 参数，如果 `npx` 是本地安装而非全局安装，请提供 `npx` 的完整路径。
   - 将 `<gitlab.example.com>` 替换为：
     - 在 极狐 GitLab 私有化部署 上，您的 极狐 GitLab 实例 URL。
     - 在 JihuLab.com 上，`JihuLab.com`。

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

1. 保存配置并重启兼容 MCP 的 AI 客户端。
1. 首次连接时，兼容 MCP 的 AI 客户端会打开一个浏览器窗口进行 OAuth 认证。审查并批准请求。
1. 转到 **设置** > **开发者** 并验证新的 极狐 GitLab MCP 配置。

![在兼容 MCP 的 AI 客户端中查看连接的本地 MCP 服务器](img/view_local_mcp_servers_v18_10.png)

<a id="customize-tool-permissions"></a>

## 自定义工具权限

成功连接 MCP 服务器后，您可以自定义 AI 助手
在与您的 极狐 GitLab 实例交互时可以使用的工具。例如，
您可以配置 AI 助手在执行某些操作之前请求批准，
如创建议题或管理 CI/CD 流水线。

要在兼容 MCP 的 AI 客户端中查看工具权限：

1. 在左侧侧边栏中，选择 **自定义** > **连接器**。
1. 在 **桌面端** 下，选择 **极狐 GitLab**。
1. 将 `create_issue` 设置为 **需要审批** 或 **始终允许**。

![在兼容 MCP 的 AI 客户端中查看连接器的工具权限](img/view_connectors_v18_10.png)

<a id="test-the-connection"></a>

## 测试连接

现在您已成功将兼容 MCP 的 AI 客户端连接到 MCP 服务器，
请使用提示测试连接：

1. 在聊天文本框中，输入：

   ```plaintext
   您使用的是哪个 MCP 服务器版本？
   ```

1. 按 <kbd>Enter</kbd> 或选择 **发送**。

AI 助手应响应服务器版本以及
关于集成和它用于回答
提示的工具的详情。

![通过提示验证 MCP 服务器版本，并查看 AI 助手使用了哪些工具](img/verify_mcp_server_version_v18_10.png)

<a id="create-an-issue-in-a-project"></a>

## 在项目中创建议题

现在，让 AI 助手查找一个特定项目，
您可以在其中创建测试议题。

1. 在聊天文本框中，输入：

   ```plaintext
   您能找到我的项目 <project_name> 吗？
   ```

   将 `<project_name>` 替换为您的项目。
1. 按 <kbd>Enter</kbd> 或选择 **发送**。
1. 在 AI 助手找到您的项目后，询问
   AI 助手在项目中创建议题。
   在聊天文本框中，输入：

   ```plaintext
   您可以在名为“来自 MCP 服务器的测试议题”的项目中创建一个议题吗，并给它以下描述：“这是由兼容 MCP 的 AI 客户端和 极狐 GitLab MCP 服务器创建的测试议题。”
   ```

1. 按 <kbd>Enter</kbd> 或选择 **发送**。
1. 如果您将 `create_issue` 设置为 **需要审批**，AI 助手将请求创建议题的权限。
   选择 **始终允许** 或从下拉列表中选择 **允许一次**。

   ![授予 AI 助手在项目中创建议题的权限](img/grant_permission_to_create_issue_v18_10.png)

在 AI 助手创建议题后，它将提供议题详情，包括在浏览器中访问议题的 URL。
