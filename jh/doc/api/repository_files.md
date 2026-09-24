---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for managing Git repository files in GitLab.
title: 仓库文件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [仓库文件](../user/project/repository/_index.md)。
您还可以为此 API [配置速率限制](../administration/settings/files_api_rate_limits.md)。

<a id="available-scopes-for-personal-access-tokens"></a>

## 个人访问令牌的可用范围

[个人访问令牌](../user/profile/personal_access_tokens.md) 支持以下范围：

| 范围                | 描述 |
|---------------------|------|
| `api`               | 允许对仓库文件进行读写访问。 |
| `read_api`          | 允许对仓库文件进行读访问。 |
| `read_repository`   | 允许对仓库文件进行读访问。 |

<a id="retrieve-a-file-from-a-repository"></a>

## 从仓库获取文件

获取仓库中指定文件的信息，包括文件名称、大小和文件内容。
文件内容经过 Base64 编码。如果仓库是公开的，您可以在不进行身份验证的情况下访问此端点。

对于大于 10 MB 的 blob，此端点有每分钟 5 个请求的速率限制。

```plaintext
GET /projects/:id/repository/files/:file_path
```

支持的属性：

| 属性         | 类型               | 是否必需 | 描述 |
|--------------|--------------------|----------|------|
| `file_path`  | string             | 是       | 文件的 URL 编码完整路径，例如 `lib%2Fclass%2Erb`。 |
| `id`         | integer 或 string  | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ref`        | string             | 是       | 分支、标签或提交的名称。使用 `HEAD` 可以自动使用默认分支。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性                | 类型     | 描述 |
|---------------------|----------|------|
| `blob_id`           | string   | Blob SHA。 |
| `commit_id`         | string   | 文件的提交 SHA。 |
| `content`           | string   | Base64 编码的文件内容。 |
| `content_sha256`    | string   | 文件内容的 SHA256 哈希。 |
| `encoding`          | string   | 文件内容使用的编码。 |
| `execute_filemode`  | boolean  | 如果为 `true`，则文件上设置了执行标志。 |
| `file_name`         | string   | 文件名称。 |
| `file_path`         | string   | 文件的完整路径。 |
| `last_commit_id`    | string   | 最后一个修改此文件的提交 SHA。 |
| `ref`               | string   | 使用的分支、标签或提交的名称。 |
| `size`              | integer  | 文件大小（字节）。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb?ref=main"
```

如果您不知道分支名称或想使用默认分支，可以使用 `HEAD` 作为 `ref` 的值。例如：

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

您也可以使用 `HEAD` 仅获取文件元数据。

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

## 从仓库获取文件 Blame 历史

获取仓库中指定文件的 blame 历史。每个 blame 范围包含行及其对应的提交信息。

```plaintext
GET /projects/:id/repository/files/:file_path/blame
```

支持的属性：

| 属性            | 类型               | 是否必需 | 描述 |
|-----------------|--------------------|----------|------|
| `file_path`     | string             | 是       | 文件的 URL 编码完整路径，例如 `lib%2Fclass%2Erb`。 |
| `id`            | integer 或 string  | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `ref`           | string             | 是       | 分支、标签或提交的名称。使用 `HEAD` 可以自动使用默认分支。 |
| `range`         | hash               | 否       | Blame 范围。 |
| `range[end]`    | integer            | 否       | 要 blame 的范围的最后一行。 |
| `range[start]`  | integer            | 否       | 要 blame 的范围的第一行。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性       | 类型    | 描述 |
|------------|---------|------|
| `commit`   | object  | Blame 范围的提交信息。 |
| `lines`    | array   | 此 blame 范围的行数组。 |

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

### 仅获取文件 Blame 元数据

使用 `HEAD` 方法仅返回文件 blame 元数据。

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

### 请求 Blame 范围

要请求 blame 范围，请使用文件起始和结束行号指定 `range[start]` 和 `range[end]` 参数。

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

## 从仓库获取原始文件

获取仓库中指定文件的原始文件内容。

```plaintext
GET /projects/:id/repository/files/:file_path/raw
```

支持的属性：

| 属性         | 类型               | 是否必需 | 描述 |
|--------------|--------------------|----------|------|
| `file_path`  | string             | 是       | 文件的 URL 编码完整路径，例如 `lib%2Fclass%2Erb`。 |
| `id`         | integer 或 string  | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `lfs`        | boolean            | 否       | 如果为 `true`，则确定响应是否应为 Git LFS 文件内容，而不是指针。如果文件未被 Git LFS 跟踪，则忽略。默认为 `false`。 |
| `ref`        | string             | 否       | 分支、标签或提交的名称。默认为项目的 `HEAD`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fmodels%2Fkey%2Erb/raw?ref=main"
```

> [!note]
> 与 [从仓库获取文件](repository_files.md#retrieve-a-file-from-a-repository) 类似，您可以使用 `HEAD` 仅获取文件元数据。

<a id="create-a-file-in-a-repository"></a>

## 在仓库中创建文件

{{< history >}}

- 在极狐GitLab 18.7 中引入了请求大小和速率限制。

{{< /history >}}

在指定仓库中创建一个文件。要使用单个请求创建多个文件，请参见 [提交 API](commits.md#create-a-commit)。

```plaintext
POST /projects/:id/repository/files/:file_path
```

> [!note]
> 此端点受 [请求大小和速率限制](../administration/instance_limits.md#commits-and-files-api-limits) 的约束。超过默认 300 MB 限制的请求将被拒绝。大于 20 MB 的请求每 30 秒限速 3 个请求。

支持的属性：

| 属性                | 类型               | 是否必需 | 描述 |
|---------------------|--------------------|----------|------|
| `branch`            | string             | 是       | 要创建的分支名称。提交将添加到该分支。 |
| `commit_message`    | string             | 是       | 提交消息。 |
| `content`           | string             | 是       | 文件内容。 |
| `file_path`         | string             | 是       | 文件的 URL 编码完整路径。例如：`lib%2Fclass%2Erb`。 |
| `id`                | integer 或 string  | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email`      | string             | 否       | 提交作者的电子邮件地址。 |
| `author_name`       | string             | 否       | 提交作者姓名。 |
| `encoding`          | string             | 否       | 将编码更改为 `base64`。默认为 `text`。 |
| `execute_filemode`  | boolean            | 否       | 如果为 `true`，则在文件上启用 `execute` 标志。如果为 `false`，则禁用文件上的 `execute` 标志。 |
| `start_branch`      | string             | 否       | 要从中创建分支的基准分支名称。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性        | 类型    | 描述 |
|-------------|---------|------|
| `branch`    | string  | 创建文件所在的分支名称。 |
| `file_path` | string  | 创建的文件的路径。 |

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

## 更新仓库中的文件

{{< history >}}

- 在极狐GitLab 18.7 中引入了请求大小和速率限制。

{{< /history >}}

更新仓库中的指定文件。要使用单个请求更新多个文件，请参见 [提交 API](commits.md#create-a-commit)。

```plaintext
PUT /projects/:id/repository/files/:file_path
```

> [!note]
> 此端点受 [请求大小和速率限制](../administration/instance_limits.md#commits-and-files-api-limits) 的约束。超过默认 300 MB 限制的请求将被拒绝。大于 20 MB 的请求每 30 秒限速 3 个请求。

支持的属性：

| 属性               | 类型               | 是否必需 | 描述 |
|--------------------|--------------------|----------|------|
| `branch`           | string             | 是       | 要创建的分支名称。提交将添加到该分支。 |
| `commit_message`   | string             | 是       | 提交消息。 |
| `content`          | string             | 是       | 文件内容。 |
| `file_path`        | string             | 是       | 文件的 URL 编码完整路径。例如：`lib%2Fclass%2Erb`。 |
| `id`               | integer 或 string  | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email`     | string             | 否       | 提交作者的电子邮件地址。 |
| `author_name`      | string             | 否       | 提交作者姓名。 |
| `encoding`         | string             | 否       | 将编码更改为 `base64`。默认为 `text`。 |
| `execute_filemode` | boolean            | 否       | 如果为 `true`，则在文件上启用 `execute` 标志。如果为 `false`，则禁用文件上的 `execute` 标志。 |
| `last_commit_id`   | string             | 否       | 最后已知的文件提交 ID。 |
| `start_branch`     | string             | 否       | 要从中创建分支的基准分支名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性        | 类型    | 描述 |
|-------------|---------|------|
| `branch`    | string  | 更新文件所在的分支名称。 |
| `file_path` | string  | 更新的文件的路径。 |

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

如果提交因任何原因失败，API 返回 `400 Bad Request` 错误，并附带非具体的错误消息。提交失败的可能原因包括：

- `file_path` 包含 `/../`（尝试目录遍历）。
- 提交为空：新文件内容与当前文件内容完全相同。
- 在文件编辑进行时，有人使用 `git push` 更新了分支。

[极狐GitLab Shell](https://jihulab.com/gitlab-cn/gitlab-shell) 有一个布尔返回值，阻止 极狐GitLab 指定错误。

<a id="delete-a-file-in-a-repository"></a>

## 删除仓库中的文件

删除仓库中的指定文件。要使用单个请求删除多个文件，请参见 [提交 API](commits.md#create-a-commit)。

```plaintext
DELETE /projects/:id/repository/files/:file_path
```

支持的属性：

| 属性             | 类型               | 是否必需 | 描述 |
|------------------|--------------------|----------|------|
| `branch`         | string             | 是       | 要创建的分支名称。提交将添加到该分支。 |
| `commit_message` | string             | 是       | 提交消息。 |
| `file_path`      | string             | 是       | 文件的 URL 编码完整路径。例如：`lib%2Fclass%2Erb`。 |
| `id`             | integer 或 string  | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `author_email`   | string             | 否       | 提交作者的电子邮件地址。 |
| `author_name`    | string             | 否       | 提交作者姓名。 |
| `last_commit_id` | string             | 否       | 最后已知的文件提交 ID。 |
| `start_branch`   | string             | 否       | 要从中创建分支的基准分支名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。

```shell
curl --request DELETE \
  --header 'PRIVATE-TOKEN: <your_access_token>' \
  --header "Content-Type: application/json" \
  --data '{"branch": "main", "author_email": "author@example.com", "author_name": "Firstname Lastname",
       "commit_message": "delete file"}' \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/files/app%2Fproject%2Erb"
```