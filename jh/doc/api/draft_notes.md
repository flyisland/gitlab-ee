---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for draft notes (unpublished comments) in 极狐GitLab.
title: 草稿评论 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理草稿评论。这些评论是合并请求中待处理的、未发布的评论。
草稿评论可以发起一个讨论，或作为对已有讨论的回复来继续讨论。

在发布之前，草稿评论仅对作者可见。

<a id="list-all-merge-request-draft-notes"></a>

## 列出所有合并请求草稿评论

列出所有合并请求的草稿评论。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/draft_notes
```

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |

```json
[
  {
    "id": 5,
    "author_id": 23,
    "merge_request_id": 11,
    "resolve_discussion": false,
    "discussion_id": null,
    "note": "Example title",
    "commit_id": null,
    "line_code": null,
    "position": {
      "base_sha": null,
      "start_sha": null,
      "head_sha": null,
      "old_path": null,
      "new_path": null,
      "position_type": "text",
      "old_line": null,
      "new_line": null,
      "line_range": null
    }
  }
]
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes"
```

<a id="retrieve-a-draft-note"></a>

## 获取单个草稿评论

获取合并请求的单个草稿评论。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id
```

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `draft_note_id`     | 整数           | 是      | 草稿评论的 ID |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |

```json
[
  {
    "id": 5,
    "author_id": 23,
    "merge_request_id": 11,
    "resolve_discussion": false,
    "discussion_id": null,
    "note": "Example title",
    "commit_id": null,
    "line_code": null,
    "position": {
      "base_sha": null,
      "start_sha": null,
      "head_sha": null,
      "old_path": null,
      "new_path": null,
      "position_type": "text",
      "old_line": null,
      "new_line": null,
      "line_range": null
    }
  }
]
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5"
```

<a id="create-a-draft-note"></a>

## 创建草稿评论

为合并请求创建草稿评论。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/draft_notes
```

| 属性                         | 类型              | 是否必需    | 描述           |
| ----------------------------| ----------------- | ----------- | --------------------- |
| `id`                        | 整数或字符串 | 是         | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid`         | 整数           | 是         | 项目合并请求的 IID |
| `note`                      | 字符串            | 是         | 评论的内容 |
| `commit_id`                 | 字符串            | 否          | 要与此草稿评论关联的提交的 SHA |
| `in_reply_to_discussion_id` | 字符串            | 否          | 此草稿评论回复的讨论的 ID |
| `resolve_discussion`        | 布尔值           | 否          | 关联的讨论应被解决 |
| `position`                  | 哈希              | 否          | 创建差异评论时的位置。如果省略，则创建常规讨论评论 |
| `position[base_sha]`        | 字符串            | 是（如果提供了 `position`） | 源分支中的基础提交 SHA |
| `position[head_sha]`        | 字符串            | 是（如果提供了 `position`） | 此合并请求 HEAD 的 SHA |
| `position[start_sha]`       | 字符串            | 是（如果提供了 `position`） | 目标分支中提交的 SHA |
| `position[new_path]`        | 字符串            | 是（如果位置类型为 `text`） | 变更后的文件路径 |
| `position[old_path]`        | 字符串            | 是（如果位置类型为 `text`） | 变更前的文件路径 |
| `position[position_type]`   | 字符串            | 是（如果提供了 `position`） | 位置引用的类型。允许值：`text`、`image` 或 `file`。`file` 在极狐GitLab 16.4 中引入 |
| `position[new_line]`        | 整数           | 否          | 对于 `text` 差异评论，变更后的行号 |
| `position[old_line]`        | 整数           | 否          | 对于 `text` 差异评论，变更前的行号 |
| `position[line_range]`      | 哈希              | 否          | 多行差异评论的行范围 |
| `position[width]`           | 整数           | 否          | 对于 `image` 差异评论，图片宽度 |
| `position[height]`          | 整数           | 否          | 对于 `image` 差异评论，图片高度 |
| `position[x]`               | 浮点数             | 否          | 对于 `image` 差异评论，X 坐标 |
| `position[y]`               | 浮点数             | 否          | 对于 `image` 差异评论，Y 坐标 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes?note=note"
```

<a id="update-a-draft-note"></a>

## 更新草稿评论

更新合并请求的草稿评论。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id
```

| 属性                       | 类型              | 是否必需 | 描述 |
| ------------------------- | ----------------- | -------- | ----------- |
| `id`                      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `draft_note_id`           | 整数           | 是      | 草稿评论的 ID |
| `merge_request_iid`       | 整数           | 是      | 项目合并请求的 IID |
| `note`                    | 字符串            | 否       | 评论的内容 |
| `position`                | 哈希              | 否       | 创建差异评论时的位置 |
| `position[base_sha]`      | 字符串            | 是（如果提供了 `position`） | 源分支中的基础提交 SHA |
| `position[head_sha]`      | 字符串            | 是（如果提供了 `position`） | 此合并请求 HEAD 的 SHA |
| `position[start_sha]`     | 字符串            | 是（如果提供了 `position`） | 目标分支中提交的 SHA |
| `position[new_path]`      | 字符串            | 是（如果位置类型为 `text`） | 变更后的文件路径 |
| `position[old_path]`      | 字符串            | 是（如果位置类型为 `text`） | 变更前的文件路径 |
| `position[position_type]` | 字符串            | 是（如果提供了 `position`） | 位置引用的类型。允许值：`text`、`image` 或 `file`。`file` 在极狐GitLab 16.4 中引入 |
| `position[new_line]`      | 整数           | 否       | 对于 `text` 差异评论，变更后的行号 |
| `position[old_line]`      | 整数           | 否       | 对于 `text` 差异评论，变更前的行号 |
| `position[line_range]`    | 哈希              | 否       | 多行差异评论的行范围 |
| `position[width]`         | 整数           | 否       | 对于 `image` 差异评论，图片宽度 |
| `position[height]`        | 整数           | 否       | 对于 `image` 差异评论，图片高度 |
| `position[x]`             | 浮点数             | 否       | 对于 `image` 差异评论，X 坐标 |
| `position[y]`             | 浮点数             | 否       | 对于 `image` 差异评论，Y 坐标 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5"
```

<a id="delete-a-draft-note"></a>

## 删除草稿评论

删除合并请求的草稿评论。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id
```

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `draft_note_id`     | 整数           | 是      | 草稿评论的 ID |
| `id`                | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5"
```

<a id="publish-a-draft-note"></a>

## 发布草稿评论

发布合并请求的草稿评论。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id/publish
```

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `draft_note_id`     | 整数           | 是      | 草稿评论的 ID |
| `id`                | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5/publish"
```

<a id="publish-all-pending-draft-notes"></a>

## 发布所有待处理的草稿评论

发布属于当前用户的合并请求中所有待处理的草稿评论。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/draft_notes/bulk_publish
```

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | 整数           | 是      | 项目合并请求的 IID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/bulk_publish"
```