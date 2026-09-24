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
> `CI_JOB_JWT_V2` 在极狐GitLab 15.9 中[已弃用](../../../update/deprecations.md#old-versions-of-json-web-tokens-are-deprecated)，并计划在极狐GitLab 17.0 中移除。请改用 [ID 令牌](../../secrets/id_token_authentication.md)。

本教程展示如何使用极狐GitLab CI/CD 作业和 JSON Web Token (JWT) 从 AWS 获取临时凭证，而无需存储密钥。为此，您必须在极狐GitLab 和 AWS 之间配置 OpenID Connect (OIDC) 进行 ID 联合。有关使用 OIDC 集成极狐GitLab 的背景和要求，请参阅[连接到云服务](../_index.md)。

要完成本教程：

1. [添加身份提供商](#add-the-identity-provider)
1. [配置角色和信任](#configure-a-role-and-trust)
1. [获取临时凭证](#retrieve-temporary-credentials)

<a id="add-the-identity-provider"></a>

## 添加身份提供商

按照这些[说明](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)在 AWS 中将极狐GitLab 创建为 IAM OIDC 提供商。

包括以下信息：

- **提供商 URL**：您的极狐GitLab 实例的地址，例如 `https://gitlab.com` 或 `http://gitlab.example.com`。此地址必须可公开访问。如果不可公开访问，请参阅如何[配置非公开极狐GitLab 实例](#configure-a-non-public-gitlab-instance)。
- **受众**：您打算使用所请求安全令牌的目标服务的逻辑名称。
  - 在 AWS OIDC 集成中，这通常与您在 IAM OIDC 身份提供商中配置的受众值匹配（通常是 `sts.amazonaws.com` 或您的极狐GitLab 实例 URL）。
  - 此值由 AWS 验证，以确保令牌是为您的特定身份提供商准备的。

  > [!note]
  > 如果 AWS 身份提供商引用与之匹配，使用 `https://gitlab.com` 或您的极狐GitLab 实例 URL 可能有效，但这在语义上具有误导性。
  > 受众应代表验证和接受令牌的服务。

<a id="configure-a-role-and-trust"></a>

## 配置角色和信任

创建身份提供商后，配置一个 [Web 身份角色](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)，并设置条件以限制对极狐GitLab 资源的访问。临时凭证使用 [AWS Security Token Service](https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html) 获取，因此将 `Action` 设置为 [`sts:AssumeRoleWithWebIdentity`](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)。

您可以为角色创建[自定义信任策略](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-custom.html)，以将授权限制到特定的群组、项目、分支或标签。有关支持的过滤类型完整列表，请参阅[连接到云服务](../_index.md#configure-a-conditional-role-with-oidc-claims)。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::AWS_ACCOUNT:oidc-provider/gitlab.example.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.example.com:sub": "project_path:mygroup/myproject:ref_type:branch:ref:main"
        }
      }
    }
  ]
}
```

角色创建后，附加一个定义对 AWS 服务（S3、EC2、Secrets Manager）权限的策略。

<a id="retrieve-temporary-credentials"></a>

## 获取临时凭证

配置 OIDC 和角色后，极狐GitLab CI/CD 作业可以从 [AWS Security Token Service (STS)](https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html) 获取临时凭证。

```yaml
assume role:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.example.com
  script:
    # 这样做是为了正确处理退出代码
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

- 请参阅此[参考项目](https://jihulab.com/guided-explorations/aws/configure-openid-connect-in-aws)，了解如何使用 Terraform 在 AWS 中配置 OIDC 以及用于获取临时凭证的示例脚本。
- [OIDC 和极狐GitLab 与 ECS 的多账户部署](https://jihulab.com/guided-explorations/aws/oidc-and-multi-account-deployment-with-ecs)。
- AWS 合作伙伴 (APN) 博客：[使用极狐GitLab CI/CD 设置 OpenID Connect](https://aws.amazon.com/blogs/apn/setting-up-openid-connect-with-gitlab-ci-cd-to-provide-secure-access-to-environments-in-aws-accounts/)。

<a id="configure-a-non-public-gitlab-instance"></a>

## 配置非公开极狐GitLab 实例

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.1 中引入。

{{< /history >}}

> [!warning]
> 此变通方法是一种高级配置选项，需要了解安全注意事项。
> 您必须小心地将 OpenID 配置和公钥从您的私有化部署极狐GitLab 实例正确同步到可公开访问的位置（例如 S3 存储桶）。
> 您还必须确保 S3 存储桶及其内部文件得到适当保护。
> 未能正确保护 S3 存储桶可能导致与此 OpenID Connect 身份关联的任何云账户被接管。

如果您的极狐GitLab 实例不可公开访问，默认情况下无法在 AWS 中配置 OpenID Connect。您可以使用一种变通方法，使某些特定配置可公开访问，从而为实例启用 OpenID Connect 配置：

1. 将极狐GitLab 实例的身份验证详细信息存储在可公开访问的位置，例如 S3 文件中：

   - 将实例的 OpenID 配置托管在 S3 文件中。该配置位于 `/.well-known/openid-configuration`，例如 `http://gitlab.example.com/.well-known/openid-configuration`。更新配置文件中的 `issuer:` 和 `jwks_uri:` 值，使其指向可公开访问的位置。
   - 将实例 URL 的公钥托管在 S3 文件中。密钥位于 `/oauth/discovery/keys`，例如 `http://gitlab.example.com/oauth/discovery/keys`。

   例如：

   - OpenID 配置文件：`https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com/.well-known/openid-configuration`。
   - JWKS（JSON Web 密钥集）：`https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com/oauth/discovery/keys`。
   - ID 令牌中的颁发者声明 `iss:` 和 OpenID 配置中的 `issuer:` 值将为：`https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com`

1. 可选。使用 OpenID 配置验证器，例如 [OpenID Configuration Endpoint Validator](https://www.oauth2.dev/tools/openid-configuration-validator)，来验证您的可公开访问的 OpenID 配置。
1. 为您的 ID 令牌配置自定义颁发者声明。默认情况下，极狐GitLab ID 令牌的颁发者声明 `iss:` 设置为您极狐GitLab 实例的地址，例如：`http://gitlab.example.com`。
1. 更新颁发者 URL：

   {{< tabs >}}

   {{< tab title="Linux 安装包 (Omnibus)" >}}

   1. 编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      gitlab_rails['ci_id_tokens_issuer_url'] = '<public_url_with_openid_configuration_and_keys>'
      ```

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com` 的 URL。

   1. 保存文件并[重新配置极狐GitLab](../../../administration/restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

   {{< /tab >}}

   {{< tab title="Helm Chart (Kubernetes)" >}}

   1. 导出 Helm 值：

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

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com` 的 URL。

   1. 保存文件并应用新值：

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

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com` 的 URL。

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

      将 `<public_url_with_openid_configuration_and_keys>` 替换为类似 `https://example-oidc-configuration-s3-bucket.s3.eu-north-1.amazonaws.com` 的 URL。

   1. 保存文件并[重新配置极狐GitLab](../../../administration/restart_gitlab.md#self-compiled-installations) 以使更改生效。

   {{< /tab >}}

   {{< /tabs >}}

1. 运行 [`ci:validate_id_token_configuration` Rake 任务](../../../administration/raketasks/tokens/_index.md#validate-custom-issuer-url-configuration-for-cicd-id-tokens) 以验证 CI/CD ID 令牌配置。

<a id="troubleshooting"></a>

## 故障排除

### 错误：`Not authorized to perform sts:AssumeRoleWithWebIdentity`

如果您看到此错误：

```plaintext
调用 AssumeRoleWithWebIdentity 操作时发生错误 (AccessDenied)：无权执行 sts:AssumeRoleWithWebIdentity
```

可能的原因有多种：

- 云管理员尚未配置项目以使用 OIDC 与极狐GitLab。
- 角色被限制在分支或标签上运行。请参阅[配置条件角色](../_index.md)。
- 在使用通配符条件时使用了 `StringEquals` 而不是 `StringLike`。请参阅[相关议题](https://jihulab.com/guided-explorations/aws/configure-openid-connect-in-aws/-/issues/2#note_852901934)。

### `Could not connect to openid configuration of provider` 错误

在 AWS IAM 中添加身份提供商后，您可能会收到以下错误：

```plaintext
您的请求有问题。请查看以下详细信息。
  - 无法连接到提供商的 openid 配置：`https://gitlab.example.com`
```

当 OIDC 身份提供商的颁发者提供的证书链顺序错误，或包含重复或额外的证书时，会发生此错误。

验证您的极狐GitLab 实例的证书链。该链必须以域名或颁发者 URL 开头，然后是中间证书，最后是根证书。使用以下命令检查证书链，将 `gitlab.example.com` 替换为您的极狐GitLab 主机名：

```shell
echo | /opt/gitlab/embedded/bin/openssl s_client -connect gitlab.example.com:443
```

### `Couldn't retrieve verification key from your identity provider` 错误

您可能会收到类似以下的错误：

- `调用 AssumeRoleWithWebIdentity 操作时发生错误 (InvalidIdentityToken)：无法从您的身份提供商检索验证密钥，请参考 AssumeRoleWithWebIdentity 文档了解要求`

此错误可能是因为：

- 身份提供商 (IdP) 的 `.well_known` URL 和 `jwks_uri` 无法从公共互联网访问。
- 自定义防火墙阻止了请求。
- 从 IdP 到 AWS STS 端点的 API 请求延迟超过 5 秒。
- STS 对您的 `.well_known` URL 或 IdP 的 `jwks_uri` 发出了过多请求。

如 [AWS 知识中心针对此错误的文章](https://repost.aws/knowledge-center/iam-sts-invalididentitytoken) 中所述，您的极狐GitLab 实例需要可公开访问，以便可以解析 `.well_known` URL 和 `jwks_uri`。如果无法做到这一点，例如您的极狐GitLab 实例处于离线环境中，请参阅如何[配置非公开极狐GitLab 实例](#configure-a-non-public-gitlab-instance)。