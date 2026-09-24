---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户 API
description: 极狐GitLab 用户 API 可以创建、修改、搜索和删除用户账户。它还支持管理员操作和 SCIM 预配。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与极狐GitLab 上的用户账户交互。这些端点可以帮助管理[您的账户](../user/profile/_index.md)或[其他用户的账户](../administration/administer_users.md)。

<a id="list-all-users"></a>

## 列出所有用户

列出所有用户。

使用[分页参数](rest/_index.md#offset-based-pagination) `page` 和 `per_page` 来限制用户列表。

<a id="as-a-regular-user"></a>

### 作为普通用户

{{< history >}}

- 键集分页在极狐GitLab 16.5 引入。
- `saml_provider_id` 属性在极狐GitLab 18.2 中移除。

{{< /history >}}

```plaintext
GET /users
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------------------|:---------|:---------|:------------|
| `username` | string | no | 通过特定用户名获取单个用户。 |
| `public_email` | string | no | 通过特定公共邮箱获取单个用户。 |
| `search` | string | no | 按名称、用户名或公共邮箱搜索用户。 |
| `active` | boolean | no | 仅过滤活跃用户。默认值为 `false`。 |
| `external` | boolean | no | 仅过滤外部用户。默认值为 `false`。 |
| `blocked` | boolean | no | 仅过滤已封锁用户。默认值为 `false`。 |
| `humans` | boolean | no | 仅过滤非机器人或内部用户的普通用户。默认值为 `false`。 |
| `created_after` | DateTime | no | 返回在指定时间之后创建的用户。 |
| `created_before` | DateTime | no | 返回在指定时间之前创建的用户。 |
| `exclude_active` | boolean | no | 仅过滤非活跃用户。默认值为 `false`。 |
| `exclude_external` | boolean | no | 仅过滤非外部用户。默认值为 `false`。 |
| `exclude_humans` | boolean | no | 仅过滤机器人或内部用户。默认值为 `false`。 |
| `exclude_internal` | boolean | no | 仅过滤非内部用户。默认值为 `false`。 |
| `without_project_bots` | boolean | no | 过滤不带项目机器人的用户。默认值为 `false`。 |

示例响应：

```json
[
  {
    "id": 1,
    "username": "john_smith",
    "name": "John Smith",
    "state": "active",
    "locked": false,
    "avatar_url": "http://localhost:3000/uploads/user/avatar/1/cd8.jpeg",
    "web_url": "http://localhost:3000/john_smith"
  },
  {
    "id": 2,
    "username": "jack_smith",
    "name": "Jack Smith",
    "state": "blocked",
    "locked": false,
    "avatar_url": "http://gravatar.com/../e32131cd8.jpeg",
    "web_url": "http://localhost:3000/jack_smith"
  }
]
```

此端点支持[键集分页](rest/_index.md#keyset-based-pagination)。在极狐GitLab 17.0 及更高版本中，对于响应数量为 50,000 及以上的情况，要求使用键集分页。

您还可以使用 `?search=` 按名称、用户名或公共邮箱搜索用户。例如，`/users?search=John`。当您搜索：

- 公共邮箱时，必须使用完整的邮箱地址才能获得精确匹配。
- 名称或用户名时，不需要精确匹配，因为这是模糊搜索。

此外，您可以通过用户名查找用户：

```plaintext
GET /users?username=:username
```

例如：

```plaintext
GET /users?username=jack_smith
```

> [!note]
> 用户名搜索不区分大小写。

此外，您可以根据状态 `blocked` 和 `active` 过滤用户。不支持 `active=false` 或 `blocked=false`。

```plaintext
GET /users?active=true
```

```plaintext
GET /users?blocked=true
```

此外，您可以使用 `external=true` 仅搜索外部用户。不支持 `external=false`。

```plaintext
GET /users?external=true
```

极狐GitLab 支持机器人用户，例如[警报机器人](../operations/incident_management/integrations.md)或[支持机器人](../user/project/service_desk/configure.md#support-bot-user)。您可以使用 `exclude_internal=true` 参数从用户列表中排除以下类型的[内部用户](../administration/internal_users.md)：

- 警报机器人
- 支持机器人

但是，此操作不会排除[项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)或[群组机器人用户](../user/group/settings/group_access_tokens.md#bot-users-for-groups)。

```plaintext
GET /users?exclude_internal=true
```

此外，要从用户列表中排除外部用户，可以使用参数 `exclude_external=true`。

```plaintext
GET /users?exclude_external=true
```

要排除[项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)和[群组机器人用户](../user/group/settings/group_access_tokens.md#bot-users-for-groups)，您可以使用参数 `without_project_bots=true`。

```plaintext
GET /users?without_project_bots=true
```

<a id="as-an-administrator"></a>

### 作为管理员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 响应中的 `created_by` 字段在极狐GitLab 15.6 引入。
- 响应中的 `scim_identities` 字段在极狐GitLab 16.1 引入。
- 响应中的 `auditors` 字段在极狐GitLab 16.2 引入。
- 响应中的 `email_reset_offered_at` 字段在极狐GitLab 16.7 引入。
- 响应中的 `email_reset_offered_at` 字段在极狐GitLab 18.3 移除。

{{< /history >}}

```plaintext
GET /users
```

您可以使用所有[对所有用户可用的参数](#as-a-regular-user)，以及以下仅限管理员使用的额外属性。

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:-------------------|:--------|:---------|:------------|
| `search` | string | no | 按名称、用户名、公共邮箱或私有邮箱搜索用户。 |
| `extern_uid` | string | no | 获取具有特定外部认证提供者 UID 的单个用户。 |
| `provider` | string | no | 外部提供者。 |
| `order_by` | string | no | 返回按 `id`、`name`、`username`、`created_at` 或 `updated_at` 字段排序的用户。默认值为 `id`。 |
| `sort` | string | no | 返回按 `asc`（升序）或 `desc`（降序）排序的用户。默认值为 `desc`。 |
| `two_factor` | string | no | 按双重认证过滤用户。过滤值为 `enabled` 或 `disabled`。默认情况下返回所有用户。 |
| `without_projects` | boolean | no | 过滤没有项目的用户。默认值为 `false`，表示返回所有用户，包括有项目和没有项目的用户。 |
| `admins` | boolean | no | 仅返回管理员。默认值为 `false`。 |
| `auditors` | boolean | no | 仅返回审计员用户。默认值为 `false`。如果不包含此参数，则返回所有用户。仅适用于专业版和旗舰版。 |
| `skip_ldap` | boolean | no | 跳过 LDAP 用户。仅适用于专业版和旗舰版。 |

示例响应：

```json
[
  {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "locked": false,
    "avatar_url": "http://localhost:3000/uploads/user/avatar/1/index.jpg",
    "web_url": "http://localhost:3000/john_smith",
    "created_at": "2012-05-23T08:00:58Z",
    "is_admin": false,
    "bio": "",
    "location": null,
    "linkedin": "",
    "twitter": "",
    "discord": "",
    "github": "",
    "website_url": "",
    "organization": "",
    "job_title": "",
    "last_sign_in_at": "2012-06-01T11:41:01Z",
    "confirmed_at": "2012-05-23T09:05:22Z",
    "theme_id": 1,
    "last_activity_on": "2012-05-23",
    "color_scheme_id": 2,
    "projects_limit": 100,
    "current_sign_in_at": "2012-06-02T06:36:55Z",
    "note": "DMCA Request: 2018-11-05 | DMCA Violation | Abuse | https://gitlab.zendesk.com/agent/tickets/123",
    "identities": [
      {"provider": "github", "extern_uid": "2435223452345"},
      {"provider": "bitbucket", "extern_uid": "john.smith"},
      {"provider": "google_oauth2", "extern_uid": "8776128412476123468721346"}
    ],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": true,
    "external": false,
    "private_profile": false,
    "current_sign_in_ip": "196.165.1.102",
    "last_sign_in_ip": "172.127.2.22",
    "namespace_id": 1,
    "created_by": null
  },
  {
    "id": 2,
    "username": "jack_smith",
    "email": "jack@example.com",
    "name": "Jack Smith",
    "state": "blocked",
    "locked": false,
    "avatar_url": "http://localhost:3000/uploads/user/avatar/2/index.jpg",
    "web_url": "http://localhost:3000/jack_smith",
    "created_at": "2012-05-23T08:01:01Z",
    "is_admin": false,
    "bio": "",
    "location": null,
    "linkedin": "",
    "twitter": "",
    "discord": "",
    "github": "",
    "website_url": "",
    "organization": "",
    "job_title": "",
    "last_sign_in_at": null,
    "confirmed_at": "2012-05-30T16:53:06.148Z",
    "theme_id": 1,
    "last_activity_on": "2012-05-23",
    "color_scheme_id": 3,
    "projects_limit": 100,
    "current_sign_in_at": "2014-03-19T17:54:13Z",
    "identities": [],
    "can_create_group": true,
    "can_create_project": true,
    "two_factor_enabled": true,
    "external": false,
    "private_profile": false,
    "current_sign_in_ip": "10.165.1.102",
    "last_sign_in_ip": "172.127.2.22",
    "namespace_id": 2,
    "created_by": null
  }
]
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到 `shared_runners_minutes_limit`、`extra_shared_runners_minutes_limit`、`is_auditor` 和 `using_license_seat` 参数。

```json
[
  {
    "id": 1,
    ...
    "shared_runners_minutes_limit": 133,
    "extra_shared_runners_minutes_limit": 133,
    "is_auditor": false,
    "using_license_seat": true
    ...
  }
]
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到 `group_saml` 提供者选项和 `provisioned_by_group_id` 参数：

```json
[
  {
    "id": 1,
    ...
    "identities": [
      {"provider": "github", "extern_uid": "2435223452345"},
      {"provider": "bitbucket", "extern_uid": "john.smith"},
      {"provider": "google_oauth2", "extern_uid": "8776128412476123468721346"},
      {"provider": "group_saml", "extern_uid": "123789", "saml_provider_id": 10}
    ],
    "provisioned_by_group_id": 123789
    ...
  }
]
```

您还可以使用 `?search=` 按名称、用户名或邮箱搜索用户。例如，`/users?search=John`。当您搜索：

- 邮箱时，必须使用完整的邮箱地址才能获得精确匹配。作为管理员，您可以同时搜索公共和私有邮箱地址。
- 名称或用户名时，不需要精确匹配，因为这是模糊搜索。

您可以通过外部 UID 和提供者查找用户：

```plaintext
GET /users?extern_uid=:extern_uid&provider=:provider
```

例如：

```plaintext
GET /users?extern_uid=1234567&provider=github
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)用户还可以使用 `scim` 提供者：

```plaintext
GET /users?extern_uid=1234567&provider=scim
```

您可以按创建日期时间范围搜索用户：

```plaintext
GET /users?created_before=2001-01-02T00:00:00.060Z&created_after=1999-01-02T00:00:00.060
```

您可以使用 `/users?without_projects=true` 搜索没有项目的用户。

您可以使用[自定义属性](custom_attributes.md)进行过滤：

```plaintext
GET /users?custom_attributes[key]=value&custom_attributes[other_key]=other_value
```

您可以使用以下方式在响应中包含用户的[自定义属性](custom_attributes.md)：

```plaintext
GET /users?with_custom_attributes=true
```

您可以使用 `created_by` 参数查看用户账户是如何创建的：

- [由管理员手动创建](../user/profile/account/create_accounts.md#create-a-user-in-the-admin-area)。
- 作为[项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)创建。

如果返回的值为 `null`，则该账户是由用户自行注册创建的。

<a id="retrieve-a-single-user"></a>

## 获取单个用户

获取单个用户。

<a id="retrieve-a-single-user-as-a-regular-user"></a>

### 作为普通用户获取单个用户

作为普通用户获取单个用户。

先决条件：

- 您必须登录才能使用此端点。

```plaintext
GET /users/:id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | yes | 用户的 ID。 |

示例响应：

```json
{
  "id": 1,
  "username": "john_smith",
  "name": "John Smith",
  "state": "active",
  "locked": false,
  "avatar_url": "http://localhost:3000/uploads/user/avatar/1/cd8.jpeg",
  "web_url": "http://localhost:3000/john_smith",
  "created_at": "2012-05-23T08:00:58Z",
  "bio": "",
  "bot": false,
  "location": null,
  "public_email": "john@example.com",
  "linkedin": "",
  "twitter": "",
  "discord": "",
  "github": "",
  "website_url": "",
  "organization": "",
  "job_title": "Operations Specialist",
  "pronouns": "he/him",
  "work_information": null,
  "followers": 1,
  "following": 1,
  "local_time": "3:38 PM",
  "is_followed": false
}
```

<a id="as-an-administrator-1"></a>

### 作为管理员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 响应中的 `created_by` 字段在极狐GitLab 15.6 引入。
- 响应中的 `email_reset_offered_at` 字段在极狐GitLab 16.7 引入。
- 响应中的 `email_reset_offered_at` 字段在极狐GitLab 18.3 移除。

{{< /history >}}

作为管理员获取单个用户。

```plaintext
GET /users/:id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | yes | 用户的 ID。 |

示例响应：

```json
{
  "id": 1,
  "username": "john_smith",
  "email": "john@example.com",
  "name": "John Smith",
  "state": "active",
  "locked": false,
  "avatar_url": "http://localhost:3000/uploads/user/avatar/1/index.jpg",
  "web_url": "http://localhost:3000/john_smith",
  "created_at": "2012-05-23T08:00:58Z",
  "is_admin": false,
  "bio": "",
  "location": null,
  "public_email": "john@example.com",
  "linkedin": "",
  "twitter": "",
  "discord": "",
  "github": "",
  "website_url": "",
  "organization": "",
  "job_title": "Operations Specialist",
  "pronouns": "he/him",
  "work_information": null,
  "followers": 1,
  "following": 1,
  "local_time": "3:38 PM",
  "last_sign_in_at": "2012-06-01T11:41:01Z",
  "confirmed_at": "2012-05-23T09:05:22Z",
  "theme_id": 1,
  "last_activity_on": "2012-05-23",
  "color_scheme_id": 2,
  "projects_limit": 100,
  "current_sign_in_at": "2012-06-02T06:36:55Z",
  "note": "DMCA Request: 2018-11-05 | DMCA Violation | Abuse | https://gitlab.zendesk.com/agent/tickets/123",
  "identities": [
    {"provider": "github", "extern_uid": "2435223452345"},
    {"provider": "bitbucket", "extern_uid": "john.smith"},
    {"provider": "google_oauth2", "extern_uid": "8776128412476123468721346"}
  ],
  "can_create_group": true,
  "can_create_project": true,
  "two_factor_enabled": true,
  "external": false,
  "private_profile": false,
  "commit_email": "john-codes@example.com",
  "current_sign_in_ip": "196.165.1.102",
  "last_sign_in_ip": "172.127.2.22",
  "plan": "gold",
  "trial": true,
  "sign_in_count": 1337,
  "namespace_id": 1,
  "created_by": null
}
```

> [!note]
> `plan` 和 `trial` 参数仅在极狐GitLab 企业版中可用。

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到 `shared_runners_minutes_limit`、`is_auditor` 和 `extra_shared_runners_minutes_limit` 参数。

```json
{
  "id": 1,
  "username": "john_smith",
  "is_auditor": false,
  "shared_runners_minutes_limit": 133,
  "extra_shared_runners_minutes_limit": 133,
  ...
}
```

[JihuLab.com 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到 `group_saml` 选项和 `provisioned_by_group_id` 参数：

```json
{
  "id": 1,
  "username": "john_smith",
  "shared_runners_minutes_limit": 133,
  "extra_shared_runners_minutes_limit": 133,
  "identities": [
    {"provider": "github", "extern_uid": "2435223452345"},
    {"provider": "bitbucket", "extern_uid": "john.smith"},
    {"provider": "google_oauth2", "extern_uid": "8776128412476123468721346"},
    {"provider": "group_saml", "extern_uid": "123789", "saml_provider_id": 10}
  ],
  "provisioned_by_group_id": 123789
  ...
}
```

[JihuLab.com 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到 `scim_identities` 参数：

```json
{
  ...
  "extra_shared_runners_minutes_limit": null,
  "scim_identities": [
      {"extern_uid": "2435223452345", "group_id": "3", "active": true},
      {"extern_uid": "john.smith", "group_id": "42", "active": false}
    ]
  ...
}
```

管理员可以使用 `created_by` 参数查看用户账户是如何创建的：

- [由管理员手动创建](../user/profile/account/create_accounts.md#create-a-user-in-the-admin-area)。
- 作为[项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)创建。

如果返回的值为 `null`，则该账户是由用户自行注册创建的。

您可以使用以下方式在响应中包含用户的[自定义属性](custom_attributes.md)：

```plaintext
GET /users/:id?with_custom_attributes=true
```

<a id="retrieve-the-current-user"></a>

## 获取当前用户

获取当前用户。

<a id="as-a-regular-user-1"></a>

### 作为普通用户

获取您的用户详情。

```plaintext
GET /user
```

示例响应：

```json
{
  "id": 1,
  "username": "john_smith",
  "email": "john@example.com",
  "name": "John Smith",
  "state": "active",
  "locked": false,
  "avatar_url": "http://localhost:3000/uploads/user/avatar/1/index.jpg",
  "web_url": "http://localhost:3000/john_smith",
  "created_at": "2012-05-23T08:00:58Z",
  "bio": "",
  "location": null,
  "public_email": "john@example.com",
  "linkedin": "",
  "twitter": "",
  "discord": "",
  "github": "",
  "website_url": "",
  "organization": "",
  "job_title": "",
  "pronouns": "he/him",
  "bot": false,
  "work_information": null,
  "followers": 0,
  "following": 0,
  "local_time": "3:38 PM",
  "last_sign_in_at": "2012-06-01T11:41:01Z",
  "confirmed_at": "2012-05-23T09:05:22Z",
  "theme_id": 1,
  "last_activity_on": "2012-05-23",
  "color_scheme_id": 2,
  "projects_limit": 100,
  "current_sign_in_at": "2012-06-02T06:36:55Z",
  "identities": [
    {"provider": "github", "extern_uid": "2435223452345"},
    {"provider": "bitbucket", "extern_uid": "john_smith"},
    {"provider": "google_oauth2", "extern_uid": "8776128412476123468721346"}
  ],
  "can_create_group": true,
  "can_create_project": true,
  "two_factor_enabled": true,
  "external": false,
  "private_profile": false,
  "commit_email": "admin@example.com",
  "preferred_language": "en"
}
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到 `shared_runners_minutes_limit`、`extra_shared_runners_minutes_limit` 参数。

<a id="as-an-administrator-2"></a>

### 作为管理员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 响应中的 `created_by` 字段在极狐GitLab 15.6 引入。
- 响应中的 `email_reset_offered_at` 字段在极狐GitLab 16.7 引入。
- 响应中的 `email_reset_offered_at` 字段在极狐GitLab 18.3 移除。

{{< /history >}}

获取您的用户详情，或其他用户的详情。

```plaintext
GET /user
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `sudo` | integer | no | 要以其身份进行调用的用户 ID。 |

```json
{
  "id": 1,
  "username": "john_smith",
  "email": "john@example.com",
  "name": "John Smith",
  "state": "active",
  "locked": false,
  "avatar_url": "http://localhost:3000/uploads/user/avatar/1/index.jpg",
  "web_url": "http://localhost:3000/john_smith",
  "created_at": "2012-05-23T08:00:58Z",
  "is_admin": true,
  "bio": "",
  "location": null,
  "public_email": "john@example.com",
  "linkedin": "",
  "twitter": "",
  "discord": "",
  "github": "",
  "website_url": "",
  "organization": "",
  "job_title": "",
  "last_sign_in_at": "2012-06-01T11:41:01Z",
  "confirmed_at": "2012-05-23T09:05:22Z",
  "theme_id": 1,
  "last_activity_on": "2012-05-23",
  "color_scheme_id": 2,
  "projects_limit": 100,
  "current_sign_in_at": "2012-06-02T06:36:55Z",
  "identities": [
    {"provider": "github", "extern_uid": "2435223452345"},
    {"provider": "bitbucket", "extern_uid": "john.smith"},
    {"provider": "google_oauth2", "extern_uid": "8776128412476123468721346"}
  ],
  "can_create_group": true,
  "can_create_project": true,
  "two_factor_enabled": true,
  "external": false,
  "private_profile": false,
  "commit_email": "john-codes@example.com",
  "current_sign_in_ip": "196.165.1.102",
  "last_sign_in_ip": "172.127.2.22",
  "namespace_id": 1,
  "created_by": null,
  "note": null
}
```

[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/)的用户还会看到以下参数：

- `shared_runners_minutes_limit`
- `extra_shared_runners_minutes_limit`
- `is_auditor`
- `provisioned_by_group_id`
- `using_license_seat`

<a id="create-a-user"></a>

## 创建用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.3 中引入了创建审计员用户的能力。

{{< /history >}}

创建用户。

先决条件：

- 您必须是管理员。

> [!note]
> `private_profile` 默认值取决于[默认将新用户的个人资料设为私密](../administration/settings/account_and_limit_settings.md#set-profiles-of-new-users-to-private-by-default)设置。`bio` 默认为 `""` 而不是 `null`。

```plaintext
POST /users
```

支持的属性：
| 属性 | 是否必需 | 描述 |
|:-------------------------------------|:---------|:------------|
| `username` | 是 | 用户的用户名 |
| `name` | 是 | 用户的姓名 |
| `email` | 是 | 用户的电子邮件 |
| `password` | 有条件 | 用户的密码。如果未定义 `force_random_password` 或 `reset_password`，则为必需。如果定义了 `force_random_password` 或 `reset_password`，这些设置将优先。 |
| `admin` | 否 | 用户是否为管理员。有效值为 `true` 或 `false`。默认为 false。 |
| `auditor` | 否 | 用户是否为审计员。有效值为 `true` 或 `false`。默认为 false。在极狐GitLab 15.3 中引入。仅限专业版和旗舰版。 |
| `avatar` | 否 | 用户头像的图片文件 |
| `bio` | 否 | 用户个人简介 |
| `can_create_group` | 否 | 用户是否可以创建顶级群组 - true 或 false |
| `color_scheme_id` | 否 | 用户用于文件查看器的配色方案（更多信息，请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-syntax-highlighting-theme)） |
| `commit_email` | 否 | 用户的提交电子邮件地址 |
| `extern_uid` | 否 | 外部 UID |
| `external` | 否 | 将用户标记为外部用户 - true 或 false（默认） |
| `extra_shared_runners_minutes_limit` | 否 | 仅管理员可设置。为此用户提供的额外计算分钟数。仅限专业版和旗舰版。 |
| `force_random_password` | 否 | 如果为 `true`，则将用户密码设置为随机值。可与 `reset_password` 一起使用。优先级高于 `password`。 |
| `group_id_for_saml` | 否 | 已配置 SAML 的群组 ID |
| `linkedin` | 否 | LinkedIn |
| `location` | 否 | 用户的位置 |
| `note` | 否 | 此用户的管理员备注 |
| `organization` | 否 | 组织名称 |
| `private_profile` | 否 | 用户的个人资料是否为私密 - true 或 false。默认值由[一项设置](../administration/settings/account_and_limit_settings.md#set-profiles-of-new-users-to-private-by-default)决定。 |
| `projects_limit` | 否 | 用户可以创建的项目数量 |
| `pronouns` | 否 | 用户的代词 |
| `provider` | 否 | 外部提供商名称 |
| `public_email` | 否 | 用户的公开电子邮件地址 |
| `reset_password` | 否 | 如果为 `true`，则向用户发送重置密码的链接。可与 `force_random_password` 一起使用。优先级高于 `password`。 |
| `shared_runners_minutes_limit` | 否 | 仅管理员可设置。此用户每月的最大计算分钟数。可为 `nil`（默认；继承系统默认值）、`0`（无限制）或 `> 0`。仅限专业版和旗舰版。 |
| `skip_confirmation` | 否 | 跳过确认 - true 或 false（默认） |
| `theme_id` | 否 | 用户的极狐GitLab主题（更多信息，请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-navigation-theme)） |
| `twitter` | 否 | X（原 Twitter）账户 |
| `discord` | 否 | Discord 账户 |
| `github` | 否 | GitHub 用户名 |
| `view_diffs_file_by_file` | 否 | 指示用户每页仅查看一个文件差异的标志 |
| `website_url` | 否 | 网站 URL |

<a id="modify-a-user"></a>

## 修改用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 修改审计员用户的功能在极狐GitLab 15.3 中引入。

{{< /history >}}

修改现有用户。

前提条件：

- 您必须是管理员。

`email` 字段是用户的主电子邮件地址。您只能将此字段更改为该用户已添加的辅助电子邮件地址。要向同一用户添加更多电子邮件地址，请使用[添加电子邮件端点](user_email_addresses.md#add-an-email-address)。

```plaintext
PUT /users/:id
```

支持的属性：

| 属性 | 是否必需 | 描述 |
|:-------------------------------------|:---------|:------------|
| `admin` | 否 | 用户是否为管理员。有效值为 `true` 或 `false`。默认为 false。 |
| `auditor` | 否 | 用户是否为审计员。有效值为 `true` 或 `false`。默认为 false。在极狐GitLab 15.3 中引入。仅限专业版和旗舰版。 |
| `avatar` | 否 | 用户头像的图片文件 |
| `bio` | 否 | 用户个人简介 |
| `can_create_group` | 否 | 用户是否可以创建群组 - true 或 false |
| `color_scheme_id` | 否 | 用户用于文件查看器的配色方案（更多信息，请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-syntax-highlighting-theme)） |
| `commit_email` | 否 | 用户的提交电子邮件。设置为 `_private` 以使用私有提交电子邮件。在极狐GitLab 15.5 中引入。 |
| `email` | 否 | 用户的电子邮件 |
| `extern_uid` | 否 | 外部 UID |
| `external` | 否 | 将用户标记为外部用户 - true 或 false（默认） |
| `extra_shared_runners_minutes_limit` | 否 | 仅管理员可设置。为此用户提供的额外计算分钟数。仅限专业版和旗舰版。 |
| `group_id_for_saml` | 否 | 已配置 SAML 的群组 ID |
| `id` | 是 | 用户的 ID |
| `linkedin` | 否 | LinkedIn |
| `location` | 否 | 用户的位置 |
| `name` | 否 | 用户的姓名 |
| `note` | 否 | 此用户的管理员备注 |
| `organization` | 否 | 组织名称 |
| `password` | 否 | 用户的密码 |
| `private_profile` | 否 | 用户的个人资料是否为私密 - true 或 false。 |
| `projects_limit` | 否 | 限制每个用户可以创建的项目数量 |
| `pronouns` | 否 | 代词 |
| `provider` | 否 | 外部提供商名称 |
| `public_email` | 否 | 用户的公开电子邮件（必须已验证） |
| `shared_runners_minutes_limit` | 否 | 仅管理员可设置。此用户每月的最大计算分钟数。可为 `nil`（默认；继承系统默认值）、`0`（无限制）或 `> 0`。仅限专业版和旗舰版。 |
| `skip_reconfirmation` | 否 | 跳过重新确认 - true 或 false（默认） |
| `theme_id` | 否 | 用户的极狐GitLab主题（更多信息，请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-navigation-theme)） |
| `twitter` | 否 | X（原 Twitter）账户 |
| `discord` | 否 | Discord 账户 |
| `github` | 否 | GitHub 用户名 |
| `username` | 否 | 用户的用户名 |
| `view_diffs_file_by_file` | 否 | 指示用户每页仅查看一个文件差异的标志 |
| `website_url` | 否 | 网站 URL |

如果您更新了用户的密码，他们下次登录时将被强制更改密码。

即使在某些情况下返回 `409`（冲突）更合适，也会返回 `404` 错误。例如，将电子邮件地址重命名为已存在的地址时。

<a id="delete-a-user"></a>

## 删除用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

删除用户。

前提条件：

- 您必须是管理员。

返回：

- 如果操作成功，则返回 `204 No Content` 状态码。
- 如果未找到资源，则返回 `404`。
- 如果无法软删除用户，则返回 `409`。

```plaintext
DELETE /users/:id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:--------------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户的 ID |
| `hard_delete` | boolean | 否 | 如果为 true，则通常会[移至幽灵用户](../user/profile/account/delete_account.md#associated-records)的贡献将被删除，同时删除仅由此用户拥有的群组。 |

<a id="retrieve-your-user-status"></a>

## 获取您的用户状态

获取您的用户状态。

前提条件：

- 您必须已认证。

```plaintext
GET /user/status
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/status"
```

示例响应：

```json
{
  "emoji":"coffee",
  "availability":"busy",
  "message":"I crave coffee :coffee:",
  "message_html": "I crave coffee <gl-emoji title=\"hot beverage\" data-name=\"coffee\" data-unicode-version=\"4.0\">☕</gl-emoji>",
  "clear_status_at": null
}
```

<a id="retrieve-the-status-of-a-user"></a>

## 获取用户的状态

获取用户的状态。您可以在不进行认证的情况下访问此端点。

```plaintext
GET /users/:id_or_username/status
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------------|:-------|:---------|:------------|
| `id_or_username` | string | 是 | 要获取状态的用户的 ID 或用户名 |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/users/<username>/status"
```

示例响应：

```json
{
  "emoji":"coffee",
  "availability":"busy",
  "message":"I crave coffee :coffee:",
  "message_html": "I crave coffee <gl-emoji title=\"hot beverage\" data-name=\"coffee\" data-unicode-version=\"4.0\">☕</gl-emoji>",
  "clear_status_at": null
}
```

<a id="set-your-user-status"></a>

## 设置您的用户状态

设置您的用户状态。

前提条件：

- 您必须已认证。

```plaintext
PUT /user/status
PATCH /user/status
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:---------------------|:-------|:---------|:------------|
| `emoji` | string | 否 | 用作状态的 emoji 名称。如果省略，则使用 `speech_balloon`。Emoji 名称可以是 [Gemojione 索引](https://github.com/bonusly/gemojione/blob/master/config/index.json)中指定的名称之一。 |
| `message` | string | 否 | 设置为状态的消息。也可以包含 emoji 代码。不能超过 100 个字符。 |
| `availability` | string | 否 | 用户的可用性。可能的值：`busy` 和 `not_set`。 |
| `clear_status_after` | string | 否 | 在给定时间间隔后自动清除状态，允许的值：`30_minutes`、`3_hours`、`8_hours`、`1_day`、`3_days`、`7_days`、`30_days` |

`PUT` 和 `PATCH` 的区别：

- 使用 `PUT` 时，任何未传递的参数都将设置为 `null`，因此被清除。
- 使用 `PATCH` 时，任何未传递的参数都将被忽略。显式传递 `null` 以清除字段。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/status" \
  --data "clear_status_after=1_day" \
  --data "emoji=coffee" \
  --data "message=I crave coffee" \
  --data "availability=busy"
```

示例响应：

```json
{
  "emoji":"coffee",
  "availability":"busy",
  "message":"I crave coffee",
  "message_html": "I crave coffee",
  "clear_status_at":"2021-02-15T10:49:01.311Z"
}
```

<a id="retrieve-your-user-preferences"></a>

## 获取您的用户偏好设置

获取您的用户偏好设置。

前提条件：

- 您必须已认证。

```plaintext
GET /user/preferences
```

示例响应：

```json
{
  "id": 1,
  "user_id": 1,
  "view_diffs_file_by_file": true,
  "show_whitespace_in_diffs": false,
  "pass_user_identities_to_ci_jwt": false
}
```

<a id="update-your-user-preferences"></a>

## 更新您的用户偏好设置

更新您的用户偏好设置。

前提条件：

- 您必须已认证。

```plaintext
PUT /user/preferences
```

```json
{
  "id": 1,
  "user_id": 1,
  "view_diffs_file_by_file": true,
  "show_whitespace_in_diffs": false,
  "pass_user_identities_to_ci_jwt": false
}
```

支持的属性：

| 属性 | 是否必需 | 描述 |
|:---------------------------------|:---------|:------------|
| `view_diffs_file_by_file` | 是 | 指示用户每页仅查看一个文件差异的标志。 |
| `show_whitespace_in_diffs` | 是 | 指示用户在差异中查看空白更改的标志。 |
| `pass_user_identities_to_ci_jwt` | 是 | 指示用户将其外部身份作为 CI 信息传递的标志。此属性不包含足够的信息来在外部系统中识别或授权用户。该属性是极狐GitLab 内部的，不得传递给第三方服务。有关更多信息和示例，请参见[令牌负载](../ci/secrets/id_token_authentication.md#token-payload)。 |

<a id="upload-an-avatar-for-yourself"></a>

## 为自己上传头像

{{< history >}}

- 在极狐GitLab 17.0 中引入。

{{< /history >}}

为自己上传头像。

前提条件：

- 您必须已认证。
- 文件大小必须为 200 KB 或更小。理想的图像尺寸为 192 x 192 像素。
- 图像必须是以下文件类型之一：
  - `.bmp`
  - `.gif`
  - `.ico`
  - `.jpeg`
  - `.png`
  - `.tiff`

```plaintext
PUT /user/avatar
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-------|:---------|:------------|
| `avatar` | string | 是 | 要上传的文件。 |

要从文件系统上传头像，请使用 `--form` 参数。这会使 cURL 使用标头 `Content-Type: multipart/form-data` 发布数据。`avatar=` 参数必须指向文件系统上的图像文件，并以 `@` 开头。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/avatar" \
  --form "avatar=@/path/to/your/avatar.png"
```

示例响应：

```json
{
  "avatar_url": "http://gitlab.example.com/uploads/-/system/user/avatar/76/avatar.png",
}
```

返回：

- 如果成功，则返回 `200`。
- 如果文件大小大于 200 KiB，则返回 `400 Bad Request`。

<a id="retrieve-a-count-of-your-assigned-issues-merge-requests-and-reviews"></a>

## 获取分配给您的议题、合并请求和审查的计数

获取分配给您的议题、合并请求和审查的计数。

前提条件：

- 您必须已认证。

支持的属性：

| 属性 | 类型 | 描述 |
|:----------------------------------|:-------|:------------|
| `assigned_issues` | number | 打开并分配给当前用户的议题数量。 |
| `assigned_merge_requests` | number | 活跃并分配给当前用户的合并请求数量。 |
| `merge_requests` | number | 在极狐GitLab 13.8 中[已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/50026)。等同于 `assigned_merge_requests` 并被其取代。 |
| `review_requested_merge_requests` | number | 当前用户被要求审查的合并请求数量。 |
| `todos` | number | 当前用户的待办事项数量。 |

```plaintext
GET /user_counts
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user_counts"
```

示例响应：

```json
{
  "merge_requests": 4,
  "assigned_issues": 15,
  "assigned_merge_requests": 11,
  "review_requested_merge_requests": 0,
  "todos": 1
}
```

<a id="retrieve-a-count-of-a-users-projects-groups-issues-and-merge-requests"></a>

## 获取用户的项目、群组、议题和合并请求的计数

获取用户以下内容的计数列表：

- 项目。
- 群组。
- 议题。
- 合并请求。

管理员可以查询任何用户，但非管理员只能查询自己。

```plaintext
GET /users/:id/associations_count
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户的 ID |

示例响应：

```json
{
  "groups_count": 2,
  "projects_count": 3,
  "issues_count": 8,
  "merge_requests_count": 5
}
```

<a id="list-a-users-activity"></a>

## 列出用户的活动

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 您必须是管理员才能查看具有私密个人资料的用户的活动。

获取具有公开个人资料的用户的最后活动日期，按从旧到新排序。

更新用户事件时间戳（`last_activity_on` 和 `current_sign_in_at`）的活动包括：

- Git HTTP/SSH 活动（例如 clone、push）
- 用户登录极狐GitLab
- 用户访问与仪表板、项目、议题和合并请求相关的页面
- 用户使用 API
- 用户使用 GraphQL API

默认情况下，它显示过去 6 个月内具有公开个人资料的用户的活跃情况，但可以使用 `from` 参数进行修改。

```plaintext
GET /user/activities
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-------|:---------|:------------|
| `from` | string | 否 | 格式为 `YEAR-MM-DD` 的日期字符串。例如 `2016-03-11`。默认为 6 个月前。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/activities"
```

示例响应：

```json
[
  {
    "username": "user1",
    "last_activity_on": "2015-12-14",
    "last_activity_at": "2015-12-14"
  },
  {
    "username": "user2",
    "last_activity_on": "2015-12-15",
    "last_activity_at": "2015-12-15"
  },
  {
    "username": "user3",
    "last_activity_on": "2015-12-16",
    "last_activity_at": "2015-12-16"
  }
]
```

`last_activity_at` 已弃用。请改用 `last_activity_on`。

<a id="list-projects-and-groups-that-a-user-is-a-member-of"></a>

## 列出用户所属的项目和群组

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 您必须是管理员。

列出用户所属的所有项目和群组。

返回成员资格的 `source_id`、`source_name`、`source_type` 和 `access_level`。来源可以是 `Namespace`（代表群组）或 `Project` 类型。响应仅代表直接成员资格。继承的成员资格（例如在子群组中）不包括在内。访问级别由整数值表示：

- `0`：无访问权限
- `5`：最小权限
- `10`：访客
- `15`：计划者
- `20`：报告者
- `30`：开发者
- `40`：维护者
- `50`：所有者

```plaintext
GET /users/:id/memberships
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | 是 | 指定用户的 ID |
| `type` | string | 否 | 按类型过滤成员资格。可以是 `Project` 或 `Namespace` |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/:user_id/memberships"
```

示例响应：

```json
[
  {
    "source_id": 1,
    "source_name": "Project one",
    "source_type": "Project",
    "access_level": "20"
  },
  {
    "source_id": 3,
    "source_name": "Group three",
    "source_type": "Namespace",
    "access_level": "20"
  }
]
```

返回：

- 成功时返回 `200 OK`。
- 如果找不到用户，则返回 `404 User Not Found`。
- 如果不是由管理员请求，则返回 `403 Forbidden`。
- 如果请求的类型不受支持，则返回 `400 Bad Request`。

<a id="disable-two-factor-authentication-for-a-user"></a>

## 为用户禁用双因素认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.2 中引入。

{{< /history >}}

前提条件：

- 您必须是管理员。

为指定用户禁用双因素认证 (2FA)。

管理员无法使用 API 为自己的用户账户或其他管理员禁用 2FA。相反，他们可以[使用 Rails 控制台](../security/two_factor_authentication.md#for-a-single-user)禁用管理员的 2FA。

```plaintext
PATCH /users/:id/disable_two_factor
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户的 ID |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/1/disable_two_factor"
```

返回：

- 成功时返回 `204 No content`。
- 
| 属性 | 类型 | 必需 | 描述 |
|:-------------------|:-------------|:---------|:------------|
| `runner_type` | string | 是 | 指定 Runner 的范围；`instance_type`、`group_type` 或 `project_type`。 |
| `group_id` | integer | 否 | 在其中创建 Runner 的群组 ID。如果 `runner_type` 为 `group_type` 则为必需项。 |
| `project_id` | integer | 否 | 在其中创建 Runner 的项目 ID。如果 `runner_type` 为 `project_type` 则为必需项。 |
| `description` | string | 否 | Runner 的描述。 |
| `paused` | boolean | 否 | 指定 Runner 是否忽略新的作业。 |
| `locked` | boolean | 否 | 指定 Runner 是否应被当前项目锁定。 |
| `run_untagged` | boolean | 否 | 指定 Runner 是否应处理未标记的作业。 |
| `tag_list` | string | 否 | 以逗号分隔的 Runner 标签列表。 |
| `access_level` | string | 否 | Runner 的访问级别；`not_protected` 或 `ref_protected`。 |
| `maximum_timeout` | integer | 否 | 限制 Runner 运行作业的最大时间（以秒为单位）。 |
| `maintenance_note` | string | 否 | Runner 的自由格式维护备注（1024 个字符）。 |
| `token_expires_at` | datetime | 否 | Runner 认证令牌的过期时间，采用 ISO 8601 格式。必须介于未来 5 分钟到 15 天之间。如已配置，不能超过实例、群组或项目级别的限制。仅适用于初始令牌。轮换后的令牌使用设置中计算出的有效期。（专业版及以上） |
| `token_rotation_deadline` | datetime | 否 | 在此截止时间后，令牌轮换请求将被拒绝。需要 `token_expires_at`。必须小于或等于 `token_expires_at`。将两者设置为相同值会禁用令牌轮换。成功轮换后清除。（专业版及以上） |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/runners" \
  --data "runner_type=instance_type"
```

示例响应：

```json
{
    "id": 9171,
    "token": "<access-token>",
    "token_expires_at": null
}
```

## 从用户中删除认证身份

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用与该身份关联的提供者名称删除用户的认证身份。

先决条件：

- 您必须是管理员。

```plaintext
DELETE /users/:id/identities/:provider
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:-----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户 ID |
| `provider` | string | 是 | 外部提供者名称 |

## 创建支持 PIN

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.8。

{{< /history >}}

为您的用户账户创建支持 PIN。该 PIN 在创建后七天过期。极狐GitLab 支持团队可能会要求您提供此 PIN 以验证您的身份。

先决条件：

- 您必须已通过认证。

```plaintext
POST /user/support_pin
```

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/support_pin"
```

示例响应：

```json
{
  "pin":"123456",
  "expires_at":"2025-02-27T22:06:57Z"
}
```

## 获取支持 PIN 的详细信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.8。

{{< /history >}}

获取您账户支持 PIN 的详细信息。极狐GitLab 支持团队可能会要求您提供此 PIN 以验证您的身份。

先决条件：

- 您必须已通过认证。

```plaintext
GET /user/support_pin
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/user/support_pin"
```

示例响应：

```json
{
  "pin":"123456",
  "expires_at":"2025-02-27T22:06:57Z"
}
```

## 获取特定用户的支持 PIN

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.8。

{{< /history >}}

获取指定用户支持 PIN 的详细信息。极狐GitLab 支持团队可能会要求您提供此 PIN 以验证您的身份。

先决条件：

- 您必须是管理员。

```plaintext
GET /users/:id/support_pin
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/1234/support_pin"
```

示例响应：

```json
{
  "pin":"123456",
  "expires_at":"2025-02-27T22:06:57Z"
}
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户账户 ID |

## 撤销特定用户的支持 PIN

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.11。

{{< /history >}}

在自然过期之前撤销指定用户的支持 PIN。这将立即过期并移除该 PIN。

先决条件：

- 您必须是管理员。

```plaintext
POST /users/:id/support_pin/revoke
```

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/1234/support_pin/revoke"
```

示例响应：

如果成功，返回 `202 Accepted`。

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户 ID |