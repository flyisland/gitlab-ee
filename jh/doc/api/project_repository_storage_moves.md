---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目代码仓库存储移动 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

项目代码仓库（包括 Wiki 和设计代码仓库）可以在不同存储之间移动。例如，当您[迁移到 Gitaly 集群 (Praefect)](../administration/gitaly/praefect/_index.md#migrate-to-gitaly-cluster-praefect) 时，此 API 可以为您提供帮助。

项目代码仓库存储移动在处理过程中会经历不同的状态。`state`的取值包括：

- `initial`：记录已创建，但后台作业尚未调度。
- `scheduled`：后台作业已调度。
- `started`：项目代码仓库正在复制到目标存储。
- `replicated`：项目已移动。
- `failed`：项目代码仓库复制失败，或校验和不匹配。
- `finished`：项目已移动，且源存储上的代码仓库已删除。
- `cleanup failed`：项目已移动，但无法删除源存储上的代码仓库。

为确保数据完整性，项目在移动期间会处于临时的只读状态。在此期间，如果用户尝试推送新提交，会收到 `The repository is temporarily read-only. Please try again later.` 消息。

此 API 要求您以管理员身份[进行身份验证](rest/authentication.md)。

其他代码仓库类型请参见：

- [代码片段代码仓库存储移动 API](snippet_repository_storage_moves.md)。
- [群组代码仓库存储移动 API](group_repository_storage_moves.md)。

<a id="list-all-project-repository-storage-moves"></a>

## 列出所有项目代码仓库存储移动

```plaintext
GET /project_repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 条结果，因为 API 结果已[分页](rest/_index.md#pagination)。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_repository_storage_moves"
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
    "project": {
      "id": 1,
      "description": null,
      "name": "project1",
      "name_with_namespace": "John Doe2 / project1",
      "path": "project1",
      "path_with_namespace": "namespace1/project1",
      "created_at": "2020-05-07T04:27:17.016Z"
    }
  }
]
```

<a id="list-all-repository-storage-moves-for-a-project"></a>

## 列出某个项目的所有代码仓库存储移动

```plaintext
GET /projects/:project_id/repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 条结果，因为 API 结果已[分页](rest/_index.md#pagination)。

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `project_id` | integer | 是 | 项目的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository_storage_moves"
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
    "project": {
      "id": 1,
      "description": null,
      "name": "project1",
      "name_with_namespace": "John Doe2 / project1",
      "path": "project1",
      "path_with_namespace": "namespace1/project1",
      "created_at": "2020-05-07T04:27:17.016Z"
    }
  }
]
```

<a id="retrieve-a-project-repository-storage-move"></a>

## 检索某个项目代码仓库存储移动

```plaintext
GET /project_repository_storage_moves/:repository_storage_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `repository_storage_id` | integer | 是 | 项目代码仓库存储移动的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_repository_storage_moves/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "project": {
    "id": 1,
    "description": null,
    "name": "project1",
    "name_with_namespace": "John Doe2 / project1",
    "path": "project1",
    "path_with_namespace": "namespace1/project1",
    "created_at": "2020-05-07T04:27:17.016Z"
  }
}
```

<a id="retrieve-a-repository-storage-move-for-a-project"></a>

## 检索某个项目的代码仓库存储移动

```plaintext
GET /projects/:project_id/repository_storage_moves/:repository_storage_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `project_id` | integer | 是 | 项目的 ID |
| `repository_storage_id` | integer | 是 | 项目代码仓库存储移动的 ID |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository_storage_moves/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "project": {
    "id": 1,
    "description": null,
    "name": "project1",
    "name_with_namespace": "John Doe2 / project1",
    "path": "project1",
    "path_with_namespace": "namespace1/project1",
    "created_at": "2020-05-07T04:27:17.016Z"
  }
}
```

<a id="create-a-repository-storage-move-for-a-project"></a>

## 为某个项目创建代码仓库存储移动

```plaintext
POST /projects/:project_id/repository_storage_moves
```

参数：

| 属性 | 类型 | 是否必需 | 描述                                                                                                                                                                                                        |
| --------- | ---- | -------- |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `project_id` | integer | 是 | 项目的 ID                                                                                                                                                                                                  |
| `destination_storage_name` | string | 否 | 目标存储分片的名称。如果未提供，将[根据存储权重自动选择存储](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"destination_storage_name":"storage2"}' \
  --url "https://gitlab.example.com/api/v4/projects/1/repository_storage_moves"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "project": {
    "id": 1,
    "description": null,
    "name": "project1",
    "name_with_namespace": "John Doe2 / project1",
    "path": "project1",
    "path_with_namespace": "namespace1/project1",
    "created_at": "2020-05-07T04:27:17.016Z"
  }
}
```

<a id="create-repository-storage-moves-for-all-projects-on-a-storage-shard"></a>

## 为某个存储分片上的所有项目创建代码仓库存储移动

为源存储分片上存储的每个项目代码仓库创建代码仓库存储移动。此端点会一次性迁移所有项目。

```plaintext
POST /project_repository_storage_moves
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `source_storage_name` | string | 是 | 源存储分片的名称。 |
| `destination_storage_name` | string | 否 | 目标存储分片的名称。如果未提供，将[根据存储权重自动选择存储](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"source_storage_name":"default"}' \
  --url "https://gitlab.example.com/api/v4/project_repository_storage_moves"
```

示例响应：

```json
{
  "message": "202 Accepted"
}
```
