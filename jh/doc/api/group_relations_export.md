---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组关系导出 API
description: "使用 REST API 导出群组关系。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

此 API 由目标实例在[通过直接迁移进行群组迁移](../user/group/import/_index.md)期间使用，以迁移群组结构。你通常无需自行使用此 API。

在此上下文中，{{< glossary-tooltip text="关系" >}} 指可导出的项目，例如史诗。导出时，关系包括与该关系相关的任何项目，例如标签。

如果你想使用此 API，你的极狐GitLab 实例必须满足特定的[前提条件](../user/group/import/direct_transfer_migrations.md#prerequisites)。

<a id="schedule-a-new-export-for-a-group"></a>

## 为群组安排新的导出

为指定群组安排关系导出。

```plaintext
POST /groups/:id/export_relations
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|------------ |
| `id`      | 整数或字符串 | 是      | 群组的 ID。 |
| `batched` | 布尔值           | 否       | 是否分批导出。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/export_relations"
```

```json
{
  "message": "202 Accepted"
}
```

<a id="retrieve-the-status-of-an-export"></a>

## 查看导出状态

查看关系导出的状态。

```plaintext
GET /groups/:id/export_relations/status
```

| 属性  | 类型              | 是否必需 | 描述 |
|------------|-------------------|----------|------------ |
| `id`       | 整数或字符串 | 是      | 群组的 ID。 |
| `relation` | 字符串            | 否       | 要查看的群组顶级关系的名称。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/export_relations/status"
```

状态可以是以下之一：

- `0`：`started`
- `1`：`finished`
- `-1`：`failed`

```json
[
  {
    "relation": "badges",
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

## 下载导出文件

下载已完成的关系导出文件。

```plaintext
GET /groups/:id/export_relations/download
```

| 属性      | 类型              | 是否必需 | 描述 |
|----------------|-------------------|----------|------------ |
| `id`           | 整数或字符串 | 是      | 群组的 ID。 |
| `relation`     | 字符串            | 是      | 要下载的群组顶级关系的名称。 |
| `batched`      | 布尔值           | 否       | 导出是否为分批进行。 |
| `batch_number` | 整数           | 否       | 要下载的导出批次编号。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --remote-header-name \
  --remote-name "https://gitlab.example.com/api/v4/groups/1/export_relations/download?relation=labels"
```

```shell
ls labels.ndjson.gz
labels.ndjson.gz
```