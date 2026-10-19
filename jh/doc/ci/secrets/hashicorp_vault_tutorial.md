---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 HashiCorp Vault 进行身份验证并读取密钥'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程演示如何在极狐GitLab CI/CD 中使用 HashiCorp 的 Vault 进行身份验证、配置并读取密钥。

<a id="prerequisites"></a>

## 先决条件

本教程假设您熟悉极狐GitLab CI/CD 和 Vault。

要跟随本教程操作，您必须具备：

- 一个极狐GitLab 账号。
- 访问一个正在运行的 Vault 服务器（至少 v1.2.0）的权限，以便配置身份验证并创建角色和策略。
  对于 HashiCorp Vault，这可以是开源版或企业版。

> [!note]
> 您必须将以下示例中的 `vault.example.com` URL 替换为您 Vault 服务器的 URL，
> 并将 `gitlab.example.com` 替换为您极狐GitLab 实例的 URL。

<a id="configure-the-vault"></a>

## 配置 Vault

> [!warning]
> JWT 是凭据，可用于授予对资源的访问权限。粘贴它们时请务必小心！

假设您将预发布数据库和生产数据库的密码存储在 Vault 服务器中。此场景假设您使用 [KV v2](https://developer.hashicorp.com/vault/docs/secrets/kv#kv-version-2) 密钥引擎。如果您使用的是 [KV v1](https://developer.hashicorp.com/vault/docs/secrets/kv#version-comparison)，请从以下策略路径中移除 `/data/`，并参阅[如何配置您的 CI/CD 作业](convert-to-id-tokens.md#kv-secrets-engine-v1)。

您可以使用 `vault kv get` 命令检索密码。

```shell
$ vault kv get -field=password secret/myproject/staging/db
pa$$w0rd

$ vault kv get -field=password secret/myproject/production/db
real-pa$$w0rd
```

您的预发布密码是 `pa$$w0rd`，生产密码是 `real-pa$$w0rd`。

要配置您的 Vault 服务器，首先启用 [JWT Auth](https://developer.hashicorp.com/vault/docs/auth/jwt) 方法：

```shell
$ vault auth enable jwt
Success! Enabled jwt auth method at: jwt/
```

然后创建允许您读取这些密钥的策略（每个密钥一个）：

```shell
$ vault policy write myproject-staging - <<EOF
# Policy name: myproject-staging
#
# Read-only permission on 'secret/data/myproject/staging/*' path
path "secret/data/myproject/staging/*" {
  capabilities = [ "read" ]
}
EOF
Success! Uploaded policy: myproject-staging

$ vault policy write myproject-production - <<EOF
# Policy name: myproject-production
#
# Read-only permission on 'secret/data/myproject/production/*' path
path "secret/data/myproject/production/*" {
  capabilities = [ "read" ]
}
EOF
Success! Uploaded policy: myproject-production
```

您还需要能够将 JWT 与这些策略关联起来的角色。

例如，一个名为 `myproject-staging`的预发布角色。[bound claims](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims) 配置为仅允许该策略用于 ID 为 `22`的项目中的 `main` 分支：

```json
$ vault write auth/jwt/role/myproject-staging - <<EOF
{
  "role_type": "jwt",
  "policies": ["myproject-staging"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_audiences": "https://vault.example.com",
  "bound_claims": {
    "project_id": "22",
    "ref": "main",
    "ref_type": "branch"
  }
}
EOF
```

以及一个名为 `myproject-production`的生产角色。此角色的 `bound_claims` 部分仅允许匹配 `auto-deploy-*` 模式的受保护分支访问这些密钥。

```json
$ vault write auth/jwt/role/myproject-production - <<EOF
{
  "role_type": "jwt",
  "policies": ["myproject-production"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_audiences": "https://vault.example.com",
  "bound_claims_type": "glob",
  "bound_claims": {
    "project_id": "22",
    "ref_protected": "true",
    "ref_type": "branch",
    "ref": "auto-deploy-*"
  }
}
EOF
```

结合[受保护分支](../../user/project/repository/branches/protected.md)，您可以限制哪些人可以进行身份验证并读取密钥。

[包含在 JWT 中](id_token_authentication.md#token-payload)的任何声明都可以与 bound claims 中的值列表进行匹配。例如：

```json
"bound_claims": {
  "user_login": ["alice", "bob", "mallory"]
}

"bound_claims": {
  "ref": ["main", "develop", "test"]
}

"bound_claims": {
  "namespace_id": ["10", "20", "30"]
}

"bound_claims": {
  "project_id": ["12", "22", "37"]
}
```

- 如果仅使用 `namespace_id`，则允许该命名空间中的所有项目。嵌套项目不包含在内，
  因此如有需要，还必须将其命名空间 ID 添加到列表中。
- 如果同时使用 `namespace_id` 和 `project_id`，Vault 会先检查项目的命名空间
  是否在 `namespace_id`中，然后检查项目是否在 `project_id`中。

[`token_explicit_max_ttl`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_explicit_max_ttl)
指定 Vault 在身份验证成功后签发的令牌具有 60 秒的硬性生存期限制。

[`user_claim`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#user_claim)
指定 Vault 在成功登录后创建的身份别名的名称。

[`bound_claims_type`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims_type)
配置 `bound_claims` 值的解释方式。如果设置为 `glob`，这些值将被解释为 glob，其中 `*` 匹配任意数量的字符。

还可以通过使用 Vault 中 JWT 认证的访问器名称，访问[声明字段](id_token_authentication.md#token-payload)以用于 [Vault 的策略路径模板化](https://developer.hashicorp.com/vault/tutorials/policies/policy-templating?in=vault%2Fpolicies)。[挂载访问器名称](https://developer.hashicorp.com/vault/tutorials/auth-methods/identity#step-1-create-an-entity-with-alias)（以下示例中的 `ACCESSOR_NAME`）可以通过运行 `vault auth list` 获取。

使用名为 `project_path`的命名元数据字段的策略模板示例：

```plaintext
path "secret/data/{{identity.entity.aliases.ACCESSOR_NAME.metadata.project_path}}/staging/*" {
  capabilities = [ "read" ]
}
```

支持上述模板化策略映射的角色示例，通过使用 [`claim_mappings`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#claim_mappings) 配置将声明字段 `project_path` 映射为元数据字段：

```json
{
  "role_type": "jwt",
  ...
  "claim_mappings": {
    "project_path": "project_path"
  }
}
```

有关完整的选项列表，请参阅 Vault 的[创建角色文档](https://developer.hashicorp.com/vault/api-docs/auth/jwt#create-role)。

> [!warning]
> 请始终使用提供的声明之一（例如 `project_id` 或 `namespace_id`）
> 将您的角色限制到项目或命名空间。否则，此实例生成的任何 JWT
> 都可能被允许使用此角色进行身份验证。

现在，配置 JWT 身份验证方法：

```shell
$ vault write auth/jwt/config \
    oidc_discovery_url="https://gitlab.example.com" \
    bound_issuer="https://gitlab.example.com"
```

[`bound_issuer`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_issuer)
指定只有签发者（即 `iss` 声明）设置为 `gitlab.example.com`的 JWT 才能使用此方法进行身份验证，并且应使用 `oidc_discovery_url`（`https://gitlab.example.com`）来验证令牌。

有关可用配置选项的完整列表，请参阅 Vault 的 [API 文档](https://developer.hashicorp.com/vault/api-docs/auth/jwt#configure)。

在极狐GitLab 中，创建以下 [CI/CD 变量](../variables/_index.md#for-a-project)以提供有关您 Vault 服务器的详细信息：

- `VAULT_SERVER_URL`：您 Vault 服务器的 URL，例如 `https://vault.example.com:8200`。
- `VAULT_AUTH_ROLE`：可选。尝试进行身份验证时要使用的 Vault JWT Auth 角色名称。在本教程中，
  您已经创建了两个角色，名称分别为 `myproject-staging` 和 `myproject-production`。如果未指定角色，
  Vault 将使用配置身份验证方法时指定的[默认角色](https://developer.hashicorp.com/vault/api-docs/auth/jwt#default_role)。
- `VAULT_AUTH_PATH`：可选。身份验证方法的挂载路径。
  默认为 `jwt`。
- `VAULT_NAMESPACE`：可选。用于读取密钥和进行身份验证的 [Vault Enterprise 命名空间](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)。
  如果未指定命名空间，Vault 将使用根（`/`）命名空间。
  Vault 开源版会忽略此设置。

<a id="automatic-id-token-authentication"></a>

## 自动 ID 令牌身份验证

以下作业在针对默认分支运行时，可以读取 `secret/myproject/staging/` 下的密钥，但无法读取 `secret/myproject/production/` 下的密钥：

```yaml
job_with_secrets:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
    STAGING_DB_PASSWORD:
      vault: myproject/staging/db/password@secret  # translates to a path of 'secret/myproject/staging/db' and field 'password'. Authenticates using $VAULT_ID_TOKEN.
  script:
    - access-staging-db.sh --token $STAGING_DB_PASSWORD
```

在此示例中：

- `id_tokens` - 用于 OIDC 身份验证的 JSON Web Token (JWT)。`aud` 声明
  设置为与用于 Vault JWT 身份验证方法的 `role`的 `bound_audiences` 参数相匹配。
- `@secret` - Vault 名称，即您的密钥引擎启用的位置。
- `myproject/staging/db` - 密钥在 Vault 中的路径位置。
- `password` - 要获取的所引用密钥中的字段。

如果定义了多个 ID 令牌，请使用 `token` 关键字指定应使用哪个令牌。例如：

```yaml
job_with_secrets:
  id_tokens:
    FIRST_ID_TOKEN:
      aud: https://first.service.com
    SECOND_ID_TOKEN:
      aud: https://second.service.com
  secrets:
    FIRST_DB_PASSWORD:
      vault: first/db/password
      token: $FIRST_ID_TOKEN
    SECOND_DB_PASSWORD:
      vault: second/db/password
      token: $SECOND_ID_TOKEN
  script:
    - access-first-db.sh --token $FIRST_DB_PASSWORD
    - access-second-db.sh --token $SECOND_DB_PASSWORD
```

> [!note]
> 从 Vault 1.17 开始，当 JWT 包含 `aud` 声明时，
> [JWT 认证登录要求角色上设置 bound audiences](https://developer.hashicorp.com/vault/docs/upgrading/upgrade-to-1.17.x#jwt-auth-login-requires-bound-audiences-on-the-role)。
> `aud` 声明可以是单个字符串或字符串列表。

<a id="manual-authentication"></a>

### 手动身份验证

您可以使用 ID 令牌手动向 HashiCorp Vault 进行身份验证。例如：

```yaml
manual_authentication:
  variables:
    VAULT_ADDR: http://vault.example.com:8200
  image: vault:latest
  id_tokens:
    VAULT_ID_TOKEN:
      aud: http://vault.example.com
  script:
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=myproject-example jwt=$VAULT_ID_TOKEN)"
    - export PASSWORD="$(vault kv get -field=password secret/myproject/example/db)"
    - my-authentication-script.sh $VAULT_TOKEN $PASSWORD
```

<a id="limit-token-access-to-vault-secrets"></a>

## 限制令牌对 Vault 密钥的访问

您可以通过使用 Vault 保护和极狐GitLab 功能来控制 ID 令牌对 Vault 密钥的访问。例如，通过以下方式限制令牌：

- 针对特定的 ID 令牌 `aud` 声明使用 Vault [bound audiences](https://developer.hashicorp.com/vault/docs/auth/jwt#bound-audiences)。
- 针对使用 `group_claim`的特定群组使用 Vault [bound claims](https://developer.hashicorp.com/vault/docs/auth/jwt#bound-claims)。
- 根据特定用户的 `user_login` 和 `user_email`
  硬编码 Vault bound claims 的值。
- 按照 [`token_explicit_max_ttl`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_explicit_max_ttl)中的规定，
  为令牌的 TTL 设置 Vault 时间限制，令牌在身份验证后过期。
- 将 JWT 的作用域限定为[极狐GitLab 受保护分支](../../user/project/repository/branches/protected.md)，
  这些分支仅限项目用户子集访问。
- 将 JWT 的作用域限定为[极狐GitLab 受保护标签](../../user/project/protected_tags.md)，
  这些标签仅限项目用户子集访问。

<a id="troubleshooting"></a>

## 故障排除

<a id="the-secrets-provider-can-not-be-found-check-your-cicd-variables-and-try-again-message"></a>

### `The secrets provider can not be found. Check your CI/CD variables and try again.` 消息

在尝试启动配置为访问 HashiCorp Vault 的作业时，您可能会收到此错误：

```plaintext
The secrets provider can not be found. Check your CI/CD variables and try again.
```

由于未定义所需的变量，无法创建该作业：

- `VAULT_SERVER_URL`

<a id="api-error-status-code-400-missing-role-error"></a>

### `api error: status code 400: missing role` 错误

在尝试启动配置为访问 HashiCorp Vault 的作业时，您可能会收到 `missing role` 错误。该错误可能是因为未定义 `VAULT_AUTH_ROLE` 变量，因此该作业无法向 Vault 服务器进行身份验证。

<a id="audience-claim-does-not-match-any-expected-audience-error"></a>

### `audience claim does not match any expected audience` 错误

如果 YAML 文件中指定的 ID 令牌的 `aud:` 声明值与用于 JWT 身份验证的 `role`的 `bound_audiences` 参数不匹配，您可能会收到此错误：

`invalid audience (aud) claim: audience claim does not match any expected audience`

请确保这些值相同。
