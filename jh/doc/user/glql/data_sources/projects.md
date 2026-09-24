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

{{< history >}}

- 在 极狐GitLab 18.11 中[新增]字段 `avatarUrl`。

{{< /history >}}

## 查询字段

以下字段为必填：[群组/命名空间](#project-group)

| 字段                                                    | 名称 (及别名)           | 操作符  |
| -------------------------------------------------------- | ---------------------- | ---------- |
| [仅已归档](#project-archived-only)                        | `archivedOnly`         | `=`, `!=`  |
| [群组/命名空间](#project-group)                           | `namespace`, `group`   | `=`        |
| [有代码覆盖率](#project-has-code-coverage)               | `hasCodeCoverage`      | `=`, `!=`  |
| [有漏洞](#project-has-vulnerabilities)                  | `hasVulnerabilities`   | `=`, `!=`  |
| [包含已归档](#project-include-archived)                 | `includeArchived`      | `=`, `!=`  |
| [包含子群组](#project-include-subgroups)                | `includeSubgroups`     | `=`, `!=`  |
| [议题已启用](#project-issues-enabled)                    | `issuesEnabled`        | `=`, `!=`  |
| [合并请求已启用](#project-merge-requests-enabled)        | `mergeRequestsEnabled` | `=`, `!=`  |

<a id="project-archived-only"></a>

### 仅已归档

**描述**：筛选以仅显示已归档的项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

**注意**：

- 不能与 `includeArchived` 一起使用。

<a id="project-group"></a>

### 群组 / 命名空间

**描述**：指定群组命名空间以从其中查询项目。此字段为必填。你可以使用 `namespace` 或 `group` 作为字段名称。

**允许的值类型**：`字符串`

<a id="project-has-code-coverage"></a>

### 有代码覆盖率

**描述**：根据项目是否有代码覆盖率报告来筛选项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

<a id="project-has-vulnerabilities"></a>

### 有漏洞

**描述**：根据项目是否有安全漏洞来筛选项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

<a id="project-include-archived"></a>

### 包含已归档

**描述**：在结果中包含已归档的项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

**注意**：

- 不能与 `archivedOnly` 一起使用。
- 默认情况下，不包含已归档项目。

<a id="project-include-subgroups"></a>

### 包含子群组

**描述**：是否包含来自子群组的项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

**注意**：

- 此字段只能与 `namespace` 或 `group` 字段一起使用。
- 当指定了 `namespace` 或 `group` 时，默认值为 `true`。

<a id="project-issues-enabled"></a>

### 议题已启用

**描述**：根据项目是否启用了议题来筛选项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

<a id="project-merge-requests-enabled"></a>

### 合并请求已启用

**描述**：根据项目是否启用了合并请求来筛选项目。

**允许的值类型**：`布尔` (即 `true` 或 `false`)

## 显示字段

| 字段                            | 名称 (及别名)                   | 描述 |
| -------------------------------- | -------------------------------- | ----------- |
| 已归档                           | `archived`                       | 显示项目是否已归档 |
| 头像 URL                         | `avatarUrl`                      | 显示项目头像的 URL |
| Duo 功能已启用                   | `duoFeaturesEnabled`             | 显示 Duo 功能是否已启用 |
| 已 Fork                         | `forked`                         | 显示项目是否为 Fork |
| Fork 数量                       | `forksCount`                     | 显示 Fork 的数量 |
| 完整路径                         | `fullPath`                       | 显示项目的完整路径 |
| 群组                             | `group`                          | 显示项目所属的群组 |
| ID                               | `id`                             | 显示项目 ID |
| 议题已启用                       | `issuesEnabled`                  | 显示议题是否已启用 |
| 最后活跃时间                     | `lastActivity`, `lastActivityAt` | 显示项目最后一次活跃的时间 |
| 合并请求已启用                   | `mergeRequestsEnabled`           | 显示合并请求是否已启用 |
| 名称                             | `name`                           | 显示项目名称 |
| 打开的议题数量                   | `openIssuesCount`                | 显示打开的议题数量 |
| 打开的合并请求数量               | `openMergeRequestsCount`         | 显示打开的合并请求数量 |
| 路径                             | `path`                           | 显示项目路径 |
| 密钥推送保护已启用               | `secretPushProtectionEnabled`    | 显示密钥推送保护是否已启用 |
| Star 数量                       | `starCount`                      | 显示 Star 的数量 |
| 可见性                           | `visibility`                     | 显示项目可见性级别 |
| Web URL                          | `webUrl`                         | 显示项目的 Web URL |

## 排序字段

| 字段         | 名称 (及别名)                   | 描述                    |
| ------------- | -------------------------------- | ------------------------------ |
| 完整路径      | `fullPath`                       | 按完整路径排序              |
| 最后活跃时间  | `lastActivity`, `lastActivityAt` | 按最后活跃日期排序          |
| 路径          | `path`                           | 按路径排序                   |

**注意**：

- `lastActivity` 仅支持降序 (`desc`) 排序。

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

- 列出 `gitlab-org` 群组中的所有项目，按最近活跃排序：

  ````yaml
  ```glql
  display: table
  fields: name, fullPath, lastActivity
  sort: lastActivity desc
  query: type = Project and group = "gitlab-org"
  ```
  ````