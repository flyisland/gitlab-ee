---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例 SSH 证书 API
description: 用于列出、添加和删除实例 SSH 证书颁发机构公钥的 REST API。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

使用此 API 管理实例信任的 SSH 证书颁发机构（CA）公钥。极狐GitLab 将每个 CA 公钥存储在数据库中，并在整个实例范围内信任它，因此您可以通过 API 调用轮换 CA，而无需更改 `sshd_config` 或 `gitlab-sshd` 配置文件。有关基于文件的替代方案，请参阅[使用 `gitlab-sshd`的实例级 SSH 证书](../administration/operations/gitlab_sshd_ssh_certificates.md)。

`key` 属性包含 CA 公钥，而不是私钥或已签名的用户证书。

<a id="authentication-and-availability"></a>

## 身份验证和可用性

所有端点都要求管理员通过
[REST API](rest/authentication.md) 进行身份验证。
如果实例启用了管理员模式，则适用现有的[管理员模式要求](../administration/settings/sign_in_restrictions.md#admin-mode)，包括个人访问令牌或 OAuth 令牌的 `admin_mode` 范围。

极狐GitLab 会在检查功能可用性之前先检查身份验证和管理员访问权限。以下错误适用于所有端点，即使功能标志已禁用也是如此：

| 状态 | 描述 |
|--------|-------------|
| `401 Unauthorized` | 请求未经过身份验证。 |
| `403 Forbidden` | 已通过身份验证的用户没有管理员访问权限。 |
| `404 Not Found` | 用户具有管理员访问权限，但该功能不可用。 |

<a id="list-all-instance-ssh-certificates"></a>

## 列出所有实例 SSH 证书

按 ID 降序列出所有实例 SSH CA 公钥记录。

```plaintext
GET /admin/ssh_certificates
```

此端点支持标准[分页](rest/_index.md#offset-based-pagination)。

| 属性 | 类型 | 必需 | 描述 |
|-----------|------|----------|-------------|
| `page` | integer | 否 | 要检索的页码。默认值：`1`。 |
| `per_page` | integer | 否 | 每页的记录数。默认值：`20`。最大值：`100`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及一个包含以下响应属性的对象数组：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `created_at` | string | 记录的创建日期和时间，采用 ISO 8601 格式。 |
| `fingerprint` | string | SSH CA 公钥的 SHA256 指纹。 |
| `id` | integer | 实例 SSH 证书记录的 ID。 |
| `key` | string | SSH CA 公钥。 |
| `title` | string | 记录的标题。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ssh_certificates?page=1&per_page=20"
```

示例响应（`<ca_public_key>` 表示完整的 SSH CA 公钥）：

```json
[
  {
    "id": 2,
    "title": "Engineering CA",
    "key": "<ca_public_key>",
    "fingerprint": "<ca_public_key_fingerprint>",
    "created_at": "2026-09-08T12:39:00.172Z"
  },
  {
    "id": 1,
    "title": "Operations CA",
    "key": "<ca_public_key>",
    "fingerprint": "<ca_public_key_fingerprint>",
    "created_at": "2026-09-08T11:30:00.000Z"
  }
]
```

空结果返回 `[]`。

<a id="add-an-instance-ssh-certificate"></a>

## 添加实例 SSH 证书

添加一条实例 SSH CA 公钥记录。

```plaintext
POST /admin/ssh_certificates
```

| 属性 | 类型 | 必需 | 描述 |
|-----------|------|----------|-------------|
| `key` | string | 是 | SSH CA 公钥。不能为空。最大长度：5,000 个字符。 |
| `title` | string | 是 | 记录的标题。不能为空。最大长度：255 个字符。 |

如果成功，则返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `created_at` | string | 记录的创建日期和时间，采用 ISO 8601 格式。 |
| `fingerprint` | string | SSH CA 公钥的 SHA256 指纹。 |
| `id` | integer | 实例 SSH 证书记录的 ID。 |
| `key` | string | SSH CA 公钥。 |
| `title` | string | 记录的标题。 |

示例请求，其中 CA 公钥位于 `/path/to/ca_key.pub`：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data-urlencode "title=Engineering CA" \
  --data-urlencode "key@/path/to/ca_key.pub" \
  --url "https://gitlab.example.com/api/v4/admin/ssh_certificates"
```

示例响应：

```json
{
  "id": 2,
  "title": "Engineering CA",
  "key": "<ca_public_key>",
  "fingerprint": "<ca_public_key_fingerprint>",
  "created_at": "2026-09-08T12:39:00.172Z"
}
```

除了共有的身份验证和可用性错误之外，此端点还可能返回：

| 状态 | 描述 |
|--------|-------------|
| `400 Bad Request` | 缺少必需参数，或者 `title` 或 `key` 超出其最大长度。 |
| `422 Unprocessable Entity` | 某个值为空或无效。密钥指纹重复，或者密钥被 [SSH 密钥限制](../security/ssh_keys_restrictions.md)或联邦信息处理标准（FIPS）限制拒绝时，也会返回此错误。 |

<a id="delete-an-instance-ssh-certificate"></a>

## 删除实例 SSH 证书

删除指定的实例 SSH CA 公钥记录。

```plaintext
DELETE /admin/ssh_certificates/:id
```

| 属性 | 类型 | 必需 | 描述 |
|-----------|------|----------|-------------|
| `id` | integer | 是 | 实例 SSH 证书记录的 ID。 |

如果成功，则返回 [`204 No Content`](rest/troubleshooting.md#status-codes)，响应正文为空且没有响应属性。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/ssh_certificates/2"
```

除了共有的身份验证和可用性错误之外，此端点还可能返回：

| 状态 | 描述 |
|--------|-------------|
| `404 Not Found` | 没有具有指定 ID 的实例 SSH 证书记录。 |
| `422 Unprocessable Entity` | 极狐GitLab 无法删除该记录。 |
