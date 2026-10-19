---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中草稿评论（未发布的评论）REST API 的文档。
title: 草稿评论 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理草稿评论。这些评论是合并请求上待发布、未发布的评论。草稿评论可以发起一个讨论，也可以作为回复继续已有讨论。

发布之前，草稿评论仅对作者可见。

<a id="list-all-merge-request-draft-notes"></a>

## 列出所有合并请求草稿评论

列出所有合并请求草稿评论。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/draft_notes
```

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `merge_request_iid` | integer           | 是      | 项目合并请求的 IID |

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

## 获取草稿评论

获取某个合并请求的草稿评论。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id
```

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `draft_note_id`     | integer           | 是      | 草稿评论的 ID。 |
| `merge_request_iid` | integer           | 是      | 项目合并请求的 IID。 |

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

为某个合并请求创建草稿评论。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/draft_notes
```

| 属性                   | 类型              | 是否必需    | 描述           |
| ----------------------------| ----------------- | ----------- | --------------------- |
| `id`                        | integer or string | 是         | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid`         | integer           | 是         | 项目合并请求的 IID。 |
| `note`                      | string            | 是         | 评论的内容。 |
| `commit_id`                 | string            | 否          | 要将草稿评论关联到的提交的 SHA。 |
| `in_reply_to_discussion_id` | string            | 否          | 草稿评论所回复的讨论的 ID。 |
| `resolve_discussion`        | boolean           | 否          | 应解决关联的讨论。 |
| `position`                  | hash              | 否          | 创建差异评论时的位置。如果省略，则创建普通讨论评论。 |
| `position[base_sha]`        | string            | 是（如果提供了 `position`） | 源分支中的基础提交 SHA。 |
| `position[head_sha]`        | string            | 是（如果提供了 `position`） | 引用此合并请求 HEAD 的 SHA。 |
| `position[start_sha]`       | string            | 是（如果提供了 `position`） | 引用目标分支中提交的 SHA。 |
| `position[new_path]`        | string            | 是（如果位置类型为 `text`） | 变更后的文件路径。 |
| `position[old_path]`        | string            | 是（如果位置类型为 `text`） | 变更前的文件路径。 |
| `position[position_type]`   | string            | 是（如果提供了 `position`） | 位置引用的类型。允许的值：`text`、`image` 或 `file`。 |
| `position[new_line]`        | integer           | 否          | 对于 `text` 差异评论，变更后的行号。 |
| `position[old_line]`        | integer           | 否          | 对于 `text` 差异评论，变更前的行号。 |
| `position[line_range]`      | hash              | 否          | 多行差异评论的行范围。 |
| `position[width]`           | integer           | 否          | 对于 `image` 差异评论，图像的宽度。 |
| `position[height]`          | integer           | 否          | 对于 `image` 差异评论，图像的高度。 |
| `position[x]`               | float             | 否          | 对于 `image` 差异评论，X 坐标。 |
| `position[y]`               | float             | 否          | 对于 `image` 差异评论，Y 坐标。 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes?note=note"
```

<a id="update-a-draft-note"></a>

## 更新草稿评论

更新某个合并请求的草稿评论。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id
```

| 属性                 | 类型              | 是否必需 | 描述 |
| ------------------------- | ----------------- | -------- | ----------- |
| `id`                      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `draft_note_id`           | integer           | 是      | 草稿评论的 ID。 |
| `merge_request_iid`       | integer           | 是      | 项目合并请求的 IID。 |
| `note`                    | string            | 否       | 评论的内容。 |
| `position`                | hash              | 否       | 差异评论的新位置。如果省略，则保留现有位置。 |
| `position[base_sha]`      | string            | 是（如果提供了 `position`） | 源分支中的基础提交 SHA。 |
| `position[head_sha]`      | string            | 是（如果提供了 `position`） | 引用此合并请求 HEAD 的 SHA。 |
| `position[start_sha]`     | string            | 是（如果提供了 `position`） | 引用目标分支中提交的 SHA。 |
| `position[new_path]`      | string            | 是（如果位置类型为 `text`） | 变更后的文件路径。 |
| `position[old_path]`      | string            | 是（如果位置类型为 `text`） | 变更前的文件路径。 |
| `position[position_type]` | string            | 是（如果提供了 `position`） | 位置引用的类型。允许的值：`text`、`image` 或 `file`。 |
| `position[new_line]`      | integer           | 否       | 对于 `text` 差异评论，变更后的行号。 |
| `position[old_line]`      | integer           | 否       | 对于 `text` 差异评论，变更前的行号。 |
| `position[line_range]`    | hash              | 否       | 多行差异评论的行范围。 |
| `position[width]`         | integer           | 否       | 对于 `image` 差异评论，图像的宽度。 |
| `position[height]`        | integer           | 否       | 对于 `image` 差异评论，图像的高度。 |
| `position[x]`             | float             | 否       | 对于 `image` 差异评论，X 坐标。 |
| `position[y]`             | float             | 否       | 对于 `image` 差异评论，Y 坐标。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5"
```

<a id="delete-a-draft-note"></a>

## 删除草稿评论

删除某个合并请求的草稿评论。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id
```

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `draft_note_id`     | integer           | 是      | 草稿评论的 ID。 |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 项目合并请求的 IID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5"
```

<a id="publish-a-draft-note"></a>

## 发布草稿评论

发布某个合并请求的草稿评论。

```plaintext
PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id/publish
```

| 属性           | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `draft_note_id`     | integer           | 是      | 草稿评论的 ID。 |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 项目合并请求的 IID。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/5/publish"
```

<a id="publish-all-pending-draft-notes"></a>

## 发布所有待发布的草稿评论

发布某个合并请求中属于该用户的所有待发布草稿评论。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/draft_notes/bulk_publish
```

| 属性           | 类型              | 是否必需 | 描述 |
| ------------------- | ----------------- | -------- | ----------- |
| `id`                | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | integer           | 是      | 项目合并请求的 IID。 |
| `note`              | string            | 否       | 要添加到合并请求的摘要评论文本。 |
| `internal`          | boolean           | 否       | 如果为 `true`，则摘要评论为内部评论。 |
| `reviewer_state`    | string            | 否       | 如果已定义，则设置发布后的评审状态。不会记录正式审批。可能的值：`requested_changes`、`reviewed`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/14/merge_requests/11/draft_notes/bulk_publish"
```
