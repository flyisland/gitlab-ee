---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中 Git 代码仓库 REST API 的文档。
title: 代码仓库 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [Git 代码仓库](../user/project/repository/_index.md)。

<a id="list-all-repository-trees-in-a-project"></a>

## 列出项目中的所有代码仓库树

列出指定项目中的所有代码仓库文件和目录。如果代码仓库可公开访问，则无需身份验证即可访问此端点。

此命令提供的功能与 `git ls-tree` 命令基本相同。有关更多信息，请参阅 Git 内部原理文档中的[树对象](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects.html#_tree_objects)。

> [!warning]
> 极狐GitLab 17.7 更改了请求路径未找到时的错误处理行为。
> 该端点现在返回状态码 `404 Not Found`。此前，状态码为 `200 OK`。
>
> 如果您的实现依赖于在路径缺失时收到带有空数组的 `200` 状态码，
> 则必须更新错误处理逻辑，以处理新的 `404` 响应。

```plaintext
GET /projects/:id/repository/tree
```

支持的属性：

| 属性    | 类型              | 必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `page_token` | string            | 否       | 用于获取下一页的树记录 ID。仅与键集分页一起使用。 |
| `pagination` | string            | 否       | 如果为 `keyset`，则使用[基于键集的分页方法](rest/_index.md#keyset-based-pagination)。 |
| `path`       | string            | 否       | 代码仓库内的路径。用于获取子目录的内容。 |
| `per_page`   | integer           | 否       | 每页显示的结果数。如果未指定，默认为 `20`。有关更多信息，请参阅[分页](rest/_index.md#pagination)。 |
| `recursive`  | boolean           | 否       | 如果为 `true`，则获取递归树。默认为 `false`。 |
| `ref`        | string            | 否       | 代码仓库分支或标签的名称。如果未指定，则使用默认分支。 |
| `with_last_commit` | boolean     | 否       | 如果为 `true`，则包含每个树条目的最后一次提交。不能与 `recursive` 组合使用。默认为 `false`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及树对象数组。当 `with_last_commit` 为 `true` 时，每个树对象都包含一个 `last_commit` 对象，其中包含更改该条目的最近一次提交的详细信息。`last_commit` 对象使用与[提交 API](commits.md) 相同的属性。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/tree"
```

示例响应：

```json
[
  {
    "id": "a1e8f8d745cc87e3a9248358d9352bb7f9a0aeba",
    "name": "html",
    "type": "tree",
    "path": "files/html",
    "mode": "040000"
  },
  {
    "id": "4535904260b1082e14f867f7a24fd8c21495bde3",
    "name": "images",
    "type": "tree",
    "path": "files/images",
    "mode": "040000"
  },
  {
    "id": "31405c5ddef582c5a9b7a85230413ff90e2fe720",
    "name": "js",
    "type": "tree",
    "path": "files/js",
    "mode": "040000"
  },
  {
    "id": "cc71111cfad871212dc99572599a568bfe1e7e00",
    "name": "lfs",
    "type": "tree",
    "path": "files/lfs",
    "mode": "040000"
  },
  {
    "id": "fd581c619bf59cfdfa9c8282377bb09c2f897520",
    "name": "markdown",
    "type": "tree",
    "path": "files/markdown",
    "mode": "040000"
  },
  {
    "id": "23ea4d11a4bdd960ee5320c5cb65b5b3fdbc60db",
    "name": "ruby",
    "type": "tree",
    "path": "files/ruby",
    "mode": "040000"
  },
  {
    "id": "7d70e02340bac451f281cecf0a980907974bd8be",
    "name": "whitespace",
    "type": "blob",
    "path": "files/whitespace",
    "mode": "100644"
  }
]
```

使用 `with_last_commit`的示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/tree?with_last_commit=true"
```

示例响应：

```json
[
  {
    "id": "a1e8f8d745cc87e3a9248358d9352bb7f9a0aeba",
    "name": "html",
    "type": "tree",
    "path": "files/html",
    "mode": "040000",
    "last_commit": {
      "id": "913c66a37b4a45b9769037c55c2d238bd0942d2e",
      "short_id": "913c66a3",
      "created_at": "2014-02-27T10:14:56.000+02:00",
      "parent_ids": [
        "cfe32cf61b73a0d5e9f13e774abde7ff789b1660"
      ],
      "title": "Files, encoding and much more",
      "message": "Files, encoding and much more\n",
      "author_name": "Dmitriy Zaporozhets",
      "author_email": "dmitriy.zaporozhets@gmail.com",
      "authored_date": "2014-02-27T10:14:56.000+02:00",
      "committer_name": "Dmitriy Zaporozhets",
      "committer_email": "dmitriy.zaporozhets@gmail.com",
      "committed_date": "2014-02-27T10:14:56.000+02:00",
      "trailers": {},
      "extended_trailers": {},
      "web_url": "https://gitlab.example.com/example-group/example-project/-/commit/913c66a37b4a45b9769037c55c2d238bd0942d2e"
    }
  }
]
```

<a id="retrieve-a-blob-from-a-repository"></a>

## 从代码仓库中检索 blob

检索代码仓库中 blob 的相关信息，例如大小和内容。Blob 内容采用 Base64 编码。如果代码仓库可公开访问，则无需身份验证即可访问此端点。

对于大于 10 MB 的 blob，此端点的速率限制为每分钟 5 个请求。

```plaintext
GET /projects/:id/repository/blobs/:sha
```

支持的属性：

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | string            | 是      | Blob SHA。   |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性  | 类型    | 描述 |
|------------|---------|-------------|
| `content`  | string  | Base64 编码的 blob 内容。 |
| `encoding` | string  | 用于 blob 内容的编码。 |
| `sha`      | string  | Blob SHA。   |
| `size`     | integer | 原始 Git blob 的大小（以字节为单位）。 |

> [!note]
> 对于在 Git 中未以有效 UTF-8 存储的文本文件（例如 UTF-16 或 `ISO-8859-1`），
> `content` 会在进行 Base64 编码之前转换为 UTF-8。
> 在这些情况下，`size` 反映的是原始 blob 大小，可能与解码后内容的长度不同。
> 要检索 Git 中存储的确切字节，请使用[原始 blob 端点](#retrieve-raw-blob-content)。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/blobs/79f7bbd25901e8334750839545a9bd021f0e4c83"
```

示例响应：

```json
{
  "size": 1476,
  "encoding": "base64",
  "content": "VGhpcyBpcyBhIGJpbmFyeSBmaWxl",
  "sha": "79f7bbd25901e8334750839545a9bd021f0e4c83"
}
```

<a id="retrieve-raw-blob-content"></a>

## 检索原始 blob 内容

按 blob SHA 检索 blob 的原始文件内容。如果代码仓库可公开访问，则无需身份验证即可访问此端点。

```plaintext
GET /projects/:id/repository/blobs/:sha/raw
```

支持的属性：

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | string            | 是      | Blob SHA。   |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/blobs/79f7bbd25901e8334750839545a9bd021f0e4c83/raw"
```

<a id="retrieve-multiple-blobs-in-a-single-request"></a>

## 在单个请求中检索多个 blob

{{< details >}}

- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

在单个请求中检索最多 20 个文件的内容。每个请求的文件都针对分支、标签或提交进行解析。Blob 内容采用 Base64 编码。

此端点需要身份验证。未通过身份验证的请求会被拒绝，并返回 [`401 Unauthorized`](rest/troubleshooting.md#status-codes)。如果功能标志已禁用，该端点会返回 `404 Not Found`。

此端点按用户和项目进行速率限制。默认值为每分钟 5 个请求，可通过 `project_repositories_blobs_batch_limit` [应用程序设置](settings.md)进行配置。

每个 blob 都会被截断为前 1 MB 的内容。当 blob 被截断时，`truncated` 字段为 `true`，且 `size` 报告完整的 blob 大小（以字节为单位）。在请求的引用处不存在的文件会从响应中省略。

```plaintext
POST /projects/:id/repository/blobs/batch
```

支持的属性：

| 属性      | 类型              | 必需 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `files`        | array             | 是      | 要检索的文件对象数组。最多 20 个。 |
| `files[].path` | string            | 是      | 文件在代码仓库中的路径。 |
| `files[].ref`  | string            | 否       | 分支、标签或提交。默认为默认分支。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及一个数组，其中包含每个已解析文件的以下响应属性：

| 属性   | 类型    | 描述 |
|-------------|---------|-------------|
| `content`   | string  | Base64 编码的 blob 内容。 |
| `encoding`  | string  | 用于 blob 内容的编码。 |
| `path`      | string  | 文件在代码仓库中的路径。 |
| `ref`       | string  | 解析该文件时所依据的引用。 |
| `size`      | integer | Blob 的完整大小（以字节为单位）。 |
| `truncated` | boolean | `content` 是否被截断为 blob 的前 1 MB。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"files": [{"path": "README.md"}, {"path": "config/database.yml", "ref": "main"}]}' \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/blobs/batch"
```

示例响应：

```json
[
  {
    "path": "README.md",
    "ref": "main",
    "size": 1476,
    "truncated": false,
    "encoding": "base64",
    "content": "VGhpcyBpcyBhIGJpbmFyeSBmaWxl"
  }
]
```

<a id="retrieve-file-archive-from-a-repository"></a>

## 从代码仓库中检索文件归档

检索指定代码仓库的文件归档。如果代码仓库可公开访问，则无需身份验证即可访问此端点。

对于 JihuLab.com 用户，此端点的速率限制阈值为每分钟 5 个请求。

```plaintext
GET /projects/:id/repository/archive[.format]
```

`format` 是归档格式的可选后缀，默认为 `tar.gz`。例如，指定 `archive.zip` 会以 ZIP 格式发送归档。可用选项包括：

- `bz2`
- `tar`
- `tar.bz2`
- `tar.gz`
- `tb2`
- `tbz`
- `tbz2`
- `zip`

支持的属性：

| 属性           | 类型              | 必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `exclude_paths`     | string            | 否       | 要从归档中排除的路径列表，以逗号分隔。 |
| `include_lfs_blobs` | boolean           | 否       | 如果为 `true`，则归档中包含 LFS 对象。设置为 `false` 时，则排除 LFS 对象。默认为 `true`。 |
| `path`              | string            | 否       | 要下载的代码仓库子路径。如果为空字符串，则默认为整个代码仓库。 |
| `sha`               | string            | 否       | 要下载的提交 SHA。接受标签、分支引用或 SHA。如果未指定，则默认为默认分支的顶端。 |
| `ref_type`          | string            | 否       | `sha`中引用的类型。当分支和标签同名时，用于选择正确的引用。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://jihulab.com/api/v4/projects/<project_id>/repository/archive?sha=<commit_sha>&path=<path>&exclude_paths=<path1,path2>"
```

<a id="compare-branches-tags-or-commits"></a>

## 比较分支、标签或提交

检索指定项目中两个分支、标签或提交之间的差异。如果代码仓库可公开访问，则无需身份验证即可访问此端点。

当 `compare_timeout` 为 `true` 时，表示比较超出了大小限制或超时：

- `commits` 数组始终是完整的。
- `diffs` 数组可能不完整。
- 如果单个差异对象的内容超出限制，其 `diff` 字符串可能为空。

```plaintext
GET /projects/:id/repository/compare
```

支持的属性：

| 属性         | 类型              | 必需 | 描述 |
|-------------------|-------------------|----------|-------------|
| `from`            | string            | 是      | 提交 SHA 或分支名称。 |
| `id`              | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `to`              | string            | 是      | 提交 SHA 或分支名称。 |
| `from_project_id` | integer           | 否       | 要比较的源项目 ID。 |
| `straight`        | boolean           | 否       | 如果为 `true`，则比较方法为 `from` 与 `to` 之间的直接比较（`from`..`to`）。如果为 `false`，则使用合并基准进行比较（`from`...`to`）。默认为 `false`。 |
| `unidiff`         | boolean           | 否       | 如果为 `true`，则以[统一差异](https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html)格式呈现差异。默认为 `false`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                | 类型         | 描述 |
|--------------------------|--------------|-------------|
| `commit`                 | object       | 比较中最近一次提交的详细信息。 |
| `commits`                | object array | 两个引用之间的提交。始终完整，即使 `compare_timeout` 为 `true`。 |
| `commits[].author_email` | string       | 提交作者的电子邮件地址。 |
| `commits[].author_name`  | string       | 提交作者的姓名。 |
| `commits[].created_at`   | datetime     | 提交创建时间戳。 |
| `commits[].id`           | string       | 完整提交 SHA。 |
| `commits[].short_id`     | string       | 短提交 SHA。 |
| `commits[].title`        | string       | 提交标题。 |
| `compare_same_ref`       | boolean      | 如果为 `true`，则比较的起始和结束使用同一引用。 |
| `compare_timeout`        | boolean      | 如果为 `true`，则比较超出了大小限制或超时。`diffs` 数组可能不完整。 |
| `diffs`                  | object array | 文件差异列表。 |
| `diffs[].a_mode`         | string       | 旧文件模式。 |
| `diffs[].b_mode`         | string       | 新文件模式。 |
| `diffs[].collapsed`      | boolean      | 如果为 `true`，则排除文件差异，但可按需获取。 |
| `diffs[].deleted_file`   | boolean      | 如果为 `true`，则文件已被移除。 |
| `diffs[].diff`           | string       | 显示对文件所做更改的差异内容。 |
| `diffs[].new_file`       | boolean      | 如果为 `true`，则文件已被添加。 |
| `diffs[].new_path`       | string       | 文件的新路径。 |
| `diffs[].old_path`       | string       | 文件的旧路径。 |
| `diffs[].renamed_file`   | boolean      | 如果为 `true`，则文件已被重命名。 |
| `diffs[].too_large`      | boolean      | 如果为 `true`，则排除文件差异且无法检索。 |
| `web_url`                | string       | 用于查看比较的 Web URL。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/compare?from=main&to=feature"
```

示例响应：

```json
{
  "commit": {
    "id": "12d65c8dd2b2676fa3ac47d955accc085a37a9c1",
    "short_id": "12d65c8dd2b",
    "title": "JS fix",
    "author_name": "Example User",
    "author_email": "user@example.com",
    "created_at": "2014-02-27T10:27:00+02:00"
  },
  "commits": [{
    "id": "12d65c8dd2b2676fa3ac47d955accc085a37a9c1",
    "short_id": "12d65c8dd2b",
    "title": "JS fix",
    "author_name": "Example User",
    "author_email": "user@example.com",
    "created_at": "2014-02-27T10:27:00+02:00"
  }],
  "diffs": [{
    "old_path": "files/js/application.js",
    "new_path": "files/js/application.js",
    "a_mode": null,
    "b_mode": "100644",
    "diff": "@@ -24,8 +24,10 @@\n //= require g.raphael-min\n //= require g.bar-min\n //= require branch-graph\n-//= require highlightjs.min\n-//= require ace/ace\n //= require_tree .\n //= require d3\n //= require underscore\n+\n+function fix() { \n+  alert(\"Fixed\")\n+}",
    "collapsed": false,
    "too_large": false,
    "new_file": false,
    "renamed_file": false,
    "deleted_file": false
  }],
  "compare_timeout": false,
  "compare_same_ref": false,
  "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/compare/ae73cb07c9eeaf35924a10f713b364d32b2dd34f...0b4bc9a49b562e85de7cc9e834518ea6828729b9"
}
```

<a id="get-contributor-list"></a>

## 获取贡献者列表

获取代码仓库贡献者列表。如果代码仓库可公开访问，则无需身份验证即可访问此端点。

返回的提交计数不包含合并提交。

```plaintext
GET /projects/:id/repository/contributors
```

支持的属性：

| 属性  | 类型              | 必需 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by` | string            | 否       | 按 `name`、`email` 或 `commits`（提交数）对贡献者排序。如果未指定，则按提交日期对贡献者排序。 |
| `ref`      | string            | 否       | 代码仓库分支或标签的名称。如果未给出，则为默认分支。 |
| `sort`     | string            | 否       | 按 `asc` 或 `desc` 顺序返回排序后的贡献者。默认为 `asc`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性   | 类型    | 描述 |
|-------------|---------|-------------|
| `additions` | integer | 贡献者添加的行数。 |
| `commits`   | integer | 贡献者的提交数。 |
| `deletions` | integer | 贡献者删除的行数。 |
| `email`     | string  | 贡献者的电子邮件地址。 |
| `name`      | string  | 贡献者的姓名。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/7/repository/contributors"
```

示例响应：

```json
[{
  "name": "Example User",
  "email": "example@example.com",
  "commits": 117,
  "additions": 0,
  "deletions": 0
}, {
  "name": "Sample User",
  "email": "sample@example.com",
  "commits": 33,
  "additions": 0,
  "deletions": 0
}]
```

<a id="get-merge-base"></a>

## 获取合并基准

获取 2 个或更多引用（例如提交 SHA、分支名称或标签）的共同祖先。

```plaintext
GET /projects/:id/repository/merge_base
```

支持的属性：

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `refs`    | array             | 是      | 要查找共同祖先的引用。接受多个引用。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型     | 描述 |
|---------------------|----------|-------------|
| `author_email`      | string   | 作者的电子邮件地址。 |
| `author_name`       | string   | 作者的姓名。 |
| `authored_date`     | datetime | 提交的创作日期。 |
| `committed_date`    | datetime | 提交的提交日期。 |
| `committer_email`   | string   | 提交者的电子邮件地址。 |
| `committer_name`    | string   | 提交者的姓名。 |
| `created_at`        | datetime | 提交创建时间戳。 |
| `extended_trailers` | object   | 关于 Git 尾注的扩展信息。 |
| `id`                | string   | 完整提交 SHA。 |
| `message`           | string   | 完整提交消息。 |
| `parent_ids`        | array    | 父提交 SHA 列表。 |
| `short_id`          | string   | 短提交 SHA。 |
| `title`             | string   | 提交标题。 |
| `trailers`          | object   | 从提交消息中解析出的 Git 尾注。 |
| `web_url`           | string   | 用于在极狐GitLab Web 界面中查看该提交的 URL。 |

示例请求，为便于阅读，引用已截断：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/merge_base?refs[]=304d257d&refs[]=0031876f"
```

示例响应：

```json
{
  "id": "1a0b36b3cdad1d2ee32457c102a8c0b7056fa863",
  "short_id": "1a0b36b3",
  "title": "Initial commit",
  "created_at": "2014-02-27T08:03:18.000Z",
  "parent_ids": [],
  "message": "Initial commit\n",
  "author_name": "Example User",
  "author_email": "user@example.com",
  "authored_date": "2014-02-27T08:03:18.000Z",
  "committer_name": "Example User",
  "committer_email": "user@example.com",
  "committed_date": "2014-02-27T08:03:18.000Z",
  "trailers": {},
  "extended_trailers": {},
  "web_url": "https://gitlab.example.com/example-group/example-project/-/commit/1a0b36b3cdad1d2ee32457c102a8c0b7056fa863"
}
```

<a id="retrieve-diff-statistics"></a>

## 检索差异统计信息

{{< details >}}

- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

检索两个引用之间不同的每个文件的添加和删除行数。

此端点需要身份验证。未通过身份验证的请求会被拒绝，并返回 [`401 Unauthorized`](rest/troubleshooting.md#status-codes)。

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数控制结果的分页。

```plaintext
GET /projects/:id/repository/diff_stats
```

支持的属性：

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `from`    | string            | 是      | 要比较的源引用。接受提交 SHA、分支名称或标签名称。最大长度为 255 个字符。 |
| `to`      | string            | 是      | 要比较的目标引用。接受提交 SHA、分支名称或标签名称。最大长度为 255 个字符。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及一个差异统计信息数组，其中包含以下响应属性：

| 属性   | 类型    | 描述 |
|-------------|---------|-------------|
| `additions` | integer | 添加的行数。 |
| `deletions` | integer | 删除的行数。 |
| `old_path`  | string  | 文件的先前路径。当文件被重命名时，与 `path` 不同。 |
| `path`      | string  | 文件的路径。 |

可能返回以下状态码：

- `400 Bad Request`：`from` 或 `to` 缺失或超出最大长度。
- `401 Unauthorized`：请求未通过身份验证。
- `403 Forbidden`：您没有权限比较此项目中的代码仓库内容，或者代码仓库已被禁用。
- `404 Not Found`：项目不存在或对您不可见、指定的引用不存在，或者 `repository_diff_stats_api` 功能标志已禁用。
- `429 Too Many Requests`：超出此端点的速率限制。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/diff_stats?from=main&to=feature"
```

示例响应：

```json
[
  {
    "old_path": "app/models/user.rb",
    "path": "app/models/user.rb",
    "additions": 15,
    "deletions": 4
  },
  {
    "old_path": "app/assets/javascripts/pages/users/index.js",
    "path": "app/assets/javascripts/pages/users/show.js",
    "additions": 8,
    "deletions": 0
  },
  {
    "old_path": "spec/models/user_spec.rb",
    "path": "spec/models/user_spec.rb",
    "additions": 22,
    "deletions": 3
  }
]
```

<a id="retrieve-diverging-commit-counts"></a>

## 检索分叉提交计数

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

检索两个引用分叉的提交数。这些计数是相对于彼此而言的：

- `behind` 是 `from`中不在 `to`中的提交数。
- `ahead` 是 `to`中不在 `from`中的提交数。

此端点需要身份验证。未通过身份验证的请求会被拒绝，并返回 [`401 Unauthorized`](rest/troubleshooting.md#status-codes)。

```plaintext
GET /projects/:id/repository/diverging_commits
```

支持的属性：

| 属性   | 类型              | 必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `from`      | string            | 是      | 要比较的源引用。接受提交 SHA、分支名称或标签名称。 |
| `to`        | string            | 是      | 要比较的目标引用。接受提交 SHA、分支名称或标签名称。 |
| `max_count` | integer           | 否       | 要计数的最大提交数。使用 `0` 表示不限制。默认为 `0`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型    | 描述 |
|-----------|---------|-------------|
| `ahead`   | integer | `to`中不在 `from`中的提交数。 |
| `behind`  | integer | `from`中不在 `to`中的提交数。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/diverging_commits?from=main&to=feature"
```

示例响应：

```json
{
  "behind": 3,
  "ahead": 5
}
```

<a id="retrieve-changed-paths"></a>

## 检索已更改的路径

{{< details >}}

- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

检索两个提交、分支或标签之间发生更改的文件列表。

此端点需要身份验证。未通过身份验证的请求会被拒绝，并返回 [`401 Unauthorized`](rest/troubleshooting.md#status-codes)。

```plaintext
GET /projects/:id/repository/changed_paths
```

支持的属性：

| 属性      | 类型              | 必需 | 描述 |
|----------------|-------------------|----------|-------------|
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `from`         | string            | 是      | 要比较的源提交 SHA、分支或标签。 |
| `to`           | string            | 是      | 要比较的目标提交 SHA、分支或标签。 |
| `find_renames` | boolean           | 否       | 如果为 `true`，则检测文件重命名。默认为 `false`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及一个已更改路径列表，其中包含以下响应属性：

| 属性  | 类型   | 描述 |
|------------|--------|-------------|
| `new_mode` | string | 新文件模式。 |
| `old_mode` | string | 先前的文件模式。 |
| `old_path` | string | 文件的先前路径。对于新增文件为空字符串。 |
| `path`     | string | 文件的路径。 |
| `status`   | string | 更改类型。为 `ADDED`、`MODIFIED`、`DELETED`、`RENAMED`、`TYPE_CHANGED` 或 `COPIED` 之一。 |

可能返回以下状态码：

- `400 Bad Request`：`from` 或 `to` 缺失或超出最大长度。
- `401 Unauthorized`：请求未通过身份验证。
- `403 Forbidden`：您没有权限比较此项目中的代码仓库内容，或者代码仓库已被禁用。
- `404 Not Found`：项目不存在或对您不可见、指定的引用不存在，或者 `repository_changed_paths_api` 功能标志已禁用。
- `429 Too Many Requests`：超出此端点的速率限制。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/changed_paths?from=main&to=feature"
```

示例响应：

```json
[
  {
    "status": "MODIFIED",
    "path": "app/models/user.rb",
    "old_path": "app/models/user.rb",
    "old_mode": "100644",
    "new_mode": "100644"
  }
]
```

<a id="generate-changelog-data"></a>

## 生成变更日志数据

基于代码仓库中的提交生成变更日志数据，而不将其提交到变更日志文件。

其工作方式与 `POST /projects/:id/repository/changelog` 完全相同，区别在于变更日志数据不会提交到任何变更日志文件。

```plaintext
GET /projects/:id/repository/changelog
```

可选。您可以添加 `.txt` 后缀，以纯文本 Markdown 形式返回变更日志，
而不是 JSON：

```plaintext
GET /projects/:id/repository/changelog.txt
```

支持的属性：

| 属性         | 类型     | 必需 | 描述 |
|-------------------|----------|----------|-------------|
| `version`         | string   | 是      | 要为其生成变更日志的版本。格式必须遵循[语义化版本](https://semver.org/)。 |
| `config_file`     | string   | 否       | 项目 Git 代码仓库中变更日志配置文件的路径。默认为 `.gitlab/changelog_config.yml`。 |
| `config_file_ref` | string   | 否       | 定义变更日志配置文件的 Git 引用（例如分支）。默认为默认代码仓库分支。 |
| `date`            | datetime | 否       | 发布版本的日期和时间。使用 ISO 8601 格式。示例：`2016-03-11T03:45:40Z`。默认为当前时间。 |
| `from`            | string   | 否       | 用于生成变更日志的提交范围起点（以 SHA 表示）。此提交本身不包含在列表中。 |
| `to`              | string   | 否       | 用于生成变更日志的提交范围终点（以 SHA 表示）。此提交包含在列表中。默认为默认项目分支的 HEAD。 |
| `trailer`         | string   | 否       | 用于包含提交的 Git 尾注。默认为 `Changelog`。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `notes`   | string | 以 Markdown 格式生成的变更日志数据。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: token" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog?version=1.0.0"
```

示例响应，为便于阅读已添加换行：

```json
{
  "notes": "## 1.0.0 (2021-11-17)\n\n### feature (2 changes)\n\n-
    [Title 2](namespace13/project13@ad608eb642124f5b3944ac0ac772fecaf570a6bf)
    ([merge request](namespace13/project13!2))\n-
    [Title 1](namespace13/project13@3c6b80ff7034fa0d585314e1571cc780596ce3c8)
    ([merge request](namespace13/project13!1))\n"
}
```

使用 `.txt` 格式的示例请求：

```shell
curl --header "PRIVATE-TOKEN: token" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog.txt?version=1.0.0"
```

示例响应：

```plaintext
## 1.0.0 (2021-11-17)

### feature (2 changes)

- [Title 2](namespace13/project13@ad608eb642124f5b3944ac0ac772fecaf570a6bf)
  ([merge request](namespace13/project13!2))
- [Title 1](namespace13/project13@3c6b80ff7034fa0d585314e1571cc780596ce3c8)
  ([merge request](namespace13/project13!1))
```

<a id="add-changelog-data-to-file"></a>

## 将变更日志数据添加到文件

基于代码仓库中的提交生成变更日志数据，并将其提交到变更日志文件。

给定一个[语义化版本](https://semver.org/)和一系列提交，极狐GitLab 会为所有使用特定 [Git 尾注](https://git-scm.com/docs/git-interpret-trailers)的提交生成变更日志。极狐GitLab 会在项目的 Git 代码仓库中的变更日志文件里添加一个新的 Markdown 格式章节。输出格式可以自定义。

出于性能和安全原因，解析变更日志配置的时间限制为 2 秒。此限制有助于防止由格式错误的变更日志模板引发的潜在 DoS 攻击。如果请求超时，请考虑减小 `changelog_config.yml` 文件的大小。

有关面向用户的文档，请参阅[变更日志](../user/project/changelogs.md)。

```plaintext
POST /projects/:id/repository/changelog
```

变更日志支持以下属性：

| 属性              | 类型     | 必需 | 描述 |
|------------------------|----------|----------|-------------|
| `version`[^version-attribute-include] | string   | 是      | 要为其生成变更日志的版本。格式必须遵循[语义化版本](https://semver.org/)。 |
| `branch`               | string   | 否       | 要将变更日志更改提交到的分支。默认为项目的默认分支。 |
| `config_file`          | string   | 否       | 项目 Git 代码仓库中变更日志配置文件的路径。默认为 `.gitlab/changelog_config.yml`。 |
| `config_file_ref`      | string   | 否       | 定义变更日志配置文件的 Git 引用（例如分支）。默认为默认代码仓库分支。 |
| `date`                 | datetime | 否       | 发布版本的日期和时间。默认为当前时间。 |
| `file`                 | string   | 否       | 要将更改提交到的文件。默认为 `CHANGELOG.md`。 |
| `from`[^unspecified-automatically-finds]    | string   | 否       | 标记要包含在变更日志中的提交范围起点的提交 SHA。此提交不包含在变更日志中。 |
| `message`              | string   | 否       | 提交更改时使用的提交消息。默认为 `Add changelog for version X`，其中 `X` 是 `version` 参数的值。 |
| `to`                   | string   | 否       | 标记要包含在变更日志中的提交范围终点的提交 SHA。此提交包含在变更日志中。默认为 `branch` 属性中指定的分支。限制为 15000 个提交。 |
| `trailer`              | string   | 否       | 用于包含提交的 Git 尾注。默认为 `Changelog`。区分大小写：`Example` 不匹配 `example` 或 `eXaMpLE`。 |

[^version-attribute-include]: `version` 属性可以包含或省略 `v` 前缀。`1.0.0` 和 `v1.0.0` 会产生相同的结果。
    [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/437616)于极狐GitLab 17.0。
[^unspecified-automatically-finds]: 当未指定 `from` 时，极狐GitLab 会自动查找您指定版本之前的最后一个稳定版本标签。
    极狐GitLab 识别遵循语义化版本的 `X.Y.Z` 或 `vX.Y.Z` 格式的标签。

    例如，如果 `version` 为 `2.1.0`，极狐GitLab 会使用标签 `v2.0.0`。当 `version` 为 `1.1.1` 或 `1.2.0` 时，
    极狐GitLab 会使用标签 `v1.1.0`。像 `v1.0.0-pre1` 这样的预发布标签会被忽略。

    如果未找到合适的标签，API 会返回错误，您必须显式指定 `from` 属性。

<a id="examples"></a>

### 示例

这些示例使用 [cURL](https://curl.se/) 执行 HTTP 请求。示例命令使用以下值：

- 项目 ID：42
- 位置：托管在 JihuLab.com 上
- 示例 API 令牌：`token`

此命令为版本 `1.0.0` 生成变更日志。

提交范围：

- 从上一个发布的标签开始。
- 以目标分支上的最后一次提交结束。默认目标分支为
  项目的默认分支。

如果最后一个标签为 `v0.9.0`，且默认分支为 `main`，则此示例中包含的提交范围为 `v0.9.0..main`：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog"
```

要在其他分支上生成数据，请指定 `branch` 参数。此命令从 `foo` 分支生成数据：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0&branch=foo" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog"
```

要使用不同的尾注，请使用 `trailer` 参数：

```shell
curl --request POST --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0&trailer=Type" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog"
```

要将结果存储到不同的文件，请使用 `file` 参数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0&file=NEWS" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog"
```

要将分支指定为参数，请使用 `to` 属性：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: token" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog?version=1.0.0&to=release/x.x.x"
```

<a id="migrate-from-manual-changelog-files"></a>

## 从手动变更日志文件迁移

当您从现有的手动管理的变更日志文件迁移到使用 Git 尾注的变更日志文件时，请确保变更日志文件符合[预期格式](../user/project/changelogs.md)。否则，API 添加的新变更日志条目可能会插入到意外位置。例如，如果手动管理的变更日志文件中的版本值指定为 `vX.Y.Z` 而不是 `X.Y.Z`，则使用 Git 尾注添加的新变更日志条目会追加到变更日志文件的末尾。

[议题 444183](https://gitlab.com/gitlab-org/gitlab/-/issues/444183) 提议自定义变更日志文件中的版本标头格式。但是，在该议题完成之前，变更日志文件中预期的版本标头格式为 `X.Y.Z`。

<a id="health"></a>

## 健康状况

获取与项目代码仓库健康状况相关的统计信息。

当 `generate` 为 `true` 时，此端点按项目限制为每小时 5 个请求。此端点仅对拥有代码仓库推送权限的用户可用。

```plaintext
GET /projects/:id/repository/health
```

支持的属性：

| 属性  | 类型    | 必需 | 描述                                                                            |
|------------|---------|----------|----------------------------------------------------------------------------------------|
| `generate` | boolean | 否       | 如果为 `true`，则应生成新的健康状况报告。如果该端点返回 `404`，请设置此项。 |

如果成功，则返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及代码仓库健康状况统计信息。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: token" \
  --url "https://gitlab.com/api/v4/projects/42/repository/health"
```

示例响应：

```json
{
  "size": 2619748827,
  "references": {
    "loose_count": 13,
    "packed_size": 333978,
    "reference_backend": "REFERENCE_BACKEND_FILES"
  },
  "objects": {
    "size": 2180475409,
    "recent_size": 2180453999,
    "stale_size": 21410,
    "keep_size": 0,
    "packfile_count": 1,
    "reverse_index_count": 1,
    "cruft_count": 0,
    "keep_count": 0,
    "loose_objects_count": 36,
    "stale_loose_objects_count": 36,
    "loose_objects_garbage_count": 0
  },
  "commit_graph": {
    "commit_graph_chain_length": 1,
    "has_bloom_filters": true,
    "has_generation_data": true,
    "has_generation_data_overflow": false
  },
  "bitmap": null,
  "multi_pack_index": {
    "packfile_count": 1,
    "version": 1
  },
  "multi_pack_index_bitmap": {
    "has_hash_cache": true,
    "has_lookup_table": true,
    "version": 1
  },
  "alternates": null,
  "is_object_pool": false,
  "last_full_repack": {
    "seconds": 1745892013,
    "nanos": 0
  },
  "updated_at": "2025-05-14T02:31:08.022Z"
}
```

有关响应中每个字段的说明，请参阅
[`RepositoryInfoResponse`](https://gitlab.com/gitlab-org/gitaly/blob/fcb986a6482f82b088488db3ed7ca35adfa42fdc/proto/repository.proto#L444)
protobuf 消息。
