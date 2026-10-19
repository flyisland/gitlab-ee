---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 资源状态事件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可与议题、合并请求和史诗的状态变更事件交互。

此 API 不跟踪资源的初始状态（“创建”或“打开”）。对于未被关闭或重新打开的资源，将返回空列表。

<a id="issues"></a>

## 议题

<a id="list-project-issue-state-events"></a>

### 列出项目议题状态事件

列出单个议题的所有状态事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_state_events
```

| 属性   | 类型           | 是否必需 | 描述                                                                     |
| ----------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`        | integer or string | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | integer        | 是      | 议题的 IID                                                             |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_state_events"
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
    "resource_id": 11,
    "source_commit": null,
    "source_merge_request_id": null,
    "state": "opened"
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
    "resource_id": 11,
    "source_commit": null,
    "source_merge_request_id": null,
    "state": "closed"
  }
]
```

<a id="retrieve-a-single-issue-state-event"></a>

### 检索单个议题状态事件

检索特定项目议题的单个状态事件。

```plaintext
GET /projects/:id/issues/:issue_iid/resource_state_events/:resource_state_event_id
```

参数：

| 属性                     | 类型           | 是否必需 | 描述                                                                     |
| ----------------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`                          | integer or string | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid`                   | integer        | 是      | 议题的 IID                                                             |
| `resource_state_event_id`     | integer        | 是      | 状态事件的 ID                                                     |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/resource_state_events/143"
```

示例响应：

```json
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
  "resource_id": 11,
  "source_commit": null,
  "source_merge_request_id": null,
  "state": "closed"
}
```

<a id="merge-requests"></a>

## 合并请求

<a id="list-project-merge-request-state-events"></a>

### 列出项目合并请求状态事件

列出单个合并请求的所有状态事件。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/resource_state_events
```

| 属性           | 类型           | 是否必需 | 描述                                                                     |
| ------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`                | integer or string | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | integer        | 是      | 合并请求的 IID                                                      |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/resource_state_events"
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
    "resource_id": 11,
    "source_commit": null,
    "source_merge_request_id": null,
    "state": "opened"
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
    "resource_id": 11,
    "source_commit": null,
    "source_merge_request_id": null,
    "state": "closed"
  }
]
```

<a id="retrieve-a-single-merge-request-state-event"></a>

### 检索单个合并请求状态事件

检索特定项目合并请求的单个状态事件。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/resource_state_events/:resource_state_event_id
```

参数：

| 属性                     | 类型           | 是否必需 | 描述                                                                     |
| ----------------------------- | -------------- | -------- | ------------------------------------------------------------------------------- |
| `id`                          | integer or string | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid`           | integer        | 是      | 合并请求的 IID                                                      |
| `resource_state_event_id`     | integer        | 是      | 状态事件的 ID                                                     |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/resource_state_events/120"
```

示例响应：

```json
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
  "created_at": "2018-08-21T14:38:20.077Z",
  "resource_type": "MergeRequest",
  "resource_id": 11,
  "source_commit": null,
  "source_merge_request_id": null,
  "state": "closed"
}
```

<a id="epics"></a>

## 史诗

{{< history >}}

- 引入于 GitLab 15.4。

{{< /history >}}

> [!warning]
> 史诗 REST API 在 GitLab 17.0 中已弃用，
> 并计划在 API v5 中移除。
> 从 GitLab 17.4 到 18.0，如果已启用 [新版史诗](../user/group/epics/_index.md#epics-as-work-items)，以及在 GitLab 18.1 及更高版本中，请改用
> 工作项 API。有关更多信息，请参见[将史诗 API 迁移到工作项](graphql/epic_work_items_api_migration_guide.md)。
> 这是一个破坏性变更。

<a id="list-group-epic-state-events"></a>

### 列出群组史诗状态事件

列出单个史诗的所有状态事件。

```plaintext
GET /groups/:id/epics/:epic_id/resource_state_events
```

| 属性   | 类型           | 是否必需 | 描述                                                                    |
|-------------| -------------- | -------- |--------------------------------------------------------------------------------|
| `id`        | integer or string | 是      | 群组 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。   |
| `epic_id`   | integer        | 是      | 史诗的 ID。                                                              |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/resource_state_events"
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
    "resource_type": "Epic",
    "resource_id": 11,
    "source_commit": null,
    "source_merge_request_id": null,
    "state": "opened"
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
    "resource_type": "Epic",
    "resource_id": 11,
    "source_commit": null,
    "source_merge_request_id": null,
    "state": "closed"
  }
]
```

<a id="retrieve-a-single-epic-state-event"></a>

### 检索单个史诗状态事件

检索单个史诗状态事件。

```plaintext
GET /groups/:id/epics/:epic_id/resource_state_events/:resource_state_event_id
```

参数：

| 属性                 | 类型           | 是否必需 | 描述                                                                   |
|---------------------------| -------------- | -------- |-------------------------------------------------------------------------------|
| `id`                      | integer or string | 是      | 群组 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。  |
| `epic_id`                 | integer        | 是      | 史诗的 ID。                                                           |
| `resource_state_event_id` | integer        | 是      | 状态事件的 ID。                                                       |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/resource_state_events/143"
```

示例响应：

```json
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
  "resource_type": "Epic",
  "resource_id": 11,
  "source_commit": null,
  "source_merge_request_id": null,
  "state": "closed"
}
```
