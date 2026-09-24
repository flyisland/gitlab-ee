---
title: 预注册 MCP OAuth 应用程序
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: agent_foundations
documentation_link: "../../../user/model_context_protocol/mcp_server#reuse-a-pre-registered-oauth-application"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/601437
categories: [ Agent Tools ]
level: secondary
weight: 50
---

此前，`mcp` 范围在**管理员**区域的 OAuth 应用程序表单中处于隐藏状态，因此您无法在不使用动态客户端注册（DCR）的情况下为您的 MCP 客户端预注册 OAuth 应用程序。
现在，您可以直接在**管理员**区域创建具有 `mcp` 范围的共享 OAuth 应用程序，为您的用户提供可复用的稳定客户端 ID，并帮助您避免共享网络上的 DCR 速率限制。
