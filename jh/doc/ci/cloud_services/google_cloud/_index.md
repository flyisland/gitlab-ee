---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 OpenID Connect 与 GCP 工作负载身份联合
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> `CI_JOB_JWT_V2` 在极狐GitLab 15.9 中[被弃用](../../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)，
> 并计划在极狐GitLab 17.0 中移除。请改用 [ID tokens](../../secrets/id_token_authentication.md)。

本教程演示了如何在极狐GitLab CI/CD 作业中使用 JSON Web 令牌 (JWT) 和工作负载身份联合向 Google Cloud 进行身份验证。此配置可以按需生成短期的凭据，无需存储任何密钥。

要开始配置，请在极狐GitLab 和 Google Cloud 之间设置 OpenID Connect (OIDC) 身份联合。有关在极狐GitLab 中使用 OIDC 的更多信息，请参阅[连接到云服务](../_index.md)。

本教程假设您拥有 Google Cloud 账号和一个 Google Cloud 项目。您的账号必须至少对 Google Cloud 项目拥有**工作负载身份池管理员**权限。

要完成本教程，请执行以下步骤：

1. [创建 Google Cloud 工作负载身份池](#create-the-google-cloud-workload-identity-pool)。
1. [创建工作负载身份提供者](#create-a-workload-identity-provider)。
1. [授予服务账号模拟权限](#grant-permissions-for-service-account-impersonation)。
1. [获取临时凭据](#retrieve-a-temporary-credential)。

<a id="create-the-google-cloud-workload-identity-pool"></a>

## 创建 Google Cloud 工作负载身份池

[创建一个新的 Google Cloud 工作负载身份池](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create_the_workload_identity_pool_and_provider)，并使用以下选项：

- **名称**：工作负载身份池的易于识别的名称，例如 `GitLab`。
- **池 ID**：工作负载身份池在 Google Cloud 项目中的唯一 ID，例如 `gitlab`。此值用于引用该池，并会出现在 URL 中。
- **描述**：可选。对池的描述。
- **启用池**：确保此选项为 `true`。

我们建议在每个 Google Cloud 项目中为每个极狐GitLab 安装创建一个单独的池。如果您在同一极狐GitLab 实例上有多个极狐GitLab 仓库和 CI/CD 作业，它们可以使用不同的提供者对同一个池进行身份验证。

<a id="create-a-workload-identity-provider"></a>

## 创建工作负载身份提供者

在之前步骤中创建的工作负载身份池内，使用以下选项[创建一个新的 Google Cloud 工作负载身份提供者](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create_the_workload_identity_pool_and_provider)：

- **提供者类型**：OpenID Connect (OIDC)。
- **提供者名称**：工作负载身份提供者的易于识别的名称，例如 `gitlab/gitlab`。
- **提供者 ID**：工作负载身份提供者在池中的唯一 ID，例如 `gitlab-gitlab`。此值用于引用该提供者，并会出现在 URL 中。
- **发行者（URL）**：您的极狐GitLab 实例的地址，例如 `https://gitlab.com/` 或 `https://gitlab.example.com/`。
  - 地址必须使用 `https://` 协议。
  - 地址必须以尾随斜杠结尾。
- **受众**：手动将允许的受众列表设置为您的极狐GitLab 实例的地址，例如 `https://gitlab.com` 或 `https://gitlab.example.com`。
  - 地址必须使用 `https://` 协议。
  - 地址不得以尾随斜杠结尾。
- **提供者属性映射**：创建以下映射，其中 `attribute.X` 是将作为声明包含在 Google 令牌中的属性名称，而 `assertion.X` 是要从[极狐GitLab 声明](../_index.md#id-token-authentication-for-cloud-services)中提取的值：

  | Attribute（在 Google 上） | Assertion（来自极狐GitLab） |
  | --- | --- |
  | `google.subject` | `assertion.sub` |
  | `attribute.X` | `assertion.X` |

  您还可以使用通用表达式语言 (CEL) [构建复杂属性](https://cloud.google.com/iam/docs/workload-identity-federation#mapping)。

  您必须映射要用于权限授予的每个属性。例如，如果您希望在下一步中基于用户的邮箱地址映射权限，则必须将 `attribute.user_email` 映射到 `assertion.user_email`。

> [!warning]
> 对于托管在 JihuLab.com 上的项目，GCP 要求您[限制只能访问您的极狐GitLab 群组签发的令牌](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#gitlab-saas_2)。

<a id="grant-permissions-for-service-account-impersonation"></a>

## 授予服务账号模拟权限

创建工作负载身份池和工作负载身份提供者定义了向 Google Cloud 进行身份验证的方式。此时，您可以从极狐GitLab CI/CD 作业向 Google Cloud 进行身份验证。但是，您在 Google Cloud 上还没有任何权限（授权）。

要向极狐GitLab CI/CD 作业授予 Google Cloud 权限，您必须：

1. [创建一个 Google Cloud 服务账号](https://cloud.google.com/iam/docs/service-accounts-create)。您可以使用任何您喜欢的名称和 ID。
1. [向您的服务账号授予 IAM 权限](https://cloud.google.com/iam/docs/granting-changing-revoking-access)，以便访问 Google Cloud 资源。这些权限因您的用例而异。通常，会根据您希望极狐GitLab CI/CD 作业能够使用的 Google Cloud 项目和资源，向此服务账号授予相应权限。例如，如果您需要在极狐GitLab CI/CD 作业中将文件上传到 Google Cloud Storage 存储桶，您可以向此服务账号授予对您的 Cloud Storage 存储桶的 `roles/storage.objectCreator` 角色。
1. [授予外部身份权限](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#impersonate)以模拟该服务账号。此步骤允许极狐GitLab CI/CD 作业通过服务账号模拟的方式，向 Google Cloud 进行授权。此步骤在服务账号自身上授予 IAM 权限，赋予外部身份充当该服务账号的权限。外部身份使用 `principalSet://` 协议表示。

与前一步类似，此步骤在很大程度上取决于您所需的配置。例如，要允许用户名是 `chris` 的极狐GitLab 用户启动的极狐GitLab CI/CD 作业模拟名为 `my-service-account` 的服务账号，您需要向 `my-service-account` 上的外部身份授予 `roles/iam.workloadIdentityUser` IAM 角色。外部身份的格式如下：

```plaintext
principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.user_login/chris
```

其中 `PROJECT_NUMBER` 是您的 Google Cloud 项目编号，`POOL_ID` 是第一节中创建的工作负载身份池的 ID（不是名称）。

此配置还假设您在上一节中将 `user_login` 添加为从断言映射的属性。

<a id="retrieve-a-temporary-credential"></a>

## 获取临时凭据

配置好 OIDC 和角色之后，极狐GitLab CI/CD 作业可以从 [Google Cloud 安全令牌服务 (STS)](https://cloud.google.com/iam/docs/reference/sts/rest) 获取临时凭据。

将 `id_tokens` 添加到您的 CI/CD 作业：

```yaml
job:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.example.com
```

使用 ID 令牌获取临时凭据：

```shell
PAYLOAD="$(cat <<EOF
{
  "audience": "//iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID",
  "grantType": "urn:ietf:params:oauth:grant-type:token-exchange",
  "requestedTokenType": "urn:ietf:params:oauth:token-type:access_token",
  "scope": "https://www.googleapis.com/auth/cloud-platform",
  "subjectTokenType": "urn:ietf:params:oauth:token-type:jwt",
  "subjectToken": "${GITLAB_OIDC_TOKEN}"
}
EOF
)"
```

```shell
FEDERATED_TOKEN="$(curl --fail "https://sts.googleapis.com/v1/token" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data "${PAYLOAD}" \
  | jq -r '.access_token'
)"
```

其中：

- `PROJECT_NUMBER` 是您的 Google Cloud 项目编号（不是名称）。
- `POOL_ID` 是第一节中创建的工作负载身份池的 ID。
- `PROVIDER_ID` 是第二节中创建的工作负载身份提供者的 ID。
- `GITLAB_OIDC_TOKEN` 是一个 OIDC [ID 令牌](../../secrets/id_token_authentication.md)。

然后，您可以使用生成的联合令牌来模拟在上一节中创建的服务账号：

```shell
ACCESS_TOKEN="$(curl --fail "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/SERVICE_ACCOUNT_EMAIL:generateAccessToken" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer FEDERATED_TOKEN" \
  --data '{"scope": ["https://www.googleapis.com/auth/cloud-platform"]}' \
  | jq -r '.accessToken'
)"
```

其中：

- `SERVICE_ACCOUNT_EMAIL` 是要模拟的服务账号的完整邮箱地址，该账号在上一节中创建。
- `FEDERATED_TOKEN` 是从上一步获取的联合令牌。

结果是一个 Google Cloud OAuth 2.0 访问令牌，当用作持有者令牌时，您可以使用它向大多数 Google Cloud API 和服务进行身份验证。您也可以通过设置环境变量 `CLOUDSDK_AUTH_ACCESS_TOKEN` 将此值传递给 `gcloud` CLI。

<a id="working-example"></a>

## 工作示例

请参阅此[参考项目](https://jihulab.com/guided-explorations/gcp/configure-openid-connect-in-gcp)，了解使用 Terraform 在 GCP 中配置 OIDC 以及用于获取临时凭据的示例脚本。

<a id="troubleshooting"></a>

## 故障排除

- 在调试 `curl` 响应时，请安装最新版本的 curl。使用 `--fail-with-body` 代替 `-f`。该命令会打印整个响应体，其中可能包含有用的错误消息。

- 有关更多信息，请参阅[工作负载身份联合故障排除](https://cloud.google.com/iam/docs/troubleshooting-workload-identity-federation)。