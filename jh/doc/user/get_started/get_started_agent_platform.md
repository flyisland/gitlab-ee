---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在整个开发生命周期中使用 AI 原生功能。
title: 开始使用极狐GitLab Duo Agent Platform
---

极狐GitLab Duo Agent Platform 是一种 AI 原生解决方案，在整个软件开发生命周期中
嵌入了多个智能助手（“Agent”）。

- 无需遵循线性工作流，而是与 AI Agent 异步协作。
- 将日常任务（从代码重构、安全扫描到调研）委托给专门的 AI Agent。

Agent Platform 由多项功能组成，
这些功能可在极狐GitLab UI 和 IDE 中使用。

<a id="step-1-access-gitlab-duo-chat"></a>

## 第 1 步：访问极狐GitLab Duo Chat

极狐GitLab Duo Agentic Chat 是您提问和与 Agent 交互的界面。
它可以提供建议，也可以提出并实施解决方案。

Chat 可以访问您的项目，包括议题、合并请求、提交和 CI/CD 流水线，并且 Chat 会在对话之间保持上下文。您可以逐步增加复杂度，引用之前的回答，并不断迭代直到达到预期结果。

极狐GitLab Duo Chat 可在以下位置使用：

- 极狐GitLab UI。
- 各种 IDE。
- 极狐GitLab Duo CLI。

更多信息，请参见：

- [极狐GitLab Duo Agentic Chat](../gitlab_duo_chat/agentic_chat.md)。
- [极狐GitLab Duo CLI](../gitlab_duo_cli/_index.md)。

<a id="step-2-work-with-agents"></a>

## 第 2 步：使用 Agent

Agent 是为特定工作流设计的专门 AI 助手。

- 内置 Agent 默认可用，可处理常见的开发任务。
  极狐GitLab Duo Agent 可提供问题解答、解释和代码导航方面的一般协助。
  其他内置 Agent 可协助规划发布或保护代码等工作。
- 自定义 Agent 由您的组织创建，用于处理团队特定的工作流。
  您可以为代码评审标准、合规检查、部署自动化
  或任何团队独有的工作流构建 Agent。
- 外部 Agent 将极狐GitLab 与您已在使用的 AI 模型提供商集成。
  您可以从议题、史诗和合并请求触发外部 Agent。

更多信息，请参见：

- [Agent 概览](../duo_agent_platform/agents/_index.md)。
- [内置 Agent](../duo_agent_platform/agents/foundational_agents/_index.md)。
- [自定义 Agent](../duo_agent_platform/agents/custom.md)。
- [外部 Agent](../duo_agent_platform/agents/external.md)。

<a id="step-3-use-multiple-agents-together-in-a-flow"></a>

## 第 3 步：在任务流中同时使用多个 Agent

任务流是一个或多个 Agent 协同工作以完成某项任务的组合。任务流可以帮助您自动化多步骤工作流，这些工作流通常需要工具或团队成员之间手动协调。

例如，您可以从合并请求触发一个任务流，该任务流可以执行安全扫描、评审代码、生成测试并起草文档。

极狐GitLab 提供内置任务流，例如 IDE 中的软件开发任务流，或 UI 中用于转换或修复 CI/CD 流水线的任务流。您也可以创建自己的自定义任务流。

AI 目录是您发现和创建 Agent 与任务流，并在项目中启用它们的中心位置。

更多信息，请参见：

- [任务流](../duo_agent_platform/flows/_index.md)。
- [AI 目录](../duo_agent_platform/ai_catalog.md)。
- [触发器](../duo_agent_platform/triggers/_index.md)。

<a id="step-4-monitor-and-review-agent-activity"></a>

## 第 4 步：监控和审查 Agent 活动

Agent 执行的操作会在会话中通过日志进行跟踪。会话有助于调试、促进学习并支持审计要求。

要查看会话，请转到您的项目并选择 **AI** > **会话**。

更多信息，请参见：

- [会话](../duo_agent_platform/sessions/_index.md)。

<a id="step-5-extend-capabilities-with-integrations"></a>

## 第 5 步：通过集成扩展能力

要增加 AI Agent 的知识，请使用知识图谱。它会为您的代码仓库创建结构化表示，帮助 Agent 和您的团队更好地理解文件、函数和依赖项之间的关系。

您还可以通过连接外部工具和数据源，将平台扩展到极狐GitLab 之外。

- 将 Agentic Chat 等极狐GitLab Duo 功能连接到外部 MCP 服务器，
  以便其他 MCP 客户端可以提供更全面的协助。
- MCP 服务器的工作方向相反：Claude Desktop 或 Cursor 等外部 AI 工具
  可以安全地连接到您的
  极狐GitLab 实例，使这些工具能够访问您的极狐GitLab 数据。

更多信息，请参见：

- [知识图谱](../project/repository/knowledge_graph/_index.md)。
- [MCP 客户端](../gitlab_duo/model_context_protocol/mcp_clients.md)。
- [MCP 服务器](../model_context_protocol/mcp_server.md)。

<a id="resources"></a>

## 资源

- 八部分教程：[开始使用极狐GitLab Duo Agent Platform：完整指南](https://about.gitlab.com/blog/gitlab-duo-agent-platform-complete-getting-started-guide/)
- 博客：[GitLab 工程师：我如何通过 AI 改善入职体验](https://about.gitlab.com/blog/gitlab-engineer-how-i-improved-my-onboarding-experience-with-ai/)
- [从非 Agentic 极狐GitLab Duo 过渡到极狐GitLab Duo Agent Platform](../../administration/gitlab_duo/configure/transition-to-the-agent-platform.md)
<!-- Video published on 2025-12-09 -->
