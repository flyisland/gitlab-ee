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

本教程演示如何在极狐GitLab CI/CD 中对 HashiCorp 的 Vault 进行身份验证、配置并读取密钥。

<a id="prerequisites"></a>

## 先决条件

本教程假设你已熟悉极狐GitLab CI/CD 和 Vault。

要跟随操作，你必须具备：

- 一个极狐GitLab 账户。
- 能够访问一个运行中的 Vault 服务器（至少 v1.2.0），用于配置身份验证并创建角色和策略。
  对于 HashiCorp Vault，可以是开源版或企业版。

> [!note]
> 你必须将以下示例中的 `vault.example.com` URL 替换为你的 Vault 服务器 URL，
> 并将 `gitlab.example.com` 替换为你的极狐GitLab 实例 URL。

<a id="configure-the-vault"></a>

## 配置 Vault

> [!warning]
> JWT 属于凭证，可以授予对资源的访问权限。请注意妥善保管！

设想一个场景，你将预发布环境和生产环境的数据库密码存储在 Vault 服务器中。
此场景假设你使用 [KV v2](https://developer.hashicorp.com/vault/docs/secrets/kv#kv-version-2) 机密引擎。
如果你使用的是 [KV v1](https://developer.hashicorp.com/vault/docs/secrets/kv#version-comparison)，
请从下面的策略路径中移除 `/data/`，并参阅 [如何配置你的 CI/CD 作业](convert-to-id-tokens.md#kv-secrets-engine-v1)。

你可以使用 `vault kv get` 命令检索密码。

```shell
$ vault kv get -field=password secret/myproject/staging/db
pa$$w0rd

$ vault kv get -field=password secret/myproject/production/db
real-pa$$w0rd
```

你的预发布环境密码是 `pa$$w0rd`，
生产环境密码是 `real-pa$$w0rd`。

要配置你的 Vault 服务器，首先启用 [JWT 认证](https://developer.hashicorp.com/vault/docs/auth/jwt) 方法：

```shell
$ vault auth enable jwt
Success! Enabled jwt auth method at: jwt/
```

然后创建允许你读取这些密钥的策略（每个密钥一个策略）：

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

你还需要将 JWT 与这些策略关联起来的角色。

例如，为预发布环境创建一个名为 `myproject-staging` 的角色。[绑定 claims](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims)
被配置为仅允许该策略用于 ID 为 `22` 的项目中的 `main` 分支：

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

再为生产环境创建一个名为 `myproject-production` 的角色。该角色的 `bound_claims` 部分
仅允许匹配 `auto-deploy-*` 模式的受保护分支访问密钥。

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

结合 [受保护分支](../../user/project/repository/branches/protected.md)，
你可以限制谁能够进行身份验证并读取密钥。

[JWT 中包含的任何 claims](id_token_authentication.md#token-payload)
都可以与绑定 claims 中的值列表进行匹配。例如：

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

- 如果仅使用 `namespace_id`，则命名空间中的所有项目都被允许。子项目不会被包含，
  因此如果需要，其命名空间 ID 也必须添加到列表中。
- 如果同时使用 `namespace_id` 和 `project_id`，Vault 会首先检查项目的命名空间
  是否在 `namespace_id` 中，然后检查项目是否在 `project_id` 中。

[`token_explicit_max_ttl`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_explicit_max_ttl)
指定 Vault 在成功认证后签发的令牌具有 60 秒的硬性生存时间限制。

[`user_claim`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#user_claim)
指定 Vault 在成功登录后创建的身份别名名称。

[`bound_claims_type`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims_type)
配置 `bound_claims` 值的解释方式。如果设置为 `glob`，则值会被解释为通配符模式，
`*` 匹配任意数量的字符。

[claim 字段](id_token_authentication.md#token-payload) 也可以用于
[Vault 策略路径模板化](https://developer.hashicorp.com/vault/tutorials/policies/policy-templating?in=vault%2Fpolicies)，
方法是使用 Vault 中 JWT 认证方法的访问器名称。
可以通过运行 `vault auth list` 获取 [挂载访问器名称](https://developer.hashicorp.com/vault/tutorials/auth-methods/identity#step-1-create-an-entity-with-alias)
（以下示例中的 `ACCESSOR_NAME`）。

利用名为 `project_path` 的命名元数据字段的策略模板示例：

```plaintext
path "secret/data/{{identity.entity.aliases.ACCESSOR_NAME.metadata.project_path}}/staging/*" {
  capabilities = [ "read" ]
}
```

支持前面模板化策略的角色示例，该策略通过使用 [`claim_mappings`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#claim_mappings)
配置将 claim 字段 `project_path` 映射为元数据字段：

```json
{
  "role_type": "jwt",
  ...
  "claim_mappings": {
    "project_path": "project_path"
  }
}
```

有关选项的完整列表，请参阅 Vault 的 [创建角色文档](https://developer.hashicorp.com/vault/api-docs/auth/jwt#create-role)。

> [!warning]
> 始终通过使用提供的某个 claim（例如 `project_id` 或 `namespace_id`）
> 将你的角色限制到项目或命名空间。否则，该实例生成的任何 JWT 都可能被允许使用此角色进行身份验证。

现在，配置 JWT 认证方法：

```shell
$ vault write auth/jwt/config \
    oidc_discovery_url="https://gitlab.example.com" \
    bound_issuer="https://gitlab.example.com"
```

[`bound_issuer`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_issuer)
指定只有签发者（即 `iss` claim）设置为 `gitlab.example.com` 的 JWT
才能使用此方法进行身份验证，并且 `oidc_discovery_url`（`https://gitlab.example.com`）
应用于验证令牌。

有关可用配置选项的完整列表，请参阅 Vault 的 [API 文档](https://developer.hashicorp.com/vault/api-docs/auth/jwt#configure)。

在极狐GitLab 中，创建以下 [CI/CD 变量](../variables/_index.md#for-a-project)
以提供 Vault 服务器的详细信息：

- `VAULT_SERVER_URL`：你的 Vault 服务器 URL，例如 `https://vault.example.com:8200`。
- `VAULT_AUTH_ROLE`：可选。尝试认证时使用的 Vault JWT 认证角色名称。在本教程中，
  你已经创建了两个角色，名称分别为 `myproject-staging` 和 `myproject-production`。如果未指定角色，
  Vault 会使用在配置认证方法时指定的 [默认角色](https://developer.hashicorp.com/vault/api-docs/auth/jwt#default_role)。
- `VAULT_AUTH_PATH`：可选。认证方法挂载的路径。
  默认为 `jwt`。
- `VAULT_NAMESPACE`：可选。用于读取机密和认证的 [Vault Enterprise 命名空间](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)。
  如果未指定命名空间，Vault 将使用根（`/`）命名空间。
  该设置会被 Vault 开源版忽略。

<a id="automatic-id-token-authentication"></a>

## 自动 ID 令牌认证

以下作业在为默认分支运行时，可以读取 `secret/myproject/staging/` 下的密钥，
但不能读取 `secret/myproject/production/` 下的密钥：

```yaml
job_with_secrets:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
    STAGING_DB_PASSWORD:
      vault: myproject/staging/db/password@secret  # 转换为路径 'secret/myproject/staging/db' 和字段 'password'。使用 $VAULT_ID_TOKEN 进行认证。
  script:
    - access-staging-db.sh --token $STAGING_DB_PASSWORD
```

在此示例中：

- `id_tokens` - 用于 OIDC 认证的 JSON Web Token (JWT)。`aud` claim
  被设置为与在 Vault JWT 认证方法中使用的角色的 `bound_audiences` 参数相匹配。
- `@secret` - 启用了机密引擎的 vault 名称。
- `myproject/staging/db` - Vault 中密钥的路径位置。
- `password` - 在引用的密钥中要获取的字段。

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
> 从 Vault 1.17 开始，当 JWT 包含 `aud` claim 时，[JWT 认证登录要求角色上必须绑定 audiences](https://developer.hashicorp.com/vault/docs/upgrading/upgrade-to-1.17.x#jwt-auth-login-requires-bound-audiences-on-the-role)。
> `aud` claim 可以是单个字符串或字符串列表。

<a id="manual-authentication"></a>

### 手动认证

你可以使用 ID 令牌手动向 HashiCorp Vault 进行身份验证。例如：

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

## 限制令牌访问 Vault 密钥

你可以通过使用 Vault 保护机制和极狐GitLab 功能来控制 ID 令牌对 Vault 密钥的访问。例如，通过以下方式限制令牌：

- 对特定的 ID 令牌 `aud` claim 使用 Vault [绑定 audiences](https://developer.hashicorp.com/vault/docs/auth/jwt#bound-audiences)。
- 使用 Vault [绑定 claims](https://developer.hashicorp.com/vault/docs/auth/jwt#bound-claims) 为特定群组使用 `group_claim`。
- 根据特定用户的 `user_login` 和 `user_email` 对 Vault 绑定 claims 的值进行硬编码。
- 设置 Vault 的时间限制，即如在 [`token_explicit_max_ttl`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_explicit_max_ttl) 中所指定的，令牌在认证后过期。
- 将 JWT 的作用域限制为 [极狐GitLab 受保护分支](../../user/project/repository/branches/protected.md)，这些分支仅限项目中的一部分用户。
- 将 JWT 的作用域限制为 [极狐GitLab 受保护标签](../../user/project/protected_tags.md)，这些标签仅限项目中的一部分用户。

<a id="troubleshooting"></a>

## 故障排除

<a id="the-secrets-provider-can-not-be-found-check-your-cicd-variables-and-try-again-message"></a>

### `未找到密钥提供程序。请检查你的 CI/CD 变量并重试。` 消息

你在尝试启动配置为访问 HashiCorp Vault 的作业时可能会收到此错误：

```plaintext
The secrets provider can not be found. Check your CI/CD variables and try again.
```

无法创建作业，因为未定义必需的变量：

- `VAULT_SERVER_URL`

<a id="api-error-status-code-400-missing-role-error"></a>

### `api error: status code 400: missing role` 错误

你在尝试启动配置为访问 HashiCorp Vault 的作业时可能会收到 `missing role` 错误。
此错误可能是因为未定义 `VAULT_AUTH_ROLE` 变量，因此该作业无法向 Vault 服务器进行身份验证。

<a id="audience-claim-does-not-match-any-expected-audience-error"></a>

### `audience claim does not match any expected audience` 错误

如果 YAML 文件中指定的 ID 令牌的 `aud:` claim 值
与用于 JWT 认证的角色的 `bound_audiences` 参数不匹配，你可能会收到此错误：

`invalid audience (aud) claim: audience claim does not match any expected audience`

确保这些值相同。