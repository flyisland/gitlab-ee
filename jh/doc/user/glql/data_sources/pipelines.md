---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="allowed-modes"></a>

## 允许的模式

- 标准模式（默认）：查询流水线记录。
- 分析模式：查询聚合的流水线指标。更多信息，请参见[流水线分析](pipeline_analytics.md)。

> [!note]
> 标准模式不支持排序。

<a id="allowed-scopes"></a>

## 允许的范围

| 范围     | 描述                              |
| --------- | ---------------------------------------- |
| `project` | 查询特定项目中的流水线。   |

更多信息，请参见[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                                          | 名称（及别名）                             | 运算符                  |
| ---------------------------------------------- | -------------------------------------------- | -------------------------- |
| [作者](#pipeline-author)                     | `author`                                     | `=`                        |
| [引用](#pipeline-ref)                           | `ref`                                        | `=`                        |
| [范围](#pipeline-scope)                       | `scope`                                      | `=`                        |
| [SHA](#pipeline-sha)                           | `sha`                                        | `=`                        |
| [来源](#pipeline-source)                     | `source`                                     | `=`                        |
| [状态](#pipeline-status)                     | `status`                                     | `=`                        |
| [更新时间](#pipeline-updated-at)             | `updated`, `updatedAt`                       | `=`, `>`, `<`, `>=`, `<=`  |

### 作者 {#pipeline-author}

**描述**：按触发流水线的用户筛选。

**允许的值类型**：

- `String`
- `User`（例如，`@username`）

### 引用 {#pipeline-ref}

**描述**：按流水线运行所在的 Git 引用（分支或标签名称）筛选。

**允许的值类型**：`String`

### 范围 {#pipeline-scope}

**描述**：按流水线的范围筛选。

**允许的值类型**：

- `Enum`，为 `branches`、`tags`、`finished`、`pending` 或 `running` 之一

### SHA {#pipeline-sha}

**描述**：按提交 SHA 筛选流水线。

**允许的值类型**：`String`

### 来源 {#pipeline-source}

**描述**：按触发流水线的来源筛选。

**允许的值类型**：`String`

### 状态 {#pipeline-status}

**描述**：按流水线的 CI/CD 状态筛选。

**允许的值类型**：

- `Enum`，为 `canceled`、`canceling`、`created`、`failed`、`manual`、`pending`、
  `preparing`、`running`、`scheduled`、`skipped`、`success`、`waiting_for_callback`
  或 `waiting_for_resource` 之一

### 更新时间 {#pipeline-updated-at}

**描述**：按流水线的最后更新时间筛选。

**允许的值类型**：

- `AbsoluteDate`（格式为 `YYYY-MM-DD`）
- `RelativeDate`（格式为`<sign><digit><unit>`，其中 sign 为`+`、`-`或省略，
  digit 为整数，`unit` 为 `d`（天）、`w`（周）、`m`（月）或 `y`（年）之一）

**注意**：

- 对于`=`运算符，时间范围按用户所在时区的 00:00 至 23:59 计算。

<a id="display-fields"></a>

## 显示字段

| 字段              | 名称（及别名）                   | 描述 |
| ------------------ | ---------------------------------- | ----------- |
| 活动状态             | `active`                           | 显示流水线是否处于活动状态 |
| 可取消         | `cancelable`                       | 显示流水线是否可取消 |
| 子流水线              | `child`                            | 显示这是否为子流水线 |
| 提交             | `commit`                           | 显示提交详情（ID、短 ID、标题、作者姓名、Web URL） |
| 提交路径        | `commitPath`                       | 显示触发流水线的提交路径 |
| 提交时间       | `committed`, `committedAt`         | 显示提交时间戳 |
| 已完成           | `complete`                         | 显示流水线是否已完成 |
| 计算分钟    | `computeMinutes`                   | 显示使用的计算分钟 |
| 配置来源      | `configSource`                     | 显示流水线配置来源 |
| 覆盖率           | `coverage`                         | 显示代码覆盖率百分比 |
| 创建时间         | `created`, `createdAt`             | 显示流水线的创建时间 |
| 时长           | `duration`                         | 显示流水线时长 |
| 失败作业数  | `failedJobsCount`                  | 显示失败的作业数量 |
| 失败原因     | `failureReason`                    | 显示流水线失败的原因 |
| 完成时间        | `finished`, `finishedAt`           | 显示流水线的完成时间 |
| ID                 | `id`                               | 显示流水线 ID |
| IID                | `iid`                              | 显示流水线内部 ID |
| 最新             | `latest`                           | 显示这是否为该引用的最新流水线 |
| 名称               | `name`                             | 显示流水线名称 |
| 路径               | `path`                             | 显示流水线路径 |
| 引用                | `ref`                              | 显示 Git 引用（分支或标签） |
| 引用路径           | `refPath`                          | 显示触发流水线的引用路径 |
| 可重试          | `retryable`                        | 显示流水线是否可重试 |
| SHA                | `sha`                              | 显示提交 SHA |
| 来源             | `source`                           | 显示触发流水线的来源 |
| 阶段             | `stages`                           | 显示流水线阶段（名称和状态） |
| 开始时间         | `started`, `startedAt`             | 显示流水线的开始时间 |
| 状态             | `status`                           | 显示流水线状态 |
| 卡住              | `stuck`                            | 显示流水线是否卡住 |
| 作业总数         | `totalJobs`                        | 显示作业总数 |
| 更新时间         | `updated`, `updatedAt`             | 显示流水线的最后更新时间 |
| 用户               | `user`                             | 显示触发流水线的用户 |
| 警告           | `warnings`                         | 显示流水线警告 |
| YAML 错误        | `yamlErrors`                       | 显示流水线是否有 YAML 错误 |
| YAML 错误消息| `yamlErrorMessages`                | 显示 YAML 错误消息 |

<a id="known-issues"></a>

## 已知问题

- 日期范围较大的查询可能会导致超时。

<a id="examples"></a>

## 示例

- 列出 `gitlab-org/gitlab` 项目中今天失败的所有流水线：

  ````yaml
  ```glql
  title: "Failed pipelines today"
  display: table
  fields: id, ref, status, startedAt
  query: type = Pipeline and project = "gitlab-org/gitlab" and status = failed and updated = today()
  ```
  ````

- 列出 `gitlab-org/gitlab` 项目中所有 Duo Agent 流水线：

  ````yaml
  ```glql
  title: "GitLab Duo agent pipelines"
  display: table
  fields: id, ref, status, source, startedAt
  query: type = Pipeline and project = "gitlab-org/gitlab" and source = "duo_workflow"
  ```
  ````
