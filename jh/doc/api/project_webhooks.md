---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目 Webhook API
description: "Set up and manage webhooks for a project with the REST API."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来管理 [项目 Webhooks](../user/project/integrations/webhooks.md)。项目 Webhooks 不同于影响整个实例的 [系统钩子](system_hooks.md)，以及影响群组中所有项目和子群组的 [群组 Webhooks](group_webhooks.md)。

先决条件：

- 你必须是管理员或具有该项目的维护者或所有者角色。

<a id="list-webhooks-for-a-project"></a>

## 列出项目 Webhooks

获取项目 Webhooks 列表。

```plaintext
GET /projects/:id/hooks
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

<a id="retrieve-a-project-webhook"></a>

## 获取项目 Webhook

{{< history >}}

- 在极狐GitLab 17.1 中引入了 `name` 和 `description` 属性。
- 在极狐GitLab 19.0 中引入了 `token_present` 和 `signing_token_present` 属性。

{{< /history >}}

获取指定项目的特定 Webhook。

```plaintext
GET /projects/:id/hooks/:hook_id
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | 整数           | 是      | 项目 Webhook 的 ID。 |
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

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

{{< history >}}

- 在极狐GitLab 17.3 中引入。

{{< /history >}}

列出指定项目 Webhook 从开始日期起过去 7 天内的所有事件。

```plaintext
GET /projects/:id/hooks/:hook_id/events
```

支持的属性：

| 属性  | 类型              | 是否必需 | 描述 |
|:-----------|:------------------|:---------|:------------|
| `hook_id`  | 整数           | 是      | 项目 Webhook 的 ID。 |
| `id`       | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `status`   | 整数或字符串 | 否       | 事件的响应状态码，例如：`200` 或 `500`。你可按状态类别搜索：`successful` (200-299)，`client_failure` (400-499)，以及 `server_failure` (500-599)。 |
| `page`     | 整数           | 否       | 要获取的页码。默认为 `1`。 |
| `per_page` | 整数           | 否       | 每页返回的记录数。默认为 `20`。 |

示例响应：

```json
[
  {
    "id": 1,
    "url": "https://example.net/",
    "trigger": "push_hooks",
    "request_headers": {
      "Content-Type": "application/json",
      "User-Agent": "极狐GitLab/17.1.0-pre",
      "Idempotency-Key": "3a427872-00df-429c-9bc9-a9475de2efe4",
      "X-极狐GitLab-Event": "Push Hook",
      "X-极狐GitLab-Webhook-UUID": "3c5c0404-c866-44bc-a5f6-452bb1bfc76e",
      "X-极狐GitLab-Instance": "https://gitlab.example.com",
      "X-极狐GitLab-Event-UUID": "9cebe914-4827-408f-b014-cfa23a47a35f",
      "X-极狐GitLab-Token": "[REDACTED]"
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
      "User-Agent": "极狐GitLab/17.1.0-pre",
      "Idempotency-Key": "7c6e0583-49f2-4dc5-a50b-4c0bcf3c1b27",
      "X-极狐GitLab-Event": "Push Hook",
      "X-极狐GitLab-Webhook-UUID": "a753eedb-1d72-4549-9ca7-eac8ea8e50dd",
      "X-极狐GitLab-Instance": "https://gitlab.example.com",
      "X-极狐GitLab-Event-UUID": "842d7c3e-3114-4396-8a95-66c084d53cb1",
      "X-极狐GitLab-Token": "[REDACTED]"
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
        "visibility_level": 10"
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

## 重发项目 Webhook 事件

{{< history >}}

- 在极狐GitLab 17.4 中引入。

{{< /history >}}

重发一个特定的项目 Webhook 事件。

此端点有速率限制：每个项目 Webhook 和已认证用户每分钟五个请求。要在私有化部署中禁用此限制，管理员可以 [禁用功能标志](../administration/feature_flags/_index.md) 名为 `web_hook_event_resend_api_endpoint_rate_limit`。

```plaintext
POST /projects/:id/hooks/:hook_id/events/:hook_event_id/resend
```

支持的属性：

| 属性       | 类型    | 是否必需 | 描述 |
|:----------------|:--------|:---------|:------------|
| `hook_event_id` | 整数 | 是      | 项目 Webhook 事件的 ID。 |
| `hook_id`       | 整数 | 是      | 项目 Webhook 的 ID。 |

示例响应：

```json
{
  "response_status": 200
}
```

<a id="add-a-webhook-to-a-project"></a>

## 向项目添加 Webhook

{{< history >}}

- 在极狐GitLab 17.1 中引入了 `name` 和 `description` 属性。
- 在极狐GitLab 19.0 中引入了 `signing_token` 属性，[以功能标志](../administration/feature_flags/_index.md) 命名为 `webhook_signing_token`。默认启用。

{{< /history >}}

> [!flag]
> `signing_token` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。

向指定项目添加一个 Webhook。

```plaintext
POST /projects/:id/hooks
```

支持的属性：

| 属性                      | 类型              | 是否必需 | 描述 |
|:-------------------------------|:------------------|:---------|:------------|
| `id`                           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url`                          | 字符串            | 是      | 项目 Webhook URL。 |
| `branch_filter_strategy`       | 字符串            | 否       | 按分支过滤推送事件。可选值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `confidential_issues_events`   | 布尔           | 否       | 触动机密议题事件的项目 Webhook。 |
| `confidential_note_events`     | 布尔           | 否       | 触动机密评论事件的项目 Webhook。 |
| `custom_headers`               | 数组             | 否       | 项目 Webhook 的自定义头。 |
| `custom_webhook_template`      | 字符串            | 否       | 项目 Webhook 的自定义模板。 |
| `deployment_events`            | 布尔           | 否       | 触发部署事件的项目 Webhook。 |
| `description`                  | 字符串            | 否       | Webhook 的描述。 |
| `enable_ssl_verification`      | 布尔           | 否       | 触发 Webhook 时进行 SSL 验证。 |
| `feature_flag_events`          | 布尔           | 否       | 触发功能标志事件的项目 Webhook。 |
| `issues_events`                | 布尔           | 否       | 触发议题事件的项目 Webhook。 |
| `job_events`                   | 布尔           | 否       | 触发任务事件的项目 Webhook。 |
| `merge_requests_events`        | 布尔           | 否       | 触发合并请求事件的项目 Webhook。 |
| `milestone_events`             | 布尔           | 否       | 触发里程碑事件的项目 Webhook。 |
| `name`                         | 字符串            | 否       | 项目 Webhook 的名称。 |
| `note_events`                  | 布尔           | 否       | 触发评论事件的项目 Webhook。 |
| `pipeline_events`              | 布尔           | 否       | 触发流水线事件的项目 Webhook。 |
| `push_events`                  | 布尔           | 否       | 触发推送事件的项目 Webhook。 |
| `push_events_branch_filter`    | 字符串            | 否       | 仅为匹配的分支触发推送事件的项目 Webhook。 |
| `releases_events`              | 布尔           | 否       | 触发发布事件的项目 Webhook。 |
| `resource_access_token_events` | 布尔           | 否       | 触发项目访问令牌过期事件的项目 Webhook。 |
| `signing_token`                | 字符串            | 否       | 用于计算 `webhook-signature` 头的 HMAC 签名令牌。必须采用 `whsec_<base64>` 格式，编码 32 字节密钥。不在响应中返回。 |
| `tag_push_events`              | 布尔           | 否       | 触发标签推送事件的项目 Webhook。 |
| `token`                        | 字符串            | 否       | 用于验证接收到的有效载荷的密钥令牌。不在响应中返回。 |
| `wiki_page_events`             | 布尔           | 否       | 触发 Wiki 事件的项目 Webhook。 |
| `resource_deploy_token_events` | 布尔           | 否       | 触发项目部署令牌过期事件的项目 Webhook。 |

<a id="update-a-project-webhook"></a>

## 更新项目 Webhook

{{< history >}}

- 在极狐GitLab 17.1 中引入了 `name` 和 `description` 属性。
- 在极狐GitLab 19.0 中引入了 `signing_token` 属性，[以功能标志](../administration/feature_flags/_index.md) 命名为 `webhook_signing_token`。默认启用。

{{< /history >}}

> [!flag]
> `signing_token` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。

更新指定项目的项目 Webhook。

```plaintext
PUT /projects/:id/hooks/:hook_id
```

支持的属性：

| 属性                      | 类型              | 是否必需 | 描述 |
|:-------------------------------|:------------------|:---------|:------------|
| `hook_id`                      | 整数           | 是      | 项目 Webhook 的 ID。 |
| `id`                           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url`                          | 字符串            | 是      | 项目 Webhook URL。 |
| `branch_filter_strategy`       | 字符串            | 否       | 按分支过滤推送事件。可选值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `custom_headers`               | 数组             | 否       | 项目 Webhook 的自定义头。 |
| `custom_webhook_template`      | 字符串            | 否       | 项目 Webhook 的自定义模板。 |
| `description`                  | 字符串            | 否       | 项目 Webhook 的描述。 |
| `confidential_issues_events`   | 布尔           | 否       | 触动机密议题事件的项目 Webhook。 |
| `confidential_note_events`     | 布尔           | 否       | 触动机密评论事件的项目 Webhook。 |
| `deployment_events`            | 布尔           | 否       | 触发部署事件的项目 Webhook。 |
| `enable_ssl_verification`      | 布尔           | 否       | 触发钩子时进行 SSL 验证。 |
| `feature_flag_events`          | 布尔           | 否       | 触发功能标志事件的项目 Webhook。 |
| `issues_events`                | 布尔           | 否       | 触发议题事件的项目 Webhook。 |
| `job_events`                   | 布尔           | 否       | 触发任务事件的项目 Webhook。 |
| `merge_requests_events`        | 布尔           | 否       | 触发合并请求事件的项目 Webhook。 |
| `milestone_events`             | 布尔           | 否       | 触发里程碑事件的项目 Webhook。 |
| `name`                         | 字符串            | 否       | 项目 Webhook 的名称。 |
| `note_events`                  | 布尔           | 否       | 触发评论事件的项目 Webhook。 |
| `pipeline_events`              | 布尔           | 否       | 触发流水线事件的项目 Webhook。 |
| `push_events`                  | 布尔           | 否       | 触发推送事件的项目 Webhook。 |
| `push_events_branch_filter`    | 字符串            | 否       | 仅为匹配的分支触发推送事件的项目 Webhook。 |
| `releases_events`              | 布尔           | 否       | 触发发布事件的项目 Webhook。 |
| `resource_access_token_events` | 布尔           | 否       | 触发项目访问令牌过期事件的项目 Webhook。 |
| `signing_token`                | 字符串            | 否       | 用于计算 `webhook-signature` 头的 HMAC 签名令牌。必须采用 `whsec_<base64>` 格式，编码 32 字节密钥。不在响应中返回。 |
| `tag_push_events`              | 布尔           | 否       | 触发标签推送事件的项目 Webhook。 |
| `token`                        | 字符串            | 否       | 用于验证接收到的有效载荷的密钥令牌。不在响应中返回。当你更改 Webhook URL 时，密钥令牌会被重置且不会保留。 |
| `wiki_page_events`             | 布尔           | 否       | 触发 Wiki 页面事件的项目 Webhook。 |
| `resource_deploy_token_events` | 布尔           | 否       | 触发项目部署令牌过期事件的项目 Webhook。 |

<a id="delete-project-webhook"></a>

## 删除项目 Webhook

从项目中移除一个 Webhook。此方法是幂等的，可以多次调用。项目 Webhook 要么可用，要么不可用。

```plaintext
DELETE /projects/:id/hooks/:hook_id
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | 整数           | 是      | 项目 Webhook 的 ID。 |
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

注意，JSON 响应会因项目 Webhook 是否可用而异。如果项目 Webhook 在返回前可用，则返回 JSON 响应，否则返回空响应。

<a id="trigger-a-test-project-webhook"></a>

## 触发测试项目 Webhook

{{< history >}}

- 在极狐GitLab 16.11 中引入。
- 在极狐GitLab 17.0 中引入了特殊速率限制，[以功能标志](../administration/feature_flags/_index.md) 命名为 `web_hook_test_api_endpoint_rate_limit`。默认启用。

{{< /history >}}

为指定项目触发一个测试项目 Webhook。

在极狐GitLab 17.0 及更高版本中，此端点有特殊速率限制：

- 在极狐GitLab 17.0 中，速率为每个项目 Webhook 每分钟三个请求。
- 在极狐GitLab 17.1 中，此限制更改为每个项目和已认证用户每分钟五个请求。

要在私有化部署中禁用此限制，管理员可以 [禁用功能标志](../administration/feature_flags/_index.md) 名为 `web_hook_test_api_endpoint_rate_limit`。

```plaintext
POST /projects/:id/hooks/:hook_id/test/:trigger
```

支持的属性：
| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 webhook 的 ID。 |
| `id`      | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `trigger` | string            | 是      | 值为以下之一：`push_events`、`tag_push_events`、`issues_events`、`confidential_issues_events`、`note_events`、`merge_requests_events`、`job_events`、`pipeline_events`、`wiki_page_events`、`releases_events`、`milestone_events`、`emoji_events`、`resource_access_token_events` 或 `resource_deploy_token_events`。 |

示例响应：

```json
{"message":"201 Created"}
```

## 设置自定义头部

<a id="set-a-custom-header"></a>

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

```plaintext
PUT /projects/:id/hooks/:hook_id/custom_headers/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 webhook 的 ID。 |
| `id`      | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | 自定义头部的键。 |
| `value`   | string            | 是      | 自定义头部的值。 |

成功时，此端点返回响应代码 `204 No Content`。

## 删除自定义头部

<a id="delete-a-custom-header"></a>

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

```plaintext
DELETE /projects/:id/hooks/:hook_id/custom_headers/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 webhook 的 ID。 |
| `id`      | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | 自定义头部的键。 |

成功时，此端点返回响应代码 `204 No Content`。

## 设置 URL 变量

<a id="set-a-url-variable"></a>

```plaintext
PUT /projects/:id/hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 webhook 的 ID。 |
| `id`      | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | URL 变量的键。 |
| `value`   | string            | 是      | URL 变量的值。 |

成功时，此端点返回响应代码 `204 No Content`。

## 删除 URL 变量

<a id="delete-a-url-variable"></a>

```plaintext
DELETE /projects/:id/hooks/:hook_id/url_variables/:key
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|:----------|:------------------|:---------|:------------|
| `hook_id` | integer           | 是      | 项目 webhook 的 ID。 |
| `id`      | integer 或 string | 是      | ID 或 [项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | string            | 是      | URL 变量的键。 |

成功时，此端点返回响应代码 `204 No Content`。

