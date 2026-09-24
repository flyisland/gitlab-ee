---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目代码片段
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [项目代码片段](../user/snippets.md)。相关的 API 包括 [个人代码片段](snippets.md) 和 [在不同存储之间移动代码片段](snippet_repository_storage_moves.md)。

<a id="list-all-snippets-for-a-project"></a>

## 列出项目的所有代码片段

列出指定项目的所有代码片段。

```plaintext
GET /projects/:id/snippets
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|---------------------|---------|-------------|
| `author.created_at` | 字符串 | 作者账户的创建日期和时间。 |
| `author.email` | 字符串 | 代码片段作者的电子邮件地址。 |
| `author.id` | 整数 | 代码片段作者的 ID。 |
| `author.name` | 字符串 | 代码片段作者的显示名称。 |
| `author.state` | 字符串 | 作者账户的状态。 |
| `author.username` | 字符串 | 代码片段作者的用户名。 |
| `created_at` | 字符串 | 代码片段创建日期和时间（ISO 8601 格式）。 |
| `description` | 字符串 | 代码片段的描述。 |
| `file_name` | 字符串 | 代码片段文件的名称。 |
| `id` | 整数 | 代码片段的 ID。 |
| `imported` | 布尔值 | 如果为 `true`，则表示代码片段是导入的。 |
| `imported_from` | 字符串 | 如果代码片段是导入的，则表示导入来源。 |
| `project_id` | 整数 | 包含代码片段的项目 ID。 |
| `raw_url` | 字符串 | 原始代码片段内容的直接 URL。 |
| `title` | 字符串 | 代码片段的标题。 |
| `updated_at` | 字符串 | 代码片段最后更新日期和时间（ISO 8601 格式）。 |
| `web_url` | 字符串 | 在极狐GitLab Web 界面中查看代码片段的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets"
```

响应示例：

```json
[
  {
    "id": 1,
    "title": "test",
    "file_name": "add.rb",
    "description": "Ruby test snippet",
    "author": {
      "id": 1,
      "username": "john_smith",
      "email": "john@example.com",
      "name": "John Smith",
      "state": "active",
      "created_at": "2012-05-23T08:00:58Z"
    },
    "updated_at": "2012-06-28T10:52:04Z",
    "created_at": "2012-06-28T10:52:04Z",
    "imported": false,
    "imported_from": "none",
    "project_id": 1,
    "web_url": "http://example.com/example/example/snippets/1",
    "raw_url": "http://example.com/example/example/snippets/1/raw"
  },
  {
    "id": 3,
    "title": "Configuration helper",
    "file_name": "config.yml",
    "description": "YAML configuration snippet",
    "author": {
      "id": 2,
      "username": "jane_doe",
      "email": "jane@example.com",
      "name": "Jane Doe",
      "state": "active",
      "created_at": "2013-02-15T10:30:20Z"
    },
    "updated_at": "2013-03-10T14:15:30Z",
    "created_at": "2013-03-01T09:45:12Z",
    "imported": false,
    "imported_from": "none",
    "project_id": 1,
    "web_url": "http://example.com/example/example/snippets/3",
    "raw_url": "http://example.com/example/example/snippets/3/raw"
  }
]
```

<a id="retrieve-a-snippet"></a>

## 获取一个代码片段

获取指定的项目代码片段。

```plaintext
GET /projects/:id/snippets/:snippet_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 项目代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|---------------------|---------|-------------|
| `author.created_at` | 字符串 | 作者账户的创建日期和时间。 |
| `author.email` | 字符串 | 代码片段作者的电子邮件地址。 |
| `author.id` | 整数 | 代码片段作者的 ID。 |
| `author.name` | 字符串 | 代码片段作者的显示名称。 |
| `author.state` | 字符串 | 作者账户的状态。 |
| `author.username` | 字符串 | 代码片段作者的用户名。 |
| `created_at` | 字符串 | 代码片段创建日期和时间（ISO 8601 格式）。 |
| `description` | 字符串 | 代码片段的描述。 |
| `file_name` | 字符串 | 代码片段文件的名称。 |
| `id` | 整数 | 代码片段的 ID。 |
| `imported` | 布尔值 | 如果为 `true`，则表示代码片段是导入的。 |
| `imported_from` | 字符串 | 如果代码片段是导入的，则表示导入来源。 |
| `project_id` | 整数 | 包含代码片段的项目 ID。 |
| `raw_url` | 字符串 | 原始代码片段内容的直接 URL。 |
| `title` | 字符串 | 代码片段的标题。 |
| `updated_at` | 字符串 | 代码片段最后更新日期和时间（ISO 8601 格式）。 |
| `web_url` | 字符串 | 在极狐GitLab Web 界面中查看代码片段的 URL。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets/2"
```

响应示例：

```json
{
  "id": 2,
  "title": "test",
  "file_name": "add.rb",
  "description": "Ruby test snippet",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "imported": false,
  "imported_from": "none",
  "project_id": 1,
  "web_url": "http://example.com/example/example/snippets/2",
  "raw_url": "http://example.com/example/example/snippets/2/raw"
}
```

<a id="create-a-snippet"></a>

## 创建一个代码片段

创建一个项目代码片段。用户必须具有创建代码片段的权限。

```plaintext
POST /projects/:id/snippets
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-------------------|-------------------|----------|-------------|
| `files` | 哈希数组 | 是 | 代码片段文件的数组。 |
| `files:content` | 字符串 | 是 | 代码片段文件的内容。 |
| `files:file_path` | 字符串 | 是 | 代码片段文件的文件路径。 |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `title` | 字符串 | 是 | 代码片段的标题。 |
| `content` | 字符串 | 否 | 已弃用：请改用 `files`。代码片段的内容。 |
| `description` | 字符串 | 否 | 代码片段的描述。 |
| `file_name` | 字符串 | 否 | 已弃用：请改用 `files`。代码片段文件的名称。 |
| `visibility` | 字符串 | 否 | 代码片段的可见性级别。可选值：`public`、`private` 和 `internal`。在 JihuLab.com 上，`internal` 值不可用。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|---------------------|---------|-------------|
| `author.created_at` | 字符串 | 作者账户的创建日期和时间。 |
| `author.email` | 字符串 | 代码片段作者的电子邮件地址。 |
| `author.id` | 整数 | 代码片段作者的 ID。 |
| `author.name` | 字符串 | 代码片段作者的显示名称。 |
| `author.state` | 字符串 | 作者账户的状态。 |
| `author.username` | 字符串 | 代码片段作者的用户名。 |
| `created_at` | 字符串 | 代码片段创建日期和时间（ISO 8601 格式）。 |
| `description` | 字符串 | 代码片段的描述。 |
| `file_name` | 字符串 | 代码片段文件的名称。 |
| `id` | 整数 | 代码片段的 ID。 |
| `imported` | 布尔值 | 如果为 `true`，则表示代码片段是导入的。 |
| `imported_from` | 字符串 | 如果代码片段是导入的，则表示导入来源。 |
| `project_id` | 整数 | 包含代码片段的项目 ID。 |
| `raw_url` | 字符串 | 原始代码片段内容的直接 URL。 |
| `title` | 字符串 | 代码片段的标题。 |
| `updated_at` | 字符串 | 代码片段最后更新日期和时间（ISO 8601 格式）。 |
| `web_url` | 字符串 | 在极狐GitLab Web 界面中查看代码片段的 URL。 |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"title": "Example Snippet Title", "description": "More verbose snippet description", "visibility": "private", "files": [{"file_path": "example.txt", "content": "source code \n with multiple lines\n"}]}' \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets"
```

响应示例：

```json
{
  "id": 1,
  "title": "Example Snippet Title",
  "file_name": "example.txt",
  "description": "More verbose snippet description",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "imported": false,
  "imported_from": "none",
  "project_id": 1,
  "web_url": "http://example.com/example/example/snippets/1",
  "raw_url": "http://example.com/example/example/snippets/1/raw"
}
```

<a id="update-a-snippet"></a>

## 更新一个代码片段

更新指定的项目代码片段。用户必须具有更改现有代码片段的权限。

对包含多个文件的代码片段的更新必须使用 `files` 属性。

```plaintext
PUT /projects/:id/snippets/:snippet_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------------------- | ----------------- | ------------- | ----------- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 项目代码片段的 ID。 |
| `files:action` | 字符串 | 有条件 | 对文件执行的操作类型。可选值：`create`、`update`、`delete`、`move`。使用 `files` 属性时必需。 |
| `content` | 字符串 | 否 | 已弃用：请改用 `files`。代码片段的内容。 |
| `description` | 字符串 | 否 | 代码片段的描述。 |
| `file_name` | 字符串 | 否 | 已弃用：请改用 `files`。代码片段文件的名称。 |
| `files` | 哈希数组 | 否 | 代码片段文件的数组。 |
| `files:content` | 字符串 | 否 | 代码片段文件的内容。 |
| `files:file_path` | 字符串 | 否 | 代码片段文件的文件路径。 |
| `files:previous_path` | 字符串 | 否 | 代码片段文件的前一路径。 |
| `title` | 字符串 | 否 | 代码片段的标题。 |
| `visibility` | 字符串 | 否 | 代码片段的可见性级别。可选值：`public`、`private` 和 `internal`。在 JihuLab.com 上，`internal` 值不可用。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|---------------------|---------|-------------|
| `author.created_at` | 字符串 | 作者账户的创建日期和时间。 |
| `author.email` | 字符串 | 代码片段作者的电子邮件地址。 |
| `author.id` | 整数 | 代码片段作者的 ID。 |
| `author.name` | 字符串 | 代码片段作者的显示名称。 |
| `author.state` | 字符串 | 作者账户的状态。 |
| `author.username` | 字符串 | 代码片段作者的用户名。 |
| `created_at` | 字符串 | 代码片段创建日期和时间（ISO 8601 格式）。 |
| `description` | 字符串 | 代码片段的描述。 |
| `file_name` | 字符串 | 代码片段文件的名称。 |
| `id` | 整数 | 代码片段的 ID。 |
| `imported` | 布尔值 | 如果为 `true`，则表示代码片段是导入的。 |
| `imported_from` | 字符串 | 如果代码片段是导入的，则表示导入来源。 |
| `project_id` | 整数 | 包含代码片段的项目 ID。 |
| `raw_url` | 字符串 | 原始代码片段内容的直接 URL。 |
| `title` | 字符串 | 代码片段的标题。 |
| `updated_at` | 字符串 | 代码片段最后更新日期和时间（ISO 8601 格式）。 |
| `web_url` | 字符串 | 在极狐GitLab Web 界面中查看代码片段的 URL。 |

请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"title": "Updated Snippet Title", "description": "More verbose snippet description", "visibility": "private", "files": [{"action": "update", "file_path": "example.txt", "content": "updated source code \n with multiple lines\n"}]}' \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets/2"
```

响应示例：

```json
{
  "id": 2,
  "title": "Updated Snippet Title",
  "file_name": "example.txt",
  "description": "More verbose snippet description",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "imported": false,
  "imported_from": "none",
  "project_id": 1,
  "web_url": "http://example.com/example/example/snippets/2",
  "raw_url": "http://example.com/example/example/snippets/2/raw"
}
```

<a id="delete-a-snippet"></a>

## 删除一个代码片段

删除指定的项目代码片段。操作成功时返回 `204 No Content` 状态码，如果资源未找到则返回 `404`。

```plaintext
DELETE /projects/:id/snippets/:snippet_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 项目代码片段的 ID。 |

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets/2"
```

<a id="retrieve-snippet-content"></a>

## 获取代码片段内容

以纯文本形式获取原始项目代码片段。

```plaintext
GET /projects/:id/snippets/:snippet_id/raw
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 项目代码片段的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets/2/raw"
```

<a id="retrieve-snippet-repository-file-content"></a>

## 获取代码片段仓库文件内容

以纯文本形式获取原始文件内容。

```plaintext
GET /projects/:id/snippets/:snippet_id/files/:ref/:file_path/raw
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `file_path` | 字符串 | 是 | 文件的 URL 编码路径，例如 `snippet%2Erb`。 |
| `ref` | 字符串 | 是 | 分支、标签或提交的名称，例如 `main`。 |
| `snippet_id` | 整数 | 是 | 项目代码片段的 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets/2/files/master/snippet%2Erb/raw"
```

<a id="retrieve-user-agent-details"></a>

## 获取用户代理详情

获取指定代码片段的用户代理详情。仅管理员可访问。

```plaintext
GET /projects/:id/snippets/:snippet_id/user_agent_detail
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|---------------------|---------|-------------|
| `akismet_submitted` | 布尔值 | 如果为 `true`，则表示代码片段已提交给 Akismet 进行垃圾检测。 |
| `ip_address` | 字符串 | 创建代码片段的用户的 IP 地址。 |
| `user_agent` | 字符串 | 用于创建代码片段的浏览器的用户代理字符串。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/snippets/2/user_agent_detail"
```

响应示例：

```json
{
  "user_agent": "AppleWebKit/537.36",
  "ip_address": "127.0.0.1",
  "akismet_submitted": false
}
```