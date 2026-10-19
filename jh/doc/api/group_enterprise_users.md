---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组企业用户 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用这些 API 端点与企业用户交互。更多信息，请参见[企业用户](../user/enterprise_user/_index.md)。

这些 API 端点仅适用于顶级群组。用户不必是该群组的成员。

先决条件：

- 您必须在顶级群组中拥有所有者角色。

<a id="list-all-enterprise-users"></a>

## 列出所有企业用户

列出指定顶级群组的所有企业用户。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)筛选结果。

```plaintext
GET /groups/:id/enterprise_users
```

支持的属性：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `username`       | string         | 否       | 返回具有给定用户名的用户。 |
| `search`         | string         | 否       | 返回名称、电子邮件或用户名匹配的用户。使用部分值可增加结果数量。 |
| `active`         | boolean        | 否       | 仅返回活跃用户。 |
| `blocked`        | boolean        | 否       | 仅返回已封锁用户。 |
| `created_after`  | datetime       | 否       | 返回在指定时间之后创建的用户。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `created_before` | datetime       | 否       | 返回在指定时间之前创建的用户。格式：ISO 8601（`YYYY-MM-DDTHH:MM:SSZ`）。 |
| `two_factor`     | string         | 否       | 根据用户的双因素认证（2FA）注册状态返回用户。可能的值：`enabled`、`disabled`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/enterprise_users"
```

示例响应：

```json
[
  {
    "id": 66,
    "username": "user22",
    "name": "Sidney Jones22",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/xxx?s=80&d=identicon",
    "web_url": "http://my.gitlab.com/user22",
    "created_at": "2021-09-10T12:48:22.381Z",
    "bio": "",
    "location": null,
    "public_email": "",
    "linkedin": "",
    "twitter": "",
    "website_url": "",
    "organization": null,
    "job_title": "",
    "pronouns": null,
    "bot": false,
    "work_information": null,
    "followers": 0,
    "following": 0,
    "local_time": null,
    "last_sign_in_at": null,
    "confirmed_at": "2021-09-10T12:48:22.330Z",
    "last_activity_on": null,
    "email": "user22@example.org",
    "theme_id": 1,
    "color_scheme_id": 1,
    "projects_limit": 100000,
    "current_sign_in_at": null,
    "identities": [
      {
        "provider": "group_saml",
        "extern_uid": "2435223452345",
        "saml_provider_id": 1
      }
    ],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": false,
    "external": false,
    "private_profile": false,
    "commit_email": "user22@example.org",
    "shared_runners_minutes_limit": null,
    "extra_shared_runners_minutes_limit": null,
    "scim_identities": [
      {
        "extern_uid": "2435223452345",
        "group_id": 1,
        "active": true
      }
    ]
  },
  ...
]
```

<a id="retrieve-an-enterprise-user"></a>

## 检索企业用户

检索指定的企业用户。

```plaintext
GET /groups/:id/enterprise_users/:user_id
```

支持的属性：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | integer        | 是      | 用户账号的 ID。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/enterprise_users/:user_id"
```

示例响应：

```json
{
  "id": 66,
  "username": "user22",
  "name": "Sidney Jones22",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/xxx?s=80&d=identicon",
  "web_url": "http://my.gitlab.com/user22",
  "created_at": "2021-09-10T12:48:22.381Z",
  "bio": "",
  "location": null,
  "public_email": "",
  "linkedin": "",
  "twitter": "",
  "website_url": "",
  "organization": null,
  "job_title": "",
  "pronouns": null,
  "bot": false,
  "work_information": null,
  "followers": 0,
  "following": 0,
  "local_time": null,
  "last_sign_in_at": null,
  "confirmed_at": "2021-09-10T12:48:22.330Z",
  "last_activity_on": null,
  "email": "user22@example.org",
  "theme_id": 1,
  "color_scheme_id": 1,
  "projects_limit": 100000,
  "current_sign_in_at": null,
  "identities": [
    {
      "provider": "group_saml",
      "extern_uid": "2435223452345",
      "saml_provider_id": 1
    }
  ],
  "can_create_group": true,
  "can_create_project": true,
  "two_factor_enabled": false,
  "external": false,
  "private_profile": false,
  "commit_email": "user22@example.org",
  "shared_runners_minutes_limit": null,
  "extra_shared_runners_minutes_limit": null,
  "scim_identities": [
    {
      "extern_uid": "2435223452345",
      "group_id": 1,
      "active": true
    }
  ]
}
```

<a id="update-an-enterprise-user"></a>

## 更新企业用户

更新指定的企业用户。

```plaintext
PATCH /groups/:id/enterprise_users/:user_id
```

支持的属性：

| 属性          | 类型           | 是否必需 | 描述 |
|:-------------------|:---------------|:---------|:------------|
| `id`               | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`          | integer        | 是      | 用户账号的 ID。 |
| `name`             | string         | 否       | 用户账号的名称。 |
| `email`            | string         | 否       | 用户账号的电子邮件地址。必须来自已验证的[群组域名](../user/enterprise_user/_index.md#manage-group-domains)。 |
| `projects_limit`   | integer        | 否       | 用户可以创建的项目数量。 |
| `can_create_group` | boolean        | 否       | 指示用户是否可以创建群组的标志。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "email=new-email@example.com" \
  --data "name=New name" \
  --url "https://gitlab.example.com/api/v4/groups/:id/enterprise_users/:user_id"
```

如果成功，返回 `200 OK`。

成功响应示例：

```json
{
  "id": 66,
  "username": "user22",
  "name": "New name",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/xxx?s=80&d=identicon",
  "web_url": "http://my.gitlab.com/user22",
  "created_at": "2021-09-10T12:48:22.381Z",
  "bio": "",
  "location": null,
  "public_email": "",
  "linkedin": "",
  "twitter": "",
  "website_url": "",
  "organization": null,
  "job_title": "",
  "pronouns": null,
  "bot": false,
  "work_information": null,
  "followers": 0,
  "following": 0,
  "local_time": null,
  "last_sign_in_at": null,
  "confirmed_at": "2021-09-10T12:48:22.330Z",
  "last_activity_on": null,
  "email": "new-email@example.com",
  "theme_id": 1,
  "color_scheme_id": 1,
  "projects_limit": 100000,
  "current_sign_in_at": null,
  "identities": [
    {
      "provider": "group_saml",
      "extern_uid": "2435223452345",
      "saml_provider_id": 1
    }
  ],
  "can_create_group": true,
  "can_create_project": true,
  "two_factor_enabled": false,
  "external": false,
  "private_profile": false,
  "commit_email": "user22@example.org",
  "shared_runners_minutes_limit": null,
  "extra_shared_runners_minutes_limit": null,
  "scim_identities": [
    {
      "extern_uid": "2435223452345",
      "group_id": 1,
      "active": true
    }
  ]
}
```

其他可能的响应：

- `400 Bad Request`：验证错误。
- `403 Forbidden`：已认证用户不是所有者。
- `404 Not found`：找不到用户。

<a id="delete-an-enterprise-user"></a>

## 删除企业用户

删除指定的企业用户。

```plaintext
DELETE /groups/:id/enterprise_users/:user_id
```

支持的属性：

| 属性     | 类型           | 是否必需 | 描述                                                                                                                                                                                                                                                                              |
|:--------------|:---------------|:---------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`          | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                                                                                          |
| `user_id`     | integer        | 是      | 用户账号的 ID。                                                                                                                                                                                                                                                                      |
| `hard_delete` | boolean        | 否       | 如果为 `false`，则删除该用户并将其贡献[移至幽灵用户](../user/profile/account/delete_account.md#associated-records)。如果为 `true`，则删除该用户、其相关贡献以及仅由该用户拥有的任何群组。默认值：`false`。  |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/enterprise_users/:user_id"
```

如果成功，返回 `204 No content`。

其他可能的响应：

- `403 Forbidden`：已认证用户不是所有者。
- `404 Not found`：找不到该用户。
- `409 Conflict`：无法移除作为群组唯一所有者的用户。

<a id="disable-two-factor-authentication-for-an-enterprise-user"></a>

## 为企业用户禁用双因素认证

为指定的企业用户禁用双因素认证（2FA）。

```plaintext
PATCH /groups/:id/enterprise_users/:user_id/disable_two_factor
```

支持的属性：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | integer        | 是      | 用户账号的 ID。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/enterprise_users/:user_id/disable_two_factor"
```

如果成功，返回 `204 No content`。

其他可能的响应：

- `400 Bad request`：指定的用户未启用 2FA。
- `403 Forbidden`：已认证用户不是所有者。
- `404 Not found`：找不到用户。
