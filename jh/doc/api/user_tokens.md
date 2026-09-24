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

## 为用户创建个人访问令牌

{{< history >}}

- `expires_at` 属性默认值在极狐GitLab 16.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/120213)。

{{< /history >}}

为指定用户创建个人访问令牌。

令牌值会包含在响应中，但之后无法再次获取。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
POST /users/:user_id/personal_access_tokens
```

支持的属性：

| 属性          | 类型    | 是否必需 | 描述 |
|:-------------|:--------|:---------|:------------|
| `user_id`    | integer | 是      | 用户帐户的 ID。 |
| `name`       | string  | 是      | 个人访问令牌的名称。 |
| `description`| string  | 否       | 个人访问令牌的描述。最大长度：255 个字符。 |
| `expires_at` | date    | 否       | 访问令牌的过期日期，采用 ISO 格式 (`YYYY-MM-DD`)。如果未定义，日期将设置为[最大允许生存期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |
| `scopes`     | array   | 是      | 批准的权限范围数组。有关可能值的列表，请参见[个人访问令牌范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。 |

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
    "description": "测试令牌描述",
    "scopes": [
        "api"
    ],
    "user_id": 42,
    "active": true,
    "expires_at": "2020-12-31",
    "token": "<your_new_access_token>"
}
```

## 创建个人访问令牌

{{< history >}}

- [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/131923)于极狐GitLab 16.5。

{{< /history >}}

为您自己的帐户创建个人访问令牌。出于安全目的，该令牌：

- 仅限于 [`k8s_proxy` 和 `self_rotate` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。

令牌值会包含在响应中，但之后无法再次获取。

先决条件：

- 您必须已通过身份验证。

```plaintext
POST /user/personal_access_tokens
```

支持的属性：

| 属性          | 类型   | 是否必需 | 描述 |
|:-------------|:-------|:---------|:------------|
| `name`       | string | 是      | 个人访问令牌的名称。 |
| `description`| string | 否       | 个人访问令牌的描述。最大长度：255 个字符。 |
| `scopes`     | array  | 是      | 批准的权限范围数组。仅接受 `k8s_proxy` 和 `self_rotate`。 |
| `expires_at` | date  | 否       | 访问令牌的过期日期，采用 ISO 格式 (`YYYY-MM-DD`)。如果未定义，日期将设置为[最大允许生存期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

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
    "description": "测试令牌描述",
    "scopes": [
        "k8s_proxy"
    ],
    "user_id": 42,
    "active": true,
    "expires_at": "2020-10-15",
    "token": "<your_new_access_token>"
}
```

## 列出用户的所有模拟令牌

列出指定用户的所有模拟令牌。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)来过滤结果。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
GET /users/:user_id/impersonation_tokens
```

支持的属性：

| 属性       | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `user_id` | integer | 是      | 用户帐户的 ID |
| `state`   | string  | 否       | 根据状态过滤令牌。可能的值：`all`、`active` 或 `inactive`。 |

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
      "description": "测试令牌描述",
      "id" : 2,
      "created_at" : "2017-03-17T17:18:09.283Z",
      "impersonation" : true,
      "expires_at" : "2017-04-04",
      "last_used_at": "2017-03-24T09:44:21.722Z"
   },
   {
      "active" : false,
      "user_id" : 2,
      "scopes" : [
         "read_user"
      ],
      "revoked" : true,
      "name" : "mytoken2",
      "description": "测试令牌描述",
      "created_at" : "2017-03-17T17:19:28.697Z",
      "id" : 3,
      "impersonation" : true,
      "expires_at" : "2017-04-14",
      "last_used_at": "2017-03-24T09:44:21.722Z"
   }
]
```

## 获取用户的模拟令牌

获取指定用户的模拟令牌。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
GET /users/:user_id/impersonation_tokens/:impersonation_token_id
```

支持的属性：

| 属性                      | 类型    | 是否必需 | 描述 |
|:-------------------------|:--------|:---------|:------------|
| `user_id`                | integer | 是      | 用户帐户的 ID |
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
   "description": "测试令牌描述",
   "id" : 2,
   "created_at" : "2017-03-17T17:18:09.283Z",
   "impersonation" : true,
   "expires_at" : "2017-04-04"
}
```

## 创建模拟令牌

为指定用户创建模拟令牌。这些令牌用于代表用户执行操作，并且可以执行 API 调用以及 Git 读取和写入操作。这些令牌对于关联用户在其个人资料设置页面上是不可见的。

令牌值会包含在响应中，但之后无法再次获取。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
POST /users/:user_id/impersonation_tokens
```

支持的属性：

| 属性          | 类型    | 是否必需 | 描述 |
|:-------------|:--------|:---------|:------------|
| `user_id`    | integer | 是      | 用户帐户的 ID |
| `name`       | string  | 是      | 模拟令牌的名称 |
| `description`| string  | 否       | 模拟令牌的描述 |
| `expires_at` | date    | 是      | 模拟令牌的过期日期，采用 ISO 格式 (`YYYY-MM-DD`)。如果未定义，日期将设置为[最大允许生存期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |
| `scopes`     | array   | 是      | 批准的权限范围数组。有关可能值的列表，请参见[个人访问令牌范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。 |

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
   "description": "测试令牌描述",
   "created_at" : "2017-03-17T17:18:09.283Z",
   "expires_at" : "2017-04-04"
}
```

## 撤销模拟令牌

撤销指定用户的模拟令牌。

先决条件：

- 您必须具有实例的管理员访问权限。

```plaintext
DELETE /users/:user_id/impersonation_tokens/:impersonation_token_id
```

支持的属性：

| 属性                      | 类型    | 是否必需 | 描述 |
|:-------------------------|:--------|:---------|:------------|
| `user_id`                | integer | 是      | 用户帐户的 ID |
| `impersonation_token_id` | integer | 是      | 模拟令牌的 ID |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/42/impersonation_tokens/1"
```