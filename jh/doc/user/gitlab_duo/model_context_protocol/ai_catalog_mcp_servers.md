---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 MCP 服务器将 AI 目录中的自定义 Agent 连接到外部数据源和第三方服务。
title: AI 目录中的 MCP 服务器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

AI 目录中的自定义 Agent 可以通过[模型上下文协议](https://modelcontextprotocol.io/)（MCP）连接到外部数据源和
第三方服务（例如 Jira 或 Linear）。

此功能是一项[实验](../../../policy/development_stages_support.md#experiment)。请在[议题 593219](https://gitlab.com/gitlab-org/gitlab/-/work_items/593219)中分享您的反馈。

借助 AI 目录中的 MCP 服务器，您可以：

- 将 MCP 服务器添加到组织的目录中（名称、URL 和传输类型）。
- 将 MCP 服务器与自定义 Agent 关联。
- 查看每个 Agent 连接了哪些 MCP 服务器。
- 通过支持 OAuth 的 MCP 服务器进行身份验证。

AI 目录导航中会显示一个专用的 **MCP** 选项卡，与 **Agents** 和 **Flows** 并列。与您命名空间中已启用的 Agent 关联的 MCP 服务器，也会在群组和项目级别的 **AI** > **MCP 服务器** 下提供。

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../../duo_agent_platform/_index.md#prerequisites)。
- 在 JihuLab.com 上，您必须是一个顶级群组的成员，且该群组已
  [开启极狐GitLab Duo 实验和测试版功能](../turn_on_off.md#on-gitlabcom-2)。
- 在极狐GitLab 私有化部署上，您的实例已
  [开启极狐GitLab Duo 实验和测试版功能](../turn_on_off.md#on-gitlab-self-managed-2)。
- 在极狐GitLab 私有化部署上，管理员已启用 `mcp_client`
  [功能标志](../../../administration/feature_flags/_index.md)。
- MCP 服务器必须是：
  - 经过审核的 MCP 服务器或合作伙伴 MCP 服务器。不允许使用任意 URL。
  - 远程 MCP 服务器。

<a id="add-an-mcp-server-to-the-ai-catalog"></a>

## 将 MCP 服务器添加到 AI 目录

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 具有实例的管理员访问权限。

在极狐GitLab 私有化部署上，实例管理员可以从[可用的 MCP 服务器](#available-mcp-servers)列表中，为其实例将 MCP 服务器添加到 AI 目录。

> [!note]
> 在 JihuLab.com 上，顶级群组成员无法将 MCP 服务器添加到 AI 目录，因为这由 JihuLab.com 管理员集中管理。

要将 MCP 服务器添加到 AI 目录：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **MCP** 选项卡。
1. 选择 **新建 MCP 服务器**。
1. 填写以下字段：
   - **名称**：MCP 服务器的描述性名称（例如 `Jira`）。
   - **描述**（可选）：该服务器所提供内容的简要描述。
   - **URL**：MCP 服务器的 HTTP 端点。
   - **主页 URL**（可选）：MCP 服务器的主页或文档 URL。
   - **传输**：选择 **HTTP**。仅支持 HTTP 传输。
     不支持 SSE 和 stdio 传输。
   - **认证类型**：选择以下之一：
     - **无**：无需身份验证。
     - **OAuth**：使用 OAuth 2.0 进行身份验证。如果服务器支持
       [OAuth 2.0 动态客户端注册](https://tools.ietf.org/html/rfc7591)，
       极狐GitLab 会在首次连接时自动将自己注册为 OAuth 客户端。
1. 选择 **创建 MCP 服务器**。

该 MCP 服务器现在已在您的组织目录中提供，并可与 Agent 关联。

<a id="edit-an-mcp-server"></a>

## 编辑 MCP 服务器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 具有实例的管理员访问权限。

在极狐GitLab 私有化部署上，实例管理员可以为其实例编辑 AI 目录中的 MCP 服务器。

> [!note]
> 在 JihuLab.com 上，顶级群组成员无法编辑 AI 目录中的 MCP 服务器，因为这由 JihuLab.com 管理员集中管理。

要编辑 MCP 服务器：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **MCP** 选项卡。
1. 选择您要编辑的 MCP 服务器。
1. 选择 **编辑**。
1. 根据需要更新字段。
1. 选择 **保存更改**。

<a id="connect-an-mcp-server-to-a-custom-agent"></a>

## 将 MCP 服务器连接到自定义 Agent

要将 MCP 服务器连接到自定义 Agent：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **Agents** 选项卡。
1. 选择您要配置的 Agent，然后选择 **编辑**。
1. 在 **MCP 服务器** 部分中，选择要与此 Agent 关联的 MCP 服务器。
1. 选择 **保存更改**。

该 Agent 现在可以在执行期间使用关联 MCP 服务器提供的所有工具。

您无法限制 Agent 使用特定的 MCP 服务器工具。

<a id="view-mcp-servers-connected-to-a-custom-agent"></a>

## 查看连接到自定义 Agent 的 MCP 服务器

要查看哪些 MCP 服务器已连接到自定义 Agent：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **Agents** 选项卡。
1. 选择该 Agent。

Agent 详情页面会列出所有已连接的 MCP 服务器。

<a id="disconnect-an-mcp-server-from-custom-agents"></a>

## 断开 MCP 服务器与自定义 Agent 的连接

您可以断开 MCP 服务器与其已建立连接的所有自定义 Agent 的连接。您无法断开 MCP 服务器与特定 Agent 的连接。

断开连接后，现有的自定义 Agent 对话仍可引用已从该 MCP 服务器检索到的内容。但是，Agent 将无法再获取新内容或执行任何操作。

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组。
1. 选择 **构建** > **AI 目录**。
1. 选择 **MCP** 选项卡。
1. 对于您要断开连接的 MCP 服务器，选择 **断开**。
1. 在确认对话框中，选择 **断开**。

<a id="view-mcp-servers-for-a-namespace"></a>

## 查看命名空间的 MCP 服务器

**AI** > **MCP 服务器** 页面会显示与您命名空间中已启用的 Agent 关联的所有 MCP 服务器。每个服务器都会显示使用它的 Agent 数量，悬停时会在工具提示中显示 Agent 名称。

此页面在群组和项目级别均可用：

- **群组级别**显示与整个群组中的 Agent 关联的 MCP 服务器。
- **项目级别**显示与项目中配置的 Agent 关联的 MCP 服务器。

要在群组或项目级别查看 MCP 服务器：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组或项目。
1. 选择 **AI** > **MCP 服务器**。

对于您尚未通过身份验证的、支持 OAuth 的服务器，会显示 **连接** 选项。

<a id="authenticate-with-an-mcp-server"></a>

## 通过 MCP 服务器进行身份验证

要通过支持 OAuth 的 MCP 服务器进行身份验证：

1. 在左侧边栏中，选择**搜索或跳转到**并找到您的群组或项目。
1. 选择 **AI** > **MCP 服务器**。
1. 找到该 MCP 服务器并选择 **连接**。
1. 在该 MCP 服务器的授权页面上查看并批准授权请求。
1. 极狐GitLab 会安全地存储访问令牌，以供将来请求使用。

如果服务器支持 [OAuth 2.0 动态客户端注册](https://tools.ietf.org/html/rfc7591)，极狐GitLab 会在首次连接时自动将自己注册为 OAuth 客户端。您无需手动提供 OAuth 凭据。

<a id="available-mcp-servers"></a>

## 可用的 MCP 服务器

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

您可以将以下 MCP 服务器从 AI 目录添加到您的自定义 Agent。有关为目录提议的更多服务器，请参阅[议题 591969](https://gitlab.com/gitlab-org/gitlab/-/work_items/591969)。

<a id="linear"></a>

### Linear

Linear MCP 服务器允许 AI Agent 和任务流实时与 Linear 数据交互，
包括查找、创建和更新议题、项目和评论。

| 属性 | 值 |
|---|---|
| URL | `https://mcp.linear.app/mcp` |
| 传输 | HTTP |
| 认证 | OAuth |

<a id="atlassian"></a>

### Atlassian

Atlassian MCP 服务器允许 AI Agent 和任务流实时与 Jira 和 Confluence 数据交互，
包括搜索、创建和更新议题、页面和项目内容。

| 属性 | 值 |
|---|---|
| URL | `https://mcp.atlassian.com/v1/mcp` |
| 传输 | HTTP |
| 认证 | OAuth |

连接之前，请将您的 Atlassian 实例配置为信任极狐GitLab 作为授权域：

1. 在 Atlassian 中，转到管理页面。
1. 选择 **应用** > **AI 设置** > **Rovo MCP 服务器**。
1. 将 `https://jihulab.com/**` 添加到受信任域列表中。

<a id="context7"></a>

### Context7

Context7 MCP 会从来源获取最新的、特定版本的文档和代码示例，并将其添加到您的提示中。

| 属性 | 值 |
|---|---|
| URL | `https://mcp.context7.com/mcp` |
| 传输 | HTTP |
| 认证 | 无 |

<a id="troubleshooting"></a>

## 故障排除

在 AI 目录中使用 MCP 服务器时，您可能会遇到以下问题。

<a id="mcp-server-issues-due-to-outbound-request-restrictions"></a>

### 因出站请求限制导致的 MCP 服务器问题

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

极狐GitLab 验证 MCP 服务器 URL 的方式与验证其他出站请求（例如 webhook 和集成）的方式相同。如果您的极狐GitLab 私有化部署实例限制了[出站请求](../../../security/webhooks.md)，则添加、编辑或连接到 MCP 服务器的尝试可能会失败，即使 URL 本身有效也是如此。

如何解决此问题取决于 MCP 服务的托管位置。

有关更多故障排除信息，请参阅[过滤出站请求](../../../security/webhooks.md#troubleshooting)。

<a id="public-mcp-server"></a>

#### 公共 MCP 服务器

公共 MCP 服务器可以是经过审核的服务器或合作伙伴服务器，也可以是您自己的、可通过互联网访问的服务器。

如果您的实例[阻止除允许名单中的请求之外的所有出站请求](../../../security/webhooks.md#filter-requests)，请让您的实例管理员将 MCP 服务器的域名或 IP 地址添加到[出站请求允许名单](../../../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains)中。

如果您的实例未执行此操作，则无需进一步操作。

<a id="internal-or-local-mcp-server"></a>

#### 内部或本地 MCP 服务器

内部或本地 MCP 服务器可以是运行在 `localhost` 上的服务器，也可以是运行在私有或内部网络上的服务器。

默认情况下，极狐GitLab 会阻止对本地和私有网络地址的请求，以防止服务器端请求伪造。

要允许该请求，请让您的实例管理员执行以下任一操作：

- [允许来自 webhook 和集成的本地网络请求](../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。
  这会允许对所有的本地和私有网络地址的请求，而不仅仅是您的 MCP 服务器。
- 仅将 MCP 服务器的域名或 IP 地址（以及端口，如果需要）添加到出站请求
  允许名单中。此选项限制更严格，因为它不会开放对整个
  本地网络的访问。
