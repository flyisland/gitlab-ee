---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目仓库存储迁移 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

包括 Wiki 和设计仓库在内的项目仓库可以在存储节点之间迁移。例如，在[迁移到 Gitaly 集群（Praefect）](../administration/gitaly/praefect/_index.md#migrate-to-gitaly-cluster-praefect)时，此 API 可以为你提供帮助。

随着项目仓库存储迁移的处理，它们会经历不同的状态。`state` 的值为：

- `initial`：记录已创建但后台作业尚未调度。
- `scheduled`：后台作业已调度。
- `started`：项目仓库正在复制到目标存储。
- `replicated`：项目已迁移。
- `failed`：项目仓库复制失败或校验和不匹配。
- `finished`：项目已迁移且源存储上的仓库已被删除。
- `cleanup failed`：项目已迁移但源存储上的仓库无法删除。

为确保数据完整性，在迁移期间，项目会被置于临时只读状态。在此期间，如果用户尝试推送新的提交，会收到 `The repository is temporarily read-only. Please try again later.` 消息。

此 API 要求你以管理员身份[进行身份认证](https://gitlab.cn/docs/api/rest/authentication.md)。

关于其他仓库类型，请参见：

- [代码片段仓库存储迁移 API](snippet_repository_storage_moves.md)。
- [群组仓库存储迁移 API](group_repository_storage_moves.md)。

<a id="list-all-project-repository-storage-moves"></a>

## 列出所有项目仓库存储迁移

```plaintext
GET /project_repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果是[分页](https://gitlab.cn/docs/api/rest/_index.md#pagination)的。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_repository_storage_moves"
```

响应示例：

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

## 列出项目的所有仓库存储迁移

```plaintext
GET /projects/:project_id/repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果是[分页](https://gitlab.cn/docs/api/rest/_index.md#pagination)的。

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `project_id` | integer | yes | 项目的 ID |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository_storage_moves"
```

响应示例：

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

## 检索项目仓库存储迁移

```plaintext
GET /project_repository_storage_moves/:repository_storage_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `repository_storage_id` | integer | yes | 项目仓库存储迁移的 ID |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_repository_storage_moves/1"
```

响应示例：

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

## 检索项目的仓库存储迁移

```plaintext
GET /projects/:project_id/repository_storage_moves/:repository_storage_id
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `project_id` | integer | yes | 项目的 ID |
| `repository_storage_id` | integer | yes | 项目仓库存储迁移的 ID |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/repository_storage_moves/1"
```

响应示例：

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

## 为项目创建仓库存储迁移

```plaintext
POST /projects/:project_id/repository_storage_moves
```

参数：

| 属性 | 类型 | 是否必需 | 描述                                                                                                                                                                                                        |
| --------- | ---- | -------- |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `project_id` | integer | yes | 项目的 ID                                                                                                                                                                                                  |
| `destination_storage_name` | string | no | 目标存储分片的名称。如果未提供，将[根据存储权重自动选择存储](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored) |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"destination_storage_name":"storage2"}' \
  --url "https://gitlab.example.com/api/v4/projects/1/repository_storage_moves"
```

响应示例：

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

## 为存储分片上的所有项目创建仓库存储迁移

为源存储分片上存储的每个项目仓库创建仓库存储迁移。此端点会一次性迁移所有项目。

```plaintext
POST /project_repository_storage_moves
```

参数：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `source_storage_name` | string | yes | 源存储分片的名称。 |
| `destination_storage_name` | string | no | 目标存储分片的名称。如果未提供，将[根据存储权重自动选择存储](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)。 |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"source_storage_name":"default"}' \
  --url "https://gitlab.example.com/api/v4/project_repository_storage_moves"
```

响应示例：

```json
{
  "message": "202 Accepted"
}
```

## 相关主题

- [移动由极狐GitLab 管理的仓库](https://gitlab.cn/docs/administration/operations/moving_repositories.md)