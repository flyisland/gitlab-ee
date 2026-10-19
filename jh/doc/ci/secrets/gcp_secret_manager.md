---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何在极狐GitLab CI/CD 流水线中使用 GCP 密钥管理器中的密钥
title: 在极狐GitLab CI/CD 中使用 GCP 密钥管理器中的密钥
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab CI/CD 流水线中使用存储在 [Google Cloud (GCP) 密钥管理器](https://cloud.google.com/security/products/secret-manager)中的密钥。

将极狐GitLab 与 GCP 密钥管理器配合使用的流程如下：

1. 极狐GitLab 向 CI/CD 作业签发 ID 令牌。
1. Runner 使用该 ID 令牌向 GCP 进行身份验证。
1. GCP 向极狐GitLab 验证该 ID 令牌。
1. GCP 签发一个短期访问令牌。
1. Runner 使用该访问令牌访问密钥数据。
1. GCP 根据访问令牌的主体检查 IAM 密钥权限。
1. GCP 将密钥数据返回给 Runner。

要将极狐GitLab 与 GCP 密钥管理器配合使用，您必须：

- 已在 [GCP 密钥管理器](https://cloud.google.com/security/products/secret-manager)中存储密钥。
- 配置 [GCP 工作负载身份联合](#configure-gcp-iam-workload-identity-federation-wif)，将极狐GitLab 纳入为身份提供商。
- 配置 [GCP IAM](#grant-access-to-gcp-iam-principal) 权限，以授予对 GCP 密钥管理器的访问权限。
- 配置[使用 GCP 密钥管理器的极狐GitLab CI/CD](#configure-gitlab-cicd-to-use-gcp-secret-manager-secrets)。

<a id="configure-gcp-iam-workload-identity-federation-wif"></a>

## 配置 GCP IAM 工作负载身份联合 (WIF)

必须配置 GCP IAM WIF，使其能够识别极狐GitLab 签发的 ID 令牌，并为其分配适当的主体。
该主体用于授权访问密钥管理器资源：

1. 在 GCP Console 中，转到**IAM 和管理** > **工作负载身份联合**。
1. 选择**创建池**，并使用唯一名称创建新的身份池，例如 `gitlab-pool`。
1. 选择**添加提供程序**，向该身份池添加一个具有唯一名称的新 OIDC 提供程序，例如 `gitlab-provider`。
   1. 将**颁发者 (URL)**设置为极狐GitLab URL，例如 `https://jihulab.com`。
   1. 选择**默认受众**，或选择**允许的受众**以使用自定义受众，该受众用于极狐GitLab CI/CD ID 令牌中的 `aud`。
1. 在**属性映射**下，创建以下映射，其中：

   - `attribute.X` 是要作为声明包含在 Google 令牌中的属性名称。
   - `assertion.X` 是要从[极狐GitLab 声明](../cloud_services/_index.md#id-token-authentication-for-cloud-services)中提取的值。

   | 属性（在 Google 上）         | 声明（来自极狐GitLab） |
   |-------------------------------|-------------------------|
   | `google.subject`              | `assertion.sub`         |
   | `attribute.gitlab_project_id` | `assertion.project_id`  |

<a id="grant-access-to-gcp-iam-principal"></a>

## 向 GCP IAM 主体授予访问权限

设置 WIF 后，您必须向 WIF 主体授予对密钥管理器中密钥的访问权限。

1. 在 GCP Console 中，转到 **安全** > **密钥管理器**。
1. 选择您希望授予访问权限的密钥名称，以查看该密钥的详细信息。
1. 在 **权限** 标签页中，选择 **授予访问权限**，向通过 WIF 提供程序创建的主体集授予访问权限。
   外部身份格式为：

   ```plaintext
   principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.gitlab_project_id/GITLAB_PROJECT_ID
   ```

   在此示例中：

   - `PROJECT_NUMBER`：您的 Google Cloud 项目编号（不是 ID），可在
     [项目仪表板](https://console.cloud.google.com/home/dashboard)中找到。
   - `POOL_ID`：第一节中创建的工作负载身份池的 ID（不是名称），
     例如 `gitlab-pool`。
   - `GITLAB_PROJECT_ID`：在[项目概览页面](../../user/project/working_with_projects.md#find-the-project-id)中找到的极狐GitLab 项目 ID。

1. 分配 **Secret Manager Secret Accessor** 角色。

<a id="configure-gitlab-cicd-to-use-gcp-secret-manager-secrets"></a>

## 配置极狐GitLab CI/CD 以使用 GCP 密钥管理器密钥

您必须[添加以下 CI/CD 变量](../variables/_index.md#for-a-project)，以提供有关
您的 GCP 密钥管理器的详细信息：

- `GCP_PROJECT_NUMBER`：GCP [项目编号](https://docs.cloud.google.com/resource-manager/docs/creating-managing-projects)。
- `GCP_WORKLOAD_IDENTITY_FEDERATION_POOL_ID`：WIF 池 ID，例如 `gitlab-pool`。
- `GCP_WORKLOAD_IDENTITY_FEDERATION_PROVIDER_ID`：WIF 提供程序 ID，例如 `gitlab-provider`。

然后，您可以通过使用 `gcp_secret_manager` 关键字定义密钥，在 CI/CD 作业中使用存储在 GCP 密钥管理器中的密钥：

```yaml
job_using_gcp_sm:
  id_tokens:
    GCP_ID_TOKEN:
      # `aud` must match the audience defined in the WIF Identity Pool.
      aud: https://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${GCP_WORKLOAD_IDENTITY_FEDERATION_POOL_ID}/providers/${GCP_WORKLOAD_IDENTITY_FEDERATION_PROVIDER_ID}
  secrets:
    DATABASE_PASSWORD:
      gcp_secret_manager:
        name: my-project-secret  # This is the name of the secret defined in GCP Secret Manager
        version: 1               # optional: default to `latest`.
      token: $GCP_ID_TOKEN
```

<a id="use-secrets-from-a-different-gcp-project"></a>

### 使用来自其他 GCP 项目的密钥

GCP 中的密钥名称是按项目划分的。默认情况下，`gcp_secret_manager:name`中指定的密钥从 `GCP_PROJECT_NUMBER` 指定的项目中读取。

要从包含 WIF 池的项目之外的其他项目读取密钥，请使用格式为 `projects/<project-number>/secrets/<secret-name>` 的完全限定密钥名称。

例如，如果 `my-project-secret` 位于 GCP 项目编号 `123456789`中，则您可以通过以下方式访问该密钥：

```yaml
job_using_gcp_sm:
  # ... as previously configured ...
  secrets:
    DATABASE_PASSWORD:
      gcp_secret_manager:
        name: projects/123456789/secrets/my-project-secret  # fully-qualified name of the secret defined in GCP Secret Manager
        version: 1                                          # optional: defaults to `latest`.
      token: $GCP_ID_TOKEN
```

<a id="troubleshooting"></a>

## 故障排除

<a id="error-the-size-of-mapped-attribute-googlesubject-exceeds-the-127-bytes-limit"></a>

### 错误：映射属性 `google.subject`的大小超过 127 字节限制

较长的分支路径可能导致作业失败并出现此错误，因为 [`assertion.sub` 属性](id_token_authentication.md#token-payload)的长度超过 127 个字符：

```plaintext
ERROR: Job failed (system failure): resolving secrets: failed to exchange sts token: googleapi: got HTTP response code 400 with body:
{"error":"invalid_request","error_description":"The size of mapped attribute google.subject exceeds the 127 bytes limit.
Either modify your attribute mapping or the incoming assertion to produce a mapped attribute that is less than 127 bytes."}
```

较长的分支路径可能由以下原因导致：

- 深度嵌套的子群组。
- 较长的群组、代码仓库或分支名称。

例如，对于 `gitlab-org/gitlab` 分支，载荷为 `project_path:gitlab-org/gitlab:ref_type:branch:ref:{branch_name}`。要使该字符串保持在 127 个字符以内，分支名称必须不超过 76 个字符。
此限制由 Google Cloud IAM 施加，记录在 [Google 议题 #264362370](https://issuetracker.google.com/issues/264362370?pli=1)中。

此问题的唯一修复方法是[为您的分支和代码仓库](https://github.com/google-github-actions/auth/blob/main/docs/TROUBLESHOOTING.md#subject-exceeds-the-127-byte-limit)使用较短的名称。

<a id="the-secrets-provider-can-not-be-found-check-your-cicd-variables-and-try-again-message"></a>

### `The secrets provider can not be found. Check your CI/CD variables and try again.` 消息

当您尝试启动配置为访问 GCP 密钥管理器的作业时，可能会收到此错误：

```plaintext
The secrets provider can not be found. Check your CI/CD variables and try again.
```

无法创建该作业，因为一个或多个必需变量未定义：

- `GCP_PROJECT_NUMBER`
- `GCP_WORKLOAD_IDENTITY_FEDERATION_POOL_ID`
- `GCP_WORKLOAD_IDENTITY_FEDERATION_PROVIDER_ID`

<a id="warning-not-resolved-no-resolver-that-can-handle-the-secret-warning"></a>

### `WARNING: Not resolved: no resolver that can handle the secret` 警告

当 Runner 版本不支持 Google Cloud 密钥管理器集成时，会出现此警告。
请将您的 Runner 升级到受支持的版本。
