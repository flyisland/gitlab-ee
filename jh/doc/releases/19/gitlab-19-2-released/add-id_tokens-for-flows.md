---
title: 在 Flow 中配置 ID 令牌
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: ai-powered
documentation_link: "../../../user/duo_agent_platform/flows/execution/#configure-id-tokens"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/591140
categories: [ Runner Execution, System Access ]
level: secondary
weight: 50
---

使用 ID 令牌与第三方 OpenID Connect（OIDC）服务进行身份验证，无需存储长期凭证。例如，使用 ID 令牌对二进制文件和提交进行无密钥签名，或从密钥管理器中检索密钥。

要使用此功能，请更新您的 Agent 配置以包含 `id_tokens` 关键字，然后将服务配置为信任由极狐GitLab Duo Agent Platform 颁发的令牌。
