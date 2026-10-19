---
title: 为 MCP 禁用 OAuth 动态客户端注册
tier: [ Free, Premium, Ultimate ]
offering: [ self_managed, gitlab_dedicated ]
stage: software_supply_chain_security
documentation_link: "../../../administration/settings/account_and_limit_settings/#oauth-dynamic-client-registration"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/601438
categories: [ System Access ]
level: secondary
weight: 50
---

此前，MCP 客户端和 AI 工具可以通过动态客户端注册（DCR）在您的实例上自动注册 OAuth 应用程序，而您无法关闭此功能。这使得极狐GitLab 私有化部署实例上的管理员难以控制哪些 OAuth 客户端可以连接。

现在，您可以使用应用程序设置 API 完全禁用 DCR，从而完全控制哪些 OAuth 客户端可以访问您的实例。当 DCR 被禁用时，客户端必须使用预先注册的 OAuth 应用程序，而不是自动注册。
