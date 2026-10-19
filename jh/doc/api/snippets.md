---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码片段 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[代码片段](../user/snippets.md)。相关的 API 还有[项目代码片段](project_snippets.md)和[在存储之间移动代码片段](snippet_repository_storage_moves.md)。

<a id="list-all-snippets-for-current-user"></a>

## 列出当前用户的所有代码片段

获取当前用户的代码片段列表。

```plaintext
GET /snippets
```

支持的属性：

| 属性        | 类型     | 是否必需 | 描述 |
|------------------|----------|----------|-------------|
| `created_after`  | datetime | 否       | 返回在给定时间之后创建的代码片段。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before` | datetime | 否       | 返回在给定时间之前创建的代码片段。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `page`           | integer  | 否       | 要检索的页码。 |
| `per_page`       | integer  | 否       | 每页返回的代码片段数量。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性       | 类型    | 描述 |
|-----------------|---------|-------------|
| `author`        | object  | 表示代码片段作者的用户对象。 |
| `created_at`    | string  | 代码片段的创建日期和时间。 |
| `description`   | string  | 代码片段的描述。 |
| `file_name`     | string  | 代码片段文件的名称。 |
| `http_url_to_repo` | string | 代码片段代码仓库的 HTTP URL。仅在代码片段代码仓库存在时返回。 |
| `id`            | integer | 代码片段的 ID。 |
| `imported`      | boolean | 如果为 `true`，则表示该代码片段是导入的。 |
| `imported_from` | string  | 导入来源。 |
| `project_id`    | integer | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`       | string  | 代码片段原始内容的 URL。 |
| `ssh_url_to_repo` | string | 代码片段代码仓库的 SSH URL。仅在代码片段代码仓库存在时返回。 |
| `title`         | string  | 代码片段的标题。 |
| `updated_at`    | string  | 代码片段最后更新的日期和时间。 |
| `visibility`    | string  | 代码片段的可见性级别。 |
| `web_url`       | string  | 代码片段在极狐GitLab UI 中的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets"
```

示例响应：

```json
[
    {
        "id": 42,
        "title": "Voluptatem iure ut qui aut et consequatur quaerat.",
        "file_name": "mclaughlin.rb",
        "description": null,
        "visibility": "internal",
        "imported": false,
        "imported_from": "none",
        "author": {
            "id": 22,
            "name": "User 0",
            "username": "user0",
            "state": "active",
            "avatar_url": "https://www.gravatar.com/avatar/52e4ce24a915fb7e51e1ad3b57f4b00a?s=80&d=identicon",
            "web_url": "http://example.com/user0"
        },
        "updated_at": "2018-09-18T01:12:26.383Z",
        "created_at": "2018-09-18T01:12:26.383Z",
        "project_id": null,
        "web_url": "http://example.com/snippets/42",
        "raw_url": "http://example.com/snippets/42/raw",
        "ssh_url_to_repo": "ssh://git@example.com:snippets/42.git",
        "http_url_to_repo": "http://example.com/snippets/42.git"
    },
    {
        "id": 41,
        "title": "Ut praesentium non et atque.",
        "file_name": "ondrickaemard.rb",
        "description": null,
        "visibility": "internal",
        "imported": false,
        "imported_from": "none",
        "author": {
            "id": 22,
            "name": "User 0",
            "username": "user0",
            "state": "active",
            "avatar_url": "https://www.gravatar.com/avatar/52e4ce24a915fb7e51e1ad3b57f4b00a?s=80&d=identicon",
            "web_url": "http://example.com/user0"
        },
        "updated_at": "2018-09-18T01:12:26.360Z",
        "created_at": "2018-09-18T01:12:26.360Z",
        "project_id": 1,
        "web_url": "http://example.com/gitlab-org/gitlab-test/snippets/41",
        "raw_url": "http://example.com/gitlab-org/gitlab-test/snippets/41/raw",
        "ssh_url_to_repo": "ssh://git@example.com:gitlab-org/gitlab-test/snippets/41.git",
        "http_url_to_repo": "http://example.com/gitlab-org/gitlab-test/snippets/41.git"
    }
]
```

<a id="retrieve-a-snippet"></a>

## 检索代码片段

检索指定的代码片段。

```plaintext
GET /snippets/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述                |
|-----------|---------|----------|----------------------------|
| `id`      | integer | 是      | 要检索的代码片段 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型    | 描述 |
|--------------------|---------|-------------|
| `author`           | object  | 表示代码片段作者的用户对象。 |
| `created_at`       | string  | 代码片段的创建日期和时间。 |
| `description`      | string  | 代码片段的描述。 |
| `expires_at`       | string  | 代码片段过期的日期和时间。 |
| `file_name`        | string  | 代码片段文件的名称。 |
| `http_url_to_repo` | string  | 代码片段代码仓库的 HTTP URL。仅在代码片段代码仓库存在时返回。 |
| `id`               | integer | 代码片段的 ID。 |
| `imported`         | boolean | 如果为 `true`，则表示该代码片段是导入的。 |
| `imported_from`    | string  | 导入来源。 |
| `project_id`       | integer | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`          | string  | 代码片段原始内容的 URL。 |
| `ssh_url_to_repo`  | string  | 代码片段代码仓库的 SSH URL。仅在代码片段代码仓库存在时返回。 |
| `title`            | string  | 代码片段的标题。 |
| `updated_at`       | string  | 代码片段最后更新的日期和时间。 |
| `visibility`       | string  | 代码片段的可见性级别。 |
| `web_url`          | string  | 代码片段在极狐GitLab UI 中的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1"
```

示例响应：

```json
{
  "id": 1,
  "title": "test",
  "file_name": "add.rb",
  "description": "Ruby test snippet",
  "visibility": "private",
  "imported": false,
  "imported_from": "none",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "expires_at": null,
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "project_id": null,
  "web_url": "http://example.com/snippets/1",
  "raw_url": "http://example.com/snippets/1/raw",
  "ssh_url_to_repo": "ssh://git@example.com:snippets/1.git",
  "http_url_to_repo": "http://example.com/snippets/1.git"
}
```

<a id="single-snippet-contents"></a>

## 单个代码片段内容

获取单个代码片段的原始内容。

```plaintext
GET /snippets/:id/raw
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述                |
|-----------|---------|----------|----------------------------|
| `id`      | integer | 是      | 要检索的代码片段 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及代码片段的原始内容。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/raw"
```

示例响应：

```plaintext
Hello World snippet
```

<a id="snippet-repository-file-content"></a>

## 代码片段代码仓库文件内容

以纯文本形式返回原始文件内容。

```plaintext
GET /snippets/:id/files/:ref/:file_path/raw
```

支持的属性：

| 属性   | 类型    | 是否必需 | 描述 |
|-------------|---------|----------|-------------|
| `file_path` | string  | 是      | 经过 URL 编码的文件路径。 |
| `id`        | integer | 是      | 要检索的代码片段 ID。 |
| `ref`       | string  | 是      | 对标签、分支或提交的引用。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及原始文件内容。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/files/main/snippet%2Erb/raw"
```

示例响应：

```plaintext
Hello World snippet
```

<a id="create-a-snippet"></a>

## 创建代码片段

创建新的代码片段。

> [!note]
> 用户必须拥有创建新代码片段的权限。

创建代码片段受到速率限制，每个已认证用户每小时最多 300 次请求。该限制在此端点、[创建项目代码片段](project_snippets.md#create-a-snippet)
以及极狐GitLab UI 使用的 `createSnippet` GraphQL 变更之间共享。
更多信息，请参见[不可配置的速率限制](../rate_limits/non_configurable.md)。

```plaintext
POST /snippets
```

支持的属性：

| 属性         | 类型            | 是否必需 | 描述 |
| ----------------- | --------------- | -------- | ----------- |
| `files:content`   | string          | 是      | 代码片段文件的内容。 |
| `files:file_path` | string          | 是      | 代码片段文件的文件路径。 |
| `title`           | string          | 是      | 代码片段的标题。 |
| `content`         | string          | 否       | 已弃用：请改用 `files`。代码片段的内容。 |
| `description`     | string          | 否       | 代码片段的描述。 |
| `file_name`       | string          | 否       | 已弃用：请改用 `files`。代码片段文件的名称。 |
| `files`           | 哈希数组 | 否       | 代码片段文件的数组。 |
| `visibility`      | string          | 否       | 代码片段的可见性级别。可能的值：`public`、`private` 和 `internal`。在 JihuLab.com 上，`internal` 值不可用。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型    | 描述 |
|--------------------|---------|-------------|
| `author`           | object  | 表示代码片段作者的用户对象。 |
| `created_at`       | string  | 代码片段的创建日期和时间。 |
| `description`      | string  | 代码片段的描述。 |
| `expires_at`       | string  | 代码片段过期的日期和时间。 |
| `file_name`        | string  | 代码片段文件的名称。 |
| `files`            | array   | 代码片段文件的数组。 |
| `http_url_to_repo` | string  | 代码片段代码仓库的 HTTP URL。仅在代码片段代码仓库存在时返回。 |
| `id`               | integer | 代码片段的 ID。 |
| `imported`         | boolean | 如果为 `true`，则表示该代码片段是导入的。 |
| `imported_from`    | string  | 导入来源。 |
| `project_id`       | integer | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`          | string  | 代码片段原始内容的 URL。 |
| `ssh_url_to_repo`  | string  | 代码片段代码仓库的 SSH URL。仅在代码片段代码仓库存在时返回。 |
| `title`            | string  | 代码片段的标题。 |
| `updated_at`       | string  | 代码片段最后更新的日期和时间。 |
| `visibility`       | string  | 代码片段的可见性级别。 |
| `web_url`          | string  | 代码片段在极狐GitLab UI 中的 URL。 |

示例请求：

```shell
curl --request POST \
  --header 'Content-Type: application/json' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data @snippet.json \
  --url "https://gitlab.example.com/api/v4/snippets"
```

上一个示例请求中使用的 `snippet.json`：

```json
{
  "title": "This is a snippet",
  "description": "Hello World snippet",
  "visibility": "internal",
  "files": [
    {
      "content": "Hello world",
      "file_path": "test.txt"
    }
  ]
}
```

示例响应：

```json
{
  "id": 1,
  "title": "This is a snippet",
  "description": "Hello World snippet",
  "visibility": "internal",
  "imported": false,
  "imported_from": "none",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "expires_at": null,
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "project_id": null,
  "web_url": "http://example.com/snippets/1",
  "raw_url": "http://example.com/snippets/1/raw",
  "ssh_url_to_repo": "ssh://git@example.com:snippets/1.git",
  "http_url_to_repo": "http://example.com/snippets/1.git",
  "file_name": "test.txt",
  "files": [
    {
      "path": "text.txt",
      "raw_url": "https://gitlab.example.com/-/snippets/1/raw/main/renamed.md"
    }
  ]
}
```

<a id="update-snippet"></a>

## 更新代码片段

更新现有的代码片段。

> [!note]
> 用户必须拥有更改现有代码片段的权限。

```plaintext
PUT /snippets/:id
```

支持的属性：

| 属性             | 类型            | 是否必需      | 描述 |
| --------------------- | --------------- | ------------- | ----------- |
| `id`                  | integer         | 是           | 要更新的代码片段 ID。 |
| `files:action`        | string          | 是           | 要对文件执行的操作类型，以下之一：`create`、`update`、`delete`、`move`。 |
| `content`             | string          | 否            | 已弃用：请改用 `files`。代码片段的内容。 |
| `description`         | string          | 否            | 代码片段的描述。 |
| `file_name`           | string          | 否            | 已弃用：请改用 `files`。代码片段文件的名称。 |
| `files`               | 哈希数组 | 有条件 | 代码片段文件的数组。更新包含多个文件的代码片段时必需。 |
| `files:content`       | string          | 否            | 代码片段文件的内容。 |
| `files:file_path`     | string          | 否            | 代码片段文件的文件路径。 |
| `files:previous_path` | string          | 否            | 代码片段文件的先前路径。 |
| `title`               | string          | 否            | 代码片段的标题。 |
| `visibility`          | string          | 否            | 代码片段的可见性级别。可能的值：`public`、`private` 和 `internal`。在 JihuLab.com 上，`internal` 值不可用。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型    | 描述 |
|--------------------|---------|-------------|
| `author`           | object  | 表示代码片段作者的用户对象。 |
| `created_at`       | string  | 代码片段的创建日期和时间。 |
| `description`      | string  | 代码片段的描述。 |
| `expires_at`       | string  | 代码片段过期的日期和时间。 |
| `file_name`        | string  | 代码片段文件的名称。 |
| `files`            | array   | 代码片段文件的数组。 |
| `http_url_to_repo` | string  | 代码片段代码仓库的 HTTP URL。仅在代码片段代码仓库存在时返回。 |
| `id`               | integer | 代码片段的 ID。 |
| `imported`         | boolean | 如果为 `true`，则表示该代码片段是导入的。 |
| `imported_from`    | string  | 导入来源。 |
| `project_id`       | integer | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`          | string  | 代码片段原始内容的 URL。 |
| `ssh_url_to_repo`  | string  | 代码片段代码仓库的 SSH URL。仅在代码片段代码仓库存在时返回。 |
| `title`            | string  | 代码片段的标题。 |
| `updated_at`       | string  | 代码片段最后更新的日期和时间。 |
| `visibility`       | string  | 代码片段的可见性级别。 |
| `web_url`          | string  | 代码片段在极狐GitLab UI 中的 URL。 |

示例请求：

```shell
curl --request PUT \
  --header 'Content-Type: application/json' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data @snippet.json \
  --url "https://gitlab.example.com/api/v4/snippets/1"
```

上一个示例请求中使用的 `snippet.json`：

```json
{
  "title": "foo",
  "files": [
    {
      "action": "move",
      "previous_path": "test.txt",
      "file_path": "renamed.md"
    }
  ]
}
```

示例响应：

```json
{
  "id": 1,
  "title": "test",
  "description": "description of snippet",
  "visibility": "internal",
  "imported": false,
  "imported_from": "none",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "expires_at": null,
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "project_id": null,
  "web_url": "http://example.com/snippets/1",
  "raw_url": "http://example.com/snippets/1/raw",
  "ssh_url_to_repo": "ssh://git@example.com:snippets/1.git",
  "http_url_to_repo": "http://example.com/snippets/1.git",
  "file_name": "renamed.md",
  "files": [
    {
      "path": "renamed.md",
      "raw_url": "https://gitlab.example.com/-/snippets/1/raw/main/renamed.md"
    }
  ]
}
```

<a id="delete-snippet"></a>

## 删除代码片段

删除现有的代码片段。

```plaintext
DELETE /snippets/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述              |
|-----------|---------|----------|--------------------------|
| `id`      | integer | 是      | 要删除的代码片段 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1"
```

以下是可能的返回码：

| 代码  | 描述 |
|-------|-------------|
| `204` | 删除成功。不返回任何数据。 |
| `404` | 未找到代码片段。 |

<a id="list-all-public-snippets"></a>

## 列出所有公开代码片段

列出所有公开代码片段。

```plaintext
GET /snippets/public
```

支持的属性：

| 属性        | 类型     | 是否必需 | 描述 |
|------------------|----------|----------|-------------|
| `created_after`  | datetime | 否       | 返回在给定时间之后创建的代码片段。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before` | datetime | 否       | 返回在给定时间之前创建的代码片段。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `page`           | integer  | 否       | 要检索的页码。 |
| `per_page`       | integer  | 否       | 每页返回的代码片段数量。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性     | 类型    | 描述 |
|---------------|---------|-------------|
| `author`      | object  | 表示代码片段作者的用户对象。 |
| `created_at`  | string  | 代码片段的创建日期和时间。 |
| `description` | string  | 代码片段的描述。 |
| `file_name`   | string  | 代码片段文件的名称。 |
| `http_url_to_repo` | string | 代码片段代码仓库的 HTTP URL。仅在代码片段代码仓库存在时返回。 |
| `id`          | integer | 代码片段的 ID。 |
| `imported`    | boolean | 如果为 `true`，则表示该代码片段是导入的。 |
| `imported_from` | string | 导入来源。 |
| `project_id`  | integer | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`     | string  | 代码片段原始内容的 URL。 |
| `ssh_url_to_repo` | string | 代码片段代码仓库的 SSH URL。仅在代码片段代码仓库存在时返回。 |
| `title`       | string  | 代码片段的标题。 |
| `updated_at`  | string  | 代码片段最后更新的日期和时间。 |
| `visibility`  | string  | 代码片段的可见性级别。 |
| `web_url`     | string  | 代码片段在极狐GitLab UI 中的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/public?per_page=2&page=1"
```

示例响应：

```json
[
    {
        "author": {
            "avatar_url": "http://www.gravatar.com/avatar/edaf55a9e363ea263e3b981d09e0f7f7?s=80&d=identicon",
            "id": 12,
            "name": "Libby Rolfson",
            "state": "active",
            "username": "elton_wehner",
            "web_url": "http://example.com/elton_wehner"
        },
        "created_at": "2016-11-25T16:53:34.504Z",
        "file_name": "oconnerrice.rb",
        "id": 49,
        "title": "Ratione cupiditate et laborum temporibus.",
        "updated_at": "2016-11-25T16:53:34.504Z",
        "project_id": null,
        "web_url": "http://example.com/snippets/49",
        "raw_url": "http://example.com/snippets/49/raw",
        "ssh_url_to_repo": "ssh://git@example.com:snippets/49.git",
        "http_url_to_repo": "http://example.com/snippets/49.git",
        "imported": false,
        "imported_from": "none"
    },
    {
        "author": {
            "avatar_url": "http://www.gravatar.com/avatar/36583b28626de71061e6e5a77972c3bd?s=80&d=identicon",
            "id": 16,
            "name": "Llewellyn Flatley",
            "state": "active",
            "username": "adaline",
            "web_url": "http://example.com/adaline"
        },
        "created_at": "2016-11-25T16:53:34.479Z",
        "file_name": "muellershields.rb",
        "id": 48,
        "title": "Minus similique nesciunt vel fugiat qui ullam sunt.",
        "updated_at": "2016-11-25T16:53:34.479Z",
        "project_id": null,
        "web_url": "http://example.com/snippets/48",
        "raw_url": "http://example.com/snippets/48/raw",
        "ssh_url_to_repo": "ssh://git@example.com:snippets/48.git",
        "http_url_to_repo": "http://example.com/snippets/48.git",
        "imported": false,
        "imported_from": "none",
        "visibility": "public"
    }
]
```

<a id="list-all-snippets"></a>

## 列出所有代码片段

列出当前用户有权访问的所有代码片段。具有管理员或审计员访问级别的用户可以看到所有代码片段（包括个人代码片段和项目代码片段）。

```plaintext
GET /snippets/all
```

支持的属性：

| 属性            | 类型     | 是否必需 | 描述 |
|----------------------|----------|----------|-------------|
| `created_after`      | datetime | 否       | 返回在给定时间之后创建的代码片段。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `created_before`     | datetime | 否       | 返回在给定时间之前创建的代码片段。预期为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。 |
| `page`               | integer  | 否       | 要检索的页码。 |
| `per_page`           | integer  | 否       | 每页返回的代码片段数量。 |
| `repository_storage` | string   | 否       | 按代码片段使用的代码仓库存储进行筛选*（仅限管理员）*。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性            | 类型    | 描述 |
|----------------------|---------|-------------|
| `author`             | object  | 表示代码片段作者的用户对象。 |
| `created_at`         | string  | 代码片段的创建日期和时间。 |
| `description`        | string  | 代码片段的描述。 |
| `file_name`          | string  | 代码片段文件的名称。 |
| `files`              | array   | 代码片段文件的数组。 |
| `http_url_to_repo`   | string  | 代码片段代码仓库的 HTTP URL。仅在代码片段代码仓库存在时返回。 |
| `id`                 | integer | 代码片段的 ID。 |
| `imported`           | boolean | 如果为 `true`，则表示该代码片段是导入的。 |
| `imported_from`      | string  | 导入来源。 |
| `project_id`         | integer | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`            | string  | 代码片段原始内容的 URL。 |
| `repository_storage` | string  | 代码片段使用的代码仓库存储。 |
| `ssh_url_to_repo`    | string  | 代码片段代码仓库的 SSH URL。仅在代码片段代码仓库存在时返回。 |
| `title`              | string  | 代码片段的标题。 |
| `updated_at`         | string  | 代码片段最后更新的日期和时间。 |
| `visibility`         | string  | 代码片段的可见性级别。 |
| `web_url`            | string  | 代码片段在极狐GitLab UI 中的 URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/all?per_page=2&page=1"
```

示例响应：

```json
[
  {
    "id": 113,
    "title": "Internal Project Snippet",
    "description": null,
    "visibility": "internal",
    "imported": false,
    "imported_from": "none",
    "author": {
      "id": 17,
      "username": "tim_kreiger",
      "name": "Tim Kreiger",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/edaf55a9e363ea263e3b981d09e0f7f7?s=80&d=identicon",
      "web_url": "http://example.com/tim_kreiger"
    },
    "created_at": "2023-08-03T10:21:02.480Z",
    "updated_at": "2023-08-03T10:21:02.480Z",
    "project_id": 35,
    "web_url": "http://example.com/tim_kreiger/internal_project/-/snippets/113",
    "raw_url": "http://example.com/tim_kreiger/internal_project/-/snippets/113/raw",
    "file_name": "",
    "files": [],
    "repository_storage": "default"
  },
  {
    "id": 112,
    "title": "Private Personal Snippet",
    "description": null,
    "visibility": "private",
    "imported": false,
    "imported_from": "none",
    "author": {
      "id": 1,
      "username": "root",
      "name": "Administrator",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/edaf55a9e363ea263e3b981d09e0f7f7?s=80&d=identicon",
      "web_url": "http://example.com/root"
    },
    "created_at": "2023-08-03T10:20:59.994Z",
    "updated_at": "2023-08-03T10:20:59.994Z",
    "project_id": null,
    "web_url": "http://example.com/-/snippets/112",
    "raw_url": "http://example.com/-/snippets/112/raw",
    "file_name": "",
    "files": [],
    "repository_storage": "default"
  },
  {
    "id": 111,
    "title": "Public Personal Snippet",
    "description": null,
    "visibility": "public",
    "imported": false,
    "imported_from": "none",
    "author": {
      "id": 17,
      "username": "tim_kreiger",
      "name": "Tim Kreiger",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/edaf55a9e363ea263e3b981d09e0f7f7?s=80&d=identicon",
      "web_url": "http://example.com/tim_kreiger"
    },
    "created_at": "2023-08-03T10:21:01.312Z",
    "updated_at": "2023-08-03T10:21:01.312Z",
    "project_id": null,
    "web_url": "http://example.com/-/snippets/111",
    "raw_url": "http://example.com/-/snippets/111/raw",
    "file_name": "",
    "files": [],
    "repository_storage": "default"
  }
]
```

<a id="get-user-agent-details"></a>

## 获取用户代理详细信息

> [!note]
> 仅对管理员可用。

```plaintext
GET /snippets/:id/user_agent_detail
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述    |
|-----------|---------|----------|----------------|
| `id`      | integer | 是      | 代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型    | 描述 |
|---------------------|---------|-------------|
| `akismet_submitted` | boolean | 如果为 `true`，则表示详细信息已提交至 Akismet。 |
| `ip_address`        | string  | 用于创建代码片段的 IP 地址。 |
| `user_agent`        | string  | 用于创建代码片段的用户代理字符串。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/user_agent_detail"
```

示例响应：

```json
{
  "user_agent": "AppleWebKit/537.36",
  "ip_address": "127.0.0.1",
  "akismet_submitted": false
}
```
