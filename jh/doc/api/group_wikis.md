---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组维基 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来管理[群组维基](../user/project/wiki/group.md)。
此外还提供了[项目维基](wikis.md)的 API。

维基页面的评论称为 `notes`。要与之交互，请使用 [评论 API](notes.md#group-wikis)。

<a id="list-wiki-pages"></a>

## 列出维基页面

列出指定群组的所有维基页面。

```plaintext
GET /groups/:id/wikis
```

| 属性      | 类型           | 是否必需 | 描述 |
| -------------- | -------------- | -------- | ----------- |
| `id`           | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `with_content` | 布尔值        | 否       | 包含页面内容。 |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/wikis?with_content=1"
```

示例响应：

```json
[
  {
    "content" : "Here is an instruction how to deploy this project.",
    "format" : "markdown",
    "slug" : "deploy",
    "title" : "deploy",
    "encoding": "UTF-8"
  },
  {
    "content" : "Our development process is described here.",
    "format" : "markdown",
    "slug" : "development",
    "title" : "development",
    "encoding": "UTF-8"
  },{
    "content" : "*  [Deploy](deploy)\n*  [Development](development)",
    "format" : "markdown",
    "slug" : "home",
    "title" : "home",
    "encoding": "UTF-8"
  }
]
```

<a id="retrieve-a-wiki-page"></a>

## 检索维基页面

检索指定群组的维基页面。

```plaintext
GET /groups/:id/wikis/:slug
```

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `slug`        | 字符串         | 是      | 维基页面的 URL 编码 slug（唯一字符串），例如 `dir%2Fpage_name`。 |
| `render_html` | 布尔值        | 否       | 返回维基页面渲染后的 HTML。 |
| `version`     | 字符串         | 否       | 维基页面版本的 SHA。 |

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/wikis/home"
```

示例响应：

```json
{
  "content" : "home page",
  "format" : "markdown",
  "slug" : "home",
  "title" : "home",
  "encoding": "UTF-8"
}
```

<a id="create-a-wiki-page"></a>

## 创建维基页面

为特定项目创建具有给定标题、slug 和内容的维基页面。

```plaintext
POST /projects/:id/wikis
```

| 属性 | 类型           | 是否必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `content` | 字符串         | 是      | 维基页面的内容。 |
| `title`   | 字符串         | 是      | 维基页面的标题。 |
| `format`  | 字符串         | 否       | 维基页面的格式。可用格式为：`markdown`（默认）、`rdoc`、`asciidoc` 和 `org`。 |

```shell
curl --request POST \
     --data "format=rdoc&title=Hello&content=Hello world" \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/groups/1/wikis"
```

示例响应：

```json
{
  "content" : "Hello world",
  "format" : "markdown",
  "slug" : "Hello",
  "title" : "Hello",
  "encoding": "UTF-8"
}
```

<a id="update-a-wiki-page"></a>

## 更新维基页面

更新维基页面。至少需要一个参数来更新维基页面。

```plaintext
PUT /groups/:id/wikis/:slug
```

| 属性 | 类型           | 是否必需                           | 描述 |
| --------- | -------------- | ---------------------------------- | ----------- |
| `id`      | 整数或字符串 | 是                                | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `content` | 字符串         | 是（如果未提供 `title`）   | 维基页面的内容。 |
| `title`   | 字符串         | 是（如果未提供 `content`） | 维基页面的标题。 |
| `format`  | 字符串         | 否                                 | 维基页面的格式。可用格式为 `markdown`（默认）、`rdoc`、`asciidoc` 和 `org`。 |
| `slug`    | 字符串         | 是                                | 维基页面的 URL 编码 slug（唯一字符串）。例如：`dir%2Fpage_name`。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/wikis/foo" \
  --data "format=rdoc" \
  --data "title=Docs" \
  --data "content=documentation"
```

示例响应：

```json
{
  "content" : "documentation",
  "format" : "markdown",
  "slug" : "Docs",
  "title" : "Docs",
  "encoding": "UTF-8"
}
```

<a id="delete-a-wiki-page"></a>

## 删除维基页面

从特定项目中删除具有指定 slug 的维基页面。

```plaintext
DELETE /groups/:id/wikis/:slug
```

| 属性 | 类型           | 是否必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `slug`    | 字符串         | 是      | 维基页面的 URL 编码 slug（唯一字符串），例如 `dir%2Fpage_name`。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/wikis/foo"
```

如果成功，预期会收到一个 `204 No Content` HTTP 响应，其正文为空。

<a id="upload-an-attachment-to-the-wiki-repository"></a>

## 上传附件到维基仓库

将文件上传到特定项目的维基仓库中的附件文件夹。附件文件夹就是 `uploads` 文件夹。

```plaintext
POST /groups/:id/wikis/attachments
```

| 属性     | 类型           | 是否必需 | 描述 |
| ------------- | -------------- | -------- | ----------- |
| `id`          | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `file`        | 字符串         | 是      | 要上传的附件。 |
| `branch`      | 字符串         | 否       | 分支的名称。默认为维基仓库的默认分支。 |

要从文件系统上传文件，请使用 `--form` 参数。这会使 cURL 使用标头 `Content-Type: multipart/form-data` 来发布数据。
`file=` 参数必须指向文件系统上的文件，并以 `@` 开头。例如：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/wikis/attachments" \
  --form "file=@dk.png"
```

示例响应：

```json
{
  "file_name" : "dk.png",
  "file_path" : "uploads/6a061c4cf9f1c28cb22c384b4b8d4e3c/dk.png",
  "branch" : "main",
  "link" : {
    "url" : "uploads/6a061c4cf9f1c28cb22c384b4b8d4e3c/dk.png",
    "markdown" : "![dk](uploads/6a061c4cf9f1c28cb22c384b4b8d4e3c/dk.png)"
  }
}
```