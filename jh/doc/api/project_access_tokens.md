---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目访问令牌 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与项目访问令牌进行交互。有关更多信息，请参见[项目访问令牌](../user/project/settings/project_access_tokens.md)。

<a id="list-all-project-access-tokens"></a>

## 列出所有项目访问令牌

{{< history >}}

- `state` 属性在 极狐GitLab 17.2 引入。

{{< /history >}}

列出指定项目的所有项目访问令牌。

```plaintext
GET projects/:id/access_tokens
GET projects/:id/access_tokens?state=inactive
```

| 属性                | 类型                | 是否必需 | 描述   |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | 整数或字符串        | 是      | 项目的 ID 或 [URL-encoded path](rest/_index.md#namespaced-paths)。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 如果定义，返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 如果定义，返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之后上次使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之前上次使用的令牌。 |
| `revoked`          | 布尔值              | 否       | 如果为 `true`，仅返回已撤销的令牌。 |
| `search`           | 字符串              | 否       | 如果定义，返回名称中包含指定值的令牌。 |
| `sort`             | 字符串              | 否       | 如果定义，按指定值对结果进行排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`            | 字符串              | 否       | 如果定义，返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens"
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
      "last_used_at" : null,
      "revoked" : false,
      "access_level" : 40
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
      "last_used_at" : "2021-02-13T10:34:57.178Z",
      "access_level" : 40
   }
]
```

<a id="retrieve-details-on-a-project-access-token"></a>

## 检索项目访问令牌的详细信息

检索项目访问令牌的详细信息。

```plaintext
GET projects/:id/access_tokens/:token_id
```

| 属性        | 类型              | 是否必需 | 描述   |
| ---------- | ----------------- | -------- | ----------- |
| `id`       | 整数或字符串      | 是      | 项目的 ID 或 [URL-encoded path](rest/_index.md#namespaced-paths)。 |
| `token_id` | 整数或字符串      | 是      | 令牌 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens/<token_id>"
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
   "last_used_at": "2022-03-15T11:05:42.437Z"
}
```

<a id="create-a-project-access-token"></a>

## 创建项目访问令牌

{{< history >}}

- `expires_at` 属性默认值在 极狐GitLab 16.0 引入。

{{< /history >}}

为指定项目创建项目访问令牌。您不能创建访问级别高于您账户的令牌。例如，拥有维护者角色的用户无法创建具有所有者角色的项目访问令牌。

您必须在此端点上使用个人访问令牌。您不能使用项目访问令牌进行身份验证。

```plaintext
POST projects/:id/access_tokens
```

| 属性           | 类型              | 是否必需 | 描述   |
| -------------- | ----------------- | -------- | ----------- |
| `id`           | 整数或字符串      | 是      | 项目的 ID 或 [URL-encoded path](rest/_index.md#namespaced-paths)。 |
| `name`         | 字符串            | 是      | 令牌的名称。 |
| `description`  | 字符串            | 否       | 项目访问令牌的描述。最大：255 个字符。 |
| `scopes`       | `Array[String]`   | 是      | 可供令牌使用的[范围](../user/project/settings/project_access_tokens.md#project-access-token-scopes)列表。 |
| `access_level` | 整数              | 否       | 令牌的角色。可能的值：`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）和 `50`（所有者）。默认值：`40`。 |
| `expires_at`   | date              | 是      | 令牌的过期日期，采用 ISO 格式 (`YYYY-MM-DD`)。如果未定义，日期将设置为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_personal_access_token>" \
  --header "Content-Type:application/json" \
  --data '{ "name":"test_token", "scopes":["api", "read_repository"], "expires_at":"2021-01-31", "access_level":30 }' \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens"
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

<a id="rotate-a-project-access-token"></a>

## 轮换项目访问令牌

{{< history >}}

- 在 极狐GitLab 16.0 引入。
- `expires_at` 属性在 极狐GitLab 16.6 添加。

{{< /history >}}

轮换项目访问令牌。这会立即撤销前一个令牌并创建一个新令牌。通常，此端点通过个人访问令牌进行身份验证来轮换特定的项目访问令牌。您也可以使用项目访问令牌进行自轮换。有关更多信息，请参见[自轮换](#self-rotate)。

如果您尝试使用此端点轮换之前已撤销的令牌，同一令牌系列中的所有活动令牌都会被撤销。有关更多信息，请参见[自动重用检测](personal_access_tokens.md#automatic-reuse-detection)。

先决条件：

- 要轮换另一个项目访问令牌，您必须拥有一个具有 [`api` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)的个人访问令牌。
- 要[自轮换](#self-rotate)项目访问令牌，该令牌必须具有 [`api` 或 `self_rotate` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。

```plaintext
POST /projects/:id/access_tokens/:token_id/rotate
```

| 属性          | 类型              | 是否必需 | 描述   |
| ------------ | ----------------- | -------- | ----------- |
| `id`         | 整数或字符串      | 是      | 项目的 ID 或 [URL-encoded path](rest/_index.md#namespaced-paths)。 |
| `token_id`   | 整数或字符串      | 是      | 项目访问令牌的 ID 或关键词 `self`。 |
| `expires_at` | date              | 否       | 访问令牌的过期日期，采用 ISO 格式 (`YYYY-MM-DD`)。如果令牌需要过期日期，则默认为 1 周。如果不强制要求，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens/<token_id>/rotate"
```

示例响应：

```json
{
    "id": 42,
    "name": "Rotated Token",
    "revoked": false,
    "created_at": "2023-08-01T15:00:00.000Z",
    "description": "Test project access token",
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

- `400: Bad Request` 如果轮换不成功。
- `401: Unauthorized` 如果满足以下任一条件：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 您无权访问指定的令牌。
  - 您正使用项目访问令牌来轮换另一个项目访问令牌。请改用[自轮换](#self-rotate)。
- `403: Forbidden` 如果令牌不允许自轮换。
- `404: Not Found` 如果用户是管理员但令牌不存在。
- `405: Method Not Allowed` 如果令牌不是项目访问令牌。

<a id="self-rotate"></a>

### 自轮换

除了轮换特定的项目访问令牌外，您还可以轮换用于对请求进行身份验证的同一个项目访问令牌。要自轮换项目访问令牌，您必须：

- 使用具有 [`api` 或 `self_rotate` 范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)的项目访问令牌进行轮换。
- 在请求 URL 中使用 `self` 关键词。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_project_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens/self/rotate"
```

<a id="revoke-a-project-access-token"></a>

## 撤销项目访问令牌

撤销指定的项目访问令牌。

```plaintext
DELETE projects/:id/access_tokens/:token_id
```

| 属性        | 类型              | 是否必需 | 描述   |
| ---------- | ----------------- | -------- | ----------- |
| `id`       | 整数或字符串      | 是      | 项目的 ID 或 [URL-encoded path](rest/_index.md#namespaced-paths)。 |
| `token_id` | 整数              | 是      | 项目访问令牌的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/access_tokens/<token_id>"
```

如果成功，返回 `204 No content`。

其他可能的响应：

- `400: Bad Request` 如果撤销不成功。
- `404: Not Found` 如果访问令牌不存在。