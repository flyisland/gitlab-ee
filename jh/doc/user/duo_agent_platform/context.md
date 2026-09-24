---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Understand what context is available to 极狐GitLab Duo features and how to control what information they can access.
title: 极狐GitLab Duo Agent Platform 上下文感知
---

不同信息可用于帮助极狐GitLab Duo 做出决策和提供建议。

信息可用方式：

- 始终可用。
- 基于你的位置（导航时上下文会变化）。
- 显式引用时。例如，你通过 URL、ID 或文件路径提及信息。

<a id="gitlab-duo-agentic-chat"></a>

## 极狐GitLab Duo Agentic Chat

{{< history >}}

- 当前页面标题和 URL 在极狐GitLab 18.6 添加。

{{< /history >}}

以下上下文可用于极狐GitLab Duo Agentic Chat。

<a id="always-available"></a>

### 始终可用

- 极狐GitLab 文档。
- 通用编程知识、最佳实践和语言特性。
- 你的整个项目及其所有被 Git 跟踪的文件。
- 极狐GitLab [Search API](../../api/search.md)，Chat 使用它来查找相关的议题或合并请求。
- 在极狐GitLab UI 中使用 Chat 时，当前页面标题和 URL。

Chat 将自动从 SDLC 数据、[知识图谱](../project/repository/knowledge_graph/_index.md)、[MCP 客户端](../gitlab_duo/model_context_protocol/mcp_clients.md) 和 [自定义指令](customize/_index.md) 中查找必要的上下文。

<a id="based-on-location"></a>

### 基于位置

- 在你的 IDE 中，打开的文件。如果你不希望它们被用作上下文，可以关闭这些文件。
- 在极狐GitLab UI 中，当前页面上下文（例如，查看合并请求或议题时）。

<a id="when-referenced-explicitly"></a>

### 显式引用时

极狐GitLab Duo Agentic Chat 可以自主检索和使用：

- 文件（通过搜索你的项目或当你提供文件路径时）
- 史诗
- 议题
- 合并请求
- CI/CD 流水线和作业日志
- 提交
- 工作项

与非 Agentic Chat 不同，Agentic Chat 可以搜索这些资源，而无需你指定确切的 ID 或 URL。例如，你可以问“查找关于身份验证的合并请求”，Chat 会搜索相关的合并请求。

<a id="extended-context"></a>

### 扩展上下文

- 要将 Chat 连接到外部数据源和工具，请使用 [模型上下文协议 (MCP)](../gitlab_duo/model_context_protocol/_index.md)。
- 要提供项目特定的上下文、编码标准和团队实践，请在 Chat、代理和流程中使用 [自定义规则](customize/custom_rules.md) 或 [AGENTS.md](customize/agents_md.md)。

<a id="software-development-flow"></a>

## 软件开发流程

以下上下文可用于极狐GitLab Duo Agent Platform 中的软件开发流程。

<a id="always-available-1"></a>

### 始终可用

- 通用编程知识、最佳实践和语言特性。
- 你的整个项目及其所有被 Git 跟踪的文件。
- 极狐GitLab [Search API](../../api/search.md)，用于查找相关的议题或合并请求。

<a id="based-on-location-1"></a>

### 基于位置

- 在 IDE 中打开的文件（如果你不希望它们被用作上下文，请关闭文件）。

<a id="when-referenced-explicitly-1"></a>

### 显式引用时

- 文件
- 史诗
- 议题
- 合并请求
- 合并请求的流水线

<a id="exclude-context-from-gitlab-duo"></a>

## 从极狐GitLab Duo 排除上下文

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}
{{< history >}}

- 在极狐GitLab 18.2 引入，带有一个[功能标志](../../administration/feature_flags/_index.md)，名为 `use_duo_context_exclusion`。默认禁用。
- 在极狐GitLab 18.4 中改为测试版。
- 在极狐GitLab 18.5 中默认启用。
- 在极狐GitLab 18.10 中 GA。

{{< /history >}}

你可以控制哪些项目内容被排除作为极狐GitLab Duo 的上下文。使用此功能保护敏感信息，如密码和配置文件。

当你排除内容时，所有极狐GitLab Duo Agent Platform 功能都会将这些信息排除在上下文之外。

<a id="manage-gitlab-duo-context-exclusions"></a>

### 管理极狐GitLab Duo 上下文排除项

要指定极狐GitLab Duo 排除的内容：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **通用**。
1. 在 **极狐GitLab Duo** 下，**极狐GitLab Duo 上下文排除项** 部分，选择 **管理排除项**。
1. 指定要从极狐GitLab Duo 上下文中排除哪些项目文件和目录，然后选择 **保存排除项**。
1. 可选。要删除现有排除项，请选择相应排除项的 **删除** ({{< icon name="remove" >}})。
1. 选择 **保存更改**。

