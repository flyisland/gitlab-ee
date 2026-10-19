---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Azure 中配置 OpenID Connect 以获取临时凭证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> `CI_JOB_JWT_V2` 已在 [极狐GitLab 17.0 中移除](../../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)。
> 请改用 [ID 令牌](../../secrets/id_token_authentication.md)。

本教程演示如何在极狐GitLab CI/CD 作业中使用 JSON Web 令牌（JWT），
从 Azure 获取临时凭证，而无需存储密钥。

首先，为极狐GitLab 与 Azure 之间的身份联合配置 OpenID Connect（OIDC）。
有关在极狐GitLab 中使用 OIDC 的更多信息，请阅读[连接到云服务](../_index.md)。

先决条件：

- 可以访问现有的 Azure 订阅，并具有 `Owner` 访问级别。
- 可以访问相应的 Microsoft Entra ID 租户，并至少具有 `Application Developer` 访问级别。
- 本地安装 [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)。
  或者，您也可以使用 [Azure Cloud Shell](https://portal.azure.com/#cloudshell/) 完成以下所有步骤。
- 您的极狐GitLab 实例必须可通过互联网公开访问，因为 Azure 必须能够连接到极狐GitLab OIDC 端点。
- 一个极狐GitLab 项目。

要完成本教程：

1. [创建 Entra ID 应用程序和服务主体](#create-an-entra-id-application-and-service-principal)。
1. [创建 Entra ID 联合身份凭证](#create-entra-id-federated-identity-credentials)。
1. [为服务主体授予权限](#grant-permissions-for-the-service-principal)。
1. [获取临时凭证](#retrieve-a-temporary-credential)。

有关 Azure 身份联合的更多信息，请参阅[工作负载身份联合](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation)。

<a id="create-an-entra-id-application-and-service-principal"></a>

## 创建 Entra ID 应用程序和服务主体

要为极狐GitLab 创建 [Entra ID 应用程序](https://learn.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az-ad-app-create)
和服务主体：

1. 在 Azure CLI 中，为极狐GitLab 创建应用程序：

   ```shell
   appId=$(az ad app create --display-name gitlab-oidc --query appId -otsv)
   ```

   保存输出的 `appId`（应用程序客户端 ID），稍后配置极狐GitLab CI/CD 流水线时需要用到。

1. 创建相应的[服务主体](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create)：

   ```shell
   az ad sp create --id $appId --query appId -otsv
   ```

除了使用 Azure CLI，您也可以[使用 Azure 门户创建这些资源](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal)。

<a id="create-entra-id-federated-identity-credentials"></a>

## 创建 Entra ID 联合身份凭证

要为前面的 Entra ID 应用程序创建针对 `<mygroup>/<myproject>` 中特定分支的联合身份凭证：

```shell
objectId=$(az ad app show --id $appId --query id -otsv)

cat <<EOF > body.json
{
  "name": "gitlab-federated-identity",
  "issuer": "https://gitlab.example.com",
  "subject": "project_path:<mygroup>/<myproject>:ref_type:branch:ref:<branch>",
  "description": "GitLab service account federated identity",
  "audiences": [
    "https://gitlab.example.com"
  ]
}
EOF

az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$objectId/federatedIdentityCredentials" --body @body.json
```

如果遇到与 `issuer`、`subject` 或 `audiences` 值相关的问题，请参阅[故障排除](#troubleshooting)详情。

您也可以选择在 Azure 门户中验证 Entra ID 应用程序和 Entra ID 联合身份凭证：

1. 打开 [Microsoft Entra ID 应用注册](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)
   视图，通过搜索显示名称 `gitlab-oidc` 选择相应的应用注册。
1. 在概览页面上，您可以验证 `Application (client) ID`、
   `Object ID` 和 `Tenant ID` 等详细信息。
1. 在 `Certificates & secrets` 下，转到 `Federated credentials` 以查看您的
   Entra ID 联合身份凭证。

<a id="create-credentials-for-any-branch-or-any-tag"></a>

### 为任意分支或任意标签创建凭证

要为任意分支或标签（通配符匹配）创建凭证，您可以使用[灵活的联合身份凭证](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-flexible-federated-identity-credentials)。

为 `<mygroup>/<myproject>` 中的所有分支：

```shell
objectId=$(az ad app show --id $appId --query id -otsv)

cat <<EOF > body.json
{
  "name": "gitlab-federated-identity",
  "issuer": "https://gitlab.example.com",
  "subject": null,
  "claimsMatchingExpression": {
    "value": "claims['sub'] matches 'project_path:<mygroup>/<myproject>:ref_type:branch:ref:*'",
    "languageVersion": 1
  },
  "description": "GitLab service account federated identity",
  "audiences": [
    "https://gitlab.example.com"
  ]
}
EOF

az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$objectId/federatedIdentityCredentials" --body @body.json
```

为 `<mygroup>/<myproject>` 中的所有标签：

```shell
objectId=$(az ad app show --id $appId --query id -otsv)

cat <<EOF > body.json
{
  "name": "gitlab-federated-identity",
  "issuer": "https://gitlab.example.com",
  "subject": null,
  "claimsMatchingExpression": {
    "value": "claims['sub'] matches 'project_path:<mygroup>/<myproject>:ref_type:tag:ref:*'",
    "languageVersion": 1
  },
  "description": "GitLab service account federated identity",
  "audiences": [
    "https://gitlab.example.com"
  ]
}
EOF

az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$objectId/federatedIdentityCredentials" --body @body.json
```

<a id="grant-permissions-for-the-service-principal"></a>

## 为服务主体授予权限

创建凭证后，使用 [`role assignment`](https://learn.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create) 为前面的服务主体授予权限，使其能够访问 Azure 资源：

```shell
az role assignment create --assignee $appId --role Reader --scope /subscriptions/<subscription-id>
```

您可以在以下位置找到您的订阅 ID：

- [Azure 门户](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id#find-your-azure-subscription)。
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/manage-azure-subscriptions-azure-cli#get-the-active-subscription)。

前面的命令会为整个订阅授予只读权限。有关在您的组织环境中应用最小权限原则的更多信息，请阅读 [Entra ID 角色的最佳实践](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices)。

<a id="retrieve-a-temporary-credential"></a>

## 获取临时凭证

配置 Entra ID 应用程序和联合身份凭证后，CI/CD 作业可以使用 [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login) 获取临时凭证：

```yaml
default:
  image: mcr.microsoft.com/azure-cli:latest

variables:
  AZURE_CLIENT_ID: "<client-id>"
  AZURE_TENANT_ID: "<tenant-id>"

auth:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://jihulab.com
  script:
    - az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token $GITLAB_OIDC_TOKEN
    - az account show
```

CI/CD 变量包括：

- `AZURE_CLIENT_ID`：[您之前保存的应用程序客户端 ID](#create-an-entra-id-application-and-service-principal)。
- `AZURE_TENANT_ID`：您的 Microsoft Entra ID 租户 ID。您可以
  [使用 Azure CLI 或 Azure 门户找到它](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-find-tenant)。
- `GITLAB_OIDC_TOKEN`：一个 OIDC [ID 令牌](../../secrets/id_token_authentication.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-no-matching-federated-identity-record-found"></a>

### 错误：`No matching federated identity record found`

如果您收到错误 `ERROR: AADSTS70021: No matching federated identity record found for presented assertion.`，您应验证：

- Entra ID 联合身份凭证中定义的 `Issuer`，例如
  `https://jihulab.com` 或您自己的极狐GitLab URL。
- Entra ID 联合身份凭证中定义的 `Subject identifier`，
  例如 `project_path:<mygroup>/<myproject>:ref_type:branch:ref:<branch>`。
  - 对于 `gitlab-group/gitlab-project` 项目和 `main` 分支，该值为：
    `project_path:gitlab-group/gitlab-project:ref_type:branch:ref:main`。
  - 要获取 `mygroup` 和 `myproject`的正确值，可以检查访问极狐GitLab 项目时的 URL，
    或者在项目概览页面的右上角选择**代码**。
- Entra ID 联合身份凭证中定义的 `Audience`，例如 `https://jihulab.com`
  或您自己的极狐GitLab URL。

您可以在 Azure 门户中查看这些设置以及您的 `AZURE_CLIENT_ID` 和 `AZURE_TENANT_ID`
CI/CD 变量：

1. 打开 [Microsoft Entra ID 应用注册](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)
   视图，通过搜索显示名称 `gitlab-oidc` 选择相应的应用注册。
1. 在概览页面上，您可以验证 `Application (client) ID`、
   `Object ID` 和 `Tenant ID` 等详细信息。
1. 在 `Certificates & secrets` 下，转到 `Federated credentials` 以查看您的
   Entra ID 联合身份凭证。

有关更多详细信息，请参阅[连接到云服务](../_index.md)。

<a id="request-to-external-oidc-endpoint-failed-message"></a>

### `Request to External OIDC endpoint failed` 消息

如果您收到错误 `ERROR: AADSTS501661: Request to External OIDC endpoint failed.`，您应验证您的极狐GitLab 实例是否可从互联网公开访问。

Azure 必须能够访问以下极狐GitLab 端点才能通过 OIDC 进行身份验证：

- `GET /.well-known/openid-configuration`
- `GET /oauth/discovery/keys`

如果您更新了防火墙后仍收到此错误，请[清除 Redis 缓存](../../../administration/raketasks/maintenance.md#clear-redis-cache)，然后重试。

<a id="no-matching-federated-identity-record-found-for-presented-assertion-audience-message"></a>

### `No matching federated identity record found for presented assertion audience` 消息

如果您收到错误 `ERROR: AADSTS700212: No matching federated identity record found for presented assertion audience 'https://jihulab.com'`，您应验证您的 CI/CD 作业是否使用了正确的 `aud` 值。

`aud` 值应与[创建联合身份凭证](#create-entra-id-federated-identity-credentials)时使用的受众匹配。
