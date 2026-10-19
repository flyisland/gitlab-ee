---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Cube to query the GitLab Product analytics API. Send queries, generate access tokens, and retrieve analytics metadata.
title: 产品分析 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.4 中引入，带有名为 `cube_api_proxy` 的功能标志。默认禁用。
- 在极狐GitLab 15.10 中，`cube_api_proxy` 被移除，并由 `product_analytics_internal_preview` 替代。
- 在极狐GitLab 15.11 中，`product_analytics_internal_preview` 被 `product_analytics_dashboards` 替代。
- 在极狐GitLab 16.11 中，`product_analytics_dashboards` 默认启用。
- 在极狐GitLab 17.1 中，功能标志 `product_analytics_dashboards` 被移除。
- [在极狐GitLab 17.5 中](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/167296) 变更为 Beta，带有名为 `product_analytics_features` 的功能标志。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能尚未准备好用于生产环境。

使用此 API 来跟踪用户行为和应用使用情况。

> [!note]
> 务必先通过 [此 API](settings.md) 定义 `cube_api_base_url` 和 `cube_api_key` 应用设置。

## 创建 Cube 查询请求

创建一个到 Cube API 的查询请求并生成一个访问令牌。

```plaintext
POST /projects/:id/product_analytics/request/load
POST /projects/:id/product_analytics/request/dry-run
```

| 属性              | 类型             | 是否必需 | 描述                                                      |
|-----------------|------------------| -------- |-------------------------------------------------------------|
| `id`            | integer          | 是      | 当前用户有读取权限的项目的 ID。                               |
| `include_token` | boolean          | 否       | 是否在响应中包含访问令牌。(仅漏斗生成时需要。) |

### 请求体

加载请求的正文必须是有效的 Cube 查询。

> [!note]
> 当测量 `TrackedEvents` 时，你必须使用 `TrackedEvents.*` 作为 `dimensions` 和 `timeDimensions`。测量 `Sessions` 时也适用相同的规则。

#### TrackedEvents 示例

```json
{
  "query": {
    "measures": [
      "TrackedEvents.count"
    ],
    "timeDimensions": [
      {
        "dimension": "TrackedEvents.utcTime",
        "dateRange": "This week"
      }
    ],
    "order": [
      [
        "TrackedEvents.count",
        "desc"
      ],
      [
        "TrackedEvents.docPath",
        "desc"
      ],
      [
        "TrackedEvents.utcTime",
        "asc"
      ]
    ],
    "dimensions": [
      "TrackedEvents.docPath"
    ],
    "limit": 23
  },
  "queryType": "multi"
}
```

#### Sessions 示例

```json
{
  "query": {
    "measures": [
      "Sessions.count"
    ],
    "timeDimensions": [
      {
        "dimension": "Sessions.startAt",
        "granularity": "day"
      }
    ],
    "order": {
      "Sessions.startAt": "asc"
    },
    "limit": 100
  },
  "queryType": "multi"
}
```

## 获取 Cube 元数据

获取分析数据的 Cube 元数据。

```plaintext
GET /projects/:id/product_analytics/request/meta
```

| 属性 | 类型             | 是否必需 | 描述                                                   |
| --------- |------------------| -------- |-------------------------------------------------------------|
| `id`      | integer          | 是      | 当前用户有读取权限的项目的 ID。 |

