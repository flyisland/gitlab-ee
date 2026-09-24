---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 搜索管理员 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.1 中引入

{{< /history >}}

使用此 API 检索有关[高级搜索迁移](../integration/advanced_search/elasticsearch.md#advanced-search-migrations)的信息。

前提条件：

- 您必须是管理员。

<a id="list-all-advanced-search-migrations"></a>

## 列出所有高级搜索迁移

列出极狐GitLab 实例的所有高级搜索迁移。

```plaintext
获取 /admin/search/migrations
```

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/admin/search/migrations"
```

示例响应：

```json
[
  {
    "version": 20230427555555,
    "name": "BackfillHiddenOnMergeRequests",
    "started_at": "2023-05-12T01:35:05.469+00:00",
    "completed_at": "2023-05-12T01:36:06.432+00:00",
    "completed": true,
    "obsolete": false,
    "migration_state": {}
  },
  {
    "version": 20230428500000,
    "name": "AddSuffixProjectInWikiRid",
    "started_at": "2023-05-04T18:59:43.542+00:00",
    "completed_at": "2023-05-04T18:59:43.542+00:00",
    "completed": false,
    "obsolete": false,
    "migration_state": {
      "pause_indexing": true,
      "slice": 1,
      "task_id": null,
      "max_slices": 5,
      "retry_attempt": 0
    }
  },
  {
    "version": 20230503064300,
    "name": "BackfillProjectPermissionsInBlobsUsingPermutations",
    "started_at": "2023-05-03T16:04:44.074+00:00",
    "completed_at": "2023-05-03T16:04:44.074+00:00",
    "completed": true,
    "obsolete": false,
    "migration_state": {
      "permutation_idx": 8,
      "documents_remaining": 5,
      "task_id": "I2_LXc-xQlOeu-KmjYpM8g:172820",
      "documents_remaining_for_permutation": 0
    }
  }
]
```

<a id="retrieve-an-advanced-search-migration"></a>

## 检索一个高级搜索迁移

根据迁移版本或名称检索指定的高级搜索迁移。

```plaintext
获取 /admin/search/migrations/:version_or_name
```

参数：

| 属性              | 类型           | 是否必填 | 描述                       |
|-------------------|----------------|----------|----------------------------|
| `version_or_name` | 整数或字符串   | 是       | 迁移的版本或名称。         |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/admin/search/migrations/20230503064300"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://primary.example.com/api/v4/admin/search/migrations/BackfillProjectPermissionsInBlobsUsingPermutations"
```

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性              | 类型     | 描述                                           |
|:------------------|:---------|:------------------------------------------------------|
| `version`         | 整数     | 迁移的版本。                                   |
| `name`            | 字符串   | 迁移的名称。                                   |
| `started_at`      | 日期时间 | 迁移的开始日期。                               |
| `completed_at`    | 日期时间 | 迁移的完成日期。                               |
| `completed`       | 布尔值   | 如果为 `true`，表示迁移已完成。                |
| `obsolete`        | 布尔值   | 如果为 `true`，表示迁移已被标记为过时。        |
| `migration_state` | 对象     | 存储的迁移状态。                               |

示例响应：

```json
{
  "version": 20230503064300,
  "name": "BackfillProjectPermissionsInBlobsUsingPermutations",
  "started_at": "2023-05-03T16:04:44.074+00:00",
  "completed_at": "2023-05-03T16:04:44.074+00:00",
  "completed": true,
  "obsolete": false,
  "migration_state": {
    "permutation_idx": 8,
    "documents_remaining": 5,
    "task_id": "I2_LXc-xQlOeu-KmjYpM8g:172820",
    "documents_remaining_for_permutation": 0
  }
}
```