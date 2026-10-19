---
title: 独立于 Agent Platform 开启 MCP 服务器
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/590729
categories: [ AI Agents ]
level: secondary
weight: 50
---

为了让您更精细地控制外部工具如何连接到您的极狐GitLab 实例或群组，
您现在可以独立于 Agent Platform 设置，开启或关闭极狐GitLab MCP 服务器。

此前，极狐GitLab MCP 服务器和 Agent Platform 共用同一个开关设置，
因此您无法在不开启 Agent Platform 功能的情况下开启 MCP 服务器。
现在，您可以允许其他工具将极狐GitLab 作为 MCP 服务器访问，而无需开启 Agent Platform，
也可以在您使用 Agent Platform 功能时，保持极狐GitLab MCP 服务器处于关闭状态。
