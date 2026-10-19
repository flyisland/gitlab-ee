---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 GCP 工作负载身份联合配置 OpenID Connect
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> `CI_JOB_JWT_V2` 已在 [极狐GitLab 17.0 中移除](../../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)。
> 请改用 [ID 令牌](../../secrets/id_token_authentication.md)。

本教程演示如何在极狐GitLab CI/CD 作业中使用 JSON Web Token (JWT) 令牌和工作负载身份联合向 Google Cloud 进行身份验证。此配置会按需生成短期凭证，无需存储任何密钥。

首先，为极狐GitLab 与 Google Cloud 之间的身份联合配置 OpenID Connect (OIDC)。有关将 OIDC 与极狐GitLab 配合使用的更多信息，请阅读[连接到云服务](../_index.md)。

本教程假设您拥有 Google Cloud 账号和 Google Cloud 项目。您的账号必须至少拥有 Google Cloud 项目上的 **工作负载身份池管理员** 权限。

> [!note]
> 如果您希望改用 Terraform 模块和 CI/CD 模板，而不是本教程，
> 请参阅 [OIDC 如何简化极狐GitLab CI/CD 流水线与 Google Cloud 的身份验证](https://about.gitlab.com/blog/introduction-of-oidc-modules-for-integration-between-google-cloud-and-gitlab-ci/)。

要完成本教程：

1. [创建 Google Cloud 工作负载身份池](#create-the-google-cloud-workload-identity-pool)。
1. [创建工作负载身份提供商](#create-a-workload-identity-provider)。
1. [授予服务账号模拟权限](#grant-permissions-for-service-account-impersonation)。
1. [获取临时凭证](#retrieve-a-temporary-credential)。

<a id="create-the-google-cloud-workload-identity-pool"></a>

## 创建 Google Cloud 工作负载身份池

使用以下选项[创建新的 Google Cloud 工作负载身份池](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create_the_workload_identity_pool_and_provider)：

- **名称**：工作负载身份池的易读名称，例如 `GitLab`。
- **池 ID**：工作负载身份池在 Google Cloud 项目中的唯一 ID，
  例如 `gitlab`。此值用于引用该池，并会出现在 URL 中。
- **描述**：可选。该池的描述。
- **启用池**：确保此选项为 `true`。

为每个 Google Cloud 项目中的每个极狐GitLab 安装创建一个池。如果您在同一极狐GitLab 实例上有多个代码仓库和 CI/CD 作业，它们可以使用不同的提供商针对同一个池进行身份验证。

<a id="create-a-workload-identity-provider"></a>

## 创建工作负载身份提供商

在上一步创建的工作负载身份池中，[创建新的 Google Cloud 工作负载身份提供商](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#create_the_workload_identity_pool_and_provider)，使用以下选项：

- **提供商类型**：OpenID Connect (OIDC)。
- **提供商名称**：工作负载身份提供商的易读名称，
  例如 `gitlab/gitlab`。
- **提供商 ID**：工作负载身份提供商在池中的唯一 ID，
  例如 `gitlab-gitlab`。此值用于引用该提供商，并会出现在 URL 中。
- **签发者（URL）**：您的极狐GitLab 实例地址，例如 `https://jihulab.com/` 或
  `https://gitlab.example.com/`。
  - 该地址必须使用 `https://` 协议。
  - 该地址必须以斜杠结尾。
- **受众**：将允许的受众列表手动设置为您的
  极狐GitLab 实例地址，例如 `https://jihulab.com` 或 `https://gitlab.example.com`。
  - 该地址必须使用 `https://` 协议。
  - 该地址不得以斜杠结尾。
- **提供商属性映射**：创建以下映射，其中 `attribute.X` 是要作为声明包含在 Google 令牌中的属性名称，`assertion.X`
  是要从 [极狐GitLab 声明](../_index.md#id-token-authentication-for-cloud-services)中提取的值：

  | 属性（Google 侧） | 声明（来自极狐GitLab） |
  | --- | --- |
  | `google.subject` | `assertion.sub` |
  | `attribute.X` | `assertion.X` |

  您还可以使用 Common Expression Language (CEL) [构建复杂属性](https://cloud.google.com/iam/docs/workload-identity-federation#mapping)。

  您必须映射要用于授予权限的每个属性。例如，如果您想在下一步中根据用户的电子邮件地址映射权限，则必须将 `attribute.user_email` 映射到 `assertion.user_email`。

> [!warning]
> 对于托管在 JihuLab.com 上的项目，GCP 要求您
> [仅限访问由您的极狐GitLab 群组签发的令牌](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#gitlab-saas_2)。

<a id="grant-permissions-for-service-account-impersonation"></a>

## 授予服务账号模拟权限

创建工作负载身份池和工作负载身份提供商定义了向 Google Cloud 的身份验证。
此时，您可以从极狐GitLab CI/CD 作业向 Google Cloud 进行身份验证。
但是，您在 Google Cloud 上没有任何权限（授权）。

要授予您的极狐GitLab CI/CD 作业在 Google Cloud 上的权限，您必须：

1. [创建 Google Cloud 服务账号](https://docs.cloud.google.com/iam/docs/service-accounts-create)。
   您可以使用任意喜欢的名称和 ID。
1. 在 Google Cloud 资源上为您的服务账号[授予 IAM 权限](https://docs.cloud.google.com/iam/docs/granting-changing-revoking-access)。这些权限因您的使用场景而异。
   通常，为该服务账号授予您希望极狐GitLab CI/CD 作业使用的 Google Cloud
   项目和资源上的权限。例如，如果您需要在极狐GitLab CI/CD 作业中将文件上传到 Google Cloud Storage 存储桶，则应为该服务账号授予 Cloud Storage 存储桶上的 `roles/storage.objectCreator` 角色。
1. [授予外部身份权限](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#impersonate)
   以模拟该服务账号。此步骤使极狐GitLab CI/CD 作业能够通过服务账号模拟向 Google Cloud 授权。
   此步骤在服务账号本身上授予 IAM 权限，赋予外部身份以该服务账号身份行事的权限。
   外部身份使用 `principalSet://` 协议表示。

与上一步类似，此步骤在很大程度上取决于您期望的配置。例如，如果极狐GitLab CI/CD 作业由用户名为 `chris`的极狐GitLab 用户发起，要允许该作业模拟名为 `my-service-account`的服务账号，则应为 `my-service-account` 上的外部身份授予 `roles/iam.workloadIdentityUser` IAM 角色。外部身份的格式为：

```plaintext
principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.user_login/chris
```

其中 `PROJECT_NUMBER` 是您的 Google Cloud 项目编号，`POOL_ID` 是
第一节中创建的工作负载身份池的 ID（不是名称）。

此配置还假设您已将 `user_login` 添加为上一节中从声明映射的属性。

<a id="retrieve-a-temporary-credential"></a>

## 获取临时凭证

配置 OIDC 和角色后，极狐GitLab CI/CD 作业可以从
[Google Cloud Security Token Service (STS)](https://docs.cloud.google.com/iam/docs/reference/sts/rest) 获取临时凭证。

将 `id_tokens` 添加到您的 CI/CD 作业：

```yaml
job:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.example.com
```

使用 ID 令牌获取临时凭证：

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
- `PROVIDER_ID` 是第二节中创建的工作负载身份提供商的 ID。
- `GITLAB_OIDC_TOKEN` 是 OIDC [ID 令牌](../../secrets/id_token_authentication.md)。

然后，您可以使用生成的联合令牌来模拟上一节中创建的服务账号：

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

- `SERVICE_ACCOUNT_EMAIL` 是要模拟的服务账号的完整电子邮件地址，
  该账号在上一节中创建。
- `FEDERATED_TOKEN` 是从上一步获取的联合令牌。

结果是 Google Cloud OAuth 2.0 访问令牌，当用作持有者令牌时，您可以使用它向大多数 Google Cloud API 和服务进行身份验证。您还可以通过设置环境变量 `CLOUDSDK_AUTH_ACCESS_TOKEN` 将此值传递给 `gcloud` CLI。

<a id="working-example"></a>

## 工作示例

请查看此[参考项目](https://gitlab.com/guided-explorations/gcp/configure-openid-connect-in-gcp)，了解如何使用 Terraform 在 GCP 中预配 OIDC，以及用于获取临时凭证的示例脚本。

<a id="troubleshooting"></a>

## 故障排除

- 调试 `curl` 响应时，请安装最新版本的 curl。使用 `--fail-with-body`
  而不是 `-f`。此命令会打印整个响应体，其中可能包含有用的错误消息。

- 有关更多信息，请参阅[对工作负载身份联合进行故障排除](https://docs.cloud.google.com/iam/docs/troubleshooting-workload-identity-federation)。
