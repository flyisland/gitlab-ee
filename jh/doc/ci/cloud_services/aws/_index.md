---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 AWS 中配置 OpenID Connect 以获取临时凭证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> `CI_JOB_JWT_V2` 已在 [极狐GitLab 17.0 中移除](../../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)。
> 请改用 [ID 令牌](../../secrets/id_token_authentication.md)。

本教程介绍如何使用带有 JSON Web 令牌（JWT）的极狐GitLab CI/CD 作业，从 AWS 获取临时凭证，而无需存储密钥。为此，您必须为极狐GitLab 与 AWS 之间的 ID 联合配置 OpenID Connect（OIDC）。有关使用 OIDC 集成极狐GitLab 的背景信息和要求，请参阅[连接到云服务](../_index.md)。

要完成本教程：

1. [添加身份提供商](#add-the-identity-provider)
1. [配置角色和信任](#configure-a-role-and-trust)
1. [获取临时凭证](#retrieve-temporary-credentials)

<a id="add-the-identity-provider"></a>

## 添加身份提供商

按照这些[说明](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)，在 AWS 中将极狐GitLab 创建为 IAM OIDC 提供商。

请包含以下信息：

- **提供商 URL**：您的极狐GitLab 实例地址，例如 `https://jihulab.com` 或 `http://gitlab.example.com`。
  该地址必须可公开访问。如果无法公开访问，请参阅如何
  [配置非公开的极狐GitLab 实例](#configure-a-non-public-gitlab-instance)
- **受众**：您打算将所请求的安全令牌用于的目标服务的逻辑名称。
  - 在 AWS OIDC 集成中，这通常与您在 IAM OIDC 身份提供商中配置的受众值一致（通常是 `sts.amazonaws.com` 或您的极狐GitLab 实例 URL）。
  - AWS 会验证该值，以确保该令牌是用于您的特定身份提供商的。

  > [!note]
  > 如果 AWS 身份提供商的引用与之匹配，使用 `https://jihulab.com` 或您的极狐GitLab 实例 URL 可能可行，但这在语义上具有误导性。
  > 受众应表示验证并接受该令牌的服务。

<a id="configure-a-role-and-trust"></a>

## 配置角色和信任

创建身份提供商后，配置一个 [Web 身份角色](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)，并设置用于限制对极狐GitLab 资源访问的条件。临时凭证通过 [AWS Security Token Service](https://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html) 获取，因此请将 `Action` 设置为 [`sts:AssumeRoleWithWebIdentity`](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)。

您可以为该角色创建[自定义信任策略](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-custom.html)，以将授权限制到特定的群组、项目、分支或标签。有关支持的筛选类型的完整列表，请参阅[连接到云服务](../_index.md#configure-a-conditional-role-with-oidc-claims)。

在 JihuLab.com 上，AWS 支持为 `jihulab.com` OIDC 身份提供商使用[其他条件键](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-wif)，包括 `namespace_id` 和 `project_id`。请在角色信任策略中针对这些稳定且唯一的标识符设置条件。由于这些标识符与路径无关，引用它们的信任策略不会受到路径变更（例如群组或项目重命名）的影响。

这些其他条件键仅适用于 `jihulab.com` OIDC 身份提供商。对于极狐GitLab 私有化部署，仅支持将 `sub` 和 `aud` 声明用作 AWS 条件键。对于这些部署，请使用 `sub`（例如 `gitlab.example.com:sub`）来限定信任策略的范围，并可选择与 `aud` 结合使用。

AWS 支持将以下声明用作条件键：

| 声明                | JihuLab.com    | 极狐GitLab 私有化部署 |
|----------------------|---------------|------------------------------------------|
| `sub`                | {{< yes >}}   | {{< yes >}}                              |
| `aud`                | {{< yes >}}   | {{< yes >}}                              |
| `namespace_id`       | {{< yes >}}   | {{< no >}}                               |
| `project_id`         | {{< yes >}}   | {{< no >}}                               |
| `user_id`            | {{< yes >}}   | {{< no >}}                               |
| `user_login`         | {{< yes >}}   | {{< no >}}                               |
| `user_email`         | {{< yes >}}   | {{< no >}}                               |
| `user_access_level`  | {{< yes >}}   | {{< no >}}                               |
| `ref_protected`      | {{< yes >}}   | {{< no >}}                               |
| `pipeline_source`    | {{< yes >}}   | {{< no >}}                               |
| `runner_environment` | {{< yes >}}   | {{< no >}}                               |
| 所有其他声明     | {{< no >}}    | {{< no >}}                               |

`project_id` 是全局唯一的，并且在项目的整个生命周期内保持不变，包括跨群组重命名、项目重命名和项目转移。只要项目仍位于其当前命名空间中，`namespace_id` 就是稳定的。如果项目被转移到其他命名空间，`namespace_id` 会发生变化，这会故意使固定到它的信任策略失效。

要查找项目的 `namespace_id` 和 `project_id` 值，请参阅项目的设置页面或 [Projects API](../../../api/projects.md)。有关可用作条件键的声明的完整列表，请参阅 [ID 令牌负载](../../secrets/id_token_authentication.md#token-payload)。

以下示例信任策略使用 `sub` 以及 `namespace_id` 和 `project_id`，将信任固定到 JihuLab.com 上的特定群组、项目和分支：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::AWS_ACCOUNT:oidc-provider/jihulab.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "jihulab.com:sub": "project_path:mygroup/myproject:ref_type:branch:ref:main",
          "jihulab.com:namespace_id": "12345",
          "jihulab.com:project_id": "67890"
        }
      }
    }
  ]
}
```

创建角色后，附加一个定义 AWS 服务（S3, EC2, Secrets Manager）权限的策略。

<a id="retrieve-temporary-credentials"></a>

## 获取临时凭证

配置 OIDC 和角色后，极狐GitLab CI/CD 作业可以从 [AWS Security Token Service (STS)](https://docs.aws.amazon.com/STS/latest/APIReference/Welcome.html) 获取临时凭证。

```yaml
assume role:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.example.com
  script:
    # this is split out for correct exit code handling
    - >
      aws_sts_output=$(aws sts assume-role-with-web-identity
      --role-arn ${ROLE_ARN}
      --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token ${GITLAB_OIDC_TOKEN}
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text)
    - export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" $aws_sts_output)
    - aws sts get-caller-identity
```

- `ROLE_ARN`：在此[步骤](#configure-a-role-and-trust)中定义的角色 ARN。
- `GITLAB_OIDC_TOKEN`：一个 OIDC [ID 令牌](../../secrets/id_token_authentication.md)。

<a id="working-examples"></a>

## 工作示例

- 请参阅此[参考项目](https://gitlab.com/guided-explorations/aws/configure-openid-connect-in-aws)，了解如何使用 Terraform 在 AWS 中预配 OIDC，以及用于获取临时凭证的示例脚本。
- [使用极狐GitLab 和 ECS 进行 OIDC 和多账户部署](https://gitlab.com/guided-explorations/aws/oidc-and-multi-account-deployment-with-ecs)。
- AWS 合作伙伴（APN）博客：[使用极狐GitLab CI/CD 设置 OpenID Connect](https://aws.amazon.com/blogs/apn/setting-up-openid-connect-with-gitlab-ci-cd-to-provide-secure-access-to-environments-in-aws-accounts/)。

<a id="configure-a-non-public-gitlab-instance"></a>

## 配置非公开的极狐GitLab 实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 此变通方法是一种高级配置选项，需要了解相关的安全注意事项。
> 您必须谨慎地将 OpenID 配置和公钥从您的私有
> 极狐GitLab 私有化部署实例正确同步到可公开访问的位置，例如 S3 存储桶。
> 您还必须确保 S3 存储桶及其中的文件得到妥善保护。
> 未能妥善保护 S3 存储桶可能导致与此 OpenID Connect 身份关联的任何云账户被接管。

如果您的极狐GitLab 实例无法公开访问，则默认无法在 AWS 中配置 OpenID Connect。您可以使用变通方法将某些特定配置设为可公开访问，从而为该实例启用 OpenID Connect 配置：

1. 将极狐GitLab 实例的认证详细信息存储在可公开访问的位置，
   例如 S3 文件中：

   - 将实例的 OpenID 配置托管在 S3 文件中。该配置位于
     `/.well-known/openid-configuration`，例如 `http://gitlab.example.com/.well-known/openid-configuration`。
     更新配置文件中的 `issuer:` 和 `jwks_uri:` 值，使其指向可公开访问的位置。
   - 将实例 URL 的公钥托管在 S3 文件中。这些密钥位于
     `/oauth/discovery/keys`，例如 `http://gitlab.example.com/oauth/discovery/keys`。

   例如：

   - OpenID 配置文件：`https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com/.well-known/openid-configuration`。
   - JWKS（JSON Web Key Sets）：`https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com/oauth/discovery/keys`。
   - ID 令牌中的颁发者声明 `iss:` 以及 OpenID 配置中的 `issuer:` 值将为：
     `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com`

1. 可选。使用 OpenID 配置验证器（例如 [OpenID Configuration Endpoint Validator](https://www.oauth2.dev/tools/openid-configuration-validator)）
   来验证您可公开访问的 OpenID 配置。
1. 为您的 ID 令牌配置自定义颁发者声明。默认情况下，极狐GitLab ID 令牌
   的颁发者声明 `iss:` 设置为您的极狐GitLab 实例地址，例如：`http://gitlab.example.com`。

1. 更新颁发者 URL：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   1. 编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      gitlab_rails['ci_id_tokens_issuer_url'] = '<public_url_with_openid_configuration_and_keys>'
      ```

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com`的 URL。

   1. 保存文件并[重新配置极狐GitLab](../../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

   1. 导出 Helm values：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1. 编辑 `gitlab_values.yaml`：

      ```yaml
      global:
        appConfig:
          ciIdTokens:
            issuerUrl: '<public_url_with_openid_configuration_and_keys>'
      ```

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com`的 URL。

   1. 保存文件并应用新的 values：

      ```shell
      helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
      ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   1. 编辑 `docker-compose.yml`：

      ```yaml
      version: "3.6"
      services:
        gitlab:
          environment:
            GITLAB_OMNIBUS_CONFIG: |
              gitlab_rails['ci_id_tokens_issuer_url'] = '<public_url_with_openid_configuration_and_keys>'
      ```

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com`的 URL。

   1. 保存文件并重启极狐GitLab：

      ```shell
      docker compose up -d
      ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

      ```yaml
       production: &base
         ci_id_tokens:
           issuer_url: '<public_url_with_openid_configuration_and_keys>'
      ```

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com`的 URL。

   1. 保存文件并[重新配置极狐GitLab](../../../administration/restart_gitlab.md#self-compiled-installations)
      以使更改生效。

   {{< /tab >}}

   {{< /tabs >}}

1. 运行 [`ci:validate_id_token_configuration` Rake 任务](../../../administration/raketasks/tokens/_index.md#validate-custom-issuer-url-configuration-for-cicd-id-tokens)
   以验证 CI/CD ID 令牌配置。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-not-authorized-to-perform-stsassumerolewithwebidentity"></a>

### 错误：`Not authorized to perform sts:AssumeRoleWithWebIdentity`

如果您看到此错误：

```plaintext
An error occurred (AccessDenied) when calling the AssumeRoleWithWebIdentity operation:
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

它可能由多种原因引起：

- 云管理员尚未将项目配置为使用 OIDC 与极狐GitLab 集成。
- 该角色被限制为不能在分支或标签上运行。请参阅[配置条件角色](../_index.md)。
- 在使用通配符条件时，使用了 `StringEquals` 而不是 `StringLike`。请参阅[相关议题](https://gitlab.com/guided-explorations/aws/configure-openid-connect-in-aws/-/issues/2#note_852901934)。

<a id="could-not-connect-to-openid-configuration-of-provider-error"></a>

### `Could not connect to openid configuration of provider` 错误

在 AWS IAM 中添加身份提供商后，您可能会收到以下错误：

```plaintext
Your request has a problem. Please see the following details.
  - Could not connect to openid configuration of provider: `https://gitlab.example.com`
```

当 OIDC 身份提供商的颁发者提供的证书链顺序错误，或者包含重复或额外的证书时，会发生此错误。

验证您的极狐GitLab 实例的证书链。该链必须以域名或颁发者 URL 开头，然后是中间证书，最后以根证书结尾。使用此命令查看证书链，将 `gitlab.example.com` 替换为您的极狐GitLab 主机名：

```shell
echo | /opt/gitlab/embedded/bin/openssl s_client -connect gitlab.example.com:443
```

<a id="couldnt-retrieve-verification-key-from-your-identity-provider-error"></a>

### `Couldn't retrieve verification key from your identity provider` 错误

您可能会收到类似以下的错误：

- `An error occurred (InvalidIdentityToken) when calling the AssumeRoleWithWebIdentity operation: Couldn't retrieve verification key from your identity provider, please reference AssumeRoleWithWebIdentity documentation for requirements`

此错误可能是因为：

- 身份提供商（IdP）的 `.well_known` URL 和 `jwks_uri` 无法从公共互联网访问。
- 自定义防火墙正在阻止这些请求。
- 从 IdP 到 AWS STS 端点的 API 请求延迟超过 5 秒。
- STS 对您的 `.well_known` URL 或 IdP 的 `jwks_uri` 发出的请求过多。

如[针对此错误的 AWS Knowledge Center 文章](https://repost.aws/knowledge-center/iam-sts-invalididentitytoken)所述，
您的极狐GitLab 实例需要可公开访问，以便能够解析 `.well_known` URL 和 `jwks_uri`。如果无法做到这一点，例如您的极狐GitLab 实例位于离线环境中，请参阅如何[配置非公开的极狐GitLab 实例](#configure-a-non-public-gitlab-instance)
