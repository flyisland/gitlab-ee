---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何在极狐GitLab CI/CD 流水线中使用 Azure Key Vault 密钥
title: 在极狐GitLab CI/CD 中使用 Azure Key Vault 密钥
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab CI/CD 流水线中使用存储在 [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault/)中的密钥。

先决条件：

- 在 Azure 上拥有一个 [Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/quick-create-portal)。
  - 您的 IAM 用户必须针对分配给该 Key Vault 的**资源组**[被授予 **Key Vault Administrator** 角色分配](https://learn.microsoft.com/en-us/azure/role-based-access-control/quickstart-assign-role-user-portal#grant-access)。否则，您无法在 Key Vault 中创建密钥。
- [在 Azure 中配置 OpenID Connect 以获取临时凭证](../cloud_services/azure/_index.md)。这些步骤包括如何为 Key Vault 访问创建 Azure AD 应用程序的说明。
- 为您的项目[添加 CI/CD 变量](../variables/_index.md#for-a-project)，以提供有关 Vault 服务器的详细信息：
  - `AZURE_KEY_VAULT_SERVER_URL`：您的 Azure Key Vault 服务器的 URL，例如 `https://vault.example.com`。
  - `AZURE_CLIENT_ID`：Azure 应用程序的客户端 ID。
  - `AZURE_TENANT_ID`：Azure 应用程序的租户 ID。

<a id="use-azure-key-vault-secrets-in-a-cicd-job"></a>

## 在 CI/CD 作业中使用 Azure Key Vault 密钥

您可以通过使用 [`azure_key_vault`](../yaml/_index.md#secretsazure_key_vault) 关键字定义密钥，在作业中使用存储在 Azure Key Vault 中的密钥：

```yaml
job:
  id_tokens:
    AZURE_JWT:
      aud: 'https://jihulab.com'
  secrets:
    DATABASE_PASSWORD:
      token: $AZURE_JWT
      azure_key_vault:
        name: 'DATABASE-PASSWORD'
        version: '00000000000000000000000000000000'
```

要在同一作业中使用 Azure Key Vault 中的多个密钥，请在 `secrets` 关键字下定义每个密钥：

```yaml
job:
  id_tokens:
    AZURE_JWT:
      aud: 'https://jihulab.com'
  secrets:
    REDIS_PASSWORD:
      token: $AZURE_JWT
      azure_key_vault:
        name: 'REDIS-PASSWORD'
        version: '00000000000000000000000000000000'
    DATABASE_PASSWORD:
      token: $AZURE_JWT
      azure_key_vault:
        name: 'DATABASE-PASSWORD'
        version: '00000000000000000000000000000000'
```

在这些示例中：

- `aud` 是受众，它必须与[创建联合身份凭证](../cloud_services/azure/_index.md#create-entra-id-federated-identity-credentials)时使用的受众一致。
- `name` 是 Azure Key Vault 中密钥的名称。
- `version` 是 Azure Key Vault 中密钥的版本。该版本是一个不带连字符的自动生成的 GUID，可在 Azure Key Vault 密钥页面上找到。
- 极狐GitLab 从 Azure Key Vault 获取密钥，并将值存储在一个临时文件中。该文件的路径存储在您于密钥下定义的名称对应的 CI/CD 变量中（例如 `DATABASE_PASSWORD` 或 `REDIS_PASSWORD`），类似于[文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)。

<a id="troubleshooting"></a>

## 故障排除

有关在 Azure 上设置 OIDC 时遇到的一般问题，请参阅 [Azure 的 OIDC 故障排除](../cloud_services/azure/_index.md#troubleshooting)。

<a id="jwt-token-is-invalid-or-malformed-message"></a>

### `JWT token is invalid or malformed` 消息

从 Azure Key Vault 获取密钥时，您可能会收到此错误：

```plaintext
RESPONSE 400 Bad Request
AADSTS50027: JWT token is invalid or malformed.
```

这是由于极狐GitLab Runner 中的一个[已知问题](https://gitlab.com/gitlab-org/gitlab/-/issues/424746)导致的，即 JWT 令牌未被正确解析。要解决此问题，请将您的 runner 升级到受支持的版本。

<a id="caller-is-not-authorized-to-perform-action-on-resource-message"></a>

### `Caller is not authorized to perform action on resource` 消息

从 Azure Key Vault 获取密钥时，您可能会收到此错误：

```plaintext
RESPONSE 403: 403 Forbidden
ERROR CODE: Forbidden
Caller is not authorized to perform action on resource.\r\nIf role assignments, deny assignments or role definitions were changed recently, please observe propagation time.
ForbiddenByRbac
```

如果您的 Azure Key Vault 使用 RBAC，则必须为您的 Azure AD 应用程序添加 **Key Vault Secrets User** 角色分配。

例如：

```shell
appId=$(az ad app list --display-name gitlab-oidc --query '[0].appId' -otsv)
az role assignment create --assignee $appId --role "Key Vault Secrets User" --scope /subscriptions/<subscription-id>
```

您可以在以下位置找到您的订阅 ID：

- [Azure 门户](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id#find-your-azure-subscription)。
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/manage-azure-subscriptions-azure-cli#get-the-active-subscription)。

<a id="the-secrets-provider-can-not-be-found-check-your-cicd-variables-and-try-again-message"></a>

### `The secrets provider can not be found. Check your CI/CD variables and try again.` 消息

尝试启动配置为访问 Azure Key Vault 的作业时，您可能会收到此错误：

```plaintext
The secrets provider can not be found. Check your CI/CD variables and try again.
```

无法创建该作业，因为一个或多个必需变量未定义：

- `AZURE_KEY_VAULT_SERVER_URL`
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
