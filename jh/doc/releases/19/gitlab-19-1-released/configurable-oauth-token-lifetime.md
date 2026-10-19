---
title: OAuth 访问令牌自定义有效期
tier: [ Free, Premium, Ultimate ]
offering: [ self_managed, gitlab_dedicated ]
stage: software_supply_chain_security
documentation_link: ../../../administration/settings/account_and_limit_settings/#limit-the-lifetime-of-oauth-access-tokens
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/595570
categories: [ System Access ]
level: secondary
weight: 50
---

默认情况下，极狐GitLab 中的 OAuth 访问令牌在两小时后过期。在极狐GitLab 19.1 中，极狐GitLab 私有化部署的实例管理员可以为新的 OAuth 访问令牌设置自定义有效期。您可以配置 300 到 7200 秒之间的任意值。这有助于您为安全敏感的 OAuth 集成（包括 MCP 客户端）强制使用更短生命周期的令牌，同时不改变现有令牌的行为。
