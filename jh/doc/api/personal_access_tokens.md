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

使用此 API 与[个人访问令牌](../user/profile/personal_access_tokens.md)交互。

<a id="list-all-personal-access-tokens"></a>

## 列出所有个人访问令牌

列出经过身份验证的用户可访问的所有个人访问令牌。对于管理员，返回实例中的所有个人访问令牌。对于非管理员，返回其所有的个人访问令牌。

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

| 属性          | 类型                | 必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 如果定义，返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 如果定义，返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果定义，返回名称中包含指定值的令牌。 |
| `sort`             | string              | 否       | 如果定义，按指定值对结果排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`            | string              | 否       | 如果定义，返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |
| `user_id`          | integer or string   | 否       | 如果定义，返回指定用户拥有的令牌。非管理员只能筛选自己的令牌。 |

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
        "last_used_ips": ["192.0.2.10"],
        "active": true,
        "expires_at": null,
        "granular_scopes": [
            {
                "access": "selected_memberships",
                "permissions": ["read_job"],
                "project_id": 6,
                "group_id": null
            }
        ]
    }
]
```

> [!note]
> `last_used_ips` 属性最多列出五个使用此令牌进行身份验证的唯一 IP 地址。达到上限时，最早的 IP 地址会被移除。该列表每个令牌每分钟更新一次。`granular_scopes` 属性仅存在于使用细粒度作用域而非标准 `scopes` 属性创建的令牌中。当 `access` 为 `selected_memberships` 且作用域以项目为目标时，每个作用域都有一个 `project_id`；当作用域以群组为目标时，则有一个 `group_id`。对于 `access` 为 `user`、`instance`、`all_memberships` 或 `personal_projects`的作用域，两者均为 `null`。

如果成功，返回令牌列表。

其他可能的响应：

- `401: Unauthorized` 如果非管理员使用 `user_id` 属性筛选其他用户。

<a id="retrieve-a-personal-access-token"></a>

## 检索个人访问令牌

检索指定个人访问令牌的详细信息。管理员可以检索任何令牌的详细信息。非管理员只能检索自己令牌的详细信息。响应具有与[列出所有个人访问令牌](#list-all-personal-access-tokens)相同的属性，包括 `granular_scopes`。

```plaintext
GET /personal_access_tokens/:id
```

| 属性 | 类型    | 必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | integer or string | 是 | 个人访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/<id>"
```

如果成功，返回令牌的详细信息。

其他可能的响应：

- `401: Unauthorized` 如果满足以下任一条件：
  - 令牌不存在。
  - 您无权访问指定的令牌。
- `404: Not Found` 如果用户是管理员但令牌不存在。

<a id="self-inform"></a>

### 自查询

除了获取特定个人访问令牌的详细信息外，您还可以返回用于验证请求的个人访问令牌的详细信息。要返回这些详细信息，您必须在请求 URL 中使用 `self` 关键字。

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

您可以使用用户令牌 API 创建个人访问令牌。有关更多信息，请参见以下端点：

- [创建个人访问令牌](user_tokens.md#create-a-personal-access-token)
- [为用户创建个人访问令牌](user_tokens.md#create-a-personal-access-token-for-a-user)

<a id="rotate-a-personal-access-token"></a>

## 轮换个人访问令牌

轮换指定的个人访问令牌。这会撤销先前的令牌并创建一个一周后过期的新令牌。管理员可以撤销任何用户的令牌。非管理员只能撤销自己的令牌。

```plaintext
POST /personal_access_tokens/:id/rotate
```

| 属性 | 类型      | 是否必需 | 描述         |
|-----------|-----------|----------|---------------------|
| `id` | integer or string | 是      | 个人访问令牌的 ID，或关键字 `self`。 |
| `expires_at` | date   | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果令牌要求提供过期日期，则默认为一周。如果不要求，则该令牌没有过期日期。 |

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
    "last_used_ips": [],
    "active": true,
    "expires_at": "2023-08-15",
    "token": "s3cr3t"
}
```

> [!note]
> 轮换具有细粒度作用域的令牌会在新令牌上以 `granular_scopes` 属性返回这些作用域，如[列出所有个人访问令牌](#list-all-personal-access-tokens)中所述。

如果成功，返回 `200: OK`。

其他可能的响应：

- `400: Bad Request` 如果未成功轮换。
- `401: Unauthorized` 如果满足以下任一条件：
  - 令牌不存在。
  - 令牌已过期。
  - 令牌已被撤销。
  - 您无权访问指定的令牌。
- `403: Forbidden` 如果该令牌不允许自行轮换。
- `404: Not Found` 如果用户是管理员但令牌不存在。
- `405: Method Not Allowed` 如果该令牌不是个人访问令牌。

<a id="self-rotate"></a>

### 自行轮换

除了轮换特定的个人访问令牌外，您还可以轮换用于验证请求的同一个个人访问令牌。要自行轮换个人访问令牌，您必须：

- 使用 [`api` 或 `self_rotate` 作用域](../security/tokens/access_token_scopes.md)轮换个人访问令牌。
- 在请求 URL 中使用 `self` 关键字。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/self/rotate"
```

<a id="automatic-reuse-detection"></a>

### 自动重用检测

当您轮换或撤销令牌时，极狐GitLab 会自动跟踪旧令牌和新令牌之间的关系。每次生成新令牌时，都会与先前的令牌建立连接。这些相互连接的令牌构成一个令牌族。

如果您尝试使用 API 轮换一个已被撤销的访问令牌，同一令牌族中的任何活动令牌都会被撤销。

此功能有助于在旧令牌泄露或被盗时保护极狐GitLab 的安全。通过跟踪令牌关系并在使用旧令牌时自动撤销访问权限，攻击者无法利用已泄露的令牌。

<a id="revoke-a-personal-access-token"></a>

## 撤销个人访问令牌

撤销指定的个人访问令牌。管理员可以撤销任何用户的令牌。非管理员只能撤销自己的令牌。

```plaintext
DELETE /personal_access_tokens/:id
```

| 属性 | 类型    | 必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id` | integer or string | 是 | 个人访问令牌的 ID 或关键字 `self`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/<personal_access_token_id>"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request` 如果未成功撤销。
- `401: Unauthorized` 如果请求未获授权。
- `403: Forbidden` 如果不允许该请求。

<a id="self-revoke"></a>

### 自行撤销

除了撤销特定的个人访问令牌外，您还可以撤销用于验证请求的同一个个人访问令牌。任何令牌都可以使用此端点。要自行撤销个人访问令牌，您必须在请求 URL 中使用 `self` 关键字。

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/personal_access_tokens/self"
```

<a id="list-all-token-associations"></a>

## 列出所有令牌关联

列出用于验证请求的个人访问令牌可访问的所有群组和项目。通常，这包括该用户所属的任何群组或项目。

```plaintext
GET /personal_access_tokens/self/associations
GET /personal_access_tokens/self/associations?page=2
GET /personal_access_tokens/self/associations?min_access_level=40
```

支持的属性：

| 属性           | 类型     | 必需 | 描述                                                              |
|---------------------|----------|----------|--------------------------------------------------------------------------|
| `min_access_level`  | integer  | 否       | 限制为令牌至少具有指定访问级别的群组和项目。可能的值：`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `page`              | integer  | 否       | 要检索的页码。默认为 `1`。                                       |
| `per_page`          | integer  | 否       | 每页返回的记录数。默认为 `20`。                  |

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
