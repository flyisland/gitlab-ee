---
stage: Tutorials
group: Tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将 Claude Desktop 连接到极狐GitLab MCP 服务器并创建议题。
title: "教程：将 Claude Desktop 连接到极狐GitLab MCP 服务器"
---

通过 [极狐GitLab 模型上下文协议（MCP）服务器](../../user/model_context_protocol/mcp_server.md)，您可以将外部 AI 工具和应用程序连接到您的极狐GitLab 实例。在本教程中，
您将配置极狐GitLab MCP 服务器以连接到 Claude Desktop。在您成功
将 Claude Desktop 与 MCP 服务器集成后，您将
指示 Claude 在您的极狐GitLab 实例中创建议题。

<a id="before-you-begin"></a>

## 开始之前

- 允许访问 MCP 服务器：
  - 在 JihuLab.com 上，[为顶级群组](../../user/group/access_and_permissions.md#allow-access-to-the-mcp-server)。
  - 在极狐GitLab 私有化部署上，[为该实例](../../administration/settings/visibility_and_access_controls.md#allow-access-to-the-mcp-server)。
- 为您的操作系统安装 [Claude Desktop](https://support.claude.com/en/articles/10065433-install-claude-desktop)。
- 安装 Node.js 20 或更高版本。
  确保 Node.js 在 `PATH` 环境变量中全局可用（`which -a node`）。
- 至少有一个活跃项目，您可以在其中创建议题。

<a id="connect-claude-desktop-to-the-gitlab-mcp-server"></a>

## 将 Claude Desktop 连接到极狐GitLab MCP 服务器

1. 打开 Claude Desktop。
1. 编辑配置文件。您可以执行以下任一操作：
   - 在 Claude Desktop 中，选择**设置** > **开发者** > **编辑配置**。
   - 在您的文件系统中，转到 `claude_desktop_config.json` 并打开该文件。例如：
     - 在 macOS 上：`~/Library/Application Support/Claude/claude_desktop_config.json`。
     - 在 Windows 上：`%APPDATA%\Claude\claude_desktop_config.json`。
1. 为极狐GitLab MCP 服务器添加以下条目，并根据需要进行编辑：
   - 对于 `"command":` 参数，如果 `npx` 是本地安装而非全局安装，请提供 `npx`的完整路径。
   - 将 `<gitlab.example.com>` 替换为：
     - 在极狐GitLab 私有化部署上，您的极狐GitLab 实例 URL。
     - 在 JihuLab.com 上，`GitLab.com`。

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
1. 首次连接时，Claude Desktop 会打开浏览器窗口进行 OAuth 认证。请查看并批准该请求。
1. 转到**设置** > **开发者**，验证新的极狐GitLab MCP 配置。

![在 Claude Desktop 中查看已连接的本地 MCP 服务器](img/view_local_mcp_servers_v18_10.png)

<a id="customize-tool-permissions"></a>

## 自定义工具权限

成功连接 MCP 服务器后，您可以自定义 Claude 在与您的极狐GitLab 实例交互时可以使用的工具。例如，您可以配置 Claude 在执行某些操作前请求批准，例如创建议题或管理 CI/CD 流水线。

要在 Claude 中查看工具权限：

1. 在左侧边栏中，选择**自定义** > **连接器**。
1. 在**桌面**下，选择 **GitLab**。
1. 将 `create_issue` 设置为**需要批准**或**始终允许**。

![在 Claude Desktop 中查看连接器的工具权限](img/view_connectors_v18_10.png)

<a id="test-the-connection"></a>

## 测试连接

现在您已成功将 Claude Desktop 连接到 MCP 服务器，
请使用提示测试连接：

1. 在聊天文本框中，输入：

   ```plaintext
   Which MCP server version are you using?
   ```

1. 按 <kbd>Enter</kbd> 或选择**发送**。

Claude 应回复服务器版本，以及有关集成和它用于回答该提示的工具的详细信息。

![使用提示验证 MCP 服务器版本，并查看 Claude 使用了哪些工具](img/verify_mcp_server_version_v18_10.png)

<a id="create-an-issue-in-a-project"></a>

## 在项目中创建议题

现在，请让 Claude 查找一个特定的项目，您可以在其中创建测试议题。

1. 在聊天文本框中，输入：

   ```plaintext
   Can you find my project <project_name>?
   ```

   将 `<project_name>` 替换为您的项目。
1. 按 <kbd>Enter</kbd> 或选择**发送**。
1. 在 Claude 找到您的项目后，请让
   Claude 在该项目中创建议题。
   在聊天文本框中，输入：

   ```plaintext
   Can you create an issue in the project called "Test issue from MCP server", and give it the following description: "This is a test issue created by Claude Desktop and the GitLab MCP server."
   ```

1. 按 <kbd>Enter</kbd> 或选择**发送**。
1. 如果您将 `create_issue` 设置为**需要批准**，Claude 将请求创建议题的权限。
   选择**始终允许**，或者从下拉列表中选择**仅允许一次**。

   ![授予 Claude 在项目中创建议题的权限](img/grant_permission_to_create_issue_v18_10.png)

在 Claude 创建议题后，它将提供议题详细信息，包括可在浏览器中访问该议题的 URL。
