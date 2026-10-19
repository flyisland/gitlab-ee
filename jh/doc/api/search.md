---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 搜索 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可以[在极狐GitLab 中进行搜索](../user/search/_index.md)。每次调用此 API 都需要认证。

部分范围适用于[基础搜索](../user/search/_index.md#available-scopes)。当启用[高级搜索](../user/search/advanced_search.md#available-scopes)或[精确代码搜索](../user/search/exact_code_search.md#available-scopes)时，[全局搜索](#search-an-instance)、[群组搜索](#search-a-group)和[项目搜索](#search-a-project)操作会提供额外的范围。

如果您想改用基础搜索，请参阅[指定搜索类型](../user/search/_index.md#specify-a-search-type)。

搜索 API 支持[基于偏移量的分页](rest/_index.md#offset-based-pagination)。

使用高级搜索时，最多可以检索 10,000 条结果（`page` 乘以 `per_page`）。超过该限制的请求会返回一个没有 `next` 链接的空页面，因此客户端会一直分页直到收到空响应，并在达到该限制时停止。基础搜索和精确代码
搜索不受影响。在 Elasticsearch 集群上提高 `index.max_result_window`
不会提高该限制，因为极狐GitLab 不会读取该设置。

<a id="search-an-instance"></a>

## 搜索实例

在整个极狐GitLab 实例中搜索某个[词条](../user/search/advanced_search.md#syntax)。响应取决于所请求的范围。

```plaintext
GET /search
```

| 属性          | 类型             | 是否必需 | 描述                                                                                                                                                                                                    |
|--------------------|------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `scope`            | string           | 是      | 要搜索的范围。取值包括 `projects`、`groups`、`issues`、`work_items`、`merge_requests`、`milestones`、`snippet_titles` 和 `users`。其他范围包括 `wiki_blobs`、`commits`、`blobs` 和 `notes`。               |
| `search`           | string           | 是      | 搜索词条。                                                                                                                                                                                               |
| `search_type`      | string           | 否       | 要使用的搜索类型。取值包括 `basic`、`advanced` 和 `zoekt`。                                                                                                                                       |
| `confidential`     | boolean          | 否       | 按机密性筛选。支持 `issues` 和 `work_items` 范围；其他范围会被忽略。                                                                                                                                  |
| `exclude_forks`      | boolean          | 否       | 从搜索中排除 forked 项目。适用于精确代码搜索。如果未设置，forks 将被排除。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)极狐GitLab 18.7。          |
| `regex`              | boolean          | 否       | 使用正则表达式搜索代码。适用于精确代码搜索。如果未设置，则使用正则表达式。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/521686)极狐GitLab 18.9。 |
| `fields`             | array of strings | 否       | 您希望搜索的字段数组，允许的值只有 `title`。仅支持 `issues` 和 `merge_requests` 范围。仅限专业版和旗舰版。                                                            |
| `include_archived`   | boolean          | 否       | 在搜索中包含已归档项目。默认为 `false`。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)极狐GitLab 18.7。                                                           |
| `num_context_lines`  | integer          | 否       | 结果中每个匹配项周围要包含的上下文行数。仅适用于高级搜索和精确代码搜索。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/583217)极狐GitLab 18.11。 |
| `state`              | string           | 否       | 按状态筛选。支持 `issues`、`work_items` 和 `merge_requests` 范围；其他范围会被忽略。                                                                                                                      |
| `type`               | array of strings | 否       | 按类型筛选工作项。仅适用于 `work_items` 范围。可用类型：`issue`、`task`、`epic`、`incident`、`test_case`、`requirement`、`objective`、`key_result`、`ticket`。                          |
| `order_by`           | string           | 否       | 允许的值是 `created_at` 和 `title`。使用基础搜索时，可以按 `title` 对 `issues`、`work_items` 和 `merge_requests` 范围排序；使用高级搜索时，可以对 `issues` 和 `work_items` 范围排序。在高级搜索的标题排序回填完成之前，高级搜索对 `order_by=title`的响应会按 `created_at` 降序返回结果。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/565410)极狐GitLab 19.5。如果未设置，基础搜索的结果按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                              |
| `sort`               | string           | 否       | 允许的值只有 `asc` 或 `desc`。如果未设置，基础搜索的结果按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                           |
| `author_username`    | string           | 否       | 按作者用户名筛选。不匹配任何用户的用户名会被忽略。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `label_name`         | array of strings | 否       | 按标记名称筛选。结果必须带有每个能解析为现有标记的名称；不匹配任何标记的名称会被忽略。最多 30 个名称。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[author_username]` | string           | 否       | 排除由此用户名创作的结果。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[source_branch]` | string           | 否       | 排除具有此源分支的合并请求。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[target_branch]` | string           | 否       | 排除具有此目标分支的合并请求。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `source_branch`      | string           | 否       | 按源分支筛选合并请求。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `target_branch`      | string           | 否       | 按目标分支筛选合并请求。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |

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
    "tag_list":[], //deprecated, use `topics` instead
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

<a id="scope-groups"></a>

### 范围：`groups`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=groups&search=flight"
```

示例响应：

```json
[
  {
    "id": 3,
    "web_url": "http://localhost:3000/groups/flightjs",
    "name": "Flightjs"
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
> `assignee` 列已弃用。它现在显示为单元素数组 `assignees`，以符合极狐GitLab 企业版 API。

<a id="scope-work_items"></a>

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

您可以使用 `type` 参数按类型筛选工作项：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/search?scope=work_items&search=backend&type[]=task&type[]=issue"
```

<a id="scope-merge_requests"></a>

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

<a id="scope-snippet_titles"></a>

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

<a id="scope-wiki_blobs"></a>

### 范围：`wiki_blobs`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

使用此范围搜索 Wiki。

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

此范围提供以下筛选条件：

- `filename`
- `path`
- `extension`

要使用筛选条件，请将其包含在查询中（例如，`a query filename:some_name*`）。

您可以使用通配符（`*`）进行 glob 匹配。

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
> `filename` 已弃用，建议改用 `path`。两者都会返回文件在代码仓库中的完整路径，但未来 `filename` 将只表示文件名，而不是完整路径。有关详细信息，请参阅[议题 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。

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

此范围仅在启用[高级搜索](../user/search/advanced_search.md#use-advanced-search)或[精确代码搜索](../user/search/exact_code_search.md#use-exact-code-search)时可用。

此范围提供以下筛选条件：

- `filename`
- `path`
- `extension`

要使用筛选条件，请将其包含在查询中（例如，`a query filename:some_name*`）。

您可以使用通配符（`*`）进行 glob 匹配。

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
> `filename` 已弃用，建议改用 `path`。两者都会返回文件在代码仓库中的完整路径，但未来 `filename` 将只表示文件名，而不是完整路径。有关详细信息，请参阅[议题 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。
> Elasticsearch 语法在精确代码搜索中可能无法正常工作。对于精确代码搜索，请将 Elasticsearch 通配符查询替换为正则表达式。有关更多信息，请参阅[议题 521686](https://gitlab.com/gitlab-org/gitlab/-/issues/521686)。

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

在指定群组中搜索某个[词条](../user/search/_index.md)。

如果用户不是群组成员且该群组是私有的，则对该群组的 `GET` 请求会返回 `404 Not Found` 状态码。

```plaintext
GET /groups/:id/search
```

| 属性          | 类型              | 是否必需 | 描述                                                                                                                                                                                                    |
|--------------------|-------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`               | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                    |
| `scope`            | string            | 是      | 要搜索的范围。取值包括 `projects`、`groups`、`issues`、`work_items`、`merge_requests`、`milestones` 和 `users`。其他范围包括 `wiki_blobs`、`commits`、`blobs` 和 `notes`。                                 |
| `search`           | string            | 是      | 搜索词条。                                                                                                                                                                                               |
| `search_type`      | string            | 否       | 要使用的搜索类型。取值包括 `basic`、`advanced` 和 `zoekt`。                                                                                                                                       |
| `confidential`     | boolean           | 否       | 按机密性筛选。支持 `issues` 和 `work_items` 范围；其他范围会被忽略。                                                                                                                                  |
| `exclude_forks`      | boolean           | 否       | 从搜索中排除 forked 项目。适用于精确代码搜索。如果未设置，forks 将被排除。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)极狐GitLab 18.7。          |
| `regex`              | boolean           | 否       | 使用正则表达式搜索代码。适用于精确代码搜索。如果未设置，则使用正则表达式。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/521686)极狐GitLab 18.9。 |
| `fields`             | array of strings  | 否       | 您希望搜索的字段数组，允许的值只有 `title`。仅支持 `issues` 和 `merge_requests` 范围。仅限专业版和旗舰版。                                                            |
| `include_archived`   | boolean           | 否       | 在搜索中包含已归档项目。默认为 `false`。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/493281)极狐GitLab 18.7。                                                           |
| `num_context_lines`  | integer           | 否       | 结果中每个匹配项周围要包含的上下文行数。仅适用于高级搜索和精确代码搜索。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/583217)极狐GitLab 18.11。 |
| `state`              | string            | 否       | 按状态筛选。支持 `issues`、`work_items` 和 `merge_requests` 范围；其他范围会被忽略。                                                                                                                      |
| `type`               | array of strings  | 否       | 按类型筛选工作项。仅适用于 `work_items` 范围。可用类型：`issue`、`task`、`epic`、`incident`、`test_case`、`requirement`、`objective`、`key_result`、`ticket`。                          |
| `order_by`           | string            | 否       | 允许的值是 `created_at` 和 `title`。使用基础搜索时，可以按 `title` 对 `issues`、`work_items` 和 `merge_requests` 范围排序；使用高级搜索时，可以对 `issues` 和 `work_items` 范围排序。在高级搜索的标题排序回填完成之前，高级搜索对 `order_by=title`的响应会按 `created_at` 降序返回结果。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/565410)极狐GitLab 19.5。如果未设置，基础搜索的结果按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                              |
| `sort`               | string            | 否       | 允许的值只有 `asc` 或 `desc`。如果未设置，基础搜索的结果按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                           |
| `author_username`    | string            | 否       | 按作者用户名筛选。不匹配任何用户的用户名会被忽略。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `label_name`         | array of strings  | 否       | 按标记名称筛选。结果必须带有每个能解析为现有标记的名称；不匹配任何标记的名称会被忽略。最多 30 个名称。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[author_username]` | string            | 否       | 排除由此用户名创作的结果。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[source_branch]` | string            | 否       | 排除具有此源分支的合并请求。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[target_branch]` | string            | 否       | 排除具有此目标分支的合并请求。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `source_branch`      | string            | 否       | 按源分支筛选合并请求。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `target_branch`      | string            | 否       | 按目标分支筛选合并请求。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |

响应取决于所请求的范围。

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
    "tag_list":[], //deprecated, use `topics` instead
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

<a id="scope-groups-1"></a>

### 范围：`groups`

此范围返回指定群组的子群组，而不是群组本身。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=groups&search=flight"
```

示例响应：

```json
[
  {
    "id": 8,
    "web_url": "http://localhost:3000/groups/flightjs/flight-crew",
    "name": "Flight Crew"
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
> `assignee` 列已弃用。它现在是单元素 `assignees` 数组。

<a id="scope-work_items-1"></a>

### 范围：`work_items`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=work_items&search=migrate"
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

您可以使用 `type` 参数按类型筛选工作项：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=work_items&search=backend&type[]=task&type[]=issue"
```

<a id="scope-merge_requests-1"></a>

### 范围：`merge_requests`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=merge_requests&search=file"
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

<a id="scope-milestones-1"></a>

### 范围：`milestones`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=milestones&search=release"
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

<a id="scope-users-1"></a>

### 范围：`users`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/3/search?scope=users&search=doe"
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

<a id="scope-wiki_blobs-1"></a>

### 范围：`wiki_blobs`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

使用此范围搜索 Wiki。

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

此范围提供以下筛选条件：

- `filename`
- `path`
- `extension`

要使用筛选条件，请将其包含在查询中（例如，`a query filename:some_name*`）。

您可以使用通配符（`*`）进行 glob 匹配。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/6/search?scope=wiki_blobs&search=bye"
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
> `filename` 已弃用，建议改用 `path`。两者都会返回文件在代码仓库中的完整路径，但未来 `filename` 将只表示文件名，而不是完整路径。有关详细信息，请参阅[议题 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。

<a id="scope-commits-1"></a>

### 范围：`commits`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/6/search?scope=commits&search=bye"
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

<a id="scope-blobs-1"></a>

### 范围：`blobs`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

使用此范围搜索代码。

此范围仅在启用[高级搜索](../user/search/advanced_search.md#use-advanced-search)或[精确代码搜索](../user/search/exact_code_search.md#use-exact-code-search)时可用。

此范围提供以下筛选条件：

- `filename`
- `path`
- `extension`

要使用筛选条件，请将其包含在查询中（例如，`a query filename:some_name*`）。

您可以使用通配符（`*`）进行 glob 匹配。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/6/search?scope=blobs&search=installation"
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
> `filename` 已弃用，建议改用 `path`。两者都会返回文件在代码仓库中的完整路径，但未来 `filename` 将只表示文件名，而不是完整路径。有关详细信息，请参阅[议题 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。
> Elasticsearch 语法在精确代码搜索中可能无法正常工作。对于精确代码搜索，请将 Elasticsearch 通配符查询替换为正则表达式。有关更多信息，请参阅[议题 521686](https://gitlab.com/gitlab-org/gitlab/-/issues/521686)。

<a id="scope-notes-1"></a>

### 范围：`notes`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

此范围仅在[启用高级搜索](../user/search/advanced_search.md#use-advanced-search)时可用。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/6/search?scope=notes&search=maxime"
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

<a id="search-a-project"></a>

## 搜索项目

在指定项目中搜索某个[词条](../user/search/_index.md)。

如果用户不是项目成员且该项目是私有的，则对该项目的 `GET` 请求会返回 `404` 状态码。

```plaintext
GET /projects/:id/search
```

| 属性      | 类型              | 是否必需 | 描述                                                                                                                                                                                                    |
|----------------|-------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`                 | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                  |
| `scope`              | string            | 是      | 要搜索的范围。取值包括 `issues`、`work_items`、`merge_requests`、`milestones` 和 `users`。其他范围包括 `wiki_blobs`、`commits`、`blobs` 和 `notes`。                                             |
| `search`             | string            | 是      | 搜索词条。                                                                                                                                                                                               |
| `search_type`        | string            | 否       | 要使用的搜索类型。取值包括 `basic`、`advanced` 和 `zoekt`。                                                                                                                                       |
| `confidential`       | boolean           | 否       | 按机密性筛选。支持 `issues` 和 `work_items` 范围；其他范围会被忽略。                                                                                                                                  |
| `regex`              | boolean           | 否       | 使用正则表达式搜索代码。适用于精确代码搜索。如果未设置，则使用正则表达式。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/521686)极狐GitLab 18.9。 |
| `fields`             | array of strings  | 否       | 您希望搜索的字段数组，允许的值只有 `title`。仅支持 `issues` 和 `merge_requests` 范围。仅限专业版和旗舰版。                                                            |
| `num_context_lines`  | integer           | 否       | 结果中每个匹配项周围要包含的上下文行数。仅适用于高级搜索和精确代码搜索。[引入于](https://gitlab.com/gitlab-org/gitlab/-/work_items/583217)极狐GitLab 18.11。 |
| `ref`                | string            | 否       | 要搜索的代码仓库分支或标签名称。默认使用项目的默认分支。仅适用于 `blobs`、`commits` 和 `wiki_blobs` 范围。                                         |
| `state`              | string            | 否       | 按状态筛选。支持 `issues`、`work_items` 和 `merge_requests` 范围；其他范围会被忽略。                                                                                                                      |
| `type`               | array of strings  | 否       | 按类型筛选工作项。仅适用于 `work_items` 范围。可用类型：`issue`、`task`、`epic`、`incident`、`test_case`、`requirement`、`objective`、`key_result`、`ticket`。                          |
| `order_by`           | string            | 否       | 允许的值是 `created_at` 和 `title`。使用基础搜索时，可以按 `title` 对 `issues`、`work_items` 和 `merge_requests` 范围排序；使用高级搜索时，可以对 `issues` 和 `work_items` 范围排序。在高级搜索的标题排序回填完成之前，高级搜索对 `order_by=title`的响应会按 `created_at` 降序返回结果。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/565410)极狐GitLab 19.5。如果未设置，基础搜索的结果按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                              |
| `sort`               | string            | 否       | 允许的值只有 `asc` 或 `desc`。如果未设置，基础搜索的结果按 `created_at` 降序排序，高级搜索则按最相关的文档排序。                           |
| `author_username`    | string            | 否       | 按作者用户名筛选。不匹配任何用户的用户名会被忽略。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `label_name`         | array of strings  | 否       | 按标记名称筛选。结果必须带有每个能解析为现有标记的名称；不匹配任何标记的名称会被忽略。最多 30 个名称。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[author_username]` | string            | 否       | 排除由此用户名创作的结果。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时支持 `issues`、`merge_requests` 和 `work_items` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[source_branch]` | string            | 否       | 排除具有此源分支的合并请求。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `not[target_branch]` | string            | 否       | 排除具有此目标分支的合并请求。将筛选条件与其自身的否定组合会匹配任一条件，从而扩大结果集。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `source_branch`      | string            | 否       | 按源分支筛选合并请求。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |
| `target_branch`      | string            | 否       | 按目标分支筛选合并请求。使用高级搜索时仅支持 `merge_requests` 范围。仅限专业版和旗舰版。[引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/493214)极狐GitLab 19.5。 |

响应取决于所请求的范围。

<a id="scope-issues-2"></a>

### 范围：`issues`

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
> `assignee` 列已弃用。它现在是单元素 `assignees` 数组。

<a id="scope-work_items-2"></a>

### 范围：`work_items`

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

您可以使用 `type` 参数按类型筛选工作项：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/12/search?scope=work_items&search=backend&type[]=task&type[]=issue"
```

<a id="scope-merge_requests-2"></a>

### 范围：`merge_requests`

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

<a id="scope-milestones-2"></a>

### 范围：`milestones`

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

<a id="scope-users-2"></a>

### 范围：`users`

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

<a id="scope-wiki_blobs-2"></a>

### 范围：`wiki_blobs`

使用此范围搜索 Wiki。

此范围提供以下筛选条件：

- `filename`
- `path`
- `extension`

要使用筛选条件，请将其包含在查询中（例如，`a query filename:some_name*`）。

您可以使用通配符（`*`）进行 glob 匹配。

Wiki blob 搜索会同时针对文件名和内容执行。搜索结果：

- 在文件名中找到的结果会显示在内容中找到的结果之前。
- 同一 blob 可能包含多个匹配项，因为搜索字符串
  可能同时出现在文件名和内容中，或者可能在内容中多次出现。

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
> `filename` 已弃用，建议改用 `path`。两者都会返回文件在代码仓库中的完整路径，但未来 `filename` 将只表示文件名，而不是完整路径。有关详细信息，请参阅[议题 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。

<a id="scope-commits-2"></a>

### 范围：`commits`

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

<a id="scope-blobs-2"></a>

### 范围：`blobs`

使用此范围搜索代码。

此范围提供以下筛选条件：

- `filename`
- `path`
- `extension`

要使用筛选条件，请将其包含在查询中（例如，`a query filename:some_name*`）。

您可以使用通配符（`*`）进行 glob 匹配。

Blob 搜索会同时针对文件名和内容执行。搜索结果：

- 在文件名中找到的结果会显示在内容中找到的结果之前。
- 同一 blob 可能包含多个匹配项，因为搜索字符串
  可能同时出现在文件名和内容中，或者可能在内容中多次出现。

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
> `filename` 已弃用，建议改用 `path`。两者都会返回文件在代码仓库中的完整路径，但未来 `filename` 将只表示文件名，而不是完整路径。有关详细信息，请参阅[议题 34521](https://gitlab.com/gitlab-org/gitlab/-/issues/34521)。
> Elasticsearch 语法在精确代码搜索中可能无法正常工作。对于精确代码搜索，请将 Elasticsearch 通配符查询替换为正则表达式。有关更多信息，请参阅[议题 521686](https://gitlab.com/gitlab-org/gitlab/-/issues/521686)。

<a id="scope-notes-2"></a>

### 范围：`notes`

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

<a id="semantic-search"></a>

### 语义搜索

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

基于含义而非关键词匹配在项目中搜索代码。

```plaintext
GET /projects/:id/search/semantic
```

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `q`              | string            | 是      | 自然语言搜索查询。 |
| `directory_path` | string            | 否       | 用于限定搜索范围的目录路径。 |
| `knn`            | integer           | 否       | 向量搜索期间要考虑的最近邻数量（1-100）。默认为 `64`。 |
| `limit`          | integer           | 否       | 要返回的最大结果数（1-100）。默认为 `20`。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/12/search/semantic?q=authentication%20middleware"
```

示例响应：

响应是代码搜索结果数组。每个结果包含以下字段：

| 字段 | 类型 | 描述 |
|-------|------|-------------|
| `path` | string | 相对于代码仓库根目录的文件路径。 |
| `content` | string | 来自匹配文件的代码内容片段。 |
| `score` | number | 查询与结果之间的语义相似度得分（0-1）。得分越高表示匹配越好。 |
| `language` | string | 文件的编程语言。 |
| `start_line` | integer | 匹配代码片段开始的行号。 |
| `blob_id` | string | 文件的 Git blob ID。 |
| `file_url` | string | 在极狐GitLab 中查看文件的 URL。 |

```json
[
  {
    "path": "app/services/auth/jwt_service.rb",
    "content": "def verify_token(token)\n  JWT.decode(token, secret_key)...",
    "score": 0.91,
    "language": "ruby",
    "start_line": 42,
    "blob_id": "a1b2c3d4e5f6...",
    "file_url": "https://gitlab.example.com/my-org/my-project/-/blob/main/app/services/auth/jwt_service.rb"
  }
]
```
