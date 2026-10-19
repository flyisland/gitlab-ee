---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组访问令牌 API
description: 用于列出、获取、创建、轮换、自行轮换和撤销群组访问令牌的 API。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与群组访问令牌交互。更多信息，请参见[群组访问令牌](../user/group/settings/group_access_tokens.md)。

<a id="list-all-group-access-tokens"></a>

## 列出所有群组访问令牌

列出指定群组的所有群组访问令牌。

```plaintext
GET /groups/:id/access_tokens
GET /groups/:id/access_tokens?state=inactive
```

| 属性          | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果已定义，则返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果已定义，则返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 如果已定义，则返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 如果已定义，则返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果已定义，则返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果已定义，则返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果已定义，则返回名称中包含指定值的令牌。 |
| `sort`             | string              | 否       | 如果已定义，则按指定值对结果排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。|
| `state`            | string              | 否       | 如果已定义，则返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens"
```

```json
[
   {
      "user_id" : 141,
      "scopes" : [
         "api"
      ],
      "name" : "token",
      "expires_at" : "2021-01-31",
      "id" : 42,
      "active" : true,
      "created_at" : "2021-01-20T22:11:48.151Z",
      "description": "Test Token description",
      "revoked" : false,
      "last_used_at": null,
      "last_used_ips": [],
      "access_level": 40
   },
   {
      "user_id" : 141,
      "scopes" : [
         "read_api"
      ],
      "name" : "token-2",
      "expires_at" : "2021-01-31",
      "id" : 43,
      "active" : false,
      "created_at" : "2021-01-21T12:12:38.123Z",
      "description": "Test Token description",
      "revoked" : true,
      "last_used_at": "2021-02-13T10:34:57.178Z",
      "last_used_ips": ["192.0.2.10"],
      "access_level": 40
   }
]
```

> [!note]
> `last_used_ips` 属性最多列出五个使用此令牌进行身份验证的唯一 IP 地址。
> 达到上限时，最早的 IP 地址会被移除。该列表每个令牌每分钟更新一次。

<a id="retrieve-details-on-a-group-access-token"></a>

## 检索群组访问令牌的详细信息

检索指定群组访问令牌的详细信息。

```plaintext
GET /groups/:id/access_tokens/:token_id
```

| 属性  | 类型              | 是否必需 | 描述 |
| ---------- | ----------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `token_id` | integer or string | 是      | ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens/<token_id>"
```

```json
{
   "user_id" : 141,
   "scopes" : [
      "api"
   ],
   "name" : "token",
   "expires_at" : "2021-01-31",
   "id" : 42,
   "active" : true,
   "created_at" : "2021-01-20T22:11:48.151Z",
   "description": "Test Token description",
   "revoked" : false,
   "access_level": 40,
   "last_used_at": null,
   "last_used_ips": []
}
```

<a id="create-a-group-access-token"></a>

## 创建群组访问令牌

为指定群组创建群组访问令牌。

先决条件：

- 您必须具有该群组的所有者角色。

```plaintext
POST /groups/:id/access_tokens
```

| 属性      | 类型              | 是否必需 | 描述 |
| -------------- | ----------------- | -------- | ----------- |
| `id`           | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`         | String            | 是      | 令牌的名称。 |
| `description`  | string            | 否       | 群组访问令牌的描述。最大长度：255 个字符。 |
| `scopes`       | `Array[String]`   | 是      | 令牌可用的[作用域](../security/tokens/access_token_scopes.md)列表。 |
| `access_level` | Integer           | 否       | 令牌的角色。可能的值：`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）和 `50`（所有者）。默认值：`40`。 |
| `expires_at`   | date              | 否       | 访问令牌的到期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果未定义且令牌需要到期日期，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。如果不需要，则令牌没有到期日期。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type:application/json" \
  --data '{ "name":"test_token", "scopes":["api", "read_repository"], "expires_at":"2021-01-31", "access_level": 30 }' \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens"
```

```json
{
   "scopes" : [
      "api",
      "read_repository"
   ],
   "active" : true,
   "name" : "test",
   "revoked" : false,
   "created_at" : "2021-01-21T19:35:37.921Z",
   "description": "Test Token description",
   "user_id" : 166,
   "id" : 58,
   "expires_at" : "2021-01-31",
   "token" : "D4y...Wzr",
   "access_level": 30
}
```

<a id="rotate-a-group-access-token"></a>

## 轮换群组访问令牌

轮换指定的群组访问令牌。这会立即撤销先前的令牌并创建一个新令牌。通常，此端点通过使用个人访问令牌进行身份验证来轮换特定的群组访问令牌。您也可以使用群组访问令牌自行轮换。更多信息，请参见[自行轮换](#self-rotate)。

如果您尝试使用此端点轮换先前已撤销的令牌，则同一令牌族中的任何有效令牌都会被撤销。更多信息，请参见[自动重用检测](personal_access_tokens.md#automatic-reuse-detection)。

先决条件：

- 要轮换另一个群组访问令牌，您必须拥有具有 [`api` 作用域](../security/tokens/access_token_scopes.md)的个人访问令牌。
- 要[自行轮换](#self-rotate)群组访问令牌，该令牌必须具有 [`api` 或 `self_rotate` 作用域](../security/tokens/access_token_scopes.md)。

```plaintext
POST /groups/:id/access_tokens/:token_id/rotate
```

| 属性    | 类型              | 是否必需 | 描述 |
| ------------ | ----------------- | -------- | ----------- |
| `id`         | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `token_id`   | integer or string | 是      | 群组访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | date              | 否       | 访问令牌的到期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果令牌需要到期日期，则默认为一周。如果不需要，则令牌没有到期日期。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens/<token_id>/rotate"
```

示例响应：

```json
{
    "id": 42,
    "name": "Rotated Token",
    "revoked": false,
    "created_at": "2023-08-01T15:00:00.000Z",
    "description": "Test group access token",
    "scopes": ["api"],
    "user_id": 1337,
    "last_used_at": null,
    "last_used_ips": [],
    "active": true,
    "expires_at": "2023-08-15",
    "access_level": 30,
    "token": "s3cr3t"
}
```

如果成功，则返回 `200: OK`。

其他可能的响应：

- `400: Bad Request`：如果未成功轮换。
- `401: Unauthorized`：如果满足以下任一条件：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 您无权访问指定的令牌。
  - 您正在使用群组访问令牌轮换另一个群组访问令牌。请改用[自行轮换](#self-rotate)。
- `403: Forbidden`：如果该令牌不允许自行轮换。
- `404: Not Found`：如果用户是管理员但令牌不存在。
- `405: Method Not Allowed`：如果该令牌不是访问令牌。

<a id="self-rotate"></a>

### 自行轮换

您不必轮换特定的群组访问令牌，而是可以轮换用于对请求进行身份验证的同一个群组访问令牌。要自行轮换群组访问令牌，您必须：

- 使用具有 [`api` 或 `self_rotate` 作用域](../security/tokens/access_token_scopes.md)的群组访问令牌进行轮换。
- 在请求 URL 中使用 `self` 关键字。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_group_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens/self/rotate"
```

<a id="revoke-a-group-access-token"></a>

## 撤销群组访问令牌

撤销指定的群组访问令牌。

```plaintext
DELETE /groups/:id/access_tokens/:token_id
```

| 属性  | 类型              | 是否必需 | 描述 |
| ---------- | ----------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `token_id` | integer           | 是      | 群组访问令牌的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens/<token_id>"
```

如果成功，则返回 `204 No content`。

其他可能的响应：

- `400: Bad Request`：如果未成功撤销。
- `404: Not Found`：如果访问令牌不存在。
