---
title: MCP 服务器项目与用户工具
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server_tools"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/627598
categories: [ Agent Tools ]
level: secondary
weight: 50
---

新的项目和用户工具让 Agent 能够通过极狐GitLab MCP 服务器获取所需的上下文，从而准确定位工作目标：

- `list_projects` 查找并读取项目详情。
- `get_user` 查询用户详情，用于指派和提及。

此前，Agent 无法通过极狐GitLab MCP 服务器发现项目或用户信息。
