---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for issue links in 极狐GitLab.
title: 议题链接 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 简单的“关联”关系在 13.4 版本中移至极狐GitLab 基础版。

{{< /history >}}

使用此 API 管理[议题链接](../user/project/issues/related_issues.md)。

<a id="list-all-issue-links"></a>

列出所有议题链接

列出指定议题的所有[关联议题](../user/project/issues/related_issues.md)，按关系创建时间升序排序。议题根据用户授权进行过滤。

```plaintext
GET /projects/:id/issues/:issue_iid/links
```

参数：

| 属性   | 类型    | 是否必需 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | integer 或 string | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)  |
| `issue_iid` | integer | 是      | 项目议题的内部 ID |

```json
[
  {
    "id" : 84,
    "iid" : 14,
    "issue_link_id": 1,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/14",
    "confidential": false,
    "weight": null,
    "link_type": "relates_to",
    "link_created_at": "2016-01-07T12:44:33.959Z",
    "link_updated_at": "2016-01-07T12:44:33.959Z"
  }
]
```

<a id="retrieve-an-issue-link"></a>

获取议题链接

{{< history >}}

- 在极狐GitLab 15.1 中引入。
- `id` 响应属性在极狐GitLab 18.9 中引入。

{{< /history >}}

获取指定议题链接的详细信息。

```plaintext
GET /projects/:id/issues/:issue_iid/links/:issue_link_id
```

支持的属性：

| 属性       | 类型           | 是否必需               | 描述                                                                 |
|-----------------|----------------|------------------------|-----------------------------------------------------------------------------|
| `id`            | integer 或 string | 是 | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `issue_iid`     | integer        | 是 | 项目议题的内部 ID。                                           |
| `issue_link_id` | integer 或 string | 是 | 议题关系的 ID。                                                |

响应体属性：

| 属性      | 类型   | 描述                                                                               |
|:---------------|:-------|:------------------------------------------------------------------------------------------|
| `id`           | integer | 议题链接的 ID。                                                                     |
| `source_issue` | object | 关系的源议题详细信息。                                          |
| `target_issue` | object | 关系的目标议题详细信息。                                          |
| `link_type`    | string | 关系类型。可能的值为 `relates_to`、`blocks` 和 `is_blocked_by`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/84/issues/14/links/1"
```

示例响应：

```json
{
  "id": 1,
  "source_issue" : {
    "id" : 83,
    "iid" : 11,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "subscribed" : true,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/11",
    "confidential": false,
    "weight": null
  },
  "target_issue" : {
    "id" : 84,
    "iid" : 14,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "subscribed" : true,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/14",
    "confidential": false,
    "weight": null
  },
  "link_type": "relates_to"
}
```

<a id="create-an-issue-link"></a>

创建议题链接

{{< history >}}

- `id` 响应属性在极狐GitLab 18.9 中引入。

{{< /history >}}

在两个议题之间创建双向关系。用户必须有权更新两个议题才能成功。

```plaintext
POST /projects/:id/issues/:issue_iid/links
```

| 属性           | 类型           | 是否必需 | 描述                          |
|---------------------|----------------|----------|--------------------------------------|
| `id`                | integer 或 string | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `issue_iid`         | integer        | 是      | 项目议题的内部 ID |
| `target_project_id` | integer 或 string | 是      | 目标项目的 ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)  |
| `target_issue_iid`  | integer 或 string | 是      | 目标项目议题的内部 ID |
| `link_type`         | string         | 否       | 关系类型（`relates_to`、`blocks`、`is_blocked_by`），默认为 `relates_to`）。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/4/issues/1/links?target_project_id=5&target_issue_iid=1"
```

示例响应：

```json
{
  "id": 1,
  "source_issue" : {
    "id" : 83,
    "iid" : 11,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "subscribed" : true,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/11",
    "confidential": false,
    "weight": null
  },
  "target_issue" : {
    "id" : 84,
    "iid" : 14,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "subscribed" : true,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/14",
    "confidential": false,
    "weight": null
  },
  "link_type": "relates_to"
}
```

<a id="delete-an-issue-link"></a>

删除议题链接

{{< history >}}

- `id` 响应属性在极狐GitLab 18.9 中引入。

{{< /history >}}

删除指定的议题链接，移除双向关系。

```plaintext
DELETE /projects/:id/issues/:issue_iid/links/:issue_link_id
```

| 属性   | 类型    | 是否必需 | 描述                          |
|-------------|---------|----------|--------------------------------------|
| `id`        | integer 或 string | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)  |
| `issue_iid` | integer | 是      | 项目议题的内部 ID |
| `issue_link_id` | integer 或 string | 是      | 议题关系的 ID |
| `link_type` | string  | 否 | 关系类型（`relates_to`、`blocks`、`is_blocked_by`），默认为 `relates_to` |

```json
{
  "id": 1,
  "source_issue" : {
    "id" : 83,
    "iid" : 11,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "subscribed" : true,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/11",
    "confidential": false,
    "weight": null
  },
  "target_issue" : {
    "id" : 84,
    "iid" : 14,
    "project_id" : 4,
    "created_at" : "2016-01-07T12:44:33.959Z",
    "title" : "Issues with auth",
    "state" : "opened",
    "assignees" : [],
    "assignee" : null,
    "labels" : [
      "bug"
    ],
    "author" : {
      "name" : "Alexandra Bashirian",
      "avatar_url" : null,
      "state" : "active",
      "web_url" : "https://gitlab.example.com/eileen.lowe",
      "id" : 18,
      "username" : "eileen.lowe"
    },
    "description" : null,
    "updated_at" : "2016-01-07T12:44:33.959Z",
    "milestone" : null,
    "subscribed" : true,
    "user_notes_count": 0,
    "due_date": null,
    "web_url": "http://example.com/example/example/issues/14",
    "confidential": false,
    "weight": null
  },
  "link_type": "relates_to"
}
```