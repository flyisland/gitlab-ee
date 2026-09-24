---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 群组服务账号 API
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

使用此 API 与您的群组的服务帐户进行交互。有关更多信息，请参阅 [Service accounts](../user/profile/service_accounts.md)。

前提条件：

- 您必须具有实例的管理员访问权限，或者拥有极狐GitLab.com 群组的所有者角色。

<a id="list-all-service-account-users"></a>

## 列出所有服务帐户用户

{{< history >}}

- 引入于极狐GitLab 17.1。

{{< /history >}}

列出指定顶级群组中的所有服务帐户用户。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination)过滤结果。

```plaintext
GET /groups/:id/service_accounts
```

参数：

| 属性         | 类型             | 必需   | 描述                                                             |
|:-------------|:-----------------|:-------|:----------------------------------------------------------------|
| `id`         | integer/string   | yes    | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by`   | string           | no     | 按 `username` 或 `id` 排序用户列表。默认是 `id`。              |
| `sort`       | string           | no     | 指定按 `asc` 或 `desc` 排序。默认是 `desc`。                     |

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
    "username": "service_account_group_346_<random_hash>",
    "name": "Service account user",
    "email": "service_account_group_346_<random_hash>@noreply.gitlab.example.com"
  }
]
```

<a id="create-a-service-account-user"></a>

## 创建一个服务帐户用户

{{< history >}}

- 引入于极狐GitLab 16.1。
- 指定服务帐户用户名或名称引入于极狐GitLab 16.10。
- 指定服务帐户用户电子邮件地址引入于极狐GitLab 17.9，使用名为 `group_service_account_custom_email` 的[功能标志](../administration/feature_flags.md)。
- 在极狐GitLab 17.11 中 GA。功能标志 `group_service_account_custom_email` 被移除。

{{< /history >}}

在给定的顶级群组中创建一个服务帐户用户。

{{< alert type="note" >}}

此端点仅适用于顶级群组。

{{< /alert >}}

```plaintext
POST /groups/:id/service_accounts
```

支持的属性：

| 属性       | 类型             | 必需   | 描述                                                                                                                                                                                                                       |
|:-----------|:-----------------|:-------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`       | integer/string   | yes    | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                                         |
| `name`     | string           | no     | 用户帐户名称。如果未指定，则使用 `Service account user`。                                                                                                                                                                   |
| `username` | string           | no     | 用户帐户用户名。如果未指定，则生成一个以 `service_account_group_` 为前缀的名称。                                                                                                                                             |
| `email`    | string           | no     | 用户帐户电子邮件。如果未指定，则生成一个以 `service_account_group_` 为前缀的电子邮件。自定义电子邮件地址在账户激活前需要确认，除非群组有一个匹配的 [verified domain](../user/enterprise_user/_index.md#verified-domains-for-groups)。 |

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

<a id="update-a-service-account-user"></a>

## 更新一个服务帐户用户

{{< history >}}

- 引入于极狐GitLab 17.10。

{{< /history >}}

更新给定顶级群组中的服务帐户用户。

{{< alert type="note" >}}

此端点仅适用于顶级群组。

{{< /alert >}}

```plaintext
PATCH /groups/:id/service_accounts/:user_id
```

参数：

| 属性       | 类型             | 必需   | 描述                                                             |
|:-----------|:-----------------|:-------|:----------------------------------------------------------------|
| `id`       | integer/string   | yes    | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`  | integer          | yes    | 服务帐户用户的 ID。                                              |
| `name`     | string           | no     | 用户的名称。                                                     |
| `username` | string           | no     | 用户的用户名。                                                   |

示例请求：

```shell
curl --request PATCH --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/345/service_accounts/57" --data "name=Updated Service Account"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_group_345_6018816a18e515214e0c34c2b33523fc",
  "name": "Updated Service Account",
  "email": "service_account_group_345_<random_hash>@noreply.gitlab.example.com"
}
```

<a id="delete-a-service-account-user"></a>

## 删除一个服务帐户用户

{{< history >}}

- 引入于极狐GitLab 17.1。

{{< /history >}}

从给定的顶级群组中删除服务帐户用户。

{{< alert type="note" >}}

此端点仅适用于顶级群组。

{{< /alert >}}

```plaintext
DELETE /groups/:id/service_accounts/:user_id
```

参数：

| 属性                     | 类型             | 必需   | 描述                                                             |
|:-------------------------|:-----------------|:-------|:----------------------------------------------------------------|
| `id`                     | integer/string   | yes    | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`                | integer          | yes    | 服务帐户用户的 ID。                                              |
| `hard_delete`            | boolean          | no     | 如果为 true，则通常会被[移动到 Ghost 用户](../user/profile/account/delete_account.md#associated-records)的贡献会被删除，以及由此服务帐户用户唯一拥有的群组。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/345/service_accounts/181"
```

<a id="list-all-personal-access-tokens-for-a-service-account-user"></a>

## 列出服务帐户用户的所有个人访问令牌

{{< history >}}

- 引入于极狐GitLab 17.11。

{{< /history >}}

列出顶级群组中服务帐户用户的所有个人访问令牌。

```plaintext
GET /groups/:id/service_accounts/:user_id/personal_access_tokens
```

支持的属性：

| 属性                  | 类型                  | 必需   | 描述                                                             |
| --------------------- | --------------------- | -------| ----------- |
| `id`                  | integer/string        | yes    | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`             | integer               | yes    | 服务帐户用户的 ID。                                              |
| `created_after`       | datetime (ISO 8601)   | No     | 如果定义，返回在指定时间之后创建的令牌。                         |
| `created_before`      | datetime (ISO 8601)   | No     | 如果定义，返回在指定时间之前创建的令牌。                         |
| `expires_after`       | date (ISO 8601)       | No     | 如果定义，返回在指定时间之后过期的令牌。                         |
| `expires_before`      | date (ISO 8601)       | No     | 如果定义，返回在指定时间之前过期的令牌。                         |
| `last_used_after`     | datetime (ISO 8601)   | No     | 如果定义，返回在指定时间之后最后使用的令牌。                     |
| `last_used_before`    | datetime (ISO 8601)   | No     | 如果定义，返回在指定时间之前最后使用的令牌。                     |
| `revoked`             | boolean               | No     | 如果为 `true`，只返回已吊销的令牌。                              |
| `search`              | string                | No     | 如果定义，返回名称中包含指定值的令牌。                           |
| `sort`                | string                | No     | 如果定义，按指定值排序结果。可能的值：`created_asc`、`created_desc`、`expires_asc`、`expires_desc`、`last_used_asc`、`last_used_desc`、`name_asc`、`name_desc`。 |
| `state`               | string                | No     | 如果定义，返回具有指定状态的令牌。可能的值：`active` 和 `inactive`。 |

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

不成功响应的示例：

- `401: Unauthorized`
- `404 Group Not Found`

<a id="create-a-personal-access-token-for-a-service-account-user"></a>

## 为服务帐户用户创建个人访问令牌

{{< history >}}

- 引入于极狐GitLab 16.1。

{{< /history >}}

为给定顶级群组中的现有服务帐户用户创建个人访问令牌。

```plaintext
POST /groups/:id/service_accounts/:user_id/personal_access_tokens
```

参数：

| 属性          | 类型             | 必需   | 描述                                                             |
| ---------     | ---------------  | -------| ----------- |
| `id`          | integer/string   | yes    | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`     | integer          | yes    | 服务帐户用户的 ID。                                              |
| `name`        | string           | yes    | 个人访问令牌的名称。                                             |
| `description` | string           | no     | 个人访问令牌的描述。                                             |
| `scopes`      | array            | yes    | 批准的权限范围数组。有关可能的值列表，请参阅 [Personal access token scopes](../user/profile/personal_access_tokens.md#personal-access-token-scopes)。 |
| `expires_at`  | date             | no     | 访问令牌的过期日期，格式为 ISO (`YYYY-MM-DD`)。如果未指定，则日期设置为 [最大允许生命周期限制](../user/profile/personal_access_tokens.md#access-token-expiration)。 |

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

<a id="revoke-a-personal-access-token-for-a-service-account-user"></a>

## 吊销服务帐户用户的个人访问令牌

{{< history >}}

- 引入于极狐GitLab 17.10。

{{< /history >}}

为给定顶级群组中的现有服务帐户用户吊销个人访问令牌。

{{< alert type="note" >}}

此端点仅适用于顶级群组。

{{< /alert >}}

```plaintext
DELETE /groups/:id/service_accounts/:user_id/personal_access_tokens/:token_id
```

参数：

| 属性         | 类型             | 必需   | 描述                                                             |
| ------------ | ---------------  | -------| ----------- |
| `id`         | integer/string   | yes    | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`    | integer          | yes    | 服务帐户用户的 ID。                                              |
| `token_id`   | integer          | yes    | 令牌的 ID。                                                      |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/35/service_accounts/71/personal_access_tokens/6"
```

如果成功，返回 `204: No Content`。

其他可能的响应：

- `400: Bad Request` 如果未成功吊销。
- `401: Unauthorized` 如果请求未被授权。
- `403: Forbidden` 如果请求不被允许。
- `404: Not Found` 如果访问令牌不存在。

<a id="rotate-a-personal-access-token-for-a-service-account-user"></a>

## 旋转服务帐户用户的个人访问令牌

{{< history >}}

- 引入于极狐GitLab 16.1。

{{< /history >}}

为给定顶级群组中的现有服务帐户用户旋转个人访问令牌。这将创建一个有效期为一周的新令牌，并吊销所有现有令牌。

{{< alert type="note" >}}

此端点仅适用于顶级群组。

{{< /alert >}}

```plaintext
POST /groups/:id/service_accounts/:user_id/personal_access_tokens/:token_id/rotate
```

参数：

| 属性         | 类型             | 必需   | 描述                                                             |
| ------------ | ---------------  | -------| ----------- |
| `id`         | integer/string   | yes    | 目标群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`    | integer          | yes    | 服务帐户用户的 ID。                                              |
| `token_id`   | integer          | yes    | 令牌的 ID。                                                      |
| `expires_at` | date             | no     | 访问令牌的过期日期，格式为 ISO (`YYYY-MM-DD`)。引入于极狐GitLab 17.9。如果未定义，则令牌在一周后过期。 |

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
