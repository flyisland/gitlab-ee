---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Describes Model Context Protocol and how to use it
title: 极狐GitLab MCP 客户端
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- 不可用于自部署模型的极狐GitLab Duo

{{< /collapsible >}}

{{< history >}}

- 引入于极狐GitLab 18.1，带有功能标志 `duo_workflow_mcp_support`，默认禁用。
- 在极狐GitLab 18.2 中于 JihuLab.com 和私有化部署上启用，功能标志 `duo_workflow_mcp_support` 已移除。
- 在极狐GitLab 18.3 中从实验阶段变更为测试版。
- 在极狐GitLab 18.8 中 GA。
- 在极狐GitLab 18.10 中于 JihuLab.com 的基础版上可用，需使用极狐GitLab Credits。
- 在极狐GitLab 18.11 版本中引入于极狐GitLab Duo CLI 8.81.0。

{{< /history >}}

模型上下文协议（MCP）为极狐GitLab Duo 功能提供了一种标准化的方式，以安全地连接到不同的外部数据源和工具。

以下功能可以作为 MCP 客户端，并连接到 MCP 服务器上的外部工具：

- [极狐GitLab Duo Agentic Chat](../../gitlab_duo_chat/agentic_chat.md)
- [软件开发流程](../../duo_agent_platform/flows/foundational_flows/software_development.md)

这些功能随后可以访问外部上下文和信息，以生成更强大的答案。

要将功能与 MCP 结合使用：

1. 为您的群组开启 MCP。
2. 配置您希望功能连接的 MCP 服务器。

## 先决条件

- 满足 [极狐GitLab Duo Agent Platform 的先决条件](../../duo_agent_platform/_index.md#prerequisites)。
- 对于命令行：
  - 满足 [极狐GitLab Duo CLI 的先决条件](../../gitlab_duo_cli/_index.md#prerequisites)。
  - 安装并配置 [极狐GitLab Duo CLI](../../gitlab_duo_cli/_index.md#set-up-the-gitlab-duo-cli) 8.81.0 或更高版本。

## 允许外部 MCP 工具

允许您的本地环境访问外部 MCP 工具，在配置了极狐GitLab Duo 的顶级群组中进行设置。

### 在 JihuLab.com 上

要在 JihuLab.com 上允许您的本地环境访问外部 MCP 工具：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **外部 MCP 工具** 下，选中 **允许外部 MCP 工具** 复选框。
1. 选择 **保存更改**。

### 在私有化部署实例上

要在私有化部署实例上允许您的本地环境访问外部 MCP 工具：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **外部 MCP 工具** 下，选中 **允许外部 MCP 工具** 复选框。
1. 选择 **保存更改**。

## 配置 MCP 服务器

要将 MCP 与 Language Server 集成，请设置工作区配置、用户配置或两者。极狐GitLab Language Server 会加载并合并这些配置文件。

### 创建工作区配置

工作区配置仅应用于当前项目，并会覆盖同一服务器的任何用户配置。

要设置工作区配置：

1. 在项目工作区中，创建文件 `<workspace>/.gitlab/duo/mcp.json`。
1. 使用[配置格式](#配置格式)，添加您希望功能连接的 MCP 服务器的信息。
1. 保存文件。
1. 重启极狐GitLab Duo CLI。

### 创建用户配置

用户配置设置适用于个人工具和常用服务器。它们应用于所有工作区，但同一服务器的任何工作区设置会覆盖用户配置。

要设置用户配置：

1. 创建配置文件：

   {{< tabs >}}

   {{< tab title="极狐GitLab Duo CLI" >}}

   - 在您的主目录中创建 `mcp.json` 文件：
     - 对于 Linux 或 macOS，位于 `~/.gitlab/duo/mcp.json`。
     - 对于 Windows，位于 `%APPDATA%\GitLab\duo\mcp.json`。

       例如，`C:\Users\<username>\AppData\Roaming\GitLab\duo\mcp.json`。

   如果您设置了以下任一环境变量，请在其它位置创建文件：

   - 对于 `GLAB_CONFIG_DIR`，位于 `$GLAB_CONFIG_DIR/duo/mcp.json`。
   - 对于 `XDG_CONFIG_HOME`，位于 `$XDG_CONFIG_HOME/gitlab/duo/mcp.json`。

   {{< /tab >}}
   {{< /tabs >}}

1. 使用[配置格式](#配置格式)，添加您希望功能连接的 MCP 服务器的信息。
1. 保存文件。
1. 重启极狐GitLab Duo CLI。

### 配置格式

两种配置文件使用相同的 JSON 格式，详细信息位于 `mcpServers` 键中：

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "path/to/server",
      "args": ["--arg1", "value1"],
      "env": {
        "ENV_VAR": "value"
      },
      "approvedTools": true
    },
    "http-server": {
      "type": "http",
      "url": "http://localhost:3000/mcp",
      "approvedTools": ["read_file", "search"]
    },
    "sse-server": {
      "type": "sse",
      "url": "http://localhost:3000/mcp/sse"
    }
  }
}
```

> [!note]
> 对于其他 MCP 客户端，Atlassian 文档在示例配置文件中使用 `mcp.servers`。
> 对于极狐GitLab，请使用 `mcpServers`。

### 配置工具审批

默认情况下，在每个会话中，您必须手动批准来自服务器的每个 MCP 工具。

您可以在配置文件中预先批准 MCP 工具，以跳过手动批准提示。

为此，请将 `approvedTools` 字段添加到任何服务器配置中：

- `"approvedTools": true` - 自动批准此服务器的所有当前和未来工具。
- `"approvedTools": ["tool1", "tool2"]` - 仅批准您指定的工具。

如果不包含此字段，则必须在会话中手动批准每个工具（这是默认行为）。

> [!warning]
> 仅对您完全信任的服务器使用 `"approvedTools": true`。

例如：

```json
{
  "mcpServers": {
    "trusted-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["my-trusted-mcp-server"],
      "approvedTools": true
    },
    "selective-server": {
      "type": "http",
      "url": "http://localhost:3000/mcp",
      "approvedTools": ["read_file", "search"]
    },
    "untrusted-server": {
      "type": "sse",
      "url": "http://example.com/mcp/sse"
    }
  }
}
```

#### 工具审批的工作原理

极狐GitLab 对 MCP 工具使用两级审批系统：

- 基于配置的审批（永久）：在 `mcp.json` 中使用 `approvedTools` 字段批准的工具。这些审批在所有会话中持续有效。
- 基于会话的审批（临时）：在当前工作流会话的运行时批准的工具。当您关闭 IDE 或结束工作流时，这些审批将被清除。

只要满足任一条件，工具即被批准。

### MCP 服务器配置示例

使用以下代码示例帮助您创建 MCP 服务器配置文件。

有关更多信息和示例，请参阅 [MCP 示例服务器文档](https://modelcontextprotocol.io/examples)。其他示例服务器有 [Smithery.ai](https://smithery.ai/) 和 [Awesome MCP Servers](https://mcpservers.org/)。

#### 本地服务器

```json
{
  "mcpServers": {
    "enterprise-data-v2": {
      "type": "stdio",
      "command": "node",
      "args": ["src/server.js"],
      "cwd": "</path/to/your-mcp-server>",
      "approvedTools": ["query_database", "fetch_metrics"]
    }
  }
}
```

#### 极狐GitLab Knowledge Graph 服务器

[极狐GitLab Knowledge Graph](https://gitlab-org.gitlab.io/rust/knowledge-graph) 通过 MCP 提供代码智能。您可以批准所有工具或特定工具：

```json
{
  "mcpServers": {
    "knowledge-graph": {
      "type": "sse",
      "url": "http://localhost:27495/mcp/sse",
      "approvedTools": true
    }
  }
}
```

或者仅批准特定工具：

```json
{
  "mcpServers": {
    "knowledge-graph": {
      "type": "sse",
      "url": "http://localhost:27495/mcp/sse",
      "approvedTools": ["list_projects", "search_codebase_definitions", "get_references", "get_definition"]
    }
  }
}
```

有关可用工具的更多信息，请参阅 [Knowledge Graph MCP 工具文档](https://gitlab-org.gitlab.io/rust/knowledge-graph/mcp/tools/)。

#### HTTP 服务器

```json
{
  "mcpServers": {
    "local-http-server": {
      "type": "http",
      "url": "http://localhost:3000/mcp",
      "approvedTools": ["read_file", "write_file"]
    }
  }
}
```

## 重新认证 MCP 服务器

在 MCP 配置文件中更新身份验证详细信息后，您必须重新认证相关的 MCP 服务器。

要触发重新认证：

- 向极狐GitLab Duo 提问，该问题需要来自该 MCP 服务器的数据（例如，对于 Atlassian，提问 `我的 Jira 项目中有哪些议题？`）。身份验证流程将自动启动。

## 故障排除

### 删除 MCP 身份验证缓存

极狐GitLab 在本地将 MCP 身份验证缓存于 `~/.mcp-auth/` 下。为避免在故障排除时出现误报，请删除缓存目录：

```shell
rm -rf ~/.mcp-auth/
```

### `启动服务器 filesystem 时出错：Error: spawn ... ENOENT`

当您使用相对路径指定命令（例如 `node` 而不是 `/usr/bin/node`），并且该命令在传递给极狐GitLab Language Server 的 `PATH` 环境变量中找不到时，会出现此错误。

有关解决 `PATH` 问题的改进，请参见议题 1345。