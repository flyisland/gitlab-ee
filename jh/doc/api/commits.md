---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中 Git 提交的 REST API 文档。
title: 提交 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [Git 提交](../user/project/repository/commits/_index.md)。

<a id="responses"></a>

## 响应

此 API 响应中的某些日期字段是重复信息，或可能看起来是重复信息：

- `created_at` 字段仅用于与其他极狐GitLab API 保持一致。它始终与 `committed_date` 字段相同。
- `committed_date` 和 `authored_date` 字段来自不同的数据源，可能不完全相同。

<a id="pagination-response-headers"></a>

### 分页响应头

出于性能原因，极狐GitLab 不会在提交 API 响应中返回以下响应头：

- `x-total`
- `x-total-pages`

有关更多信息，请参阅 [议题 389582](https://gitlab.com/gitlab-org/gitlab/-/issues/389582)。

<a id="list-repository-commits"></a>

## 列出代码仓库提交

获取项目中代码仓库提交的列表。

```plaintext
GET /projects/:id/repository/commits
```

| 属性      | 类型           | 必填 | 描述 |
|----------------|----------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `all`          | 布尔值        | 否       | 检索代码仓库中的每个提交。如果为 `true`，则忽略 `ref_name` 参数。 |
| `author`       | 字符串         | 否       | 按提交作者搜索提交。 |
| `first_parent` | 布尔值        | 否       | 如果为 `true`，则在遇到合并提交时仅跟踪第一个父提交。 |
| `follow`       | 布尔值        | 否       | 如果为 `true`，则在按 `path` 筛选提交时跟踪文件重命名，并返回该文件的提交，即使文件已被重命名。如果为 `false`，则仅返回文件在其当前路径下存在的提交。仅在 `path` 指定单个文件时使用。默认为 `true`。 |
| `order`        | 字符串         | 否       | 按顺序列出提交。可能的值：`default`、[`topo`](https://git-scm.com/docs/git-log#Documentation/git-log.txt---topo-order)。默认为 `default`，即按时间倒序显示提交。 |
| `path`         | 字符串         | 否       | 文件路径。 |
| `ref_name`     | 字符串         | 否       | 代码仓库分支、标签或修订范围名称；如果未提供，则为默认分支。 |
| `since`        | 字符串         | 否       | 仅返回此日期之后（含此日期）的提交，格式为 ISO 8601 `YYYY-MM-DDTHH:MM:SSZ`。 |
| `trailers`     | 布尔值        | 否       | 如果为 `true`，则为每个提交解析并包含 [Git trailers](https://git-scm.com/docs/git-interpret-trailers)。 |
| `until`        | 字符串         | 否       | 仅返回此日期之前（含此日期）的提交，格式为 ISO 8601 `YYYY-MM-DDTHH:MM:SSZ`。 |
| `with_stats`   | 布尔值        | 否       | 如果为 `true`，则检索每个提交的统计信息。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性           | 类型   | 描述 |
|---------------------|--------|-------------|
| `author_email`      | 字符串 | 提交作者的电子邮件地址。 |
| `author_name`       | 字符串 | 提交作者的姓名。 |
| `authored_date`     | 字符串 | 提交的创作日期。 |
| `committed_date`    | 字符串 | 提交的提交日期。 |
| `committer_email`   | 字符串 | 提交者的电子邮件地址。 |
| `committer_name`    | 字符串 | 提交者的姓名。 |
| `created_at`        | 字符串 | 提交的创建日期（与 `committed_date` 相同）。 |
| `extended_trailers` | 对象 | 包含所有值的扩展 Git trailers。 |
| `id`                | 字符串 | 提交的 SHA。 |
| `message`           | 字符串 | 完整的提交消息。 |
| `parent_ids`        | 数组  | 父提交 SHA 的数组。 |
| `short_id`          | 字符串 | 提交的短 SHA。 |
| `title`             | 字符串 | 提交消息的标题。 |
| `trailers`          | 对象 | 从提交消息中解析出的 Git trailers。 |
| `web_url`           | 字符串 | 提交的 Web URL。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits"
```

示例响应：

```json
[
  {
    "id": "ed899a2f4b50b4370feeea94676502b42383c746",
    "short_id": "ed899a2f4b5",
    "title": "Replace sanitize with escape once",
    "author_name": "Example User",
    "author_email": "user@example.com",
    "authored_date": "2021-09-20T11:50:22.001+00:00",
    "committer_name": "Administrator",
    "committer_email": "admin@example.com",
    "committed_date": "2021-09-20T11:50:22.001+00:00",
    "created_at": "2021-09-20T11:50:22.001+00:00",
    "message": "Replace sanitize with escape once",
    "parent_ids": [
      "6104942438c14ec7bd21c6cd5bd995272b3faff6"
    ],
    "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/commit/ed899a2f4b50b4370feeea94676502b42383c746",
    "trailers": {},
    "extended_trailers": {}
  },
  {
    "id": "6104942438c14ec7bd21c6cd5bd995272b3faff6",
    "short_id": "6104942438c",
    "title": "Sanitize for network graph",
    "author_name": "randx",
    "author_email": "user@example.com",
    "committer_name": "ExampleName",
    "committer_email": "user@example.com",
    "created_at": "2021-09-20T09:06:12.201+00:00",
    "message": "Sanitize for network graph\nCc: John Doe <johndoe@gitlab.com>\nCc: Jane Doe <janedoe@gitlab.com>",
    "parent_ids": [
      "ae1d9fb46aa2b07ee9836d49862ec4e2c46fbbba"
    ],
    "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/commit/ed899a2f4b50b4370feeea94676502b42383c746",
    "trailers": {
      "Cc": "Jane Doe <janedoe@gitlab.com>"
    },
    "extended_trailers": {
      "Cc": [
        "John Doe <johndoe@gitlab.com>",
        "Jane Doe <janedoe@gitlab.com>"
      ]
    }
  }
]
```

<a id="create-a-commit"></a>

## 创建提交

通过发布 JSON 负载创建提交

```plaintext
POST /projects/:id/repository/commits
```

> [!note]
> 此端点受[请求大小和速率限制](../administration/instance_limits.md#commits-and-files-api-limits)约束。超过默认 300 MB 限制的请求将被拒绝。大于 20 MB 的请求将受到每 30 秒 3 个请求的速率限制。

| 属性        | 类型              | 必填 | 描述 |
|------------------|-------------------|----------|-------------|
| `branch`         | 字符串            | 是      | 要提交到的分支名称。要创建新分支，还需提供 `start_branch` 或 `start_sha`，并可选择提供 `start_project`。 |
| `commit_message` | 字符串            | 是      | 提交消息。 |
| `id`             | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `actions[]`      | 数组             | 否       | 要作为一批提交的操作哈希数组。有关其可接受的属性，请参阅下一个表格。 |
| `allow_empty`    | 布尔值           | 否       | 当为 `true` 时，创建空提交。默认为 `false`。 |
| `author_email`   | 字符串            | 否       | 指定提交作者的电子邮件地址。 |
| `author_name`    | 字符串            | 否       | 指定提交作者的姓名。 |
| `force`          | 布尔值           | 否       | 如果为 `true`，则基于 `start_branch` 或 `start_sha` 的新提交覆盖 `branch`，替换该分支现有的提交历史。默认为 `false`。 <sup>1</sup> |
| `start_branch`   | 字符串            | 否       | 用作新提交父分支的分支名称。如果未提供且 `start_sha` 也未提供，则默认为 `branch` 的值。与 `start_sha` 互斥。 <sup>1</sup> |
| `start_project`  | 整数或字符串 | 否       | 用作 `start_branch` 或 `start_sha` 来源的项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。默认为 `id` 的值。 |
| `start_sha`      | 字符串            | 否       | 用作新提交父提交的提交 SHA。必须是完整的 40 字符 SHA。与 `start_branch` 互斥。 <sup>1</sup> |
| `stats`          | 布尔值           | 否       | 包含提交统计信息。默认为 `true`。 |

**脚注**：

1. 当 `force` 为 `true` 时，提供 `start_branch` 或 `start_sha` 以指定不同的父提交。
   如果两者均未提供，则 `start_branch` 默认为 `branch` 的值，新提交基于当前分支顶端。
   在这种情况下，`force` 没有效果，因为结果与常规提交相同。

> [!note]
> 包含许多操作的大型请求可能受大小限制。有关更多信息，请参阅[提交 API 限制](../administration/instance_limits.md#commits-and-files-api-limits)。

| `actions[]` 属性 | 类型    | 必填 | 描述 |
|-----------------------|---------|----------|-------------|
| `action`              | 字符串  | 是      | 要执行的操作：`create`、`delete`、`move`、`update` 或 `chmod`。 |
| `file_path`           | 字符串  | 是      | 文件的完整路径。例如：`lib/class.rb`。 |
| `content`             | 字符串  | 否       | 文件内容，除 `delete`、`chmod` 和 `move` 外，其他操作均必填。未指定 `content` 的移动操作会保留现有文件内容，而 `content` 的任何其他值都会覆盖文件内容。 |
| `encoding`            | 字符串  | 否       | `text` 或 `base64`。默认为 `text`。 |
| `execute_filemode`    | 布尔值 | 否       | 如果为 `true`，则启用文件的执行标志。如果为 `false`，则禁用它。仅对 `chmod` 操作生效。 |
| `last_commit_id`      | 字符串  | 否       | 上次已知的文件提交 ID。仅在更新、移动和删除操作中生效。 |
| `previous_path`       | 字符串  | 否       | 被移动文件的原始完整路径。例如 `lib/class1.rb`。仅对 `move` 操作生效。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性         | 类型   | 描述 |
|-------------------|--------|-------------|
| `author_email`    | 字符串 | 提交作者的电子邮件地址。 |
| `author_name`     | 字符串 | 提交作者的姓名。 |
| `authored_date`   | 字符串 | 提交的创作日期。 |
| `committed_date`  | 字符串 | 提交的提交日期。 |
| `committer_email` | 字符串 | 提交者的电子邮件地址。 |
| `committer_name`  | 字符串 | 提交者的姓名。 |
| `created_at`      | 字符串 | 提交的创建日期。 |
| `id`              | 字符串 | 创建的提交的 SHA。 |
| `message`         | 字符串 | 完整的提交消息。 |
| `parent_ids`      | 数组  | 父提交 SHA 的数组。 |
| `short_id`        | 字符串 | 创建的提交的短 SHA。 |
| `stats`           | 对象 | 关于提交的统计信息（新增、删除、总计）。 |
| `status`          | 字符串 | 提交的状态。 |
| `title`           | 字符串 | 提交消息的标题。 |
| `web_url`         | 字符串 | 提交的 Web URL。 |

```shell
PAYLOAD=$(cat << 'JSON'
{
  "branch": "main",
  "commit_message": "some commit message",
  "actions": [
    {
      "action": "create",
      "file_path": "foo/bar",
      "content": "some content"
    },
    {
      "action": "delete",
      "file_path": "foo/bar2"
    },
    {
      "action": "move",
      "file_path": "foo/bar3",
      "previous_path": "foo/bar4",
      "content": "some content"
    },
    {
      "action": "update",
      "file_path": "foo/bar5",
      "content": "new content"
    },
    {
      "action": "chmod",
      "file_path": "foo/bar5",
      "execute_filemode": true
    }
  ]
}
JSON
)
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data "$PAYLOAD" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository/commits"
```

示例响应：

```json
{
  "id": "ed899a2f4b50b4370feeea94676502b42383c746",
  "short_id": "ed899a2f4b5",
  "title": "some commit message",
  "author_name": "Example User",
  "author_email": "user@example.com",
  "committer_name": "Example User",
  "committer_email": "user@example.com",
  "created_at": "2016-09-20T09:26:24.000-07:00",
  "message": "some commit message",
  "parent_ids": [
    "ae1d9fb46aa2b07ee9836d49862ec4e2c46fbbba"
  ],
  "committed_date": "2016-09-20T09:26:24.000-07:00",
  "authored_date": "2016-09-20T09:26:24.000-07:00",
  "stats": {
    "additions": 2,
    "deletions": 2,
    "total": 4
  },
  "status": null,
  "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/commit/ed899a2f4b50b4370feeea94676502b42383c746"
}
```

极狐GitLab 支持[表单编码](rest/_index.md#array-and-hash-types)。以下是使用提交 API 进行表单编码的示例：

```shell
curl --request POST \
     --form "branch=main" \
     --form "commit_message=some commit message" \
     --form "start_branch=main" \
     --form "actions[][action]=create" \
     --form "actions[][file_path]=foo/bar" \
     --form "actions[][content]=</path/to/local.file" \
     --form "actions[][action]=delete" \
     --form "actions[][file_path]=foo/bar2" \
     --form "actions[][action]=move" \
     --form "actions[][file_path]=foo/bar3" \
     --form "actions[][previous_path]=foo/bar4" \
     --form "actions[][content]=</path/to/local1.file" \
     --form "actions[][action]=update" \
     --form "actions[][file_path]=foo/bar5" \
     --form "actions[][content]=</path/to/local2.file" \
     --form "actions[][action]=chmod" \
     --form "actions[][file_path]=foo/bar5" \
     --form "actions[][execute_filemode]=true" \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/repository/commits"
```

<a id="retrieve-a-commit"></a>

## 检索提交

检索由提交哈希或分支或标签名称标识的指定提交。

```plaintext
GET /projects/:id/repository/commits/:sha
```

参数：

| 属性 | 类型           | 必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串         | 是      | 提交哈希或代码仓库分支或标签的名称。 |
| `stats`   | 布尔值        | 否       | 包含提交统计信息。默认为 `true`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性         | 类型   | 描述 |
|-------------------|--------|-------------|
| `author_email`    | 字符串 | 提交作者的电子邮件地址。 |
| `author_name`     | 字符串 | 提交作者的姓名。 |
| `authored_date`   | 字符串 | 提交的创作日期。 |
| `committed_date`  | 字符串 | 提交的提交日期。 |
| `committer_email` | 字符串 | 提交者的电子邮件地址。 |
| `committer_name`  | 字符串 | 提交者的姓名。 |
| `created_at`      | 字符串 | 提交的创建日期。 |
| `id`              | 字符串 | 提交的 SHA。 |
| `last_pipeline`   | 对象 | 此提交的最后一次流水线的信息。 |
| `message`         | 字符串 | 完整的提交消息。 |
| `parent_ids`      | 数组  | 父提交 SHA 的数组。 |
| `short_id`        | 字符串 | 提交的短 SHA。 |
| `stats`           | 对象 | 关于提交的统计信息（新增、删除、总计）。 |
| `status`          | 字符串 | 提交的状态。 |
| `title`           | 字符串 | 提交消息的标题。 |
| `web_url`         | 字符串 | 提交的 Web URL。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/main"
```

示例响应：

```json
{
  "id": "6104942438c14ec7bd21c6cd5bd995272b3faff6",
  "short_id": "6104942438c",
  "title": "Sanitize for network graph",
  "author_name": "randx",
  "author_email": "user@example.com",
  "committer_name": "Dmitriy",
  "committer_email": "user@example.com",
  "created_at": "2021-09-20T09:06:12.300+03:00",
  "message": "Sanitize for network graph",
  "committed_date": "2021-09-20T09:06:12.300+03:00",
  "authored_date": "2021-09-20T09:06:12.420+03:00",
  "parent_ids": [
    "ae1d9fb46aa2b07ee9836d49862ec4e2c46fbbba"
  ],
  "last_pipeline": {
    "id": 8,
    "ref": "main",
    "sha": "2dc6aa325a317eda67812f05600bdf0fcdc70ab0",
    "status": "created"
  },
  "stats": {
    "additions": 15,
    "deletions": 10,
    "total": 25
  },
  "status": "running",
  "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/commit/6104942438c14ec7bd21c6cd5bd995272b3faff6"
}
```

<a id="list-all-references-a-commit-is-pushed-to"></a>

## 列出提交被推送到的所有引用

列出提交被推送到的所有引用（来自分支或标签）。可以使用分页参数 `page` 和 `per_page` 来限制引用列表。

```plaintext
GET /projects/:id/repository/commits/:sha/refs
```

参数：

| 属性 | 类型           | 必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串         | 是      | 提交哈希。 |
| `type`    | 字符串         | 否       | 提交的范围。可能的值：`branch`、`tag`、`all`。默认为 `all`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `name`    | 字符串 | 分支或标签的名称。 |
| `type`    | 字符串 | 引用的类型（`branch` 或 `tag`）。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/5937ac0a7beb003549fc5fd26fc247adbce4a52e/refs?type=all"
```

示例响应：

```json
[
  {
    "type": "branch",
    "name": "'test'"
  },
  {
    "type": "branch",
    "name": "add-balsamiq-file"
  },
  {
    "type": "branch",
    "name": "wip"
  },
  {
    "type": "tag",
    "name": "v1.1.0"
  }
]
```

<a id="get-commit-sequence"></a>

## 获取提交序号

通过从给定提交跟踪父链接，获取项目中提交的序号。

此 API 为给定的提交 SHA 提供与 `git rev-list --count` 命令基本相同的功能。

```plaintext
GET /projects/:id/repository/commits/:sha/sequence
```

参数：

| 属性      | 类型           | 必填 | 描述 |
|----------------|----------------|----------|-------------|
| `id`           | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`          | 字符串         | 是      | 提交哈希。 |
| `first_parent` | 布尔值        | 否       | 如果为 `true`，则在遇到合并提交时仅跟踪第一个父提交。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `count` | 整数 | 提交的序号。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/5937ac0a7beb003549fc5fd26fc247adbce4a52e/sequence"
```

示例响应：

```json
{
  "count": 632
}
```

<a id="cherry-pick-a-commit"></a>

## 拣选提交

将提交拣选到给定分支。

```plaintext
POST /projects/:id/repository/commits/:sha/cherry_pick
```

参数：

| 属性 | 类型           | 必填 | 描述 |
|-----------|----------------|----------|-------------|
| `branch`  | 字符串         | 是      | 分支的名称。 |
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串         | 是      | 提交哈希。 |
| `dry_run` | 布尔值        | 否       | 如果为 `true`，则不提交任何更改。默认为 `false`。 |
| `message` | 字符串         | 否       | 用于新提交的自定义提交消息。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性         | 类型   | 描述 |
|-------------------|--------|-------------|
| `author_email`    | 字符串 | 原始提交作者的电子邮件地址。 |
| `author_name`     | 字符串 | 原始提交作者的姓名。 |
| `authored_date`   | 字符串 | 原始提交的创作日期。 |
| `committed_date`  | 字符串 | 拣选提交的提交日期。 |
| `committer_email` | 字符串 | 拣选提交者的电子邮件地址。 |
| `committer_name`  | 字符串 | 拣选提交者的姓名。 |
| `created_at`      | 字符串 | 拣选提交的创建日期。 |
| `id`              | 字符串 | 拣选提交的 SHA。 |
| `message`         | 字符串 | 完整的提交消息。 |
| `parent_ids`      | 数组  | 父提交 SHA 的数组。 |
| `short_id`        | 字符串 | 拣选提交的短 SHA。 |
| `title`           | 字符串 | 提交消息的标题。 |
| `web_url`         | 字符串 | 拣选提交的 Web URL。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "branch=main" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/main/cherry_pick"
```

示例响应：

```json
{
  "id": "8b090c1b79a14f2bd9e8a738f717824ff53aebad",
  "short_id": "8b090c1b",
  "author_name": "Example User",
  "author_email": "user@example.com",
  "authored_date": "2016-12-12T20:10:39.000+01:00",
  "created_at": "2016-12-12T20:10:39.000+01:00",
  "committer_name": "Administrator",
  "committer_email": "admin@example.com",
  "committed_date": "2016-12-12T20:10:39.000+01:00",
  "title": "Feature added",
  "message": "Feature added\n\nSigned-off-by: Example User <user@example.com>\n",
  "parent_ids": [
    "a738f717824ff53aebad8b090c1b79a14f2bd9e8"
  ],
  "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/commit/8b090c1b79a14f2bd9e8a738f717824ff53aebad"
}
```

如果拣选失败，响应会提供有关原因的上下文：

```json
{
  "message": "Sorry, we cannot cherry-pick this commit automatically. This commit may already have been cherry-picked, or a more recent commit may have updated some of its content.",
  "error_code": "empty"
}
```

在这种情况下，拣选失败是因为变更集为空，这很可能表明该提交已存在于目标分支中。另一个可能的错误代码是 `conflict`，表示存在合并冲突。

当启用 `dry_run` 时，服务器会尝试应用拣选，_但不会实际提交任何结果更改_。如果拣选干净地应用，API 会以 `200 OK` 响应：

```json
{
  "dry_run": "success"
}
```

如果失败，显示的错误与未启用 dry run 时的失败相同。

<a id="revert-a-commit"></a>

## 还原提交

在给定分支中还原提交。

```plaintext
POST /projects/:id/repository/commits/:sha/revert
```

参数：

| 属性 | 类型           | 必填 | 描述 |
|-----------|----------------|----------|-------------|
| `branch`  | 字符串         | 是      | 目标分支名称。 |
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串         | 是      | 要还原的提交 SHA。 |
| `dry_run` | 布尔值        | 否       | 如果为 `true`，则不提交任何更改。默认为 `false`。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性         | 类型   | 描述 |
|-------------------|--------|-------------|
| `author_email`    | 字符串 | 还原提交作者的电子邮件地址。 |
| `author_name`     | 字符串 | 还原提交作者的姓名。 |
| `authored_date`   | 字符串 | 还原提交的创作日期。 |
| `committed_date`  | 字符串 | 还原提交的提交日期。 |
| `committer_email` | 字符串 | 还原提交提交者的电子邮件地址。 |
| `committer_name`  | 字符串 | 还原提交提交者的姓名。 |
| `created_at`      | 字符串 | 还原提交的创建日期。 |
| `id`              | 字符串 | 还原提交的 SHA。 |
| `message`         | 字符串 | 完整的还原提交消息。 |
| `parent_ids`      | 数组  | 父提交 SHA 的数组。 |
| `short_id`        | 字符串 | 还原提交的短 SHA。 |
| `title`           | 字符串 | 还原提交消息的标题。 |
| `web_url`         | 字符串 | 还原提交的 Web URL。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "branch=main" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/a738f717824ff53aebad8b090c1b79a14f2bd9e8/revert"
```

示例响应：

```json
{
  "id": "8b090c1b79a14f2bd9e8a738f717824ff53aebad",
  "short_id": "8b090c1b",
  "title": "Revert \"Feature added\"",
  "created_at": "2018-11-08T15:55:26.000Z",
  "parent_ids": [
    "a738f717824ff53aebad8b090c1b79a14f2bd9e8"
  ],
  "message": "Revert \"Feature added\"\n\nThis reverts commit a738f717824ff53aebad8b090c1b79a14f2bd9e8",
  "author_name": "Administrator",
  "author_email": "admin@example.com",
  "authored_date": "2018-11-08T15:55:26.000Z",
  "committer_name": "Administrator",
  "committer_email": "admin@example.com",
  "committed_date": "2018-11-08T15:55:26.000Z",
  "web_url": "https://gitlab.example.com/janedoe/gitlab-foss/-/commit/8b090c1b79a14f2bd9e8a738f717824ff53aebad"
}
```

如果还原失败，响应会提供有关原因的上下文：

```json
{
  "message": "Sorry, we cannot revert this commit automatically. This commit may already have been reverted, or a more recent commit may have updated some of its content.",
  "error_code": "conflict"
}
```

在这种情况下，还原失败是因为尝试的还原产生了合并冲突。另一个可能的错误代码是 `empty`，表示变更集为空，这很可能是因为更改已被还原。

当启用 `dry_run` 时，服务器会尝试应用还原，_但不会实际提交任何结果更改_。如果还原干净地应用，API 会以 `200 OK` 响应：

```json
{
  "dry_run": "success"
}
```

如果失败，显示的错误与未启用 dry run 时的失败相同。

<a id="retrieve-commit-diff"></a>

## 检索提交差异

检索项目中提交的差异。

```plaintext
GET /projects/:id/repository/commits/:sha/diff
```

参数：

| 属性 | 类型           | 必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串         | 是      | 提交哈希或代码仓库分支或标签的名称。 |
| `unidiff` | 布尔值        | 否       | 如果为 `true`，则以[统一差异](https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html)格式呈现差异。默认为 `false`。 |

> [!note]
> 此端点受[差异限制](../administration/diff_limits.md)约束。当提交超过配置的最大文件数时，分页停止，不会返回超出限制的其他文件。有关 JihuLab.com 的特定限制，请参阅差异显示限制。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性      | 类型    | 描述 |
|----------------|---------|-------------|
| `a_mode`       | 字符串  | 文件的旧文件模式。 |
| `b_mode`       | 字符串  | 文件的新文件模式。 |
| `collapsed`    | 布尔值 | 文件差异被排除，但可以按需获取。 |
| `deleted_file` | 布尔值 | 文件已被删除。 |
| `diff`         | 字符串  | 对文件所做更改的差异表示。 |
| `new_file`     | 布尔值 | 文件已被添加。 |
| `new_path`     | 字符串  | 文件的新路径。 |
| `old_path`     | 字符串  | 文件的旧路径。 |
| `renamed_file` | 布尔值 | 文件已被重命名。 |
| `too_large`    | 布尔值 | 文件差异被排除且无法检索。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/main/diff"
```

示例响应：

```json
[
  {
    "diff": "@@ -71,6 +71,8 @@\n sudo -u git -H bundle exec rake migrate_keys RAILS_ENV=production\n sudo -u git -H bundle exec rake migrate_inline_notes RAILS_ENV=production\n \n+sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production\n+\n ```\n \n ### 6. Update config files",
    "collapsed": false,
    "too_large": false,
    "new_path": "doc/update/5.4-to-6.0.md",
    "old_path": "doc/update/5.4-to-6.0.md",
    "a_mode": null,
    "b_mode": "100644",
    "new_file": false,
    "renamed_file": false,
    "deleted_file": false
  }
]
```

<a id="list-all-commit-comments"></a>

## 列出所有提交评论

列出项目中提交的所有评论。

```plaintext
GET /projects/:id/repository/commits/:sha/comments
```

参数：

| 属性 | 类型           | 必填 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串         | 是      | 提交哈希或代码仓库分支或标签的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性 | 类型   | 描述 |
|-----------|--------|-------------|
| `author`  | 对象 | 评论作者的信息。 |
| `note`    | 字符串 | 评论文本。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/main/comments"
```

示例响应：

```json
[
  {
    "note": "this code is really nice",
    "author": {
      "id": 11,
      "username": "admin",
      "email": "admin@local.host",
      "name": "Administrator",
      "state": "active",
      "created_at": "2014-03-06T08:17:35.000Z"
    }
  }
]
```

<a id="post-comment-to-commit"></a>

## 向提交发布评论

在提交上创建评论。

要在特定文件的特定行上发布评论，您必须指定完整的提交 SHA、`path`、`line`，并将 `line_type` 设置为 `new`。

如果以下任一情况成立，评论将添加到最后一个提交的末尾：

- `sha` 是分支或标签，且 `line` 或 `path` 无效
- `line` 行号无效（不存在）
- `path` 无效（不存在）

在上述任一情况下，`line`、`line_type` 和 `path` 的响应将设置为 `null`。

有关在合并请求上评论的其他方法，请参阅 notes API 中的[创建合并请求评论](notes.md#create-a-merge-request-note)，以及 discussions API 中的[在合并请求差异中创建新讨论串](discussions.md#create-a-new-thread-in-the-merge-request-diff)。

```plaintext
POST /projects/:id/repository/commits/:sha/comments
```

| 属性   | 类型           | 必填 | 描述 |
|-------------|----------------|----------|-------------|
| `id`        | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `note`      | 字符串         | 是      | 评论文本。 |
| `sha`       | 字符串         | 是      | 提交 SHA 或代码仓库分支或标签的名称。 |
| `line`      | 整数        | 否       | 评论应放置的行号。 |
| `line_type` | 字符串         | 否       | 行类型。接受 `new` 或 `old` 作为参数。 |
| `path`      | 字符串         | 否       | 相对于代码仓库的文件路径。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性    | 类型    | 描述 |
|--------------|---------|-------------|
| `author`     | 对象  | 评论作者的信息。 |
| `created_at` | 字符串  | 评论的创建日期。 |
| `line_type`  | 字符串  | 评论所在行的类型。 |
| `line`       | 整数 | 评论所在的行号。 |
| `note`       | 字符串  | 评论文本。 |
| `path`       | 字符串  | 相对于代码仓库的文件路径。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "note=Nice picture\!" \
  --form "path=README.md" \
  --form "line=11" \
  --form "line_type=new" \
  --url "https://gitlab.example.com/api/v4/projects/17/repository/commits/18f3e63d05582537db6d183d9d557be09e1f90c8/comments"
```

示例响应：

```json
{
  "author": {
    "web_url": "https://gitlab.example.com/janedoe",
    "avatar_url": "https://gitlab.example.com/uploads/user/avatar/28/jane-doe-400-400.png",
    "username": "janedoe",
    "state": "active",
    "name": "Jane Doe",
    "id": 28
  },
  "created_at": "2016-01-19T09:44:55.600Z",
  "line_type": "new",
  "path": "README.md",
  "line": 11,
  "note": "Nice picture!"
}
```

<a id="list-all-commit-discussions"></a>

## 列出所有提交讨论

列出项目中提交的所有讨论。

```plaintext
GET /projects/:id/repository/commits/:sha/discussions
```

参数：

| 属性 | 类型 | 必填 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | 整数或字符串 | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串 | 是 | 提交哈希或代码仓库分支或标签的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性         | 类型    | 描述 |
|-------------------|---------|-------------|
| `id`              | 字符串  | 讨论的 ID。 |
| `individual_note` | 布尔值 | 如果为 `true`，则该讨论是单条评论。 |
| `notes`           | 数组   | 讨论中的评论数组。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/4604744a1c64de00ff62e1e8a6766919923d2b41/discussions"
```

示例响应：

```json
[
  {
    "id": "4604744a1c64de00ff62e1e8a6766919923d2b41",
    "individual_note": true,
    "notes": [
      {
        "id": 334686748,
        "type": null,
        "body": "Nice piece of code!",
        "attachment": null,
        "author": {
          "id": 28,
          "name": "Jane Doe",
          "username": "janedoe",
          "web_url": "https://gitlab.example.com/janedoe",
          "state": "active",
          "avatar_url": "https://gitlab.example.com/uploads/user/avatar/28/jane-doe-400-400.png"
        },
        "created_at": "2020-04-30T18:48:11.432Z",
        "updated_at": "2020-04-30T18:48:11.432Z",
        "system": false,
        "noteable_id": null,
        "noteable_type": "Commit",
        "resolvable": false,
        "confidential": null,
        "noteable_iid": null,
        "commands_changes": {}
      }
    ]
  }
]
```

<a id="commit-status"></a>

## 提交状态

用于极狐GitLab 的提交状态 API。

<a id="list-commit-statuses"></a>

### 列出提交状态

列出项目中提交的状态。可以使用分页参数 `page` 和 `per_page` 来限制引用列表。

```plaintext
GET /projects/:id/repository/commits/:sha/statuses
```

| 属性     | 类型              | 必填 | 描述 |
|---------------|-------------------|----------|-------------|
| `id`          | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`         | 字符串            | 是      | 提交的哈希。 |
| `all`         | 布尔值           | 否       | 如果为 `true`，则包含所有状态，而不仅仅是最新状态。默认为 `false`。 |
| `name`        | 字符串            | 否       | 按[作业名称](../ci/yaml/_index.md#job-keywords)筛选状态。例如，`bundler:audit`。 |
| `order_by`    | 字符串            | 否       | 状态排序的值。有效值为 `id` 和 `pipeline_id`。默认为 `id`。 |
| `pipeline_id` | 整数           | 否       | 按流水线 ID 筛选状态。例如，`1234`。 |
| `ref`         | 字符串            | 否       | 分支或标签的名称。默认为默认分支。 |
| `sort`        | 字符串            | 否       | 按升序或降序对状态排序。有效值为 `asc` 和 `desc`。默认为 `asc`。 |
| `stage`       | 字符串            | 否       | 按[构建阶段](../ci/yaml/_index.md#stages)筛选状态。例如，`test`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性       | 类型    | 描述 |
|-----------------|---------|-------------|
| `allow_failure` | 布尔值 | 如果为 `true`，则该状态允许失败。 |
| `author`        | 对象  | 状态作者的信息。 |
| `created_at`    | 字符串  | 状态的创建日期。 |
| `description`   | 字符串  | 状态的描述。 |
| `finished_at`   | 字符串  | 状态的完成日期。 |
| `id`            | 整数 | 状态的 ID。 |
| `name`          | 字符串  | 状态的名称。 |
| `ref`           | 字符串  | 提交的引用（分支或标签）。 |
| `sha`           | 字符串  | 提交的 SHA。 |
| `started_at`    | 字符串  | 状态的开始日期。 |
| `status`        | 字符串  | 提交的状态。 |
| `target_url`    | 字符串  | 与状态关联的目标 URL。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/17/repository/commits/18f3e63d05582537db6d183d9d557be09e1f90c8/statuses"
```

示例响应：

```json
[
  ...
  {
    "status": "pending",
    "created_at": "2016-01-19T08:40:25.934Z",
    "started_at": null,
    "name": "bundler:audit",
    "allow_failure": true,
    "author": {
      "username": "janedoe",
      "state": "active",
      "web_url": "https://gitlab.example.com/janedoe",
      "avatar_url": "https://gitlab.example.com/uploads/user/avatar/28/jane-doe-400-400.png",
      "id": 28,
      "name": "Jane Doe"
    },
    "description": null,
    "sha": "18f3e63d05582537db6d183d9d557be09e1f90c8",
    "target_url": "https://gitlab.example.com/janedoe/gitlab-foss/builds/91",
    "finished_at": null,
    "id": 91,
    "ref": "main"
  },
  {
    "started_at": null,
    "name": "test",
    "allow_failure": false,
    "status": "pending",
    "created_at": "2016-01-19T08:40:25.832Z",
    "target_url": "https://gitlab.example.com/janedoe/gitlab-foss/builds/90",
    "id": 90,
    "finished_at": null,
    "ref": "main",
    "sha": "18f3e63d05582537db6d183d9d557be09e1f90c8",
    "author": {
      "id": 28,
      "name": "Jane Doe",
      "username": "janedoe",
      "web_url": "https://gitlab.example.com/janedoe",
      "state": "active",
      "avatar_url": "https://gitlab.example.com/uploads/user/avatar/28/jane-doe-400-400.png"
    },
    "description": null
  }
  ...
]
```

<a id="set-commit-pipeline-status"></a>

### 设置提交流水线状态

添加或更新由 `external` 阶段中的作业表示的提交状态。如果提交与合并请求关联，则将提交定位在合并请求的源分支中。

当您设置提交状态时：

- 首先搜索现有的流水线，以将作业附加到其中。
- 如果不存在合适的流水线，则会创建新的流水线，并设置 `CI_PIPELINE_SOURCE: external`。

有关更多信息，请参阅[外部提交状态](../ci/ci_cd_for_external_repos/external_commit_statuses.md)。

> [!note]
> 当同一提交存在重复的流水线时，外部状态由哪个流水线接收可能不明确。
> 请配置您的流水线以[避免重复](../ci/jobs/job_rules.md#avoid-duplicate-pipelines)。

如果流水线已存在且超过[单个流水线中的最大作业数限制](../administration/cicd/limits.md#maximum-number-of-jobs-in-a-pipeline)：

- 如果指定了 `pipeline_id`，则返回 `422` 错误：`The number of jobs has exceeded the limit`。
- 否则，将创建新的流水线。

如果 SHA/ref 组合的更新已在进行中，则返回 `409` 错误。要处理此错误，请重试请求。

```plaintext
POST /projects/:id/statuses/:sha
```

| 属性           | 类型              | 必填 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`               | 字符串            | 是      | 提交 SHA。 |
| `state`             | 字符串            | 是      | 状态的状态。可以是以下之一：`pending`、`running`、`success`、`failed`、`canceled`、`skipped`。 |
| `coverage`          | 浮点数             | 否       | 总代码覆盖率。 |
| `description`       | 字符串            | 否       | 状态的简短描述。必须为 255 个字符或更少。 |
| `name` 或 `context` | 字符串            | 否       | 用于将此状态与其他系统的状态区分开的标签。默认值为 `default`。 |
| `pipeline_id`       | 整数           | 否       | 要设置状态的流水线的 ID。当同一 SHA 上有多个流水线时使用。 |
| `ref`               | 字符串            | 否       | 状态所引用的 `ref`（分支或标签）。必须为 255 个字符或更少。 |
| `target_url`        | 字符串            | 否       | 与此状态关联的目标 URL。必须为 255 个字符或更少。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性       | 类型    | 描述 |
|-----------------|---------|-------------|
| `allow_failure` | 布尔值 | 如果为 `true`，则该状态允许失败。 |
| `author`        | 对象  | 状态作者的信息。 |
| `coverage`      | 浮点数   | 代码覆盖率百分比。 |
| `created_at`    | 字符串  | 状态的创建日期。 |
| `description`   | 字符串  | 状态的描述。 |
| `finished_at`   | 字符串  | 状态的完成日期。 |
| `id`            | 整数 | 状态的 ID。 |
| `name`          | 字符串  | 状态的名称。 |
| `ref`           | 字符串  | 提交的引用（分支或标签）。 |
| `sha`           | 字符串  | 提交的 SHA。 |
| `started_at`    | 字符串  | 状态的开始日期。 |
| `status`        | 字符串  | 提交的状态。 |
| `target_url`    | 字符串  | 与状态关联的目标 URL。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/17/statuses/18f3e63d05582537db6d183d9d557be09e1f90c8?state=success"
```

示例响应：

```json
{
  "author": {
    "web_url": "https://gitlab.example.com/janedoe",
    "name": "Jane Doe",
    "avatar_url": "https://gitlab.example.com/uploads/user/avatar/28/jane-doe-400-400.png",
    "username": "janedoe",
    "state": "active",
    "id": 28
  },
  "name": "default",
  "sha": "18f3e63d05582537db6d183d9d557be09e1f90c8",
  "status": "success",
  "coverage": 100.0,
  "description": null,
  "id": 93,
  "target_url": null,
  "ref": null,
  "started_at": null,
  "created_at": "2016-01-19T09:05:50.355Z",
  "allow_failure": false,
  "finished_at": "2016-01-19T09:05:50.365Z"
}
```

<a id="list-merge-requests-associated-with-a-commit"></a>

## 列出与提交关联的合并请求

返回最初引入特定提交的合并请求的信息。

```plaintext
GET /projects/:id/repository/commits/:sha/merge_requests
```

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串            | 是      | 提交 SHA。 |
| `state`   | 字符串            | 否       | 返回具有指定状态的合并请求：`opened`、`closed`、`locked` 或 `merged`。省略此参数可获取所有状态的合并请求。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性                      | 类型    | 描述 |
|--------------------------------|---------|-------------|
| `assignee`                     | 对象  | 合并请求指派人的信息。 |
| `author`                       | 对象  | 合并请求作者的信息。 |
| `created_at`                   | 字符串  | 合并请求的创建日期。 |
| `description`                  | 字符串  | 合并请求的描述。 |
| `discussion_locked`            | 布尔值 | 如果为 `true`，则讨论已锁定。 |
| `downvotes`                    | 整数 | 反对票数。 |
| `draft`                        | 布尔值 | 如果为 `true`，则该合并请求是草稿。 |
| `force_remove_source_branch`   | 布尔值 | 如果为 `true`，则强制删除源分支。 |
| `id`                           | 整数 | 合并请求的 ID。 |
| `iid`                          | 整数 | 合并请求的内部 ID。 |
| `labels`                       | 数组   | 与合并请求关联的标记。 |
| `merge_commit_sha`             | 字符串  | 合并提交的 SHA。 |
| `merge_status`                 | 字符串  | 合并请求的合并状态。 |
| `merge_when_pipeline_succeeds` | 布尔值 | 如果为 `true`，则在流水线成功时合并。 |
| `milestone`                    | 对象  | 与合并请求关联的里程碑。 |
| `project_id`                   | 整数 | 项目 ID。 |
| `sha`                          | 字符串  | 合并请求的 SHA。 |
| `should_remove_source_branch`  | 布尔值 | 如果为 `true`，则在合并后删除源分支。 |
| `source_branch`                | 字符串  | 合并请求的源分支。 |
| `source_project_id`            | 整数 | 源项目 ID。 |
| `squash_commit_sha`            | 字符串  | 压缩提交的 SHA。 |
| `state`                        | 字符串  | 合并请求的状态。 |
| `target_branch`                | 字符串  | 合并请求的目标分支。 |
| `target_project_id`            | 整数 | 目标项目 ID。 |
| `time_stats`                   | 对象  | 时间跟踪统计信息。 |
| `title`                        | 字符串  | 合并请求的标题。 |
| `updated_at`                   | 字符串  | 合并请求的最后更新日期。 |
| `upvotes`                      | 整数 | 赞成票数。 |
| `user_notes_count`             | 整数 | 用户评论数。 |
| `web_url`                      | 字符串  | 合并请求的 Web URL。 |
| `work_in_progress`             | 布尔值 | 如果为 `true`，则该合并请求被设置为进行中。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/repository/commits/af5b13261899fb2c0db30abdd0af8b07cb44fdc5/merge_requests?state=opened"
```

示例响应：

```json
[
  {
    "id": 45,
    "iid": 1,
    "project_id": 35,
    "title": "Add new file",
    "description": "",
    "state": "opened",
    "created_at": "2018-03-26T17:26:30.916Z",
    "updated_at": "2018-03-26T17:26:30.916Z",
    "target_branch": "main",
    "source_branch": "test-branch",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "web_url": "https://gitlab.example.com/janedoe",
      "name": "Jane Doe",
      "avatar_url": "https://gitlab.example.com/uploads/user/avatar/28/jane-doe-400-400.png",
      "username": "janedoe",
      "state": "active",
      "id": 28
    },
    "assignee": null,
    "source_project_id": 35,
    "target_project_id": 35,
    "labels": [],
    "draft": false,
    "work_in_progress": false,
    "milestone": null,
    "merge_when_pipeline_succeeds": false,
    "merge_status": "can_be_merged",
    "sha": "af5b13261899fb2c0db30abdd0af8b07cb44fdc5",
    "merge_commit_sha": null,
    "squash_commit_sha": null,
    "user_notes_count": 0,
    "discussion_locked": null,
    "should_remove_source_branch": null,
    "force_remove_source_branch": false,
    "web_url": "https://gitlab.example.com/root/test-project/merge_requests/1",
    "time_stats": {
      "time_estimate": 0,
      "total_time_spent": 0,
      "human_time_estimate": null,
      "human_total_time_spent": null
    }
  }
]
```

<a id="retrieve-commit-signature"></a>

## 检索提交签名

如果提交已签名，则检索[提交的签名](../user/project/repository/signed_commits/_index.md)。对于未签名的提交，将返回 404 响应。

```plaintext
GET /projects/:id/repository/commits/:sha/signature
```

参数：

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `sha`     | 字符串            | 是      | 提交哈希或代码仓库分支或标签的名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性               | 类型    | 描述 |
|-------------------------|---------|-------------|
| `commit_source`         | 字符串  | 提交的来源。 |
| `gpg_key_id`            | 整数 | GPG 密钥的 ID（用于 PGP 签名）。 |
| `gpg_key_primary_keyid` | 字符串  | GPG 密钥的主密钥 ID。 |
| `gpg_key_subkey_id`     | 字符串  | GPG 密钥的子密钥 ID。 |
| `gpg_key_user_email`    | 字符串  | 与 GPG 密钥关联的电子邮件地址。 |
| `gpg_key_user_name`     | 字符串  | 与 GPG 密钥关联的用户名。 |
| `key`                   | 对象  | SSH 密钥信息（用于 SSH 签名）。 |
| `signature_type`        | 字符串  | 签名类型（`PGP`、`SSH` 或 `X509`）。 |
| `verification_status`   | 字符串  | 签名的验证状态。 |
| `x509_certificate`      | 对象  | X.509 证书信息（用于 X.509 签名）。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository/commits/da738facbc19eb2fc2cef57c49be0e6038570352/signature"
```

提交为 GPG 签名时的示例响应：

```json
{
  "signature_type": "PGP",
  "verification_status": "verified",
  "gpg_key_id": 1,
  "gpg_key_primary_keyid": "8254AAB3FBD54AC9",
  "gpg_key_user_name": "John Doe",
  "gpg_key_user_email": "johndoe@example.com",
  "gpg_key_subkey_id": null,
  "commit_source": "gitaly"
}
```

提交使用 SSH 签名时的示例响应：

```json
{
  "signature_type": "SSH",
  "verification_status": "verified",
  "key": {
    "id": 11,
    "title": "Key",
    "created_at": "2023-05-08T09:12:38.503Z",
    "expires_at": "2024-05-07T00:00:00.000Z",
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZzYDq6DhLp3aX84DGIV3F6Vf+Ae4yCTTz7RnqMJOlR MyKey)",
    "usage_type": "auth_and_signing"
  },
  "commit_source": "gitaly"
}
```

提交为 X.509 签名时的示例响应：

```json
{
  "signature_type": "X509",
  "verification_status": "unverified",
  "x509_certificate": {
    "id": 1,
    "subject": "CN=gitlab@example.org,OU=Example,O=World",
    "subject_key_identifier": "BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC:BC",
    "email": "gitlab@example.org",
    "serial_number": 278969561018901340486471282831158785578,
    "certificate_status": "good",
    "x509_issuer": {
      "id": 1,
      "subject": "CN=PKI,OU=Example,O=World",
      "subject_key_identifier": "AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB:AB",
      "crl_url": "http://example.com/pki.crl"
    }
  },
  "commit_source": "gitaly"
}
```

提交未签名时的示例响应：

```json
{
  "message": "404 GPG Signature Not Found"
}
```
