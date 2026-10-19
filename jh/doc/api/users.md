---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户 API
description: 极狐GitLab 用户 API 可以创建、修改、搜索和删除用户账号。它还支持管理员操作和 SCIM 预配。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与极狐GitLab 上的用户账号进行交互。这些端点可帮助管理[您的账号](../user/profile/_index.md)或[其他用户的账号](../administration/administer_users.md)。

<a id="list-all-users"></a>

## 列出所有用户

列出所有用户。

使用[分页参数](rest/_index.md#offset-based-pagination) `page` 和 `per_page` 来限制用户列表。

<a id="as-a-regular-user"></a>

### 作为普通用户

```plaintext
GET /users
```

支持的属性：

| 属性              | 类型     | 是否必需 | 描述 |
|:-----------------------|:---------|:---------|:------------|
| `username`             | string   | 否       | 检索具有指定用户名的单个用户。 |
| `public_email`         | string   | 否       | 检索具有指定公开邮箱的单个用户。 |
| `search`               | string   | 否       | 按姓名、用户名或公开邮箱搜索用户。 |
| `active`               | boolean  | 否       | 仅筛选活跃用户。默认为 `false`。 |
| `external`             | boolean  | 否       | 仅筛选外部用户。默认为 `false`。 |
| `blocked`              | boolean  | 否       | 仅筛选已阻止的用户。默认为 `false`。 |
| `humans`               | boolean  | 否       | 仅筛选非机器人且非内部用户的普通用户。默认为 `false`。 |
| `created_after`        | DateTime | 否       | 返回在指定时间之后创建的用户。 |
| `created_before`       | DateTime | 否       | 返回在指定时间之前创建的用户。 |
| `exclude_active`       | boolean  | 否       | 仅筛选非活跃用户。默认为 `false`。 |
| `exclude_external`     | boolean  | 否       | 仅筛选非外部用户。默认为 `false`。 |
| `exclude_humans`       | boolean  | 否       | 仅筛选机器人或内部用户。默认为 `false`。 |
| `exclude_internal`     | boolean  | 否       | 仅筛选非内部用户。默认为 `false`。 |
| `without_project_bots` | boolean  | 否       | 筛选用户时排除项目机器人。默认为 `false`。 |

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

<!-- vale gitlab_base.OxfordComma = NO -->
此端点支持[键集分页](rest/_index.md#keyset-based-pagination)。在极狐GitLab 17.0 及更高版本中，对于 50,000 及以上的响应，必须使用键集分页。
<!-- vale gitlab_base.OxfordComma = YES -->

您还可以使用 `?search=` 按姓名、用户名或公开邮箱搜索用户。例如，`/users?search=John`。当您搜索：

- 公开邮箱时，必须使用完整邮箱地址才能获得精确匹配。
- 姓名或用户名时，不必获得精确匹配，因为这是模糊搜索。

此外，您可以按用户名查找用户：

```plaintext
GET /users?username=:username
```

例如：

```plaintext
GET /users?username=jack_smith
```

> [!note]
> 用户名搜索不区分大小写。

此外，您可以根据状态 `blocked` 和 `active` 筛选用户。它不支持 `active=false` 或 `blocked=false`。

```plaintext
GET /users?active=true
```

```plaintext
GET /users?blocked=true
```

此外，您只能使用 `external=true` 搜索外部用户。它不支持 `external=false`。

```plaintext
GET /users?external=true
```

极狐GitLab 支持机器人用户，例如[告警机器人](../operations/incident_management/integrations.md)或[支持机器人](../user/project/service_desk/configure.md#support-bot-user)。您可以使用 `exclude_internal=true` 参数从用户列表中排除以下类型的[内部用户](../administration/internal_users.md)：

- 告警机器人
- 支持机器人

但是，此操作不会排除[项目的机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)或[群组的机器人用户](../user/group/settings/group_access_tokens.md#bot-users-for-groups)。

```plaintext
GET /users?exclude_internal=true
```

此外，要从用户列表中排除外部用户，您可以使用参数 `exclude_external=true`。

```plaintext
GET /users?exclude_external=true
```

要排除[项目的机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)和[群组的机器人用户](../user/group/settings/group_access_tokens.md#bot-users-for-groups)，您可以使用参数 `without_project_bots=true`。

```plaintext
GET /users?without_project_bots=true
```

<a id="as-an-administrator"></a>

### 作为管理员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

```plaintext
GET /users
```

您可以使用[所有用户可用的参数](#as-a-regular-user)，以及以下仅管理员可用的附加属性。

支持的属性：

| 属性          | 类型    | 是否必需 | 描述 |
|:-------------------|:--------|:---------|:------------|
| `search`           | string  | 否       | 按姓名、用户名、公开邮箱或私有邮箱搜索用户。 |
| `extern_uid`       | string  | 否       | 检索具有指定外部身份验证提供商 UID 的单个用户。 |
| `provider`         | string  | 否       | 外部提供商。 |
| `order_by`         | string  | 否       | 按 `id`、`name`、`username`、`created_at` 或 `updated_at` 字段对用户排序。默认为 `id`。 |
| `sort`             | string  | 否       | 按 `asc` 或 `desc` 顺序对用户排序。默认为 `desc`。 |
| `two_factor`       | string  | 否       | 按双因素认证状态筛选用户。筛选值为 `enabled` 或 `disabled`。默认返回所有用户。 |
| `without_projects` | boolean | 否       | 筛选没有项目的用户。默认为 `false`，即返回有项目和没有项目的所有用户。 |
| `admins`           | boolean | 否       | 仅返回管理员。默认为 `false`。 |
| `auditors`         | boolean | 否       | 仅返回审计员用户。默认为 `false`。未提供时返回所有用户。仅限专业版和旗舰版。 |
| `skip_ldap`        | boolean | 否       | 跳过 LDAP 用户。仅限专业版和旗舰版。 |

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
    "provisioned_by_project_id": null,
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
    "provisioned_by_project_id": null,
    "created_by": null
  }
]
```

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `shared_runners_minutes_limit`、`extra_shared_runners_minutes_limit`、`is_auditor` 和 `using_license_seat` 参数。

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

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `group_saml` 提供商选项和 `provisioned_by_group_id` 参数：

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

您还可以使用 `?search=` 按姓名、用户名或邮箱搜索用户。例如，`/users?search=John`。当您搜索：

- 邮箱时，必须使用完整邮箱地址才能获得精确匹配。作为管理员，您可以同时搜索公开和私有邮箱地址。
- 姓名或用户名时，不必获得精确匹配，因为这是模糊搜索。

您可以按外部 UID 和提供商查找用户：

```plaintext
GET /users?extern_uid=:extern_uid&provider=:provider
```

例如：

```plaintext
GET /users?extern_uid=1234567&provider=github
```

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户可以使用 `scim` 提供商：

```plaintext
GET /users?extern_uid=1234567&provider=scim
```

您可以使用以下方式按创建日期时间范围搜索用户：

```plaintext
GET /users?created_before=2001-01-02T00:00:00.060Z&created_after=1999-01-02T00:00:00.060
```

您可以使用以下方式搜索没有项目的用户：`/users?without_projects=true`

您可以使用以下方式按[自定义属性](custom_attributes.md)筛选：

```plaintext
GET /users?custom_attributes[key]=value&custom_attributes[other_key]=other_value
```

您可以使用以下方式在响应中包含用户的[自定义属性](custom_attributes.md)：

```plaintext
GET /users?with_custom_attributes=true
```

您可以使用 `created_by` 参数查看用户账号是否由以下方式创建：

- [由管理员手动创建](../user/profile/account/create_accounts.md#create-a-user-in-the-admin-area)。
- 作为[项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)创建。

如果返回值为 `null`，则该账号是由自行注册账号的用户创建的。

<a id="retrieve-a-single-user"></a>

## 检索单个用户

检索单个用户。

<a id="retrieve-a-single-user-as-a-regular-user"></a>

### 作为普通用户检索单个用户

作为普通用户检索单个用户。

先决条件：

- 您必须登录才能使用此端点。

```plaintext
GET /users/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户的 ID。 |

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
  "bio_html": "",
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

作为管理员检索单个用户。

```plaintext
GET /users/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户的 ID。 |

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
  "bio_html": "",
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
  "provisioned_by_project_id": null,
  "created_by": null
}
```

> [!note]
> `plan` 和 `trial` 参数仅在 极狐GitLab 企业版上可用。

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `shared_runners_minutes_limit`、`is_auditor` 和 `extra_shared_runners_minutes_limit` 参数。

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

使用 [JihuLab.com 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `group_saml` 选项和 `provisioned_by_group_id` 参数：

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

使用 [JihuLab.com 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `scim_identities` 参数：

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

管理员可以使用 `created_by` 参数查看用户账号是否由以下方式创建：

- [由管理员手动创建](../user/profile/account/create_accounts.md#create-a-user-in-the-admin-area)。
- 作为[项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)创建。

如果返回值为 `null`，则该账号是由自行注册账号的用户创建的。

您可以使用以下方式在响应中包含用户的[自定义属性](custom_attributes.md)：

```plaintext
GET /users/:id?with_custom_attributes=true
```

<a id="retrieve-the-current-user"></a>

## 检索当前用户

检索当前用户。

<a id="as-a-regular-user-1"></a>

### 作为普通用户

检索您的用户详情。

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
  "preferred_language": "en",
}
```

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到 `shared_runners_minutes_limit`、`extra_shared_runners_minutes_limit` 参数。

<a id="as-an-administrator-2"></a>

### 作为管理员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

检索您的用户详情，或其他用户的详情。

```plaintext
GET /user
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `sudo`    | integer | 否       | 要代其发起调用的用户 ID。 |

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
    {"provider": "bitbucket", "extern_uid": "john_smith"},
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
  "provisioned_by_project_id": null,
  "created_by": null,
  "note": null
}
```

使用 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)的用户还会看到以下参数：

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

创建用户。

先决条件：

- 您必须是管理员。

> [!note]
> `private_profile` 默认为
> [将新用户的个人资料默认设为私有](../administration/settings/account_and_limit_settings.md#set-profiles-of-new-users-to-private-by-default)
> 设置的值。`bio` 默认为 `""`，而不是 `null`。

```plaintext
POST /users
```

支持的属性：

| 属性                            | 是否必需 | 描述 |
|:-------------------------------------|:---------|:------------|
| `username`                           | 是      | 用户的用户名。 |
| `name`                               | 是      | 用户的姓名。 |
| `email`                              | 是      | 用户的邮箱地址。 |
| `password`                           | 有条件 | 用户的密码。如果 `force_random_password` 和 `reset_password` 均未定义，则必须提供。若定义了 `force_random_password` 或 `reset_password`，这些设置优先于 `password`。 |
| `admin`                              | 否       | 用户是否为管理员。有效值为 `true` 或 `false`。默认为 false。 |
| `auditor`                            | 否       | 用户是否为审计员。有效值为 `true` 或 `false`。默认为 false。仅限专业版和旗舰版。 |
| `avatar`                             | 否       | 用户头像的图像文件。 |
| `bio`                                | 否       | 用户的个人简介。 |
| `can_create_group`                   | 否       | 用户是否可以创建顶级群组：true 或 false。 |
| `color_scheme_id`                    | 否       | 用户在文件查看器中的配色方案（详情请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-syntax-highlighting-theme)）。 |
| `commit_email`                       | 否       | 用户的提交邮箱地址。 |
| `extern_uid`                         | 否       | 外部 UID。 |
| `external`                           | 否       | 用户是否标记为外部用户：true 或 false（默认值）。 |
| `extra_shared_runners_minutes_limit` | 否       | 只能由管理员设置。此用户的额外计算分钟数。仅限专业版和旗舰版。 |
| `force_random_password`              | 否       | 如果为 `true`，将用户密码设为随机值。可与 `reset_password` 同用。优先于 `password`。 |
| `group_id_for_saml`                  | 否       | 已配置 SAML 的群组 ID。 |
| `linkedin`                           | 否       | LinkedIn    |
| `location`                           | 否       | 用户的位置。 |
| `note`                               | 否       | 管理员为此用户填写的备注。 |
| `organization`                       | 否       | 组织名称。 |
| `private_profile`                    | 否       | 用户的个人资料是否为私有：true 或 false。默认值由[一项设置](../administration/settings/account_and_limit_settings.md#set-profiles-of-new-users-to-private-by-default)决定。 |
| `projects_limit`                     | 否       | 用户可创建的项目数量。 |
| `pronouns`                           | 否       | 用户的代词。 |
| `provider`                           | 否       | 外部提供商名称。 |
| `public_email`                       | 否       | 用户的公开邮箱地址。 |
| `reset_password`                     | 否       | 如果为 `true`，向用户发送重置密码链接。可与 `force_random_password` 同用。优先于 `password`。 |
| `shared_runners_minutes_limit`       | 否       | 只能由管理员设置。此用户每月计算分钟数的上限。可以是 `nil`（默认值，继承系统默认值）、`0`（无限制）或 `> 0`。仅限专业版和旗舰版。 |
| `skip_confirmation`                  | 否       | 是否跳过确认：true 或 false（默认值）。 |
| `theme_id`                           | 否       | 用户的极狐GitLab 主题（详情请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-navigation-theme)）。 |
| `twitter`                            | 否       | X（原 Twitter）账号。 |
| `discord`                            | 否       | Discord 账号。 |
| `github`                             | 否       | GitHub 用户名。 |
| `view_diffs_file_by_file`            | 否       | 是否每页仅显示一个文件差异的标志。 |
| `website_url`                        | 否       | 网站 URL。 |

<a id="modify-a-user"></a>

## 修改用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

修改现有用户。

先决条件：

- 您必须是管理员。

`email` 字段是用户的主要邮箱地址。您只能将此字段更改为该用户已添加的辅助邮箱地址。要向同一用户添加更多邮箱地址，请使用[添加邮箱端点](user_email_addresses.md#add-an-email-address)。

```plaintext
PUT /users/:id
```

支持的属性：

| 属性                            | 是否必需 | 描述 |
|:-------------------------------------|:---------|:------------|
| `admin`                              | 否       | 用户是否为管理员。有效值为 `true` 或 `false`。默认为 false。 |
| `auditor`                            | 否       | 用户是否为审计员。有效值为 `true` 或 `false`。默认为 false。仅限专业版和旗舰版。 |
| `avatar`                             | 否       | 用户头像的图像文件。 |
| `bio`                                | 否       | 用户的个人简介。 |
| `can_create_group`                   | 否       | 用户是否可以创建群组：true 或 false。 |
| `color_scheme_id`                    | 否       | 用户在文件查看器中的配色方案（详情请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-syntax-highlighting-theme)）。 |
| `commit_email`                       | 否       | 用户的提交邮箱地址。设为 `_private` 可使用私有提交邮箱地址。 |
| `email`                              | 否       | 用户的邮箱地址。 |
| `extern_uid`                         | 否       | 外部 UID。 |
| `external`                           | 否       | 用户是否标记为外部用户：true 或 false（默认值）。 |
| `extra_shared_runners_minutes_limit` | 否       | 只能由管理员设置。此用户的额外计算分钟数。仅限专业版和旗舰版。 |
| `group_id_for_saml`                  | 否       | 已配置 SAML 的群组 ID。 |
| `id`                                 | 是      | 用户的 ID。 |
| `linkedin`                           | 否       | LinkedIn    |
| `location`                           | 否       | 用户的位置。 |
| `name`                               | 否       | 用户的姓名。 |
| `note`                               | 否       | 管理员为此用户填写的备注。 |
| `organization`                       | 否       | 组织名称。 |
| `password`                           | 否       | 用户的密码。 |
| `private_profile`                    | 否       | 用户的个人资料是否为私有：true 或 false。 |
| `projects_limit`                     | 否       | 限制每个用户可创建的项目数量。 |
| `pronouns`                           | 否       | Pronouns    |
| `provider`                           | 否       | 外部提供商名称。 |
| `public_email`                       | 否       | 用户的公开邮箱地址（必须已验证）。 |
| `shared_runners_minutes_limit`       | 否       | 只能由管理员设置。此用户每月计算分钟数的上限。可以是 `nil`（默认值，继承系统默认值）、`0`（无限制）或 `> 0`。仅限专业版和旗舰版。 |
| `skip_reconfirmation`                | 否       | 是否跳过重新确认：true 或 false（默认值）。 |
| `theme_id`                           | 否       | 用户的极狐GitLab 主题（详情请参见[用户偏好设置文档](../user/profile/preferences.md#change-the-navigation-theme)）。 |
| `twitter`                            | 否       | X（原 Twitter）账号。 |
| `discord`                            | 否       | Discord 账号。 |
| `github`                             | 否       | GitHub 用户名。 |
| `username`                           | 否       | 用户的用户名。 |
| `view_diffs_file_by_file`            | 否       | 是否每页仅显示一个文件差异的标志。 |
| `website_url`                        | 否       | 网站 URL。 |

如果您更新用户的密码，则系统会强制他们在下次登录时更改密码。

返回 `404` 错误，即使在 `409`（冲突）更合适的情况下也是如此。例如，将邮箱地址重命名为已存在的邮箱地址时。

<a id="delete-a-user"></a>

## 删除用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

删除用户。

先决条件：

- 您必须是管理员。

返回：

- 如果操作成功，返回 `204 No Content` 状态码。
- 如果未找到资源，返回 `404`。
- 如果无法软删除该用户，返回 `409`。

```plaintext
DELETE /users/:id
```

支持的属性：

| 属性     | 类型    | 是否必需 | 描述 |
|:--------------|:--------|:---------|:------------|
| `id`          | integer | 是      | 用户的 ID。 |
| `hard_delete` | boolean | 否       | 如果为 true，则删除通常会[移至 Ghost User](../user/profile/account/delete_account.md#associated-records) 的贡献，以及仅由该用户拥有的群组。 |

<a id="retrieve-your-user-status"></a>

## 检索您的用户状态

检索您的用户状态。

先决条件：

- 您必须已通过身份验证。

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

## 检索用户的状态

检索用户的状态。您无需身份验证即可访问此端点。

```plaintext
GET /users/:id_or_username/status
```

支持的属性：

| 属性        | 类型   | 是否必需 | 描述 |
|:-----------------|:-------|:---------|:------------|
| `id_or_username` | string | 是      | 要获取其状态的用户 ID 或用户名。 |

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

先决条件：

- 您必须已通过身份验证。

```plaintext
PUT /user/status
PATCH /user/status
```

支持的属性：

| 属性            | 类型   | 是否必需 | 描述 |
|:---------------------|:-------|:---------|:------------|
| `emoji`              | string | 否       | 用作状态的表情符号名称。若省略，使用 `speech_balloon`。名称可以是 [Gemojione 索引](https://github.com/bonusly/gemojione/blob/master/config/index.json)中指定的名称之一。 |
| `message`            | string | 否       | 要设置的状态消息。也可以包含表情符号代码。不得超过 100 个字符。 |
| `availability`       | string | 否       | 用户的可用状态。可选值：`busy` 和 `not_set`。 |
| `clear_status_after` | string | 否       | 在指定时间间隔后自动清除状态。允许值：`30_minutes`、`3_hours`、`8_hours`、`1_day`、`3_days`、`7_days`、`30_days`。 |

`PUT` 和 `PATCH`的区别：

- 使用 `PUT` 时，任何未传递的参数都会设置为 `null`，因此会被清除。
- 使用 `PATCH` 时，任何未传递的参数都会被忽略。要清除字段，请显式传递 `null`。

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

## 检索您的用户偏好设置

检索您的用户偏好设置。

先决条件：

- 您必须已通过身份验证。

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

先决条件：

- 您必须已通过身份验证。

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

| 属性                        | 是否必需 | 描述 |
|:---------------------------------|:---------|:------------|
| `view_diffs_file_by_file`        | 是      | 用户是否每页仅查看一个文件差异的标志。 |
| `show_whitespace_in_diffs`       | 是      | 用户是否在差异中查看空白字符变化的标志。 |
| `pass_user_identities_to_ci_jwt` | 是      | 用户是否将外部身份作为 CI 信息传递的标志。此属性包含的信息不足以在外部系统中识别用户或授权用户。此属性属于极狐GitLab 内部信息，不得传给第三方服务。更多信息和示例，请参见[令牌载荷](../ci/secrets/id_token_authentication.md#token-payload)。 |

<a id="upload-an-avatar-for-yourself"></a>

## 为您自己上传头像

为您自己上传头像。

先决条件：

- 您必须已通过身份验证。
- 您的文件必须小于或等于 200 KB。理想图像尺寸为 192 x 192 像素。
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

| 属性 | 类型   | 是否必需 | 描述 |
|:----------|:-------|:---------|:------------|
| `avatar`  | string | 是      | 要上传的文件。 |

要从您的文件系统上传头像，请使用 `--form` 参数。这会使 cURL 使用请求头 `Content-Type: multipart/form-data` 提交数据。`avatar=` 参数必须指向您文件系统上的图像文件，并在前面加上 `@`。

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

- 如果成功，返回 `200`。
- 如果文件大小超过 200 KiB，返回 `400 Bad Request`。

<a id="retrieve-a-count-of-your-assigned-issues-merge-requests-and-reviews"></a>

## 检索分配给您的议题、合并请求和评审的数量

检索分配给您的议题、合并请求和评审的数量。

先决条件：

- 您必须已通过身份验证。

支持的属性：

| 属性                         | 类型   | 描述 |
|:----------------------------------|:-------|:------------|
| `assigned_issues`                 | number | 已打开且分配给当前用户的议题数量。 |
| `assigned_merge_requests`         | number | 处于活跃状态且分配给当前用户的合并请求数量。 |
| `merge_requests`                  | number | 在极狐GitLab 13.8 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/50026)。等同于 `assigned_merge_requests`，并已被其替代。 |
| `review_requested_merge_requests` | number | 当前用户被请求评审的合并请求数量。 |
| `todos`                           | number | 当前用户的待办事项数量。 |

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

## 检索用户的项目、群组、议题和合并请求的数量

检索用户以下各项的数量列表：

- 项目。
- 群组。
- 议题。
- 合并请求。

管理员可以查询任何用户，但非管理员只能查询自己。

```plaintext
GET /users/:id/associations_count
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户的 ID。 |

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

先决条件：

- 您必须是管理员才能查看具有私有个人资料的用户的活动。

获取具有公开个人资料的用户的最后活动日期，按从最早到最新排序。

会更新用户事件时间戳（`last_activity_on` 和 `current_sign_in_at`）的活动包括：

- Git HTTP/SSH 活动（例如克隆、推送）
- 用户登录极狐GitLab
- 用户访问与仪表板、项目、议题和合并请求相关的页面
- 用户使用 API
- 用户使用 GraphQL API

默认情况下，它会显示具有公开个人资料的用户在过去 6 个月内的活动，但可以使用 `from` 参数进行修改。

```plaintext
GET /user/activities
```

支持的属性：

| 属性 | 类型   | 是否必需 | 描述 |
|:----------|:-------|:---------|:------------|
| `from`    | string | 否       | 格式为 `YEAR-MM-DD` 的日期字符串，例如 `2016-03-11`。默认为六个月前。 |

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

先决条件：

- 您必须是管理员。

列出用户所属的所有项目和群组。

返回成员关系的 `source_id`、`source_name`、`source_type` 和 `access_level`。来源类型可以是 `Namespace`（表示群组）或 `Project`。响应仅表示直接成员关系。继承的成员关系（例如子群组中的成员关系）不包含在内。访问级别由整数值表示：

- `0`：无访问权限
- `5`：最低访问权限
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

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 指定用户的 ID。 |
| `type`    | string  | 否       | 按类型筛选成员关系。可以是 `Project` 或 `Namespace`。 |

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
- 如果找不到用户，返回 `404 User Not Found`。
- 如果不是由管理员请求，返回 `403 Forbidden`。
- 如果请求的类型不受支持，返回 `400 Bad Request`。

<a id="disable-two-factor-authentication-for-a-user"></a>

## 为用户禁用双重身份验证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是管理员。

为指定用户禁用双重身份验证（2FA）。

管理员无法使用 API 为自己的用户账号或其他管理员禁用 2FA。相反，他们可以[使用 Rails 控制台](../security/two_factor_authentication.md#for-a-single-user)禁用管理员的 2FA。

```plaintext
PATCH /users/:id/disable_two_factor
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户的 ID。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/users/1/disable_two_factor"
```

返回：

- 成功时返回 `204 No content`。
- 如果指定用户未启用双重身份验证，返回 `400 Bad request`。
- 如果未以管理员身份进行身份验证，返回 `403 Forbidden`。
- 如果找不到用户，返回 `404 User Not Found`。

<a id="create-a-runner-linked-to-a-user"></a>

## 创建链接到用户的 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建链接到当前用户的 Runner。出于审计目的，该用户会被列为所有者，但 Runner 的可用性取决于 `runner_type`。有关更多信息，请参阅[管理 Runner](../ci/runners/runners_scope.md)。

先决条件：

- 您必须是管理员，或拥有目标命名空间或项目的所有者角色。
- 对于 `instance_type`，您必须是极狐GitLab 实例的管理员。
- 对于具有所有者角色的 `group_type` 或 `project_type`，必须允许 [Runner 注册](../administration/settings/continuous_integration.md#control-runner-registration)。
- 具有 `create_runner` 范围的访问令牌。

请务必复制或保存响应中的 `token`，该值无法再次获取。

```plaintext
POST /user/runners
```

支持的属性：

| 属性          | 类型         | 是否必需 | 描述 |
|:-------------------|:-------------|:---------|:------------|
| `runner_type`      | string       | 是      | 指定 Runner 的范围；`instance_type`、`group_type` 或 `project_type`。 |
| `group_id`         | integer      | 否       | 在其中创建 Runner 的群组 ID。如果 `runner_type` 为 `group_type`，则此项为必填。 |
| `project_id`       | integer      | 否       | 在其中创建 Runner 的项目 ID。如果 `runner_type` 为 `project_type`，则此项为必填。 |
| `description`      | string       | 否       | Runner 的描述。 |
| `paused`           | boolean      | 否       | 指定 Runner 是否应忽略新作业。 |
| `locked`           | boolean      | 否       | 指定 Runner 是否应锁定到当前项目。 |
| `run_untagged`     | boolean      | 否       | 指定 Runner 是否应处理未打标签的作业。 |
| `tag_list`         | string | 否       | 以逗号分隔的 Runner 标签列表。 |
| `access_level`     | string       | 否       | Runner 的访问级别；`not_protected` 或 `ref_protected`。 |
| `maximum_timeout`  | integer      | 否       | 最大超时时间，用于限制 Runner 运行作业的时间（以秒为单位）。 |
| `maintenance_note` | string       | 否       | Runner 的自由格式维护备注（1024 个字符）。 |
| `token_expires_at` | datetime     | 否       | Runner 认证令牌的过期时间，采用 ISO 8601 格式。必须介于未来 5 分钟到 21 天之间。如果配置了实例、群组或项目级限制，则不能超过这些限制。仅适用于初始令牌。轮换后的令牌使用设置中计算出的过期时间。**(专业版及以上)** |
| `token_rotation_deadline` | datetime | 否 | 超过此截止时间后，令牌轮换请求将被拒绝。需要设置 `token_expires_at`。必须小于或等于 `token_expires_at`。将两者设置为相同的值会禁用令牌轮换。轮换成功后会清除。**(专业版及以上)** |

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

<a id="delete-authentication-identity-from-a-user"></a>

## 从用户删除身份验证身份

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用与该身份关联的提供商名称删除用户的身份验证身份。

先决条件：

- 您必须是管理员。

```plaintext
DELETE /users/:id/identities/:provider
```

支持的属性：

| 属性  | 类型    | 是否必需 | 描述 |
|:-----------|:--------|:---------|:------------|
| `id`       | integer | 是      | 用户的 ID。 |
| `provider` | string  | 是      | 外部提供商名称。 |

<a id="create-a-support-pin"></a>

## 创建支持 PIN

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为您的用户账号创建支持 PIN。该 PIN 在创建后七天过期。极狐GitLab 支持可能会要求提供此 PIN 以验证您的身份。

先决条件：

- 您必须已通过身份验证。

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

<a id="get-details-on-a-support-pin"></a>

## 获取支持 PIN 的详细信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

获取您账号的支持 PIN 的详细信息。极狐GitLab 支持可能会要求提供此 PIN 以验证您的身份。

先决条件：

- 您必须已通过身份验证。

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

<a id="get-a-support-pin-for-a-user"></a>

## 获取用户的支持 PIN

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

获取指定用户的支持 PIN 的详细信息。极狐GitLab 支持可能会要求提供此 PIN 以验证您的身份。

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

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户账号的 ID。 |

<a id="revoke-a-support-pin-for-a-user"></a>

## 撤销用户的支持 PIN

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在指定用户的支持 PIN 自然过期之前撤销它。这会立即使该 PIN 过期并将其移除。

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

| 属性 | 类型    | 是否必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id`      | integer | 是      | 用户的 ID。 |
