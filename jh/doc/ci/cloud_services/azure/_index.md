---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Azure 中配置 OpenID Connect 以检索临时凭证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> `CI_JOB_JWT_V2` 已在极狐GitLab 15.9 [弃用](../../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)，并计划在极狐GitLab 17.0 中移除。请改用 [ID 令牌](../../secrets/id_token_authentication.md)。

本教程演示如何在不存储密钥的情况下，在极狐GitLab CI/CD 作业中使用 JSON Web 令牌（JWT）从 Azure 检索临时凭证。

要开始使用，请为极狐GitLab 和 Azure 之间的身份联合配置 OpenID Connect (OIDC)。有关将 OIDC 与极狐GitLab 结合使用的更多信息，请参阅[连接到云服务](../_index.md)。

前提条件：

- 具有 `所有者` 访问级别的现有 Azure 订阅。
- 具有至少 `应用程序开发者` 访问级别的相应 Microsoft Entra ID 租户访问权限。
- 本地安装的 [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)。或者，你也可以使用 [Azure Cloud Shell](https://portal.azure.com/#cloudshell/) 执行后续所有步骤。
- 你的极狐GitLab 实例必须能够通过互联网公开访问，因为 Azure 需要连接到极狐GitLab OIDC 端点。
- 一个极狐GitLab 项目。

要完成本教程：

1. [创建 Entra ID 应用程序和服务主体](#create-an-entra-id-application-and-service-principal)。
1. [创建 Entra ID 联合身份凭证](#create-entra-id-federated-identity-credentials)。
1. [授予服务主体权限](#grant-permissions-for-the-service-principal)。
1. [检索临时凭证](#retrieve-a-temporary-credential)。

有关 Azure 身份联合的更多信息，请参阅[工作负载身份联合](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation)。

<a id="create-an-entra-id-application-and-service-principal"></a>

## 创建 Entra ID 应用程序和服务主体

要为极狐GitLab 创建 [Entra ID 应用程序](https://learn.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az-ad-app-create)和服务主体：

1. 在 Azure CLI 中，为极狐GitLab 创建应用程序：

   ```shell
   appId=$(az ad app create --display-name gitlab-oidc --query appId -otsv)
   ```

   保存输出的 `appId`（应用程序客户端 ID），因为稍后配置极狐GitLab CI/CD 流水线时需要用到它。

1. 创建相应的[服务主体](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create)：

   ```shell
   az ad sp create --id $appId --query appId -otsv
   ```

除了使用 Azure CLI，你也可以[使用 Azure 门户创建这些资源](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal)。

<a id="create-entra-id-federated-identity-credentials"></a>

## 创建 Entra ID 联合身份凭证

要为 `<mygroup>/<myproject>` 中特定分支的上一个 Entra ID 应用程序创建联合身份凭证，请执行以下命令：

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

若遇到与 `issuer`、`subject` 或 `audiences` 值相关的问题，请参阅[故障排除](#troubleshooting)详情。

可选地，你现在可以通过 Azure 门户验证 Entra ID 应用程序和 Entra ID 联合身份凭证：

1. 打开 [Microsoft Entra ID 应用注册](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)视图，并通过搜索显示名称 `gitlab-oidc` 选择相应的应用注册。
1. 在概览页面上，你可以验证诸如 `应用程序(客户端) ID`、`对象 ID` 和 `租户 ID` 等详细信息。
1. 在 `证书和密码` 下，转到 `联合凭据` 以查看你的 Entra ID 联合身份凭证。

<a id="create-credentials-for-any-branch-or-any-tag"></a>

### 为任意分支或任意标签创建凭证

要为任意分支或标签（通配符匹配）创建凭证，你可以使用[灵活的联合身份凭证](https://learn.microsoft.com/entra/workload-id/workload-identities-flexible-federated-identity-credentials)。

针对 `<mygroup>/<myproject>` 中的所有分支：

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

针对 `<mygroup>/<myproject>` 中的所有标签：

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

## 授予服务主体权限

创建凭证后，使用 [`role assignment`](https://learn.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create) 向上一个服务主体授予权限，使其能够访问 Azure 资源：

```shell
az role assignment create --assignee $appId --role Reader --scope /subscriptions/<subscription-id>
```

你可以通过以下方式找到你的订阅 ID：

- [Azure 门户](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id#find-your-azure-subscription)。
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/manage-azure-subscriptions-azure-cli#get-the-active-subscription)。

上述命令授予对整个订阅的只读权限。有关如何在你的组织上下文中应用最小权限原则的更多信息，请参阅[Entra ID 角色的最佳实践](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices)。

<a id="retrieve-a-temporary-credential"></a>

## 检索临时凭证

配置 Entra ID 应用程序和联合身份凭证后，CI/CD 作业可以使用 [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login) 检索临时凭证：

```yaml
default:
  image: mcr.microsoft.com/azure-cli:latest

variables:
  AZURE_CLIENT_ID: "<client-id>"
  AZURE_TENANT_ID: "<tenant-id>"

auth:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.com
  script:
    - az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token $GITLAB_OIDC_TOKEN
    - az account show
```

CI/CD 变量如下：

- `AZURE_CLIENT_ID`：你[之前保存的应用程序客户端 ID](#create-an-entra-id-application-and-service-principal)。
- `AZURE_TENANT_ID`：你的 Microsoft Entra ID 租户 ID。你可以[使用 Azure CLI 或 Azure 门户找到它](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-find-tenant)。
- `GITLAB_OIDC_TOKEN`：一个 OIDC [ID 令牌](../../secrets/id_token_authentication.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-no-matching-federated-identity-record-found"></a>

### 错误：`未找到匹配的联合身份记录`

如果你收到错误 `ERROR: AADSTS70021: No matching federated identity record found for presented assertion.`，请验证：

- 在 Entra ID 联合身份凭证中定义的 `Issuer`，例如 `https://gitlab.com` 或你自己的极狐GitLab URL。
- 在 Entra ID 联合身份凭证中定义的 `Subject identifier`，例如 `project_path:<mygroup>/<myproject>:ref_type:branch:ref:<branch>`。
  - 对于 `gitlab-group/gitlab-project` 项目和 `main` 分支，它将是：`project_path:gitlab-group/gitlab-project:ref_type:branch:ref:main`。
  - `mygroup` 和 `myproject` 的正确值可以通过检查访问极狐GitLab 项目时的 URL 获取，或在项目概览页的右上角选择 **代码** 获取。
- 在 Entra ID 联合身份凭证中定义的 `Audience`，例如 `https://gitlab.com` 或你自己的极狐GitLab URL。

你可以通过 Azure 门户查看这些设置，以及你的 `AZURE_CLIENT_ID` 和 `AZURE_TENANT_ID` CI/CD 变量：

1. 打开 [Microsoft Entra ID 应用注册](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)视图，并通过搜索显示名称 `gitlab-oidc` 选择相应的应用注册。
1. 在概览页面上，你可以验证诸如 `应用程序(客户端) ID`、`对象 ID` 和 `租户 ID` 等详细信息。
1. 在 `证书和密码` 下，转到 `联合凭据` 以查看你的 Entra ID 联合身份凭证。

查看[连接到云服务](../_index.md)获取更多详细信息。

<a id="request-to-external-oidc-endpoint-failed-message"></a>

### `请求外部 OIDC 端点失败` 消息

如果你收到错误 `ERROR: AADSTS501661: Request to External OIDC endpoint failed.`，应验证你的极狐GitLab 实例是否可从互联网公开访问。

Azure 必须能够访问以下极狐GitLab 端点以进行 OIDC 身份验证：

- `GET /.well-known/openid-configuration`
- `GET /oauth/discovery/keys`

如果你更新了防火墙但仍然收到此错误，请[清除 Redis 缓存](../../../administration/raketasks/maintenance.md#clear-redis-cache)并重试。

<a id="no-matching-federated-identity-record-found-for-presented-assertion-audience-message"></a>

### `未找到与提供的断言受众匹配的联合身份记录` 消息

如果你收到错误 `ERROR: AADSTS700212: No matching federated identity record found for presented assertion audience 'https://gitlab.com'`，请验证你的 CI/CD 作业使用了正确的 `aud` 值。

`aud` 值应与用于[创建联合身份凭证](#create-entra-id-federated-identity-credentials)的受众匹配。