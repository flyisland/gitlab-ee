---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 系统钩子 API
description: "Set up and manage system hooks with the REST API."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理 [系统钩子](../administration/system_hooks.md)。系统钩子与影响群组中所有项目和子群组的 [群组 webhook](group_webhooks.md) 以及仅限于单个项目的 [项目 webhook](project_webhooks.md) 不同。

先决条件：

- 您必须是管理员。

<a id="list-all-system-hooks"></a>

## 列出所有系统钩子

列出所有系统钩子。

```plaintext
GET /hooks
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/hooks"
```

示例响应：

```json
[
  {
    "id":1,
    "url":"https://gitlab.example.com/hook",
    "name": "Hook name",
    "description": "Hook description",
    "created_at":"2016-10-31T12:32:15.192Z",
    "push_events":true,
    "tag_push_events":false,
    "merge_requests_events": true,
    "repository_update_events": true,
    "enable_ssl_verification":true,
    "url_variables": [],
    "token_present": false,
    "signing_token_present": false
  }
]
```

<a id="retrieve-system-hook"></a>

## 检索系统钩子

{{< history >}}

- `name` 和 `description` 属性在极狐GitLab 17.1 中引入。
- `token_present` 和 `signing_token_present` 属性在极狐GitLab 19.0 中引入。

{{< /history >}}

通过其 ID 检索系统钩子。

```plaintext
GET /hooks/:id
```

| 属性 | 类型 | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `id` | 整数 | 是 | 钩子的 ID。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/hooks/1"
```

示例响应：

```json
{
  "id": 1,
  "url": "https://gitlab.example.com/hook",
  "name": "Hook name",
  "description": "Hook description",
  "created_at": "2016-10-31T12:32:15.192Z",
  "push_events": true,
  "tag_push_events": false,
  "merge_requests_events": true,
  "repository_update_events": true,
  "enable_ssl_verification": true,
  "url_variables": [],
  "token_present": false,
  "signing_token_present": false
}
```

<a id="add-new-system-hook"></a>

## 添加新系统钩子

{{< history >}}

- `name` 和 `description` 属性在极狐GitLab 17.1 中引入。
- `signing_token` 属性在极狐GitLab 19.0 中引入，[附带一个功能标志](../administration/feature_flags/_index.md) 名为 `webhook_signing_token`。默认启用。

{{< /history >}}

> [!flag]
> `signing_token` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。

添加一个新的系统钩子。

```plaintext
POST /hooks
```

| 属性 | 类型 | 必需 | 描述 |
|-----------------------------|---------|----------|-------------|
| `url` | 字符串 | 是 | 钩子 URL。 |
| `branch_filter_strategy` | 字符串 | 否 | 按分支过滤推送事件。可选值：`wildcard`（默认）、`regex` 和 `all_branches`。 |
| `description` | 字符串 | 否 | 钩子的描述。 |
| `enable_ssl_verification` | 布尔值 | 否 | 触发钩子时进行 SSL 验证。 |
| `merge_requests_events` | 布尔值 | 否 | 在合并请求事件时触发钩子。 |
| `name` | 字符串 | 否 | 钩子的名称。 |
| `push_events` | 布尔值 | 否 | 为 true 时，钩子在推送事件时触发。 |
| `push_events_branch_filter` | 字符串 | 否 | 仅对匹配的分支在推送事件时触发钩子。 |
| `repository_update_events` | 布尔值 | 否 | 在仓库更新事件时触发钩子。 |
| `signing_token` | 字符串 | 否 | 用于计算 `webhook-signature` 头的 HMAC 签名令牌。必须采用 `whsec_<base64>` 格式，编码一个 32 字节密钥。不在响应中返回。 |
| `tag_push_events` | 布尔值 | 否 | 为 true 时，钩子在新标签推送时触发。 |
| `token` | 字符串 | 否 | 用于验证接收到的有效载荷的密钥令牌。不在响应中返回。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/hooks?url=https://gitlab.example.com/hook"
```

示例响应：

```json
[
  {
    "id":1,
    "url":"https://gitlab.example.com/hook",
    "name": "Hook name",
    "description": "Hook description",
    "created_at":"2016-10-31T12:32:15.192Z",
    "push_events":true,
    "tag_push_events":false,
    "merge_requests_events": true,
    "repository_update_events": true,
    "enable_ssl_verification":true,
    "url_variables": [],
    "token_present": false,
    "signing_token_present": false
  }
]
```

<a id="update-system-hook"></a>

## 更新系统钩子

{{< history >}}

- `name` 和 `description` 属性在极狐GitLab 17.1 中引入。
- `signing_token` 属性在极狐GitLab 19.0 中引入，[附带一个功能标志](../administration/feature_flags/_index.md) 名为 `webhook_signing_token`。默认启用。

{{< /history >}}

> [!flag]
> `signing_token` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。

更新一个现有的系统钩子。

```plaintext
PUT /hooks/:hook_id
```

| 属性 | 类型 | 必需 | 描述 |
|-----------------------------|---------|----------|-------------|
| `hook_id` | 整数 | 是 | 系统钩子的 ID。 |
| `branch_filter_strategy` | 字符串 | 否 | 按分支过滤推送事件。可选值：`wildcard`（默认）、`regex` 和 `all_branches`。 |
| `description` | 字符串 | 否 | 钩子的描述。 |
| `enable_ssl_verification` | 布尔值 | 否 | 触发钩子时进行 SSL 验证。 |
| `merge_requests_events` | 布尔值 | 否 | 在合并请求事件时触发钩子。 |
| `name` | 字符串 | 否 | 钩子的名称。 |
| `push_events` | 布尔值 | 否 | 为 true 时，钩子在推送事件时触发。 |
| `push_events_branch_filter` | 字符串 | 否 | 仅对匹配的分支在推送事件时触发钩子。 |
| `repository_update_events` | 布尔值 | 否 | 在仓库更新事件时触发钩子。 |
| `signing_token` | 字符串 | 否 | 用于计算 `webhook-signature` 头的 HMAC 签名令牌。必须采用 `whsec_<base64>` 格式，编码一个 32 字节密钥。不在响应中返回。 |
| `tag_push_events` | 布尔值 | 否 | 为 true 时，钩子在新标签推送时触发。 |
| `token` | 字符串 | 否 | 用于验证接收到的有效载荷的密钥令牌。不在响应中返回。 |
| `url` | 字符串 | 否 | 钩子 URL。 |

<a id="test-system-hook"></a>

## 测试系统钩子

使用模拟数据执行系统钩子。

```plaintext
POST /hooks/:id
```

| 属性 | 类型 | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `id` | 整数 | 是 | 钩子的 ID。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/hooks/1"
```

响应始终为模拟数据：

```json
{
   "project_id" : 1,
   "owner_email" : "example@gitlabhq.com",
   "owner_name" : "Someone",
   "name" : "Ruby",
   "path" : "ruby",
   "event_name" : "project_create"
}
```

<a id="delete-system-hook"></a>

## 删除系统钩子

删除一个系统钩子。

```plaintext
DELETE /hooks/:id
```

| 属性 | 类型 | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `id` | 整数 | 是 | 钩子的 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/hooks/2"
```

<a id="set-a-url-variable"></a>

## 设置 URL 变量

```plaintext
PUT /hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|---------|----------|-------------|
| `hook_id` | 整数 | 是 | 系统钩子的 ID。 |
| `key` | 字符串 | 是 | URL 变量的键。 |
| `value` | 字符串 | 是 | URL 变量的值。 |

成功时，此端点返回响应代码 `204 No Content`。

<a id="delete-a-url-variable"></a>

## 删除 URL 变量

```plaintext
DELETE /hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | 整数 | 是 | 系统钩子的 ID。 |
| `key` | 字符串 | 是 | URL 变量的键。 |

成功时，此端点返回响应代码 `204 No Content`。