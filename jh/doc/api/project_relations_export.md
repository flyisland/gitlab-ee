---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目关系导出 API
description: "使用 REST API 导出项目关系。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

此 API 在通过[直接迁移进行群组迁移](../user/group/import/_index.md)时由目标实例使用，用于迁移项目结构。通常你无需自己使用此 API。

在此上下文中，{{< glossary-tooltip text="relation" >}}是指可导出的项目，例如合并请求。导出时，该关系包含与该关系相关的任何项目，例如标签。

如果要使用此 API，你的极狐GitLab 实例必须满足某些[先决条件](../user/group/import/direct_transfer_migrations.md#prerequisites)。

> [!note]
> 此 API 不能与用于基于文件迁移的[群组导入和导出 API](group_import_export.md)一起使用。

<a id="schedule-a-new-export-for-a-project"></a>

## 为项目安排新的导出

为指定项目安排关系导出。

```plaintext
POST /projects/:id/export_relations
```

| 属性 | 类型 | 是否必填 | 描述 |
|-----------|-------------------|----------|----------------------------------------------------|
| `id` | 整数或字符串 | 是 | 项目的 ID。 |
| `batched` | 布尔值 | 否 | 是否分批导出。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/export_relations"
```

```json
{
  "message": "202 已接受"
}
```

<a id="retrieve-the-status-of-an-export"></a>

## 检索导出状态

检索关系导出的状态。

```plaintext
GET /projects/:id/export_relations/status
```

| 属性 | 类型 | 是否必填 | 描述 |
|------------|-------------------|----------|----------------------------------------------------|
| `id` | 整数或字符串 | 是 | 项目的 ID。 |
| `relation` | 字符串 | 否 | 要查看的项目顶级关系的名称。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/export_relations/status"
```

状态可以是以下之一：

- `0`：`已开始`
- `1`：`已完成`
- `-1`：`失败`

```json
[
  {
    "relation": "project_badges",
    "status": 1,
    "error": null,
    "updated_at": "2021-05-04T11:25:20.423Z",
    "batched": true,
    "batches_count": 1,
    "batches": [
      {
        "status": 1,
        "batch_number": 1,
        "objects_count": 1,
        "error": null,
        "updated_at": "2021-05-04T11:25:20.423Z"
      }
    ]
  },
  {
    "relation": "boards",
    "status": 1,
    "error": null,
    "updated_at": "2021-05-04T11:25:20.085Z",
    "batched": false,
    "batches_count": 0
  }
]
```

<a id="download-an-export"></a>

## 下载导出

下载已完成的关系导出。

```plaintext
GET /projects/:id/export_relations/download
```

| 属性 | 类型 | 是否必填 | 描述 |
|----------------|-------------------|----------|-------------|
| `id` | 整数或字符串 | 是 | 项目的 ID。 |
| `relation` | 字符串 | 是 | 要下载的项目顶级关系的名称。 |
| `batched` | 布尔值 | 否 | 导出是否分批。 |
| `batch_number` | 整数 | 否 | 要下载的导出批次号。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --remote-header-name \
  --remote-name \
  --url "https://gitlab.example.com/api/v4/projects/1/export_relations/download?relation=labels"
```

```shell
ls labels.ndjson.gz
labels.ndjson.gz
```

<a id="related-topics"></a>

## 相关主题

- [群组关系导出 API](group_relations_export.md)