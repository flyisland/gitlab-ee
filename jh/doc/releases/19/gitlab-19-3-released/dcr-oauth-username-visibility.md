---
title: 查看哪个用户授权了每个 MCP OAuth 应用
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/605884
categories: [ AI Agents ]
level: secondary
weight: 50
---

此前，当 MCP 客户端使用 OAuth 动态客户端注册（DCR）连接到极狐GitLab 时，
所有动态注册的 OAuth 应用在管理区域中仅显示通用客户端名称，
无法判断哪个用户授权了特定应用。
现在，当您批准 MCP OAuth 连接时，您的用户名会自动附加到应用名称中——例如，`[Unverified Dynamic Application] kiro — authorized by @username`。
您可以直接从管理区域快速识别每个动态 OAuth 应用背后的用户，无需任何额外配置。
