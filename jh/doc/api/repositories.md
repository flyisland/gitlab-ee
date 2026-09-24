---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for Git repositories in GitLab.
title: 仓库 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [Git 仓库](../user/project/repository/_index.md)。

<a id="list-all-repository-trees-in-a-project"></a>

## 列出一个项目中的所有仓库树

列出一个指定项目中的所有仓库文件和目录。如果仓库可公开访问，无需认证即可访问该端点。

此命令提供的功能与 `git ls-tree` 命令基本相同。更多信息，请参阅 Git 内部文档中的
[tree objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects.html#_tree_objects)。

> [!warning]
> 极狐GitLab 17.7 版本更改了请求路径未找到时的错误处理行为。
> 该端点现在返回状态码 `404 Not Found`。之前，状态码是 `200 OK`。
>
> 如果你的实现依赖接收 `200` 状态码和空数组来处理缺失路径，你必须更新错误处理逻辑以处理新的 `404` 响应。

```plaintext
GET /projects/:id/repository/tree
```

支持的属性：

| 属性    | 类型              | 是否必需 | 描述 |
|--------------|-------------------|----------|-------------|
| `id`         | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `page_token` | string            | 否       | 获取下一页的 tree 记录 ID。仅用于 keyset 分页。 |
| `pagination` | string            | 否       | 如果为 `keyset`，则使用 [基于 keyset 的分页方法](rest/_index.md#keyset-based-pagination)。 |
| `path`       | string            | 否       | 仓库内部的路径。用于获取子目录的内容。 |
| `per_page`   | integer           | 否       | 每页显示的结果数量。如果未指定，默认为 `20`。更多信息，请参阅 [分页](rest/_index.md#pagination)。 |
| `recursive`  | boolean           | 否       | 如果为 `true`，则获取递归树。默认为 `false`。 |
| `ref`        | string            | 否       | 仓库分支或标签的名称。如果未指定，则使用默认分支。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和 tree 对象的数组。

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

<a id="retrieve-a-blob-from-a-repository"></a>

## 从仓库中获取 blob

获取仓库中 blob 的信息，如大小和内容等。
Blob 内容采用 Base64 编码。如果仓库可公开访问，无需认证即可访问该端点。

对于大于 10 MB 的 blob，此端点的速率限制为每分钟 5 个请求。

```plaintext
GET /projects/:id/repository/blobs/:sha
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | string            | 是      | Blob SHA。   |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下
响应属性：

| 属性  | 类型    | 描述 |
|------------|---------|-------------|
| `content`  | string  | Base64 编码的 blob 内容。 |
| `encoding` | string  | Blob 内容使用的编码。 |
| `sha`      | string  | Blob SHA。   |
| `size`     | integer | Blob 的大小（以字节为单位）。 |

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

## 获取原始 blob 内容

通过 blob SHA 获取 blob 的原始文件内容。如果仓库可公开访问，无需认证即可访问该端点。

```plaintext
GET /projects/:id/repository/blobs/:sha/raw
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | string            | 是      | Blob SHA。   |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/13083/repository/blobs/79f7bbd25901e8334750839545a9bd021f0e4c83/raw"
```

<a id="retrieve-file-archive-from-a-repository"></a>

## 从仓库中获取文件归档

获取指定仓库的文件归档。如果仓库可公开访问，无需认证即可访问该端点。

对于 JihuLab.com 用户，此端点的速率限制阈值为每分钟 5 个请求。

```plaintext
GET /projects/:id/repository/archive[.format]
```

`format` 是归档格式的可选后缀，默认为 `tar.gz`。例如，指定 `archive.zip` 可发送 ZIP 格式的归档。
可用选项包括：

- `bz2`
- `tar`
- `tar.bz2`
- `tar.gz`
- `tb2`
- `tbz`
- `tbz2`
- `zip`

支持的属性：

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `exclude_paths`     | string            | 否       | 要从归档中排除的路径，以逗号分隔。 |
| `include_lfs_blobs` | boolean           | 否       | 如果为 `true`，归档中会包含 LFS 对象。设置为 `false` 时，排除 LFS 对象。默认为 `true`。 |
| `path`              | string            | 否       | 要下载的仓库子路径。如果为空字符串，则默认为整个仓库。 |
| `sha`               | string            | 否       | 要下载的提交 SHA。接受标签、分支引用或 SHA。如果未指定，默认为默认分支的最新提交。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.com/api/v4/projects/<project_id>/repository/archive?sha=<commit_sha>&path=<path>&exclude_paths=<path1,path2>"
```

<a id="compare-branches-tags-or-commits"></a>

## 比较分支、标签或提交

{{< history >}}

- `collapsed` 和 `too_large` 响应属性在极狐GitLab 18.4 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/199633)。

{{< /history >}}

获取指定项目中两个分支、标签或提交之间的差异。
如果仓库可公开访问，无需认证即可访问此端点。

当 `compare_timeout` 为 `true` 时，表示比较超出了大小限制或超时：

- `commits` 数组始终完整。
- `diffs` 数组可能不完整。
- 单个 diff 对象的 `diff` 字符串可能为空，如果其内容超出限制。

```plaintext
GET /projects/:id/repository/compare
```

支持的属性：

| 属性         | 类型              | 是否必需 | 描述 |
|-------------------|-------------------|----------|-------------|
| `from`            | string            | 是      | 提交 SHA 或分支名称。 |
| `id`              | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `to`              | string            | 是      | 提交 SHA 或分支名称。 |
| `from_project_id` | integer           | 否       | 要比较的来源项目 ID。 |
| `straight`        | boolean           | 否       | 如果为 `true`，比较方法是 `from` 和 `to` 之间的直接比较（`from`..`to`）。如果为 `false`，则使用合并基础进行比较（`from`...`to`）。默认为 `false`。 |
| `unidiff`         | boolean           | 否       | 如果为 `true`，以 [unified diff](https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html) 格式呈现差异。默认为 `false`。[在极狐GitLab 16.5 中引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/130610)。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下
响应属性：

| 属性                | 类型         | 描述 |
|--------------------------|--------------|-------------|
| `commit`                 | object       | 比较中最新提交的详细信息。 |
| `commits`                | object 数组 | 两个引用之间的提交。即使 `compare_timeout` 为 `true`，该数组始终完整。 |
| `commits[].author_email` | string       | 提交作者的电子邮件地址。 |
| `commits[].author_name`  | string       | 提交作者的姓名。 |
| `commits[].created_at`   | datetime     | 提交创建时间戳。 |
| `commits[].id`           | string       | 完整的提交 SHA。 |
| `commits[].short_id`     | string       | 短的提交 SHA。 |
| `commits[].title`        | string       | 提交标题。 |
| `compare_same_ref`       | boolean      | 如果为 `true`，比较对 from 和 to 使用了相同的引用。 |
| `compare_timeout`        | boolean      | 如果为 `true`，比较超出了大小限制或超时。`diffs` 数组可能不完整。 |
| `diffs`                  | object 数组 | 文件差异列表。 |
| `diffs[].a_mode`         | string       | 旧文件模式。 |
| `diffs[].b_mode`         | string       | 新文件模式。 |
| `diffs[].collapsed`      | boolean      | 如果为 `true`，文件差异被排除，但可以按需获取。 |
| `diffs[].deleted_file`   | boolean      | 如果为 `true`，文件已被删除。 |
| `diffs[].diff`           | string       | 显示对文件所做更改的差异内容。 |
| `diffs[].new_file`       | boolean      | 如果为 `true`，文件已添加。 |
| `diffs[].new_path`       | string       | 文件的新路径。 |
| `diffs[].old_path`       | string       | 文件的旧路径。 |
| `diffs[].renamed_file`   | boolean      | 如果为 `true`，文件已被重命名。 |
| `diffs[].too_large`      | boolean      | 如果为 `true`，文件差异被排除且无法检索。 |
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

{{< history >}}

- `ref` 在极狐GitLab 17.4 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/156852)。

{{< /history >}}

获取仓库贡献者列表。如果仓库可公开访问，无需认证即可访问此端点。

返回的提交数量不包含合并提交。

```plaintext
GET /projects/:id/repository/contributors
```

支持的属性：

| 属性  | 类型              | 是否必需 | 描述 |
|------------|-------------------|----------|-------------|
| `id`       | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by` | string            | 否       | 根据 `name`、`email` 或 `commits`（提交数量）对贡献者排序。如果未指定，贡献者按提交日期排序。 |
| `ref`      | string            | 否       | 仓库分支或标签的名称。如果未指定，则使用默认分支。 |
| `sort`     | string            | 否       | 返回按 `asc` 或 `desc` 顺序排序的贡献者。默认为 `asc`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下
响应属性：

| 属性   | 类型    | 描述 |
|-------------|---------|-------------|
| `additions` | integer | 贡献者添加的行数。 |
| `commits`   | integer | 贡献者的提交次数。 |
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

## 获取合并基础

获取 2 个或更多引用（例如提交 SHA、分支名称或标签）的公共祖先。

```plaintext
GET /projects/:id/repository/merge_base
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `refs`    | array             | 是      | 要查找其公共祖先的引用。接受多个引用。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下
响应属性：

| 属性           | 类型     | 描述 |
|---------------------|----------|-------------|
| `author_email`      | string   | 作者的电子邮件地址。 |
| `author_name`       | string   | 作者的姓名。 |
| `authored_date`     | datetime | 提交的创作日期。 |
| `committed_date`    | datetime | 提交的提交日期。 |
| `committer_email`   | string   | 提交者的电子邮件地址。 |
| `committer_name`    | string   | 提交者的姓名。 |
| `created_at`        | datetime | 提交创建时间戳。 |
| `extended_trailers` | object   | Git trailers 的扩展信息。 |
| `id`                | string   | 完整的提交 SHA。 |
| `message`           | string   | 完整的提交消息。 |
| `parent_ids`        | array    | 父提交 SHA 的列表。 |
| `short_id`          | string   | 短的提交 SHA。 |
| `title`             | string   | 提交标题。 |
| `trailers`          | object   | 从提交消息中解析出的 Git trailers。 |
| `web_url`           | string   | 在 GitLab Web 界面中查看提交的 URL。 |

示例请求，为便于阅读已截断引用：

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

<a id="generate-changelog-data"></a>

## 生成变更日志数据

{{< history >}}

- 在极狐GitLab 17.7 通过 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md) 进行认证 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/172842)。
- `config_file_ref` 属性在极狐GitLab 18.2 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/426108)。

{{< /history >}}

根据仓库中的提交生成变更日志数据，而不会将其提交到变更日志文件。

其工作方式与 `POST /projects/:id/repository/changelog` 完全相同，只是变更日志数据不会提交到任何变更日志文件。

```plaintext
GET /projects/:id/repository/changelog
```

支持的属性：

| 属性         | 类型     | 是否必需 | 描述 |
|-------------------|----------|----------|-------------|
| `version`         | string   | 是      | 要为其生成变更日志的版本。格式必须遵循 [语义化版本](https://semver.org/)。 |
| `config_file`     | string   | 否       | 项目 Git 仓库中变更日志配置文件的路径。默认为 `.gitlab/changelog_config.yml`。 |
| `config_file_ref` | string   | 否       | 定义变更日志配置文件的 Git 引用（例如，分支）。默认为默认仓库分支。 |
| `date`            | datetime | 否       | 发布的日期和时间。使用 ISO 8601 格式。示例：`2016-03-11T03:45:40Z`。默认为当前时间。 |
| `from`            | string   | 否       | 用于生成变更日志的提交范围起点（作为 SHA）。此提交本身不包含在列表中。 |
| `to`              | string   | 否       | 用于变更日志的提交范围终点（作为 SHA）。此提交包含在列表中。默认为默认项目分支的 HEAD。 |
| `trailer`         | string   | 否       | 用于包含提交的 Git trailer。默认为 `Changelog`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下
响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `notes`   | string | 以 Markdown 格式生成的变更日志数据。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: token" \
  --url "https://gitlab.com/api/v4/projects/42/repository/changelog?version=1.0.0"
```

示例响应，为便于阅读添加了换行符：

```json
{
  "notes": "## 1.0.0 (2021-11-17)\n\n### feature (2 changes)\n\n-
    [Title 2](namespace13/project13@ad608eb642124f5b3944ac0ac772fecaf570a6bf)
    ([merge request](namespace13/project13!2))\n-
    [Title 1](namespace13/project13@3c6b80ff7034fa0d585314e1571cc780596ce3c8)
    ([merge request](namespace13/project13!1))\n"
}
```

<a id="add-changelog-data-to-file"></a>

## 将变更日志数据添加到文件

{{< history >}}

- 在极狐GitLab 17.3 中 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/364101)。功能标志 `changelog_commits_limitation` 已移除。
- `config_file_ref` 在极狐GitLab 18.2 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/426108)。

{{< /history >}}

根据仓库中的提交生成变更日志数据，并将其提交到变更日志文件。

给定一个 [语义化版本](https://semver.org/) 和一系列提交，极狐GitLab 会为所有使用特定 [Git trailer](https://git-scm.com/docs/git-interpret-trailers) 的提交生成变更日志。极狐GitLab 会将一个新的 Markdown 格式部分添加到项目 Git 仓库的变更日志文件中。输出格式可以自定义。

出于性能和安全原因，解析变更日志配置的时间限制为 2 秒。此限制有助于防止因错误的变更日志模板导致的潜在 DoS 攻击。如果请求超时，请考虑减小 `changelog_config.yml` 文件的大小。

面向用户的文档，请参阅 [变更日志](../user/project/changelogs.md)。

```plaintext
POST /projects/:id/repository/changelog
```

变更日志支持以下属性：

| 属性              | 类型     | 是否必需 | 描述 |
|------------------------|----------|----------|-------------|
| `version` <sup>1</sup> | string   | 是      | 要为其生成变更日志的版本。格式必须遵循 [语义化版本](https://semver.org/)。 |
| `branch`               | string   | 否       | 要将变更日志更改提交到的分支。默认为项目的默认分支。 |
| `config_file`          | string   | 否       | 项目 Git 仓库中变更日志配置文件的路径。默认为 `.gitlab/changelog_config.yml`。 |
| `config_file_ref`      | string   | 否       | 定义变更日志配置文件的 Git 引用（例如，分支）。默认为默认仓库分支。 |
| `date`                 | datetime | 否       | 发布的日期和时间。默认为当前时间。 |
| `file`                 | string   | 否       | 要将更改提交到的文件。默认为 `CHANGELOG.md`。 |
| `from` <sup>2</sup>    | string   | 否       | 标记要包含在变更日志中的提交范围起点的提交 SHA。此提交不包含在变更日志中。 |
| `message`              | string   | 否       | 提交更改时使用的提交消息。默认为 `Add changelog for version X`，其中 `X` 是 `version` 参数的值。 |
| `to`                   | string   | 否       | 标记要包含在变更日志中的提交范围终点的提交 SHA。此提交包含在变更日志中。默认为 `branch` 属性中指定的分支。限制为 15000 个提交。 |
| `trailer`              | string   | 否       | 用于包含提交的 Git trailer。默认为 `Changelog`。区分大小写：`Example` 不匹配 `example` 或 `eXaMpLE`。 |

**脚注**：

1. `version` 属性可以包含或省略 `v` 前缀。`1.0.0` 和 `v1.0.0` 会产生相同的结果。
   [在极狐GitLab 17.0 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/437616)。

1. 当未指定 `from` 时，极狐GitLab 会自动查找在指定版本之前的最后一个稳定版本标签。
   极狐GitLab 识别 `X.Y.Z` 或 `vX.Y.Z` 格式的标签，遵循语义化版本。

   例如，如果 `version` 是 `2.1.0`，极狐GitLab 使用标签 `v2.0.0`。当 `version` 是 `1.1.1` 或 `1.2.0` 时，
   极狐GitLab 使用标签 `v1.1.0`。类似 `v1.0.0-pre1` 的预发布标签会被忽略。

   如果未找到合适的标签，API 将返回错误，你必须明确指定 `from` 属性。

### 示例

这些示例使用 [cURL](https://curl.se/) 执行 HTTP 请求。
示例命令使用以下值：

- 项目 ID：42
- 位置：托管在 JihuLab.com 上
- 示例 API 令牌：`token`

此命令为版本 `1.0.0` 生成变更日志。

提交范围：

- 从上一次发布的标签开始。
- 以目标分支上的最后一次提交结束。默认目标分支是项目的默认分支。

如果上一个标签是 `v0.9.0`，默认分支是 `main`，此示例中包含的提交范围是 `v0.9.0..main`：
```shell
curl --request POST \
  --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0" \
  --url "https://jihulab.com/api/v4/projects/42/repository/changelog"
```

若要在其他分支上生成数据，请指定 `branch` 参数。以下命令会从 `foo` 分支生成数据：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0&branch=foo" \
  --url "https://jihulab.com/api/v4/projects/42/repository/changelog"
```

若需使用不同的尾随标记，请使用 `trailer` 参数：

```shell
curl --request POST --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0&trailer=Type" \
  --url "https://jihulab.com/api/v4/projects/42/repository/changelog"
```

若要将结果存储在不同的文件中，请使用 `file` 参数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: token" \
  --data "version=1.0.0&file=NEWS" \
  --url "https://jihulab.com/api/v4/projects/42/repository/changelog"
```

如需以参数形式指定分支，请使用 `to` 属性：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: token" \
  --url "https://jihulab.com/api/v4/projects/42/repository/changelog?version=1.0.0&to=release/x.x.x"
```

<a id="migrate-from-manual-changelog-files"></a>

## 从手动变更日志文件迁移

从现有手动管理的变更日志文件迁移到使用 Git 尾随标记时，请确保该变更日志文件符合[预期格式](../user/project/changelogs.md)。否则，通过 API 添加的新变更日志条目可能会插入到非预期的位置。例如，如果手动管理的变更日志文件中的版本值以 `vX.Y.Z` 而非 `X.Y.Z` 形式指定，则通过 Git 尾随标记添加的新条目会被追加到变更日志文件的末尾。

议题 444183 提议自定义变更日志文件中的版本标题格式，但在该议题完成之前，变更日志文件中预期的版本标题格式仍是 `X.Y.Z`。

<a id="health"></a>

## 健康状态

{{< history >}}

- 于极狐GitLab 17.10 引入，受 `project_repositories_health` 功能标志保护。
- 于极狐GitLab 18.1 新增字段。

{{< /history >}}

获取与项目仓库健康相关的统计信息。

当 `generate` 为 `true` 时，该端点限制为每个项目每小时 5 次请求。此端点仅对具有仓库推送权限的用户可用。

```plaintext
GET /projects/:id/repository/health
```

支持的属性：

| 属性         | 类型      | 是否必需 | 描述                                                                             |
|------------|---------|------|--------------------------------------------------------------------------------|
| `generate` | boolean | 否    | 如果为 `true`，则生成新的健康报告。若端点返回 `404` ，可设置此参数。 |

若成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及仓库健康统计信息。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: token" \
  --url "https://jihulab.com/api/v4/projects/42/repository/health"
```

响应示例：

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

有关响应中各字段的描述，请参阅 [`RepositoryInfoResponse`](https://gitlab.com/gitlab-org/gitaly/blob/fcb986a6482f82b088488db3ed7ca35adfa42fdc/proto/repository.proto#L444) protobuf 消息。

```