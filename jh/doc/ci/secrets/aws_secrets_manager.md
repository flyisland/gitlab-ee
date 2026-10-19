---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab CI/CD 中使用 AWS 密钥管理器中的密钥
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab CI/CD 流水线中使用存储在 [AWS 密钥管理器](https://aws.amazon.com/secrets-manager/)中的密钥。

先决条件：

- 在您的 AWS 账户中拥有对 AWS 密钥管理器的访问权限。
- 使用以下方法之一配置认证：
  - **IAM 角色**：使用分配给您的极狐GitLab Runner 实例的 IAM 角色。
  - **OpenID Connect**：[在 AWS 中配置 OpenID Connect](../cloud_services/aws/_index.md) 以获取临时凭证。
- 向您的项目添加 [CI/CD 变量](../variables/_index.md#for-a-project)，以提供有关您的 AWS 配置的详细信息：
  - `AWS_REGION`：存储密钥的 AWS 区域。
  - `AWS_ROLE_ARN`：要代入的 AWS IAM 角色的 ARN（使用 OpenID Connect 时为必填项）。
  - `AWS_ROLE_SESSION_NAME`：可选。代入角色的自定义会话名称。

<a id="use-aws-secrets-manager-secrets-in-a-cicd-job"></a>

## 在 CI/CD 作业中使用 AWS 密钥管理器中的密钥

<a id="with-iam-role-authentication"></a>

### 使用 IAM 角色认证

您可以通过使用 `aws_secrets_manager` 关键字定义密钥，在作业中使用存储在 AWS 密钥管理器中的密钥。

此方法使用分配给您的极狐GitLab Runner 实例的 IAM 角色。使用
[Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)或[自动扩缩](https://gitlab.cn/docs/runner/runner_autoscale/)时，
请确保将 IAM 角色应用于您的 runner manager。

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
    - echo "Running database migration..."
    - mysql -h $DB_HOST -u $DB_USER -p$DATABASE_PASSWORD < migration.sql
    - echo "Migration completed successfully."
```

<a id="with-openid-connect-authentication"></a>

### 使用 OpenID Connect 认证

为了增强安全性，您可以使用 OpenID Connect 向 AWS 进行认证并代入特定的 IAM 角色。默认情况下，runner 会查找名为 `AWS_ID_TOKEN`的 ID 令牌。例如：

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
    - echo "Connecting to production database..."
    - psql postgresql://$DB_USER:$DATABASE_PASSWORD@$DB_HOST:5432/$DB_NAME -c "SELECT version();"
    - echo "Database connection successful."
```

您也可以使用 `token` 选项指定自定义令牌。例如：

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
    - echo "Connecting to production database with custom token..."
    - psql postgresql://$DB_USER:$DATABASE_PASSWORD@$DB_HOST:5432/$DB_NAME -c "SELECT version();"
    - echo "Database connection successful."
```

<a id="short-form-syntax"></a>

### 简写语法

您可以通过将密钥 ID 指定为字符串来使用简化语法。您可以选择使用 `#` 字符分隔来指定字段。例如：

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
    - echo "Deploying API with specific field..."
    - curl --header "Authorization: Bearer $API_KEY" https://api.example.com/deploy
    - echo "Using full secret..."
    - curl --header "Authorization: Bearer $(cat $FULL_SECRET | jq --raw-output '.api_key')" https://api.example.com/status
```

<a id="secret-versioning"></a>

## 密钥版本控制

AWS 密钥管理器支持密钥的多个版本。您可以使用 `version_id` 或 `version_stage` 指定特定版本。例如：

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
    - echo "Deploying to production with current secret version..."
    - deploy-prod.sh --db-password $DATABASE_PASSWORD
    - echo "Testing with specific secret version..."
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
    - echo "Accessing shared secret from another account..."
    - curl --header "Authorization: Bearer $SHARED_API_KEY" https://shared-api.example.com/deploy
```

<a id="per-secret-configuration-overrides"></a>

## 按密钥配置覆盖

您可以按密钥覆盖全局 AWS 设置。例如：

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
    - echo "Deploying to EU region..."
    - deploy-to-eu.sh --db-password $EU_DATABASE_PASSWORD
    - echo "Deploying to US region..."
    - deploy-to-us.sh --db-password $US_DATABASE_PASSWORD
```

在这些示例中：

- `aud`：受众，必须与[创建联合身份凭证](../cloud_services/aws/_index.md)时使用的受众一致。
- `secret_id`：AWS 密钥管理器中密钥的名称或 ARN。要从另一个账户检索密钥，您必须使用 ARN。
- `field`：是要检索的 JSON 密钥中的特定键。如果未指定，则检索整个密钥。
  字段访问仅支持扁平 JSON 密钥（仅顶层键），并支持字符串、数字和布尔值。
  例如：
  - `password`：访问 `password` 字段。
  - `api_key`：访问 `api_key` 字段。
  - `token`：指定用于认证的 ID 令牌。如果未指定，runner 会查找名为 `AWS_ID_TOKEN`的令牌。
- `version_id`：是密钥特定版本的唯一标识符。
  如果您既未指定 `version_id` 也未指定 `version_stage`，AWS 密钥管理器会返回 `AWSCURRENT` 版本。
- `version_stage`：要检索的密钥版本的暂存标签（例如 `AWSCURRENT` 或 `AWSPENDING`）。
  您不能为同一个密钥同时指定 `version_id` 和 `version_stage`。
- `region`：为此特定密钥覆盖全局 `AWS_REGION`。
- `role_arn`：为此特定密钥覆盖全局 `AWS_ROLE_ARN`。
- `role_session_name`：为此特定密钥覆盖全局 `AWS_ROLE_SESSION_NAME`。
- 极狐GitLab 从 AWS 密钥管理器获取密钥，并将值存储在临时文件中。
  此文件的路径存储在 CI/CD 变量中，类似于
  [文件类型 CI/CD 变量](../variables/_index.md#use-file-type-cicd-variables)。

<a id="troubleshooting"></a>

## 故障排除

有关在 AWS 中设置 OIDC 时的一般问题，请参阅 [AWS 的 OIDC 故障排除](../cloud_services/aws/_index.md#troubleshooting)。

<a id="error-no-ec2-imds-role-found"></a>

### 错误：`no EC2 IMDS role found`

如果以下两个条件同时成立，可能会出现以下错误：

- CI/CD 作业配置为[使用 IAM 角色认证](#with-iam-role-authentication)。
- 该作业由托管在 AWS EKS 上、使用 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)的 runner 执行。

```plaintext
Resolving secrets
Resolving secret "MY_AWS_SECRET"...
Using "aws_secrets_manager" secret resolver...
ERROR: Job failed (system failure): resolving secrets: operation error Secrets Manager: GetSecretValue, get identity: get credentials: failed to refresh cached credentials, no EC2 IMDS role found, operation error ec2imds: GetMetadata, canceled, context deadline exceeded
```

`Resolving secrets` 步骤由 runner manager 处理。此步骤会访问缓存在 [EC2 IMDS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)中的 IAM 凭证。
如果 IAM 角色尚未应用于 runner manager，`Resolving secrets` 步骤会失败。

要解决此错误，请将正确的 IAM 角色应用于 runner manager。

将 IAM 角色应用于由 runner manager 创建和管理的 runner pod 并不能解决此问题。
