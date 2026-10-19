---
title: 限制对 MCP 服务器的访问（测试版）
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: software_supply_chain_security
documentation_link: "../../../user/ai-governance/tool-governance/#block-model-context-protocol-mcp-servers"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/628378
categories: [ AI Governance ]
level: primary
weight: 50
---

现在，您可以通过允许或拒绝访问以下内容，来限制对 MCP（模型上下文协议）服务器的访问：

- 整个外部 MCP 服务器。
- MCP 服务器上的单个工具。

此功能让您确信极狐GitLab Duo Agent Platform 中的 AI Agent 在受管控的边界内运行，并且只能访问其执行活动、会话和任务所需范围内的 MCP 工具。

这些控制措施在 AI Agent 运行的所有位置一致适用，包括：

- Agentic Chat。
- 任务流。
- IDE 和 CLI 环境。

此功能目前处于测试版，欢迎您在[议题 #628378](https://gitlab.com/gitlab-org/gitlab/-/issues/628378)中提供反馈。
