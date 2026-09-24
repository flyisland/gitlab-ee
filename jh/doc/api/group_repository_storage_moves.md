---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for moving the storage for repositories in a GitLab group.
title: 群组仓库存储迁移 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理[群组仓库存储迁移](../administration/operations/moving_repositories.md)。例如，此 API 可帮助你[迁移至 Gitaly 集群（Praefect）](../administration/gitaly/praefect/_index.md#migrate-to-gitaly-cluster-praefect)或迁移[群组 Wiki](../user/project/wiki/group.md)。此 API 不管理群组内的项目仓库。要安排项目迁移，请使用[项目仓库存储迁移 API](project_repository_storage_moves.md)。

在极狐GitLab 处理群组仓库存储迁移时，会经历不同的状态。`state` 的值包括：

- `initial`：记录已创建，但后台作业尚未安排。
- `scheduled`：后台作业已安排。
- `started`：正在将群组仓库复制到目标存储。
- `replicated`：群组已移动。
- `failed`：群组仓库复制失败，或校验和不匹配。
- `finished`：群组已移动，源存储上的仓库已删除。
- `cleanup failed`：群组已移动，但无法删除源存储上的仓库。

为确保数据完整性，极狐GitLab 在迁移期间会将群组置于临时只读状态。在此期间，如果用户尝试推送新提交，他们会收到以下消息：

```plaintext
仓库暂时为只读。请稍后重试。
```

此 API 要求你以[管理员身份进行身份验证](rest/authentication.md)。

也可使用 API 移动其他类型的仓库：

- [项目仓库存储迁移 API](project_repository_storage_moves.md)
- [代码片段仓库存储迁移 API](snippet_repository_storage_moves.md)

<a id="list-all-group-repository-storage-moves"></a>

## 列出所有群组仓库存储迁移

列出实例的所有群组仓库存储迁移。

```plaintext
GET /group_repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果是[分页的](rest/_index.md#pagination)。

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/group_repository_storage_moves"
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
    "group": {
      "id": 283,
      "web_url": "https://gitlab.example.com/groups/testgroup",
      "name": "testgroup"
    }
  }
]
```

<a id="list-all-repository-storage-moves-for-a-group"></a>

## 列出指定群组的所有仓库存储迁移

列出指定群组的所有仓库存储迁移。

```plaintext
GET /groups/:group_id/repository_storage_moves
```

默认情况下，`GET` 请求每次返回 20 个结果，因为 API 结果是[分页的](rest/_index.md#pagination)。

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `group_id` | integer | 是 | 群组的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/repository_storage_moves"
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
    "group": {
      "id": 283,
      "web_url": "https://gitlab.example.com/groups/testgroup",
      "name": "testgroup"
    }
  }
]
```

<a id="retrieve-a-group-repository-storage-move"></a>

## 获取群组仓库存储迁移

获取指定的群组仓库存储迁移。

```plaintext
GET /group_repository_storage_moves/:repository_storage_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `repository_storage_id` | integer | 是 | 群组仓库存储迁移的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/group_repository_storage_moves/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "group": {
    "id": 283,
    "web_url": "https://gitlab.example.com/groups/testgroup",
    "name": "testgroup"
  }
}
```

<a id="retrieve-a-repository-storage-move-for-a-group"></a>

## 获取群组特定的仓库存储迁移

获取指定群组的仓库存储迁移。

```plaintext
GET /groups/:group_id/repository_storage_moves/:repository_storage_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `group_id` | integer | 是 | 群组的 ID。 |
| `repository_storage_id` | integer | 是 | 群组仓库存储迁移的 ID。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/repository_storage_moves/1"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "group": {
    "id": 283,
    "web_url": "https://gitlab.example.com/groups/testgroup",
    "name": "testgroup"
  }
}
```

<a id="create-a-group-repository-storage-move"></a>

## 创建群组仓库存储迁移

为指定群组创建一个群组仓库存储迁移。此端点：

- 仅移动群组 Wiki 仓库。
- 不移动群组内项目的仓库。要安排项目迁移，请使用[项目仓库存储迁移 API](project_repository_storage_moves.md)。

```plaintext
POST /groups/:group_id/repository_storage_moves
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `group_id` | integer | 是 | 群组的 ID。 |
| `destination_storage_name` | string | 否 | 目标存储分片的名称。如果未提供，则根据[存储权重](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)选择存储。 |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"destination_storage_name":"storage2"}' \
     --url "https://gitlab.example.com/api/v4/groups/1/repository_storage_moves"
```

示例响应：

```json
{
  "id": 1,
  "created_at": "2020-05-07T04:27:17.234Z",
  "state": "scheduled",
  "source_storage_name": "default",
  "destination_storage_name": "storage2",
  "group": {
    "id": 283,
    "web_url": "https://gitlab.example.com/groups/testgroup",
    "name": "testgroup"
  }
}
```

<a id="create-group-repository-storage-moves-for-a-storage-shard"></a>

## 为存储分片创建群组仓库存储迁移

为指定存储分片上的所有群组创建仓库存储迁移。

```plaintext
POST /group_repository_storage_moves
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `source_storage_name` | string | 是 | 源存储分片的名称。 |
| `destination_storage_name` | string | 否 | 目标存储分片的名称。如果未提供，则根据[存储权重](../administration/repository_storage_paths.md#configure-where-new-repositories-are-stored)选择存储。 |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"source_storage_name":"default"}' \
     --url "https://gitlab.example.com/api/v4/group_repository_storage_moves"
```

示例响应：

```json
{
  "message": "202 Accepted"
}
```

<a id="related-topics"></a>

## 相关主题

- [极狐GitLab 管理的仓库迁移](../administration/operations/moving_repositories.md)