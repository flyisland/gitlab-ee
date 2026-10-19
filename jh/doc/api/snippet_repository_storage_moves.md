---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码片段仓库存储迁移 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 来管理[代码片段仓库存储迁移](../administration/operations/moving_repositories.md)。例如，此 API 可以帮助您[迁移到 Gitaly Cluster (Praefect)](../administration/gitaly/praefect/_index.md#migrate-to-gitaly-cluster-praefect)。

当代码片段仓库存储迁移被处理时，它们会经历不同的状态。`state` 的值有：

- `initial`：记录已创建但后台作业尚未调度。
- `scheduled`：后台作业已调度。
- `started`：代码片段仓库正在被复制到目标存储。
- `replicated`：代码片段已移动。
- `failed`：代码片段仓库复制失败或校验和不匹配。
- `finished`：代码片段已移动且源存储上的仓库已被删除。
- `cleanup failed`：代码片段已移动但源存储上的仓库无法删除。

为确保数据完整性，在移动期间，代码片段会被置于临时只读状态。在此期间，如果用户尝试推送新提交，他们会收到 `仓库暂时只读，请稍后重试。` 消息。

此 API 要求您以管理员身份[进行身份验证](rest/authentication.md)。

对于其他仓库类型，请参见：

- [项目仓库存储迁移 API](project_repository_storage_moves.md)
- [群组仓库存储迁移 API](group_repository_storage_moves.md)

<a id="list-all-snippet-repository-storage-moves"></a>

## 列出所有代码片段仓库存储迁移

列出所有代码片段仓库存储迁移。

```plaintext
GET /snippet_repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 条结果，因为 API 结果是[分页](rest/_index.md#pagination)的。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippet_repository_storage_moves"
```

示例响应：

```json
[
  {
    "id": 1,
    "created_at": "2020-05-07T04:27:17.234Z",
    "state": "scheduled",
    "source_storage_name": "default",
    "destination_storage_name": "storage2",
    "snippet": {
      "id": 65,
      "title": "Test Snippet",
      "description": null,
      "visibility": "internal",
      "updated_at": "2020-12-01T11:15:50.385Z",
      "created_at": "2020-12-01T11:15:50.385Z",
      "project_id": null,
      "web_url": "https://gitlab.example.com/-/snippets/65",
      "raw_url": "https://gitlab.example.com/-/snippets/65/raw",
      "ssh_url_to_repo": "ssh://user@gitlab.example.com/snippets/65.git",
      "http_url_to_repo": "https://gitlab.example.com/snippets/65.git"
    }
  }
]
```

<a id="list-all-repository-storage-moves-for-a-snippet"></a>

## 列出某个代码片段的所有仓库存储迁移

列出指定代码片段的所有仓库存储迁移。

```plaintext
GET /snippets/:snippet_id/repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 条结果，因为 API 结果是[分页](rest/_index.md#pagination)的。

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/repository_storage_moves"
```

示例响应：

```json
[
  {
    "id": 1,
    "created_at": "2020-05-07T04:27:17.234Z",
    "state": "scheduled",
    "source_storage_name": "default",
    "destination_storage_name": "storage2",
    "snippet": {
      "id": 65,
      "title": "Test Snippet",
      "description": null,
      "visibility": "internal",
      "updated_at": "2020-12-01T11:15:50.385Z",
      "created_at": "2020-12-01T11:15:50.385Z",
      "project_id": null,
      "web_url": "https://gitlab.example.com/-/snippets/65",
      "raw_url": "https://gitlab.example.com/-/snippets/65/raw",
      "ssh_url_to_repo": "ssh://user@gitlab.example.com/snippets/65.git",
      "http_url_to_repo": "https://gitlab.example.com/snippets/65.git"
    }
  }
]
```

<a id="retrieve-a-snippet-repository-storage-move"></a>

## 获取某个代码片段仓库存储迁移

获取指定的代码片段仓库存储迁移。

```plaintext
GET /snippet_repository_storage_moves/:repository_storage_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `repository_storage_id` | 整数 | 是 | 代码片段仓库存储迁移的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippet_repository_storage_moves/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "snippet": {
    "id": 65,
    "title": "Test Snippet",
    "description": null,
    "visibility": "internal",
    "updated_at": "2020-12-01T11:15:50.385Z",
    "created_at": "2020-12-01T11:15:50.385Z",
    "project_id": null,
    "web_url": "https://gitlab.example.com/-/snippets/65",
    "raw_url": "https://gitlab.example.com/-/snippets/65/raw",
    "ssh_url_to_repo": "ssh://user@gitlab.example.com/snippets/65.git",
    "http_url_to_repo": "https://gitlab.example.com/snippets/65.git"
  }
}
```

<a id="retrieve-a-repository-storage-move-for-a-snippet"></a>

## 获取某个代码片段的仓库存储迁移

获取指定代码片段的仓库存储迁移。

```plaintext
GET /snippets/:snippet_id/repository_storage_moves/:repository_storage_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |
| `repository_storage_id` | 整数 | 是 | 代码片段仓库存储迁移的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/snippets/1/repository_storage_moves/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "snippet": {
    "id": 65,
    "title": "Test Snippet",
    "description": null,
    "visibility": "internal",
    "updated_at": "2020-12-01T11:15:50.385Z",
    "created_at": "2020-12-01T11:15:50.385Z",
    "project_id": null,
    "web_url": "https://gitlab.example.com/-/snippets/65",
    "raw_url": "https://gitlab.example.com/-/snippets/65/raw",
    "ssh_url_to_repo": "ssh://user@gitlab.example.com/snippets/65.git",
    "http_url_to_repo": "https://gitlab.example.com/snippets/65.git"
  }
}
```

<a id="schedule-a-repository-storage-move-for-a-snippet"></a>

## 为某个代码片段调度仓库存储迁移

为指定的代码片段调度仓库存储迁移。

```plaintext
POST /snippets/:snippet_id/repository_storage_moves
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `snippet_id` | 整数 | 是 | 代码片段的 ID。 |
| `destination_storage_name` | 字符串 | 否 | 目标存储分片的名称。如果未提供，则[根据存储权重自动选择](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)存储。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"destination_storage_name":"storage2"}' \
  --url "https://gitlab.example.com/api/v4/snippets/1/repository_storage_moves"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "snippet": {
    "id": 65,
    "title": "Test Snippet",
    "description": null,
    "visibility": "internal",
    "updated_at": "2020-12-01T11:15:50.385Z",
    "created_at": "2020-12-01T11:15:50.385Z",
    "project_id": null,
    "web_url": "https://gitlab.example.com/-/snippets/65",
    "raw_url": "https://gitlab.example.com/-/snippets/65/raw",
    "ssh_url_to_repo": "ssh://user@gitlab.example.com/snippets/65.git",
    "http_url_to_repo": "https://gitlab.example.com/snippets/65.git"
  }
}
```

<a id="schedule-repository-storage-moves-for-all-snippets-on-a-storage-shard"></a>

## 为某个存储分片上的所有代码片段调度仓库存储迁移

为源存储分片上存储的每个代码片段仓库调度仓库存储迁移。此端点一次性迁移所有代码片段。

```plaintext
POST /snippet_repository_storage_moves
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `source_storage_name` | 字符串 | 是 | 源存储分片的名称。 |
| `destination_storage_name` | 字符串 | 否 | 目标存储分片的名称。如果未提供，则[根据存储权重自动选择](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)存储。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"source_storage_name":"default"}' \
  --url "https://gitlab.example.com/api/v4/snippet_repository_storage_moves"
```

示例响应：

```json
{
  "message": "202 Accepted"
}
```