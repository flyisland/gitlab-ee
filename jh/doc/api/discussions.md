---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 讨论 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [讨论](../user/discussions/_index.md)。这包括 [评论、主题](../user/discussions/_index.md) 以及关于对象更改的系统记录（例如，当里程碑更改时）。

要管理标签评论，请使用 [资源标签事件 API](resource_label_events.md)。

<a id="understand-note-types-in-the-api"></a>

## 了解 API 中的评论类型

并非所有讨论类型在 API 中都同样可用：

- 评论：在议题、合并请求、提交或代码片段的 _根_ 上留下的评论。
- 讨论：议题、合并请求、提交或代码片段中 `DiscussionNotes` 的集合，通常称为 _主题_。
- 讨论评论：议题、合并请求、提交或代码片段中讨论的单个条目。类型为 `DiscussionNote` 的条目不会作为评论 API 的一部分返回。在 [事件 API](events.md) 中不可用。

<a id="discussions-pagination"></a>

## 讨论分页

默认情况下，`GET` 请求一次返回 20 个结果，因为 API 结果已分页。

阅读有关 [分页](rest/_index.md#pagination) 的更多信息。

<a id="issues"></a>

## 议题

<a id="list-all-issue-discussion-items"></a>

### 列出所有议题讨论条目

列出一个项目中指定议题的所有讨论条目。

```plaintext
GET /projects/:id/issues/:issue_iid/discussions
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是 | 议题的 IID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|-------------------------|---------|-------------|
| `id` | 字符串 | 讨论的 ID。 |
| `individual_note` | 布尔值 | 如果为 `true`，表示是单个评论或讨论的一部分。 |
| `notes` | 数组 | 讨论中的评论对象数组。 |
| `notes[].id` | 整数 | 评论的 ID。 |
| `notes[].type` | 字符串 | 评论的类型（`DiscussionNote` 或 `null`）。 |
| `notes[].body` | 字符串 | 评论的内容。 |
| `notes[].author` | 对象 | 评论的作者。 |
| `notes[].created_at` | 字符串 | 评论创建时间（ISO 8601 格式）。 |
| `notes[].updated_at` | 字符串 | 评论最后更新时间（ISO 8601 格式）。 |
| `notes[].system` | 布尔值 | 如果为 `true`，表示系统评论。 |
| `notes[].noteable_id` | 整数 | 可评论对象的 ID。 |
| `notes[].noteable_type` | 字符串 | 可评论对象的类型。 |
| `notes[].project_id` | 整数 | 项目的 ID。 |
| `notes[].resolvable` | 布尔值 | 如果为 `true`，表示该评论可解决。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/discussions"
```

示例响应：

```json
[
  {
    "id": "6a9c1750b37d513a43987b574953fceb50b03ce7",
    "individual_note": false,
    "notes": [
      {
        "id": 1126,
        "type": "DiscussionNote",
        "body": "discussion text",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-03T21:54:39.668Z",
        "updated_at": "2018-03-03T21:54:39.668Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Issue",
        "project_id": 5,
        "noteable_iid": null
      },
      {
        "id": 1129,
        "type": "DiscussionNote",
        "body": "reply to the discussion",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T13:38:02.127Z",
        "updated_at": "2018-03-04T13:38:02.127Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Issue",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  },
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": true,
    "notes": [
      {
        "id": 1128,
        "type": null,
        "body": "a single comment",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Issue",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  }
]
```

<a id="retrieve-an-issue-discussion-item"></a>

### 获取一个议题讨论条目

获取一个项目议题的指定讨论条目。

```plaintext
GET /projects/:id/issues/:issue_iid/discussions/:discussion_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `discussion_id` | 整数 | 是 | 讨论条目的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是 | 议题的 IID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和与 [列出议题讨论条目](#list-all-issue-discussion-items) 相同的响应属性。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/discussions/<discussion_id>"
```

<a id="create-an-issue-thread"></a>

### 创建议题主题

为一个项目议题创建一个新主题。类似于创建评论，但之后可以向其中添加其他评论（回复）。

```plaintext
POST /projects/:id/issues/:issue_iid/discussions
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `body` | 字符串 | 是 | 主题的内容。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是 | 议题的 IID。 |
| `created_at` | 字符串 | 否 | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者的权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和与 [列出议题讨论条目](#list-all-issue-discussion-items) 相同的响应属性。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/discussions?body=comment"
```

<a id="add-a-note-to-an-issue-thread"></a>

### 向议题主题添加评论

向主题添加一条新评论。这也可以 [从单个评论创建主题](../user/discussions/_index.md#create-a-thread-by-replying-to-a-standard-comment)。

> [!note]
> 不能向系统评论添加评论。尝试这样做会返回 `400 Bad Request` 错误。

```plaintext
POST /projects/:id/issues/:issue_iid/discussions/:discussion_id/notes
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `body` | 字符串 | 是 | 评论或回复的内容。 |
| `discussion_id` | 整数 | 是 | 主题的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是 | 议题的 IID。 |
| `created_at` | 字符串 | 否 | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者的权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和创建的评论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/discussions/<discussion_id>/notes?body=comment"
```

<a id="update-an-issue-thread-note"></a>

### 更新议题主题评论

更新议题的现有主题评论。

```plaintext
PUT /projects/:id/issues/:issue_iid/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `body` | 字符串 | 是 | 评论或回复的内容。 |
| `discussion_id` | 整数 | 是 | 主题的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是 | 议题的 IID。 |
| `note_id` | 整数 | 是 | 主题评论的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和更新后的评论对象。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/discussions/<discussion_id>/notes/<note_id>?body=comment"
```

<a id="delete-an-issue-thread-note"></a>

### 删除议题主题评论

删除议题的现有主题评论。

```plaintext
DELETE /projects/:id/issues/:issue_iid/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `discussion_id` | 整数 | 是 | 讨论的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid` | 整数 | 是 | 议题的 IID。 |
| `note_id` | 整数 | 是 | 讨论评论的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/issues/11/discussions/<discussion_id>/notes/<note_id>"
```

<a id="snippets"></a>

## 代码片段

<a id="list-all-snippet-discussion-items"></a>

### 列出所有代码片段讨论条目

列出一个项目中指定代码片段的所有讨论条目。

```plaintext
GET /projects/:id/snippets/:snippet_id/discussions
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和与 [列出议题讨论条目](#list-all-issue-discussion-items) 相同的响应属性，其中 `noteable_type` 设置为 `Snippet`。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/discussions"
```

示例响应：

```json
[
  {
    "id": "6a9c1750b37d513a43987b574953fceb50b03ce7",
    "individual_note": false,
    "notes": [
      {
        "id": 1126,
        "type": "DiscussionNote",
        "body": "discussion text",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-03T21:54:39.668Z",
        "updated_at": "2018-03-03T21:54:39.668Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Snippet",
        "project_id": 5,
        "noteable_iid": null
      },
      {
        "id": 1129,
        "type": "DiscussionNote",
        "body": "reply to the discussion",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T13:38:02.127Z",
        "updated_at": "2018-03-04T13:38:02.127Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Snippet",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  },
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": true,
    "notes": [
      {
        "id": 1128,
        "type": null,
        "body": "a single comment",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Snippet",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  }
]
```

<a id="retrieve-a-snippet-discussion-item"></a>

### 获取一个代码片段讨论条目

获取一个项目代码片段的指定讨论条目。

```plaintext
GET /projects/:id/snippets/:snippet_id/discussions/:discussion_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------------- | -------------- | -------- | ----------- |
| `discussion_id` | 整数 | 是 | 讨论条目的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和与 [列出代码片段讨论条目](#list-all-snippet-discussion-items) 相同的响应属性。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/discussions/<discussion_id>"
```

<a id="create-a-snippet-thread"></a>

### 创建代码片段主题

为一个项目代码片段创建一个新主题。类似于创建评论，但之后可以向其中添加其他评论（回复）。

```plaintext
POST /projects/:id/snippets/:snippet_id/discussions
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `body` | 字符串 | 是 | 讨论的内容。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |
| `created_at` | 字符串 | 否 | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者的权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和创建的讨论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/discussions?body=comment"
```

<a id="add-a-note-to-a-snippet-thread"></a>

### 向代码片段主题添加评论

向主题添加一条新评论。

```plaintext
POST /projects/:id/snippets/:snippet_id/discussions/:discussion_id/notes
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `body` | 字符串 | 是 | 评论或回复的内容。 |
| `discussion_id` | 整数 | 是 | 主题的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |
| `created_at` | 字符串 | 否 | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者的权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和创建的评论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/discussions/<discussion_id>/notes?body=comment"
```

<a id="update-a-snippet-thread-note"></a>

### 更新代码片段主题评论

更新代码片段的现有主题评论。

```plaintext
PUT /projects/:id/snippets/:snippet_id/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------------- | -------------- | -------- | ----------- |
| `body` | 字符串 | 是 | 评论或回复的内容。 |
| `discussion_id` | 整数 | 是 | 主题的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `note_id` | 整数 | 是 | 主题评论的 ID。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和更新后的评论对象。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/discussions/<discussion_id>/notes/<note_id>?body=comment"
```

<a id="delete-a-snippet-thread-note"></a>

### 删除代码片段主题评论

删除代码片段的现有主题评论。

```plaintext
DELETE /projects/:id/snippets/:snippet_id/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `discussion_id` | 整数 | 是 | 讨论的 ID。 |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `note_id` | 整数 | 是 | 讨论评论的 ID。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/snippets/11/discussions/<discussion_id>/notes/<note_id>"
```

<a id="epics"></a>

## 史诗

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 史诗 REST API 在极狐GitLab 17.0 中已 [弃用](https://jihulab.com/gitlab-cn/-/issues/460668)，并计划在 API v5 中移除。这是一个破坏性变更。
>
> 请改用 Work Items API：
>
> - 极狐GitLab 17.4 至 18.0：当 [史诗的新外观](../user/group/epics/_index.md#epics-as-work-items) 启用时需要使用。
> - 极狐GitLab 18.1 及更高版本：所有安装均需要使用。
>
> 更多信息，请参阅 [API 迁移指南](graphql/epic_work_items_api_migration_guide.md)。

<a id="list-all-epic-discussion-items"></a>

### 列出所有史诗讨论条目

列出一个史诗的所有讨论条目。

```plaintext
GET /groups/:id/epics/:epic_id/discussions
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `epic_id` | 整数 | 是 | 史诗的 ID。 |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和与 [列出议题讨论条目](#list-all-issue-discussion-items) 相同的响应属性，其中 `noteable_type` 设置为 `Epic`。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/discussions"
```

示例响应：

```json
[
  {
    "id": "6a9c1750b37d513a43987b574953fceb50b03ce7",
    "individual_note": false,
    "notes": [
      {
        "id": 1126,
        "type": "DiscussionNote",
        "body": "discussion text",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-03T21:54:39.668Z",
        "updated_at": "2018-03-03T21:54:39.668Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Epic",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      },
      {
        "id": 1129,
        "type": "DiscussionNote",
        "body": "reply to the discussion",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T13:38:02.127Z",
        "updated_at": "2018-03-04T13:38:02.127Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Epic",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  },
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": true,
    "notes": [
      {
        "id": 1128,
        "type": null,
        "body": "a single comment",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Epic",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  }
]
```

<a id="retrieve-an-epic-discussion-item"></a>

### 获取一个史诗讨论条目

获取一个群组史诗的指定讨论条目。

```plaintext
GET /groups/:id/epics/:epic_id/discussions/:discussion_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `discussion_id` | 整数 | 是 | 讨论条目的 ID。 |
| `epic_id` | 整数 | 是 | 史诗的 ID。 |
| `id` | 整数或字符串 | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和与 [列出史诗讨论条目](#list-all-epic-discussion-items) 相同的响应属性。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/discussions/<discussion_id>"
```

<a id="create-an-epic-thread"></a>

### 创建史诗主题

为一个群组史诗创建一个新主题。类似于创建评论，但之后可以向其中添加其他评论（回复）。

```plaintext
POST /groups/:id/epics/:epic_id/discussions
```

支持的属性：
### 创建新史诗讨论串

创建一个新史诗讨论串。这类似于创建一条评论，但之后可以添加其他评论（回复）。

```plaintext
POST /groups/:id/epics/:epic_id/discussions
```

支持的属性：

| 属性          | 类型              | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `body`       | string            | 是      | 讨论串的内容。 |
| `epic_id`    | integer           | 是      | 史诗的 ID。 |
| `id`         | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_at` | string            | 否       | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及创建的讨论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/discussions?body=comment"
```

### 向史诗讨论串添加评论

向讨论串添加一条新评论。这也可以
[从单条评论创建讨论串](../user/discussions/_index.md#create-a-thread-by-replying-to-a-standard-comment)。

```plaintext
POST /groups/:id/epics/:epic_id/discussions/:discussion_id/notes
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `body`          | string            | 是      | 评论或回复的内容。 |
| `discussion_id` | integer            | 是      | 讨论串的 ID。 |
| `epic_id`       | integer           | 是      | 史诗的 ID。 |
| `id`            | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `created_at`    | string            | 否       | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及创建的评论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/discussions/<discussion_id>/notes?body=comment"
```

### 更新史诗讨论串评论

更新史诗的一条现有讨论串评论。

```plaintext
PUT /groups/:id/epics/:epic_id/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `body`          | string            | 是      | 评论或回复的内容。 |
| `discussion_id` | integer            | 是      | 讨论串的 ID。 |
| `epic_id`       | integer           | 是      | 史诗的 ID。 |
| `id`            | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `note_id`       | integer           | 是      | 讨论串评论的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及更新后的评论对象。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/discussions/<discussion_id>/notes/<note_id>?body=comment"
```

### 删除史诗讨论串评论

删除史诗的一条现有讨论串评论。

```plaintext
DELETE /groups/:id/epics/:epic_id/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|-------------|
| `discussion_id` | integer            | 是      | 讨论串的 ID。 |
| `epic_id`       | integer           | 是      | 史诗的 ID。 |
| `id`            | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `note_id`       | integer           | 是      | 讨论串评论的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/epics/11/discussions/<discussion_id>/notes/<note_id>"
```

<a id="merge-requests"></a>

## 合并请求

<a id="list-all-merge-request-discussion-items"></a>

### 列出所有合并请求讨论项

列出指定合并请求的所有讨论项。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/discussions
```

支持的属性：

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                     | 类型      | 描述 |
|-------------------------|---------|-------------|
| `id`                    | string  | 讨论项的 ID。 |
| `individual_note`       | boolean | 如果为 `true`，表示是独立评论或讨论的一部分。 |
| `notes`                 | array   | 讨论中的评论对象数组。 |
| `notes[].id`            | integer | 评论的 ID。 |
| `notes[].type`          | string  | 评论的类型（`DiscussionNote`、`DiffNote` 或 `null`）。 |
| `notes[].body`          | string  | 评论的内容。 |
| `notes[].author`        | object  | 评论的作者。 |
| `notes[].created_at`    | string  | 评论的创建时间（ISO 8601 格式）。 |
| `notes[].updated_at`    | string  | 评论的最后更新时间（ISO 8601 格式）。 |
| `notes[].system`        | boolean | 如果为 `true`，表示是系统评论。 |
| `notes[].noteable_id`   | integer | 可评论对象的 ID。 |
| `notes[].noteable_type` | string  | 可评论对象的类型。 |
| `notes[].project_id`    | integer | 项目的 ID。 |
| `notes[].resolved`      | boolean | 如果为 `true`，表示评论已解决（仅合并请求）。 |
| `notes[].resolvable`    | boolean | 如果为 `true`，表示评论可以被解决。 |
| `notes[].resolved_by`   | object  | 解决该评论的用户。 |
| `notes[].resolved_at`   | string  | 评论的解决时间（ISO 8601 格式）。 |
| `notes[].position`      | object  | diff 评论的位置信息。 |
| `notes[].suggestions`   | array   | 评论的建议对象数组。 |

Diff 评论也包含位置信息：

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions"
```

示例响应：

```json
[
  {
    "id": "6a9c1750b37d513a43987b574953fceb50b03ce7",
    "individual_note": false,
    "notes": [
      {
        "id": 1126,
        "type": "DiscussionNote",
        "body": "讨论文本",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-03T21:54:39.668Z",
        "updated_at": "2018-03-03T21:54:39.668Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "MergeRequest",
        "project_id": 5,
        "noteable_iid": null,
        "resolved": false,
        "resolvable": true,
        "resolved_by": null,
        "resolved_at": null
      },
      {
        "id": 1129,
        "type": "DiscussionNote",
        "body": "回复讨论",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T13:38:02.127Z",
        "updated_at": "2018-03-04T13:38:02.127Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "MergeRequest",
        "project_id": 5,
        "noteable_iid": null,
        "resolved": false,
        "resolvable": true,
        "resolved_by": null
      }
    ]
  },
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": true,
    "notes": [
      {
        "id": 1128,
        "type": null,
        "body": "一条单独的评论",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "MergeRequest",
        "project_id": 5,
        "noteable_iid": null,
        "resolved": false,
        "resolvable": true,
        "resolved_by": null
      }
    ]
  }
]
```

Diff 评论也包含位置信息：

```json
[
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": false,
    "notes": [
      {
        "id": 1128,
        "type": "DiffNote",
        "body": "diff 评论",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "MergeRequest",
        "project_id": 5,
        "noteable_iid": null,
        "commit_id": "4803c71e6b1833ca72b8b26ef2ecd5adc8a38031",
        "position": {
          "base_sha": "b5d6e7b1613fca24d250fa8e5bc7bcc3dd6002ef",
          "start_sha": "7c9c2ead8a320fb7ba0b4e234bd9529a2614e306",
          "head_sha": "4803c71e6b1833ca72b8b26ef2ecd5adc8a38031",
          "old_path": "package.json",
          "new_path": "package.json",
          "position_type": "text",
          "old_line": 27,
          "new_line": 27,
          "line_range": {
            "start": {
              "line_code": "588440f66559714280628a4f9799f0c4eb880a4a_10_10",
              "type": "new",
              "old_line": null,
              "new_line": 10
            },
            "end": {
              "line_code": "588440f66559714280628a4f9799f0c4eb880a4a_11_11",
              "type": "old",
              "old_line": 11,
              "new_line": 11
            }
          }
        },
        "resolved": false,
        "resolvable": true,
        "resolved_by": null,
        "suggestions": [
          {
            "id": 1,
            "from_line": 27,
            "to_line": 27,
            "appliable": true,
            "applied": false,
            "from_content": "x",
            "to_content": "b"
          }
        ]
      }
    ]
  }
]
```

<a id="retrieve-a-merge-request-discussion-item"></a>

### 获取一个合并请求讨论项

获取项目合并请求的指定讨论项。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id
```

支持的属性：

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `discussion_id`     | string            | 是      | 讨论项的 ID。 |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及与[列出合并请求讨论项](#list-all-merge-request-discussion-items)相同的响应属性。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions/<discussion_id>"
```

<a id="create-a-merge-request-thread"></a>

### 创建合并请求讨论串

为单个项目合并请求创建一个新讨论串。这类似于创建一条评论，但之后可以添加其他评论（回复）。其他方法，请参阅 Commits API 中的[发表对提交的评论](commits.md#post-comment-to-commit)以及 Notes API 中的[创建合并请求评论](notes.md#create-a-merge-request-note)。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/discussions
```

所有评论支持的属性：

| 属性                       | 类型              | 是否必需                             | 描述 |
|---------------------------|-------------------|--------------------------------------|-------------|
| `body`                    | string            | 是                                  | 讨论串的内容。 |
| `id`                      | integer or string | 是                                  | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid`       | integer           | 是                                  | 合并请求的 IID。 |
| `commit_id`               | string            | 否                                   | 用于启动此讨论的提交的 SHA 引用。 |
| `created_at`              | string            | 否                                   | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |
| `position`                | hash              | 否                                   | 创建 diff 评论时的位置。 |
| `position[base_sha]`      | string            | 是（如果提供了 `position*`）     | 源分支中的基础提交 SHA。 |
| `position[head_sha]`      | string            | 是（如果提供了 `position*`）     | 引用此合并请求的 HEAD 的 SHA。 |
| `position[start_sha]`     | string            | 是（如果提供了 `position*`）     | 引用目标分支中提交的 SHA。 |
| `position[position_type]` | string            | 是（如果提供了 position*）       | 位置引用的类型。允许的值：`text`、`image` 或 `file`。`file` 在极狐GitLab 16.4 中引入。 |
| `position[new_path]`      | string            | 是（如果位置类型是 `text`） | 更改后的文件路径。 |
| `position[old_path]`      | string            | 是（如果位置类型是 `text`） | 更改前的文件路径。 |
| `position[new_line]`      | integer           | 否                                   | 对于 `text` 类型的 diff 评论，更改后的行号。 |
| `position[old_line]`      | integer           | 否                                   | 对于 `text` 类型的 diff 评论，更改前的行号。 |
| `position[line_range]`    | hash              | 否                                   | 多行 diff 评论的行范围。 |
| `position[width]`         | integer           | 否                                   | 对于 `image` 类型的 diff 评论，图像的宽度。 |
| `position[height]`        | integer           | 否                                   | 对于 `image` 类型的 diff 评论，图像的高度。 |
| `position[x]`             | float             | 否                                   | 对于 `image` 类型的 diff 评论，X 坐标。 |
| `position[y]`             | float             | 否                                   | 对于 `image` 类型的 diff 评论，Y 坐标。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及创建的讨论对象。

<a id="create-a-new-thread-on-the-overview-page"></a>

#### 在概览页面创建新讨论串

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions?body=comment"
```

<a id="create-a-new-thread-in-the-merge-request-diff"></a>

#### 在合并请求 diff 中创建新讨论串

- `position[old_path]` 和 `position[new_path]` 都是必需的，并且必须分别指向更改前后的文件路径。
- 要对添加的行（在合并请求 diff 中高亮为绿色）创建讨论串，请使用 `position[new_line]`，并且不要包含 `position[old_line]`。
- 要对删除的行（在合并请求 diff 中高亮为红色）创建讨论串，请使用 `position[old_line]`，并且不要包含 `position[new_line]`。
- 要对未更改的行创建讨论串，请同时为该行包含 `position[new_line]` 和 `position[old_line]`。如果文件中的早期更改改变了行号，这些位置可能不同。

如果指定了不正确的 `base`、`head`、`start` 或 `SHA` 参数，可能会出现问题。

要创建新讨论串：

1. [获取最新的合并请求版本](merge_requests.md#retrieve-merge-request-diff-versions)：

   ```shell
   curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/versions"
   ```

1. 记下响应数组中列出的最新版本的详细信息。

   ```json
   [
     {
       "id": 164560414,
       "head_commit_sha": "f9ce7e16e56c162edbc9e480108041cf6b0291fe",
       "base_commit_sha": "5e6dffa282c5129aa67cd227a0429be21bfdaf80",
       "start_commit_sha": "5e6dffa282c5129aa67cd227a0429be21bfdaf80",
       "created_at": "2021-03-30T09:18:27.351Z",
       "merge_request_id": 93958054,
       "state": "collected",
       "real_size": "2"
     },
     "这里是之前的版本"
   ]
   ```

1. 创建一个新的 diff 讨论串。此示例在添加的行上创建讨论串：

   ```shell
   curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --form 'position[position_type]=text' \
     --form 'position[base_sha]=<请使用版本响应中的 base_commit_sha>' \
     --form 'position[head_sha]=<请使用版本响应中的 head_commit_sha>' \
     --form 'position[start_sha]=<请使用版本响应中的 start_commit_sha>' \
     --form 'position[new_path]=file.js' \
     --form 'position[old_path]=file.js' \
     --form 'position[new_line]=18' \
     --form 'body=测试评论正文' \
     --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions"
   ```

<a id="parameters-for-multiline-comments"></a>

#### 多行评论的参数

仅多行评论支持的属性：

| 属性                                      | 类型    | 是否必需 | 描述 |
|------------------------------------------|---------|----------|-------------|
| `position[line_range][end][line_code]`   | string  | 是      | 结束行的[行代码](#line-code)。 |
| `position[line_range][end][type]`        | string  | 是      | 对于本次提交添加的行，请使用 `new`，否则使用 `old`。 |
| `position[line_range][end][old_line]`    | integer | 否       | 结束行的旧行号。 |
| `position[line_range][end][new_line]`    | integer | 否       | 结束行的新行号。 |
| `position[line_range][start][line_code]` | string  | 是      | 起始行的[行代码](#line-code)。 |
| `position[line_range][start][type]`      | string  | 是      | 对于本次提交添加的行，请使用 `new`，否则使用 `old`。 |
| `position[line_range][start][old_line]`  | integer | 否       | 起始行的旧行号。 |
| `position[line_range][start][new_line]`  | integer | 否       | 起始行的新行号。 |
| `position[line_range][end]`              | hash    | 否       | 多行评论的结束行。 |
| `position[line_range][start]`            | hash    | 否       | 多行评论的起始行。 |

`line_range` 属性中的 `old_line` 和 `new_line` 参数用于显示多行评论的范围。例如，“对第 +296 行到 +297 行的评论”。

<a id="line-code"></a>

#### 行代码

行代码的格式为 `<SHA>_<old>_<new>`，如下所示：`adc83b19e793491b1c6ea0fd8b46cd9f32e292fc_5_5`

- `<SHA>` 是文件名的 SHA1 哈希值。
- `<old>` 是更改前的行号。
- `<new>` 是更改后的行号。

例如，如果一个提交（`<COMMIT_ID>`）删除了 README 中的第 463 行，您可以通过引用旧文件中的第 463 行来对删除进行评论：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "note=删除这行多余的内容真是明智之举！" \
  --form "path=README" \
  --form "line=463" \
  --form "line_type=old" \
  --url "https://gitlab.com/api/v4/projects/47/repository/commits/<COMMIT_ID>/comments"
```

如果一个提交（`<COMMIT_ID>`）向 `hello.rb` 添加了第 157 行，您可以通过引用新文件中的第 157 行来对添加进行评论：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "note=这真是太棒了！" \
  --form "path=hello.rb" \
  --form "line=157" \
  --form "line_type=new" \
  --url "https://gitlab.com/api/v4/projects/47/repository/commits/<COMMIT_ID>/comments"
```

<a id="resolve-a-merge-request-thread"></a>

### 解决合并请求讨论串

解决或重新打开合并请求中的讨论串。

前置条件：

- 你必须具有开发者、维护者或所有者角色，或者是正在被审核的更改的提交者。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id
```

支持的属性：

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `discussion_id`     | string            | 是      | 讨论串的 ID。 |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |
| `resolved`          | boolean           | 是      | 如果为 `true`，则解决或重新打开该讨论。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及更新后的讨论对象。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions/<discussion_id>?resolved=true"
```

<a id="add-note-to-a-merge-request-thread"></a>

### 向合并请求讨论串添加评论

向讨论串添加一条新评论。这也可以
[从单条评论创建讨论串](../user/discussions/_index.md#create-a-thread-by-replying-to-a-standard-comment)。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id/notes
```

支持的属性：

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `body`              | string            | 是      | 评论或回复的内容。 |
| `discussion_id`     | string            | 是      | 讨论串的 ID。 |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |
| `created_at`        | string            | 否       | 日期时间字符串，ISO 8601 格式，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及创建的评论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions/<discussion_id>/notes?body=comment"
```

<a id="update-a-merge-request-thread-note"></a>

### 更新合并请求讨论串评论

为合并请求更新或解决指定的讨论串评论。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `discussion_id`     | string            | 是      | 讨论串的 ID。 |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 合并请求的 IID。 |
| `note_id`           | integer           | 是      | 讨论串评论的 ID。 |
| `body`              | string            | 否       | 评论或回复的内容。`body` 或 `resolved` 必须设置其中一个。 |
| `resolved`          | boolean           | 否       | 解决或重新打开该评论。`body` 或 `resolved` 必须设置其中一个。 |
如果成功，将返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及更新后的评论对象。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions/<discussion_id>/notes/<note_id>?body=comment"
```

解决评论：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions/<discussion_id>/notes/<note_id>?resolved=true"
```

### 删除合并请求讨论串评论

删除合并请求中已有的讨论串评论。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|------|
| `discussion_id`     | 字符串            | 是      | 讨论串的 ID。 |
| `id`                | 整数或字符串      | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数              | 是      | 合并请求的 IID。 |
| `note_id`           | 整数              | 是      | 讨论串评论的 ID。 |

如果成功，将返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/merge_requests/11/discussions/<discussion_id>/notes/<note_id>"
```

<a id="commits"></a>

## 提交

<a id="list-all-commit-discussion-items"></a>

### 列出所有提交讨论项

列出指定提交的所有讨论项。

```plaintext
GET /projects/:id/repository/commits/:commit_id/discussions
```

支持的属性：

| 属性         | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|------|
| `commit_id` | 字符串            | 是      | 提交的 SHA。 |
| `id`        | 整数或字符串      | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |

如果成功，将返回 [`200 OK`](rest/troubleshooting.md#status-codes)，响应属性与 [列建议题讨论项](#list-all-issue-discussion-items) 相同，其中 `noteable_type` 设置为 `Commit`。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions"
```

示例响应：

```json
[
  {
    "id": "6a9c1750b37d513a43987b574953fceb50b03ce7",
    "individual_note": false,
    "notes": [
      {
        "id": 1126,
        "type": "DiscussionNote",
        "body": "讨论文本",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-03T21:54:39.668Z",
        "updated_at": "2018-03-03T21:54:39.668Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Commit",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      },
      {
        "id": 1129,
        "type": "DiscussionNote",
        "body": "针对讨论的回复",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T13:38:02.127Z",
        "updated_at": "2018-03-04T13:38:02.127Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Commit",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  },
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": true,
    "notes": [
      {
        "id": 1128,
        "type": null,
        "body": "单个评论",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Commit",
        "project_id": 5,
        "noteable_iid": null,
        "resolvable": false
      }
    ]
  }
]
```

差异评论也包含位置信息：

```json
[
  {
    "id": "87805b7c09016a7058e91bdbe7b29d1f284a39e6",
    "individual_note": false,
    "notes": [
      {
        "id": 1128,
        "type": "DiffNote",
        "body": "差异评论",
        "attachment": null,
        "author": {
          "id": 1,
          "name": "root",
          "username": "root",
          "state": "active",
          "avatar_url": "https://www.gravatar.com/avatar/00afb8fb6ab07c3ee3e9c1f38777e2f4?s=80&d=identicon",
          "web_url": "http://localhost:3000/root"
        },
        "created_at": "2018-03-04T09:17:22.520Z",
        "updated_at": "2018-03-04T09:17:22.520Z",
        "system": false,
        "noteable_id": 3,
        "noteable_type": "Commit",
        "project_id": 5,
        "noteable_iid": null,
        "position": {
          "base_sha": "b5d6e7b1613fca24d250fa8e5bc7bcc3dd6002ef",
          "start_sha": "7c9c2ead8a320fb7ba0b4e234bd9529a2614e306",
          "head_sha": "4803c71e6b1833ca72b8b26ef2ecd5adc8a38031",
          "old_path": "package.json",
          "new_path": "package.json",
          "position_type": "text",
          "old_line": 27,
          "new_line": 27
        },
        "resolvable": false
      }
    ]
  }
]
```

<a id="retrieve-a-commit-discussion-item"></a>

### 获取单个提交讨论项

获取项目提交中的指定讨论项。

```plaintext
GET /projects/:id/repository/commits/:commit_id/discussions/:discussion_id
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|------|
| `commit_id`     | 字符串            | 是      | 提交的 SHA。 |
| `discussion_id` | 字符串            | 是      | 讨论项的 ID。 |
| `id`            | 整数或字符串      | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |

如果成功，将返回 [`200 OK`](rest/troubleshooting.md#status-codes)，响应属性与 [列出所有提交讨论项](#list-all-commit-discussion-items) 相同。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions/<discussion_id>"
```

<a id="create-a-commit-thread"></a>

### 创建提交讨论串

为单个项目提交创建新的讨论串。与创建评论类似，但之后可以向其中添加其他评论（回复）。

```plaintext
POST /projects/:id/repository/commits/:commit_id/discussions
```

支持的属性：

| 属性                       | 类型              | 是否必需                     | 描述 |
|---------------------------|-------------------|------------------------------|------|
| `body`                    | 字符串            | 是                          | 讨论串的内容。 |
| `commit_id`               | 字符串            | 是                          | 提交的 SHA。 |
| `id`                      | 整数或字符串      | 是                          | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `created_at`              | 字符串            | 否                          | ISO 8601 格式的日期时间字符串，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |
| `position`                | 哈希              | 否                          | 创建差异评论时的位置。 |
| `position[base_sha]`      | 字符串            | 是（如果提供了 `position*`） | 父提交的 SHA。 |
| `position[head_sha]`      | 字符串            | 是（如果提供了 `position*`） | 此提交的 SHA。与 `commit_id` 相同。 |
| `position[start_sha]`     | 字符串            | 是（如果提供了 `position*`） | 父提交的 SHA。 |
| `position[position_type]` | 字符串            | 是（如果提供了 `position*`） | 位置引用的类型。允许的值：`text`、`image` 或 `file`。`file` 类型在 极狐GitLab 16.4 中引入。 |
| `position[new_path]`      | 字符串            | 否                          | 更改后的文件路径。 |
| `position[new_line]`      | 整数              | 否                          | 更改后的行号。 |
| `position[old_path]`      | 字符串            | 否                          | 更改前的文件路径。 |
| `position[old_line]`      | 整数              | 否                          | 更改前的行号。 |
| `position[height]`        | 整数              | 否                          | 对于 `image` 差异评论，图像高度。 |
| `position[width]`         | 整数              | 否                          | 对于 `image` 差异评论，图像宽度。 |
| `position[x]`             | 整数              | 否                          | 对于 `image` 差异评论，X 坐标。 |
| `position[y]`             | 整数              | 否                          | 对于 `image` 差异评论，Y 坐标。 |

如果成功，将返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及创建的讨论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions?body=comment"
```

创建 API 请求的规则与 [在合并请求差异中创建新讨论串](#create-a-new-thread-in-the-merge-request-diff) 相同。
例外情况：

- `base_sha`
- `head_sha`
- `start_sha`

<a id="add-note-to-a-commit-thread"></a>

### 向提交讨论串添加评论

向讨论串添加新评论。

```plaintext
POST /projects/:id/repository/commits/:commit_id/discussions/:discussion_id/notes
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|------|
| `body`          | 字符串            | 是      | 评论或回复的内容。 |
| `commit_id`     | 字符串            | 是      | 提交的 SHA。 |
| `discussion_id` | 字符串            | 是      | 讨论串的 ID。 |
| `id`            | 整数或字符串      | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `created_at`    | 字符串            | 否      | ISO 8601 格式的日期时间字符串，例如 `2016-03-11T03:45:40Z`。需要管理员或项目/群组所有者权限。 |

如果成功，将返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及创建的评论对象。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions/<discussion_id>/notes?body=comment"
```

<a id="update-a-commit-thread-note"></a>

### 更新提交讨论串评论

更新或解决提交的指定讨论串评论。

```plaintext
PUT /projects/:id/repository/commits/:commit_id/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|------|
| `body`          | 字符串            | 否      | 评论的内容。 |
| `commit_id`     | 字符串            | 是      | 提交的 SHA。 |
| `discussion_id` | 字符串            | 是      | 讨论串的 ID。 |
| `id`            | 整数或字符串      | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `note_id`       | 整数              | 是      | 讨论串评论的 ID。 |

如果成功，将返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及更新后的评论对象。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions/<discussion_id>/notes/<note_id>?body=comment"
```

解决评论：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions/<discussion_id>/notes/<note_id>?resolved=true"
```

<a id="delete-a-commit-discussion-note"></a>

### 删除提交讨论串评论

删除提交中已有的讨论串评论。

```plaintext
DELETE /projects/:id/repository/commits/:commit_id/discussions/:discussion_id/notes/:note_id
```

支持的属性：

| 属性             | 类型              | 是否必需 | 描述 |
|-----------------|-------------------|----------|------|
| `commit_id`     | 字符串            | 是      | 提交的 SHA。 |
| `discussion_id` | 字符串            | 是      | 讨论串的 ID。 |
| `id`            | 整数或字符串      | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `note_id`       | 整数              | 是      | 讨论串评论的 ID。 |

如果成功，将返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/<commit_id>/discussions/<discussion_id>/notes/<note_id>"
```