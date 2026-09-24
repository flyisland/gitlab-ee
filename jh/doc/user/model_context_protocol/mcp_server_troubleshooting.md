---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 排查极狐GitLab MCP 服务器的常见问题。
title: 极狐GitLab MCP 服务器故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

使用极狐GitLab MCP 服务器时，您可能会遇到以下问题。

<a id="error-404-not-found"></a>

## 错误：`404 Not Found`

当您启动极狐GitLab MCP 服务器，或 OAuth 流程完成后 `POST /api/v4/mcp` 返回 `404 Not Found` 时，您可能会遇到此错误。

此问题发生在您尚未满足[极狐GitLab MCP 服务器的先决条件](mcp_server.md#prerequisites)时。

要查找原因，请检查 [`mcp.log`](../../administration/logs/_index.md#mcplog) 文件中的 `denial_reason` 字段：

- `instance_setting_disabled`：在极狐GitLab 私有化部署上，MCP 服务器已针对实例[关闭](../../administration/settings/visibility_and_access_controls.md#allow-access-to-the-mcp-server)。
- `no_enabled_namespace`：在 JihuLab.com 上，您所属的任何顶级群组均未[开启](../group/access_and_permissions.md#allow-access-to-the-mcp-server) MCP 服务器。

> [!note]
> 工具调用中返回的 `404` 错误（例如 `404 Project Not Found`）不会记录在 `mcp.log` 中。相反，这些错误会出现在 JSON-RPC 响应体中，并带有 `isError: true`。

<a id="error-servers-protocol-version-is-not-supported-2025-06-18"></a>

## 错误：`Server's protocol version is not supported: 2025-06-18`

在极狐GitLab 18.6 及更早版本中，当 MCP 客户端库不支持极狐GitLab MCP 服务器协议规范时，您可能会遇到此错误。

要解决此问题，请要求 AI 工具提供商更新其客户端实现。

<a id="troubleshoot-the-gitlab-mcp-server-in-cursor"></a>

## 在 Cursor 中排查极狐GitLab MCP 服务器

1. 在 Cursor 中，要打开输出视图，请执行以下任一操作：
   - 转到 **视图** > **输出**。
   - 在 macOS 中，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>U</kbd>。
   - 在 Windows 或 Linux 中，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>U</kbd>。
1. 在输出视图中，选择 **MCP:SERVERNAME**。该名称取决于 MCP 配置值。例如，使用 `GitLab` 会得到 `MCP: user-GitLab`。
1. 报告错误时，请将输出复制到议题模板的日志部分。

<a id="troubleshoot-the-gitlab-mcp-server-on-the-cli-with-mcp-remote"></a>

## 使用 mcp-remote 在 CLI 上排查极狐GitLab MCP 服务器

1. 安装 [Node.js](https://nodejs.org/en/download) 20 或更高版本。
1. 要测试与 IDE 和桌面客户端完全相同的命令：
   1. 提取 MCP 配置。
   1. 将 `npx` 命令字符串拼成一行。
   1. 运行该命令字符串。

   ```shell
   rm -rf ~/.mcp-auth/mcp-remote*

   npx -y mcp-remote@latest https://gitlab.example.com/api/v4/mcp --static-oauth-client-metadata '{"scope": "mcp"}'
   ```

1. 添加 `--debug` 参数以记录更详细的输出：

   ```shell
   rm -rf ~/.mcp-auth/mcp-remote*

   npx -y mcp-remote@latest https://gitlab.example.com/api/v4/mcp --static-oauth-client-metadata '{"scope": "mcp"}' --debug
   ```

1. 可选。直接运行 `mcp-remote-client` 可执行文件。

   ```shell
   rm -rf ~/.mcp-auth/mcp-remote*

   npx -p mcp-remote@latest mcp-remote-client https://gitlab.example.com/api/v4/mcp --static-oauth-client-metadata '{"scope": "mcp"}'
   ```

1. 可选。如果您遇到特定版本的错误，请将 `mcp-remote` 模块固定到特定版本。例如，使用 `mcp-remote@0.1.26` 将版本固定为 `0.1.26`。

   > [!note]
   > 出于安全原因，如无必要，不建议固定版本。

<a id="troubleshoot-gitlab-mcp-server-with-claude-desktop"></a>

## 使用 Claude Desktop 排查极狐GitLab MCP 服务器

验证已安装的 [Node.js](https://nodejs.org/en/download) 版本。Claude Desktop 需要 Node.js 20 或更高版本。

```shell
for n in $(which -a node); do echo "$n" && $n -v; done
```

<a id="delete-mcp-authentication-caches"></a>

## 删除 MCP 身份验证缓存

MCP 身份验证会在本地大量缓存。在故障排查期间，您可能会遇到误报。为防止这种情况，请在故障排查期间删除缓存目录：

```shell
rm -rf ~/.mcp-auth/mcp-remote*
```

<a id="debugging-and-development-tools"></a>

## 调试和开发工具

[MCP Inspector](https://modelcontextprotocol.io/legacy/tools/inspector) 是一个用于测试和调试 MCP 服务器的交互式开发工具。要运行此工具，请使用命令行并访问 Web 界面来检查极狐GitLab MCP 服务器。

```shell
npx -y @modelcontextprotocol/inspector npx
```
