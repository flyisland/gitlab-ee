---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 webhooks API
description: "使用 REST API 设置和管理群组的 webhooks。"
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[群组 webhooks](../user/project/integrations/webhooks.md#group-webhooks)。群组 webhooks 不同于影响整个实例的[系统钩子](system_hooks.md)，也不同于仅限于单个项目的[项目 webhooks](project_webhooks.md)。

先决条件：

- 您必须是管理员或拥有群组的所有者角色。

<a id="list-all-group-hooks"></a>

## 列出所有群组 webhooks

列出指定群组的所有群组 webhooks。

```plaintext
GET /groups/:id/hooks
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| --------- | --------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks"
```

示例响应：

```json
[
  {
    "id": 1,
    "url": "http://example.com/hook",
    "name": "Test group hook",
    "description": "This is a test group hook.",
    "created_at": "2024-09-01T09:10:54.854Z",
    "push_events": true,
    "tag_push_events": false,
    "merge_requests_events": false,
    "repository_update_events": false,
    "enable_ssl_verification": true,
    "alert_status": "executable",
    "disabled_until": null,
    "url_variables": [],
    "push_events_branch_filter": null,
    "branch_filter_strategy": "all_branches",
    "group_id": 99,
    "issues_events": false,
    "confidential_issues_events": false,
    "note_events": false,
    "confidential_note_events": false,
    "pipeline_events": false,
    "wiki_page_events": false,
    "job_events": false,
    "deployment_events": false,
    "feature_flag_events": false,
    "releases_events": false,
    "milestone_events": false,
    "subgroup_events": false,
    "emoji_events": false,
    "resource_access_token_events": false,
    "member_events": false,
    "project_events": false,
    "custom_webhook_template": "{\"event\":\"{{object_kind}}\"}",
    "custom_headers": [
      {
        "key": "Authorization"
      }
    ],
    "token_present": false,
    "signing_token_present": false
  }
]
```

<a id="retrieve-a-group-hook"></a>

## 获取群组 webhook

{{< history >}}

- `name` 和 `description` 属性在极狐GitLab 17.1 引入。
- `token_present` 和 `signing_token_present` 属性在极狐GitLab 19.0 引入。

{{< /history >}}

获取指定的群组 webhook。

```plaintext
GET /groups/:id/hooks/:hook_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `hook_id` | 整数 | 是 | 群组 webhook 的 ID。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1"
```

示例响应：

```json
{
  "id": 1,
  "url": "http://example.com/hook",
  "name": "Hook name",
  "description": "Hook description",
  "group_id": 3,
  "push_events": true,
  "push_events_branch_filter": "",
  "branch_filter_strategy": "wildcard",
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
  "feature_flag_events": false,
  "releases_events": true,
  "milestone_events": false,
  "subgroup_events": true,
  "member_events": true,
  "project_events": true,
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

<a id="list-all-group-hook-events"></a>

## 列出所有群组 webhook 事件

{{< history >}}

- 在极狐GitLab 17.3 引入。

{{< /history >}}

列出指定群组 webhook 在过去七天内（从开始日期算起）的所有事件。

```plaintext
GET /groups/:id/hooks/:hook_id/events
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|----------- |--------------------- |--------- |------------ |
| `hook_id` | 整数 | 是 | 项目 webhook 的 ID。 |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `page` | 整数 | 否 | 要获取的页码。默认为 `1`。 |
| `per_page` | 整数 | 否 | 每页返回的记录数。默认为 `20`。 |
| `status` | 整数或字符串 | 否 | 事件的响应状态码，例如：`200` 或 `500`。您可以按状态类别搜索：`successful`（200-299）、`client_failure`（400-499）和 `server_failure`（500-599）。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/events"
```

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
      "Idempotency-Key": "a5461c4d-9c7f-4af9-add6-cddebe3c426f",
      "X-Gitlab-Event": "Push Hook",
      "X-Gitlab-Webhook-UUID": "3c5c0404-c866-44bc-a5f6-452bb1bfc76e",
      "X-Gitlab-Instance": "https://gitlab.example.com",
      "X-Gitlab-Event-UUID": "9cebe914-4827-408f-b014-cfa23a47a35f",
      "X-Gitlab-Token": "[REDACTED]"
    },
    "request_data": {
      "object_kind": "push",
      "event_name": "push",
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
      "Idempotency-Key": "1f0a54f0-0529-408d-a5b8-a2a98ff5f94a",
      "X-Gitlab-Event": "Push Hook",
      "X-Gitlab-Webhook-UUID": "a753eedb-1d72-4549-9ca7-eac8ea8e50dd",
      "X-Gitlab-Instance": "https://gitlab.example.com:3000",
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

<a id="resend-group-hook-event"></a>

### 重新发送群组 webhook 事件

{{< history >}}

- 在极狐GitLab 17.4 引入。

{{< /history >}}

重新发送特定的 webhook 事件。

此端点对每个 webhook 和认证用户有每分钟五次的请求速率限制。
要在私有化部署实例上禁用此限制，管理员可以[禁用功能标志](../administration/feature_flags/_index.md)，该功能标志名为 `web_hook_event_resend_api_endpoint_rate_limit`。

```plaintext
POST /groups/:id/hooks/:hook_id/events/:hook_event_id/resend
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|---------------- |------------------ |--------- |------------ |
| `hook_event_id` | 整数 | 是 | webhook 事件的 ID。 |
| `hook_id` | 整数 | 是 | 群组 webhook 的 ID。 |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/events/1/resend"
```

示例响应：

```json
{
  "response_status": 200
}
```

<a id="create-a-group-hook"></a>

## 创建群组 webhook

{{< history >}}

- `name` 和 `description` 属性在极狐GitLab 17.1 引入。
- `signing_token` 属性在极狐GitLab 19.0 引入，使用功能标志 `webhook_signing_token`。默认启用。

{{< /history >}}

> [!flag]
> `signing_token` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。

为指定群组创建群组 webhook。

```plaintext
POST /groups/:id/hooks
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|------------------------------- |------------------ |--------- |------------ |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url` | 字符串 | 是 | webhook URL。 |
| `branch_filter_strategy` | 字符串 | 否 | 按分支过滤推送事件。可能的值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `confidential_issues_events` | 布尔值 | 否 | 在机密议题事件时触发 webhook。 |
| `confidential_note_events` | 布尔值 | 否 | 在机密评论事件时触发 webhook。 |
| `custom_headers` | 数组 | 否 | webhook 的自定义标头。 |
| `custom_webhook_template` | 字符串 | 否 | webhook 的自定义 webhook 模板。 |
| `deployment_events` | 布尔值 | 否 | 在部署事件时触发 webhook。 |
| `description` | 字符串 | 否 | webhook 的描述（在极狐GitLab 17.1 引入）。 |
| `enable_ssl_verification` | 布尔值 | 否 | 触发 webhook 时进行 SSL 验证。 |
| `feature_flag_events` | 布尔值 | 否 | 在功能标志事件时触发 webhook。 |
| `issues_events` | 布尔值 | 否 | 在议题事件时触发 webhook。 |
| `job_events` | 布尔值 | 否 | 在作业事件时触发 webhook。 |
| `member_events` | 布尔值 | 否 | 在成员事件时触发 webhook。 |
| `merge_requests_events` | 布尔值 | 否 | 在合并请求事件时触发 webhook。 |
| `milestone_events` | 布尔值 | 否 | 在里程碑事件时触发 webhook。 |
| `name` | 字符串 | 否 | webhook 的名称（在极狐GitLab 17.1 引入）。 |
| `note_events` | 布尔值 | 否 | 在评论事件时触发 webhook。 |
| `pipeline_events` | 布尔值 | 否 | 在流水线事件时触发 webhook。 |
| `project_events` | 布尔值 | 否 | 在项目事件时触发 webhook。 |
| `push_events` | 布尔值 | 否 | 在推送事件时触发 webhook。 |
| `push_events_branch_filter` | 字符串 | 否 | 仅当匹配分支时触发推送事件的 webhook。 |
| `releases_events` | 布尔值 | 否 | 在发布事件时触发 webhook。 |
| `resource_access_token_events` | 布尔值 | 否 | 在项目访问令牌过期事件时触发 webhook。 |
| `signing_token` | 字符串 | 否 | 用于计算 `webhook-signature` 标头的 HMAC 签名令牌。必须为 `whsec_<base64>` 格式，编码 32 字节密钥。响应中不返回。 |
| `subgroup_events` | 布尔值 | 否 | 在子群组事件时触发 webhook。 |
| `tag_push_events` | 布尔值 | 否 | 在标签推送事件时触发 webhook。 |
| `token` | 字符串 | 否 | 用于验证接收到的有效载荷的密钥令牌。响应中不返回。 |
| `wiki_page_events` | 布尔值 | 否 | 在 Wiki 页面事件时触发 webhook。 |

示例请求：

```shell
curl --request POST \
  --header "content-type: application/json" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks" \
  --data '{"url": "https://example.com/hook", "name": "My Hook", "description": "Hook description"}'
```

示例响应：

```json
{
  "id": 42,
  "url": "https://example.com/hook",
  "name": "My Hook",
  "description": "Hook description",
  "group_id": 3,
  "push_events": true,
  "push_events_branch_filter": "",
  "branch_filter_strategy": "wildcard",
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
  "feature_flag_events": true,
  "releases_events": true,
  "milestone_events": true,
  "subgroup_events": true,
  "member_events": true,
  "project_events": true,
  "enable_ssl_verification": true,
  "repository_update_events": false,
  "alert_status": "executable",
  "disabled_until": null,
  "url_variables": [ ],
  "created_at": "2012-10-12T17:04:47Z",
  "resource_access_token_events": true,
  "custom_webhook_template": "{\"event\":\"{{object_kind}}\"}",
  "token_present": false,
  "signing_token_present": false
}
```

<a id="update-a-group-hook"></a>

## 更新群组 webhook

{{< history >}}

- `name` 和 `description` 属性在极狐GitLab 17.1 引入。
- `signing_token` 属性在极狐GitLab 19.0 引入，使用功能标志 `webhook_signing_token`。默认启用。

{{< /history >}}

> [!flag]
> `signing_token` 属性的可用性由功能标志控制。
> 更多信息，请参见历史记录。

更新指定群组的群组 webhook。

```plaintext
PUT /groups/:id/hooks/:hook_id
```

支持的属性：
<a id="edit-a-group-hook"></a>

## 编辑群组钩子

修改指定的群组钩子。

```plaintext
PUT /groups/:id/hooks/:hook_id
```

支持属性：

| 属性                                          | 类型              | 是否必需 | 描述 |
|---------------------------------------------- |------------------ |--------- |------------ |
| `hook_id`                                     | 整数              | 是       | 群组钩子的 ID。 |
| `id`                                          | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `url`                                         | 字符串            | 是       | 钩子 URL。 |
| `branch_filter_strategy`                      | 字符串            | 否       | 按分支过滤推送事件。可选值为 `wildcard`（默认）、`regex` 和 `all_branches`。 |
| `confidential_issues_events`                  | 布尔值            | 否       | 在机密议题事件上触发钩子。 |
| `confidential_note_events`                    | 布尔值            | 否       | 在机密评论事件上触发钩子。 |
| `custom_headers`                              | 数组              | 否       | 钩子的自定义标头。 |
| `custom_webhook_template`                     | 字符串            | 否       | 钩子的自定义 Webhook 模板。 |
| `deployment_events`                           | 布尔值            | 否       | 在部署事件上触发钩子。 |
| `description`                                 | 字符串            | 否       | 钩子的描述。 |
| `enable_ssl_verification`                     | 布尔值            | 否       | 触发钩子时进行 SSL 验证。 |
| `feature_flag_events`                         | 布尔值            | 否       | 在功能标志事件上触发钩子。 |
| `issues_events`                               | 布尔值            | 否       | 在议题事件上触发钩子。 |
| `job_events`                                  | 布尔值            | 否       | 在作业事件上触发钩子。 |
| `member_events`                               | 布尔值            | 否       | 在成员事件上触发钩子。 |
| `merge_requests_events`                       | 布尔值            | 否       | 在合并请求事件上触发钩子。 |
| `milestone_events`                            | 布尔值            | 否       | 在里程碑事件上触发钩子。 |
| `name`                                        | 字符串            | 否       | 钩子的名称。 |
| `note_events`                                 | 布尔值            | 否       | 在评论事件上触发钩子。 |
| `pipeline_events`                             | 布尔值            | 否       | 在流水线事件上触发钩子。 |
| `project_events`                              | 布尔值            | 否       | 在项目事件上触发钩子。 |
| `push_events`                                 | 布尔值            | 否       | 在推送事件上触发钩子。 |
| `push_events_branch_filter`                   | 字符串            | 否       | 仅在匹配的分支上触发推送事件钩子。 |
| `releases_events`                             | 布尔值            | 否       | 在发布事件上触发钩子。 |
| `resource_access_token_events`                | 布尔值            | 否       | 在项目访问令牌过期事件上触发钩子。 |
| `service_access_tokens_expiration_enforced`   | 布尔值            | 否       | 要求服务账户访问令牌具有过期日期。 |
| `signing_token`                               | 字符串            | 否       | 用于计算 `webhook-signature` 标头的 HMAC 签名令牌。格式必须为 `whsec_<base64>`，编码一个 32 字节的密钥。响应中不返回。 |
| `subgroup_events`                             | 布尔值            | 否       | 在子群组事件上触发钩子。 |
| `tag_push_events`                             | 布尔值            | 否       | 在标签推送事件上触发钩子。 |
| `token`                                       | 字符串            | 否       | 用于验证接收到的有效载荷的密钥令牌。响应中不返回。更改 webhook URL 时，密钥令牌会重置且不会保留。 |
| `wiki_page_events`                            | 布尔值            | 否       | 在 Wiki 页面事件上触发钩子。 |

示例请求：

```shell
curl --request POST \
  --header "content-type: application/json" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1" \
  --data '{"url": "https://example.com/hook", "name": "New hook name", "description": "Changed hook description"}'
```

示例响应：

```json
{
  "id": 1,
  "url": "https://example.com/hook",
  "name": "New hook name",
  "description": "Changed hook description",
  "group_id": 3,
  "push_events": true,
  "push_events_branch_filter": "",
  "branch_filter_strategy": "wildcard",
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
  "feature_flag_events": true,
  "releases_events": true,
  "milestone_events": true,
  "subgroup_events": true,
  "member_events": true,
  "project_events": true,
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

<a id="delete-a-group-hook"></a>

## 删除群组钩子

删除指定的群组钩子。这是一个幂等方法，可以多次调用。无论钩子是否可用。

```plaintext
DELETE /groups/:id/hooks/:hook_id
```

支持属性：

| 属性      | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `hook_id` | 整数              | 是       | 群组钩子的 ID。 |
| `id`      | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1"
```

成功后，不返回任何消息。

<a id="trigger-a-test-group-hook"></a>

## 触发测试群组钩子

{{< history >}}

- 在 极狐GitLab 17.1 引入。
- 在 极狐GitLab 17.1 中，特殊的速率限制被引入，并带有一个名为 `web_hook_test_api_endpoint_rate_limit` 的[功能标志](../administration/feature_flags/_index.md)。默认启用。

{{< /history >}}

为指定群组触发测试钩子。

此端点对每个群组和已认证用户的速率限制为每分钟五个请求。
对于私有化部署实例，管理员可以通过
[禁用功能标志](../administration/feature_flags/_index.md) 来关闭此限制，该功能标志名为 `web_hook_test_api_endpoint_rate_limit`。

```plaintext
POST /groups/:id/hooks/:hook_id/test/:trigger
```

| 属性      | 类型              | 是否必需 | 描述 |
|---------- |------------------ |--------- |------------ |
| `hook_id` | 整数              | 是       | 群组钩子的 ID。 |
| `id`      | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `trigger` | 字符串            | 是       | 取值为 `push_events`、`tag_push_events`、`issues_events`、`confidential_issues_events`、`note_events`、`merge_requests_events`、`job_events`、`pipeline_events`、`wiki_page_events`、`releases_events`、`milestone_events`、`emoji_events` 或 `resource_access_token_events` 之一。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/test/push_events"
```

示例响应：

```json
{"message":"201 Created"}
```

<a id="update-a-custom-header"></a>

## 更新自定义标头

{{< history >}}

- 在 极狐GitLab 17.1 引入。

{{< /history >}}

更新指定群组钩子的自定义标头。

```plaintext
PUT /groups/:id/hooks/:hook_id/custom_headers/:key
```

支持属性：

| 属性      | 类型              | 是否必需 | 描述 |
|---------- |------------------ |--------- |------------ |
| `hook_id` | 整数              | 是       | 群组钩子的 ID。 |
| `id`      | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | 字符串            | 是       | 自定义标头的键。 |
| `value`   | 字符串            | 是       | 自定义标头的值。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/custom_headers/header_key?value='header_value'"
```

成功后，不返回任何消息。

<a id="delete-a-custom-header"></a>

## 删除自定义标头

{{< history >}}

- 在 极狐GitLab 17.1 引入。

{{< /history >}}

删除自定义标头。

```plaintext
DELETE /groups/:id/hooks/:hook_id/custom_headers/:key
```

支持属性：

| 属性      | 类型              | 是否必需 | 描述 |
|---------- |------------------ |--------- |------------ |
| `hook_id` | 整数              | 是       | 群组钩子的 ID。 |
| `id`      | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | 字符串            | 是       | 自定义标头的键。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/custom_headers/header_key"
```

成功后，不返回任何消息。

<a id="update-a-url-variable"></a>

## 更新 URL 变量

{{< history >}}

- 在 极狐GitLab 15.2 引入。

{{< /history >}}

更新指定群组钩子的 URL 变量。

```plaintext
PUT /groups/:id/hooks/:hook_id/url_variables/:key
```

支持属性：

| 属性      | 类型              | 是否必需 | 描述 |
|---------- |------------------ |--------- |------------ |
| `hook_id` | 整数              | 是       | 群组钩子的 ID。 |
| `id`      | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | 字符串            | 是       | URL 变量的键。 |
| `value`   | 字符串            | 是       | URL 变量的值。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/url_variables/my_key?value='my_key_value'"
```

成功后，不返回任何消息。

<a id="delete-a-url-variable"></a>

## 删除 URL 变量

删除指定群组钩子的 URL 变量。

```plaintext
DELETE /groups/:id/hooks/:hook_id/url_variables/:key
```

支持属性：

| 属性      | 类型              | 是否必需 | 描述 |
|---------- |------------------ |--------- |------------ |
| `hook_id` | 整数              | 是       | 群组钩子的 ID。 |
| `id`      | 整数或字符串      | 是       | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `key`     | 字符串            | 是       | URL 变量的键。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/hooks/1/url_variables/my_key"
```

成功后，不返回任何消息。