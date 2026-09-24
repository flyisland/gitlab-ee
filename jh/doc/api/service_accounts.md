---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务账号 API
description: 极狐GitLab 服务账号 API 管理实例或群组级别的服务账号，具备强大的令牌和账号管理控制功能。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 基础版中引入，[附带一个功能标志](../administration/feature_flags/_index.md) 命名为 `service_accounts_available_on_free_or_unlicensed`。默认禁用。
- 在极狐GitLab 18.11 基础版中 GA。功能标志 `service_accounts_available_on_free_or_unlicensed` 已移除。

{{< /history >}}

使用此 API 与[服务账号](../user/profile/service_accounts.md) 交互。

您可以创建的服务账号数量取决于您的订阅与提供方式：

- 在极狐GitLab 专业版和旗舰版中，您可以创建无限制的服务账号，适用于所有提供方式。
- 在极狐GitLab 基础版中，根据提供方式的不同，限制如下：
  - 对于 JihuLab.com，每个顶级群组最多可以创建 100 个服务账号。这包括在子群组或项目中创建的服务账号。
  - 对于极狐GitLab 私有化部署，每个实例最多可以创建 100 个服务账号。这包括所有服务账号，无论其供应方式（实例、群组或项目级别）。

您还可以通过[用户 API](users.md) 与服务账号交互。要管理服务账号的 SSH 密钥，请使用[用户 SSH 和 GPG 密钥 API](user_keys.md)。

<a id="instance-service-accounts"></a>

## 实例服务账号

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

实例服务账号对整个极狐GitLab 实例可用，但仍必须像人类用户一样添加到群组和项目中。

要管理实例服务账号的个人访问令牌，请使用[个人访问令牌 API](personal_access_tokens.md)。

先决条件：您必须拥有实例的管理员权限。

<a id="list-all-instance-service-accounts"></a>

### 列出所有实例服务账号

{{< history >}}

- 列出所有服务账号功能在极狐GitLab 17.1 中引入。

{{< /history >}}

列出所有实例服务账号。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 过滤结果。

```plaintext
GET /service_accounts
```

支持的属性：

| 属性      | 类型   | 是否必需 | 描述 |
| ---------- | ------ | -------- | ----------- |
| `order_by` | string | 否       | 按属性排序结果。可选值：`id` 或 `username`。默认：`id`。 |
| `sort`     | string | 否       | 排序方向。可选值：`desc` 或 `asc`。默认：`desc`。 |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
[
  {
    "id": 114,
    "username": "service_account_33",
    "name": "Service account user"
  },
  {
    "id": 137,
    "username": "service_account_34",
    "name": "john doe"
  }
]
```

<a id="create-an-instance-service-account"></a>

### 创建实例服务账号

{{< history >}}

- 在极狐GitLab 16.1 中引入
- `username` 和 `name` 属性在极狐GitLab 16.10 中添加。
- `email` 属性在极狐GitLab 17.9 中添加。

{{< /history >}}

创建一个实例服务账号。

```plaintext
POST /service_accounts
POST /service_accounts?email=custom_email@gitlab.example.com
```

支持的属性：

| 属性      | 类型   | 是否必需 | 描述 |
| ---------- | ------ | -------- | ----------- |
| `name`     | string | 否       | 用户名称。若未设置，则使用 `Service account user`。 |
| `username` | string | 否       | 用户账号的用户名。若未定义，则生成以 `service_account_` 为前缀的名称。 |
| `email`    | string | 否       | 用户账号的电子邮件。若未定义，则生成一个无回复电子邮件地址。自定义电子邮件地址需要确认，除非电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_6018816a18e515214e0c34c2b33523fc",
  "name": "Service account user",
  "email": "service_account_6018816a18e515214e0c34c2b33523fc@noreply.gitlab.example.com"
}
```

如果 `email` 属性定义的电子邮件地址已被其他用户使用，则返回 `400 Bad request` 错误。

<a id="update-an-instance-service-account"></a>

### 更新实例服务账号

{{< history >}}

- 在极狐GitLab 18.2 中引入。

{{< /history >}}

更新指定的实例服务账号。

```plaintext
PATCH /service_accounts/:id
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                                                                                                                               |
|:-----------|:---------------|:---------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`       | integer        | 是      | 服务账号的 ID。  |
| `name`     | string         | 否       | 用户名称。  |
| `username` | string         | 否       | 用户账号的用户名。 |
| `email`    | string         | 否       | 用户账号的电子邮件。自定义电子邮件地址需要确认，除非电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/service_accounts/57" --data "name=Updated Service Account&email=updated_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_6018816a18e515214e0c34c2b33523fc",
  "name": "Updated Service Account",
  "email": "service_account_<random_hash>@noreply.gitlab.example.com",
  "unconfirmed_email": "custom_email@example.com"
}
```

<a id="group-service-accounts"></a>

## 群组服务账号

{{< history >}}

- 子群组服务账号于极狐GitLab 18.10 引入，[附带一个功能标志](../administration/feature_flags/_index.md) 命名为 `allow_subgroups_to_create_service_accounts`。默认禁用。
- 子群组服务账号在极狐GitLab 18.11 中 GA。功能标志 `allow_subgroups_to_create_service_accounts` 已移除。

{{< /history >}}

群组服务账号由特定群组所有，可以被邀请到创建它们的群组或任何后代子群组或项目中。它们不能被邀请到上级群组。

先决条件：

- 在 JihuLab.com 上，您必须具有群组的所有者角色。
- 在极狐GitLab 私有化部署上，您必须满足以下任一条件：
  - 成为实例的管理员。
  - 在群组中具有所有者角色，并且[被允许创建服务账号](../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)。

<a id="list-all-group-service-accounts"></a>

### 列出所有群组服务账号

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

列出指定群组中的所有服务账号。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 过滤结果。

```plaintext
GET /groups/:id/service_accounts
```

参数：

| 属性      | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by` | string         | 否       | 按 `username` 或 `id` 排序用户列表。默认为 `id`。 |
| `sort`     | string         | 否       | 指定排序 `asc` 或 `desc`。默认为 `desc`。 |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/345/service_accounts"
```

示例响应：

```json
[

  {
    "id": 57,
    "username": "service_account_group_345_<random_hash>",
    "name": "Service account user",
    "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com"
  },
  {
    "id": 58,
    "username": "service_account_group_345_<random_hash>",
    "name": "Service account user",
    "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com",
    "unconfirmed_email": "custom_email@example.com"
  }
]
```

<a id="create-a-group-service-account"></a>

### 创建群组服务账号

{{< history >}}

- 在极狐GitLab 16.1 中引入。
- `username` 和 `name` 属性在极狐GitLab 16.10 中添加。
- `email` 属性在极狐GitLab 17.9 中添加，[附带一个功能标志](../administration/feature_flags/_index.md) 命名为 `group_service_account_custom_email`。
- `email` 属性在极狐GitLab 17.11 中 GA。功能标志 `group_service_account_custom_email` 已移除。

{{< /history >}}

在指定群组中创建服务账号。

```plaintext
POST /groups/:id/service_accounts
```

支持的属性：

| 属性      | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `name`     | string         | 否       | 用户账号名称。若未指定，则使用 `Service account user`。 |
| `username` | string         | 否       | 用户账号的用户名。若未指定，则生成以 `service_account_group_` 为前缀的名称。 |
| `email`    | string         | 否       | 用户账号的电子邮件。若未指定，则生成以 `service_account_group_` 为前缀的电子邮件。自定义电子邮件地址需要确认，除非群组拥有匹配的[已验证域](../user/enterprise_user/_index.md#manage-group-domains) 或电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/345/service_accounts" --data "email=custom_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_group_345_6018816a18e515214e0c34c2b33523fc",
  "name": "Service account user",
  "email": "custom_email@example.com"
}
```

<a id="update-a-group-service-account"></a>

### 更新群组服务账号

{{< history >}}

- 在极狐GitLab 17.10 中引入。
- 添加自定义电子邮件地址在极狐GitLab 18.2 中引入。
- 在极狐GitLab 18.9 中为具有复合身份的服务账号[添加了](https://gitlab.com/gitlab-org/gitlab/-/work_items/581050) 用户名限制。

{{< /history >}}

更新指定群组中的服务账号。

> [!note]
>
> - 您不能更新与[复合身份](../user/duo_agent_platform/composite_identity.md) 关联的服务账号的用户名。

```plaintext
PATCH /groups/:id/service_accounts/:user_id
```

参数：

| 属性      | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账号的 ID。 |
| `name`     | string         | 否       | 用户名称。 |
| `username` | string         | 否       | 用户名。 |
| `email`    | string         | 否       | 用户账号的电子邮件。自定义电子邮件地址需要确认，除非群组拥有匹配的[已验证域](../user/enterprise_user/_index.md#manage-group-domains) 或电子邮件确认设置已[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/345/service_accounts/57" --data "name=Updated Service Account&email=updated_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_group_345_6018816a18e515214e0c34c2b33523fc",
  "name": "Updated Service Account",
  "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com",
  "unconfirmed_email": "custom_email@example.com"
}
```

<a id="delete-a-group-service-account"></a>

### 删除群组服务账号

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

从指定群组中删除服务账号。

```plaintext
DELETE /groups/:id/service_accounts/:user_id
```

参数：

| 属性          | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账号的 ID。 |
| `hard_delete` | boolean        | 否       | 若为 true，通常会[移至 ghost 用户](../user/profile/account/delete_account.md#associated-records) 的贡献将被删除，以及仅由此服务账号拥有的群组也将被删除。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/345/service_accounts/181"
```

<a id="list-all-personal-access-tokens-for-a-group-service-account"></a>

### 列出群组服务账号的所有个人访问令牌

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

列出指定群组中某个服务账号的所有个人访问令牌。

```plaintext
GET /groups/:id/service_accounts/:user_id/personal_access_tokens
```

支持的属性：

| 属性               | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string      | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`          | integer             | 是      | 服务账号的 ID。 |
| `created_after`    | datetime (ISO 8601) | 否       | 若定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 若定义，返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 若定义，返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 若定义，返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 若定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 若定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 若为 `true`，仅返回已吊销的令牌。 |
| `search`           | string              | 否       | 若定义，返回名称中包含指定值的令牌。 |
| `sort`             | string              | 否       | 若定义，按指定值排序结果。可选值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`            | string              | 否       | 若定义，返回具有指定状态的令牌。可选值：`active` 和 `inactive`。 |

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
        "active": true,
        "expires_at": null
    }
]
```

失败响应示例：

- `401: Unauthorized`
- `404 Group Not Found`

<a id="create-a-personal-access-token-for-a-group-service-account"></a>

### 为群组服务账号创建个人访问令牌

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

为指定群组中的现有服务账号创建个人访问令牌。

```plaintext
POST /groups/:id/service_accounts/:user_id/personal_access_tokens
```

参数：

| 属性         | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账号的 ID。 |
| `name`        | string         | 是      | 个人访问令牌的名称。 |
| `description` | string         | 否       | 个人访问令牌的描述。 |
| `scopes`      | array          | 是      | 批准的权限范围数组。可选值列表见[个人访问令牌权限范围](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。 |
| `expires_at`  | date           | 否       | 访问令牌的过期日期，ISO 格式（`YYYY-MM-DD`）。若未指定，日期将被设置为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens" --data "scopes[]=api,read_user,read_repository" --data "name=service_accounts_token"
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
  "active":true,
  "expires_at":"2024-06-12",
  "token":"<token_value>"
}
```

<a id="revoke-a-personal-access-token-for-a-group-service-account"></a>

### 吊销群组服务账号的个人访问令牌

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

吊销群组中现有服务账号的指定个人访问令牌。

```plaintext
DELETE /groups/:id/service_accounts/:user_id/personal_access_tokens/:token_id
```

参数：

| 属性      | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账号的 ID。 |
| `token_id` | integer        | 是      | 令牌的 ID。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens/6"
```

若成功，返回 `204: No Content`。

其他可能响应：

- `400: Bad Request`，若未成功吊销。
- `401: Unauthorized`，若请求未授权。
- `403: Forbidden`，若请求不被允许。
- `404: Not Found`，若访问令牌不存在。

<a id="rotate-a-personal-access-token-for-a-group-service-account"></a>

### 轮换群组服务账号的个人访问令牌

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

为指定群组中现有服务账号轮换指定的个人访问令牌。这会吊销现有令牌并创建一个具有相同名称、描述和权限范围的新令牌。

```plaintext
POST /groups/:id/service_accounts/:user_id/personal_access_tokens/:token_id/rotate
```

参数：

| 属性         | 类型           | 是否必需 | 描述 |
| ------------ | -------------- | -------- | ----------- |
| `id`         | integer or string | 是      | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`    | integer        | 是      | 服务账号的 ID。 |
| `token_id`   | integer        | 是      | 令牌的 ID。 |
| `expires_at` | date           | 否       | 访问令牌的过期日期，ISO 格式（`YYYY-MM-DD`）。[在极狐GitLab 17.9 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/505671)。若令牌需要过期日期，则默认为一周。若不需要，则默认为[最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens/6/rotate"
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
  "active":true,
  "expires_at":"2023-06-20",
  "token":"<token_value>"
}
```

<a id="project-service-accounts"></a>

## 项目服务账号

{{< history >}}

- 在极狐GitLab 18.9 中引入，[附带一个功能标志](../administration/feature_flags/_index.md) 命名为 `allow_projects_to_create_service_accounts`。默认禁用。
- 项目服务账号在极狐GitLab 18.11 中 GA。功能标志 `allow_projects_to_create_service_accounts` 已移除。

{{< /history >}}

项目服务账号由特定项目所有，仅对其关联项目可用。

先决条件：

- 在 JihuLab.com 上，您必须具有项目的所有者或维护者角色。
- 在极狐GitLab 私有化部署上，您必须满足以下任一条件：
  - 成为实例的管理员。
  - 在项目中具有所有者或维护者角色。

<a id="list-all-project-service-accounts"></a>

### 列出所有项目服务账号

列出指定项目中的所有服务账号。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 过滤结果。

```plaintext
GET /projects/:id/service_accounts
```

参数：

| 属性      | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by` | string         | 否       | 按 `username` 或 `id` 排序用户列表。默认为 `id`。 |
| `sort`     | string         | 否       | 指定排序 `asc` 或 `desc`。默认为 `desc`。 |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/345/service_accounts"
```

示例响应：

```json
[

  {
    "id": 57,
    "username": "service_account_project_345_<random_hash>",
    "name": "Service account user",
    "email": "service_account_project_345_<random_hash>@noreply.gitlab.example.com"
  },
  {
    "id": 58,
    "username": "service_account_project_345_<random_hash>",
    "name": "Service account user",
    "email": "service_account_project_345_<random_hash>@noreply.gitlab.example.com",
    "unconfirmed_email": "custom_email@example.com"
  }
]
```

<a id="create-a-project-service-account"></a>

### 创建项目服务账号

在指定项目中创建服务账号。

```plaintext
POST /projects/:id/service_accounts
```

支持的属性：

(待续)
| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`     | string         | 否       | 用户账户名称。如未指定，将使用 `Service account user`。 |
| `username` | string         | 否       | 用户账户用户名。如未指定，将生成一个以 `service_account_project_` 开头的名称。 |
| `email`    | string         | 否       | 用户账户的邮箱地址。如未指定，将生成一个以 `service_account_project_` 开头的邮箱。自定义邮箱地址需要确认，除非群组拥有匹配的[已验证域名](../user/enterprise_user/_index.md#manage-group-domains) 或邮箱确认设置已被[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/345/service_accounts" --data "email=custom_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_project_345_6018816a18e515214e0c34c2b33523fc",
  "name": "Service account user",
  "email": "custom_email@example.com"
}
```

### 更新项目服务账户

更新指定项目中的服务账户。

```plaintext
PATCH /projects/:id/service_accounts/:user_id
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账户的 ID。 |
| `name`     | string         | 否       | 用户名称。 |
| `username` | string         | 否       | 用户用户名。 |
| `email`    | string         | 否       | 用户账户的邮箱地址。自定义邮箱地址需要确认，除非群组拥有匹配的[已验证域名](../user/enterprise_user/_index.md#manage-group-domains) 或邮箱确认设置已被[关闭](../administration/settings/sign_up_restrictions.md#confirm-user-email)。 |

示例请求：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/345/service_accounts/57" --data "name=Updated Service Account&email=updated_email@example.com"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_project_345_6018816a18e515214e0c34c2b33523fc",
  "name": "Updated Service Account",
  "email": "service_account_project_345_<random_hash>@noreply.gitlab.example.com",
  "unconfirmed_email": "custom_email@example.com"
}
```

### 删除项目服务账户

从指定项目中删除服务账户。

```plaintext
DELETE /projects/:id/service_accounts/:user_id
```

参数：

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账户的 ID。 |
| `hard_delete` | boolean        | 否       | 如果为 true，通常会[移至 ghost 用户](../user/profile/account/delete_account.md#associated-records) 的贡献将被直接删除，同时删除仅由此服务账户拥有的群组。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/345/service_accounts/181"
```

### 列出项目服务账户的所有个人访问令牌

列出项目中服务账户的所有个人访问令牌。

```plaintext
GET /projects/:id/service_accounts/:user_id/personal_access_tokens
```

支持的属性：

| 属性          | 类型                | 是否必需 | 描述 |
| ------------------ | ------------------- | -------- | ----------- |
| `id`               | integer or string      | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`          | integer             | 是      | 服务账户的 ID。 |
| `created_after`    | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之后创建的令牌。 |
| `created_before`   | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之前创建的令牌。 |
| `expires_after`    | date (ISO 8601)     | 否       | 如果定义，返回在指定时间之后过期的令牌。 |
| `expires_before`   | date (ISO 8601)     | 否       | 如果定义，返回在指定时间之前过期的令牌。 |
| `last_used_after`  | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之后最后使用的令牌。 |
| `last_used_before` | datetime (ISO 8601) | 否       | 如果定义，返回在指定时间之前最后使用的令牌。 |
| `revoked`          | boolean             | 否       | 如果为 `true`，仅返回已吊销的令牌。 |
| `search`           | string              | 否       | 如果定义，返回名称中包含指定值的令牌。 |
| `sort`             | string              | 否       | 如果定义，按指定值对结果进行排序。可选值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`            | string              | 否       | 如果定义，返回具有指定状态的令牌。可选值：`active` 和 `inactive`。 |

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
        "active": true,
        "expires_at": null
    }
]
```

不成功的响应示例：

- `401: Unauthorized`
- `404 Project Not Found`

### 为项目服务账户创建个人访问令牌

为指定项目中的现有服务账户创建个人访问令牌。

```plaintext
POST /projects/:id/service_accounts/:user_id/personal_access_tokens
```

参数：

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer        | 是      | 服务账户的 ID。 |
| `name`        | string         | 是      | 个人访问令牌的名称。 |
| `description` | string         | 否       | 个人访问令牌的描述。 |
| `scopes`      | array          | 是      | 批准的 scopes 数组。有关可能的值列表，请参阅[个人访问令牌 scopes](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。 |
| `expires_at`  | date           | 否       | 访问令牌的过期日期，ISO 格式 (`YYYY-MM-DD`)。如未指定，将设置为[最大允许有效期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/35/service_accounts/71/personal_access_tokens" --data "scopes[]=api,read_user,read_repository" --data "name=service_accounts_token"
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
  "active":true,
  "expires_at":"2024-06-12",
  "token":"<token_value>"
}
```

### 吊销项目服务账户的个人访问令牌

吊销指定项目中的现有服务账户的个人访问令牌。

```plaintext
DELETE /projects/:id/service_accounts/:user_id/personal_access_tokens/:token_id
```

参数：

| 属性  | 类型           | 是否必需 | 描述 |
| ---------- | -------------- | -------- | ----------- |
| `id`       | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer        | 是      | 服务账户的 ID。 |
| `token_id` | integer        | 是      | 令牌的 ID。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/35/service_accounts/71/personal_access_tokens/6"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request` 如果未成功吊销。
- `401: Unauthorized` 如果请求未经授权。
- `403: Forbidden` 如果请求不被允许。
- `404: Not Found` 如果访问令牌不存在。

### 轮换项目服务账户的个人访问令牌

轮换指定项目中的现有服务账户的个人访问令牌。这将创建一个有效期为一周的新令牌，并吊销所有现有令牌。

```plaintext
POST /projects/:id/service_accounts/:user_id/personal_access_tokens/:token_id/rotate
```

参数：

| 属性    | 类型           | 是否必需 | 描述 |
| ------------ | -------------- | -------- | ----------- |
| `id`         | integer or string | 是      | 目标项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`    | integer        | 是      | 服务账户的 ID。 |
| `token_id`   | integer        | 是      | 令牌的 ID。 |
| `expires_at` | date           | 否       | 访问令牌的过期日期，ISO 格式 (`YYYY-MM-DD`)。在极狐GitLab 17.9 引入。如果令牌需要过期日期，则默认为一周。如果不需要，则默认为[最大允许有效期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/35/service_accounts/71/personal_access_tokens/6/rotate"
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
  "active":true,
  "expires_at":"2023-06-20",
  "token":"<token_value>"
}
```