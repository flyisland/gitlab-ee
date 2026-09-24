---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 个人访问令牌 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [个人访问令牌](../user/profile/personal_access_tokens.md) 进行交互。

<a id="list-all-personal-access-tokens"></a>

## 列出所有个人访问令牌

{{< history >}}

- `created_after`、`created_before`、`last_used_after`、`last_used_before`、`revoked`、`search` 和 `state` 过滤器于极狐GitLab 15.5 引入。

{{< /history >}}

列出已认证用户可以访问的所有个人访问令牌。对于管理员，返回实例中的所有个人访问令牌。对于非管理员，返回其自己的所有个人访问令牌。

```plaintext
GET /personal_access_tokens
GET /personal_access_tokens?created_after=2022-01-01T00:00:00
GET /personal_access_tokens?created_before=2022-01-01T00:00:00
GET /personal_access_tokens?last_used_after=2022-01-01T00:00:00
GET /personal_access_tokens?last_used_before=2022-01-01T00:00:00
GET /personal_access_tokens?revoked=true
GET /personal_access_tokens?search=name
GET /personal_access_tokens?state=inactive
GET /personal_access_tokens?user_id=1
```

支持的属性：

| 属性                | 类型               | 是否必需 | 描述 |
| ------------------- | ------------------ | -------- | ----------- |
| `created_after`     | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之后创建的令牌。 |
| `created_before`    | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之前创建的令牌。 |
| `expires_after`     | 日期 (ISO 8601)     | 否       | 如果定义，返回在指定时间之后过期的令牌。 |
| `expires_before`    | 日期 (ISO 8601)     | 否       | 如果定义，返回在指定时间之前过期的令牌。 |
| `last_used_after`   | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before`  | 日期时间 (ISO 8601) | 否       | 如果定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`           | 布尔值             | 否       | 如果为 `true`，只返回已撤销的令牌。 |
| `search`            | 字符串              | 否       | 如果定义，返回名称中包含指定值的令牌。 |
| `sort`              | 字符串              | 否       | 如果定义，根据指定的值对结果进行排序。可能的取值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`             | 字符串              | 否       | 如果定义，返回具有指定状态的令牌。可能的取值：`active` 和 `inactive`。 |
| `user_id`           | 整数或字符串         | 否       | 如果定义，返回指定用户拥有的令牌。非管理员只能过滤自己的令牌。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens?user_id=3&created_before=2022-01-01"
```

示例响应：

```json
[
    {
        "id": 4,
        "name": "Test Token",
        "revoked": false,
        "created_at": "2020-07-23T14:31:47.729Z",
        "description": "Test Token description",
        "scopes": [
            "api"
        ],
        "user_id": 3,
        "last_used_at": "2021-10-06T17:58:37.550Z",
        "active": true,
        "expires_at": null
    }
]
```

如果成功，返回令牌列表。

其他可能的响应：

- `401: Unauthorized` 当非管理员使用 `user_id` 属性过滤其他用户时返回。

<a id="retrieve-a-personal-access-token"></a>

## 获取个人访问令牌

{{< history >}}

- 于极狐GitLab 15.1 引入。
- `404` HTTP 状态码于极狐GitLab 15.3 引入。

{{< /history >}}

获取指定个人访问令牌的详细信息。管理员可以获取任何令牌的详细信息。非管理员只能获取自己令牌的详细信息。

```plaintext
GET /personal_access_tokens/:id
```

| 属性 | 类型    | 是否必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | 整数或字符串 | 是 | 个人访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/<id>"
```

如果成功，返回令牌的详细信息。

其他可能的响应：

- `401: Unauthorized` 如果出现以下任一情况：
  - 令牌不存在。
  - 你没有该指定令牌的访问权限。
- `404: Not Found` 如果用户是管理员但令牌不存在。

<a id="self-inform"></a>

### 自查询

{{< history >}}

- 于极狐GitLab 15.5 引入

{{< /history >}}

除了获取特定个人访问令牌的详细信息，你还可以返回用于认证请求的个人访问令牌的详细信息。要返回这些详细信息，你必须在请求 URL 中使用 `self` 关键字。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/self"
```

<a id="create-a-personal-access-token"></a>

## 创建个人访问令牌

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

你可以使用用户令牌 API 创建个人访问令牌。更多信息，请参见以下端点：

- [创建个人访问令牌](user_tokens.md#create-a-personal-access-token)
- [为用户创建个人访问令牌](user_tokens.md#create-a-personal-access-token-for-a-user)

<a id="rotate-a-personal-access-token"></a>

## 轮换个人访问令牌

{{< history >}}

- 于极狐GitLab 16.0 引入
- `expires_at` 属性于极狐GitLab 16.6 添加。

{{< /history >}}

轮换指定的个人访问令牌。这将撤销之前的令牌，并创建一个一周后过期的新令牌。管理员可以为任何用户撤销令牌。非管理员只能撤销自己的令牌。

```plaintext
POST /personal_access_tokens/:id/rotate
```

| 属性 | 类型      | 是否必需 | 描述         |
|-----------|-----------|----------|---------------------|
| `id` | 整数或字符串 | 是      | 个人访问令牌的 ID 或关键字 `self`。 |
| `expires_at` | 日期   | 否       | 访问令牌的过期日期，ISO 格式 (`YYYY-MM-DD`)。如果令牌需要过期日期，则默认为 1 周。如果不需要，则默认为 [最大允许的有效期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/<personal_access_token_id>/rotate"
```

示例响应：

```json
{
    "id": 42,
    "name": "Rotated Token",
    "revoked": false,
    "created_at": "2023-08-01T15:00:00.000Z",
    "description": "Test Token description",
    "scopes": ["api"],
    "user_id": 1337,
    "last_used_at": null,
    "active": true,
    "expires_at": "2023-08-15",
    "token": "s3cr3t"
}
```

如果成功，返回 `200: OK`。

其他可能的响应：

- `400: Bad Request` 如果轮换未成功。
- `401: Unauthorized` 如果以下任一条件为真：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 你没有指定令牌的访问权限。
- `403: Forbidden` 如果令牌不被允许自我轮换。
- `404: Not Found` 如果用户是管理员但令牌不存在。
- `405: Method Not Allowed` 如果令牌不是个人访问令牌。

<a id="self-rotate"></a>

### 自轮换

{{< history >}}

- 于极狐GitLab 16.10 引入

{{< /history >}}

除了轮换特定个人访问令牌，你还可以轮换用于认证请求的同一个个人访问令牌。要自轮换个人访问令牌，你必须：

- 使用具有 [`api` 或 `self_rotate` 作用域](../user/profile/personal_access_tokens.md#personal-access-token-scopes)的个人访问令牌进行轮换。
- 在请求 URL 中使用 `self` 关键字。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/self/rotate"
```

<a id="automatic-reuse-detection"></a>

### 自动重用检测

{{< history >}}

- 于极狐GitLab 16.3 引入

{{< /history >}}

当你轮换或撤销令牌时，极狐GitLab 会自动追踪旧令牌和新令牌之间的关系。每次生成新令牌时，都会建立与前一个令牌的连接。这些连接的令牌组成一个令牌家族。

如果你尝试使用 API 轮换一个已被撤销的访问令牌，同一令牌家族中的任何活跃令牌都将被撤销。

此功能有助于在旧令牌被泄露或窃取时保护极狐GitLab。通过追踪令牌关系并在使用旧令牌时自动撤销访问权限，攻击者无法利用已泄露的令牌。

<a id="revoke-a-personal-access-token"></a>

## 撤销个人访问令牌

撤销指定的个人访问令牌。管理员可以为任何用户撤销令牌。非管理员只能撤销自己的令牌。

```plaintext
DELETE /personal_access_tokens/:id
```

| 属性 | 类型    | 是否必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | 整数或字符串 | 是 | 个人访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/<personal_access_token_id>"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request` 如果撤销未成功。
- `401: Unauthorized` 如果请求未经授权。
- `403: Forbidden` 如果请求不被允许。

<a id="self-revoke"></a>

### 自撤销

{{< history >}}

- 于极狐GitLab 15.0 引入，仅限于具有 `api` 作用域的令牌。
- 于极狐GitLab 15.4 引入，任何令牌都可以使用此端点。

{{< /history >}}

除了撤销特定个人访问令牌，你还可以撤销用于认证请求的同一个个人访问令牌。要自撤销个人访问令牌，你必须在请求 URL 中使用 `self` 关键字。

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/self"
```

<a id="list-all-token-associations"></a>

## 列出所有令牌关联

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

列出用于认证请求的个人访问令牌可以访问的所有群组和项目。通常，这包括用户所属的任何群组或项目。

```plaintext
GET /personal_access_tokens/self/associations
GET /personal_access_tokens/self/associations?page=2
GET /personal_access_tokens/self/associations?min_access_level=40
```

支持的属性：

| 属性           | 类型     | 是否必需 | 描述                                                              |
|---------------------|----------|----------|--------------------------------------------------------------------------|
| `min_access_level`  | 整数  | 否       | 限制为令牌至少具有指定访问级别的群组和项目。可能的取值：`5` (最低级访问)、`10` (访客)、`15` (计划者)、`20` (报告者)、`30` (开发者)、`40` (维护者) 或 `50` (所有者)。 |
| `page`              | 整数  | 否       | 要检索的页码。默认为 `1`。                                       |
| `per_page`          | 整数  | 否       | 每页返回的记录数。默认为 `20`。                                  |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/self/associations"
```

示例响应：

```json
{
    "groups": [
        {
        "id": 1,
        "web_url": "http://gitlab.example.com/groups/test",
        "name": "Test",
        "parent_id": null,
        "organization_id": 1,
        "access_levels": 20,
        "visibility": "public"
        },
        {
        "id": 3,
        "web_url": "http://gitlab.example.com/groups/test/test_private",
        "name": "Test Private",
        "parent_id": 1,
        "organization_id": 1,
        "access_levels": 50,
        "visibility": "test_private"
        }
    ],
    "projects": [
        {
            "id": 1337,
            "description": "Leet.",
            "name": "Test Project",
            "name_with_namespace": "Test / Test Project",
            "path": "test-project",
            "path_with_namespace": "Test/test-project",
            "created_at": "2024-07-02T13:37:00.123Z",
            "access_levels": {
                "project_access_level": null,
                "group_access_level": 20
            },
            "visibility": "private",
            "web_url": "http://gitlab.example.com/test/test_project",
            "namespace": {
                "id": 1,
                "name": "Test",
                "path": "Test",
                "kind": "group",
                "full_path": "Test",
                "parent_id": null,
                "avatar_url": null,
                "web_url": "http://gitlab.example.com/groups/test"
            }
        }
    ]
}
```