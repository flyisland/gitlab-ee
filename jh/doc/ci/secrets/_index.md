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

CI/CD 作业可能需要敏感信息（称为密钥）才能完成工作。这些敏感信息可能是 API 令牌、数据库凭据或私钥等条目。密钥来自密钥提供商。

与在作业中始终可用的 CI/CD 变量不同，密钥必须由作业显式请求。

极狐GitLab 支持多种密钥管理提供商，包括：

1. [HashiCorp Vault](hashicorp_vault.md)
1. [Google Cloud 密钥管理器](gcp_secret_manager.md)
1. [Azure Key Vault](azure_key_vault.md)
1. [AWS 密钥管理器](aws_secrets_manager.md)

这些集成使用 [ID 令牌](id_token_authentication.md)进行身份验证。您还可以使用 ID 令牌手动向任何支持使用 JSON Web 令牌 (JWT) 进行 OIDC 身份验证的密钥提供商进行身份验证。
