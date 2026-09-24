---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect custom agents in the AI Catalog to external data sources and third-party services using MCP servers.
title: AI Catalog 中的 MCP 服务器
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中引入，[带有功能标志](../../../administration/feature_flags/_index.md)名为 `ai_catalog_mcp_servers`。默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产。

AI 目录中的自定义代理可以通过[模型上下文协议](https://modelcontextprotocol.io/)（MCP）连接到外部数据源和第三方服务（例如 Jira 或 Google Drive）。

此功能是[实验性功能](../../../policy/development_stages_support.md#experiment)。

借助 AI 目录中的 MCP 服务器，你可以：

- 将 MCP 服务器添加到你的组织目录中（名称、URL 和传输类型）。
- 将 MCP 服务器与自定义代理关联。
- 查看哪些 MCP 服务器连接到了每个代理。
- 对启用 OAuth 的 MCP 服务器进行认证。

AI 目录导航中会显示一个专用的 **MCP** 选项卡，与 **代理** 和 **流程** 并列。
已在你命名空间中启用的代理关联的 MCP 服务器，也会在群组和项目级别的 **AI** > **MCP 服务器** 下显示。

<a id="prerequisites"></a>

## 先决条件

- 满足 [GitLab Duo Agent Platform 的先决条件](../../duo_agent_platform/_index.md#prerequisites)。
- 成为已[开启极狐GitLab Duo 实验和测试功能](../turn_on_off.md#on-gitlabcom-2)的顶级群组的成员。
- 要添加或编辑 MCP 服务器，你必须是实例管理员。
- MCP 服务器必须是：
  - 经过审核的或合作伙伴的 MCP 服务器。不允许使用任意 URL。
  - 远程 MCP 服务器。

<a id="add-an-mcp-server-to-the-ai-catalog"></a>

## 向 AI 目录添加 MCP 服务器

向 AI 目录添加 MCP 服务器：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **MCP** 选项卡。
1. 选择 **新建 MCP 服务器**。
1. 填写字段：
   - **名称**：MCP 服务器的描述性名称（例如，`Jira`）。
   - **描述**（可选）：服务器提供内容的简要描述。
   - **URL**：MCP 服务器的 HTTP 端点。
   - **主页 URL**（可选）：MCP 服务器的主页或文档 URL。
   - **传输**：选择 **HTTP**。仅支持 HTTP 传输。SSE 和 stdio 传输不可用。
   - **认证类型**：选择以下一项：
     - **无**：无认证需求。
     - **OAuth**：通过 OAuth 2.0 认证。如果服务器支持 [OAuth 2.0 动态客户端注册](https://tools.ietf.org/html/rfc7591)，极狐GitLab 将在首次连接时自动注册为 OAuth 客户端。
1. 选择 **创建 MCP 服务器**。

MCP 服务器现在在你的组织目录中可用，并可以与代理关联。

<a id="edit-an-mcp-server"></a>

## 编辑 MCP 服务器

编辑 MCP 服务器：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **MCP** 选项卡。
1. 选择你想要编辑的 MCP 服务器。
1. 选择 **编辑**。
1. 根据需要更新字段。
1. 选择 **保存更改**。

<a id="connect-an-mcp-server-to-a-custom-agent"></a>

## 将 MCP 服务器连接到自定义代理

将 MCP 服务器连接到自定义代理：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **代理** 选项卡。
1. 选择你要配置的代理，然后选择 **编辑**。
1. 在 **MCP 服务器** 部分，选择要与此代理关联的 MCP 服务器。
1. 选择 **保存更改**。

现在，代理可以在执行期间使用关联 MCP 服务器提供的所有工具。

你无法限制代理使用特定的 MCP 服务器工具。

<a id="view-mcp-servers-connected-to-a-custom-agent"></a>

## 查看连接到自定义代理的 MCP 服务器

查看哪些 MCP 服务器连接到了自定义代理：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **代理** 选项卡。
1. 选择代理。

代理详情页面会列出所有已连接的 MCP 服务器。

<a id="disconnect-an-mcp-server-from-custom-agents"></a>

## 从自定义代理断开 MCP 服务器

{{< history >}}

- 在极狐GitLab 18.11 中引入。

{{< /history >}}

你可以从与 MCP 服务器关联的所有自定义代理中断开该 MCP 服务器。你无法从特定代理断开 MCP 服务器。

断开后，现有的自定义代理对话仍可以引用已从 MCP 服务器检索到的内容。但是，代理无法再获取新内容或执行任何操作。

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **MCP** 选项卡。
1. 对于你想要断开的 MCP 服务器，选择 **断开**。
1. 在确认对话框中，选择 **断开**。

<a id="view-mcp-servers-for-a-namespace"></a>

## 查看命名空间的 MCP 服务器

**AI** > **MCP 服务器** 页面显示了与在你命名空间中启用的代理关联的所有 MCP 服务器。每个服务器会显示使用它的代理数量，将鼠标悬停时会在工具提示中显示代理名称。

此页面在群组和项目级别均可用：

- **群组级别** 显示与该群组内代理关联的 MCP 服务器。
- **项目级别** 显示与项目中配置的代理关联的 MCP 服务器。

要在群组或项目级别查看 MCP 服务器：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组或项目。
1. 选择 **AI** > **MCP 服务器**。

对于尚未认证的启用 OAuth 的服务器，会显示一个 **连接** 选项。

<a id="authenticate-with-an-mcp-server"></a>

## 对 MCP 服务器进行认证

要对启用 OAuth 的 MCP 服务器进行认证：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的群组或项目。
1. 选择 **AI** > **MCP 服务器**。
1. 找到 MCP 服务器并选择 **连接**。
1. 在 MCP 服务器的授权页面上查看并批准授权请求。
1. 极狐GitLab 会安全地存储访问令牌，以供后续请求使用。

如果服务器支持 [OAuth 2.0 动态客户端注册](https://tools.ietf.org/html/rfc7591)，极狐GitLab 将在首次连接时自动注册为 OAuth 客户端。你无需手动提供 OAuth 凭证。

<a id="available-mcp-servers"></a>

## 可用的 MCP 服务器

你可以将以下 MCP 服务器添加到 AI 目录。有关提议添加到目录的更多服务器，请参见 issue 591969。

### Linear

Linear MCP 服务器允许 AI Agent 和工作流与 Linear 数据实时交互，包括查找、创建和更新议题、项目和评论。

| 属性 | 值 |
|---|---|
| URL | `https://mcp.linear.app/mcp` |
| 传输 | HTTP |
| 认证 | OAuth |

### Atlassian

Atlassian MCP 服务器允许 AI Agent 和工作流与 Jira 和 Confluence 数据实时交互，包括搜索、创建和更新议题、页面和项目内容。

| 属性 | 值 |
|---|---|
| URL | `https://mcp.atlassian.com/v1/mcp` |
| 传输 | HTTP |
| 认证 | OAuth |

连接前，请将 Atlassian 实例配置为信任极狐GitLab 作为授权域：

1. 在 Atlassian 中，转到管理员页面。
1. 选择 **应用** > **AI 设置** > **Rovo MCP 服务器**。
1. 将 `https://gitlab.com/**` 添加到受信任域列表中。

### Context7

Context7 MCP 从源代码中提取最新的、版本特定的文档和代码示例，并将其添加到你的提示中。

| 属性 | 值 |
|---|---|
| URL | `https://mcp.context7.com/mcp` |
| 传输 | HTTP |
| 认证 | 无 |