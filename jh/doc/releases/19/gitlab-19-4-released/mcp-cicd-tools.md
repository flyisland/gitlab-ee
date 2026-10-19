---
title: MCP 服务器 CI/CD 工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/627598
categories: [ Agent Tools ]
level: secondary
weight: 50
---

新的 CI/CD 工具让 Agent 可以从任何 MCP 客户端触发、检查和管控 CI/CD：

- `save_pipeline` 无需切换工具即可运行、重试或取消流水线。
- `get_job` 会返回作业元数据以及作业跟踪日志，因此 Agent 可以自行读取失败构建的日志并诊断问题。

此前，Agent 无法通过 MCP 触发或检查流水线。
