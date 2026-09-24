---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于管理议题、合并请求、代码片段、史诗和 Wiki 评论的 REST API。
title: 评论 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理附加到极狐GitLab 内容的评论和系统记录。您可以：

- 创建和修改议题、合并请求、史诗、代码片段和提交上的评论。
- 检索关于对象更改的[系统生成的评论](../user/project/system_notes.md)。
- 对结果进行排序和分页。
- 使用机密和内部标志控制可见性。
- 使用速率限制防止滥用。

某些系统生成的评论作为单独的资源事件进行跟踪：

- [资源标记事件](resource_label_events.md)
- [资源状态事件](resource_state_events.md)
- [资源里程碑事件](resource_milestone_events.md)
- [资源权重事件](resource_weight_events.md)
- [资源迭代事件](resource_iteration_events.md)

默认情况下，`GET` 请求一次返回 20 条结果，因为 API 结果已分页。
更多信息，请参阅[分页](rest/_index.md#pagination)。

<a id="resource-events"></a>

## 资源事件

某些系统评论不属于此 API，而是作为单独的事件记录：

- [资源标记事件](resource_label_events.md)
- [资源状态事件](resource_state_events.md)
- [资源里程碑事件](resource_milestone_events.md)
- [资源权重事件](resource_weight_events.md)
- [资源迭代事件](resource_iteration_events.md)

<a id="notes-pagination"></a>

## 评论分页

默认情况下，`GET` 请求一次返回 20 条结果，因为 API 结果已分页。

阅读更多关于[分页](rest/_index.md#pagination)的信息。

<a id="rate-limits"></a>

## 速率限制

为帮助避免滥用，您可以将用户限制为每分钟特定数量的 `Create` 请求。
更多信息，请参阅[内容创建速率限制](../rate_limits/content_creation.md)。

<a id="issues"></a>

## 议题

<a id="list-all-issue-notes"></a>

### 列出所有议题评论

列出指定议题的所有评论。

```plaintext
GET /projects/:id/issues/:issue_iid/notes
GET /projects/:id/issues/:issue_iid/notes?sort=asc&order_by=updated_at
GET /projects/:id/issues/:issue_iid/notes?activity_filter=only_comments
```

| 属性   | 类型              | 必填 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数           | 是      | 议题的 IID |
| `activity_filter` | 字符串      | 否       | 按活动类型筛选评论。有效值：`all_notes`、`only_comments`、`only_activity`。默认值为 `all_notes` |
| `sort`      | 字符串            | 否       | 按 `asc` 或 `desc` 顺序返回议题评论。默认值为 `desc` |
| `order_by`  | 字符串            | 否       | 按 `created_at` 或 `updated_at` 字段排序返回议题评论。默认值为 `created_at` |

```json
[
  {
    "id": 302,
    "body": "closed",
    "author": {
      "id": 1,
      "username": "pipin",
      "email": "admin@example.com",
      "name": "Pip",
      "state": "active",
      "created_at": "2013-09-30T13:46:01Z"
    },
    "created_at": "2013-10-02T09:22:45Z",
    "updated_at": "2013-10-02T10:22:45Z",
    "system": true,
    "noteable_id": 377,
    "noteable_type": "Issue",
    "project_id": 5,
    "noteable_iid": 377,
    "resolvable": false,
    "confidential": false,
    "internal": false,
    "imported": false,
    "imported_from": "none"
  },
  {
    "id": 305,
    "body": "Text of the comment\r\n",
    "author": {
      "id": 1,
      "username": "pipin",
      "email": "admin@example.com",
      "name": "Pip",
      "state": "active",
      "created_at": "2013-09-30T13:46:01Z"
    },
    "created_at": "2013-10-02T09:56:03Z",
    "updated_at": "2013-10-02T09:56:03Z",
    "system": true,
    "noteable_id": 121,
    "noteable_type": "Issue",
    "project_id": 5,
    "noteable_iid": 121,
    "resolvable": false,
    "confidential": true,
    "internal": true,
    "imported": false,
    "imported_from": "none"
  }
]
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/notes"
```

<a id="retrieve-an-issue-note"></a>

### 检索议题评论

检索项目议题的指定评论。

```plaintext
GET /projects/:id/issues/:issue_iid/notes/:note_id
```

参数：

| 属性   | 类型              | 必填 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数           | 是      | 项目议题的 IID |
| `note_id`   | 整数           | 是      | 议题评论的 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/notes/1"
```

<a id="create-an-issue-note"></a>

### 创建议题评论

为指定的项目议题创建评论。

```plaintext
POST /projects/:id/issues/:issue_iid/notes
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid`    | 整数           | 是      | 议题的 IID。 |
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `confidential` | 布尔值           | 否       | **已弃用**：已重命名为 `internal`。评论的机密标志。默认值为 false。 |
| `internal`     | 布尔值           | 否       | 评论的内部标志。当同时提交两个参数时，覆盖 `confidential`。默认值为 false。 |
| `created_at`   | 字符串            | 否       | ISO 8601 格式的日期时间字符串。必须在 1970-01-01 之后。示例：`2016-03-11T03:45:40Z`（需要管理员或项目/群组所有者权限） |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/notes?body=note"
```

<a id="update-an-issue-note"></a>

### 更新议题评论

更新议题的指定评论。

```plaintext
PUT /projects/:id/issues/:issue_iid/notes/:note_id
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid`    | 整数           | 是      | 议题的 IID。 |
| `note_id`      | 整数           | 是      | 评论的 ID。 |
| `body`         | 字符串            | 否       | 评论的内容。限制为 1,000,000 个字符。 |
| `confidential` | 布尔值           | 否       | **已弃用**。评论的机密标志。默认值为 false。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/notes/636?body=note"
```

<a id="delete-an-issue-note"></a>

### 删除议题评论

删除议题的现有评论。

```plaintext
DELETE /projects/:id/issues/:issue_iid/notes/:note_id
```

参数：

| 属性   | 类型              | 必填 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `issue_iid` | 整数           | 是      | 议题的 IID |
| `note_id`   | 整数           | 是      | 评论的 ID |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/notes/636"
```

<a id="snippets"></a>

## 代码片段

代码片段评论 API 适用于项目代码片段，不适用于个人代码片段。

<a id="list-all-snippet-notes"></a>

### 列出所有代码片段评论

列出指定代码片段的所有评论。代码片段评论是用户可以发布到代码片段的评论。

```plaintext
GET /projects/:id/snippets/:snippet_id/notes
GET /projects/:id/snippets/:snippet_id/notes?sort=asc&order_by=updated_at
```

| 属性    | 类型              | 必填 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `snippet_id` | 整数           | 是      | 项目代码片段的 ID |
| `sort`       | 字符串            | 否       | 按 `asc` 或 `desc` 顺序返回代码片段评论。默认值为 `desc` |
| `order_by`   | 字符串            | 否       | 按 `created_at` 或 `updated_at` 字段排序返回代码片段评论。默认值为 `created_at` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/notes"
```

<a id="retrieve-a-snippet-note"></a>

### 检索代码片段评论

检索代码片段的指定评论。

```plaintext
GET /projects/:id/snippets/:snippet_id/notes/:note_id
```

参数：

| 属性    | 类型              | 必填 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `snippet_id` | 整数           | 是      | 项目代码片段的 ID |
| `note_id`    | 整数           | 是      | 代码片段评论的 ID |

```json
{
  "id": 302,
  "body": "closed",
  "author": {
    "id": 1,
    "username": "pipin",
    "email": "admin@example.com",
    "name": "Pip",
    "state": "active",
    "created_at": "2013-09-30T13:46:01Z"
  },
  "created_at": "2013-10-02T09:22:45Z",
  "updated_at": "2013-10-02T10:22:45Z",
  "system": true,
  "noteable_id": 377,
  "noteable_type": "Issue",
  "project_id": 5,
  "noteable_iid": 377,
  "resolvable": false,
  "confidential": false,
  "internal": false,
  "imported": false,
  "imported_from": "none"
}
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/notes/11"
```

<a id="create-a-snippet-note"></a>

### 创建代码片段评论

为指定的代码片段创建新评论。代码片段评论是用户对代码片段的评论。如果您创建的评论正文仅包含表情符号回应，极狐GitLab 会返回此对象。

```plaintext
POST /projects/:id/snippets/:snippet_id/notes
```

参数：

| 属性    | 类型              | 必填 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `snippet_id` | 整数           | 是      | 代码片段的 ID |
| `body`       | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `created_at` | 字符串            | 否       | ISO 8601 格式的日期时间字符串。示例：`2016-03-11T03:45:40Z`（需要管理员或项目/群组所有者权限） |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippet/11/notes?body=note"
```

<a id="update-a-snippet-note"></a>

### 更新代码片段评论

更新代码片段的指定评论。

```plaintext
PUT /projects/:id/snippets/:snippet_id/notes/:note_id
```

参数：

| 属性    | 类型              | 必填 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `snippet_id` | 整数           | 是      | 代码片段的 ID |
| `note_id`    | 整数           | 是      | 代码片段评论的 ID |
| `body`       | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/notes/1659?body=note"
```

<a id="delete-a-snippet-note"></a>

### 删除代码片段评论

删除代码片段的现有评论。

```plaintext
DELETE /projects/:id/snippets/:snippet_id/notes/:note_id
```

参数：

| 属性    | 类型              | 必填 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `snippet_id` | 整数           | 是      | 代码片段的 ID |
| `note_id`    | 整数           | 是      | 评论的 ID |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/52/notes/1659"
```

<a id="merge-requests"></a>

## 合并请求

<a id="list-all-merge-request-notes"></a>

### 列出所有合并请求评论

列出指定合并请求的所有评论。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/notes
GET /projects/:id/merge_requests/:merge_request_iid/notes?sort=asc&order_by=updated_at
```

| 属性           | 类型              | 必填 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |
| `sort`              | 字符串            | 否       | 按 `asc` 或 `desc` 顺序返回合并请求评论。默认值为 `desc` |
| `order_by`          | 字符串            | 否       | 按 `created_at` 或 `updated_at` 字段排序返回合并请求评论。默认值为 `created_at` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/notes"
```

<a id="retrieve-a-merge-request-note"></a>

### 检索合并请求评论

检索合并请求的指定评论。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/notes/:note_id
```

参数：

| 属性           | 类型              | 必填 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |
| `note_id`           | 整数           | 是      | 合并请求评论的 ID |

```json
{
  "id": 301,
  "body": "Comment for MR",
  "author": {
    "id": 1,
    "username": "pipin",
    "email": "admin@example.com",
    "name": "Pip",
    "state": "active",
    "created_at": "2013-09-30T13:46:01Z"
  },
  "created_at": "2013-10-02T08:57:14Z",
  "updated_at": "2013-10-02T08:57:14Z",
  "system": false,
  "noteable_id": 2,
  "noteable_type": "MergeRequest",
  "project_id": 5,
  "noteable_iid": 2,
  "resolvable": false,
  "confidential": false,
  "internal": false
}
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/notes/1"
```

<a id="create-a-merge-request-note"></a>

### 创建合并请求评论

为指定的合并请求创建评论。评论不附加到合并请求中的特定行。
对于其他更细粒度的控制方法，请参阅提交 API 中的[向提交发布评论](commits.md#post-comment-to-commit)，
以及讨论 API 中的[在合并请求差异中创建新讨论串](discussions.md#create-a-new-thread-in-the-merge-request-diff)。

如果您创建的评论正文仅包含表情符号回应，极狐GitLab 会返回此对象。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/notes
```

参数：

| 属性                     | 类型              | 必填 | 描述 |
|-------------------------------|-------------------|----------|-------------|
| `body`                        | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `id`                          | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid`           | 整数           | 是      | 项目合并请求的 IID |
| `created_at`                  | 字符串            | 否       | ISO 8601 格式的日期时间字符串。示例：`2016-03-11T03:45:40Z`（需要管理员或项目/群组所有者权限） |
| `internal`                    | 布尔值           | 否       | 评论的内部标志。默认值为 false。 |
| `merge_request_diff_head_sha` | 字符串            | 否       | [`/merge`](../user/project/quick_actions.md#merge) 快速操作所必需。头部提交的 SHA，用于确保发送 API 请求后合并请求未被更新。 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/notes?body=note"
```

<a id="update-a-merge-request-note"></a>

### 更新合并请求评论

更新合并请求的指定评论。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/notes/:note_id
```

参数：

| 属性           | 类型              | 必填 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |
| `note_id`           | 整数           | 否       | 评论的 ID |
| `body`              | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `confidential`      | 布尔值           | 否       | **已弃用**。评论的机密标志。默认值为 false。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/notes/1?body=note"
```

<a id="delete-a-merge-request-note"></a>

### 删除合并请求评论

删除合并请求的现有评论。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/notes/:note_id
```

参数：

| 属性           | 类型              | 必填 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 合并请求的 IID |
| `note_id`           | 整数           | 是      | 评论的 ID |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/7/notes/1602"
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
> 此更改属于破坏性变更。

<a id="list-all-epic-notes"></a>

### 列出所有史诗评论

列出指定史诗的所有评论。史诗评论是用户可以发布到史诗的评论。

> [!note]
> 史诗评论 API 使用史诗 ID 而不是史诗 IID。如果您使用史诗的 IID，极狐GitLab 会返回 404
> 错误或错误史诗的评论。这与[议题评论 API](#issues) 和
> [合并请求评论 API](#merge-requests) 不同。

```plaintext
GET /groups/:id/epics/:epic_id/notes
GET /groups/:id/epics/:epic_id/notes?sort=asc&order_by=updated_at
```

| 属性  | 类型              | 必填 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `epic_id`  | 整数           | 是      | 群组史诗的 ID |
| `sort`     | 字符串            | 否       | 按 `asc` 或 `desc` 顺序返回史诗评论。默认值为 `desc` |
| `order_by` | 字符串            | 否       | 按 `created_at` 或 `updated_at` 字段排序返回史诗评论。默认值为 `created_at` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/notes"
```

<a id="retrieve-an-epic-note"></a>

### 检索史诗评论

检索史诗的指定评论。

```plaintext
GET /groups/:id/epics/:epic_id/notes/:note_id
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `epic_id` | 整数           | 是      | 史诗的 ID |
| `note_id` | 整数           | 是      | 评论的 ID |

```json
{
  "id": 302,
  "body": "Epic note",
  "author": {
    "id": 1,
    "username": "pipin",
    "email": "admin@example.com",
    "name": "Pip",
    "state": "active",
    "created_at": "2013-09-30T13:46:01Z"
  },
  "created_at": "2013-10-02T09:22:45Z",
  "updated_at": "2013-10-02T10:22:45Z",
  "system": true,
  "noteable_id": 11,
  "noteable_type": "Epic",
  "project_id": 5,
  "noteable_iid": 11,
  "resolvable": false,
  "confidential": false,
  "internal": false,
  "imported": false,
  "imported_from": "none"
}
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/notes/1"
```

<a id="create-an-epic-note"></a>

### 创建史诗评论

为指定的史诗创建评论。史诗评论是用户可以发布到史诗的评论。如果您创建的评论正文仅包含表情符号回应，极狐GitLab 会返回此对象。

```plaintext
POST /groups/:id/epics/:epic_id/notes
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `epic_id`      | 整数           | 是      | 史诗的 ID |
| `id`           | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `confidential` | 布尔值           | 否       | **已弃用**：已重命名为 `internal`。评论的机密标志。默认值为 `false`。 |
| `internal`     | 布尔值           | 否       | 评论的内部标志。当同时提交两个参数时，覆盖 `confidential`。默认值为 `false`。 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/notes?body=note"
```

<a id="update-an-epic-note"></a>

### 更新史诗评论

更新史诗的指定评论。

```plaintext
PUT /groups/:id/epics/:epic_id/notes/:note_id
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `epic_id`      | 整数           | 是      | 史诗的 ID |
| `note_id`      | 整数           | 是      | 评论的 ID |
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `confidential` | 布尔值           | 否       | **已弃用**。评论的机密标志。默认值为 false。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/notes/1?body=note"
```

<a id="delete-an-epic-note"></a>

### 删除史诗评论

删除史诗的现有评论。

```plaintext
DELETE /groups/:id/epics/:epic_id/notes/:note_id
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `epic_id` | 整数           | 是      | 史诗的 ID |
| `note_id` | 整数           | 是      | 评论的 ID |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/52/notes/1659"
```

<a id="project-wikis"></a>

## 项目 Wiki

<a id="list-all-project-wiki-notes"></a>

### 列出所有项目 Wiki 评论

列出指定项目 Wiki 页面的所有评论。项目 Wiki 评论是用户可以发布到 Wiki 页面的评论。

> [!note]
> Wiki 页面评论 API 使用 Wiki 页面元数据 ID 而不是 Wiki 页面 slug。如果您使用页面的 slug，极狐GitLab 会返回 404
> 错误。您可以从[项目 Wiki API](wikis.md) 检索元数据 ID。

```plaintext
GET /projects/:id/wiki_pages/:wiki_page_meta_id/notes
GET /projects/:id/wiki_pages/:wiki_page_meta_id/notes?sort=asc&order_by=updated_at
```

参数：

| 属性  | 类型              | 必填 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `sort`     | 字符串            | 否       | 按 `asc` 或 `desc` 顺序返回 Wiki 页面评论。默认值为 `desc` |
| `order_by` | 字符串            | 否       | 按 `created_at` 或 `updated_at` 字段排序返回 Wiki 页面评论。默认值为 `created_at` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/wiki_pages/35/notes"
```

<a id="retrieve-a-wiki-page-note"></a>

### 检索 Wiki 页面评论

检索指定 Wiki 页面的单个评论。

```plaintext
GET /projects/:id/wiki_pages/:wiki_page_meta_id/notes/:note_id
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `note_id` | 整数           | 是      | 评论的 ID |

```json
{
  "author": {
      "id": 1,
      "username": "pipin",
      "email": "admin@example.com",
      "name": "Pip",
      "state": "active",
      "created_at": "2013-09-30T13:46:01Z"
  },
  "body": "foobar",
  "commands_changes": {},
  "confidential": false,
  "created_at": "2025-03-11T11:36:32.222Z",
  "id": 1218,
  "imported": false,
  "imported_from": "none",
  "internal": false,
  "noteable_id": 35,
  "noteable_iid": null,
  "noteable_type": "WikiPage::Meta",
  "project_id": 5,
  "resolvable": false,
  "system": false,
  "type": null,
  "updated_at": "2025-03-11T11:36:32.222Z"
}
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/wiki_pages/35/notes/1218"
```

<a id="create-a-wiki-page-note"></a>

### 创建 Wiki 页面评论

为单个 Wiki 页面创建新评论。Wiki 页面评论是用户可以发布到 Wiki 页面的评论。

```plaintext
POST /projects/:id/wiki_pages/:wiki_page_meta_id/notes
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `id`           | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/wiki_pages/35/notes?body=note"
```

<a id="update-a-wiki-page-note"></a>

### 更新 Wiki 页面评论

更新 Wiki 页面上的现有评论。

```plaintext
PUT /projects/:id/wiki_pages/:wiki_page_meta_id/notes/:note_id
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `note_id`      | 整数           | 是      | 评论的 ID |
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/wiki_pages/35/notes/1218?body=note"
```

<a id="delete-a-wiki-page-note"></a>

### 删除 Wiki 页面评论

从 Wiki 页面删除评论。

```plaintext
DELETE /projects/:id/wiki_pages/:wiki_page_meta_id/notes/:note_id
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `note_id` | 整数           | 是      | 评论的 ID |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/wiki_pages/35/notes/1218"
```

<a id="group-wikis"></a>

## 群组 Wiki

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="list-group-wiki-notes"></a>

### 列出群组 Wiki 评论

列出指定群组 Wiki 页面的所有评论。群组 Wiki 评论是用户可以发布到 Wiki 页面的评论。

> [!note]
> Wiki 页面评论 API 使用 Wiki 页面元数据 ID 而不是 Wiki 页面 slug。如果您使用页面的 slug，极狐GitLab 会返回 404
> 错误。您可以从[群组 Wiki API](group_wikis.md) 检索元数据 ID。

```plaintext
GET /groups/:id/wiki_pages/:wiki_page_meta_id/notes
GET /groups/:id/wiki_pages/:wiki_page_meta_id/notes?sort=asc&order_by=updated_at
```

| 属性  | 类型              | 必填 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `sort`     | 字符串            | 否       | 按 `asc` 或 `desc` 顺序返回 Wiki 页面评论。默认值为 `desc` |
| `order_by` | 字符串            | 否       | 按 `created_at` 或 `updated_at` 字段排序返回 Wiki 页面评论。默认值为 `created_at` |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/wiki_pages/35/notes"
```

<a id="retrieve-a-wiki-page-note-1"></a>

### 检索 Wiki 页面评论

检索 Wiki 页面的指定评论。

```plaintext
GET /groups/:id/wiki_pages/:wiki_page_meta_id/notes/:note_id
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `note_id` | 整数           | 是      | 评论的 ID |

```json
{
  "author": {
      "id": 1,
      "username": "pipin",
      "email": "admin@example.com",
      "name": "Pip",
      "state": "active",
      "created_at": "2013-09-30T13:46:01Z"
  },
  "body": "foobar",
  "commands_changes": {},
  "confidential": false,
  "created_at": "2025-03-11T11:36:32.222Z",
  "id": 1218,
  "imported": false,
  "imported_from": "none",
  "internal": false,
  "noteable_id": 35,
  "noteable_iid": null,
  "noteable_type": "WikiPage::Meta",
  "project_id": null,
  "resolvable": false,
  "system": false,
  "type": null,
  "updated_at": "2025-03-11T11:36:32.222Z"
}
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/wiki_pages/35/notes/1218"
```

<a id="create-a-wiki-page-note-1"></a>

### 创建 Wiki 页面评论

为指定的 Wiki 页面创建评论。Wiki 页面评论是用户可以发布到 Wiki 页面的评论。

```plaintext
POST /groups/:id/wiki_pages/:wiki_page_meta_id/notes
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `id`           | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/wiki_pages/35/notes?body=note"
```

<a id="update-a-wiki-page-note-1"></a>

### 更新 Wiki 页面评论

更新 Wiki 页面上的指定评论。

```plaintext
PUT /groups/:id/wiki_pages/:wiki_page_meta_id/notes/:note_id
```

参数：

| 属性      | 类型              | 必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `note_id`      | 整数           | 是      | 评论的 ID |
| `body`         | 字符串            | 是      | 评论的内容。限制为 1,000,000 个字符。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/wiki_pages/35/notes/1218?body=note"
```

<a id="delete-a-wiki-page-note-1"></a>

### 删除 Wiki 页面评论

从 Wiki 页面删除评论。

```plaintext
DELETE /groups/:id/wiki_pages/:wiki_page_meta_id/notes/:note_id
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `wiki_page_meta_id`  | 整数           | 是      | Wiki 页面元数据的 ID |
| `note_id` | 整数           | 是      | 评论的 ID |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/wiki_pages/35/notes/1218"
```
