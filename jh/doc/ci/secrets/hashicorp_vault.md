---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "了解如何在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥，包括身份验证、Vault 配置、策略和密钥引擎。"
title: '在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥。使用 [ID 令牌](id_token_authentication.md)
来[通过 HashiCorp Vault 进行身份验证](https://developer.hashicorp.com/vault/docs/auth/jwt#jwt-authentication)。

在 CI/CD 作业中使用 Vault 密钥之前，必须先配置 Vault 服务器。
[使用 HashiCorp Vault 进行身份验证和读取密钥](hashicorp_vault_tutorial.md)
教程详细介绍了如何配置 Vault 以及使用 ID 令牌进行身份验证。

在以下示例中，将 `vault.example.com` 替换为您的 Vault 服务器 URL，将 `gitlab.example.com` 替换为您的极狐GitLab 实例 URL。

<a id="configure-your-vault-server"></a>

## 配置 Vault 服务器

要配置 Vault 服务器：

1. 运行以下命令以启用身份验证方法。这些命令会为您的 Vault
   服务器提供极狐GitLab 实例的 [OIDC 发现 URL](https://openid.net/specs/openid-connect-discovery-1_0.html)，
   以便 Vault 在身份验证时能够获取公共签名密钥并验证
   JSON Web Token (JWT)：

   ```shell
   $ vault auth enable jwt

   $ vault write auth/jwt/config \
     oidc_discovery_url="https://gitlab.example.com" \
     bound_issuer="gitlab.example.com"
   ```

1. 在 Vault 服务器上配置策略，以授予或禁止对特定
   路径和操作的访问权限。此示例授予对生产环境所需
   密钥集的读取权限：

   ```shell
   vault policy write myproject-production - <<EOF
   # Read-only permission on 'ops/data/production/*' path

   path "ops/data/production/*" {
     capabilities = [ "read" ]
   }
   EOF
   ```

1. [在 Vault 服务器上配置角色](#configure-server-roles)，将角色限制到某个项目或命名空间。
1. 创建以下 [CI/CD 变量](../variables/_index.md#for-a-project)
   以提供 Vault 服务器的详细信息：
   - `VAULT_SERVER_URL`：您的 Vault 服务器 URL，例如 `https://vault.example.com:8200`。
   - `VAULT_AUTH_ROLE`：可选。尝试进行身份验证时要使用的角色。
     如果未指定角色，Vault 会使用配置身份验证方法时指定的
     [默认角色](https://developer.hashicorp.com/vault/api-docs/auth/jwt#default_role)。
   - `VAULT_AUTH_PATH`：可选。挂载身份验证方法的路径，默认为 `jwt`。
   - `VAULT_NAMESPACE`：可选。用于读取密钥和进行身份验证的
     [Vault Enterprise 命名空间](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)。具体如下：
     - Vault 中，未指定命名空间时使用 `root`（"`/`"）命名空间。
     - Vault 开源版中，该设置会被忽略。
     - [HashiCorp Cloud Platform (HCP)](https://www.hashicorp.com/cloud) Vault 中，
       必须指定命名空间。HCP Vault 默认使用 `admin` 命名空间作为根命名空间。
       例如，`VAULT_NAMESPACE=admin`。

<a id="configure-server-roles"></a>

### 配置服务器角色

当 CI/CD 作业尝试进行身份验证时，它会指定一个角色。您可以使用角色将不同的策略组合在一起。如果身份验证成功，这些策略会附加到生成的 Vault 令牌上。

[绑定声明](https://developer.hashicorp.com/vault/docs/auth/jwt#bound-claims)是与 JWT 声明匹配的预定义值。通过绑定声明，您可以将访问权限限制为特定的极狐GitLab 用户、特定项目，甚至是为特定 Git 引用运行的作业。您可以根据需要设置任意数量的绑定声明，但它们必须全部匹配才能成功进行身份验证。

将绑定声明与[用户角色](../../user/permissions.md)和[受保护分支](../../user/project/repository/branches/protected.md)等极狐GitLab 功能结合使用，您可以根据具体用例定制这些规则。在此示例中，仅允许为名称与生产发布所用模式匹配的受保护标签运行的作业进行身份验证：

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
> 请始终使用提供的声明（如 `project_id` 或 `namespace_id`）将角色限制到某个项目或命名空间。
> 如果没有这些限制，此极狐GitLab 实例生成的任何 JWT
> 都可能被允许使用此角色进行身份验证。

有关 ID 令牌 JWT 声明的完整列表，请查看
[在极狐GitLab CI/CD 中使用 HashiCorp Vault 密钥](hashicorp_vault_tutorial.md)教程。

您还可以为生成的 Vault 令牌指定一些属性，例如生存时间、IP 地址范围和使用次数。完整选项列表请参见 [Vault 关于创建角色的文档](https://developer.hashicorp.com/vault/api-docs/auth/jwt#create-role)
中关于 JSON Web Token 方法的部分。

<a id="use-vault-secrets-in-a-cicd-job"></a>

## 在 CI/CD 作业中使用 Vault 密钥

当作业至少定义了一个 ID 令牌时，[`secrets`](../yaml/_index.md#secrets) 关键字会自动使用该令牌向 Vault 进行身份验证。

[配置 Vault 服务器](#configure-your-vault-server)后，使用 [`secrets:vault`](../yaml/_index.md#secretsvault) 关键字来使用存储在 Vault 中的密钥：

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
- 使用 `$VAULT_ID_TOKEN` 进行身份验证。

极狐GitLab 从 Vault 获取密钥后，该值会保存在一个临时文件中。此文件的路径存储在名为 `DATABASE_PASSWORD`的 CI/CD 变量中，类似于 [`file` 类型的变量](../variables/_index.md#use-file-type-cicd-variables)。

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

在此示例中，密钥值会直接放入 `DATABASE_PASSWORD` 变量，而不是指向保存该值的文件。

<a id="secrets-engines"></a>

## 密钥引擎

极狐GitLab Runner 通过 [`secrets:engine:name`](../yaml/_index.md#secretsvault) 关键字支持不同的密钥引擎：

| 密钥引擎                                                                                                                                     | `secrets:engine:name` 值 | 详细信息 |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | ------- |
| [KV 密钥引擎 - 版本 2](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2)                                                       | `kv-v2`                     | 未显式指定引擎类型时，`kv-v2` 是极狐GitLab Runner 使用的默认引擎。 |
| [KV 密钥引擎 - 版本 1](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v1)                                                       | `kv-v1` 或 `generic`        |         |
| [AWS 密钥引擎](https://developer.hashicorp.com/vault/docs/secrets/aws)                                                                       | `generic`                   |         |
| [HashiCorp Vault Artifactory 密钥插件](https://jfrog.com/help/r/jfrog-integrations-documentation/hashicorp-vault-artifactory-secrets-plugin) | `generic`                   | 与 JFrog Artifactory 服务器 5.0.0 或更高版本通信，并动态预配具有指定范围的访问令牌。 |

<a id="use-a-different-secrets-engine"></a>

### 使用其他密钥引擎

默认使用 `kv-v2` 密钥引擎。要使用其他引擎，请在配置中的 `vault` 下添加 `engine` 部分。

例如，要为 Artifactory 设置密钥引擎和路径：

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

<a id="troubleshooting"></a>

## 故障排除

<a id="self-signed-certificate-error-certificate-signed-by-unknown-authority"></a>

### 自签名证书错误：`certificate signed by unknown authority`

当 Vault 服务器使用自签名证书时，您会在作业日志中看到以下错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: initializing Vault service: preparing authenticated client: checking Vault server health: Get https://vault.example.com:8000/v1/sys/health?drsecondarycode=299&performancestandbycode=299&sealedcode=299&standbycode=299&uninitcode=299: x509: certificate signed by unknown authority
```

您有两种方法可以解决此错误：

- 将自签名证书添加到极狐GitLab Runner 服务器的 CA 存储中。
  如果您使用 [Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/) 部署了极狐GitLab Runner，则必须创建自己的极狐GitLab Runner 镜像。
- 使用 `VAULT_CACERT` 环境变量将极狐GitLab Runner 配置为信任该证书：
  - 如果您使用 systemd 管理极狐GitLab Runner，请参见[如何为极狐GitLab Runner 添加环境变量](https://gitlab.cn/docs/runner/configuration/init/#setting-custom-environment-variables)。
  - 如果您使用 [Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/) 部署了极狐GitLab Runner：
    1. [提供用于访问极狐GitLab 的自定义证书](https://gitlab.cn/docs/runner/install/kubernetes_helm_chart_configuration/#access-gitlab-with-a-custom-certificate)，
       并确保添加的是 Vault 服务器的证书，而不是极狐GitLab 的证书。
       如果您的极狐GitLab 实例也使用自签名证书，您可以在同一个 `Secret`中
       添加两者。
    1. 在 `values.yaml` 文件中添加以下行：

       ```yaml
       ## Replace both the <SECRET_NAME> and the <VAULT_CERTIFICATE>
       ## with the actual values you used to create the secret

       certsSecretName: <SECRET_NAME>

       envVars:
         - name: VAULT_CACERT
           value: "/home/gitlab-runner/.gitlab-runner/certs/<VAULT_CERTIFICATE>"
       ```

如果您在本地使用 [GitLab Development Kit (GDK)](https://gitlab.com/gitlab-org/gitlab-development-kit)
以开发模式运行 Vault 服务器，也可能会遇到此错误。您可以手动让系统信任 Vault 服务器的自签名证书。这篇[示例教程](https://iboysoft.com/tips/how-to-trust-a-certificate-on-mac.html)介绍了如何在 macOS 上执行此操作。

<a id="resolving-secrets-secret-not-found-my_secret-error"></a>

### `resolving secrets: secret not found: MY_SECRET` 错误

当极狐GitLab 无法在 Vault 中找到该密钥时，您可能会收到此错误：

```plaintext
ERROR: Job failed (system failure): resolving secrets: secret not found: MY_SECRET
```

检查 `vault` 值是否[已在 CI/CD 作业中正确配置](#use-vault-secrets-in-a-cicd-job)。

您可以使用 [Vault CLI 的 `kv` 命令](https://developer.hashicorp.com/vault/docs/commands/kv)来检查该密钥是否可检索，以帮助确定 CI/CD 配置中 `vault` 值的语法。例如，要检索该密钥：

```shell
$ vault kv get -field=password -namespace=admin -mount=ops "production/db"
this-is-a-password
```
