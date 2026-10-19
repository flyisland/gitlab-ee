---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 贡献
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

贡献是一种数据源，提供跨项目或群组的贡献活动（如提交、议题和合并请求）的聚合指标。

<a id="allowed-modes"></a>

## 允许的模式

- [`analytics`](../_index.md#analytics-mode)

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                                                              |
| --------- | ------------------------------------------------------------------------ |
| `project` | 查询特定项目中的贡献。                               |
| `group`   | 查询群组中所有项目（包括子群组）的贡献。 |

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                      | 名称      | 运算符                 |
| -------------------------- | --------- | ------------------------- |
| [创建时间](#created-at)  | `created` | `=`, `>`, `<`, `>=`, `<=` |
| [用户](#user)              | `user`    | `=`, `in`                 |

### 创建时间 {#created-at}

**描述**：按贡献的创建日期筛选贡献。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为 `<sign><digit><unit>`，其中 sign 为 `+`、`-` 或省略，digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于 `=` 运算符，GLQL 会考虑用户时区中从 00:00 到 23:59 的时间范围。

### 用户 {#user}

**描述**：按做出贡献的用户进行筛选。

**允许的值类型**：

- `Number`（用户 ID）
- `List`（使用 `in` 运算符指定多个用户 ID）

> [!note]
> 用户名筛选的支持正在 [GLQL 议题 143](https://gitlab.com/gitlab-org/glql/-/work_items/143) 中跟踪。

<a id="dimensions"></a>

## 维度

| 维度  | 名称      | 描述                                          |
| ---------- | --------- | ----------------------------------------------------- |
| 创建时间 | `created` | 按贡献创建日期分组。接受 [`granularity` 参数](../_index.md#field-parameters)，值为 `daily`、`weekly` 或 `monthly`（默认：`monthly`）。例如，`created(weekly)`。 |

<a id="metrics"></a>

## 指标

| 指标      | 名称         | 描述                    |
| ----------- | ------------ | ------------------------------- |
| 总数 | `totalCount` | 贡献的总数。 |
| 用户数 | `usersCount` | 唯一贡献者的数量。 |

<a id="sort-fields"></a>

## 排序字段

按所选维度或指标中包含的任何字段排序。有关更多信息，请参阅[分析模式排序](../_index.md#sorting)。

<a id="examples"></a>

## 示例

- 项目的月度贡献趋势：

  ````yaml
  ```glql
  title: "Monthly contributions"
  display: table
  mode: analytics
  query: type = Contribution and project = "gitlab-org/gitlab"
  dimensions: created as "Month"
  metrics: totalCount as "Total", usersCount as "Contributors"
  sort: created desc
  ```
  ````

- 一组用户的贡献趋势：

  ````yaml
  ```glql
  title: "Contributions from a set of users"
  display: table
  mode: analytics
  query: type = Contribution and project = "gitlab-org/gitlab" and user in (1234567, 2345678) and created >= -90d
  dimensions: created as "Month"
  metrics: totalCount as "Total"
  sort: created desc
  ```
  ````

- 特定用户过去一年的月度贡献：

  ````yaml
  ```glql
  title: "User contribution history"
  display: table
  mode: analytics
  query: type = Contribution and group = "gitlab-org" and user = 1234567 and created >= -365d
  dimensions: created as "Month"
  metrics: totalCount as "Total"
  sort: created asc
  ```
  ````

- 群组的整体贡献指标（不分组）：

  ````yaml
  ```glql
  title: "Overall contribution metrics"
  display: table
  mode: analytics
  query: type = Contribution and group = "gitlab-org" and created >= -90d
  metrics: totalCount as "Total", usersCount as "Contributors"
  ```
  ````
