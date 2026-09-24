---
stage: AI 驱动
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在整个开发生命周期中使用 AI 原生功能。
title: 极狐GitLab Duo Agent Platform 入门
---

极狐GitLab Duo Agent Platform 是一个 AI 原生解决方案，在整个软件开发生命周期中嵌入了多个智能助手（“Agent”）。

- 无需遵循线性工作流程，你可以与 AI Agent 进行异步协作。
- 将日常任务（从代码重构和安全扫描到研究）委派给专门的 AI Agent。

Agent Platform 由多个功能组成，这些功能在 极狐GitLab UI 和 IDE 中均可使用。

<a id="step-1-access-gitlab-duo-chat"></a>

### 步骤 1：访问 极狐GitLab Duo Chat

极狐GitLab Duo Agentic Chat，无论是在 UI 还是你的本地环境中，都是你提问和与 Agent 互动的界面。
它既可以提供建议，也可以提出并实施方案。

Chat 可以访问你的项目，包括议题、合并请求、提交以及 CI/CD 流水线，并且 Chat 会在对话中保持上下文。
你可以逐步构建复杂性，引用之前的回复，并进行迭代，直至达到预期结果。

极狐GitLab Duo Chat 在 极狐GitLab UI 和各种 IDE 中均可使用。

更多信息，请参见：

- [极狐GitLab Duo Agentic Chat](../gitlab_duo_chat/agentic_chat.md)。

<a id="step-2-work-with-agents"></a>

### 步骤 2：使用 Agent

Agent 是为特定工作流程设计的专用 AI 助手。

- 内置 Agent 默认可用，负责处理常见的开发任务。
  极狐GitLab Duo Agent 为问题、解释和代码导航提供通用帮助。
  其他内置 Agent 则协助规划版本或保护代码安全等事务。
- 自定义 Agent 由你的组织创建，用于处理团队特定的工作流程。
  你可以为代码审查标准、合规性检查、部署自动化或任何团队特有的工作流程构建 Agent。
- 外部 Agent 将 极狐GitLab 与你已在使用的 AI 模型提供商集成。
  你可以从议题、史诗和合并请求中触发外部 Agent。

更多信息，请参见：

- [Agent 概览](../duo_agent_platform/agents/_index.md)。
- [内置 Agent](../duo_agent_platform/agents/foundational_agents/_index.md)。
- [自定义 Agent](../duo_agent_platform/agents/custom.md)。
- [外部 Agent](../duo_agent_platform/agents/external.md)。

<a id="step-3-use-multiple-agents-together-in-a-flow"></a>

### 步骤 3：在工作流中将多个 Agent 结合使用

工作流（Flow）是一个或多个 Agent 协同工作以完成任务的一种组合。
工作流可以帮助你自动化多步骤工作流程，这些流程通常需要工具或团队成员之间进行手动协调。

例如，你可以从合并请求触发一个工作流，该工作流可以执行安全扫描、审查代码、生成测试并起草文档。

极狐GitLab 提供了基础工作流，例如 IDE 中的软件开发工作流，或者是 UI 中用于转换或修复 CI/CD 流水线等工作流。
你也可以创建自己的自定义工作流。

AI Catalog 是一个中心位置，你可以在其中发现并创建 Agent 和工作流，并将其启用至你的项目中使用。

更多信息，请参见：

- [工作流](../duo_agent_platform/flows/_index.md)。
- [AI Catalog](../duo_agent_platform/ai_catalog.md)。
- [触发器](../duo_agent_platform/triggers/_index.md)。

<a id="step-4-monitor-and-review-agent-activity"></a>

### 步骤 4：监控和审查 Agent 活动

Agent 执行的操作会在一个带有日志的会话中被跟踪。
会话有助于调试、促进学习并支持审计需求。

要查看会话，请前往你的项目并选择 **AI** > **Sessions**。

更多信息，请参见：

- [会话](../duo_agent_platform/sessions/_index.md)。

<a id="step-5-extend-capabilities-with-integrations"></a>

### 步骤 5：通过集成扩展能力

要增强 AI Agent 的知识，可以使用知识图谱。
它为你的代码仓库创建结构化的表示，帮助 Agent 和你的团队更好地理解文件、函数和依赖项之间的关系。

你还可以通过连接外部工具和数据源，将平台能力扩展到 极狐GitLab 之外。

- 将 Agentic Chat 等 极狐GitLab Duo 功能连接到外部 MCP 服务器，以便其他 MCP 客户端可以提供更全面的帮助。
- MCP 服务器则以相反的方向工作：兼容 MCP 的工具的 AI 助手可以安全地连接到你的 极狐GitLab 实例，让这些工具能够访问你的 极狐GitLab 数据。

更多信息，请参见：

- [知识图谱](../project/repository/knowledge_graph/_index.md)。
- [MCP 客户端](../gitlab_duo/model_context_protocol/mcp_clients.md)。
- [MCP 服务器](../gitlab_duo/model_context_protocol/mcp_server.md)。

<a id="resources"></a>

### 资源