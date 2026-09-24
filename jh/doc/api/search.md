---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 搜索 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可[跨极狐GitLab 搜索](../user/search/_index.md)。
每次调用此 API 都需要认证。

某些范围可用于[基础搜索](../user/search/_index.md#available-scopes)。
当 [高级搜索](../user/search/advanced_search.md#available-scopes) 或
[精确代码搜索](../user/search/exact_code_search.md#available-scopes) 启用时，
额外的范围可用于[全局搜索](#search-an-instance)、
[群组搜索](#search-a-group) 和 [项目搜索](#search-a-project) 操作。

如果你想使用基础搜索，请参阅
[指定搜索类型](../user/search/_index.md#specify-a-search-type)。

搜索 API 支持[基于偏移量的分页](rest/_index.md#offset-based-pagination)。

<a id="search-an-instance"></a>

## 搜索实例

在整个极狐GitLab 实例中搜索[关键词](../user/search/advanced_search.md#syntax)。
响应内容取决于请求的范围。

```plaintext
GET /search
```

| 属性 | 类型 | 是否必需 | 描述 |
|--------------------|------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `scope`            | string           | 是      | 要搜索的范围。可选值包括 `projects`、`issues`、`work_items`、`merge_requests`、`milestones`、`snippet_titles` 和 `users`。额外范围有 `wiki_blobs`、`commits`、`blobs` 和 `notes`。               |
| `search`           | string           | 是      | 搜索关键词。                                                                                                                                                                                               |
| `search_type`      | string           | 否       | 要使用的搜索类型。可选值包括 `basic`、`advanced` 和 `zoekt`。                                                                                                                                       |
| `confidential`     | boolean          | 否       | 按机密性过滤。支持 `issues` 和 `work_items` 范围；其他范围将被忽略。                                                                                                                                  |
| `exclude_forks`      | boolean          | 否       | 从搜索结果中排除派生项目。适用于精确代码搜索。如果未设置，默认会排除派生项目。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)于极狐GitLab 18.7。          |
| `regex`              | boolean          | 否       | 使用正则表达式搜索代码。适用于精确代码搜索。如果未设置，默认使用正则表达式。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/521686)于极狐GitLab 18.9。 |
| `fields`             | array of strings | 否       | 要搜索的字段数组，允许的值仅为 `title`。仅支持 `issues` 和 `merge_requests` 范围。仅专业版和旗舰版可用。                                                            |
| `include_archived`   | boolean          | 否       | 在搜索中包含已归档的项目。默认值为 `false`。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)于极狐GitLab 18.7。                                                           |
| `num_context_lines`  | integer          | 否       | 在结果中每个匹配项周围包含的上下文行数。仅适用于高级和精确代码搜索。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/583217)于极狐GitLab 18.11。 |
| `state`              | string           | 否       | 按状态过滤。支持 `issues`、`work_items` 和 `merge_requests` 范围；其他范围将被忽略。                                                                                                                      |
| `type`               | array of strings | 否       | 按工作项类型过滤。仅适用于 `work_items` 范围。可用类型：`issue`、`task`、`epic`、`incident`、`test_case`、`requirement`、`objective`、`key_result`、`ticket`。                          |
| `order_by`           | string           | 否       | 允许的值仅为 `created_at`。如果未设置，基础搜索的结果将按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                              |
| `sort`               | string           | 否       | 允许的值仅为 `asc` 或 `desc`。如果未设置，基础搜索的结果将按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                           |

<a id="scope-projects"></a>

### 范围：`projects`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=projects&search=flight"
```

示例响应：

```json
[
  {
    "id": 6,
    "description": "Nobis sed ipsam vero quod cupiditate veritatis hic.",
    "name": "Flight",
    "name_with_namespace": "Twitter / Flight",
    "path": "flight",
    "path_with_namespace": "twitter/flight",
    "created_at": "2017-09-05T07:58:01.621Z",
    "default_branch": "main",
    "tag_list":[], //已废弃，请使用 `topics` 代替
    "topics":[],
    "ssh_url_to_repo": "ssh://jarka@localhost:2222/twitter/flight.git",
    "http_url_to_repo": "http://localhost:3000/twitter/flight.git",
    "web_url": "http://localhost:3000/twitter/flight",
    "readme_url": "http://localhost:3000/twitter/flight/-/blob/main/README.md",
    "avatar_url": null,
    "star_count": 0,
    "forks_count": 0,
    "last_activity_at": "2018-01-31T09:56:30.902Z"
  }
]
```

<a id="scope-issues"></a>

### 范围：`issues`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=issues&search=file"
```

示例响应：

```json
[
  {
    "id": 83,
    "iid": 1,
    "project_id": 12,
    "title": "Add file",
    "description": "Add first file",
    "state": "opened",
    "created_at": "2018-01-24T06:02:15.514Z",
    "updated_at": "2018-02-06T12:36:23.263Z",
    "closed_at": null,
    "labels":[],
    "milestone": null,
    "assignees": [{
      "id": 20,
      "name": "Ceola Deckow",
      "username": "sammy.collier",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c23d85a4f50e0ea76ab739156c639231?s=80&d=identicon",
      "web_url": "http://localhost:3000/sammy.collier"
    }],
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "assignee": {
      "id": 20,
      "name": "Ceola Deckow",
      "username": "sammy.collier",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c23d85a4f50e0ea76ab739156c639231?s=80&d=identicon",
      "web_url": "http://localhost:3000/sammy.collier"
    },
    "user_notes_count": 0,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "discussion_locked": null,
    "web_url": "http://localhost:3000/h5bp/7bp/subgroup-prj/issues/1",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

> [!note]
> `assignee` 字段已废弃。它显示为单元素数组 `assignees` 以符合极狐GitLab EE API。

<a id="scope-workitems"></a>

### 范围：`work_items`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=work_items&search=migrate"
```

示例响应：

```json
[
  {
    "id": 142,
    "iid": 9,
    "project_id": 12,
    "title": "Migrate to new database",
    "description": "Database migration task",
    "state": "opened",
    "created_at": "2018-03-15T08:12:31.489Z",
    "updated_at": "2018-03-20T14:22:18.371Z",
    "closed_at": null,
    "labels": ["backend"],
    "milestone": null,
    "assignees": [{
      "id": 25,
      "name": "John Doe",
      "username": "john.doe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/a1b2c3d4e5f6g7h8i9j0?s=80&d=identicon",
      "web_url": "http://localhost:3000/john.doe"
    }],
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "type": "TASK",
    "user_notes_count": 2,
    "upvotes": 1,
    "downvotes": 0,
    "due_date": "2018-04-01",
    "confidential": false,
    "discussion_locked": null,
    "web_url": "http://localhost:3000/my-group/my-project/-/work_items/9",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

你可以使用 `type` 参数按工作项类型过滤：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=work_items&search=backend&type[]=task&type[]=issue"
```

<a id="scope-merge-requests"></a>

### 范围：`merge_requests`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=merge_requests&search=file"
```

示例响应：

```json
[
  {
    "id": 56,
    "iid": 8,
    "project_id": 6,
    "title": "Add first file",
    "description": "This is a test MR to add file",
    "state": "opened",
    "created_at": "2018-01-22T14:21:50.830Z",
    "updated_at": "2018-02-06T12:40:33.295Z",
    "target_branch": "main",
    "source_branch": "jaja-test",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "assignee": {
      "id": 5,
      "name": "Jacquelyn Kutch",
      "username": "abigail",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/3138c66095ee4bd11a508c2f7f7772da?s=80&d=identicon",
      "web_url": "http://localhost:3000/abigail"
    },
    "source_project_id": 6,
    "target_project_id": 6,
    "labels": [
      "ruby",
      "tests"
    ],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 13,
      "iid": 3,
      "project_id": 6,
      "title": "v2.0",
      "description": "Qui aut qui eos dolor beatae itaque tempore molestiae.",
      "state": "active",
      "created_at": "2017-09-05T07:58:29.099Z",
      "updated_at": "2017-09-05T07:58:29.099Z",
      "due_date": null,
      "start_date": null
    },
    "merge_when_pipeline_succeeds": false,
    "merge_status": "can_be_merged",
    "sha": "78765a2d5e0a43585945c58e61ba2f822e4d090b",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 0,
    "discussion_locked": null,
    "should_remove_source_branch": null,
    "force_remove_source_branch": true,
    "web_url": "http://localhost:3000/twitter/flight/merge_requests/8",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

<a id="scope-milestones"></a>

### 范围：`milestones`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=milestones&search=release"
```

示例响应：

```json
[
  {
    "id": 44,
    "iid": 1,
    "project_id": 12,
    "title": "next release",
    "description": "Next release milestone",
    "state": "active",
    "created_at": "2018-02-06T12:43:39.271Z",
    "updated_at": "2018-02-06T12:44:01.298Z",
    "due_date": "2018-04-18",
    "start_date": "2018-02-04"
  }
]
```

<a id="scope-snippet-titles"></a>

### 范围：`snippet_titles`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=snippet_titles&search=sample"
```

示例响应：

```json
[
  {
    "id": 50,
    "title": "Sample file",
    "file_name": "file.rb",
    "description": "Simple ruby file",
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "updated_at": "2018-02-06T12:49:29.104Z",
    "created_at": "2017-11-28T08:20:18.071Z",
    "project_id": 9,
    "web_url": "http://localhost:3000/root/jira-test/snippets/50"
  }
]
```

<a id="scope-users"></a>

### 范围：`users`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=users&search=doe"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "John Doe1",
    "username": "user1",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
    "web_url": "http://localhost/user1"
  }
]
```

<a id="scope-wiki-blobs"></a>

### 范围：`wiki_blobs`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

使用此范围搜索 Wiki。

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

以下过滤器可用于此范围：

- `filename`
- `path`
- `extension`

要使用过滤器，请将其包含在你的查询中（例如 `a query filename:some_name*`）。

你可以使用通配符 (`*`) 进行 glob 匹配。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=wiki_blobs&search=bye"
```

示例响应：

```json

[
  {
    "basename": "home",
    "data": "hello\n\nand bye\n\nend",
    "path": "home.md",
    "filename": "home.md",
    "id": null,
    "ref": "main",
    "startline": 5,
    "project_id": 6,
    "group_id": null
  }
]
```

> [!note]
> `filename` 已废弃，推荐使用 `path`。两者都返回仓库内文件的完整路径，但将来 `filename` 将只包含文件名而不包含完整路径。详情请参见 [issue 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。

<a id="scope-commits"></a>

### 范围：`commits`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=commits&search=bye"
```

示例响应：

```json

[
  {
  "id": "4109c2d872d5fdb1ed057400d103766aaea97f98",
  "short_id": "4109c2d8",
  "title": "goodbye $.browser",
  "created_at": "2013-02-18T22:02:54.000Z",
  "parent_ids": [
    "59d05353ab575bcc2aa958fe1782e93297de64c9"
  ],
  "message": "goodbye $.browser\n",
  "author_name": "angus croll",
  "author_email": "anguscroll@gmail.com",
  "authored_date": "2013-02-18T22:02:54.000Z",
  "committer_name": "angus croll",
  "committer_email": "anguscroll@gmail.com",
  "committed_date": "2013-02-18T22:02:54.000Z",
  "project_id": 6
  }
]
```

<a id="scope-blobs"></a>

### 范围：`blobs`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

使用此范围搜索代码。

此范围仅在启用[高级搜索](../user/search/advanced_search.md#use-advanced-search)
或[精确代码搜索](../user/search/exact_code_search.md#use-exact-code-search)时可用。

以下过滤器可用于此范围：

- `filename`
- `path`
- `extension`

要使用过滤器，请将其包含在你的查询中（例如 `a query filename:some_name*`）。

你可以使用通配符 (`*`) 进行 glob 匹配。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=blobs&search=installation"
```

示例响应：

```json

[
  {
    "basename": "README",
    "data": "```\n\n## Installation\n\nQuick start using the [pre-built",
    "path": "README.md",
    "filename": "README.md",
    "id": null,
    "ref": "main",
    "startline": 46,
    "project_id": 6
  }
]
```

> [!note]
> `filename` 已废弃，推荐使用 `path`。两者都返回仓库内文件的完整路径，但将来 `filename` 将只包含文件名而不包含完整路径。详情请参见 [issue 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。
> 在精确代码搜索中，Elasticsearch 语法可能无法正常工作。对于精确代码搜索，请将 Elasticsearch 通配符查询替换为正则表达式。更多信息，请参见 [issue 521686](https://gitlab.com/gitlab-org/gitlab/-/issues/521686)。

<a id="scope-notes"></a>

### 范围：`notes`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=notes&search=maxime"
```

示例响应：

```json
[
  {
    "id": 191,
    "body": "Harum maxime consequuntur et et deleniti assumenda facilis.",
    "attachment": null,
    "author": {
      "id": 23,
      "name": "User 1",
      "username": "user1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/111d68d06e2d317b5a59c2c6c5bad808?s=80&d=identicon",
      "web_url": "http://localhost:3000/user1"
    },
    "created_at": "2017-09-05T08:01:32.068Z",
    "updated_at": "2017-09-05T08:01:32.068Z",
    "system": false,
    "noteable_id": 22,
    "noteable_type": "Issue",
    "project_id": 6,
    "noteable_iid": 2
  }
]
```

<a id="search-a-group"></a>

## 搜索群组

在指定群组中搜索[关键词](../user/search/_index.md)。

如果用户不是某群组成员且该群组为私有，对该群组的 `GET` 请求将返回 `404 Not Found` 状态码。

```plaintext
GET /groups/:id/search
```

| 属性 | 类型 | 是否必需 | 描述 |
|--------------------|-------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`               | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                    |
| `scope`            | string            | 是      | 要搜索的范围。可选值包括 `projects`、`issues`、`work_items`、`merge_requests`、`milestones` 和 `users`。额外范围有 `wiki_blobs`、`commits`、`blobs` 和 `notes`。                                 |
| `search`           | string            | 是      | 搜索关键词。                                                                                                                                                                                               |
| `search_type`      | string            | 否       | 要使用的搜索类型。可选值包括 `basic`、`advanced` 和 `zoekt`。                                                                                                                                       |
| `confidential`     | boolean           | 否       | 按机密性过滤。支持 `issues` 和 `work_items` 范围；其他范围将被忽略。                                                                                                                                  |
| `exclude_forks`      | boolean           | 否       | 从搜索结果中排除派生项目。适用于精确代码搜索。如果未设置，默认会排除派生项目。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)于极狐GitLab 18.7。          |
| `regex`              | boolean           | 否       | 使用正则表达式搜索代码。适用于精确代码搜索。如果未设置，默认使用正则表达式。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/521686)于极狐GitLab 18.9。 |
| `fields`             | array of strings  | 否       | 要搜索的字段数组，允许的值仅为 `title`。仅支持 `issues` 和 `merge_requests` 范围。仅专业版和旗舰版可用。                                                            |
| `include_archived`   | boolean           | 否       | 在搜索中包含已归档的项目。默认值为 `false`。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)于极狐GitLab 18.7。                                                           |
| `num_context_lines`  | integer           | 否       | 在结果中每个匹配项周围包含的上下文行数。仅适用于高级和精确代码搜索。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/583217)于极狐GitLab 18.11。 |
| `state`              | string            | 否       | 按状态过滤。支持 `issues`、`work_items` 和 `merge_requests` 范围；其他范围将被忽略。                                                                                                                      |
| `type`               | array of strings  | 否       | 按工作项类型过滤。仅适用于 `work_items` 范围。可用类型：`issue`、`task`、`epic`、`incident`、`test_case`、`requirement`、`objective`、`key_result`、`ticket`。                          |
| `order_by`           | string            | 否       | 允许的值仅为 `created_at`。如果未设置，基础搜索的结果将按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                              |
| `sort`               | string            | 否       | 允许的值仅为 `asc` 或 `desc`。如果未设置，基础搜索的结果将按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                           |

响应内容取决于请求的范围。

<a id="scope-projects-1"></a>

### 范围：`projects`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=projects&search=flight"
```

示例响应：

```json
[
  {
    "id": 6,
    "description": "Nobis sed ipsam vero quod cupiditate veritatis hic.",
    "name": "Flight",
    "name_with_namespace": "Twitter / Flight",
    "path": "flight",
    "path_with_namespace": "twitter/flight",
    "created_at": "2017-09-05T07:58:01.621Z",
    "default_branch": "main",
    "tag_list":[], //已废弃，请使用 `topics` 代替
    "topics":[],
    "ssh_url_to_repo": "ssh://jarka@localhost:2222/twitter/flight.git",
    "http_url_to_repo": "http://localhost:3000/twitter/flight.git",
    "web_url": "http://localhost:3000/twitter/flight",
    "readme_url": "http://localhost:3000/twitter/flight/-/blob/main/README.md",
    "avatar_url": null,
    "star_count": 0,
    "forks_count": 0,
    "last_activity_at": "2018-01-31T09:56:30.902Z"
  }
]
```

<a id="scope-issues-1"></a>

### 范围：`issues`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=issues&search=file"
```

示例响应：
在指定项目中搜索[关键词](../user/search/_index.md)。

如果用户不是项目的成员且项目为私有，对该项目的 `GET` 请求将返回 `404` 状态码。

```plaintext
GET /projects/:id/search
```

| 属性 | 类型 | 是否必需 | 描述 |
|----------------|-------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id` | integer 或 string | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `scope` | string | 是 | 搜索范围，可选值包括 `issues`、`work_items`、`merge_requests`、`milestones` 和 `users`。额外范围包括 `wiki_blobs`、`commits`、`blobs` 和 `notes`。 |
| `search` | string | 是 | 搜索词。 |
| `search_type` | string | 否 | 搜索类型，可选值包括 `basic`、`advanced` 和 `zoekt`。 |
| `confidential` | boolean | 否 | 按机密性过滤。支持 `issues` 和 `work_items` 范围，其他范围将被忽略。 |
| `regex` | boolean | 否 | 使用正则表达式搜索代码。适用于精确代码搜索。若未设置，默认使用正则表达式。在极狐GitLab 18.9 引入。 |
| `fields` | string 数组 | 否 | 希望搜索的字段数组，仅允许 `title`。仅支持 `issues` 和 `merge_requests` 范围。仅限专业版和旗舰版。 |
| `num_context_lines` | integer | 否 | 每个匹配结果前后包含的上下文行数。仅适用于高级搜索和精确代码搜索。在极狐GitLab 18.11 引入。 |
| `ref` | string | 否 | 仓库分支或标签名称，用于指定搜索的引用。默认使用项目的默认分支。仅适用于 `blobs`、`commits` 和 `wiki_blobs` 范围。 |
| `state` | string | 否 | 按状态过滤。支持 `issues`、`work_items` 和 `merge_requests` 范围，其他范围将被忽略。 |
| `type` | string 数组 | 否 | 按类型过滤工作项。仅适用于 `work_items` 范围。可用类型：`issue`、`task`、`epic`、`incident`、`test_case`、`requirement`、`objective`、`key_result`、`ticket`。 |
| `order_by` | string | 否 | 仅允许 `created_at`。若未设置，基本搜索的结果按 `created_at` 降序排序，高级搜索按最相关文档排序。 |
| `sort` | string | 否 | 仅允许 `asc` 或 `desc`。若未设置，基本搜索的结果按 `created_at` 降序排序，高级搜索按最相关文档排序。 |

响应内容取决于所请求的 scope。

<a id="scope-issues"></a>

### Scope：`issues`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/12/search?scope=issues&search=file"
```

示例响应：

```json
[
  {
    "id": 83,
    "iid": 1,
    "project_id": 12,
    "title": "Add file",
    "description": "Add first file",
    "state": "opened",
    "created_at": "2018-01-24T06:02:15.514Z",
    "updated_at": "2018-02-06T12:36:23.263Z",
    "closed_at": null,
    "labels":[],
    "milestone": null,
    "assignees": [{
      "id": 20,
      "name": "Ceola Deckow",
      "username": "sammy.collier",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c23d85a4f50e0ea76ab739156c639231?s=80&d=identicon",
      "web_url": "http://localhost:3000/sammy.collier"
    }],
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "assignee": {
      "id": 20,
      "name": "Ceola Deckow",
      "username": "sammy.collier",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c23d85a4f50e0ea76ab739156c639231?s=80&d=identicon",
      "web_url": "http://localhost:3000/sammy.collier"
    },
    "user_notes_count": 0,
    "upvotes": 0,
    "downvotes": 0,
    "due_date": null,
    "confidential": false,
    "discussion_locked": null,
    "web_url": "http://localhost:3000/h5bp/7bp/subgroup-prj/issues/1",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

> [!note]
> `assignee` 列已弃用。现为单个 `assignees` 数组。

<a id="scope-work_items"></a>

### Scope：`work_items`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/12/search?scope=work_items&search=migrate"
```

示例响应：

```json
[
  {
    "id": 142,
    "iid": 9,
    "project_id": 12,
    "title": "Migrate to new database",
    "description": "Database migration task",
    "state": "opened",
    "created_at": "2018-03-15T08:12:31.489Z",
    "updated_at": "2018-03-20T14:22:18.371Z",
    "closed_at": null,
    "labels": ["backend"],
    "milestone": null,
    "assignees": [{
      "id": 25,
      "name": "John Doe",
      "username": "john.doe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/a1b2c3d4e5f6g7h8i9j0?s=80&d=identicon",
      "web_url": "http://localhost:3000/john.doe"
    }],
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "type": "TASK",
    "user_notes_count": 2,
    "upvotes": 1,
    "downvotes": 0,
    "due_date": "2018-04-01",
    "confidential": false,
    "discussion_locked": null,
    "web_url": "http://localhost:3000/my-group/my-project/-/work_items/9",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

你可以使用 `type` 参数按类型过滤工作项：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/12/search?scope=work_items&search=backend&type[]=task&type[]=issue"
```

<a id="scope-merge_requests"></a>

### Scope：`merge_requests`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=merge_requests&search=file"
```

示例响应：

```json
[
  {
    "id": 56,
    "iid": 8,
    "project_id": 6,
    "title": "Add first file",
    "description": "This is a test MR to add file",
    "state": "opened",
    "created_at": "2018-01-22T14:21:50.830Z",
    "updated_at": "2018-02-06T12:40:33.295Z",
    "target_branch": "main",
    "source_branch": "jaja-test",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://localhost:3000/root"
    },
    "assignee": {
      "id": 5,
      "name": "Jacquelyn Kutch",
      "username": "abigail",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/3138c66095ee4bd11a508c2f7f7772da?s=80&d=identicon",
      "web_url": "http://localhost:3000/abigail"
    },
    "source_project_id": 6,
    "target_project_id": 6,
    "labels": [
      "ruby",
      "tests"
    ],
    "draft": false,
    "work_in_progress": false,
    "milestone": {
      "id": 13,
      "iid": 3,
      "project_id": 6,
      "title": "v2.0",
      "description": "Qui aut qui eos dolor beatae itaque tempore molestiae.",
      "state": "active",
      "created_at": "2017-09-05T07:58:29.099Z",
      "updated_at": "2017-09-05T07:58:29.099Z",
      "due_date": null,
      "start_date": null
    },
    "merge_when_pipeline_succeeds": false,
    "merge_status": "can_be_merged",
    "sha": "78765a2d5e0a43585945c58e61ba2f822e4d090b",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 0,
    "discussion_locked": null,
    "should_remove_source_branch": null,
    "force_remove_source_branch": true,
    "web_url": "http://localhost:3000/twitter/flight/merge_requests/8",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

<a id="scope-milestones"></a>

### Scope：`milestones`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/12/search?scope=milestones&search=release"
```

示例响应：

```json
[
  {
    "id": 44,
    "iid": 1,
    "project_id": 12,
    "title": "next release",
    "description": "Next release milestone",
    "state": "active",
    "created_at": "2018-02-06T12:43:39.271Z",
    "updated_at": "2018-02-06T12:44:01.298Z",
    "due_date": "2018-04-18",
    "start_date": "2018-02-04"
  }
]
```

<a id="scope-users"></a>

### Scope：`users`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=users&search=doe"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "John Doe1",
    "username": "user1",
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/c922747a93b40d1ea88262bf1aebee62?s=80&d=identicon",
    "web_url": "http://localhost/user1"
  }
]
```

<a id="scope-wiki_blobs"></a>

### Scope：`wiki_blobs`

使用此范围搜索 Wiki。

此范围支持以下过滤器：

- `filename`
- `path`
- `extension`

要使用过滤器，请将其包含在查询中（例如，`a query filename:some_name*`）。

你可以使用通配符 (`*`) 进行 glob 匹配。

Wiki blob 搜索会同时在文件名和内容中执行。搜索结果：

- 在文件名中找到的结果会显示在内容结果之前。
- 同一 blob 可能包含多个匹配项，因为搜索字符串可能同时出现在文件名和内容中，或者可能在内容中多次出现。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=wiki_blobs&search=bye"
```

示例响应：

```json
[
  {
    "basename": "home",
    "data": "hello\n\nand bye\n\nend",
    "path": "home.md",
    "filename": "home.md",
    "id": null,
    "ref": "main",
    "startline": 5,
    "project_id": 6,
    "group_id": 1
  }
]
```

> [!note]
> `filename` 已弃用，建议使用 `path`。两者都会返回文件在仓库中的完整路径，但将来 `filename` 旨在仅表示文件名而非完整路径。详情请参见 issue 34521。

<a id="scope-commits"></a>

### Scope：`commits`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=commits&search=bye"
```

示例响应：

```json
[
  {
    "id": "4109c2d872d5fdb1ed057400d103766aaea97f98",
    "short_id": "4109c2d8",
    "title": "goodbye $.browser",
    "created_at": "2013-02-18T22:02:54.000Z",
    "parent_ids": [
      "59d05353ab575bcc2aa958fe1782e93297de64c9"
    ],
    "message": "goodbye $.browser\n",
    "author_name": "angus croll",
    "author_email": "anguscroll@gmail.com",
    "authored_date": "2013-02-18T22:02:54.000Z",
    "committer_name": "angus croll",
    "committer_email": "anguscroll@gmail.com",
    "committed_date": "2013-02-18T22:02:54.000Z",
    "project_id": 6
  }
]
```

<a id="scope-blobs"></a>

### Scope：`blobs`

使用此范围搜索代码。

此范围支持以下过滤器：

- `filename`
- `path`
- `extension`

要使用过滤器，请将其包含在查询中（例如，`a query filename:some_name*`）。

你可以使用通配符 (`*`) 进行 glob 匹配。

Blob 搜索会同时在文件名和内容中执行。搜索结果：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=blobs&search=installation"
```

示例响应：

```json
[
  {
    "basename": "README",
    "data": "```\n\n## Installation\n\nQuick start using the [pre-built",
    "path": "README.md",
    "filename": "README.md",
    "id": null,
    "ref": "main",
    "startline": 46,
    "project_id": 6
  }
]
```

> [!note]
> `filename` 已弃用，建议使用 `path`。两者都会返回文件在仓库中的完整路径，但将来 `filename` 旨在仅表示文件名而非完整路径。详情请参见 issue 34521。
> Elasticsearch 语法可能与精确代码搜索不兼容。对于精确代码搜索，请将 Elasticsearch 通配符查询替换为正则表达式。更多信息，请参见 issue 521686。
- 在文件名中找到的匹配项会先于在内容中找到的结果显示。
- 由于搜索字符串可能在文件名和内容中都出现，或可能在内容中出现多次，同一个 blob 可能包含多个匹配项。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=blobs&search=keyword%20filename:*.py"
```

示例响应：

```json
[
  {
    "basename": "README",
    "data": "```\n\n## 安装\n\n快速开始使用 [pre-built",
    "path": "README.md",
    "filename": "README.md",
    "id": null,
    "ref": "main",
    "startline": 46,
    "project_id": 6
  }
]
```

> [!note]
> `filename` 已弃用，改为 `path`。两者都返回仓库中文件的完整路径，但在未来 `filename` 将仅指文件名而不是完整路径。详情参见 议题 34521。
> Elasticsearch 语法可能无法正常用于精确代码搜索。对于精确代码搜索，请用正则表达式替换 Elasticsearch 通配符查询。更多信息参见 议题 521686。

### Scope: `notes`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/6/search?scope=notes&search=maxime"
```

示例响应：

```json
[
  {
    "id": 191,
    "body": "Harum maxime consequuntur et et deleniti assumenda facilis.",
    "attachment": null,
    "author": {
      "id": 23,
      "name": "User 1",
      "username": "user1",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/111d68d06e2d317b5a59c2c6c5bad808?s=80&d=identicon",
      "web_url": "http://localhost:3000/user1"
    },
    "created_at": "2017-09-05T08:01:32.068Z",
    "updated_at": "2017-09-05T08:01:32.068Z",
    "system": false,
    "noteable_id": 22,
    "noteable_type": "Issue",
    "project_id": 6,
    "noteable_iid": 2
  }
]
```