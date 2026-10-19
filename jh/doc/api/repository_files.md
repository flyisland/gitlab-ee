---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于管理极狐GitLab 中 Git 代码仓库文件的 REST API 文档。
title: 代码仓库文件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理[代码仓库文件](../user/project/repository/_index.md)。您还可以为此 API [配置速率限制](../rate_limits/api/repository-files.md)。

<a id="available-scopes-for-personal-access-tokens"></a>

## 个人访问令牌可用的范围

[个人访问令牌](../user/profile/personal_access_tokens.md)支持以下范围：

| 范围             | 描述 |
|-------------------|-------------|
| `api`             | 允许对代码仓库文件进行读写访问。 |
| `read_api`        | 允许对代码仓库文件进行读取访问。 |
| `read_repository` | 允许对代码仓库文件进行读取访问。 |

<a id="retrieve-a-file-from-a-repository"></a>

## 从代码仓库中检索文件

检索代码仓库中指定文件的信息。这些信息包括名称、大小和文件内容。文件内容采用 Base64 编码。如果代码仓库可公开访问，您无需身份验证即可访问此端点。

对于大于 10 MB 的 blob，此端点的速率限制为每分钟 5 个请求。

```plaintext
GET /projects/:id/repository/files/:file_path
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `file_path` | string            | 是      | 文件的 URL 编码完整路径，例如 `lib%2Fclass%2Erb`。 |
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ref`       | string            | 是      | 分支、标签或提交的名称。使用 `HEAD` 可自动使用默认分支。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性          | 类型    | 描述 |
|--------------------|---------|-------------|
| `blob_id`          | string  | Blob SHA。   |
| `commit_id`        | string  | 该文件的提交 SHA。 |
| `content`          | string  | Base64 编码的文件内容。 |
| `content_sha256`   | string  | 返回的 `content`的 SHA256 哈希值。 |
| `encoding`         | string  | 文件内容使用的编码。 |
| `execute_filemode` | boolean | 如果为 `true`，则在文件上设置执行标志。 |
| `file_name`        | string  | 文件名。 |
| `file_path`        | string  | 文件的完整路径。 |
| `last_commit_id`   | string  | 修改此文件的最后一次提交的 SHA。 |
| `ref`              | string  | 所使用的分支、标签或提交的名称。 |
| `size`             | integer | 原始 Git blob 的大小（以字节为单位）。 |

> [!note]
> 对于在 Git 中未以有效 UTF-8 存储的文本文件（例如 UTF-16 或 `ISO-8859-1`），
> `content` 会在 Base64 编码之前转换为 UTF-8。
> 在这些情况下：
>
> - `size` 反映原始 blob 大小，可能与解码后内容的长度不同。
> - `content_sha256` 是转换后内容的哈希值，而不是原始 blob 的哈希值。
>   它可能与通过 `git clone` 或选择**下载**时同一文件的 `sha256sum` 不匹配。
>
> 要检索存储在 Git 中的确切字节，请使用[原始文件端点](#retrieve-a-raw-file-from-a-repository)。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb?ref=main"
```

如果您不知道分支名称或想使用默认分支，可以将 `HEAD` 用作 `ref` 值。例如：

```shell
curl --header "PRIVATE-TOKEN: " \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb?ref=HEAD"
```

示例响应：

```json
{
  "file_name": "key.rb",
  "file_path": "app/models/key.rb",
  "size": 1476,
  "encoding": "base64",
  "content": "IyA9PSBTY2hlbWEgSW5mb3...",
  "content_sha256": "4c294617b60715c1d218e61164a3abd4808a4284cbc30e6728a01ad9aada4481",
  "ref": "main",
  "blob_id": "79f7bbd25901e8334750839545a9bd021f0e4c83",
  "commit_id": "d5a3ff139356ce33e37e73add446f16869741b50",
  "last_commit_id": "570e7b2abdd848b95f2f578043fc23bd6f6fd24d",
  "execute_filemode": false
}
```

<a id="get-file-metadata-only"></a>

### 仅获取文件元数据

您还可以使用 `HEAD` 仅获取文件元数据。

```plaintext
HEAD /projects/:id/repository/files/:file_path
```

```shell
curl --head --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb?ref=main"
```

示例响应：

```plaintext
HTTP/1.1 200 OK
...
X-Gitlab-Blob-Id: 79f7bbd25901e8334750839545a9bd021f0e4c83
X-Gitlab-Commit-Id: d5a3ff139356ce33e37e73add446f16869741b50
X-Gitlab-Content-Sha256: 4c294617b60715c1d218e61164a3abd4808a4284cbc30e6728a01ad9aada4481
X-Gitlab-Encoding: base64
X-Gitlab-File-Name: key.rb
X-Gitlab-File-Path: app/models/key.rb
X-Gitlab-Last-Commit-Id: 570e7b2abdd848b95f2f578043fc23bd6f6fd24d
X-Gitlab-Ref: main
X-Gitlab-Size: 1476
X-Gitlab-Execute-Filemode: false
...
```

<a id="retrieve-file-blame-history-from-a-repository"></a>

## 从代码仓库中检索文件追溯历史

检索代码仓库中指定文件的追溯历史。每个追溯范围包含若干行及其对应的提交信息。

```plaintext
GET /projects/:id/repository/files/:file_path/blame
```

支持的属性：

| 属性      | 类型              | 是否必需 | 描述 |
|----------------|-------------------|----------|-------------|
| `file_path`    | string            | 是      | 文件的 URL 编码完整路径，例如 `lib%2Fclass%2Erb`。 |
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ref`          | string            | 是      | 分支、标签或提交的名称。使用 `HEAD` 可自动使用默认分支。 |
| `range`        | hash              | 否       | 追溯范围。 |
| `range[end]`   | integer           | 否       | 要追溯的范围的最后一行。 |
| `range[start]` | integer           | 否       | 要追溯的范围的第一行。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `commit`  | object | 追溯范围的提交信息。 |
| `lines`   | array  | 此追溯范围的行数组。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/path%2Fto%2Ffile.rb/blame?ref=main"
```

示例响应：

```json
[
  {
    "commit": {
      "id": "d42409d56517157c48bf3bd97d3f75974dde19fb",
      "message": "Add feature\n\nalso fix bug\n",
      "parent_ids": [
        "cc6e14f9328fa6d7b5a0d3c30dc2002a3f2a3822"
      ],
      "authored_date": "2015-12-18T08:12:22.000Z",
      "author_name": "John Doe",
      "author_email": "john.doe@example.com",
      "committed_date": "2015-12-18T08:12:22.000Z",
      "committer_name": "John Doe",
      "committer_email": "john.doe@example.com"
    },
    "lines": [
      "require 'fileutils'",
      "require 'open3'",
      ""
    ]
  }
]
```

<a id="get-file-blame-metadata-only"></a>

### 仅获取文件追溯元数据

使用 `HEAD` 方法仅返回文件追溯元数据。

```plaintext
HEAD /projects/:id/repository/files/:file_path/blame
```

```shell
curl --head --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/path%2Fto%2Ffile.rb/blame?ref=main"
```

示例响应：

```plaintext
HTTP/1.1 200 OK
...
X-Gitlab-Blob-Id: 79f7bbd25901e8334750839545a9bd021f0e4c83
X-Gitlab-Commit-Id: d5a3ff139356ce33e37e73add446f16869741b50
X-Gitlab-Content-Sha256: 4c294617b60715c1d218e61164a3abd4808a4284cbc30e6728a01ad9aada4481
X-Gitlab-Encoding: base64
X-Gitlab-File-Name: file.rb
X-Gitlab-File-Path: path/to/file.rb
X-Gitlab-Last-Commit-Id: 570e7b2abdd848b95f2f578043fc23bd6f6fd24d
X-Gitlab-Ref: main
X-Gitlab-Size: 1476
X-Gitlab-Execute-Filemode: false
...
```

<a id="request-a-blame-range"></a>

### 请求追溯范围

要请求追溯范围，请指定 `range[start]` 和 `range[end]` 参数，并给出文件的起始和结束行号。

```shell
curl --head --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/path%2Fto%2Ffile.rb/blame?ref=main&range[start]=1&range[end]=2"
```

示例响应：

```json
[
  {
    "commit": {
      "id": "d42409d56517157c48bf3bd97d3f75974dde19fb",
      "message": "Add feature\n\nalso fix bug\n",
      "parent_ids": [
        "cc6e14f9328fa6d7b5a0d3c30dc2002a3f2a3822"
      ],
      "authored_date": "2015-12-18T08:12:22.000Z",
      "author_name": "John Doe",
      "author_email": "john.doe@example.com",
      "committed_date": "2015-12-18T08:12:22.000Z",
      "committer_name": "John Doe",
      "committer_email": "john.doe@example.com"
    },
    "lines": [
      "require 'fileutils'",
      "require 'open3'"
    ]
  }
]
```

<a id="retrieve-a-raw-file-from-a-repository"></a>

## 从代码仓库中检索原始文件

检索代码仓库中指定文件的原始内容。

```plaintext
GET /projects/:id/repository/files/:file_path/raw
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `file_path` | string            | 是      | 文件的 URL 编码完整路径，例如 `lib%2Fclass%2Erb`。 |
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `lfs`       | boolean           | 否       | 如果为 `true`，则确定响应应为 Git LFS 文件内容，而不是指针。如果文件未由 Git LFS 跟踪，则忽略此项。默认为 `false`。 |
| `ref`       | string            | 否       | 分支、标签或提交的名称。默认为项目的 `HEAD`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb/raw?ref=main"
```

> [!note]
> 与[从代码仓库中检索文件](#retrieve-a-file-from-a-repository)类似，
> 您可以使用 `HEAD` 仅获取文件元数据。

<a id="create-a-file-in-a-repository"></a>

## 在代码仓库中创建文件

在指定代码仓库中创建文件。要通过单个请求创建多个文件，请参阅[提交 API](commits.md#create-a-commit)。

```plaintext
POST /projects/:id/repository/files/:file_path
```

> [!note]
> 此端点受[请求大小和速率限制](../administration/instance_limits.md#commits-and-files-api-limits)约束。超过默认 300 MB 限制的请求会被拒绝。大于 20 MB 的请求速率限制为每 30 秒 3 个请求。

支持的属性：

| 属性          | 类型              | 是否必需 | 描述 |
|--------------------|-------------------|----------|-------------|
| `branch`           | string            | 是      | 要创建的分支名称。提交将添加到此分支。 |
| `commit_message`   | string            | 是      | 提交信息。 |
| `content`          | string            | 是      | 文件的内容。 |
| `file_path`        | string            | 是      | 文件的 URL 编码完整路径。例如：`lib%2Fclass%2Erb`。 |
| `id`               | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email`     | string            | 否       | 提交作者的电子邮件地址。 |
| `author_name`      | string            | 否       | 提交作者的姓名。 |
| `encoding`         | string            | 否       | 将编码更改为 `base64`。默认为 `text`。 |
| `execute_filemode` | boolean           | 否       | 如果为 `true`，则在文件上启用 `execute` 标志。如果为 `false`，则在文件上禁用 `execute` 标志。 |
| `start_branch`     | string            | 否       | 用于创建分支的基础分支名称。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性   | 类型   | 描述 |
|-------------|--------|-------------|
| `branch`    | string | 创建文件所在的分支名称。 |
| `file_path` | string | 所创建文件的路径。 |

```shell
curl --request POST \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header "Content-Type: application/json" \
  --data '{"branch": "main", "author_email": "author@example.com", "author_name": "Firstname Lastname",
            "content": "some content", "commit_message": "create a new file"}' \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fproject%2Erb"
```

示例响应：

```json
{
  "file_path": "app/project.rb",
  "branch": "main"
}
```

<a id="update-a-file-in-a-repository"></a>

## 更新代码仓库中的文件

更新代码仓库中指定的文件。要通过单个请求更新多个文件，请参阅[提交 API](commits.md#create-a-commit)。

```plaintext
PUT /projects/:id/repository/files/:file_path
```

> [!note]
> 此端点受[请求大小和速率限制](../administration/instance_limits.md#commits-and-files-api-limits)约束。超过默认 300 MB 限制的请求会被拒绝。大于 20 MB 的请求速率限制为每 30 秒 3 个请求。

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
| ---------------- | ----------------- | -------- | ----------- |
| `branch`         | string            | 是      | 要创建的分支名称。提交将添加到此分支。 |
| `commit_message` | string            | 是      | 提交信息。 |
| `content`        | string            | 是      | 文件的内容。 |
| `file_path`      | string            | 是      | 文件的 URL 编码完整路径。例如：`lib%2Fclass%2Erb`。 |
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)  |
| `author_email`   | string            | 否       | 提交作者的电子邮件地址。 |
| `author_name`    | string            | 否       | 提交作者的姓名。 |
| `encoding`       | string            | 否       | 将编码更改为 `base64`。默认为 `text`。 |
| `execute_filemode` | boolean         | 否       | 如果为 `true`，则在文件上启用 `execute` 标志。如果为 `false`，则在文件上禁用 `execute` 标志。 |
| `last_commit_id` | string            | 否       | 最后一次已知的文件提交 ID。 |
| `start_branch`   | string            | 否       | 用于创建分支的基础分支名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性   | 类型   | 描述 |
|-------------|--------|-------------|
| `branch`    | string | 更新文件所在的分支名称。 |
| `file_path` | string | 所更新文件的路径。 |

```shell
curl --request PUT \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header "Content-Type: application/json" \
  --data '{"branch": "main", "author_email": "author@example.com", "author_name": "Firstname Lastname",
       "content": "some content", "commit_message": "update file"}' \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fproject%2Erb"
```

示例响应：

```json
{
  "file_path": "app/project.rb",
  "branch": "main"
}
```

如果提交因任何原因失败，API 会返回 `400 Bad Request` 错误，并附带不具体的错误消息。提交失败的可能原因包括：

- `file_path`中包含 `/../`（尝试进行目录遍历）。
- 提交为空：新文件内容与当前文件内容相同。
- 在文件编辑进行期间，有人使用 `git push` 更新了分支。

[GitLab Shell](https://gitlab.com/gitlab-org/gitlab-shell/) 具有布尔返回码，导致极狐GitLab 无法指定错误。

<a id="delete-a-file-in-a-repository"></a>

## 删除代码仓库中的文件

删除代码仓库中指定的文件。要通过单个请求删除多个文件，请参阅[提交 API](commits.md#create-a-commit)。

```plaintext
DELETE /projects/:id/repository/files/:file_path
```

支持的属性：

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `branch`         | string            | 是      | 要创建的分支名称。提交将添加到此分支。 |
| `commit_message` | string            | 是      | 提交信息。 |
| `file_path`      | string            | 是      | 文件的 URL 编码完整路径。例如：`lib%2Fclass%2Erb`。 |
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email`   | string            | 否       | 提交作者的电子邮件地址。 |
| `author_name`    | string            | 否       | 提交作者的姓名。 |
| `last_commit_id` | string            | 否       | 最后一次已知的文件提交 ID。 |
| `start_branch`   | string            | 否       | 用于创建分支的基础分支名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。

```shell
curl --request DELETE \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header "Content-Type: application/json" \
  --data '{"branch": "main", "author_email": "author@example.com", "author_name": "Firstname Lastname",
       "commit_message": "delete file"}' \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fproject%2Erb"
```
