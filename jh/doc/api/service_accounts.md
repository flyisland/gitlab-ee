---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务账号 API
description: 极狐GitLab 服务账号 API 可在实例或群组级别管理服务账号，并提供完善的令牌和账号管理控制。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与[服务账号](../user/profile/service_accounts.md)交互。

您可以创建的服务账号数量取决于您的订阅和交付方式：

- 在极狐GitLab 专业版和旗舰版上，您可以为所有交付方式创建无限数量的服务账号。
- 在极狐GitLab 基础版上，限制因交付方式而异：
  - 对于 JihuLab.com，您可以为每个顶级群组创建最多 100 个服务账号。
    这包括在子群组或项目中创建的服务账号。
  - 对于极狐GitLab 私有化部署，您可以为整个实例创建最多 100 个服务账号。
    这包括在实例、群组或项目级别创建的服务账号。

您还可以通过[用户 API](users.md) 与服务账号交互。要管理服务账号的 SSH 密钥，请使用[用户 SSH 和 GPG 密钥 API](user_keys.md)。

<a id="instance-service-accounts"></a>

## 实例服务账号

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

实例服务账号可供整个极狐GitLab 实例使用，但仍必须像人类用户一样添加到群组和项目中。

要管理实例服务账号的个人访问令牌，请使用[个人访问令牌 API](personal_access_tokens.md)。

先决条件：

- 您必须具有该实例的管理员访问权限。

<a id="list-all-instance-service-accounts"></a>

### 列出所有实例服务账号

列出所有实例服务账号。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)筛选结果。

```plaintext
GET /service_accounts
```

支持的属性：

| 属性  | 类型   | 是否必需 | 描述 |
| ---------- | ------ | -------- | ----------- |
| `order_by` | string | 否       | 用于对结果排序的属性。可能的值：`id` 或 `username`。默认值：`id`。 |
| `sort`     | string | 否       | 对结果排序的方向。可能的值：`desc` 或 `asc`。默认值：`desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
[
  {
    "id": 114,
    "username": "service_account_33",
    "public_email": "",
    "name": "Service account user",
    "email": "service_account_33@noreply.gitlab.example.com"
  },
  {
    "id": 137,
    "username": "service_account_34",
    "public_email": "",
    "name": "john doe",
    "email": "service_account_34@noreply.gitlab.example.com"
  }
]
```

<a id="create-an-instance-service-account"></a>

### 创建实例服务账号

创建实例服务账号。

```plaintext
POST /service_accounts
POST /service_accounts?email=custom_email@gitlab.example.com
```

支持的属性：

| 属性  | 类型   | 是否必需 | 描述 |
| ---------- | ------ | -------- | ----------- |
| `name`     | string | 否       | 用户的名称。如果未设置，则使用 `Service account user`。 |
| `username` | string | 否       | 用户账号的用户名。如果未定义，则生成一个以 `service_account_` 为前缀的名称。 |
| `email`    | string | 否       | 用户账号的电子邮件地址。如果未指定，则生成一个以 `service_account_` 为前缀的电子邮件地址。自定义电子邮件地址需要确认，除非电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Service account user",
  "email": "service_account_6018816a18e515214e0c34c2b33523fc@noreply.gitlab.example.com"
}
```

如果 `email` 属性定义的电子邮件地址已被其他用户使用，则返回 `400 Bad request` 错误。

<a id="update-an-instance-service-account"></a>

### 更新实例服务账号

更新指定的实例服务账号。

```plaintext
PATCH /service_accounts/:id
```

参数：

| 属性  | 类型           | 是否必需 | 描述                                                                                                                                                                                                               |
|:-----------|:---------------|:---------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`       | integer        | 是      | 服务账号的 ID。  |
| `name`     | string         | 否       | 用户的名称。  |
| `username` | string         | 否       | 用户账号的用户名。 |
| `email`    | string         | 否       | 用户账号的电子邮件地址。自定义电子邮件地址需要确认，除非电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/service_accounts/57" \
  --data "name=Updated Service Account&email=updated_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Updated Service Account",
  "email": "service_account_<random_hash>@noreply.gitlab.example.com",
  "unconfirmed_email": "custom_email@example.com"
}
```

<a id="group-service-accounts"></a>

## 群组服务账号

群组服务账号由特定群组拥有，可以邀请到创建它们的群组，或邀请到任何后代子群组或项目。它们不能被邀请到祖先群组。

先决条件：

- 在 JihuLab.com 上，您必须具有该群组的所有者角色。
- 在极狐GitLab 私有化部署上，您必须满足以下任一条件：
  - 是该实例的管理员。
  - 在群组中具有所有者角色，并且[被允许创建服务账号](../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)。

<a id="list-all-group-service-accounts"></a>

### 列出所有群组服务账号

列出指定群组中的所有服务账号。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)筛选结果。

```plaintext
GET /groups/:id/service_accounts
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by` | string         | 否       | 按 `username` 或 `id` 对用户列表排序。默认为 `id`。 |
| `sort`     | string         | 否       | 指定按 `asc` 或 `desc` 排序。默认为 `desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/345/service_accounts"
```

示例响应：

```json
[

  {
    "id": 57,
    "username": "service_account_group_345_<random_hash>",
    "public_email": "",
    "name": "Service account user",
    "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com"
  },
  {
    "id": 58,
    "username": "service_account_group_345_<random_hash>",
    "public_email": "",
    "name": "Service account user",
    "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com",
    "unconfirmed_email": "custom_email@example.com"
  }
]
```

<a id="retrieve-a-group-service-account"></a>

### 检索群组服务账号

检索指定群组中的单个服务账号。

```plaintext
GET /groups/:id/service_accounts/:user_id
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 服务账号的 ID。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型    | 描述 |
| ------------------- | ------- | ----------- |
| `email`             | string  | 服务账号的电子邮件地址。 |
| `id`                | integer | 服务账号的 ID。 |
| `name`              | string  | 服务账号的名称。 |
| `public_email`      | string  | 服务账号的公开电子邮件地址。 |
| `unconfirmed_email` | string  | 等待确认的电子邮件地址。仅在确认待处理时返回。 |
| `username`          | string  | 服务账号的用户名。 |

如果服务账号在群组中不存在，则返回 `404 Not Found`；如果该用户在群组中存在但不是服务账号，则返回 `400 Bad Request`。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/345/service_accounts/57"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_group_345_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Service account user",
  "email": "service_account_group_345_6018816a18e515214e0c34c2b33523fc@noreply.gitlab.example.com"
}
```

<a id="create-a-group-service-account"></a>

### 创建群组服务账号

在指定群组中创建服务账号。

```plaintext
POST /groups/:id/service_accounts
```

支持的属性：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`     | string         | 否       | 用户账号名称。如果未指定，则使用 `Service account user`。 |
| `username` | string         | 否       | 用户账号用户名。如果未指定，则生成一个以 `service_account_group_` 为前缀的名称。 |
| `email`    | string         | 否       | 用户账号的电子邮件地址。如果未指定，则生成一个以 `service_account_group_` 为前缀的电子邮件地址。自定义电子邮件地址需要确认，除非顶级群组具有匹配的[已验证域名](../user/enterprise_user/_index.md#manage-group-domains)或电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/345/service_accounts" \
  --data "email=custom_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_group_345_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Service account user",
  "email": "custom_email@example.com"
}
```

<a id="update-a-group-service-account"></a>

### 更新群组服务账号

更新指定群组中的服务账号。

> [!note]
>
> - 您无法更新与[复合身份](../user/duo_agent_platform/composite_identity.md)关联的服务账号的用户名。

```plaintext
PATCH /groups/:id/service_accounts/:user_id
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账号的 ID。 |
| `name`     | string         | 否       | 用户的名称。 |
| `username` | string         | 否       | 用户的用户名。 |
| `email`    | string         | 否       | 用户账号的电子邮件地址。自定义电子邮件地址需要确认，除非顶级群组具有匹配的[已验证域名](../user/enterprise_user/_index.md#manage-group-domains)或电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/345/service_accounts/57" \
  --data "name=Updated Service Account&email=updated_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_group_345_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Updated Service Account",
  "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com",
  "unconfirmed_email": "custom_email@example.com"
}
```

<a id="delete-a-group-service-account"></a>

### 删除群组服务账号

从指定群组中删除服务账号。

```plaintext
DELETE /groups/:id/service_accounts/:user_id
```

参数：

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账号的 ID。 |
| `hard_delete` | boolean        | 否       | 如果为 true，通常会被[移动到幽灵用户](../user/profile/account/delete_account.md#associated-records)的贡献将被删除，仅由该服务账号拥有的群组也会被删除。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/345/service_accounts/181"
```

<a id="list-all-personal-access-tokens-for-a-group-service-account"></a>

### 列出群组服务账号的所有个人访问令牌

列出指定群组中某个服务账号的所有个人访问令牌。

```plaintext
GET /groups/:id/service_accounts/:user_id/personal_access_tokens
```

支持的属性：

| 属性          | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string      | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`          | integer             | 是      | 服务账号的 ID。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 如果定义，则返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 如果定义，则返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果定义，则返回名称中包含指定值的令牌。 |
| `sort`             | string              | 否       | 如果定义，则按指定值对结果排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`            | string              | 否       | 如果定义，则返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/187/service_accounts/195/personal_access_tokens?sort=id_desc&search=token2b&created_before=2025-03-27"
```

示例响应：

```json
[
    {
        "id": 187,
        "name": "service_accounts_token2b",
        "revoked": false,
        "created_at": "2025-03-26T14:42:51.084Z",
        "description": null,
        "scopes": [
            "api"
        ],
        "user_id": 195,
        "last_used_at": null,
        "last_used_ips": [],
        "active": true,
        "expires_at": null
    }
]
```

不成功响应的示例：

- `401: Unauthorized`
- `404 Group Not Found`

<a id="create-a-personal-access-token-for-a-group-service-account"></a>

### 为群组服务账号创建个人访问令牌

为指定群组中现有的服务账号创建个人访问令牌。

```plaintext
POST /groups/:id/service_accounts/:user_id/personal_access_tokens
```

参数：

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账号的 ID。 |
| `name`        | string         | 是      | 个人访问令牌的名称。 |
| `description` | string         | 否       | 个人访问令牌的描述。 |
| `scopes`      | array          | 是      | 已批准范围的数组。有关可能值的列表，请参阅[访问令牌范围](../security/tokens/access_token_scopes.md)。 |
| `expires_at`  | date           | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果未指定且令牌需要过期日期，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。如果不需要，则令牌没有过期日期。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens" \
  --data "scopes[]=api,read_user,read_repository" \
  --data "name=service_accounts_token"
```

示例响应：

```json
{
  "id":6,
  "name":"service_accounts_token",
  "revoked":false,
  "created_at":"2023-06-13T07:47:13.900Z",
  "scopes":["api"],
  "user_id":71,
  "last_used_at":null,
  "last_used_ips":[],
  "active":true,
  "expires_at":"2024-06-12",
  "token":"<token_value>"
}
```

<a id="revoke-a-personal-access-token-for-a-group-service-account"></a>

### 撤销群组服务账号的个人访问令牌

撤销群组中现有服务账号的指定个人访问令牌。

```plaintext
DELETE /groups/:id/service_accounts/:user_id/personal_access_tokens/:token_id
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账号的 ID。 |
| `token_id` | integer        | 是      | 令牌的 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens/6"
```

如果成功，则返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request` 如果未成功撤销。
- `401: Unauthorized` 如果请求未获授权。
- `403: Forbidden` 如果不允许该请求。
- `404: Not Found` 如果访问令牌不存在。

<a id="rotate-a-personal-access-token-for-a-group-service-account"></a>

### 轮换群组服务账号的个人访问令牌

轮换指定群组中现有服务账号的指定个人访问令牌。这会撤销现有令牌，并创建一个具有相同名称、描述和范围的新令牌。

```plaintext
POST /groups/:id/service_accounts/:user_id/personal_access_tokens/:token_id/rotate
```

参数：

| 属性    | 类型           | 是否必需 | 描述 |
| ------------ | -------------- | -------- | ----------- |
| `id`         | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`    | integer        | 是      | 服务账号的 ID。 |
| `token_id`   | integer        | 是      | 令牌的 ID。 |
| `expires_at` | date           | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/505671)于极狐GitLab 17.9。如果令牌需要过期日期，则默认为一周。如果不需要，则令牌没有过期日期。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens/6/rotate"
```

示例响应：

```json
{
  "id":7,
  "name":"service_accounts_token",
  "revoked":false,
  "created_at":"2023-06-13T07:54:49.962Z",
  "scopes":["api"],
  "user_id":71,
  "last_used_at":null,
  "last_used_ips":[],
  "active":true,
  "expires_at":"2023-06-20",
  "token":"<token_value>"
}
```

<a id="project-service-accounts"></a>

## 项目服务账号

项目服务账号由特定项目拥有，仅可供其关联项目使用。

先决条件：

- 在 JihuLab.com 上，您必须具有该项目的维护者或所有者角色。
- 在极狐GitLab 私有化部署上，您必须满足以下任一条件：
  - 是该实例的管理员。
  - 在项目中具有维护者或所有者角色。

<a id="list-all-project-service-accounts"></a>

### 列出所有项目服务账号

列出指定项目中的所有服务账号。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)筛选结果。

```plaintext
GET /projects/:id/service_accounts
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by` | string         | 否       | 按 `username` 或 `id` 对用户列表排序。默认为 `id`。 |
| `sort`     | string         | 否       | 指定按 `asc` 或 `desc` 排序。默认为 `desc`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/345/service_accounts"
```

示例响应：

```json
[

  {
    "id": 57,
    "username": "service_account_project_345_<random_hash>",
    "public_email": "",
    "name": "Service account user",
    "email": "service_account_project_345_<random_hash>@noreply.gitlab.example.com"
  },
  {
    "id": 58,
    "username": "service_account_project_345_<random_hash>",
    "public_email": "",
    "name": "Service account user",
    "email": "service_account_project_345_<random_hash>@noreply.gitlab.example.com",
    "unconfirmed_email": "custom_email@example.com"
  }
]
```

<a id="retrieve-a-project-service-account"></a>

### 检索项目服务账号

检索指定项目中的单个服务账号。

```plaintext
GET /projects/:id/service_accounts/:user_id
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 服务账号的 ID。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型    | 描述 |
| ------------------- | ------- | ----------- |
| `email`             | string  | 服务账号的电子邮件地址。 |
| `id`                | integer | 服务账号的 ID。 |
| `name`              | string  | 服务账号的名称。 |
| `public_email`      | string  | 服务账号的公开电子邮件地址。 |
| `unconfirmed_email` | string  | 等待确认的电子邮件地址。仅在确认待处理时返回。 |
| `username`          | string  | 服务账号的用户名。 |

如果服务账号在项目中不存在，则返回 `404 Not Found`。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/345/service_accounts/57"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_project_345_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Service account user",
  "email": "service_account_project_345_6018816a18e515214e0c34c2b33523fc@noreply.gitlab.example.com"
}
```

<a id="create-a-project-service-account"></a>

### 创建项目服务账号

在指定项目中创建服务账号。

```plaintext
POST /projects/:id/service_accounts
```

支持的属性：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`     | string         | 否       | 用户账号名称。如果未指定，则使用 `Service account user`。 |
| `username` | string         | 否       | 用户账号用户名。如果未指定，则生成一个以 `service_account_project_` 为前缀的名称。 |
| `email`    | string         | 否       | 用户账号的电子邮件地址。如果未指定，则生成一个以 `service_account_project_` 为前缀的电子邮件地址。自定义电子邮件地址需要确认，除非顶级群组具有匹配的[已验证域名](../user/enterprise_user/_index.md#manage-group-domains)或电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/345/service_accounts" \
  --data "email=custom_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_project_345_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Service account user",
  "email": "custom_email@example.com"
}
```

<a id="update-a-project-service-account"></a>

### 更新项目服务账号

更新指定项目中的服务账号。

```plaintext
PATCH /projects/:id/service_accounts/:user_id
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账号的 ID。 |
| `name`     | string         | 否       | 用户的名称。 |
| `username` | string         | 否       | 用户的用户名。 |
| `email`    | string         | 否       | 用户账号的电子邮件地址。自定义电子邮件地址需要确认，除非顶级群组具有匹配的[已验证域名](../user/enterprise_user/_index.md#manage-group-domains)或电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/345/service_accounts/57" \
  --data "name=Updated Service Account&email=updated_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_project_345_6018816a18e515214e0c34c2b33523fc",
  "public_email": "",
  "name": "Updated Service Account",
  "email": "service_account_project_345_<random_hash>@noreply.gitlab.example.com",
  "unconfirmed_email": "custom_email@example.com"
}
```

<a id="delete-a-project-service-account"></a>

### 删除项目服务账号

从指定项目中删除服务账号。

```plaintext
DELETE /projects/:id/service_accounts/:user_id
```

参数：

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账号的 ID。 |
| `hard_delete` | boolean        | 否       | 如果为 true，通常会被[移动到幽灵用户](../user/profile/account/delete_account.md#associated-records)的贡献将被删除，仅由该服务账号拥有的群组也会被删除。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/345/service_accounts/181"
```

<a id="list-all-personal-access-tokens-for-a-project-service-account"></a>

### 列出项目服务账号的所有个人访问令牌

列出项目中某个服务账号的所有个人访问令牌。

```plaintext
GET /projects/:id/service_accounts/:user_id/personal_access_tokens
```

支持的属性：

| 属性          | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string      | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`          | integer             | 是      | 服务账号的 ID。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 如果定义，则返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 如果定义，则返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，则返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，则仅返回已撤销的令牌。 |
| `search`           | string              | 否       | 如果定义，则返回名称中包含指定值的令牌。 |
| `sort`             | string              | 否       | 如果定义，则按指定值对结果排序。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`            | string              | 否       | 如果定义，则返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/187/service_accounts/195/personal_access_tokens?sort=id_desc&search=token2b&created_before=2025-03-27"
```

示例响应：

```json
[
    {
        "id": 187,
        "name": "service_accounts_token2b",
        "revoked": false,
        "created_at": "2025-03-26T14:42:51.084Z",
        "description": null,
        "scopes": [
            "api"
        ],
        "user_id": 195,
        "last_used_at": null,
        "last_used_ips": [],
        "active": true,
        "expires_at": null
    }
]
```

不成功响应的示例：

- `401: Unauthorized`
- `404 Project Not Found`

<a id="create-a-personal-access-token-for-a-project-service-account"></a>

### 为项目服务账号创建个人访问令牌

为指定项目中现有的服务账号创建个人访问令牌。

```plaintext
POST /projects/:id/service_accounts/:user_id/personal_access_tokens
```

参数：

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账号的 ID。 |
| `name`        | string         | 是      | 个人访问令牌的名称。 |
| `description` | string         | 否       | 个人访问令牌的描述。 |
| `scopes`      | array          | 是      | 已批准范围的数组。有关可能值的列表，请参阅[访问令牌范围](../security/tokens/access_token_scopes.md)。 |
| `expires_at`  | date           | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。如果未指定且令牌需要过期日期，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。如果不需要，则令牌没有过期日期。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/35/service_accounts/71/personal_access_tokens" \
  --data "scopes[]=api,read_user,read_repository" \
  --data "name=service_accounts_token"
```

示例响应：

```json
{
  "id":6,
  "name":"service_accounts_token",
  "revoked":false,
  "created_at":"2023-06-13T07:47:13.900Z",
  "scopes":["api"],
  "user_id":71,
  "last_used_at":null,
  "last_used_ips":[],
  "active":true,
  "expires_at":"2024-06-12",
  "token":"<token_value>"
}
```

<a id="revoke-a-personal-access-token-for-a-project-service-account"></a>

### 撤销项目服务账号的个人访问令牌

撤销指定项目中现有服务账号的个人访问令牌。

```plaintext
DELETE /projects/:id/service_accounts/:user_id/personal_access_tokens/:token_id
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账号的 ID。 |
| `token_id` | integer        | 是      | 令牌的 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/35/service_accounts/71/personal_access_tokens/6"
```

如果成功，则返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request` 如果未成功撤销。
- `401: Unauthorized` 如果请求未获授权。
- `403: Forbidden` 如果不允许该请求。
- `404: Not Found` 如果访问令牌不存在。

<a id="rotate-a-personal-access-token-for-a-project-service-account"></a>

### 轮换项目服务账号的个人访问令牌

轮换指定项目中现有服务账号的个人访问令牌。这会创建一个有效期为一周的新令牌，并撤销任何现有令牌。

```plaintext
POST /projects/:id/service_accounts/:user_id/personal_access_tokens/:token_id/rotate
```

参数：

| 属性    | 类型           | 是否必需 | 描述 |
| ------------ | -------------- | -------- | ----------- |
| `id`         | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`    | integer        | 是      | 服务账号的 ID。 |
| `token_id`   | integer        | 是      | 令牌的 ID。 |
| `expires_at` | date           | 否       | 访问令牌的过期日期，采用 ISO 格式（`YYYY-MM-DD`）。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/505671)于极狐GitLab 17.9。如果令牌需要过期日期，则默认为一周。如果不需要，则令牌没有过期日期。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/35/service_accounts/71/personal_access_tokens/6/rotate"
```

示例响应：

```json
{
  "id":7,
  "name":"service_accounts_token",
  "revoked":false,
  "created_at":"2023-06-13T07:54:49.962Z",
  "scopes":["api"],
  "user_id":71,
  "last_used_at":null,
  "last_used_ips":[],
  "active":true,
  "expires_at":"2023-06-20",
  "token":"<token_value>"
}
```
