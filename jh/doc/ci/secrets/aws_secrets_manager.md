---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab CI/CD 中使用 AWS Secrets Manager 密钥
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.2 中[引入] [带有一个功能标志](../../administration/feature_flags/_index.md)，名为 `ci_aws_secrets_manager`。默认禁用。
- 在极狐GitLab 18.3 中[GA]。

{{< /history >}}

您可以在极狐GitLab CI/CD 流水线中使用存储在 [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) 中的密钥。

先决条件：

- 拥有 AWS 账户中访问 AWS Secrets Manager 的权限。
- 使用以下方法之一配置身份认证：
  - **IAM 角色**：使用分配给极狐GitLab Runner 实例的 IAM 角色。
  - **OpenID Connect**：[在 AWS 中配置 OpenID Connect](../cloud_services/aws/_index.md) 以获取临时凭据。
- 添加 [CI/CD 变量到您的项目](../variables/_index.md#for-a-project) 以提供 AWS 配置的详细信息：
  - `AWS_REGION`：存储密钥的 AWS 区域。
  - `AWS_ROLE_ARN`：要代入的 AWS IAM 角色的 ARN（使用 OpenID Connect 时需要）。
  - `AWS_ROLE_SESSION_NAME`：可选。代入角色的自定义会话名称。

<a id="use-aws-secrets-manager-secrets-in-a-cicd-job"></a>

## 在 CI/CD 作业中使用 AWS Secrets Manager 密钥

<a id="with-iam-role-authentication"></a>

### 使用 IAM 角色认证

您可以通过在作业中使用 `aws_secrets_manager` 关键字定义存储在 AWS Secrets Manager 中的密钥来使用它。

此方法使用分配给极狐GitLab Runner 实例的 IAM 角色。当使用 [Kubernetes executor](https://gitlab.cn/docs/runner/executors/kubernetes/) 或 [弹性伸缩](https://gitlab.cn/docs/runner/runner_autoscale/) 时，请确保 IAM 角色应用于您的 runner 管理器。

先决条件：

- 极狐GitLab Runner 18.3 或更高版本。

例如：

```yaml
variables:
  AWS_REGION: us-east-1

database-migration:
  secrets:
    DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: app-secrets/database
        field: 'password'
      file: false
  stage: deploy
  script:
    - echo "正在运行数据库迁移..."
    - mysql -h $DB_HOST -u $DB_USER -p$DATABASE_PASSWORD < migration.sql
    - echo "迁移已成功完成。"
```

<a id="with-openid-connect-authentication"></a>

### 使用 OpenID Connect 认证

为了增强安全性，您可以使用 OpenID Connect 与 AWS 进行身份认证并代入特定的 IAM 角色。默认情况下，runner 会查找名为 `AWS_ID_TOKEN` 的 ID 令牌。例如：

```yaml
variables:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: 'arn:aws:iam::123456789012:role/gitlab-secrets-role'

database-migration:
  id_tokens:
    AWS_ID_TOKEN:
      aud: 'sts.amazonaws.com'
  secrets:
    DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: app-secrets/database
        field: 'password'
      file: false
  stage: deploy
  script:
    - echo "正在连接到生产数据库..."
    - psql postgresql://$DB_USER:$DATABASE_PASSWORD@$DB_HOST:5432/$DB_NAME -c "SELECT version();"
    - echo "数据库连接成功。"
```

您还可以使用 `token` 选项指定自定义令牌。例如：

```yaml
variables:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: 'arn:aws:iam::123456789012:role/gitlab-secrets-role'

database-migration:
  id_tokens:
    CUSTOM_AWS_TOKEN:
      aud: 'sts.amazonaws.com'
  secrets:
    DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: app-secrets/database
        field: 'password'
      token: $CUSTOM_AWS_TOKEN
      file: false
  stage: deploy
  script:
    - echo "正在使用自定义令牌连接到生产数据库..."
    - psql postgresql://$DB_USER:$DATABASE_PASSWORD@$DB_HOST:5432/$DB_NAME -c "SELECT version();"
    - echo "数据库连接成功。"
```

<a id="short-form-syntax"></a>

### 简写语法

您可以通过将密钥 ID 指定为字符串来使用简化的语法。您可以选择使用 `#` 字符分隔来指定字段。例如：

```yaml
variables:
  AWS_REGION: us-east-1

api-deployment:
  secrets:
    API_KEY:
      aws_secrets_manager: 'app-secrets/api#api_key'
      file: false
    FULL_SECRET:
      aws_secrets_manager: 'app-secrets/api'
      file: false
  stage: deploy
  script:
    - echo "正在使用特定字段部署 API..."
    - curl --header "Authorization: Bearer $API_KEY" https://api.example.com/deploy
    - echo "正在使用完整密钥..."
    - curl --header "Authorization: Bearer $(cat $FULL_SECRET | jq --raw-output '.api_key')" https://api.example.com/status
```

<a id="secret-versioning"></a>

## 密钥版本控制

AWS Secrets Manager 支持多个版本的密钥。您可以使用 `version_id` 或 `version_stage` 指定特定版本。例如：

```yaml
variables:
  AWS_REGION: us-east-1

production-deployment:
  secrets:
    DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: prod-app-secrets/database
        field: 'password'
        version_stage: 'AWSCURRENT'
      file: false
    STAGING_DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: prod-app-secrets/database
        field: 'password'
        version_id: '01234567-89ab-cdef-0123-456789abcdef'
      file: false
  stage: deploy
  script:
    - echo "正在使用当前密钥版本部署到生产环境..."
    - deploy-prod.sh --db-password $DATABASE_PASSWORD
    - echo "正在使用特定密钥版本进行测试..."
    - test-with-version.sh --db-password $STAGING_DATABASE_PASSWORD
```

<a id="cross-account-secret-access"></a>

## 跨账户密钥访问

要从另一个 AWS 账户检索密钥，您必须使用完整的 ARN。例如：

```yaml
variables:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: 'arn:aws:iam::123456789012:role/cross-account-secrets-role'

cross-account-deployment:
  id_tokens:
    AWS_ID_TOKEN:
      aud: 'sts.amazonaws.com'
  secrets:
    SHARED_API_KEY:
      aws_secrets_manager:
        secret_id: 'arn:aws:secretsmanager:us-east-1:987654321098:secret:shared-api-keys-AbCdEf'
        field: 'production_key'
      file: false
  stage: deploy
  script:
    - echo "正在从另一个账户访问共享密钥..."
    - curl --header "Authorization: Bearer $SHARED_API_KEY" https://shared-api.example.com/deploy
```

<a id="per-secret-configuration-overrides"></a>

## 每密钥配置覆盖

您可以在每密钥基础上覆盖全局 AWS 设置。例如：

```yaml
variables:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: 'arn:aws:iam::123456789012:role/default-role'

multi-region-deployment:
  id_tokens:
    AWS_ID_TOKEN:
      aud: 'sts.amazonaws.com'
    EU_AWS_TOKEN:
      aud: 'sts.amazonaws.com'
  secrets:
    EU_DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: eu-app-secrets/database
        field: 'password'
        region: 'eu-west-1'
        role_arn: 'arn:aws:iam::123456789012:role/eu-deployment-role'
        role_session_name: 'gitlab-eu-deployment'
      token: $EU_AWS_TOKEN
      file: false
    US_DATABASE_PASSWORD:
      aws_secrets_manager:
        secret_id: us-app-secrets/database
        field: 'password'
      file: false
  stage: deploy
  script:
    - echo "正在部署到 EU 区域..."
    - deploy-to-eu.sh --db-password $EU_DATABASE_PASSWORD
    - echo "正在部署到 US 区域..."
    - deploy-to-us.sh --db-password $US_DATABASE_PASSWORD
```

在这些示例中：

- `aud`：受众，必须与[创建联合身份凭证](../cloud_services/aws/_index.md)时使用的受众匹配。
- `secret_id`：AWS Secrets Manager 中密钥的名称或 ARN。要从另一个账户检索密钥，必须使用 ARN。
- `field`：要在 JSON 密钥中检索的特定键。如果未指定，则检索整个密钥。
  字段访问仅支持扁平 JSON 密钥（仅顶级键），并支持字符串、数字和布尔值。
  例如：
  - `password`：访问 `password` 字段。
  - `api_key`：访问 `api_key` 字段。
  - `token`：指定用于身份认证的 ID 令牌。如果未指定，runner 会查找名为 `AWS_ID_TOKEN` 的令牌。
- `version_id`：特定版本密钥的唯一标识符。
  如果您不指定 `version_id` 或 `version_stage`，AWS Secrets Manager 将返回 `AWSCURRENT` 版本。
- `version_stage`：要检索的密钥版本的暂存标签（例如 `AWSCURRENT` 或 `AWSPENDING`）。
  不能为同一个密钥同时指定 `version_id` 和 `version_stage`。
- `region`：覆盖此特定密钥的全局 `AWS_REGION`。
- `role_arn`：覆盖此特定密钥的全局 `AWS_ROLE_ARN`。
- `role_session_name`：覆盖此特定密钥的全局 `AWS_ROLE_SESSION_NAME`。
- 极狐GitLab 从 AWS Secrets Manager 获取密钥并将值存储在临时文件中。
  该文件的路径存储在 CI/CD 变量中，类似于
  [文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)。

<a id="troubleshooting"></a>

## 故障排查

请参考 [AWS 的 OIDC 故障排查](../cloud_services/aws/_index.md#troubleshooting) 以了解设置 AWS OIDC 时的一般问题。

<a id="error-no-ec2-imds-role-found"></a>

### 错误：`no EC2 IMDS role found`

如果满足以下两个条件，可能会出现此错误：

- CI/CD 作业已配置为[使用 IAM 角色认证](#with-iam-role-authentication)。
- 作业由部署在 AWS EKS 上且具有 [Kubernetes executor](https://gitlab.cn/docs/runner/executors/kubernetes/) 的 runner 执行。

```plaintext
正在解析密钥
正在解析密钥 "MY_AWS_SECRET"...
使用 "aws_secrets_manager" 密钥解析器...
错误：作业失败（系统错误）：解析密钥：操作错误 Secrets Manager：GetSecretValue，获取身份：获取凭据：刷新缓存凭据失败，未找到 EC2 IMDS 角色，操作错误 ec2imds：GetMetadata，已取消，上下文截止时间已超过
```

`解析密钥` 步骤由 runner 管理器处理。此步骤访问 [EC2 IMDS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html) 中缓存的 IAM 凭据。
如果 IAM 角色未应用于 runner 管理器，则 `解析密钥` 步骤会失败。

要解决此错误，请将正确的 IAM 角色应用于 runner 管理器。

将由 runner 管理器生成并管理的 runner pods 应用 IAM 角色无法解决此问题。