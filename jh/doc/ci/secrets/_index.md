---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 CI/CD 中使用外部密钥
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI/CD 任务可能需要敏感信息（称为密钥）来完成任务。
这些敏感信息可以是 API 令牌、数据库凭证或私钥。
密钥来源于密钥提供程序。

与在任务中始终可用的 CI/CD 变量不同，密钥必须由任务显式请求。

极狐GitLab 支持多种密钥管理提供程序，包括：

1. [HashiCorp Vault](hashicorp_vault.md)
1. [Google Cloud Secret Manager](gcp_secret_manager.md)
1. [Azure Key Vault](azure_key_vault.md)
1. [AWS Secrets Manager](aws_secrets_manager.md)

这些集成使用 [ID 令牌](id_token_authentication.md) 进行身份验证。
您还可以使用 ID 令牌手动对任何支持 OIDC 身份验证与 JSON Web 令牌 (JWT) 的密钥提供程序进行身份验证。