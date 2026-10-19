---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 系统钩子 API
description: "使用 REST API 设置和管理系统钩子。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理[系统钩子](../administration/system_hooks.md)。系统钩子不同于[群组 webhook](group_webhooks.md)（影响群组中的所有项目和子群组），也不同于[项目 webhook](project_webhooks.md)（仅限单个项目）。

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
    "organization_id": 1,
    "alert_status": "executable",
    "disabled_until": null,
    "url_variables": [],
    "push_events_branch_filter": "",
    "branch_filter_strategy": "wildcard",
    "custom_webhook_template": "{\"event\":\"{{object_kind}}\"}",
    "custom_headers": [
      {
        "key": "X-Custom-Header"
      }
    ],
    "token_present": false,
    "signing_token_present": false
  }
]
```

<a id="retrieve-system-hook"></a>

## 检索系统钩子

根据 ID 检索系统钩子。

```plaintext
GET /hooks/:id
```

| 属性 | 类型    | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | integer | 是      | 钩子的 ID。 |

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
  "organization_id": 1,
  "alert_status": "executable",
  "disabled_until": null,
  "url_variables": [],
  "push_events_branch_filter": "",
  "branch_filter_strategy": "wildcard",
  "custom_webhook_template": "{\"event\":\"{{object_kind}}\"}",
  "custom_headers": [
    {
      "key": "X-Custom-Header"
    }
  ],
  "token_present": false,
  "signing_token_present": false
}
```

<a id="add-new-system-hook"></a>

## 添加新系统钩子

添加新的系统钩子。

```plaintext
POST /hooks
```

| 属性                   | 类型    | 是否必需 | 描述 |
|-----------------------------|---------|----------|-------------|
| `url`                       | string  | 是      | 钩子 URL。 |
| `branch_filter_strategy`    | string  | 否       | 按分支筛选推送事件。可选值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `custom_webhook_template`   | string  | 否       | 请求载荷的自定义模板。 |
| `description`               | string  | 否       | 钩子的描述。 |
| `enable_ssl_verification`   | boolean | 否       | 触发钩子时是否进行 SSL 验证。 |
| `merge_requests_events`     | boolean | 否       | 在合并请求事件时触发钩子。 |
| `name`                      | string  | 否       | 钩子的名称。 |
| `push_events`               | boolean | 否       | 当为 true 时，钩子在推送事件时触发。 |
| `push_events_branch_filter` | string  | 否       | 仅在匹配分支的推送事件时触发钩子。 |
| `repository_update_events`  | boolean | 否       | 在代码仓库更新事件时触发钩子。 |
| `signing_token`             | string  | 否       | 用于计算 `webhook-signature` 请求头的 HMAC 签名令牌。必须为 `whsec_<base64>` 格式，编码一个 32 字节的密钥。不会在响应中返回。 |
| `tag_push_events`           | boolean | 否       | 当为 true 时，钩子在新标签被推送时触发。 |
| `token`                     | string  | 否       | 用于验证接收到的载荷的密钥令牌。不会在响应中返回。 |

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
    "organization_id": 1,
    "alert_status": "executable",
    "disabled_until": null,
    "url_variables": [],
    "push_events_branch_filter": "",
    "branch_filter_strategy": "wildcard",
    "custom_webhook_template": "{\"event\":\"{{object_kind}}\"}",
    "custom_headers": [
      {
        "key": "X-Custom-Header"
      }
    ],
    "token_present": false,
    "signing_token_present": false
  }
]
```

<a id="update-system-hook"></a>

## 更新系统钩子

更新现有的系统钩子。

```plaintext
PUT /hooks/:hook_id
```

| 属性                   | 类型    | 是否必需 | 描述 |
|-----------------------------|---------|----------|-------------|
| `hook_id`                   | integer | 是      | 系统钩子的 ID。 |
| `branch_filter_strategy`    | string  | 否       | 按分支筛选推送事件。可选值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `custom_webhook_template`   | string  | 否       | 请求载荷的自定义模板。 |
| `description`               | string  | 否       | 钩子的描述。 |
| `enable_ssl_verification`   | boolean | 否       | 触发钩子时是否进行 SSL 验证。 |
| `merge_requests_events`     | boolean | 否       | 在合并请求事件时触发钩子。 |
| `name`                      | string  | 否       | 钩子的名称。 |
| `push_events`               | boolean | 否       | 当为 true 时，钩子在推送事件时触发。 |
| `push_events_branch_filter` | string  | 否       | 仅在匹配分支的推送事件时触发钩子。 |
| `repository_update_events`  | boolean | 否       | 在代码仓库更新事件时触发钩子。 |
| `signing_token`             | string  | 否       | 用于计算 `webhook-signature` 请求头的 HMAC 签名令牌。必须为 `whsec_<base64>` 格式，编码一个 32 字节的密钥。不会在响应中返回。 |
| `tag_push_events`           | boolean | 否       | 当为 true 时，钩子在新标签被推送时触发。 |
| `token`                     | string  | 否       | 用于验证接收到的载荷的密钥令牌。不会在响应中返回。 |
| `url`                       | string  | 否       | 钩子 URL。 |

<a id="test-system-hook"></a>

## 测试系统钩子

使用模拟数据执行系统钩子。

```plaintext
POST /hooks/:id
```

| 属性 | 类型    | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | integer | 是      | 钩子的 ID。 |

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

删除系统钩子。

```plaintext
DELETE /hooks/:id
```

| 属性 | 类型    | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | integer | 是      | 钩子的 ID。 |

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

| 属性 | 类型    | 是否必需 | 描述 |
|-----------|---------|----------|-------------|
| `hook_id` | integer | 是      | 系统钩子的 ID。 |
| `key`     | string  | 是      | URL 变量的键。 |
| `value`   | string  | 是      | URL 变量的值。 |

成功时，此端点返回响应码 `204 No Content`。

<a id="delete-a-url-variable"></a>

## 删除 URL 变量

```plaintext
DELETE /hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 系统钩子的 ID。 |
| `key`     | string            | 是      | URL 变量的键。 |

成功时，此端点返回响应码 `204 No Content`。
