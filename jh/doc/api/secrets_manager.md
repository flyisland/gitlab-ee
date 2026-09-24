---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Secrets Manager API
description: 用于为极狐GitLab Secrets Manager 签发短期访问令牌的 REST API。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

使用此 API 可从非 CI/CD 工作负载访问[极狐GitLab Secrets Manager](../ci/secrets/secrets_manager/_index.md)中的密钥。

该 API 为项目或群组签发短期 JSON Web 令牌（JWT）。
客户端将此令牌提交给 OpenBao 后端以直接读取密钥，
方式与极狐GitLab Runner 在 CI/CD 作业期间读取密钥相同。
响应中包含客户端所需的 OpenBao 连接详情。

您需要使用具有 `api` 作用域的个人访问令牌、项目或群组访问令牌或服务账号令牌来调用此 API。
API 返回的令牌是独立的短期 OpenBao JWT，而非极狐GitLab 访问令牌。
该令牌在五分钟后过期。
读取密钥值还要求该主体拥有对应密钥的读取值（read value）权限。

要使用返回的连接详情读取密钥，请参阅
[从非 CI/CD 工作负载访问密钥](../ci/secrets/secrets_manager/non_cicd_access.md)。

<a id="create-a-secrets-manager-access-token-for-a-project"></a>

## 为项目创建 Secrets Manager 访问令牌

签发用于读取项目密钥的访问令牌。

```plaintext
POST /projects/:id/secrets_manager/access_token
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/secrets_manager/access_token"
```

示例响应：

```json
{
  "expires_at": "2026-05-27T10:35:00Z",
  "provider": {
    "vault": {
      "server": "https://secrets.gitlab.com",
      "namespace": "org_5/group_42/project_99",
      "path": "secrets/kv",
      "version": "v2",
      "secrets_path": "explicit",
      "auth": {
        "jwt": {
          "path": "api_jwt/cel",
          "role": "all_api",
          "token": "<JWT>"
        }
      }
    }
  }
}
```

响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `expires_at` | 字符串 | 令牌过期时的 ISO 8601 时间戳。令牌有效期为五分钟。 |
| `provider.vault.server` | 字符串 | 要连接的 OpenBao 服务器 URL。在 GitLab.com 上为 `https://secrets.gitlab.com`。在极狐GitLab 私有化部署上，则为该实例配置的 OpenBao URL。 |
| `provider.vault.namespace` | 字符串 | 保存项目密钥的 OpenBao 命名空间。请将其作为 `X-Vault-Namespace` 请求头传递。 |
| `provider.vault.path` | 字符串 | KV 密钥引擎的挂载路径。 |
| `provider.vault.version` | 字符串 | KV 密钥引擎的版本。 |
| `provider.vault.secrets_path` | 字符串 | KV 引擎下存储密钥的基础路径。将其添加到密钥名称前以构建读取路径（`<path>/data/<secrets_path>/<secret_name>`）。 |
| `provider.vault.auth.jwt.path` | 字符串 | JWT 认证方法的挂载路径。在 `auth/<path>/login` 进行认证。 |
| `provider.vault.auth.jwt.role` | 字符串 | 用于登录的 JWT 认证角色。 |
| `provider.vault.auth.jwt.token` | 字符串 | 客户端提交给 OpenBao 的短期 JWT。 |

<a id="create-a-secrets-manager-access-token-for-a-group"></a>

## 为群组创建 Secrets Manager 访问令牌

签发用于读取群组密钥的访问令牌。

```plaintext
POST /groups/:id/secrets_manager/access_token
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/secrets_manager/access_token"
```

示例响应：

```json
{
  "expires_at": "2026-05-27T10:35:00Z",
  "provider": {
    "vault": {
      "server": "https://secrets.gitlab.com",
      "namespace": "org_5/group_42/group_99",
      "path": "secrets/kv",
      "version": "v2",
      "secrets_path": "explicit",
      "auth": {
        "jwt": {
          "path": "api_jwt/cel",
          "role": "all_api",
          "token": "<JWT>"
        }
      }
    }
  }
}
```

响应属性与
[为项目创建 Secrets Manager 访问令牌](#create-a-secrets-manager-access-token-for-a-project)相同，
但 `provider.vault.namespace` 的范围限定为群组。
