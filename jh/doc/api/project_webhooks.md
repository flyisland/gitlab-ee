---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目 Webhook API
description: "使用 REST API 为项目设置和管理 Webhook。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[项目 Webhook](../user/project/integrations/webhooks.md)。项目 Webhook
不同于影响整个实例的[系统钩子](system_hooks.md)，也不同于影响群组中所有项目和子群组的[群组 Webhook](group_webhooks.md)。

先决条件：

- 您必须是管理员，或者拥有该项目的维护者或所有者角色。

<a id="list-webhooks-for-a-project"></a>

## 列出项目的 Webhook

获取项目 Webhook 的列表。

```plaintext
GET /projects/:id/hooks
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

<a id="retrieve-a-project-webhook"></a>

## 检索项目 Webhook

检索项目的指定 Webhook。

```plaintext
GET /projects/:id/hooks/:hook_id
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例响应：

```json
{
  "id": 1,
  "url": "http://example.com/hook",
  "name": "Hook name",
  "description": "Hook description",
  "project_id": 3,
  "push_events": true,
  "push_events_branch_filter": "",
  "issues_events": true,
  "confidential_issues_events": true,
  "merge_requests_events": true,
  "tag_push_events": true,
  "note_events": true,
  "confidential_note_events": true,
  "job_events": true,
  "pipeline_events": true,
  "wiki_page_events": true,
  "deployment_events": true,
  "releases_events": true,
  "milestone_events": true,
  "feature_flag_events": true,
  "enable_ssl_verification": true,
  "repository_update_events": false,
  "alert_status": "executable",
  "disabled_until": null,
  "url_variables": [ ],
  "created_at": "2012-10-12T17:04:47Z",
  "resource_access_token_events": true,
  "custom_webhook_template": "{\"event\":\"{{object_kind}}\"}",
  "custom_headers": [
    {
      "key": "Authorization"
    }
  ],
  "token_present": false,
  "signing_token_present": false
}
```

<a id="list-project-webhook-events"></a>

## 列出项目 Webhook 事件

列出指定项目 Webhook 从起始日期起过去 7 天内的所有事件。

```plaintext
GET /projects/:id/hooks/:hook_id/events
```

支持的属性：

| 属性  | 类型              | 是否必需 | 描述 |
|:-----------|:------------------|:---------|:------------|
| `hook_id`  | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`       | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `status`   | integer or string | 否       | 事件的响应状态码，例如：`200` 或 `500`。您可以按状态类别搜索：`successful`（200-299）、`client_failure`（400-499）和 `server_failure`（500-599）。 |
| `page`     | integer           | 否       | 要检索的页码。默认为 `1`。 |
| `per_page` | integer           | 否       | 每页返回的记录数。默认为 `20`。 |

示例响应：

```json
[
  {
    "id": 1,
    "url": "https://example.net/",
    "trigger": "push_hooks",
    "request_headers": {
      "Content-Type": "application/json",
      "User-Agent": "GitLab/17.1.0-pre",
      "Idempotency-Key": "3a427872-00df-429c-9bc9-a9475de2efe4",
      "X-Gitlab-Event": "Push Hook",
      "X-Gitlab-Webhook-UUID": "3c5c0404-c866-44bc-a5f6-452bb1bfc76e",
      "X-Gitlab-Instance": "https://gitlab.example.com",
      "X-Gitlab-Event-UUID": "9cebe914-4827-408f-b014-cfa23a47a35f",
      "X-Gitlab-Token": "[REDACTED]"
    },
    "request_data": {
      "object_kind": "push",
      "event_name": "push",
      "before": "468abc807a2b2572f43e72c743b76cee6db24025",
      "after": "f15b32277d2c55c6c595845a87109b09c913c556",
      "ref": "refs/heads/master",
      "ref_protected": true,
      "checkout_sha": "f15b32277d2c55c6c595845a87109b09c913c556",
      "message": null,
      "user_id": 1,
      "user_name": "Administrator",
      "user_username": "root",
      "user_email": null,
      "user_avatar": "https://www.gravatar.com/avatar/13efe0d4559475ba84ecc802061febbdea6e224fcbffd7ec7da9cd431845299c?s=80&d=identicon",
      "project_id": 7,
      "project": {
        "id": 7,
        "name": "Flight",
        "description": "Incidunt ea ab officia a veniam.",
        "web_url": "https://gitlab.example.com/flightjs/Flight",
        "avatar_url": null,
        "git_ssh_url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "git_http_url": "https://gitlab.example.com/flightjs/Flight.git",
        "namespace": "Flightjs",
        "visibility_level": 10,
        "path_with_namespace": "flightjs/Flight",
        "default_branch": "master",
        "ci_config_path": null,
        "homepage": "https://gitlab.example.com/flightjs/Flight",
        "url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "ssh_url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "http_url": "https://gitlab.example.com/flightjs/Flight.git"
      },
      "commits": [
        {
          "id": "f15b32277d2c55c6c595845a87109b09c913c556",
          "message": "v1.5.2\n",
          "title": "v1.5.2",
          "timestamp": "2017-06-19T14:39:53-07:00",
          "url": "https://gitlab.example.com/flightjs/Flight/-/commit/f15b32277d2c55c6c595845a87109b09c913c556",
          "author": {
            "name": "Andrew Lunny",
            "email": "[REDACTED]"
          },
          "added": [],
          "modified": [
            "package.json"
          ],
          "removed": []
        },
        {
          "id": "8749d49930866a4871fa086adbd7d2057fcc3ebb",
          "message": "Merge pull request #378 from flightjs/alunny/publish_lib\n\npublish lib and index to npm",
          "title": "Merge pull request #378 from flightjs/alunny/publish_lib",
          "timestamp": "2017-06-16T10:26:39-07:00",
          "url": "https://gitlab.example.com/flightjs/Flight/-/commit/8749d49930866a4871fa086adbd7d2057fcc3ebb",
          "author": {
            "name": "angus croll",
            "email": "[REDACTED]"
          },
          "added": [],
          "modified": [
            "package.json"
          ],
          "removed": []
        },
        {
          "id": "468abc807a2b2572f43e72c743b76cee6db24025",
          "message": "publish lib and index to npm\n",
          "title": "publish lib and index to npm",
          "timestamp": "2017-06-16T10:23:04-07:00",
          "url": "https://gitlab.example.com/flightjs/Flight/-/commit/468abc807a2b2572f43e72c743b76cee6db24025",
          "author": {
            "name": "Andrew Lunny",
            "email": "[REDACTED]"
          },
          "added": [],
          "modified": [
            "package.json"
          ],
          "removed": []
        }
      ],
      "total_commits_count": 3,
      "push_options": {},
      "repository": {
        "name": "Flight",
        "url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "description": "Incidunt ea ab officia a veniam.",
        "homepage": "https://gitlab.example.com/flightjs/Flight",
        "git_http_url": "https://gitlab.example.com/flightjs/Flight.git",
        "git_ssh_url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "visibility_level": 10
      }
    },
    "response_headers": {
      "Date": "Sun, 26 May 2024 03:03:17 GMT",
      "Content-Type": "application/json; charset=utf-8",
      "Content-Length": "16",
      "Connection": "close",
      "X-Powered-By": "Express",
      "Access-Control-Allow-Origin": "*",
      "X-Pd-Status": "sent to primary"
    },
    "response_body": "{\"success\":true}",
    "execution_duration": 1.0906479999999874,
    "response_status": "200"
  },
  {
    "id": 2,
    "url": "https://example.net/",
    "trigger": "push_hooks",
    "request_headers": {
      "Content-Type": "application/json",
      "User-Agent": "GitLab/17.1.0-pre",
      "Idempotency-Key": "7c6e0583-49f2-4dc5-a50b-4c0bcf3c1b27",
      "X-Gitlab-Event": "Push Hook",
      "X-Gitlab-Webhook-UUID": "a753eedb-1d72-4549-9ca7-eac8ea8e50dd",
      "X-Gitlab-Instance": "https://gitlab.example.com",
      "X-Gitlab-Event-UUID": "842d7c3e-3114-4396-8a95-66c084d53cb1",
      "X-Gitlab-Token": "[REDACTED]"
    },
    "request_data": {
      "object_kind": "push",
      "event_name": "push",
      "before": "468abc807a2b2572f43e72c743b76cee6db24025",
      "after": "f15b32277d2c55c6c595845a87109b09c913c556",
      "ref": "refs/heads/master",
      "ref_protected": true,
      "checkout_sha": "f15b32277d2c55c6c595845a87109b09c913c556",
      "message": null,
      "user_id": 1,
      "user_name": "Administrator",
      "user_username": "root",
      "user_email": null,
      "user_avatar": "https://www.gravatar.com/avatar/13efe0d4559475ba84ecc802061febbdea6e224fcbffd7ec7da9cd431845299c?s=80&d=identicon",
      "project_id": 7,
      "project": {
        "id": 7,
        "name": "Flight",
        "description": "Incidunt ea ab officia a veniam.",
        "web_url": "https://gitlab.example.com/flightjs/Flight",
        "avatar_url": null,
        "git_ssh_url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "git_http_url": "https://gitlab.example.com/flightjs/Flight.git",
        "namespace": "Flightjs",
        "visibility_level": 10,
        "path_with_namespace": "flightjs/Flight",
        "default_branch": "master",
        "ci_config_path": null,
        "homepage": "https://gitlab.example.com/flightjs/Flight",
        "url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "ssh_url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "http_url": "https://gitlab.example.com/flightjs/Flight.git"
      },
      "commits": [
        {
          "id": "f15b32277d2c55c6c595845a87109b09c913c556",
          "message": "v1.5.2\n",
          "title": "v1.5.2",
          "timestamp": "2017-06-19T14:39:53-07:00",
          "url": "https://gitlab.example.com/flightjs/Flight/-/commit/f15b32277d2c55c6c595845a87109b09c913c556",
          "author": {
            "name": "Andrew Lunny",
            "email": "[REDACTED]"
          },
          "added": [],
          "modified": [
            "package.json"
          ],
          "removed": []
        },
        {
          "id": "8749d49930866a4871fa086adbd7d2057fcc3ebb",
          "message": "Merge pull request #378 from flightjs/alunny/publish_lib\n\npublish lib and index to npm",
          "title": "Merge pull request #378 from flightjs/alunny/publish_lib",
          "timestamp": "2017-06-16T10:26:39-07:00",
          "url": "https://gitlab.example.com/flightjs/Flight/-/commit/8749d49930866a4871fa086adbd7d2057fcc3ebb",
          "author": {
            "name": "angus croll",
            "email": "[REDACTED]"
          },
          "added": [],
          "modified": [
            "package.json"
          ],
          "removed": []
        },
        {
          "id": "468abc807a2b2572f43e72c743b76cee6db24025",
          "message": "publish lib and index to npm\n",
          "title": "publish lib and index to npm",
          "timestamp": "2017-06-16T10:23:04-07:00",
          "url": "https://gitlab.example.com/flightjs/Flight/-/commit/468abc807a2b2572f43e72c743b76cee6db24025",
          "author": {
            "name": "Andrew Lunny",
            "email": "[REDACTED]"
          },
          "added": [],
          "modified": [
            "package.json"
          ],
          "removed": []
        }
      ],
      "total_commits_count": 3,
      "push_options": {},
      "repository": {
        "name": "Flight",
        "url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "description": "Incidunt ea ab officia a veniam.",
        "homepage": "https://gitlab.example.com/flightjs/Flight",
        "git_http_url": "https://gitlab.example.com/flightjs/Flight.git",
        "git_ssh_url": "ssh://git@gitlab.example.com:2222/flightjs/Flight.git",
        "visibility_level": 10
      }
    },
    "response_headers": {
      "Date": "Sun, 26 May 2024 03:03:19 GMT",
      "Content-Type": "application/json; charset=utf-8",
      "Content-Length": "16",
      "Connection": "close",
      "X-Powered-By": "Express",
      "Access-Control-Allow-Origin": "*",
      "X-Pd-Status": "sent to primary"
    },
    "response_body": "{\"success\":true}",
    "execution_duration": 1.0716120000000728,
    "response_status": "200"
  }
]
```

<a id="resend-a-project-webhook-event"></a>

## 重新发送项目 Webhook 事件

重新发送特定的项目 Webhook 事件。

对于给定项目，此端点对每个经过身份验证的用户有每分钟五个请求的速率限制。同一项目中的所有 Webhook 共享该限制。在极狐GitLab 私有化部署上，管理员可以[更改此限制](../administration/settings/rate-limit-on-webhook-operations.md)。

```plaintext
POST /projects/:id/hooks/:hook_id/events/:hook_event_id/resend
```

支持的属性：

| 属性       | 类型    | 是否必需 | 描述 |
|:----------------|:--------|:---------|:------------|
| `hook_event_id` | integer | 是      | 项目 Webhook 事件的 ID。 |
| `hook_id`       | integer | 是      | 项目 Webhook 的 ID。 |

示例响应：

```json
{
  "response_status": 200
}
```

<a id="add-a-webhook-to-a-project"></a>

## 为项目添加 Webhook

> [!flag]
> `duo_flow_callback_enabled` 属性的可用性由功能标志控制。
> 在该功能不可用时启用该属性会返回 `400 Bad request`。
> 禁用它始终会被接受。

为指定项目添加 Webhook。

```plaintext
POST /projects/:id/hooks
```

支持的属性：

| 属性                      | 类型              | 是否必需 | 描述 |
|:-------------------------------|:------------------|:---------|:------------|
| `id`                           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url`                          | string            | 是      | 项目 Webhook URL。 |
| `branch_filter_strategy`       | string            | 否       | 按分支筛选推送事件。可能的值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `confidential_issues_events`   | boolean           | 否       | 在机密议题事件时触发项目 Webhook。 |
| `confidential_note_events`     | boolean           | 否       | 在机密评论事件时触发项目 Webhook。 |
| `custom_headers`               | array             | 否       | 项目 Webhook 的自定义请求头。 |
| `custom_webhook_template`      | string            | 否       | 项目 Webhook 的自定义 Webhook 模板。 |
| `deployment_events`            | boolean           | 否       | 在部署事件时触发项目 Webhook。 |
| `description`                  | string            | 否       | Webhook 的描述。 |
| `duo_flow_callback_enabled`    | boolean           | 否       | 将极狐GitLab Duo 任务流事件发送到项目 Webhook。 |
| `enable_ssl_verification`      | boolean           | 否       | 触发 Webhook 时执行 SSL 验证。 |
| `feature_flag_events`          | boolean           | 否       | 在功能标志事件时触发项目 Webhook。 |
| `issues_events`                | boolean           | 否       | 在议题事件时触发项目 Webhook。 |
| `job_events`                   | boolean           | 否       | 在作业事件时触发项目 Webhook。 |
| `merge_requests_events`        | boolean           | 否       | 在合并请求事件时触发项目 Webhook。 |
| `milestone_events`             | boolean           | 否       | 在里程碑事件时触发项目 Webhook。 |
| `name`                         | string            | 否       | 项目 Webhook 的名称。 |
| `note_events`                  | boolean           | 否       | 在评论事件时触发项目 Webhook。 |
| `pipeline_events`              | boolean           | 否       | 在流水线事件时触发项目 Webhook。 |
| `push_events`                  | boolean           | 否       | 在推送事件时触发项目 Webhook。 |
| `push_events_branch_filter`    | string            | 否       | 仅在匹配分支的推送事件时触发项目 Webhook。 |
| `releases_events`              | boolean           | 否       | 在发布事件时触发项目 Webhook。 |
| `resource_access_token_events` | boolean           | 否       | 在项目访问令牌过期事件时触发项目 Webhook。 |
| `signing_token`                | string            | 否       | 用于计算 `webhook-signature` 请求头的 HMAC 签名令牌。必须为 `whsec_<base64>` 格式，编码一个 32 字节的密钥。不会在响应中返回。 |
| `tag_push_events`              | boolean           | 否       | 在标签推送事件时触发项目 Webhook。 |
| `token`                        | string            | 否       | 用于验证接收到的载荷的密钥令牌。不会在响应中返回。 |
| `wiki_page_events`             | boolean           | 否       | 在 Wiki 事件时触发项目 Webhook。 |
| `resource_deploy_token_events` | boolean           | 否       | 在项目部署令牌过期事件时触发项目 Webhook。 |

<a id="update-a-project-webhook"></a>

## 更新项目 Webhook

> [!flag]
> `duo_flow_callback_enabled` 属性的可用性由功能标志控制。
> 在该功能不可用时启用该属性会返回 `400 Bad request`。
> 禁用它始终会被接受。

更新指定项目的项目 Webhook。

```plaintext
PUT /projects/:id/hooks/:hook_id
```

支持的属性：

| 属性                      | 类型              | 是否必需 | 描述 |
|:-------------------------------|:------------------|:---------|:------------|
| `hook_id`                      | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`                           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url`                          | string            | 是      | 项目 Webhook URL。 |
| `branch_filter_strategy`       | string            | 否       | 按分支筛选推送事件。可能的值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `custom_headers`               | array             | 否       | 项目 Webhook 的自定义请求头。 |
| `custom_webhook_template`      | string            | 否       | 项目 Webhook 的自定义 Webhook 模板。 |
| `description`                  | string            | 否       | 项目 Webhook 的描述。 |
| `confidential_issues_events`   | boolean           | 否       | 在机密议题事件时触发项目 Webhook。 |
| `confidential_note_events`     | boolean           | 否       | 在机密评论事件时触发项目 Webhook。 |
| `deployment_events`            | boolean           | 否       | 在部署事件时触发项目 Webhook。 |
| `duo_flow_callback_enabled`    | boolean           | 否       | 将极狐GitLab Duo 任务流事件发送到项目 Webhook。 |
| `enable_ssl_verification`      | boolean           | 否       | 触发钩子时执行 SSL 验证。 |
| `feature_flag_events`          | boolean           | 否       | 在功能标志事件时触发项目 Webhook。 |
| `issues_events`                | boolean           | 否       | 在议题事件时触发项目 Webhook。 |
| `job_events`                   | boolean           | 否       | 在作业事件时触发项目 Webhook。 |
| `merge_requests_events`        | boolean           | 否       | 在合并请求事件时触发项目 Webhook。 |
| `milestone_events`             | boolean           | 否       | 在里程碑事件时触发项目 Webhook。 |
| `name`                         | string            | 否       | 项目 Webhook 的名称。 |
| `note_events`                  | boolean           | 否       | 在评论事件时触发项目 Webhook。 |
| `pipeline_events`              | boolean           | 否       | 在流水线事件时触发项目 Webhook。 |
| `push_events`                  | boolean           | 否       | 在推送事件时触发项目 Webhook。 |
| `push_events_branch_filter`    | string            | 否       | 仅在匹配分支的推送事件时触发项目 Webhook。 |
| `releases_events`              | boolean           | 否       | 在发布事件时触发项目 Webhook。 |
| `resource_access_token_events` | boolean           | 否       | 在项目访问令牌过期事件时触发项目 Webhook。 |
| `signing_token`                | string            | 否       | 用于计算 `webhook-signature` 请求头的 HMAC 签名令牌。必须为 `whsec_<base64>` 格式，编码一个 32 字节的密钥。不会在响应中返回。 |
| `tag_push_events`              | boolean           | 否       | 在标签推送事件时触发项目 Webhook。 |
| `token`                        | string            | 否       | 用于验证接收到的载荷的密钥令牌。不会在响应中返回。当您更改 Webhook URL 时，密钥令牌会被重置且不会保留。 |
| `wiki_page_events`             | boolean           | 否       | 在 Wiki 页面事件时触发项目 Webhook。 |
| `resource_deploy_token_events` | boolean           | 否       | 在项目部署令牌过期事件时触发项目 Webhook。 |

<a id="delete-project-webhook"></a>

## 删除项目 Webhook

从项目中移除 Webhook。此方法是幂等的，可以多次调用。项目 Webhook 要么存在，要么不存在。

```plaintext
DELETE /projects/:id/hooks/:hook_id
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果项目 Webhook 存在，则会在 JSON 响应中返回。否则，返回空响应。

<a id="trigger-a-test-project-webhook"></a>

## 触发测试项目 Webhook

为指定项目触发测试项目 Webhook。

在极狐GitLab 17.0 及更高版本中，此端点有特殊的速率限制：

- 在极狐GitLab 17.0 中，速率为每个项目 Webhook 每分钟三个请求。
- 在极狐GitLab 17.1 中，此限制更改为每个项目和经过身份验证的用户每分钟五个请求。

在极狐GitLab 私有化部署上，管理员可以[更改此限制](../administration/settings/rate-limit-on-webhook-operations.md)。

```plaintext
POST /projects/:id/hooks/:hook_id/test/:trigger
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `trigger` | string            | 是      | 以下之一：`push_events`、`tag_push_events`、`issues_events`、`confidential_issues_events`、`note_events`、`merge_requests_events`、`job_events`、`pipeline_events`、`wiki_page_events`、`releases_events`、`milestone_events`、`emoji_events`、`resource_access_token_events` 或 `resource_deploy_token_events`。 |

示例响应：

```json
{"message":"201 Created"}
```

<a id="set-a-custom-header"></a>

## 设置自定义请求头

```plaintext
PUT /projects/:id/hooks/:hook_id/custom_headers/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | 自定义请求头的键。 |
| `value`   | string            | 是      | 自定义请求头的值。 |

成功时，此端点返回响应码 `204 No Content`。

<a id="delete-a-custom-header"></a>

## 删除自定义请求头

```plaintext
DELETE /projects/:id/hooks/:hook_id/custom_headers/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | 自定义请求头的键。 |

成功时，此端点返回响应码 `204 No Content`。

<a id="set-a-url-variable"></a>

## 设置 URL 变量

```plaintext
PUT /projects/:id/hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | URL 变量的键。 |
| `value`   | string            | 是      | URL 变量的值。 |

成功时，此端点返回响应码 `204 No Content`。

<a id="delete-a-url-variable"></a>

## 删除 URL 变量

```plaintext
DELETE /projects/:id/hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 Webhook 的 ID。 |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | URL 变量的键。 |

成功时，此端点返回响应码 `204 No Content`。
