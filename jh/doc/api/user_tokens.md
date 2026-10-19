---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户令牌 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与个人访问令牌和模拟令牌进行交互。更多信息，请参见[个人访问令牌](../user/profile/personal_access_tokens.md)和[模拟令牌](rest/authentication.md#impersonation-tokens)。

<a id="create-a-personal-access-token-for-a-user"></a>

## 为用户创建个人访问令牌

为指定用户创建个人访问令牌。

令牌值会包含在响应中，但之后无法再获取。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
POST /users/:user_id/personal_access_tokens
```

支持的属性：

| 属性    | 类型    | 必需 | 描述 |
|:-------------|:--------|:---------|:------------|
| `user_id`    | integer | 是      | 用户账号的 ID。 |
| `name`       | string  | 是      | 个人访问令牌的名称。 |
| `description`| string  | 否       | 个人访问令牌的描述。最大长度：255 个字符。 |
| `expires_at` | date    | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果未定义且令牌需要过期日期，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。如果不需要，则该令牌没有过期日期。 |
| `scopes`     | array   | 是      | 已批准范围的数组。有关可能值的列表，请参见[访问令牌范围](../security/tokens/access_token_scopes.md)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "name=mytoken" --data "expires_at=2017-04-04" \
  --data "scopes[]=api" \
  --url "https://gitlab.example.com/api/v4/users/42/personal_access_tokens"
```

示例响应：

```json
{
    "id": 3,
    "name": "mytoken",
    "revoked": false,
    "created_at": "2020-10-14T11:58:53.526Z",
    "description": "Test Token description",
    "scopes": [
        "api"
    ],
    "user_id": 42,
    "last_used_ips": [],
    "active": true,
    "expires_at": "2020-12-31",
    "token": "<your_new_access_token>"
}
```

<a id="create-a-personal-access-token"></a>

## 创建个人访问令牌

为您的账号创建个人访问令牌。出于安全考虑，该令牌：

- 仅限于 [`k8s_proxy` 和 `self_rotate` 范围](../security/tokens/access_token_scopes.md)。

令牌值会包含在响应中，但之后无法再获取。

先决条件：

- 您必须已通过身份验证。

```plaintext
POST /user/personal_access_tokens
```

支持的属性：

| 属性    | 类型   | 必需 | 描述 |
|:-------------|:-------|:---------|:------------|
| `name`       | string | 是      | 个人访问令牌的名称。 |
| `description`| string | 否       | 个人访问令牌的描述。最大长度：255 个字符。 |
| `scopes`     | array  | 是      | 已批准范围的数组。仅接受 `k8s_proxy` 和 `self_rotate`。 |
| `expires_at` | date  | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果未定义且令牌需要过期日期，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。如果不需要，则该令牌没有过期日期。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "name=mytoken" --data "scopes[]=k8s_proxy" \
  --url "https://gitlab.example.com/api/v4/user/personal_access_tokens"
```

示例响应：

```json
{
    "id": 3,
    "name": "mytoken",
    "revoked": false,
    "created_at": "2020-10-14T11:58:53.526Z",
    "description": "Test Token description",
    "scopes": [
        "k8s_proxy"
    ],
    "user_id": 42,
    "last_used_ips": [],
    "active": true,
    "expires_at": "2020-10-15",
    "token": "<your_new_access_token>"
}
```

<a id="list-all-impersonation-tokens-for-a-user"></a>

## 列出用户的所有模拟令牌

列出指定用户的所有模拟令牌。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)筛选结果。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
GET /users/:user_id/impersonation_tokens
```

支持的属性：

| 属性 | 类型    | 必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `user_id` | integer | 是      | 用户账号的 ID |
| `state`   | string  | 否       | 根据状态筛选令牌。可能的值：`all`、`active` 或 `inactive`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/impersonation_tokens"
```

示例响应：

```json
[
   {
      "active" : true,
      "user_id" : 2,
      "scopes" : [
         "api"
      ],
      "revoked" : false,
      "name" : "mytoken",
      "description": "Test Token description",
      "id" : 2,
      "created_at" : "2017-03-17T17:18:09.283Z",
      "impersonation" : true,
      "expires_at" : "2017-04-04",
      "last_used_at": "2017-03-24T09:44:21.722Z",
      "last_used_ips": ["192.0.2.10"]
   },
   {
      "active" : false,
      "user_id" : 2,
      "scopes" : [
         "read_user"
      ],
      "revoked" : true,
      "name" : "mytoken2",
      "description": "Test Token description",
      "created_at" : "2017-03-17T17:19:28.697Z",
      "id" : 3,
      "impersonation" : true,
      "expires_at" : "2017-04-14",
      "last_used_at": "2017-03-24T09:44:21.722Z",
      "last_used_ips": ["192.0.2.11"]
   }
]
```

<a id="retrieve-an-impersonation-token-for-a-user"></a>

## 检索用户的模拟令牌

检索指定用户的模拟令牌。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
GET /users/:user_id/impersonation_tokens/:impersonation_token_id
```

支持的属性：

| 属性                | 类型    | 必需 | 描述 |
|:-------------------------|:--------|:---------|:------------|
| `user_id`                | integer | 是      | 用户账号的 ID |
| `impersonation_token_id` | integer | 是      | 模拟令牌的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/impersonation_tokens/2"
```

示例响应：

```json
{
   "active" : true,
   "user_id" : 2,
   "scopes" : [
      "api"
   ],
   "revoked" : false,
   "name" : "mytoken",
   "description": "Test Token description",
   "id" : 2,
   "created_at" : "2017-03-17T17:18:09.283Z",
   "impersonation" : true,
   "expires_at" : "2017-04-04",
   "last_used_ips": ["192.0.2.10"]
}
```

<a id="create-an-impersonation-token"></a>

## 创建模拟令牌

为指定用户创建模拟令牌。这些令牌用于代表用户执行操作，可以执行 API 调用以及 Git 读写操作。这些令牌在关联用户的个人资料设置页面上不可见。

令牌值会包含在响应中，但之后无法再获取。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
POST /users/:user_id/impersonation_tokens
```

支持的属性：

| 属性    | 类型    | 必需 | 描述 |
|:-------------|:--------|:---------|:------------|
| `user_id`    | integer | 是      | 用户账号的 ID |
| `name`       | string  | 是      | 模拟令牌的名称 |
| `description`| string  | 否       | 模拟令牌的描述 |
| `expires_at` | date    | 是      | 模拟令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果未定义，则日期设置为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |
| `scopes`     | array   | 是      | 已批准范围的数组。有关可能值的列表，请参见[访问令牌范围](../security/tokens/access_token_scopes.md)。  |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "name=mytoken" --data "expires_at=2017-04-04" \
  --data "scopes[]=api" \
  --url "https://gitlab.example.com/api/v4/users/42/impersonation_tokens"
```

示例响应：

```json
{
   "id" : 2,
   "revoked" : false,
   "user_id" : 2,
   "scopes" : [
      "api"
   ],
   "token" : "<impersonation_token>",
   "active" : true,
   "impersonation" : true,
   "name" : "mytoken",
   "description": "Test Token description",
   "created_at" : "2017-03-17T17:18:09.283Z",
   "expires_at" : "2017-04-04",
   "last_used_ips": []
}
```

<a id="revoke-an-impersonation-token"></a>

## 撤销模拟令牌

撤销指定用户的模拟令牌。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
DELETE /users/:user_id/impersonation_tokens/:impersonation_token_id
```

支持的属性：

| 属性                | 类型    | 必需 | 描述 |
|:-------------------------|:--------|:---------|:------------|
| `user_id`                | integer | 是      | 用户账号的 ID |
| `impersonation_token_id` | integer | 是      | 模拟令牌的 ID |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/impersonation_tokens/1"
```
