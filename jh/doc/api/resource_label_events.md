---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API，用于检索议题、合并请求和史诗的标记变更事件。
title: 资源标记事件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可检索资源标记事件，这些事件记录了谁在何时为议题、合并请求或史诗添加（或移除）了哪个[标记](../user/project/labels.md)。

<a id="issues"></a>

## 议题

<a id="list-project-issue-label-events"></a>

### 列出项目议题标记事件

列出单个议题的所有标记事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_label_events
```

| 属性           | 类型             | 是否必需   | 描述  |
| ------------------- | ---------------- | ---------- | ------------ |
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid`         | integer          | 是        | 议题的 IID |

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
    "label": {
      "id": 73,
      "name": "a1",
      "color": "#34495E",
      "description": ""
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
    "created_at": "2018-08-20T13:38:20.077Z",
    "resource_type": "Issue",
    "resource_id": 253,
    "label": {
      "id": 74,
      "name": "p1",
      "color": "#0033CC",
      "description": ""
    },
    "action": "remove"
  }
]
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_label_events"
```

<a id="retrieve-a-single-issue-label-event"></a>

### 检索单个议题标记事件

检索特定项目议题的单个标记事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_label_events/:resource_label_event_id
```

参数：

| 属性       | 类型           | 是否必需 | 描述 |
| --------------- | -------------- | -------- | ----------- |
| `id`            | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid`     | integer        | 是      | 议题的 IID |
| `resource_label_event_id` | integer        | 是      | 标记事件的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_label_events/1"
```

<a id="epics"></a>

## 史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 史诗 REST API 已在极狐GitLab 17.0 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/460668)，
> 并计划在 API v5 中移除。
> 从极狐GitLab 17.4 到 18.0，如果启用了[史诗的新外观](../user/group/epics/_index.md#epics-as-work-items)，以及在极狐GitLab 18.1 及更高版本中，请改用
> 工作项 API。更多信息，请参阅[将史诗 API 迁移到工作项](graphql/epic_work_items_api_migration_guide.md)。
> 此变更是一项破坏性变更。

<a id="list-group-epic-label-events"></a>

### 列出群组史诗标记事件

列出单个史诗的所有标记事件。

```plaintext
GET /groups/:id/epics/:epic_id/resource_label_events
```

| 属性           | 类型             | 是否必需   | 描述  |
| ------------------- | ---------------- | ---------- | ------------ |
| `id`                | integer or string   | 是        | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `epic_id`           | integer          | 是        | 史诗的 ID |

```json
[
  {
    "id": 106,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-19T11:43:01.746Z",
    "resource_type": "Epic",
    "resource_id": 33,
    "label": {
      "id": 73,
      "name": "a1",
      "color": "#34495E",
      "description": ""
    },
    "action": "add"
  },
  {
    "id": 107,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-19T11:43:01.746Z",
    "resource_type": "Epic",
    "resource_id": 33,
    "label": {
      "id": 37,
      "name": "glabel2",
      "color": "#A8D695",
      "description": ""
    },
    "action": "add"
  }
]
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/11/resource_label_events"
```

<a id="retrieve-a-single-epic-label-event"></a>

### 检索单个史诗标记事件

检索特定群组史诗的单个标记事件。

```plaintext
GET /groups/:id/epics/:epic_id/resource_label_events/:resource_label_event_id
```

参数：

| 属性       | 类型           | 是否必需 | 描述 |
| --------------- | -------------- | -------- | ----------- |
| `id`            | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `epic_id`       | integer        | 是      | 史诗的 ID |
| `resource_label_event_id` | integer        | 是      | 标记事件的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/epics/11/resource_label_events/107"
```

<a id="merge-requests"></a>

## 合并请求

<a id="list-project-merge-request-label-events"></a>

### 列出项目合并请求标记事件

列出单个合并请求的所有标记事件。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/resource_label_events
```

| 属性           | 类型             | 是否必需   | 描述  |
| ------------------- | ---------------- | ---------- | ------------ |
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | integer          | 是        | 合并请求的 IID |

```json
[
  {
    "id": 119,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-20T06:17:28.394Z",
    "resource_type": "MergeRequest",
    "resource_id": 28,
    "label": {
      "id": 74,
      "name": "p1",
      "color": "#0033CC",
      "description": ""
    },
    "action": "add"
  },
  {
    "id": 120,
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.example.com/root"
    },
    "created_at": "2018-08-20T06:17:28.394Z",
    "resource_type": "MergeRequest",
    "resource_id": 28,
    "label": {
      "id": 41,
      "name": "project",
      "color": "#D1D100",
      "description": ""
    },
    "action": "add"
  }
]
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/resource_label_events"
```

<a id="retrieve-a-single-merge-request-label-event"></a>

### 检索单个合并请求标记事件

检索特定项目合并请求的单个标记事件。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/resource_label_events/:resource_label_event_id
```

参数：

| 属性           | 类型           | 是否必需 | 描述 |
| ------------------- | -------------- | -------- | ----------- |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | integer        | 是      | 合并请求的 IID |
| `resource_label_event_id`     | integer        | 是      | 标记事件的 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/resource_label_events/120"
```
