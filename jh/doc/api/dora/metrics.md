---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Retrieve project and group DORA metrics with the REST API.
title: DevOps 研究与评估 (DORA) 指标 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 获取群组和项目的 [DORA 指标](../../user/analytics/dora_metrics.md) 详情。

更多端点可通过 [GraphQL API](../graphql/reference/_index.md) 获取。

先决条件：

- 你必须具有报告者、开发者、维护者或所有者角色。

<a id="retrieve-project-level-dora-metrics"></a>

## 获取项目级 DORA 指标

获取指定项目的 DORA 指标。

```plaintext
GET /projects/:id/dora/metrics
```

| 属性 | 类型 | 是否必需 | 描述 |
|:---------------------|:-----------------|:---------|:------------|
| `id` | integer 或 string | 是 | 经过身份验证的用户可以访问的项目 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `metric` | string | 是 | `deployment_frequency`、`lead_time_for_changes`、`time_to_restore_service` 或 `change_failure_rate` 之一。 |
| `end_date` | string | 否 | 结束日期范围。ISO 8601 日期格式，例如 `2021-03-01`。默认为当前日期。 |
| `environment_tiers` | array of strings | 否 | [环境层级](../../ci/environments/_index.md#deployment-tier-of-environments)。默认为 `production`。 |
| `interval` | string | 否 | 分桶间隔。`all`、`monthly` 或 `daily` 之一。默认为 `daily`。 |
| `start_date` | string | 否 | 开始日期范围。ISO 8601 日期格式，例如 `2021-03-01`。默认为 3 个月前。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/1/dora/metrics?metric=deployment_frequency"
```

示例响应：

```json
[
  { "date": "2021-03-01", "value": 3 },
  { "date": "2021-03-02", "value": 6 },
  { "date": "2021-03-03", "value": 0 },
  { "date": "2021-03-04", "value": 0 },
  { "date": "2021-03-05", "value": 0 },
  { "date": "2021-03-06", "value": 0 },
  { "date": "2021-03-07", "value": 0 },
  { "date": "2021-03-08", "value": 4 }
]
```

<a id="retrieve-group-level-dora-metrics"></a>

## 获取群组级 DORA 指标

获取指定群组的 DORA 指标。

```plaintext
GET /groups/:id/dora/metrics
```

| 属性 | 类型 | 是否必需 | 描述 |
|:--------------------|:-----------------|:---------|:------------|
| `id` | integer 或 string | 是 | 经过身份验证的用户可以访问的项目 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |
| `metric` | string | 是 | `deployment_frequency`、`lead_time_for_changes`、`time_to_restore_service` 或 `change_failure_rate` 之一。 |
| `end_date` | string | 否 | 结束日期范围。ISO 8601 日期格式，例如 `2021-03-01`。默认为当前日期。 |
| `environment_tiers` | array of strings | 否 | [环境层级](../../ci/environments/_index.md#deployment-tier-of-environments)。默认为 `production`。 |
| `interval` | string | 否 | 分桶间隔。`all`、`monthly` 或 `daily` 之一。默认为 `daily`。 |
| `start_date` | string | 否 | 开始日期范围。ISO 8601 日期格式，例如 `2021-03-01`。默认为 3 个月前。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/groups/1/dora/metrics?metric=deployment_frequency"
```

示例响应：

```json
[
  { "date": "2021-03-01", "value": 3 },
  { "date": "2021-03-02", "value": 6 },
  { "date": "2021-03-03", "value": 0 },
  { "date": "2021-03-04", "value": 0 },
  { "date": "2021-03-05", "value": 0 },
  { "date": "2021-03-06", "value": 0 },
  { "date": "2021-03-07", "value": 0 },
  { "date": "2021-03-08", "value": 4 }
]
```

<a id="the-value-field"></a>

## `value` 字段

对于前面描述的项目级和群组级端点，API 响应中的 `value` 字段含义取决于提供的 `metric` 查询参数：

| `metric` 查询参数 | 响应中 `value` 的描述 |
|:---------------------------|:-----------------------------------|
| `deployment_frequency` | API 返回时间段内成功部署的总数。[议题 371271](https://jihulab.com/gitlab-cn/gitlab/-/issues/371271) 提议更新 API 以返回每日平均值而不是总数。 |
| `change_failure_rate` | 时间段内的事件数除以部署数。仅适用于生产环境。 |
| `lead_time_for_changes` | 时间段内部署的所有 MR 的合并请求 (MR) 合并到 MR 提交部署之间的中位秒数。 |
| `time_to_restore_service` | 时间段内事件保持开放状态的中位秒数。仅适用于生产环境。 |

> [!note]
> API 通过计算每日中位值的中位数来返回 `monthly` 和 `all` 间隔。这可能会导致返回数据略有偏差。