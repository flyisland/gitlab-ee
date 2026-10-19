---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="allowed-scopes"></a>

## 允许的范围

| 范围       | 描述                                                                              |
| ----------- | ---------------------------------------------------------------------------------------- |
| `namespace` | 查询特定命名空间中的项目。您可以使用 `group` 作为 `namespace`的别名。 |

更多信息，请参见[范围](_index.md#scopes)。

<a id="query-fields"></a>

## 查询字段

在 `query` 参数中使用这些字段来筛选结果。

| 字段                                                    | 名称（及别名）       | 运算符  |
| -------------------------------------------------------- | ---------------------- | ---------- |
| [仅归档](#project-archived-only)                  | `archivedOnly`         | `=`, `!=`  |
| [有代码覆盖率](#project-has-code-coverage)          | `hasCodeCoverage`      | `=`, `!=`  |
| [有漏洞](#project-has-vulnerabilities)      | `hasVulnerabilities`   | `=`, `!=`  |
| [包含已归档](#project-include-archived)            | `includeArchived`      | `=`, `!=`  |
| [包含子群组](#project-include-subgroups)          | `includeSubgroups`     | `=`, `!=`  |
| [已启用议题](#project-issues-enabled)                | `issuesEnabled`        | `=`, `!=`  |
| [已启用合并请求](#project-merge-requests-enabled)| `mergeRequestsEnabled` | `=`, `!=`  |

### 仅归档 {#project-archived-only}

**描述**：筛选以仅显示已归档的项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

**注意**：

- 不能与 `includeArchived` 一起使用。

### 有代码覆盖率 {#project-has-code-coverage}

**描述**：按项目是否有代码覆盖率报告来筛选项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

### 有漏洞 {#project-has-vulnerabilities}

**描述**：按项目是否有安全漏洞来筛选项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

### 包含已归档 {#project-include-archived}

**描述**：在结果中包含已归档的项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

**注意**：

- 不能与 `archivedOnly` 一起使用。
- 默认情况下，不包含已归档的项目。

### 包含子群组 {#project-include-subgroups}

**描述**：是否包含子群组中的项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

**注意**：

- 此字段只能与 `namespace` 范围一起使用。
- 指定 `namespace` 范围时，默认为 `true`。

### 已启用议题 {#project-issues-enabled}

**描述**：按项目是否已启用议题来筛选项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

### 已启用合并请求 {#project-merge-requests-enabled}

**描述**：按项目是否已启用合并请求来筛选项目。

**允许的值类型**：`Boolean`（`true` 或 `false`）

<a id="display-fields"></a>

## 显示字段

| 字段                            | 名称（及别名）                 | 描述 |
| -------------------------------- | -------------------------------- | ----------- |
| 已归档                         | `archived`                       | 显示项目是否已归档 |
| 头像 URL                       | `avatarUrl`                      | 显示项目头像的 URL |
| 已启用 Duo 功能             | `duoFeaturesEnabled`             | 显示是否已启用 Duo 功能 |
| 已 fork                           | `forked`                         | 显示项目是否为 fork |
| fork 数量                      | `forksCount`                     | 显示fork 的数量 |
| 完整路径                        | `fullPath`                       | 显示项目的完整路径 |
| 群组                            | `group`                          | 显示项目所属的群组 |
| ID                               | `id`                             | 显示项目 ID |
| 已启用议题                   | `issuesEnabled`                  | 显示是否已启用议题 |
| 最近活动                    | `lastActivity`, `lastActivityAt` | 显示项目最近活跃的时间 |
| 已启用合并请求           | `mergeRequestsEnabled`           | 显示是否已启用合并请求 |
| 名称                             | `name`                           | 显示项目名称 |
| 未关闭议题数                | `openIssuesCount`                | 显示未关闭议题的数量 |
| 未关闭合并请求数        | `openMergeRequestsCount`         | 显示未关闭合并请求的数量 |
| 路径                             | `path`                           | 显示项目路径 |
| 已启用密钥推送保护   | `secretPushProtectionEnabled`    | 显示是否已启用密钥推送保护 |
| 星标数                       | `starCount`                      | 显示星标的数量 |
| 可见性                       | `visibility`                     | 显示项目的可见性级别 |
| Web URL                          | `webUrl`                         | 显示项目的 Web URL |

<a id="sort-fields"></a>

## 排序字段

| 字段         | 名称（及别名）                 | 描述                    |
| ------------- | -------------------------------- | ------------------------------ |
| 完整路径     | `fullPath`                       | 按完整路径排序              |
| 最近活动 | `lastActivity`, `lastActivityAt` | 按最近活动日期排序     |
| 路径          | `path`                           | 按路径排序                   |

**注意**：

- `lastActivity` 仅支持降序（`desc`）排序。

<a id="examples"></a>

## 示例

- 列出 `gitlab-org` 群组中的所有项目，按路径排序：

  ````yaml
  ```glql
  display: table
  fields: name, fullPath, starCount, openIssuesCount
  sort: path asc
  query: type = Project and group = "gitlab-org"
  ```
  ````

- 列出 `gitlab-org` 群组中的所有项目，按最近活跃时间排序：

  ````yaml
  ```glql
  display: table
  fields: name, fullPath, lastActivity
  sort: lastActivity desc
  query: type = Project and group = "gitlab-org"
  ```
  ````
