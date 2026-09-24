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

使用此 API 管理[代码片段](../user/snippets.md)。存在相关 API 用于[项目代码片段](project_snippets.md)和[在存储之间移动代码片段](snippet_repository_storage_moves.md)。

<a id="list-all-snippets-for-current-user"></a>

## 列出当前用户的所有代码片段

获取当前用户的代码片段列表。

```plaintext
GET /snippets
```

支持的属性：

| 属性               | 类型      | 是否必需 | 描述 |
|-------------------|----------|--------|-------------|
| `created_after`   | 日期时间  | 否     | 返回在指定时间之后创建的代码片段。格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。 |
| `created_before`  | 日期时间  | 否     | 返回在指定时间之前创建的代码片段。格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。 |
| `page`            | 整数     | 否     | 要检索的页码。 |
| `per_page`        | 整数     | 否     | 每页返回的代码片段数量。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性             | 类型      | 描述 |
|------------------|-----------|-------------|
| `author`         | 对象      | 代表代码片段作者的用户对象。 |
| `created_at`     | 字符串    | 代码片段创建的时间。 |
| `description`    | 字符串    | 代码片段的描述。 |
| `file_name`      | 字符串    | 代码片段文件名。 |
| `id`             | 整数      | 代码片段的 ID。 |
| `imported`       | 布尔值    | 如果为 `true`，表示代码片段已导入。 |
| `imported_from`  | 字符串    | 导入来源。 |
| `project_id`     | 整数      | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`        | 字符串    | 原始代码片段内容的 URL。 |
| `title`          | 字符串    | 代码片段的标题。 |
| `updated_at`     | 字符串    | 代码片段最后更新的时间。 |
| `visibility`     | 字符串    | 代码片段的可见性级别。 |
| `web_url`        | 字符串    | 极狐GitLab UI 中代码片段的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets"
```

响应示例：

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
        "raw_url": "http://example.com/snippets/42/raw"
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
        "raw_url": "http://example.com/gitlab-org/gitlab-test/snippets/41/raw"
    }
]
```

<a id="retrieve-a-snippet"></a>

## 获取一个代码片段

获取指定的代码片段。

```plaintext
GET /snippets/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述                |
|------|---------|------|----------------------------|
| `id` | 整数    | 是   | 要获取的代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性               | 类型      | 描述 |
|--------------------|-----------|-------------|
| `author`           | 对象      | 代表代码片段作者的用户对象。 |
| `created_at`       | 字符串    | 代码片段创建的时间。 |
| `description`      | 字符串    | 代码片段的描述。 |
| `expires_at`       | 字符串    | 代码片段到期的时间。 |
| `file_name`        | 字符串    | 代码片段文件名。 |
| `http_url_to_repo` | 字符串    | 代码片段仓库的 HTTP URL。 |
| `id`               | 整数      | 代码片段的 ID。 |
| `imported`         | 布尔值    | 如果为 `true`，表示代码片段已导入。 |
| `imported_from`    | 字符串    | 导入来源。 |
| `project_id`       | 整数      | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`          | 字符串    | 原始代码片段内容的 URL。 |
| `ssh_url_to_repo`  | 字符串    | 代码片段仓库的 SSH URL。 |
| `title`            | 字符串    | 代码片段的标题。 |
| `updated_at`       | 字符串    | 代码片段最后更新的时间。 |
| `visibility`       | 字符串    | 代码片段的可见性级别。 |
| `web_url`          | 字符串    | 极狐GitLab UI 中代码片段的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1"
```

响应示例：

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
  "raw_url": "http://example.com/snippets/1/raw"
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
|------|---------|------|----------------------------|
| `id` | 整数    | 是   | 要获取的代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及代码片段的原始内容。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/raw"
```

响应示例：

```plaintext
Hello World 代码片段
```

<a id="snippet-repository-file-content"></a>

## 代码片段仓库文件内容

以纯文本形式返回原始文件内容。

```plaintext
GET /snippets/:id/files/:ref/:file_path/raw
```

支持的属性：

| 属性         | 类型    | 是否必需 | 描述 |
|-------------|---------|------|-------------|
| `file_path` | 字符串  | 是   | 文件的 URL 编码路径。 |
| `id`        | 整数    | 是   | 要获取的代码片段的 ID。 |
| `ref`       | 字符串  | 是   | 标签、分支或提交的引用。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及原始文件内容。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/files/main/snippet%2Erb/raw"
```

响应示例：

```plaintext
Hello World 代码片段
```

<a id="create-a-snippet"></a>

## 创建一个代码片段

创建一个新代码片段。

> [!note]
> 用户必须具有创建新代码片段的权限。

```plaintext
POST /snippets
```

支持的属性：

| 属性               | 类型            | 是否必需 | 描述 |
| ----------------- | --------------- | -------- | ----------- |
| `files:content`    | 字符串          | 是       | 代码片段文件的内容。 |
| `files:file_path`  | 字符串          | 是       | 代码片段文件路径。 |
| `title`            | 字符串          | 是       | 代码片段标题。 |
| `content`          | 字符串          | 否       | 已弃用：请使用 `files` 代替。代码片段的内容。 |
| `description`      | 字符串          | 否       | 代码片段的描述。 |
| `file_name`        | 字符串          | 否       | 已弃用：请使用 `files` 代替。代码片段文件名。 |
| `files`            | 哈希数组        | 否       | 代码片段文件数组。 |
| `visibility`       | 字符串          | 否       | 代码片段的可见性级别。可取值：`public`、`private` 和 `internal`。在 JihuLab.com 上，`internal` 值不可用。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性               | 类型      | 描述 |
|--------------------|-----------|-------------|
| `author`           | 对象      | 代表代码片段作者的用户对象。 |
| `created_at`       | 字符串    | 代码片段创建的时间。 |
| `description`      | 字符串    | 代码片段的描述。 |
| `expires_at`       | 字符串    | 代码片段到期的时间。 |
| `file_name`        | 字符串    | 代码片段文件名。 |
| `files`            | 数组      | 代码片段文件数组。 |
| `http_url_to_repo` | 字符串    | 代码片段仓库的 HTTP URL。 |
| `id`               | 整数      | 代码片段的 ID。 |
| `imported`         | 布尔值    | 如果为 `true`，表示代码片段已导入。 |
| `imported_from`    | 字符串    | 导入来源。 |
| `project_id`       | 整数      | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`          | 字符串    | 原始代码片段内容的 URL。 |
| `ssh_url_to_repo`  | 字符串    | 代码片段仓库的 SSH URL。 |
| `title`            | 字符串    | 代码片段的标题。 |
| `updated_at`       | 字符串    | 代码片段最后更新的时间。 |
| `visibility`       | 字符串    | 代码片段的可见性级别。 |
| `web_url`          | 字符串    | 极狐GitLab UI 中代码片段的 URL。 |

请求示例：

```shell
curl --request POST "https://gitlab.example.com/api/v4/snippets" \
     --header 'Content-Type: application/json' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     -d @snippet.json
```

前面请求示例中使用的 `snippet.json`：

```json
{
  "title": "This is a snippet",
  "description": "Hello World 片段",
  "visibility": "internal",
  "files": [
    {
      "content": "Hello world",
      "file_path": "test.txt"
    }
  ]
}
```

响应示例：

```json
{
  "id": 1,
  "title": "This is a snippet",
  "description": "Hello World 片段",
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
  "ssh_url_to_repo": "ssh://git@gitlab.example.com:snippets/1.git",
  "http_url_to_repo": "https://gitlab.example.com/snippets/1.git",
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

更新现有代码片段。

> [!note]
> 用户必须具有更改现有代码片段的权限。

```plaintext
PUT /snippets/:id
```

支持的属性：

| 属性                   | 类型            | 是否必需         | 描述 |
| --------------------- | --------------- | ---------------- | ----------- |
| `id`                  | 整数            | 是               | 要更新的代码片段的 ID。 |
| `files:action`        | 字符串          | 是               | 在文件上执行的操作类型，可选值：`create`、`update`、`delete`、`move`。 |
| `content`             | 字符串          | 否               | 已弃用：请使用 `files` 代替。代码片段的内容。 |
| `description`         | 字符串          | 否               | 代码片段的描述。 |
| `file_name`           | 字符串          | 否               | 已弃用：请使用 `files` 代替。代码片段文件名。 |
| `files`               | 哈希数组        | 有条件           | 代码片段文件数组。更新含有多个文件的代码片段时必需。 |
| `files:content`       | 字符串          | 否               | 代码片段文件的内容。 |
| `files:file_path`     | 字符串          | 否               | 代码片段文件路径。 |
| `files:previous_path` | 字符串          | 否               | 代码片段文件之前的路径。 |
| `title`               | 字符串          | 否               | 代码片段标题。 |
| `visibility`          | 字符串          | 否               | 代码片段的可见性级别。可取值：`public`、`private` 和 `internal`。在 JihuLab.com 上，`internal` 值不可用。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性               | 类型      | 描述 |
|--------------------|-----------|-------------|
| `author`           | 对象      | 代表代码片段作者的用户对象。 |
| `created_at`       | 字符串    | 代码片段创建的时间。 |
| `description`      | 字符串    | 代码片段的描述。 |
| `expires_at`       | 字符串    | 代码片段到期的时间。 |
| `file_name`        | 字符串    | 代码片段文件名。 |
| `files`            | 数组      | 代码片段文件数组。 |
| `http_url_to_repo` | 字符串    | 代码片段仓库的 HTTP URL。 |
| `id`               | 整数      | 代码片段的 ID。 |
| `imported`         | 布尔值    | 如果为 `true`，表示代码片段已导入。 |
| `imported_from`    | 字符串    | 导入来源。 |
| `project_id`       | 整数      | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`          | 字符串    | 原始代码片段内容的 URL。 |
| `ssh_url_to_repo`  | 字符串    | 代码片段仓库的 SSH URL。 |
| `title`            | 字符串    | 代码片段的标题。 |
| `updated_at`       | 字符串    | 代码片段最后更新的时间。 |
| `visibility`       | 字符串    | 代码片段的可见性级别。 |
| `web_url`          | 字符串    | 极狐GitLab UI 中代码片段的 URL。 |

请求示例：

```shell
curl --request PUT "https://gitlab.example.com/api/v4/snippets/1" \
     --header 'Content-Type: application/json' \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     -d @snippet.json
```

前面请求示例中使用的 `snippet.json`：

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

响应示例：

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
  "ssh_url_to_repo": "ssh://git@gitlab.example.com:snippets/1.git",
  "http_url_to_repo": "https://gitlab.example.com/snippets/1.git",
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

删除现有代码片段。

```plaintext
DELETE /snippets/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述              |
|------|---------|------|--------------------------|
| `id` | 整数    | 是   | 要删除的代码片段的 ID。 |

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1"
```

可能的返回码如下：

| 代码   | 描述 |
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

| 属性              | 类型      | 是否必需 | 描述 |
|------------------|----------|------|-------------|
| `created_after`  | 日期时间  | 否   | 返回在指定时间之后创建的代码片段。格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。 |
| `created_before` | 日期时间  | 否   | 返回在指定时间之前创建的代码片段。格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。 |
| `page`           | 整数     | 否   | 要检索的页码。 |
| `per_page`       | 整数     | 否   | 每页返回的代码片段数量。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型      | 描述 |
|--------------|----------|-------------|
| `author`     | 对象     | 代表代码片段作者的用户对象。 |
| `created_at` | 字符串   | 代码片段创建的时间。 |
| `description`| 字符串   | 代码片段的描述。 |
| `file_name`  | 字符串   | 代码片段文件名。 |
| `id`         | 整数     | 代码片段的 ID。 |
| `project_id` | 整数     | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`    | 字符串   | 原始代码片段内容的 URL。 |
| `title`      | 字符串   | 代码片段的标题。 |
| `updated_at` | 字符串   | 代码片段最后更新的时间。 |
| `visibility` | 字符串   | 代码片段的可见性级别。 |
| `web_url`    | 字符串   | 极狐GitLab UI 中代码片段的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/public?per_page=2&page=1"
```

响应示例：

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
        "raw_url": "http://example.com/snippets/49/raw"
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
        "raw_url": "http://example.com/snippets/49/raw",
        "visibility": "public"
    }
]
```

<a id="list-all-snippets"></a>

## 列出所有代码片段

{{< history >}}

- 于极狐GitLab 16.3 引入。

{{< /history >}}

列出当前用户有权限访问的所有代码片段。
具有管理员或审计者访问级别的用户可以查看所有代码片段（包括个人和项目）。

```plaintext
GET /snippets/all
```

支持的属性：

| 属性                  | 类型      | 是否必需 | 描述 |
|----------------------|----------|------|-------------|
| `created_after`      | 日期时间  | 否   | 返回在指定时间之后创建的代码片段。格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。 |
| `created_before`     | 日期时间  | 否   | 返回在指定时间之前创建的代码片段。格式为 ISO 8601 (`2019-03-15T08:00:00Z`)。 |
| `page`               | 整数     | 否   | 要检索的页码。 |
| `per_page`           | 整数     | 否   | 每页返回的代码片段数量。 |
| `repository_storage` | 字符串   | 否   | 按代码片段使用的仓库存储进行筛选 _(仅管理员)_。于极狐GitLab 16.3 引入。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                  | 类型      | 描述 |
|----------------------|----------|-------------|
| `author`             | 对象     | 代表代码片段作者的用户对象。 |
| `created_at`         | 字符串   | 代码片段创建的时间。 |
| `description`        | 字符串   | 代码片段的描述。 |
| `file_name`          | 字符串   | 代码片段文件名。 |
| `files`              | 数组     | 代码片段文件数组。 |
| `id`                 | 整数     | 代码片段的 ID。 |
| `imported`           | 布尔值   | 如果为 `true`，表示代码片段已导入。 |
| `imported_from`      | 字符串   | 导入来源。 |
| `project_id`         | 整数     | 关联项目的 ID。对于个人代码片段，为 `null`。 |
| `raw_url`            | 字符串   | 原始代码片段内容的 URL。 |
| `repository_storage` | 字符串   | 代码片段使用的仓库存储。 |
| `title`              | 字符串   | 代码片段的标题。 |
| `updated_at`         | 字符串   | 代码片段最后更新的时间。 |
| `visibility`         | 字符串   | 代码片段的可见性级别。 |
| `web_url`            | 字符串   | 极狐GitLab UI 中代码片段的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/all?per_page=2&page=1"
```

响应示例：

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

## 获取用户代理详情

> [!note]
> 仅限管理员可用。

```plaintext
GET /snippets/:id/user_agent_detail
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述    |
|------|---------|------|----------------|
| `id` | 整数    | 是   | 代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：
| 属性 | 类型 | 描述 |
|---------------------|---------|-------------|
| `akismet_submitted` | boolean | 如果为 `true`，表示详情已提交至 Akismet。 |
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