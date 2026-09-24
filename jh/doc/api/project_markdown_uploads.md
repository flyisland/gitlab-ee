---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Markdown 上传 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理可在议题、合并请求、代码段或 Wiki 页面的 Markdown 文本中引用的 [Markdown 上传](../security/user_file_uploads.md)。

<a id="create-an-upload"></a>

## 创建上传

{{< history >}}

- 在极狐GitLab 15.10 GA。功能标志 `enforce_max_attachment_size_upload_api` 已移除。
- `full_path` 响应属性模式在极狐GitLab 17.1 变更。
- `id` 属性在极狐GitLab 17.3 引入。

{{< /history >}}

将文件上传到指定项目，以便在议题或合并请求描述或评论中使用。

```plaintext
POST /projects/:id/uploads
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `file` | string | 是 | 要上传的文件。 |
| `id` | integer 或 string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |

要从文件系统上传文件，请使用 `--form` 参数。这会使 cURL 使用 `Content-Type: multipart/form-data` 头部发送数据。`file=` 参数必须指向文件系统上的文件，并以 `@` 开头。

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --form "file=@dk.png" "https://gitlab.example.com/api/v4/projects/5/uploads"
```

示例响应：

```json
{
  "id": 5,
  "alt": "dk",
  "url": "/uploads/66dbcd21ec5d24ed6ea225176098d52b/dk.png",
  "full_path": "/-/project/1234/uploads/66dbcd21ec5d24ed6ea225176098d52b/dk.png",
  "markdown": "![dk](/uploads/66dbcd21ec5d24ed6ea225176098d52b/dk.png)"
}
```

在响应中：

- `full_path` 是文件的绝对路径。
- `url` 可用于 Markdown 上下文中。当使用 `markdown` 格式时，链接会被展开。

<a id="list-uploads"></a>

## 列出上传

{{< history >}}

- 在极狐GitLab 17.2 引入。

{{< /history >}}

按 `created_at` 降序排列列出项目的所有上传。

前提条件：

- 维护者或所有者角色。

```plaintext
GET /projects/:id/uploads
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|:----------|:------------------|:---------|:------------|
| `id` | integer 或 string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/uploads"
```

示例响应：

```json
[
  {
    "id": 1,
    "size": 1024,
    "filename": "image.png",
    "created_at":"2024-06-20T15:53:03.067Z",
    "uploaded_by": {
      "id": 18,
      "name" : "Alexandra Bashirian",
      "username" : "eileen.lowe"
    }
  },
  {
    "id": 2,
    "size": 512,
    "filename": "other-image.png",
    "created_at":"2024-06-19T15:53:03.067Z",
    "uploaded_by": null
  }
]
```

<a id="download-an-uploaded-file-by-id"></a>

## 通过 ID 下载上传的文件

{{< history >}}

- 在极狐GitLab 17.2 引入。

{{< /history >}}

通过 ID 下载上传的文件。

前提条件：

- 维护者或所有者角色。

```plaintext
GET /projects/:id/uploads/:upload_id
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|:------------|:------------------|:---------|:------------|
| `id` | integer 或 string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `upload_id` | integer | 是 | 上传的 ID。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 状态码并在响应体中包含上传的文件。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/uploads/1"
```

<a id="download-an-uploaded-file-by-secret-and-filename"></a>

## 通过密钥和文件名下载上传的文件

{{< history >}}

- 在极狐GitLab 17.4 引入。

{{< /history >}}

通过密钥和文件名下载上传的文件。

前提条件：

- 访客、计划者、报告者、开发者、维护者或所有者角色。

```plaintext
GET /projects/:id/uploads/:secret/:filename
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|:-----------|:------------------|:---------|:------------|
| `id` | integer 或 string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `secret` | string | 是 | 上传的 32 字符密钥。 |
| `filename` | string | 是 | 上传的文件名。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 状态码并在响应体中包含上传的文件。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/uploads/648d97c6eef5fc5df8d1004565b3ee5a/sample.jpg"
```

<a id="delete-an-uploaded-file-by-id"></a>

## 通过 ID 删除上传的文件

{{< history >}}

- 在极狐GitLab 17.2 引入。

{{< /history >}}

通过 ID 删除上传的文件。

前提条件：

- 维护者或所有者角色。

```plaintext
DELETE /projects/:id/uploads/:upload_id
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|:------------|:------------------|:---------|:------------|
| `id` | integer 或 string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `upload_id` | integer | 是 | 上传的 ID。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 状态码，响应体为空。

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/uploads/1"
```

<a id="delete-an-uploaded-file-by-secret-and-filename"></a>

## 通过密钥和文件名删除上传的文件

{{< history >}}

- 在极狐GitLab 17.4 引入。

{{< /history >}}

通过密钥和文件名删除上传的文件。

前提条件：

- 维护者或所有者角色。

```plaintext
DELETE /projects/:id/uploads/:secret/:filename
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|:-----------|:------------------|:---------|:------------|
| `id` | integer 或 string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `secret` | string | 是 | 上传的 32 字符密钥。 |
| `filename` | string | 是 | 上传的文件名。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 状态码，响应体为空。

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/5/uploads/648d97c6eef5fc5df8d1004565b3ee5a/sample.jpg"
```