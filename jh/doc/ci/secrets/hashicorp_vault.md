---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "Learn to use HashiCorp Vault secrets in GitLab CI/CD, including authentication, Vault configuration, policies, and secrets engines."
title: '在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥。使用 [ID 令牌](id_token_authentication.md)
来[与 HashiCorp Vault 进行认证](https://developer.hashicorp.com/vault/docs/auth/jwt#jwt-authentication)。

你必须先配置 Vault 服务器，然后才能在 CI/CD 任务中使用 Vault 密钥。
[使用 HashiCorp Vault 进行认证和读取密钥](hashicorp_vault_tutorial.md)
教程包含了有关配置 Vault 和使用 ID 令牌进行认证的更多详细信息。

在以下示例中，请将 `vault.example.com` 替换为你的 Vault 服务器的 URL，
并将 `gitlab.example.com` 替换为你的极狐GitLab 实例的 URL。

## 配置你的 Vault 服务器

要配置你的 Vault 服务器：

1. 通过运行以下命令来启用认证方法。它们为你的 Vault
   服务器提供了极狐GitLab 实例的 [OIDC 发现 URL](https://openid.net/specs/openid-connect-discovery-1_0.html)，
   以便 Vault 可以在认证时获取公钥签名密钥并验证 JSON Web Token (JWT)：

   ```shell
   $ vault auth enable jwt

   $ vault write auth/jwt/config \
     oidc_discovery_url="https://gitlab.example.com" \
     bound_issuer="gitlab.example.com"
   ```

1. 在你的 Vault 服务器上配置策略，以授予或禁止对特定路径和操作的访问。此示例授予对生产环境所需密钥集的读取权限：

   ```shell
   vault policy write myproject-production - <<EOF
   # 对 'ops/data/production/*' 路径的只读权限

   path "ops/data/production/*" {
     capabilities = [ "read" ]
   }
   EOF
   ```

1. 在你的 Vault 服务器上配置[角色](#configure-server-roles)，将角色限制到项目或命名空间。
1. 创建以下 [CI/CD 变量](../variables/_index.md#for-a-project)以提供 Vault 服务器的详细信息：
   - `VAULT_SERVER_URL`：你的 Vault 服务器的 URL，例如 `https://vault.example.com:8200`。
   - `VAULT_AUTH_ROLE`：可选。尝试认证时要使用的角色。如果未指定角色，Vault 将使用配置认证方法时指定的[默认角色](https://developer.hashicorp.com/vault/api-docs/auth/jwt#default_role)。
   - `VAULT_AUTH_PATH`：可选。挂载认证方法的路径，默认为 `jwt`。
   - `VAULT_NAMESPACE`：可选。用于读取密钥和认证的 [Vault 企业版命名空间](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)。当未指定命名空间时：
     - Vault 使用 `root`（"`/`"）命名空间。
     - Vault 开源版将忽略此设置。
     - [HashiCorp Cloud Platform (HCP)](https://www.hashicorp.com/cloud) Vault 要求必须指定命名空间。HCP Vault 默认使用 `admin` 命名空间作为根命名空间。例如，`VAULT_NAMESPACE=admin`。

<a id="configure-server-roles"></a>

### 配置服务器角色

当 CI/CD 任务尝试认证时，它会指定一个角色。你可以使用角色将不同的策略组合在一起。如果认证成功，这些策略将被附加到生成的 Vault 令牌上。

[绑定声明](https://developer.hashicorp.com/vault/docs/auth/jwt#bound-claims)是预定义的值，用于与 JWT 声明进行匹配。通过绑定声明，你可以将访问权限限制到特定的极狐GitLab 用户、特定的项目，甚至是针对特定 Git 引用运行的任务。你可以根据需要设置任意数量的绑定声明，但它们都必须匹配才能使认证成功。

将绑定声明与极狐GitLab 的功能（例如[用户角色](../../user/permissions.md)和[受保护分支](../../user/project/repository/branches/protected.md)）结合使用，你可以定制这些规则以适应你的特定用例。在此示例中，仅允许那些为名称匹配生产发布模式且受保护的标签运行的任务进行认证：

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
    "project_id": "42",
    "ref_protected": "true",
    "ref_type": "tag",
    "ref": "auto-deploy-*"
  }
}
EOF
```

> [!warning]
> 始终通过使用提供的声明之一（例如 `project_id` 或 `namespace_id`）将你的角色限制到项目或命名空间。如果没有这些限制，此极狐GitLab 实例生成的任何 JWT 都可能被允许使用此角色进行认证。

有关 ID 令牌 JWT 声明的完整列表，请查阅
[在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥](hashicorp_vault_tutorial.md)教程。

你还可以为生成的 Vault 令牌指定一些属性，例如生存时间、IP 地址范围和使用次数。完整的选项列表可在[用于 JSON Web Token 方法的 Vault 创建角色文档](https://developer.hashicorp.com/vault/api-docs/auth/jwt#create-role)中找到。

## 在 CI/CD 任务中使用 Vault 密钥

当一个任务至少定义了一个 ID 令牌时，[`secrets`](../yaml/_index.md#secrets) 关键字会自动使用该令牌与 Vault 进行认证。

[配置你的 Vault 服务器](#configure-your-vault-server)之后，使用 [`secrets:vault`](../yaml/_index.md#secretsvault) 关键字来使用存储在 Vault 中的密钥：

```yaml
job_using_vault:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
    DATABASE_PASSWORD:
      vault: production/db/password@ops
      token: $VAULT_ID_TOKEN
```

在此示例中：

- `production/db` 是密钥的路径。
- `password` 是字段。
- `ops` 是挂载密钥引擎的路径。
- `production/db/password@ops` 转换为路径 `ops/data/production/db`。
- 使用 `$VAULT_ID_TOKEN` 进行认证。

在极狐GitLab 从 Vault 获取密钥后，该值将保存在一个临时文件中。该文件的路径将被存储在一个名为 `DATABASE_PASSWORD` 的 CI/CD 变量中，类似于[文件类型的变量](../variables/_index.md#use-file-type-cicd-variables)。

要覆盖默认行为，请显式设置 `file` 选项：

```yaml
secrets:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  DATABASE_PASSWORD:
    vault: production/db/password@ops
    file: false
    token: $VAULT_ID_TOKEN
```

在此示例中，密钥值被直接放入 `DATABASE_PASSWORD` 变量，而不是指向保存它的文件。

## 密钥引擎

{{< history >}}

- `generic` 选项在极狐GitLab Runner 16.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/366492)。

{{< /history >}}

极狐GitLab Runner 通过 [`secrets:engine:name`](../yaml/_index.md#secretsvault) 关键字支持不同的密钥引擎：

| 密钥引擎                                                                                                                                     | `secrets:engine:name` 值 | Runner 版本 | 详情 |
|---------------------------------------------------------------------------------------------------------------------------------------------|---------------------------|-------------|------|
| [KV 密钥引擎 - 版本 2](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2)                                                       | `kv-v2`                   | 13.4        | `kv-v2` 是未明确指定引擎类型时极狐GitLab Runner 使用的默认引擎。 |
| [KV 密钥引擎 - 版本 1](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v1)                                                       | `kv-v1` 或 `generic`       | 13.4        | 对 `generic` 关键字的支持在极狐GitLab 15.11 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/366492)。 |
| [AWS 密钥引擎](https://developer.hashicorp.com/vault/docs/secrets/aws)                                                                       | `generic`                 | 16.11       |         |
| [HashiCorp Vault Artifactory 密钥插件](https://jfrog.com/help/r/jfrog-integrations-documentation/hashicorp-vault-artifactory-secrets-plugin) | `generic`                 | 16.11       | 此后端密钥引擎与 JFrog Artifactory 服务器（5.0.0 或更高版本）通信，并动态配置具有指定范围的访问令牌。 |

### 使用不同的密钥引擎

默认使用 `kv-v2` 密钥引擎。要使用不同的引擎，请在配置中的 `vault` 下添加一个 `engine` 部分。

例如，为 Artifactory 设置密钥引擎和路径：

```yaml
job_using_vault:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  secrets:
    JFROG_TOKEN:
      vault:
        engine:
          name: generic
          path: artifactory
        path: production/jfrog
        field: access_token
      file: false
```

在此示例中，密钥值从 `artifactory/production/jfrog` 获取，字段为 `access_token`。

## 故障排除

<a id="self-signed-certificate-error-certificate-signed-by-unknown-authority"></a>

### 自签名证书错误：`certificate signed by unknown authority`

当 Vault 服务器使用自签名证书时，你会在任务日志中看到以下错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: initializing Vault service: preparing authenticated client: checking Vault server health: Get https://vault.example.com:8000/v1/sys/health?drsecondarycode=299&performancestandbycode=299&sealedcode=299&standbycode=299&uninitcode=299: x509: certificate signed by unknown authority
```

你有两种方法来解决此错误：

- 将自签名证书添加到 GitLab Runner 服务器的 CA 存储区。
  如果你使用 [Helm chart](https://docs.gitlab.com/runner/install/kubernetes/) 部署 GitLab Runner，则必须创建你自己的 GitLab Runner 镜像。
- 使用 `VAULT_CACERT` 环境变量配置 GitLab Runner 以信任该证书：
  - 如果你使用 systemd 管理 GitLab Runner，请参阅[如何为 GitLab Runner 添加环境变量](https://docs.gitlab.com/runner/configuration/init/#setting-custom-environment-variables)。
  - 如果你使用 [Helm chart](https://docs.gitlab.com/runner/install/kubernetes/) 部署 GitLab Runner：
    1. [提供用于访问极狐GitLab 的自定义证书](https://docs.gitlab.com/runner/install/kubernetes_helm_chart_configuration/#access-gitlab-with-a-custom-certificate)，
       并确保添加的是 Vault 服务器的证书，而不是极狐GitLab 的证书。
       如果你的极狐GitLab 实例也使用自签名证书，你应该能够将两者添加到同一个 `Secret` 中。
    1. 在你的 `values.yaml` 文件中添加以下行：

       ```yaml
       ## 将 <SECRET_NAME> 和 <VAULT_CERTIFICATE> 都替换为
       ## 你用于创建 secret 的实际值

       certsSecretName: <SECRET_NAME>

       envVars:
         - name: VAULT_CACERT
           value: "/home/gitlab-runner/.gitlab-runner/certs/<VAULT_CERTIFICATE>"
       ```

如果你使用[极狐GitLab Development Kit (GDK)](https://gitlab.com/gitlab-org/gitlab-development-kit) 在本地以开发模式运行 Vault 服务器，也可能会遇到此错误。你可以手动要求系统信任 Vault 服务器的自签名证书。这个[示例教程](https://iboysoft.com/tips/how-to-trust-a-certificate-on-mac.html)解释了如何在 macOS 上执行此操作。

<a id="resolving-secrets-secret-not-found-my-secret-error"></a>

### `resolving secrets: secret not found: MY_SECRET` 错误

当极狐GitLab 无法在 vault 中找到密钥时，你可能会收到此错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: secret not found: MY_SECRET
```

检查 `vault` 值在 CI/CD 任务中是否[配置正确](#use-vault-secrets-in-a-cicd-job)。

你可以使用 [`kv` 命令配合 Vault CLI](https://developer.hashicorp.com/vault/docs/commands/kv) 检查密钥是否可被检索，以帮助确定 CI/CD 配置中 `vault` 值的语法。例如，要检索密钥：

```shell
$ vault kv get -field=password -namespace=admin -mount=ops "production/db"
this-is-a-password
```