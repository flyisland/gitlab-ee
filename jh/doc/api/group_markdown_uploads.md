---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 Markdown 上传 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理可在史诗或 Wiki 页面的 Markdown 文本中引用的 [Markdown 上传](../security/user_file_uploads.md)文件。

<a id="upload-a-file-to-a-group"></a>

## 上传文件到群组

{{< history >}}

- 于极狐GitLab 19.0 引入。

{{< /history >}}

将文件上传到指定群组。返回文件的 Markdown 格式链接。

你必须具有访客、计划者、报告者、开发者、维护者或所有者角色才能使用此端点。

```plaintext
POST /groups/:id/uploads
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `file`    | file              | 是      | 要上传的文件。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "file=@/path/to/image.png" \
  --url "https://gitlab.example.com/api/v4/groups/5/uploads"
```

示例响应：

```json
{
  "id": 3,
  "alt": "image",
  "url": "/uploads/648d97c6eef5fc5df8d1004565b3ee5a/image.png",
  "full_path": "/-/group/5/uploads/648d97c6eef5fc5df8d1004565b3ee5a/image.png",
  "markdown": "![image](/uploads/648d97c6eef5fc5df8d1004565b3ee5a/image.png)"
}
```

<a id="list-all-uploads-for-a-group"></a>

## 列出群组的所有上传文件

{{< history >}}

- 于极狐GitLab 17.2 引入。

{{< /history >}}

列出指定群组的所有上传文件，并按 `created_at` 降序排列。

你必须具有维护者或所有者角色才能使用此端点。

```plaintext
GET /groups/:id/uploads
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/uploads"
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

## 通过 ID 下载已上传的文件

{{< history >}}

- 于极狐GitLab 17.2 引入。

{{< /history >}}

下载具有指定 ID 的上传文件。
你必须具有维护者或所有者角色才能使用此端点。

```plaintext
GET /groups/:id/uploads/:upload_id
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `upload_id` | integer           | 是      | 上传文件的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/uploads/1"
```

如果成功，将返回 [`200`](rest/troubleshooting.md#status-codes) 状态码，并在响应体中包含上传的文件。

<a id="download-an-uploaded-file-by-secret-and-filename"></a>

## 通过密钥和文件名下载已上传的文件

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

下载具有指定密钥和文件名的上传文件。
你必须具有访客、计划者、报告者、开发者、维护者或所有者角色才能使用此端点。

```plaintext
GET /groups/:id/uploads/:secret/:filename
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `secret`    | string            | 是      | 上传文件的 32 位字符密钥。 |
| `filename`  | string            | 是      | 上传文件的文件名。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/uploads/648d97c6eef5fc5df8d1004565b3ee5a/sample.jpg"
```

如果成功，将返回 [`200`](rest/troubleshooting.md#status-codes) 状态码，并在响应体中包含上传的文件。

<a id="delete-an-uploaded-file-by-id"></a>

## 通过 ID 删除已上传的文件

{{< history >}}

- 于极狐GitLab 17.2 引入。

{{< /history >}}

删除具有指定 ID 的上传文件。
你必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /groups/:id/uploads/:upload_id
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `upload_id` | integer           | 是      | 上传文件的 ID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/uploads/1"
```

如果成功，将返回 [`204`](rest/troubleshooting.md#status-codes) 状态码，且不包含任何响应体。

<a id="delete-an-uploaded-file-by-secret-and-filename"></a>

## 通过密钥和文件名删除已上传的文件

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

删除具有指定密钥和文件名的上传文件。
你必须具有维护者或所有者角色才能使用此端点。

```plaintext
DELETE /groups/:id/uploads/:secret/:filename
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `secret`    | string            | 是      | 上传文件的 32 位字符密钥。 |
| `filename`  | string            | 是      | 上传文件的文件名。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/5/uploads/648d97c6eef5fc5df8d1004565b3ee5a/sample.jpg"
```

如果成功，将返回 [`204`](rest/troubleshooting.md#status-codes) 状态码，且不包含任何响应体。