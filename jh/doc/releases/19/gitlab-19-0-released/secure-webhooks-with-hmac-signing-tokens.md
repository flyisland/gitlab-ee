---
title: 使用 HMAC 签名令牌保护 Webhook 安全
stage: create
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../user/project/integrations/webhooks/#signing-tokens"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/19367"
categories: [ Importers ]
weight: 110
---

现有的 `X-Gitlab-Token` 标头以明文发送静态密钥，导致 Webhook 容易遭受拦截和重放攻击。

现在，您可以为任何 Webhook 添加签名令牌。极狐GitLab 使用该签名令牌对以下内容计算 HMAC-SHA256 签名：

- 唯一的 Webhook ID。
- 请求时间戳。
- Webhook 负载。

随后，极狐GitLab 通过 `webhook-signature` 标头发送计算结果，并同时发送 `webhook-id` 和 `webhook-timestamp` 标头，遵循 [Standard Webhooks](https://www.standardwebhooks.com/) 规范。

您可以重新计算签名，以确认请求确实来自极狐GitLab，且负载未被修改。同时，通过验证时间戳，您可以拒绝重放的请求。

感谢 [Van Anderson](https://gitlab.com/van.m.anderson) 和 [Norman Debald](https://gitlab.com/Modjo85) 的社区贡献！
