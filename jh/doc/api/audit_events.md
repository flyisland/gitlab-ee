---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API to retrieve GitLab audit events for instances, groups, and projects.
title: 审计事件 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 15.9 中，作者邮箱已添加到响应体。

{{< /history >}}

<a id="instance-audit-events"></a>

## 实例审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 检索 [实例审计事件](../administration/compliance/audit_event_reports.md)。

要使用 API 检索审计事件，你必须以管理员身份 [进行身份验证](rest/authentication.md)。

<a id="list-all-instance-audit-events"></a>

### 列出所有实例审计事件

{{< history >}}

- 在 极狐GitLab 15.11 中，引入了对 keyset 分页的支持。
- 在 极狐GitLab 16.2 中，为实例审计事件引入了实体类型 `Gitlab::Audit::InstanceScope`。

{{< /history >}}

列出所有可用的实例审计事件，每次查询最多限制为 30 天。

```plaintext
GET /audit_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- |-----------------------------------------------------------------------------------------------------------------|
| `created_after` | 字符串 | 否 | 返回在给定时间或之后创建的审计事件。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |
| `created_before` | 字符串 | 否 | 返回在给定时间或之前创建的审计事件。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |
| `entity_type` | 字符串 | 否 | 返回给定实体类型的审计事件。有效值为：`User`、`Group`、`Project` 或 `Gitlab::Audit::InstanceScope`。 |
| `entity_id` | 整数 | 否 | 返回给定实体 ID 的审计事件。需要提供 `entity_type` 属性。 |

> [!warning]
> 基于偏移量的分页在 极狐GitLab 17.8 中 [已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/186194)，并计划在 19.0 中移除。请改用 [基于 keyset 的分页](rest/_index.md#keyset-based-pagination)。此更改是一个重大变更。

此端点同时支持基于偏移量和 [基于 keyset 的](rest/_index.md#keyset-based-pagination) 分页。在请求连续的结果页面时，应使用基于 keyset 的分页。

阅读有关 [分页](rest/_index.md#pagination) 的更多信息。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/audit_events"
```

示例响应：

```json
[
  {
    "id": 1,
    "author_id": 1,
    "entity_id": 6,
    "entity_type": "Project",
    "details": {
      "custom_message": "Project archived",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "target_id": "flightjs/flight",
      "target_type": "Project",
      "target_details": "flightjs/flight",
      "ip_address": "127.0.0.1",
      "entity_path": "flightjs/flight"
    },
    "created_at": "2019-08-30T07:00:41.885Z"
  },
  {
    "id": 2,
    "author_id": 1,
    "entity_id": 60,
    "entity_type": "Group",
    "details": {
      "add": "group",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "target_id": "flightjs",
      "target_type": "Group",
      "target_details": "flightjs",
      "ip_address": "127.0.0.1",
      "entity_path": "flightjs"
    },
    "created_at": "2019-08-27T18:36:44.162Z"
  },
  {
    "id": 3,
    "author_id": 51,
    "entity_id": 51,
    "entity_type": "User",
    "details": {
      "change": "email address",
      "from": "hello@flightjs.com",
      "to": "maintainer@flightjs.com",
      "author_name": "Andreas",
      "author_email": "admin@example.com",
      "target_id": 51,
      "target_type": "User",
      "target_details": "Andreas",
      "ip_address": null,
      "entity_path": "Andreas"
    },
    "created_at": "2019-08-22T16:34:25.639Z"
  },
  {
    "id": 4,
    "author_id": 43,
    "entity_id": 1,
    "entity_type": "Gitlab::Audit::InstanceScope",
    "details": {
      "author_name": "Administrator",
      "author_class": "User",
      "target_id": 32,
      "target_type": "AuditEvents::Streaming::InstanceHeader",
      "target_details": "unknown",
      "custom_message": "Created custom HTTP header with key X-arg.",
      "ip_address": "127.0.0.1",
      "entity_path": "gitlab_instance"
    },
    "ip_address": "127.0.0.1",
    "author_name": "Administrator",
    "entity_path": "gitlab_instance",
    "target_details": "unknown",
    "created_at": "2023-08-01T11:29:44.764Z",
    "target_type": "AuditEvents::Streaming::InstanceHeader",
    "target_id": 32,
    "event_type": "audit_events_streaming_instance_headers_create"
  }
]
```

<a id="retrieve-an-instance-audit-event"></a>

### 检索单个实例审计事件

检索指定的实例审计事件。

```plaintext
GET /audit_events/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 审计事件的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/audit_events/1"
```

示例响应：

```json
{
  "id": 1,
  "author_id": 1,
  "entity_id": 6,
  "entity_type": "Project",
  "details": {
    "custom_message": "Project archived",
    "author_name": "Administrator",
    "author_email": "admin@example.com",
    "target_id": "flightjs/flight",
    "target_type": "Project",
    "target_details": "flightjs/flight",
    "ip_address": "127.0.0.1",
    "entity_path": "flightjs/flight"
  },
  "created_at": "2019-08-30T07:00:41.885Z"
}
```

<a id="group-audit-events"></a>

## 群组审计事件

{{< history >}}

- 在 极狐GitLab 15.2 中，引入了对 keyset 分页的支持。

{{< /history >}}

使用此 API 检索 [群组审计事件](../user/compliance/audit_events.md#group-audit-events)。

具有以下角色的用户：
- 所有者角色可以检索所有用户的群组审计事件。
- 开发者或维护者角色仅限于基于其个人操作的群组审计事件。

> [!warning]
> 基于偏移量的分页在 极狐GitLab 17.8 中 [已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/186194)，并计划在 19.0 中移除。请改用 [基于 keyset 的分页](rest/_index.md#keyset-based-pagination)。此更改是一个重大变更。

此端点同时支持基于偏移量和 [基于 keyset 的](rest/_index.md#keyset-based-pagination) 分页。在请求连续的结果页面时，建议使用基于 keyset 的分页。

<a id="list-all-group-audit-events"></a>

### 列出所有群组审计事件

{{< history >}}

- 在 极狐GitLab 15.2 中，引入了对 keyset 分页的支持。

{{< /history >}}

列出指定群组的所有审计事件。

```plaintext
GET /groups/:id/audit_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `created_after` | 字符串 | 否 | 返回在给定时间或之后创建的群组审计事件。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |
| `created_before` | 字符串 | 否 | 返回在给定时间或之前创建的群组审计事件。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果是分页的。

阅读有关 [分页](rest/_index.md#pagination) 的更多信息。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/groups/60/audit_events"
```

示例响应：

```json
[
  {
    "id": 2,
    "author_id": 1,
    "entity_id": 60,
    "entity_type": "Group",
    "details": {
      "custom_message": "Group marked for deletion",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "target_id": "flightjs",
      "target_type": "Group",
      "target_details": "flightjs",
      "ip_address": "127.0.0.1",
      "entity_path": "flightjs"
    },
    "created_at": "2019-08-28T19:36:44.162Z"
  },
  {
    "id": 1,
    "author_id": 1,
    "entity_id": 60,
    "entity_type": "Group",
    "details": {
      "add": "group",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "target_id": "flightjs",
      "target_type": "Group",
      "target_details": "flightjs",
      "ip_address": "127.0.0.1",
      "entity_path": "flightjs"
    },
    "created_at": "2019-08-27T18:36:44.162Z"
  }
]
```

<a id="retrieve-a-group-audit-event"></a>

### 检索单个群组审计事件

检索指定群组的审计事件。仅群组所有者和管理员可用。

```plaintext
GET /groups/:id/audit_events/:audit_event_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `audit_event_id` | 整数 | 是 | 审计事件的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/groups/60/audit_events/2"
```

示例响应：

```json
{
  "id": 2,
  "author_id": 1,
  "entity_id": 60,
  "entity_type": "Group",
  "details": {
    "custom_message": "Group marked for deletion",
    "author_name": "Administrator",
    "author_email": "admin@example.com",
    "target_id": "flightjs",
    "target_type": "Group",
    "target_details": "flightjs",
    "ip_address": "127.0.0.1",
    "entity_path": "flightjs"
  },
  "created_at": "2019-08-28T19:36:44.162Z"
}
```

<a id="project-audit-events"></a>

## 项目审计事件

使用此 API 检索 [项目审计事件](../user/compliance/audit_events.md#project-audit-events)。

具有维护者角色（或更高）的用户可以检索所有用户的项目审计事件。具有开发者角色的用户仅限于基于其个人操作的项目审计事件。

<a id="list-all-project-audit-events"></a>

### 列出所有项目审计事件

{{< history >}}

- 在 极狐GitLab 15.10 中，引入了对 keyset 分页的支持。

{{< /history >}}

列出指定项目的所有审计事件。

```plaintext
GET /projects/:id/audit_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `created_after` | 字符串 | 否 | 返回在给定时间或之后创建的项目审计事件。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |
| `created_before` | 字符串 | 否 | 返回在给定时间或之前创建的项目审计事件。格式：ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) |

> [!warning]
> 基于偏移量的分页在 极狐GitLab 17.8 中 [已弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/186194)，并计划在 19.0 中移除。请改用 [基于 keyset 的分页](rest/_index.md#keyset-based-pagination)。此更改是一个重大变更。

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果是分页的。在请求连续的结果页面时，应使用 [keyset 分页](rest/_index.md#keyset-based-pagination)。

阅读有关 [分页](rest/_index.md#pagination) 的更多信息。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/projects/7/audit_events"
```

示例响应：

```json
[
  {
    "id": 5,
    "author_id": 1,
    "entity_id": 7,
    "entity_type": "Project",
    "details": {
        "change": "prevent merge request approval from committers",
        "from": "",
        "to": "true",
        "author_name": "Administrator",
        "author_email": "admin@example.com",
        "target_id": 7,
        "target_type": "Project",
        "target_details": "twitter/typeahead-js",
        "ip_address": "127.0.0.1",
        "entity_path": "twitter/typeahead-js"
    },
    "created_at": "2020-05-26T22:55:04.230Z"
  },
  {
      "id": 4,
      "author_id": 1,
      "entity_id": 7,
      "entity_type": "Project",
      "details": {
          "change": "prevent merge request approval from authors",
          "from": "false",
          "to": "true",
          "author_name": "Administrator",
          "author_email": "admin@example.com",
          "target_id": 7,
          "target_type": "Project",
          "target_details": "twitter/typeahead-js",
          "ip_address": "127.0.0.1",
          "entity_path": "twitter/typeahead-js"
      },
      "created_at": "2020-05-26T22:55:04.218Z"
  }
]
```

<a id="retrieve-a-project-audit-event"></a>

### 检索单个项目审计事件

检索指定项目的审计事件。仅具有项目的维护者或所有者角色的用户可用。

```plaintext
GET /projects/:id/audit_events/:audit_event_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `audit_event_id` | 整数 | 是 | 审计事件的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/projects/7/audit_events/5"
```

示例响应：

```json
{
  "id": 5,
  "author_id": 1,
  "entity_id": 7,
  "entity_type": "Project",
  "details": {
      "change": "prevent merge request approval from committers",
      "from": "",
      "to": "true",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "target_id": 7,
      "target_type": "Project",
      "target_details": "twitter/typeahead-js",
      "ip_address": "127.0.0.1",
      "entity_path": "twitter/typeahead-js"
  },
  "created_at": "2020-05-26T22:55:04.230Z"
}
```