---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to use GCP Secret Manager secrets in GitLab CI/CD pipelines
title: 在极狐GitLab CI/CD 中使用 GCP Secret Manager 密钥
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 和 GitLab Runner 16.8 中引入。

{{< /history >}}

您可以在极狐GitLab CI/CD 流水线中使用存储在 [Google Cloud (GCP) Secret Manager](https://cloud.google.com/security/products/secret-manager) 中的密钥。

将极狐GitLab 与 GCP Secret Manager 一起使用的流程如下：

1. 极狐GitLab 向 CI/CD 作业颁发 ID 令牌。
1. Runner 使用 ID 令牌向 GCP 进行身份验证。
1. GCP 使用极狐GitLab 验证 ID 令牌。
1. GCP 颁发短期访问令牌。
1. Runner 使用访问令牌访问密钥数据。
1. GCP 检查访问令牌主体的 IAM 密钥权限。
1. GCP 将密钥数据返回给 Runner。

要将极狐GitLab 与 GCP Secret Manager 一起使用，您必须：

- 在 [GCP Secret Manager](https://cloud.google.com/security/products/secret-manager) 中存储密钥。
- 配置 [GCP 工作负载身份联合](#configure-gcp-iam-workload-identity-federation-wif) 以将极狐GitLab 作为身份提供程序包含在内。
- 配置 [GCP IAM](#grant-access-to-gcp-iam-principal) 权限以授予对 GCP Secret Manager 的访问权限。
- 配置 [极狐GitLab CI/CD 以使用 GCP Secret Manager 密钥](#configure-gitlab-cicd-to-use-gcp-secret-manager-secrets)。

<a id="configure-gcp-iam-workload-identity-federation-wif"></a>

## 配置 GCP IAM 工作负载身份联合 (WIF)

必须配置 GCP IAM WIF 以识别极狐GitLab 颁发的 ID 令牌，并为其分配适当的主体。
该主体用于授权访问 Secret Manager 资源：

1. 在 GCP 控制台中，转到 **IAM 和管理** > **工作负载身份联合**。
1. 选择 **创建池** 并使用唯一名称创建一个新的身份池，例如 `gitlab-pool`。
1. 选择 **添加提供程序** 以向身份池添加一个新的 OIDC 提供程序，并使用唯一名称，例如 `gitlab-provider`。
   1. 将 **颁发者 (URL)** 设置为极狐GitLab URL，例如 `https://jihulab.com`。
   1. 选择 **默认受众**，或选择 **允许的受众** 以使用自定义受众，该受众用于极狐GitLab CI/CD ID 令牌的 `aud` 字段。
1. 在 **属性映射** 下，创建以下映射，其中：

   - `attribute.X` 是要作为声明包含在 Google 令牌中的属性名称。
   - `assertion.X` 是从 [极狐GitLab 声明](../cloud_services/_index.md#id-token-authentication-for-cloud-services) 中提取的值。

   | 属性 (在 Google 上)         | 断言 (来自极狐GitLab) |
   |-------------------------------|-------------------------|
   | `google.subject`              | `assertion.sub`         |
   | `attribute.gitlab_project_id` | `assertion.project_id`  |

<a id="grant-access-to-gcp-iam-principal"></a>

## 授予 GCP IAM 主体访问权限

设置 WIF 后，您必须授予 WIF 主体对 Secret Manager 中密钥的访问权限。

1. 在 GCP 控制台中，转到 **安全** > **Secret Manager**。
1. 选择您要授予访问权限的密钥名称，以查看密钥的详细信息。
1. 从 **权限** 选项卡中，选择 **授予访问权限** 以授予通过 WIF 提供程序创建的主体集访问权限。
   外部身份格式为：

   ```plaintext
   principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.gitlab_project_id/GITLAB_PROJECT_ID
   ```

   在此示例中：

   - `PROJECT_NUMBER`：您的 Google Cloud 项目编号（不是 ID），可以在 [项目信息中心](https://console.cloud.google.com/home/dashboard) 中找到。
   - `POOL_ID`：在第一部分中创建的工作负载身份池的 ID（不是名称），例如 `gitlab-pool`。
   - `GITLAB_PROJECT_ID`：极狐GitLab 项目 ID，可在 [项目概览页面](../../user/project/working_with_projects.md#find-the-project-id) 上找到。

1. 分配角色 **Secret Manager 密钥访问者**。

<a id="configure-gitlab-cicd-to-use-gcp-secret-manager-secrets"></a>

## 配置极狐GitLab CI/CD 以使用 GCP Secret Manager 密钥

您必须 [添加这些 CI/CD 变量](../variables/_index.md#for-a-project) 以提供有关您的 GCP Secret Manager 的详细信息：

- `GCP_PROJECT_NUMBER`：GCP [项目编号](https://cloud.google.com/resource-manager/docs/creating-managing-projects)。
- `GCP_WORKLOAD_IDENTITY_FEDERATION_POOL_ID`：WIF 池 ID，例如 `gitlab-pool`。
- `GCP_WORKLOAD_IDENTITY_FEDERATION_PROVIDER_ID`：WIF 提供程序 ID，例如 `gitlab-provider`。

然后，您可以通过使用 `gcp_secret_manager` 关键字定义它们，在 CI/CD 作业中使用存储在 GCP Secret Manager 中的密钥：

```yaml
job_using_gcp_sm:
  id_tokens:
    GCP_ID_TOKEN:
      # `aud` 必须与 WIF 身份池中定义的受众匹配。
      aud: https://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${GCP_WORKLOAD_IDENTITY_FEDERATION_POOL_ID}/providers/${GCP_WORKLOAD_IDENTITY_FEDERATION_PROVIDER_ID}
  secrets:
    DATABASE_PASSWORD:
      gcp_secret_manager:
        name: my-project-secret  # 这是在 GCP Secret Manager 中定义的密钥名称。
        version: 1               # 可选：默认为 `latest`。
      token: $GCP_ID_TOKEN
```

<a id="use-secrets-from-a-different-gcp-project"></a>

### 使用不同 GCP 项目中的密钥

{{< history >}}

- 在极狐GitLab 17.0 中引入。

{{< /history >}}

GCP 中的密钥名称是按项目的。默认情况下，`gcp_secret_manager:name` 中命名的密钥是从 `GCP_PROJECT_NUMBER` 指定的项目中读取的。

要从与包含 WIF 池的项目不同的项目中读取密钥，请使用完全限定的密钥名称，格式为 `projects/<project-number>/secrets/<secret-name>`。

例如，如果 `my-project-secret` 位于 GCP 项目编号 `123456789` 中，则可以使用以下方式访问该密钥：

```yaml
job_using_gcp_sm:
  # ... 如前所述配置 ...
  secrets:
    DATABASE_PASSWORD:
      gcp_secret_manager:
        name: projects/123456789/secrets/my-project-secret  # 在 GCP Secret Manager 中定义的密钥的完全限定名称
        version: 1                                          # 可选：默认为 `latest`。
      token: $GCP_ID_TOKEN
```

<a id="troubleshooting"></a>

## 故障排查

<a id="error-the-size-of-mapped-attribute-googlesubject-exceeds-the-127-bytes-limit"></a>

### 错误：映射属性 `google.subject` 的大小超过 127 字节限制

长分支路径可能导致作业因此错误而失败，因为 [`assertion.sub` 属性](id_token_authentication.md#token-payload) 超过 127 个字符：

```plaintext
错误：作业失败（系统故障）：解析密钥：交换 STS 令牌失败：googleapi：收到 HTTP 响应代码 400，正文为：
{"error":"invalid_request","error_description":"映射属性 google.subject 的大小超过 127 字节限制。
请修改属性映射或传入的断言，以生成小于 127 字节的映射属性。"}
```

长分支路径可能由以下原因引起：

- 深度嵌套的子群组。
- 较长的群组、仓库或分支名称。

例如，对于 `gitlab-org/gitlab` 分支，负载为 `project_path:gitlab-org/gitlab:ref_type:branch:ref:{branch_name}`。要使字符串保持少于 127 个字符，分支名称必须为 76 个字符或更少。此限制由 Google Cloud IAM 施加，在 [Google 问题 #264362370](https://issuetracker.google.com/issues/264362370?pli=1) 中跟踪。

此问题的唯一解决方法是使用较短的名称 [为您的分支和仓库](https://github.com/google-github-actions/auth/blob/main/docs/TROUBLESHOOTING.md#subject-exceeds-the-127-byte-limit)。

<a id="the-secrets-provider-can-not-be-found-check-your-cicd-variables-and-try-again-message"></a>

### `找不到密钥提供程序。请检查您的 CI/CD 变量并重试。` 消息

当尝试启动配置为访问 GCP Secret Manager 的作业时，您可能会收到此错误：

```plaintext
找不到密钥提供程序。请检查您的 CI/CD 变量并重试。
```

无法创建作业，因为未定义一个或多个必需变量：

- `GCP_PROJECT_NUMBER`
- `GCP_WORKLOAD_IDENTITY_FEDERATION_POOL_ID`
- `GCP_WORKLOAD_IDENTITY_FEDERATION_PROVIDER_ID`

<a id="warning-not-resolved-no-resolver-that-can-handle-the-secret-warning"></a>

### `警告：未解析：没有可以处理该密钥的解析器` 警告

Google Cloud Secret Manager 集成至少需要极狐GitLab 16.8 和 GitLab Runner 16.8。如果作业由使用低于 16.8 版本的 runner 执行，则会出现此警告。