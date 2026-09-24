---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for merge request context commits in GitLab.
title: 合并请求上下文提交 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果您的合并请求基于前一个合并请求，您可能需要[包含先前合并的提交以提供上下文](../user/project/merge_requests/commits.md#show-commits-from-previous-merge-requests)到您的合并请求中。使用此 API 向合并请求添加提交以提供更多上下文。

<a id="list-context-commits-for-a-merge-request"></a>

## 列出合并请求的上下文提交

列出单个合并请求的上下文提交。

```plaintext
GET /projects/:id/merge_requests/:merge_request_iid/context_commits
```

参数：

| 属性                | 类型   | 是否必需 | 描述 |
|---------------------|--------|----------|------|
| `id`                | 整数   | 是       | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数   | 是       | 合并请求的内部 ID。 |

```json
[
    {
        "id": "4a24d82dbca5c11c61556f3b35ca472b7463187e",
        "short_id": "4a24d82d",
        "created_at": "2017-04-11T10:08:59.000Z",
        "parent_ids": null,
        "title": "Update README.md to include `Usage in testing and development`",
        "message": "Update README.md to include `Usage in testing and development`",
        "author_name": "Example \"Sample\" User",
        "author_email": "user@example.com",
        "authored_date": "2017-04-11T10:08:59.000Z",
        "committer_name": "Example \"Sample\" User",
        "committer_email": "user@example.com",
        "committed_date": "2017-04-11T10:08:59.000Z"
    }
]
```

<a id="create-context-commits-for-a-merge-request"></a>

## 为合并请求创建上下文提交

为单个合并请求创建上下文提交。

```plaintext
POST /projects/:id/merge_requests/:merge_request_iid/context_commits
```

参数：

| 属性                | 类型       | 是否必需 | 描述 |
|---------------------|------------|----------|------|
| `id`                | 整数       | 是       | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数       | 是       | 合并请求的内部 ID。 |
| `commits`           | 字符串数组 | 是       | 上下文提交的 SHA 值。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --header 'Content-Type: application/json' \
  --data '{"commits": ["51856a574ac3302a95f82483d6c7396b1e0783cb"]}' \
  --url "https://gitlab.example.com/api/v4/projects/15/merge_requests/12/context_commits"
```

示例响应：

```json
[
    {
        "id": "51856a574ac3302a95f82483d6c7396b1e0783cb",
        "short_id": "51856a57",
        "created_at": "2014-02-27T10:05:10.000+02:00",
        "parent_ids": [
            "57a82e2180507c9e12880c0747f0ea65ad489515"
        ],
        "title": "Commit title",
        "message": "Commit message",
        "author_name": "Example User",
        "author_email": "user@example.com",
        "authored_date": "2014-02-27T10:05:10.000+02:00",
        "committer_name": "Example User",
        "committer_email": "user@example.com",
        "committed_date": "2014-02-27T10:05:10.000+02:00",
        "trailers": {},
        "web_url": "https://gitlab.example.com/project/path/-/commit/b782f6c553653ab4e16469ff34bf3a81638ac304"
    }
]
```

<a id="delete-context-commits-from-a-merge-request"></a>

## 从合并请求中删除上下文提交

从单个合并请求中删除上下文提交。

```plaintext
DELETE /projects/:id/merge_requests/:merge_request_iid/context_commits
```

参数：

| 属性                | 类型       | 是否必需 | 描述 |
|---------------------|------------|----------|------|
| `commits`           | 字符串数组 | 是       | 上下文提交的 SHA 值。 |
| `id`                | 整数       | 是       | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `merge_request_iid` | 整数       | 是       | 合并请求的内部 ID。 |

