---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何从已弃用的 `CI_JOB_JWT` 变量转换为 ID Token
title: '教程：更新 HashiCorp Vault 配置以使用 ID Token'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 从 Vault 1.17 开始，当 JWT 包含 `aud` 声明时，[JWT 认证登录要求角色上绑定受众](https://developer.hashicorp.com/vault/docs/upgrading/upgrade-to-1.17.x#jwt-auth-login-requires-bound-audiences-on-the-role)。`aud` 声明可以是单个字符串或字符串列表。

本教程演示如何将现有的 CI/CD 密钥配置转换为使用 [ID Token](id_token_authentication.md)。

`CI_JOB_JWT` 变量已弃用，但更新为 ID Token 需要进行一些重要的配置更改才能与 Vault 配合使用。如果您有大量作业，一次性转换所有内容是一项艰巨的任务。

迁移到 [ID Token](id_token_authentication.md) 没有标准方法，因此本教程提供了两种转换现有 CI/CD 密钥的方法。请选择最适合您用例的方法：

1. 更新您的 Vault 配置：
   - 方法 A：将 JWT 角色迁移到新的 Vault 认证方法
     1. [在 Vault 中创建第二个 JWT 认证路径](#create-a-second-jwt-authentication-path-in-vault)
     1. [重新创建角色以使用新的认证路径](#recreate-roles-to-use-the-new-authentication-path)
   - 方法 B：在迁移窗口期内将 `iss` 声明移至角色
     1. [为每个角色添加 `bound_issuers` 声明映射](#add-bound_issuers-claim-map-to-each-role)
     1. [从认证方法中移除 `bound_issuers` 声明](#remove-bound_issuers-claim-from-auth-method)
1. [更新您的 CI/CD 作业](#update-your-cicd-jobs)

<a id="prerequisites"></a>

## 先决条件

本教程假设您熟悉极狐GitLab CI/CD 和 Vault。

要继续操作，您必须具备：

- 一个您已在使用的 Vault 服务器。
- 使用 `CI_JOB_JWT` 从 Vault 检索密钥的 CI/CD 作业。

在以下示例中，请替换：

- 将 `vault.example.com` 替换为您的 Vault 服务器的 URL。
- 将 `gitlab.example.com` 替换为您的极狐GitLab 实例的 URL。
- 将 `jwt` 或 `jwt_v2` 替换为您的认证方法名称。

<a id="method-a-migrate-jwt-roles-to-the-new-vault-auth-method"></a>

## 方法 A：将 JWT 角色迁移到新的 Vault 认证方法

此方法在与现有 JWT 认证方法并行的基础上创建一个新的 JWT 认证方法。之后，用于极狐GitLab 集成的所有 Vault 角色都将在此新认证方法中重新创建。

<a id="create-a-second-jwt-authentication-path-in-vault"></a>

### 在 Vault 中创建第二个 JWT 认证路径

作为从 `CI_JOB_JWT` 过渡到 ID Token 的一部分，您必须更新 Vault 中的 `bound_issuer` 以包含 `https://`：

```shell
$ vault write auth/jwt/config \
    oidc_discovery_url="https://gitlab.example.com" \
    bound_issuer="https://gitlab.example.com"
```

进行此更改后，使用 `CI_JOB_JWT` 的作业将开始失败。

您可以在 Vault 中创建多个认证路径，从而可以按项目或按作业进行 ID Token 的过渡，而不会中断。

1. 使用名称 `jwt_v2` 配置新的认证路径，运行：

   ```shell
   vault auth enable -path jwt_v2 jwt
   ```

   您可以选择其他名称，但本教程的其余示例假定您使用了 `jwt_v2`，因此请根据需要更新示例。

1. 为您的实例配置新的认证路径：

   ```shell
   $ vault write auth/jwt_v2/config \
       oidc_discovery_url="https://gitlab.example.com" \
       bound_issuer="https://gitlab.example.com"
   ```

<a id="recreate-roles-to-use-the-new-authentication-path"></a>

### 重新创建角色以使用新的认证路径

角色绑定到特定的认证路径，因此您需要为每个作业添加新角色。如果 JWT 包含受众，则角色的 `bound_audiences` 参数是必需的，并且必须至少与 JWT 的一个关联 `aud` 声明匹配。

1. 为名为 `myproject-staging` 的预发布环境重新创建角色：

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

1. 为名为 `myproject-production` 的生产环境重新创建角色：

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

您只需要在 `vault` 命令中将 `jwt` 更新为 `jwt_v2`，不要更改角色内部的 `role_type`。

<a id="method-b-move-iss-claim-to-roles-for-migration-window"></a>

## 方法 B：在迁移窗口期内将 `iss` 声明移至角色

此方法不需要 Vault 管理员创建第二个 JWT 认证方法并重新创建所有与极狐GitLab 相关的角色。

<a id="add-bound_issuers-claim-map-to-each-role"></a>

### 为每个角色添加 `bound_issuers` 声明映射

Vault 不允许在 JWT 认证方法级别设置多个 `iss` 声明，因为此级别的 [`bound_issuer`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_issuer) 指令只接受单个值。但是，可以通过使用 [`bound_claims`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims) 映射配置指令在角色级别配置多个声明。

使用此方法，您可以为 Vault 提供多个 `iss` 声明验证选项。这支持由 `id_tokens` 携带的、带 `https://` 前缀的极狐GitLab 实例主机名声明，以及旧的非前缀声明。

要为所需角色添加 [`bound_claims`](https://developer.hashicorp.com/vault/api-docs/auth/jwt#bound_claims) 配置，请运行：

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

除了 `bound_claims` 部分外，您无需更改任何现有的角色配置。请确保按照前面所示添加 `iss` 配置，以确保 Vault 接受此角色的带前缀和不带前缀的 `iss` 声明。

在继续下一步之前，您必须将此更改应用于用于极狐GitLab 集成的所有 JWT 角色。

在所有项目都已迁移并且您不再需要同时支持 `CI_JOB_JWT` 和 ID Token 之后，您可以根据需要撤销把 `iss` 声明验证从认证方法迁移到角色的操作，将其移回认证方法配置。

<a id="remove-bound_issuers-claim-from-auth-method"></a>

### 从认证方法中移除 `bound_issuers` 声明

在所有角色都使用 `bound_claims.iss` 声明更新后，您可以移除认证方法级别的此验证配置：

```shell
$ vault write auth/jwt/config \
    oidc_discovery_url="https://gitlab.example.com" \
    bound_issuer=""
```

将 `bound_issuer` 指令设置为空字符串会移除认证方法级别的签发者验证。但是，由于此验证现在位于角色级别，因此配置仍然是安全的。

<a id="update-your-cicd-jobs"></a>

## 更新您的 CI/CD 作业

Vault 有两种不同的 [KV 密钥引擎](https://developer.hashicorp.com/vault/docs/secrets/kv)，您使用的版本会影响您在 CI/CD 中定义密钥的方式。

请查看 HashiCorp 支持门户上的 [Which Version is my Vault KV Mount?](https://support.hashicorp.com/hc/en-us/articles/4404288741139-Which-Version-is-my-Vault-KV-Mount) 文章以检查您的 Vault 服务器。

此外，如果需要，您可以查看以下 CI/CD 文档：

- [`secrets:`](../yaml/_index.md#secrets)
- [`id_tokens:`](../yaml/_index.md#id_tokens)

以下示例演示如何获取写入 `secret/myproject/staging/db` 中 `password` 字段的预发布环境数据库密码。

`VAULT_AUTH_PATH` 变量的值取决于您使用的迁移方法：

- 方法 A（将 JWT 角色迁移到新的 Vault 认证方法）：使用 `jwt_v2`。
- 方法 B（在迁移窗口期内将 `iss` 声明移至角色）：使用 `jwt`。

<a id="kv-secrets-engine-v1"></a>

### KV 密钥引擎 v1

[`secrets:vault`](../yaml/_index.md#secretsvault) 关键字默认为 KV Mount 的 v2 版本，因此您需要显式配置作业以使用 v1 引擎：

```yaml
job:
  variables:
    VAULT_SERVER_URL: https://vault.example.com
    VAULT_AUTH_PATH: jwt_v2  # or "jwt" if you used method B
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

如果愿意，`VAULT_SERVER_URL` 和 `VAULT_AUTH_PATH` 都可以[定义为项目或群组 CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-ui)。

[`secrets:file`](../yaml/_index.md#secretsfile) 设置为 `false`，因为 ID Token 默认将密钥放在文件中，而它需要作为常规变量工作以匹配旧行为。

<a id="kv-secrets-engine-v2"></a>

### KV 密钥引擎 v2

您可以使用两种格式的 v2 引擎。

长格式：

```yaml
job:
  variables:
    VAULT_SERVER_URL: https://vault.example.com
    VAULT_AUTH_PATH: jwt_v2  # or "jwt" if you used method B
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

此长格式与 v1 引擎的示例相同，但 `secrets:vault:engine:name:` 设置为 `kv-v2` 以匹配引擎。

您也可以使用短格式：

```yaml
job:
  variables:
    VAULT_SERVER_URL: https://vault.example.com
    VAULT_AUTH_PATH: jwt_v2  # or "jwt" if you used method B
    VAULT_AUTH_ROLE: myproject-staging
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
      PASSWORD:
        vault: myproject/staging/db/password@secret
        file: false
```

提交更新的 CI/CD 配置后，您的作业将使用 ID Token 获取密钥，恭喜！

如果您已将所有项目迁移为使用 ID Token 获取密钥，并且使用了方法 B 进行迁移，那么现在可以根据需要将 `iss` 声明验证移回认证方法配置。
