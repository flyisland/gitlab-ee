---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目 Wiki API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [项目 Wiki](../user/project/wiki/_index.md)。也提供了 [群组 Wiki](group_wikis.md) 的 API。

Wiki 页面上的评论称为 `notes`。要与之交互，请使用 [notes API](notes.md#project-wikis)。

<a id="list-all-wiki-pages"></a>

## 列出所有 Wiki 页面

列出指定项目的所有 Wiki 页面。

```plaintext
GET /projects/:id/wikis
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `with_content` | 布尔值 | 否 | 是否包含页面内容。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis?with_content=1"
```

响应示例：

```json
[
  {
    "content" : "这里是如何部署该项目的说明。",
    "format" : "markdown",
    "slug" : "deploy",
    "title" : "deploy",
    "encoding": "UTF-8"
  },
  {
    "content" : "我们的开发流程在这里描述。",
    "format" : "markdown",
    "slug" : "development",
    "title" : "development",
    "encoding": "UTF-8"
  },
  {
    "content" : "*  [部署](deploy)\n*  [开发](development)",
    "format" : "markdown",
    "slug" : "home",
    "title" : "home",
    "encoding": "UTF-8"
  }
]
```

<a id="retrieve-a-wiki-page"></a>

## 获取一个 Wiki 页面

获取指定项目的一个 Wiki 页面。

```plaintext
GET /projects/:id/wikis/:slug
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `slug` | 字符串 | 是 | Wiki 页面的 URL 编码标识（唯一字符串），例如 `dir%2Fpage_name`。 |
| `render_html` | 布尔值 | 否 | 是否返回渲染后的 HTML。 |
| `version` | 字符串 | 否 | Wiki 页面版本的 SHA。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis/home"
```

响应示例：

```json
{
  "content" : "首页",
  "format" : "markdown",
  "slug" : "home",
  "title" : "home",
  "encoding": "UTF-8"
}
```

<a id="create-a-wiki-page"></a>

## 创建 Wiki 页面

为指定项目创建一个具有给定标题、标识和内容的 Wiki 页面。

```plaintext
POST /projects/:id/wikis
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `content` | 字符串 | 是 | Wiki 页面的内容。 |
| `title` | 字符串 | 是 | Wiki 页面的标题。 |
| `format` | 字符串 | 否 | Wiki 页面的格式。可用格式有：`markdown`（默认）、`rdoc`、`asciidoc` 和 `org`。 |

```shell
curl --data "format=rdoc&title=Hello&content=Hello world" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis"
```

响应示例：

```json
{
  "content" : "Hello world",
  "format" : "markdown",
  "slug" : "Hello",
  "title" : "Hello",
  "encoding": "UTF-8"
}
```

对于包含特殊字符和图表的 Markdown 内容，请使用 `--data-urlencode` 并引用文件来自动处理编码。

例如，创建一个名为 `content.md` 的文件，包含你的 Wiki 内容，然后运行：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data-urlencode "title=包含复杂内容的页面" \
  --data-urlencode "content@content.md" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis"
```

`--data-urlencode "content@content.md"` 选项会对 Markdown 文件的内容进行 URL 编码，并将其赋给 `content` 属性。这种编码可以处理特殊字符、换行符和复杂的 Markdown 语法，否则可能导致错误。

响应示例：

```json
{
"content": "<content.md 的内容>",
"format": "markdown",
"slug": "包含复杂内容的页面",
"title": "包含复杂内容的页面",
"encoding": "UTF-8"
}
```

<a id="update-a-wiki-page"></a>

## 更新 Wiki 页面

更新指定的 Wiki 页面。至少需要一个参数来更新 Wiki 页面。

```plaintext
PUT /projects/:id/wikis/:slug
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `content` | 字符串 | 如果未提供 `title` 则是 | Wiki 页面的内容。 |
| `title` | 字符串 | 如果未提供 `content` 则是 | Wiki 页面的标题。 |
| `format` | 字符串 | 否 | Wiki 页面的格式。可用格式有：`markdown`（默认）、`rdoc`、`asciidoc` 和 `org`。 |
| `slug` | 字符串 | 是 | Wiki 页面的 URL 编码标识（唯一字符串），例如 `dir%2Fpage_name`。 |

```shell
curl --request PUT \
  --data "format=rdoc&content=documentation&title=Docs" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis/foo"
```

响应示例：

```json
{
  "content" : "文档",
  "format" : "markdown",
  "slug" : "Docs",
  "title" : "Docs",
  "encoding": "UTF-8"
}
```

<a id="delete-a-wiki-page"></a>

## 删除 Wiki 页面

删除指定的 Wiki 页面。

```plaintext
DELETE /projects/:id/wikis/:slug
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `slug` | 字符串 | 是 | Wiki 页面的 URL 编码标识（唯一字符串），例如 `dir%2Fpage_name`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis/foo"
```

如果成功，预期返回 `204 No Content` HTTP 响应，响应体为空。

<a id="upload-an-attachment-to-the-wiki-repository"></a>

## 上传附件到 Wiki 仓库

将文件上传到 Wiki 仓库内的附件文件夹。附件文件夹是 `uploads` 文件夹。

```plaintext
POST /projects/:id/wikis/attachments
```

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `file` | 字符串 | 是 | 要上传的附件。 |
| `branch` | 字符串 | 否 | 分支名称。默认为 Wiki 仓库的默认分支。 |

要从文件系统上传文件，请使用 `--form` 参数。这会使 cURL 使用 `Content-Type: multipart/form-data` 头来发送数据。`file=` 参数必须指向文件系统上的一个文件，并在前面加上 `@`。例如：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "file=@dk.png" \
  --url "https://gitlab.example.com/api/v4/projects/1/wikis/attachments"
```

响应示例：

```json
{
  "file_name" : "dk.png",
  "file_path" : "uploads/6a061c4cf9f1c28cb22c384b4b8d4e3c/dk.png",
  "branch" : "main",
  "link" : {
    "url" : "uploads/6a061c4cf9f1c28cb22c384b4b8d4e3c/dk.png",
    "markdown" : "![附件描述](uploads/6a061c4cf9f1c28cb22c384b4b8d4e3c/dk.png)"
  }
}
```