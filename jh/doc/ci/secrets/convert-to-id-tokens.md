---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 更新您的 HashiCorp Vault 配置，改用 ID 令牌，而不再使用已弃用的 CI_JOB_JWT 变量。
title: '教程：更新 HashiCorp Vault 配置以使用 ID 令牌'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程演示如何将您当前的 CI/CD 密钥配置转换为使用 [ID 令牌](id_token_authentication.md)。

`CI_JOB_JWT` 变量已弃用。要改用 ID 令牌，您必须更新 Vault 认证方法和角色配置。

要转换为 ID 令牌：

1. 更新您的 Vault 配置。选择以下方式之一：
   - [将 JWT 角色迁移到新的认证路径](#migrate-jwt-roles-to-a-new-auth-path)
     1. [在 Vault 中创建第二个 JWT 认证路径](#create-a-second-jwt-authentication-path-in-vault)
     1. [重新创建角色以使用新的认证路径](#recreate-roles-to-use-the-new-authentication-path)
   - [将 `iss` 声明移动到角色级声明](#move-the-iss-claim-to-role-level-claims)
     1. [为每个角色添加 `bound_issuers` 声明映射](#add-bound_issuers-claim-map-to-each-role)
     1. [从认证方法中移除 `bound_issuers` 声明](#remove-bound_issuers-claim-from-auth-method)
1. [更新您的 CI/CD 作业](#update-your-cicd-jobs)

<a id="before-you-begin"></a>

## 开始之前

本教程假设您熟悉极狐GitLab CI/CD 和 Vault。

要继续学习，您必须具备：

- 一个您已在使用的 Vault 服务器。
- 使用 `CI_JOB_JWT` 从 Vault 检索密钥的 CI/CD 作业。

> [!note]
> 在 Vault 1.17 及更高版本中，当 JWT 包含 `aud` 声明时，[JWT 认证登录要求角色上绑定受众](https://developer.hashicorp.com/vault/docs/upgrading/upgrade-to-1.17.x#jwt-auth-login-requires-bound-audiences-on-the-role)。
> `aud` 声明可以是单个字符串，也可以是字符串列表。

<a id="migrate-jwt-roles-to-a-new-auth-path"></a>

## 将 JWT 角色迁移到新的认证路径

此方法会与您当前的认证方法并行创建一个第二个 JWT 认证方法，然后重新创建您的角色以使用它。如果您不想复制认证方法，请改用[角色级声明](#move-the-iss-claim-to-role-level-claims)。

<a id="create-a-second-jwt-authentication-path-in-vault"></a>

### 在 Vault 中创建第二个 JWT 认证路径

在这些示例中，请将 `gitlab.example.com` 替换为您的极狐GitLab 实例的 URL。

作为从 `CI_JOB_JWT` 过渡到 ID 令牌的一部分，您必须更新 Vault 中的 `bound_issuer`，使其包含 `https://`：

```shell
$ vault write auth/jwt/config \
    oidc_discovery_url="https://gitlab.example.com" \
    bound_issuer="https://gitlab.example.com"
```

进行此更改后，使用 `CI_JOB_JWT`的作业会开始失败。

要在不中断的情况下按项目或按作业过渡到 ID 令牌，请在 Vault 中创建多个认证路径：

1. 配置一个名为 `jwt_v2`的新认证路径，运行：

   ```shell
   vault auth enable -path jwt_v2 jwt
   ```

   您可以选择其他名称，但本教程其余示例假设您使用了 `jwt_v2`，因此
   请根据需要更新示例。

1. 为您的实例配置新的认证路径：

   ```shell
   $ vault write auth/jwt_v2/config \
       oidc_discovery_url="https://gitlab.example.com" \
       bound_issuer="https://gitlab.example.com"
   ```

<a id="recreate-roles-to-use-the-new-authentication-path"></a>

### 重新创建角色以使用新的认证路径

在这些示例中，请将 `vault.example.com` 替换为您的 Vault 服务器的 URL。

角色会绑定到特定的认证路径，因此您需要为每个作业添加新角色。如果 JWT 包含受众，则角色的 `bound_audiences` 参数是必需的，并且必须与 JWT 关联的 `aud` 声明中的至少一个匹配。

1. 重新创建名为 `myproject-staging`的预发布环境角色：

   ```shell
   $ vault write auth/jwt_v2/role/myproject-staging - <<EOF
   {
     "role_type": "jwt",
     "policies": ["myproject-staging"],
     "token_explicit_max_ttl": 60,
     "user_claim": "user_email",
     "bound_audiences": ["https://vault.example.com"],
     "bound_claims": {
       "project_id": "22",
       "ref": "master",
       "ref_type": "branch"
     }
   }
   EOF
   ```

1. 重新创建名为 `myproject-production`的生产环境角色：

   ```shell
   $ vault write auth/jwt_v2/role/myproject-production - <<EOF
   {
     "role_type": "jwt",
     "policies": ["myproject-production"],
     "token_explicit_max_ttl": 60,
     "user_claim": "user_email",
     "bound_audiences": ["https://vault.example.com"],
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

您只需在 `vault` 命令中将 `jwt` 更新为 `jwt_v2`。不要更改角色内部的
`role_type`。

<a id="move-the-iss-claim-to-role-level-claims"></a>

## 将 `iss` 声明移动到角色级声明

此方法不需要您创建第二个 JWT 认证方法或重新创建任何角色。相反，您可以直接将新的 `iss` 声明值添加到当前角色中。如果您希望每个角色保留单个声明值，请改用[新的认证路径](#migrate-jwt-roles-to-a-new-auth-path)。

<a id="add-bound_issuers-claim-map-to-each-role"></a>

### 为每个角色添加 `bound_issuers` 声明映射

在这些示例中，请将 `gitlab.example.com` 替换为您的极狐GitLab 实例的 URL，将 `vault.example.com` 替换为您的 Vault 服务器的 URL，并将 `jwt` 替换为您当前的认证方法名称。

Vault 不允许在 JWT 认证方法级别设置多个 `iss` 声明，因为此级别上的 [`bound_issuer`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_issuer) 指令只接受单个值。但是，您可以使用
[`bound_claims`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims)
映射配置指令在角色级别配置多个声明。

使用此方法，您可以为 Vault 提供多个 `iss` 声明验证选项：随 ID 令牌一起提供的带 `https://` 前缀的极狐GitLab 实例主机名声明，以及旧的不带前缀的声明。

要将
[`bound_claims`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims)
配置添加到所需角色，请运行：

```shell
$ vault write auth/jwt/role/myproject-staging - <<EOF
{
  "role_type": "jwt",
  "policies": ["myproject-staging"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_audiences": ["https://vault.example.com"],
  "bound_claims": {
    "iss": [
      "https://gitlab.example.com",
      "gitlab.example.com"
    ],
    "project_id": "22",
    "ref": "master",
    "ref_type": "branch"
  }
}
EOF
```

除了 `bound_claims` 部分之外，您无需更改任何当前角色配置。请务必如前所示添加 `iss` 配置，以确保 Vault 接受此角色的带前缀和不带前缀的 `iss` 声明。

在继续下一步之前，您必须将此更改应用到用于极狐GitLab 集成的所有 JWT 角色。

<a id="remove-bound_issuers-claim-from-auth-method"></a>

### 从认证方法中移除 `bound_issuers` 声明

在所有角色都已更新 `bound_claims.iss` 声明后，您可以移除此验证的认证方法级别配置：

```shell
$ vault write auth/jwt/config \
    oidc_discovery_url="https://gitlab.example.com" \
    bound_issuer=""
```

空的 `bound_issuer` 值会移除认证方法级别上的颁发者验证。但是，由于此验证现在位于角色级别，因此配置仍然是安全的。

一旦您将所有项目都迁移到 ID 令牌，并且不再需要同时支持 `CI_JOB_JWT`，您就可以还原此配置：从每个角色的 `bound_claims`中移除 `iss` 声明，并将认证方法上的 `bound_issuer` 重新设置为单个值。

<a id="update-your-cicd-jobs"></a>

## 更新您的 CI/CD 作业

Vault 有两种不同的 [KV 密钥引擎](https://developer.hashicorp.com/vault/docs/secrets/kv)。您使用的版本会影响您在 CI/CD 中定义密钥的方式。

请查看 HashiCorp 支持门户上的[我的 Vault KV 挂载是哪个版本？](https://support.hashicorp.com/hc/en-us/articles/4404288741139-Which-Version-is-my-Vault-KV-Mount)文章，以检查您的 Vault 服务器。

此外，如果需要，您可以查看以下 CI/CD 文档：

- [`secrets:`](../yaml/_index.md#secrets)
- [`id_tokens:`](../yaml/_index.md#id_tokens)

这些示例展示如何获取预发布数据库密码。它存储在 `secret/myproject/staging/db`的 `password` 字段中。在这些示例中，请将 `vault.example.com` 替换为您的 Vault 服务器的
URL。

`VAULT_AUTH_PATH` 变量的值取决于您用于迁移的方法：

- 新认证路径：使用 `jwt_v2`。
- 角色级声明：使用 `jwt`。

<a id="kv-secrets-engine-v1"></a>

### KV 密钥引擎 v1

[`secrets:vault`](../yaml/_index.md#secretsvault) 关键字默认使用 KV 挂载的 v2，因此您需要显式配置作业以使用 v1 引擎：

```yaml
job:
  variables:
    VAULT_SERVER_URL: https://vault.example.com
    VAULT_AUTH_PATH: jwt_v2  # or "jwt" if you used the role-level claims approach
    VAULT_AUTH_ROLE: myproject-staging
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
    PASSWORD:
      vault:
        engine:
          name: kv-v1
          path: secret
        field: password
        path: myproject/staging/db
      file: false
```

如果需要，`VAULT_SERVER_URL` 和 `VAULT_AUTH_PATH` 都可以[定义为项目或群组 CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-ui)。

[`secrets:file`](../yaml/_index.md#secretsfile) 设置为 `false`，因为 ID 令牌默认将密钥放在文件中。密钥需要改为作为常规变量使用，以匹配旧行为。

<a id="kv-secrets-engine-v2"></a>

### KV 密钥引擎 v2

您可以为 v2 引擎使用两种格式。

长格式：

```yaml
job:
  variables:
    VAULT_SERVER_URL: https://vault.example.com
    VAULT_AUTH_PATH: jwt_v2  # or "jwt" if you used the role-level claims approach
    VAULT_AUTH_ROLE: myproject-staging
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
    PASSWORD:
      vault:
        engine:
          name: kv-v2
          path: secret
        field: password
        path: myproject/staging/db
      file: false
```

此长格式与 v1 引擎的示例相同，但 `secrets:vault:engine:name:` 设置为 `kv-v2` 以匹配该引擎。

您也可以使用短格式：

```yaml
job:
  variables:
    VAULT_SERVER_URL: https://vault.example.com
    VAULT_AUTH_PATH: jwt_v2  # or "jwt" if you used the role-level claims approach
    VAULT_AUTH_ROLE: myproject-staging
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
      PASSWORD:
        vault: myproject/staging/db/password@secret
        file: false
```

提交更新后的 CI/CD 配置后，您的作业将使用 ID 令牌获取密钥。恭喜！
