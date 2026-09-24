---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 资源里程碑事件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com， 私有化部署

{{< /details >}}

使用此 API 与议题和合并请求的里程碑事件进行交互。

<a id="issues"></a>

## 议题

<a id="list-project-issue-milestone-events"></a>

### 列出项目议题里程碑事件

列出单个议题的所有里程碑事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_milestone_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`        | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数 | 是 | 议题的 IID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_milestone_events"
```

示例响应：

```json
[
  {
    "id": 142,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-20T13:38:20.077Z",
    "resource_type": "Issue",
    "resource_id": 253,
    "milestone":   {
      "id": 61,
      "iid": 9,
      "project_id": 7,
      "title": "v1.2",
      "description": "Ipsum Lorem",
      "state": "active",
      "created_at": "2020-01-27T05:07:12.573Z",
      "updated_at": "2020-01-27T05:07:12.573Z",
      "due_date": null,
      "start_date": null,
      "web_url": "http://gitlab.example.com:3000/group/project/-/milestones/9"
    },
    "action": "add"
  },
  {
    "id": 143,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-21T14:38:20.077Z",
    "resource_type": "Issue",
    "resource_id": 253,
    "milestone":   {
      "id": 61,
      "iid": 9,
      "project_id": 7,
      "title": "v1.2",
      "description": "Ipsum Lorem",
      "state": "active",
      "created_at": "2020-01-27T05:07:12.573Z",
      "updated_at": "2020-01-27T05:07:12.573Z",
      "due_date": null,
      "start_date": null,
      "web_url": "http://gitlab.example.com:3000/group/project/-/milestones/9"
    },
    "action": "remove"
  }
]
```

<a id="retrieve-a-single-issue-milestone-event"></a>

### 获取单个议题里程碑事件

获取特定项目议题的单个里程碑事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_milestone_events/:resource_milestone_event_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`                          | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid`                   | 整数 | 是 | 议题的 IID |
| `resource_milestone_event_id` | 整数 | 是 | 里程碑事件的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_milestone_events/1"
```

<a id="merge-requests"></a>

## 合并请求

<a id="list-project-merge-request-milestone-events"></a>

### 列出项目合并请求里程碑事件

列出单个合并请求的所有里程碑事件。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/resource_milestone_events
```

| 属性 | 类型 | 是否必需 | 描述 |
| ------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`                | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数 | 是 | 合并请求的 IID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/resource_milestone_events"
```

示例响应：

```json
[
  {
    "id": 142,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-20T13:38:20.077Z",
    "resource_type": "MergeRequest",
    "resource_id": 142,
    "milestone":   {
      "id": 61,
      "iid": 9,
      "project_id": 7,
      "title": "v1.2",
      "description": "Ipsum Lorem",
      "state": "active",
      "created_at": "2020-01-27T05:07:12.573Z",
      "updated_at": "2020-01-27T05:07:12.573Z",
      "due_date": null,
      "start_date": null,
      "web_url": "http://gitlab.example.com:3000/group/project/-/milestones/9"
    },
    "action": "add"
  },
  {
    "id": 143,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-21T14:38:20.077Z",
    "resource_type": "MergeRequest",
    "resource_id": 142,
    "milestone":   {
      "id": 61,
      "iid": 9,
      "project_id": 7,
      "title": "v1.2",
      "description": "Ipsum Lorem",
      "state": "active",
      "created_at": "2020-01-27T05:07:12.573Z",
      "updated_at": "2020-01-27T05:07:12.573Z",
      "due_date": null,
      "start_date": null,
      "web_url": "http://gitlab.example.com:3000/group/project/-/milestones/9"
    },
    "action": "remove"
  }
]
```

<a id="retrieve-a-single-merge-request-milestone-event"></a>

### 获取单个合并请求里程碑事件

获取特定项目合并请求的单个里程碑事件。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/resource_milestone_events/:resource_milestone_event_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`                          | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid`           | 整数 | 是 | 合并请求的 IID |
| `resource_milestone_event_id` | 整数 | 是 | 里程碑事件的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/resource_milestone_events/120"
```

