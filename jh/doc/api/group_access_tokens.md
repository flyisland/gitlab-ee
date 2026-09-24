---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组访问令牌 API
description: 用于列出、获取、创建、轮换、自轮换和撤销群组访问令牌的 API。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与群组访问令牌进行交互。更多信息，请参见[群组访问令牌](../user/group/settings/group_access_tokens.md)。

<a id="list-all-group-access-tokens"></a>

## 列出所有群组访问令牌

{{< history >}}

- `state` 属性在极狐GitLab 17.2 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/462217)。

{{< /history >}}

列出指定群组的所有群组访问令牌。

```plaintext
GET /groups/:id/access_tokens
GET /groups/:id/access_tokens?state=inactive
```

| 属性              | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | 整数或字符串   | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_after`    | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之前创建的令牌。 |
| `expires_after`    | 日期 (ISO 8601)     | 否       | 如果定义，返回在指定时间之后过期的令牌。 |
| `expires_before`   | 日期 (ISO 8601)     | 否       | 如果定义，返回在指定时间之前过期的令牌。 |
| `last_used_after`  | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`          | 布尔值             | 否       | 如果为 `true`，仅返回已撤销的令牌。 |
| `search`           | 字符串              | 否       | 如果定义，返回名称中包含指定值的令牌。 |
| `sort`             | 字符串              | 否       | 如果定义，按指定值对结果排序。可能值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。|
| `state`            | 字符串              | 否       | 如果定义，返回具有指定状态的令牌。可能值：`active` 和 `inactive`。 |

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
      "access_level": 40
   }
]
```

<a id="retrieve-details-on-a-group-access-token"></a>

## 获取群组访问令牌的详细信息

获取指定群组访问令牌的详细信息。

```plaintext
GET /groups/:id/access_tokens/:token_id
```

| 属性      | 类型              | 是否必需 | 描述 |
| ---------- | ----------------- | -------- | ----------- |
| `id`       | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `token_id` | 整数或字符串 | 是      | ID |

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
   "access_level": 40
}
```

<a id="create-a-group-access-token"></a>

## 创建群组访问令牌

{{< history >}}

- `expires_at` 属性的默认值在极狐GitLab 16.0 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/120213)。

{{< /history >}}

为指定群组创建群组访问令牌。

先决条件：

- 您必须对群组具有 所有者 角色。

```plaintext
POST /groups/:id/access_tokens
```

| 属性          | 类型              | 是否必需 | 描述 |
| -------------- | ----------------- | -------- | ----------- |
| `id`           | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`         | 字符串            | 是      | 令牌的名称。 |
| `description`  | 字符串            | 否       | 群组访问令牌的描述。最大：255 字符。 |
| `scopes`       | `Array[String]`   | 是      | 令牌可用的[范围](../user/group/settings/group_access_tokens.md#group-access-token-scopes)列表。 |
| `access_level` | 整数           | 否       | 令牌的角色。可能值：`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）和 `50`（所有者）。默认值：`40`。 |
| `expires_at`   | 日期              | 否       | 访问令牌的过期日期，ISO 格式 (`YYYY-MM-DD`)。如果未定义，日期将设置为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

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

{{< history >}}

- 在极狐GitLab 16.0 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/403042)
- `expires_at` 属性在极狐GitLab 16.6 [新增](https://gitlab.com/gitlab-org/gitlab/-/issues/416795)。

{{< /history >}}

轮换指定的群组访问令牌。这会立即撤销以前的令牌并创建一个新令牌。通常，此端点通过使用个人访问令牌进行身份验证来轮换特定的群组访问令牌。您也可以使用群组访问令牌来轮换自身。更多信息，请参见[自轮换](#self-rotate)。

如果您尝试使用此端点轮换之前已撤销的令牌，则来自同一令牌系列的所有活跃令牌都将被撤销。更多信息，请参见[自动重用检测](personal_access_tokens.md#automatic-reuse-detection)。

先决条件：

- 要轮换另一个群组访问令牌，您必须拥有具有 [`api` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)的个人访问令牌。
- 要[自轮换](#self-rotate)群组访问令牌，该令牌必须具有 [`api` 或 `self_rotate` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。

```plaintext
POST /groups/:id/access_tokens/:token_id/rotate
```

| 属性        | 类型              | 是否必需 | 描述 |
| ------------ | ----------------- | -------- | ----------- |
| `id`         | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `token_id`   | 整数或字符串 | 是      | 群组访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | 日期              | 否       | 访问令牌的过期日期，ISO 格式 (`YYYY-MM-DD`)。如果令牌需要过期日期，默认为 1 周。如果不需要，默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

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
    "active": true,
    "expires_at": "2023-08-15",
    "access_level": 30,
    "token": "s3cr3t"
}
```

如果成功，返回 `200: OK`。

其他可能的响应：

- `400: Bad Request` 如果未成功轮换。
- `401: Unauthorized` 如果满足以下任一条件：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 您无权访问指定的令牌。
  - 您正在使用群组访问令牌轮换另一个群组访问令牌。请改为参见[自轮换](#self-rotate)。
- `403: Forbidden` 如果令牌不被允许轮换自身。
- `404: Not Found` 如果用户是管理员但令牌不存在。
- `405: Method Not Allowed` 如果令牌不是访问令牌。

<a id="self-rotate"></a>

### 自轮换

您可以轮换用于验证请求的同一群组访问令牌，而不是轮换特定的群组访问令牌。要自轮换群组访问令牌，您必须：

- 使用具有 [`api` 或 `self_rotate` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)的群组访问令牌进行轮换。
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

| 属性      | 类型              | 是否必需 | 描述 |
| ---------- | ----------------- | -------- | ----------- |
| `id`       | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `token_id` | 整数           | 是      | 群组访问令牌的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/<group_id>/access_tokens/<token_id>"
```

如果成功，返回 `204 No content`。

其他可能的响应：

- `400: Bad Request` 如果未成功撤销。
- `404: Not Found` 如果访问令牌不存在。