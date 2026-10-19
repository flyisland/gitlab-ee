---
stage: Agent Foundations
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解极狐GitLab Duo 功能可以使用哪些上下文，以及如何控制它们可以访问的信息。
title: 极狐GitLab Duo Agent Platform 上下文感知
---

可以使用不同的信息来帮助极狐GitLab Duo 做出决策并提供建议。

信息可以在以下情况下可用：

- 始终可用。
- 根据您所在的位置（当您导航时上下文会发生变化）。
- 在明确引用时。例如，您通过 URL、ID 或文件路径提及该信息。

<a id="gitlab-duo-agentic-chat"></a>

## 极狐GitLab Duo Agentic Chat

以下上下文可供极狐GitLab Duo Agentic Chat 使用。

<a id="always-available"></a>

### 始终可用

- 极狐GitLab 文档。
- 通用编程知识、最佳实践和语言特性。
- 您的整个项目及其所有受 Git 跟踪的文件。
- 极狐GitLab [搜索 API](../../api/search.md)，Chat 使用它来查找相关议题或合并请求。
- 在极狐GitLab UI 中使用 Chat 时，当前页面标题和 URL。

Chat 会自动从 SDLC 数据、[知识图谱](../project/repository/knowledge_graph/_index.md)、[MCP 客户端](../gitlab_duo/model_context_protocol/mcp_clients.md)和[自定义指令](customize/_index.md)中查找必要的上下文。

<a id="based-on-location"></a>

### 基于位置

- 在您的 IDE 中，您已打开的文件。如果您不希望将这些文件用作上下文，可以关闭它们。
- 在极狐GitLab UI 中，当前页面上下文（例如，在查看合并请求或议题时）。

<a id="when-referenced-explicitly"></a>

### 在明确引用时

极狐GitLab Duo Agentic Chat 可以自主检索并使用：

- 文件（通过搜索您的项目，或在您提供文件路径时）
- 史诗
- 议题
- 合并请求
- CI/CD 流水线和作业日志
- 提交
- 工作项

与非 Agentic Chat 不同，Agentic Chat 可以搜索这些资源，而无需您指定确切的 ID 或 URL。例如，您可以询问“查找关于身份验证的合并请求”，Chat 会搜索相关的合并请求。

<a id="extended-context"></a>

### 扩展上下文

- 要将 Chat 连接到外部数据源和工具，请使用[模型上下文协议（MCP）](../gitlab_duo/model_context_protocol/_index.md)。
- 要提供项目特定的上下文、编码标准和团队实践，
  请在 Chat、Agent 和任务流中使用[自定义规则](customize/custom_rules.md)或 [AGENTS.md](customize/agents_md.md)。

<a id="software-development-flow"></a>

## 软件开发任务流

以下上下文可供极狐GitLab Duo Agent Platform 中的软件开发任务流使用。

<a id="always-available-1"></a>

### 始终可用

- 通用编程知识、最佳实践和语言特性。
- 您的整个项目及其所有受 Git 跟踪的文件。
- 极狐GitLab [搜索 API](../../api/search.md)，用于查找相关议题或合并请求。

<a id="based-on-location-1"></a>

### 基于位置

- 您在 IDE 中已打开的文件（如果您不希望将这些文件用作上下文，请关闭它们）。

<a id="when-referenced-explicitly-1"></a>

### 在明确引用时

- 文件
- 史诗
- 议题
- 合并请求
- 合并请求的流水线

<a id="exclude-context-from-gitlab-duo"></a>

## 从极狐GitLab Duo 中排除上下文

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

您可以控制将哪些项目内容排除在极狐GitLab Duo 的上下文之外。使用此功能可保护敏感信息，例如密码和配置文件。

当您排除内容后，所有极狐GitLab Duo Agent Platform 功能
都会将该信息排除在上下文之外。

<a id="manage-gitlab-duo-context-exclusions"></a>

### 管理极狐GitLab Duo 上下文排除项

要指定极狐GitLab Duo 排除的内容：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 在**极狐GitLab Duo** 下，在**极狐GitLab Duo 上下文排除项**部分，选择**管理排除项**。
1. 指定哪些项目文件和目录从极狐GitLab Duo 上下文中排除，然后选择**保存排除项**。
1. 可选。要删除现有排除项，请为相应的排除项选择**删除**（{{< icon name="remove" >}}）。
1. 选择**保存更改**。
