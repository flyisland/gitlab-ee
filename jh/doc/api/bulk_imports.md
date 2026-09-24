---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过直接转移 API 进行群组和项目迁移
description: "使用 REST API 启动和查看群组与项目迁移。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 通过[直接转移](../user/group/import/direct_transfer_migrations.md)来迁移群组和项目。

先决条件：

- 参见[通过直接转移迁移群组的先决条件](../user/group/import/direct_transfer_migrations.md#prerequisites)。

<a id="start-a-group-or-project-migration"></a>

## 启动群组或项目迁移

启动一个新的群组或项目迁移。要迁移项目，请指定 `entities[project_entity]`。

```plaintext
POST /bulk_imports
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------------------------------- | ------- | -------- | ----------- |
| `configuration` | Hash | 是 | 源极狐GitLab 实例配置。 |
| `configuration[url]` | String | 是 | 源极狐GitLab 实例 URL。 |
| `configuration[access_token]` | String | 是 | 源极狐GitLab 实例的访问令牌。 |
| `entities` | Array | 是 | 要导入的实体列表。 |
| `entities[source_type]` | String | 是 | 源实体类型。有效值为 `group_entity` 和 `project_entity`。 |
| `entities[source_full_path]` | String | 是 | 要导入的实体的源完整路径。例如，`gitlab-org/gitlab`。 |
| `entities[destination_slug]` | String | 是 | 实体的目标 slug。极狐GitLab 使用 slug 作为实体的 URL 路径。导入实体的名称从源实体的名称复制，而不是 slug。 |
| `entities[destination_namespace]` | String | 是 | 实体的目标群组[命名空间](../user/namespace/_index.md)的完整路径。对于 `project_entity`，此值必须是目标实例上的现有群组。对于 `group_entity`，此值可以是目标实例上的现有群组，或者为空字符串 `""` 以在目标实例上创建顶级群组（在私有化部署实例上）。不支持个人命名空间。 |
| `entities[destination_name]` | String | 否 | 已弃用：请改用 `destination_slug`。实体的目标 slug。 |
| `entities[migrate_memberships]` | Boolean | 否 | 导入用户成员资格。默认为 `true`。 |
| `entities[migrate_projects]` | Boolean | 否 | 同时导入群组的所有嵌套项目（如果 `source_type` 为 `group_entity`）。默认为 `true`。 |

```shell
curl --request POST \
  --url "https://destination-gitlab-instance.example.com/api/v4/bulk_imports" \
  --header "PRIVATE-TOKEN: <your_access_token_for_destination_gitlab_instance>" \
  --header "Content-Type: application/json" \
  --data '{
    "configuration": {
      "url": "https://source-gitlab-instance.example.com",
      "access_token": "<your_access_token_for_source_gitlab_instance>"
    },
    "entities": [
      {
        "source_full_path": "source/full/path",
        "source_type": "group_entity",
        "destination_slug": "destination_slug",
        "destination_namespace": "destination/namespace/path"
      }
    ]
  }'
```

```json
{
  "id": 1,
  "status": "created",
  "source_type": "gitlab",
  "source_url": "https://gitlab.example.com",
  "created_at": "2021-06-18T09:45:55.358Z",
  "updated_at": "2021-06-18T09:46:27.003Z",
  "has_failures": false
}
```

<a id="list-all-group-or-project-migrations"></a>

## 列出所有群组或项目迁移

列出所有群组或项目迁移。

```plaintext
GET /bulk_imports
```

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------|:--------|:---------|:-----------------------------------------------------------------------------------|
| `per_page` | integer | 否 | 每页返回的记录数。 |
| `page` | integer | 否 | 要检索的页。 |
| `sort` | string | 否 | 按创建日期以 `asc` 或 `desc` 顺序返回记录。默认为 `desc`。 |
| `status` | string | 否 | 导入状态。 |

状态可以是以下之一：

- `created`
- `started`
- `finished`
- `failed`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports?per_page=2&page=1"
```

```json
[
    {
        "id": 1,
        "status": "finished",
        "source_type": "gitlab",
        "source_url": "https://gitlab.example.com",
        "created_at": "2021-06-18T09:45:55.358Z",
        "updated_at": "2021-06-18T09:46:27.003Z",
        "has_failures": false
    },
    {
        "id": 2,
        "status": "started",
        "source_type": "gitlab",
        "source_url": "https://gitlab.example.com",
        "created_at": "2021-06-18T09:47:36.581Z",
        "updated_at": "2021-06-18T09:47:58.286Z",
        "has_failures": false
    }
]
```

<a id="list-all-group-or-project-migration-entities"></a>

## 列出所有群组或项目迁移实体

列出所有群组或项目迁移实体。

```plaintext
GET /bulk_imports/entities
```

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------|:--------|:---------|:-----------------------------------------------------------------------------------|
| `per_page` | integer | 否 | 每页返回的记录数。 |
| `page` | integer | 否 | 要检索的页。 |
| `sort` | string | 否 | 按创建日期以 `asc` 或 `desc` 顺序返回记录。默认为 `desc`。 |
| `status` | string | 否 | 导入状态。 |

状态可以是以下之一：

- `created`
- `started`
- `finished`
- `failed`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports/entities?per_page=2&page=1&status=started"
```

```json
[
    {
        "id": 1,
        "bulk_import_id": 1,
        "status": "finished",
        "entity_type": "group",
        "source_full_path": "source_group",
        "destination_full_path": "destination/full_path",
        "destination_name": "destination_slug",
        "destination_slug": "destination_slug",
        "destination_namespace": "destination_path",
        "parent_id": null,
        "namespace_id": 1,
        "project_id": null,
        "created_at": "2021-06-18T09:47:37.390Z",
        "updated_at": "2021-06-18T09:47:51.867Z",
        "failures": [],
        "migrate_projects": true,
        "migrate_memberships": true,
        "has_failures": false,
        "stats": {
            "labels": {
                "source": 10,
                "fetched": 10,
                "imported": 10
            },
            "milestones": {
                "source": 10,
                "fetched": 10,
                "imported": 10
            }
        }
    },
    {
        "id": 2,
        "bulk_import_id": 2,
        "status": "failed",
        "entity_type": "group",
        "source_full_path": "another_group",
        "destination_full_path": "destination/full_path",
        "destination_name": "destination_slug",
        "destination_slug": "another_slug",
        "destination_namespace": "another_namespace",
        "parent_id": null,
        "namespace_id": null,
        "project_id": null,
        "created_at": "2021-06-24T10:40:20.110Z",
        "updated_at": "2021-06-24T10:40:46.590Z",
        "failures": [
            {
                "relation": "group",
                "step": "extractor",
                "exception_message": "Error!",
                "exception_class": "Exception",
                "correlation_id_value": "dfcf583058ed4508e4c7c617bd7f0edd",
                "created_at": "2021-06-24T10:40:46.495Z",
                "pipeline_class": "BulkImports::Groups::Pipelines::GroupPipeline",
                "pipeline_step": "extractor"
            }
        ],
        "migrate_projects": true,
        "migrate_memberships": true,
        "has_failures": false,
        "stats": { }
    }
]
```

<a id="retrieve-a-group-or-project-migration"></a>

## 获取群组或项目迁移

获取群组或项目迁移的详细信息。

```plaintext
GET /bulk_imports/:id
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports/1"
```

```json
{
  "id": 1,
  "status": "finished",
  "source_type": "gitlab",
  "source_url": "https://gitlab.example.com",
  "created_at": "2021-06-18T09:45:55.358Z",
  "updated_at": "2021-06-18T09:46:27.003Z"
}
```

<a id="list-group-or-project-migration-entities"></a>

## 列出群组或项目迁移实体

列出特定迁移的群组或项目迁移实体。

```plaintext
GET /bulk_imports/:id/entities
```

| 属性 | 类型 | 是否必需 | 描述 |
|:-----------|:--------|:---------|:-----------------------------------------------------------------------------------|
| `per_page` | integer | 否 | 每页返回的记录数。 |
| `page` | integer | 否 | 要检索的页。 |
| `sort` | string | 否 | 按创建日期以 `asc` 或 `desc` 顺序返回记录。默认为 `desc`。 |
| `status` | string | 否 | 导入状态。 |

状态可以是以下之一：

- `created`
- `started`
- `finished`
- `failed`

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports/1/entities?per_page=2&page=1&status=finished"
```

```json
[
    {
        "id": 1,
        "bulk_import_id": 1,
        "status": "finished",
        "entity_type": "group",
        "source_full_path": "source_group",
        "destination_full_path": "destination/full_path",
        "destination_name": "destination_slug",
        "destination_slug": "destination_slug",
        "destination_namespace": "destination_path",
        "parent_id": null,
        "namespace_id": 1,
        "project_id": null,
        "created_at": "2021-06-18T09:47:37.390Z",
        "updated_at": "2021-06-18T09:47:51.867Z",
        "failures": [
            {
                "relation": "group",
                "step": "extractor",
                "exception_message": "Error!",
                "exception_class": "Exception",
                "correlation_id_value": "dfcf583058ed4508e4c7c617bd7f0edd",
                "created_at": "2021-06-24T10:40:46.495Z",
                "pipeline_class": "BulkImports::Groups::Pipelines::GroupPipeline",
                "pipeline_step": "extractor"
            }
        ],
        "migrate_projects": true,
        "migrate_memberships": true,
        "has_failures": true,
        "stats": {
            "labels": {
                "source": 10,
                "fetched": 10,
                "imported": 10
            },
            "milestones": {
                "source": 10,
                "fetched": 10,
                "imported": 10
            }
        }
    }
]
```

<a id="retrieve-a-group-or-project-migration-entity"></a>

## 获取群组或项目迁移实体

获取群组或项目迁移实体的详细信息。

```plaintext
GET /bulk_imports/:id/entities/:entity_id
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports/1/entities/2"
```

```json
{
    "id": 1,
    "bulk_import_id": 1,
    "status": "finished",
    "entity_type": "group",
    "source_full_path": "source_group",
    "destination_full_path": "destination/full_path",
    "destination_name": "destination_slug",
    "destination_slug": "destination_slug",
    "destination_namespace": "destination_path",
    "parent_id": null,
    "namespace_id": 1,
    "project_id": null,
    "created_at": "2021-06-18T09:47:37.390Z",
    "updated_at": "2021-06-18T09:47:51.867Z",
    "failures": [
        {
            "relation": "group",
            "step": "extractor",
            "exception_message": "Error!",
            "exception_class": "Exception",
            "correlation_id_value": "dfcf583058ed4508e4c7c617bd7f0edd",
            "created_at": "2021-06-24T10:40:46.495Z",
            "pipeline_class": "BulkImports::Groups::Pipelines::GroupPipeline",
            "pipeline_step": "extractor"
        }
    ],
    "migrate_projects": true,
    "migrate_memberships": true,
    "has_failures": true,
    "stats": {
        "labels": {
            "source": 10,
            "fetched": 10,
            "imported": 10
        },
        "milestones": {
            "source": 10,
            "fetched": 10,
            "imported": 10
        }
    }
}
```

<a id="list-failed-import-records-for-a-migration-entity"></a>

## 列出迁移实体的失败导入记录

{{< history >}}

- 在极狐GitLab 16.6 中引入。

{{< /history >}}

列出群组或项目迁移实体的失败导入记录。

```plaintext
GET /bulk_imports/:id/entities/:entity_id/failures
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports/1/entities/2/failures"
```

```json
{
  "relation": "issues",
  "exception_message": "Error!",
  "exception_class": "StandardError",
  "correlation_id_value": "06289e4b064329a69de7bb2d7a1b5a97",
  "source_url": "https://gitlab.example/project/full/path/-/issues/1",
  "source_title": "Issue title"
}
```

<a id="cancel-a-migration"></a>

## 取消迁移

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

取消直接转移迁移。

```plaintext
POST /bulk_imports/:id/cancel
```

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/bulk_imports/1/cancel"
```

```json
{
  "id": 1,
  "status": "canceled",
  "source_type": "gitlab",
  "created_at": "2021-06-18T09:45:55.358Z",
  "updated_at": "2021-06-18T09:46:27.003Z",
  "has_failures": false
}
```

可能的响应状态码：

| 状态 | 描述 |
|--------|---------------------------------|
| 200 | 迁移已成功取消 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 未找到迁移 |
| 503 | 服务不可用 |