---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户 SSH 和 GPG 密钥 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与用户的 [SSH 密钥](../user/ssh.md) 和 [GPG 密钥](../user/project/repository/signed_commits/gpg.md) 进行交互。

<a id="list-all-ssh-keys"></a>

## 列出所有 SSH 密钥

列出你用户账户的所有 SSH 密钥。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 对结果进行过滤。

先决条件：

- 你必须经过身份验证。

```plaintext
GET /user/keys
```

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/keys"
```

响应示例：

```json
[
  {
    "id": 1,
    "title": "公共密钥",
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt4596k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
    "created_at": "2014-08-01T14:47:39.080Z",
    "usage_type": "auth"
  },
  {
    "id": 3,
    "title": "另一个公共密钥",
    "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt4596k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
    "created_at": "2014-08-01T14:47:39.080Z",
    "usage_type": "signing"
  }
]
```

<a id="list-all-ssh-keys-for-a-user"></a>

## 列出用户的所有 SSH 密钥

列出指定用户账户的所有 SSH 密钥。此端点无需身份验证。

```plaintext
GET /users/:id_or_username/keys
```

支持的属性：

| 属性             | 类型   | 必需     | 描述                     |
|:-----------------|:-------|:---------|:-------------------------|
| `id_or_username` | string | 是       | 用户账户的 ID 或用户名   |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/1/keys"
```

<a id="retrieve-an-ssh-key"></a>

## 检索 SSH 密钥

检索你用户账户的 SSH 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
GET /user/keys/:key_id
```

支持的属性：

| 属性     | 类型   | 必需 | 描述               |
|:---------|:-------|:-----|:-------------------|
| `key_id` | string | 是   | 现有密钥的 ID      |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/keys/1"
```

响应示例：

```json
{
  "id": 1,
  "title": "公共密钥",
  "key": "<SSH_KEY>",
  "created_at": "2014-08-01T14:47:39.080Z",
  "usage_type": "auth"
}
```

<a id="retrieve-an-ssh-key-for-a-user"></a>

## 检索用户的 SSH 密钥

检索指定用户账户的 SSH 密钥。此端点无需身份验证。

```plaintext
GET /users/:id/keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述                     |
|:---------|:--------|:-----|:-------------------------|
| `id`     | integer | 是   | 用户账户的 ID 或用户名   |
| `key_id` | integer | 是   | 现有密钥的 ID            |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/users/1/keys/1"
```

响应示例：

```json
{
  "id": 1,
  "title": "公共密钥",
  "key": "<SSH_KEY>",
  "created_at": "2014-08-01T14:47:39.080Z",
  "usage_type": "auth"
}
```

<a id="add-an-ssh-key"></a>

## 添加 SSH 密钥

{{< history >}}

- `usage_type` 参数在极狐GitLab 15.7 中引入。

{{< /history >}}

为你用户账户添加 SSH 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
POST /user/keys
```

支持的属性：

| 属性         | 类型   | 必需     | 描述                                                         |
|:-------------|:-------|:---------|:-------------------------------------------------------------|
| `title`      | string | 是       | 密钥标题                                                     |
| `key`        | string | 是       | 公钥值                                                       |
| `expires_at` | string | 否       | 密钥的过期日期，ISO 格式（`YYYY-MM-DD`）                     |
| `usage_type` | string | 否       | 密钥的使用范围。可选值：`auth`、`signing` 或 `auth_and_signing`。默认值：`auth_and_signing` |

返回以下之一：

- 成功时返回状态 `201 Created` 和创建的密钥。
- 一个 `400 Bad Request` 错误，并附带解释错误的消息：

  ```json
  {
    "message": {
      "fingerprint": [
        "已被占用"
      ],
      "key": [
        "已被占用"
      ]
    }
  }
  ```

响应示例：

```json
{
  "title": "ABC",
  "key": "<SSH_KEY>",
  "expires_at": "2016-01-21T00:00:00.000Z",
  "usage_type": "auth"
}
```

<a id="add-an-ssh-key-for-a-user"></a>

## 为用户添加 SSH 密钥

{{< history >}}

- `usage_type` 参数在极狐GitLab 15.7 中引入。

{{< /history >}}

为指定用户账户添加 SSH 密钥。

> [!note]
> 此操作还会添加一个审计事件。

先决条件：

- 你必须拥有实例的管理员访问权限。

```plaintext
POST /users/:id/keys
```

支持的属性：

| 属性         | 类型    | 必需     | 描述                                                         |
|:-------------|:--------|:---------|:-------------------------------------------------------------|
| `id`         | integer | 是       | 用户账户的 ID                                                |
| `title`      | string  | 是       | 密钥标题                                                     |
| `key`        | string  | 是       | 公钥值                                                       |
| `expires_at` | string  | 否       | 密钥的过期日期，ISO 格式（`YYYY-MM-DD`）                     |
| `usage_type` | string  | 否       | 密钥的使用范围。可选值：`auth`、`signing` 或 `auth_and_signing`。默认值：`auth_and_signing` |

返回以下之一：

- 成功时返回状态 `201 Created` 和创建的密钥。
- 一个 `400 Bad Request` 错误，并附带解释错误的消息：

  ```json
  {
    "message": {
      "fingerprint": [
        "已被占用"
      ],
      "key": [
        "已被占用"
      ]
    }
  }
  ```

响应示例：

```json
{
  "title": "ABC",
  "key": "<SSH_KEY>",
  "expires_at": "2016-01-21T00:00:00.000Z",
  "usage_type": "auth"
}
```

<a id="delete-an-ssh-key"></a>

## 删除 SSH 密钥

从你用户账户中删除 SSH 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
DELETE /user/keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述               |
|:---------|:--------|:-----|:-------------------|
| `key_id` | integer | 是   | 现有密钥的 ID      |

返回以下之一：

- 如果操作成功，返回 `204 No Content` 状态码。
- 如果资源未找到，返回 `404` 状态码。

<a id="delete-an-ssh-key-for-a-user"></a>

## 删除用户的 SSH 密钥

从指定用户账户中删除 SSH 密钥。

先决条件：

- 你必须拥有实例的管理员访问权限。

```plaintext
DELETE /users/:id/keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述               |
|:---------|:--------|:-----|:-------------------|
| `id`     | integer | 是   | 用户账户的 ID      |
| `key_id` | integer | 是   | 现有密钥的 ID      |

<a id="list-all-gpg-keys"></a>

## 列出所有 GPG 密钥

列出你用户账户的所有 GPG 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
GET /user/gpg_keys
```

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/gpg_keys"
```

响应示例：

```json
[
  {
    "id": 1,
    "key": "<PGP_PUBLIC_KEY_BLOCK>",
    "created_at": "2017-09-05T09:17:46.264Z"
  }
]
```

<a id="list-all-gpg-keys-for-a-user"></a>

## 列出用户的所有 GPG 密钥

列出指定用户账户的所有 GPG 密钥。此端点无需身份验证。

```plaintext
GET /users/:id/gpg_keys
```

支持的属性：

| 属性 | 类型    | 必需 | 描述               |
|:-----|:--------|:-----|:-------------------|
| `id` | integer | 是   | 用户账户的 ID      |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/2/gpg_keys"
```

响应示例：

```json
[
  {
    "id": 1,
    "key": "<PGP_PUBLIC_KEY_BLOCK>",
    "created_at": "2017-09-05T09:17:46.264Z"
  }
]
```

<a id="retrieve-a-gpg-key"></a>

## 检索 GPG 密钥

检索你用户账户的 GPG 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
GET /user/gpg_keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述               |
|:---------|:--------|:-----|:-------------------|
| `key_id` | integer | 是   | 现有密钥的 ID      |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/gpg_keys/1"
```

响应示例：

```json
{
  "id": 1,
  "key": "<PGP_PUBLIC_KEY_BLOCK>",
  "created_at": "2017-09-05T09:17:46.264Z"
}
```

<a id="retrieve-a-gpg-key-for-a-user"></a>

## 检索用户的 GPG 密钥

检索指定用户账户的 GPG 密钥。此端点无需身份验证。

```plaintext
GET /users/:id/gpg_keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述               |
|:---------|:--------|:-----|:-------------------|
| `id`     | integer | 是   | 用户账户的 ID      |
| `key_id` | integer | 是   | 现有密钥的 ID      |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/2/gpg_keys/1"
```

响应示例：

```json
{
  "id": 1,
  "key": "<PGP_PUBLIC_KEY_BLOCK>",
  "created_at": "2017-09-05T09:17:46.264Z"
}
```

<a id="add-a-gpg-key"></a>

## 添加 GPG 密钥

为你用户账户添加 GPG 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
POST /user/gpg_keys
```

支持的属性：

| 属性   | 类型   | 必需 | 描述     |
|:-------|:-------|:-----|:---------|
| `key`  | string | 是   | 公钥值   |

请求示例：

```shell
export KEY="$(gpg --armor --export <your_gpg_key_id>)"

curl --data-urlencode "key=<PGP_PUBLIC_KEY_BLOCK>" \
     --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/user/gpg_keys"
```

响应示例：

```json
[
  {
    "id": 1,
    "key": "<PGP_PUBLIC_KEY_BLOCK>",
    "created_at": "2017-09-05T09:17:46.264Z"
  }
]
```

<a id="add-a-gpg-key-for-a-user"></a>

## 为用户添加 GPG 密钥

为指定用户账户添加 GPG 密钥。

先决条件：

- 你必须拥有实例的管理员访问权限。

```plaintext
POST /users/:id/gpg_keys
```

支持的属性：

| 属性 | 类型    | 必需 | 描述               |
|:-----|:--------|:-----|:-------------------|
| `id` | integer | 是   | 用户账户的 ID      |
| `key`| integer | 是   | 公钥值             |

请求示例：

```shell
curl --data-urlencode "key=<PGP_PUBLIC_KEY_BLOCK>" \
     --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/users/2/gpg_keys"
```

响应示例：

```json
[
  {
    "id": 1,
    "key": "<PGP_PUBLIC_KEY_BLOCK>",
    "created_at": "2017-09-05T09:17:46.264Z"
  }
]
```

<a id="delete-a-gpg-key"></a>

## 删除 GPG 密钥

从你用户账户中删除 GPG 密钥。

先决条件：

- 你必须经过身份验证。

```plaintext
DELETE /user/gpg_keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述               |
|:---------|:--------|:-----|:-------------------|
| `key_id` | integer | 是   | 现有密钥的 ID      |

返回以下之一：

- 成功时返回 `204 No Content`。
- 如果找不到密钥，返回 `404 Not Found`。

<a id="delete-a-gpg-key-for-a-user"></a>

## 删除用户的 GPG 密钥

从指定用户账户中删除 GPG 密钥。

先决条件：

- 你必须拥有实例的管理员访问权限。

```plaintext
DELETE /users/:id/gpg_keys/:key_id
```

支持的属性：

| 属性     | 类型    | 必需 | 描述               |
|:---------|:--------|:-----|:-------------------|
| `id`     | integer | 是   | 用户账户的 ID      |
| `key_id` | integer | 是   | 现有密钥的 ID      |