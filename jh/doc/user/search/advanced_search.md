---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 高级搜索
description: "使用高级搜索在整个极狐GitLab 实例中查找代码、提交、工作项和合并请求。"
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用高级搜索，在整个极狐GitLab 实例中精确找到您需要的内容。

通过高级搜索，您可以：

- 在所有项目中识别代码模式，从而更高效地重构共享组件。
- 在整个组织的代码库和依赖项中定位安全漏洞。
- 在所有代码仓库中跟踪已弃用函数或库的使用情况。
- 查找隐藏在议题、合并请求或评论中的讨论。
- 发现现有解决方案，避免重复实现已经存在的功能。

高级搜索适用于：

- 代码
- 评论
- 提交
- 群组
- 工作项
- 合并请求
- 里程碑
- 项目
- 用户
- Wiki

<a id="use-advanced-search"></a>

## 使用高级搜索

先决条件：

- 必须启用高级搜索：
  - 对于 JihuLab.com，付费订阅中默认启用高级搜索。
  - 对于极狐GitLab 私有化部署，管理员必须
    [启用高级搜索](../../integration/advanced_search/elasticsearch.md#enable-advanced-search)。

要使用高级搜索：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 在搜索框中，输入您的搜索词。

您也可以在项目或群组中使用高级搜索。

<a id="available-scopes"></a>

## 可用范围

> [!flag]
> 群组范围的可用性由功能标志控制。

范围描述您正在搜索的数据类型。高级搜索提供以下范围：

| 范围                       | 全局 <sup>1</sup> <sup>2</sup> | 群组       | 项目     |
|-----------------------------|----------------------------------|-------------|-------------|
| 代码                        | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| 评论                    | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| 提交                     | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| 群组 <sup>5</sup>         | {{< yes >}}                      | {{< yes >}} | {{< no >}}  |
| 工作项 <sup>3</sup>     | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| 合并请求 <sup>3</sup> | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| 里程碑 <sup>4</sup>     | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| 项目                    | {{< yes >}}                      | {{< yes >}} | {{< no >}}  |
| 用户                       | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |
| Wiki                       | {{< yes >}}                      | {{< yes >}} | {{< yes >}} |

**脚注**：

1. 管理员可以[禁用全局搜索范围](_index.md#disable-global-search-scopes)。
   在极狐GitLab 私有化部署上，默认启用有限索引时，全局搜索不可用。
   管理员可以[为有限索引启用全局搜索](../../integration/advanced_search/elasticsearch.md#indexed-namespaces)。
1. 在 JihuLab.com 上，代码、提交和 Wiki 未启用全局搜索。
1. 当您搜索工作项和合并请求时，结果
   会包含与您的搜索词匹配的评论。
1. 高级搜索仅返回项目里程碑，因为群组里程碑未在
   Elasticsearch 中建立索引。更多信息，请参见
   [议题 428589](https://gitlab.com/gitlab-org/gitlab/-/issues/428589)。
1. 群组搜索返回您正在搜索的群组的子群组，而不是该群组本身。
   在此范围返回结果之前，必须完成 `backfill_groups_to_elasticsearch` 高级搜索迁移。

<a id="syntax"></a>

## 语法

<!-- Remember to also update the tables in `doc/drawers/advanced_search_syntax.md` -->

高级搜索使用 [`simple_query_string`](https://www.elastic.co/docs/reference/query-languages/query-dsl/query-dsl-simple-query-string-query)，
它同时支持精确查询和模糊查询。

当您搜索用户时，默认使用 [`fuzzy`](https://www.elastic.co/docs/reference/query-languages/query-dsl/query-dsl-fuzzy-query) 查询。
您可以使用 `simple_query_string` 优化用户搜索。

| 语法 | 描述      | 示例 |
|--------|------------------|---------|
| `"`    | 精确搜索     | `"gem sidekiq"` |
| `~`    | 模糊搜索     | `J~ Doe` |
| `\|`   | 或               | `display \| banner` |
| `+`    | 与              | `display +banner` |
| `-`    | 排除          | `display -banner` |
| `*`    | 部分匹配          | `bug error 50*` |
| ` \ `  | 转义           | `\*md`  |
| `#`    | 议题 ID         | `#23456` |
| `!`    | 合并请求 ID | `!23456` |

<a id="code-search"></a>

### 代码搜索

| 语法       | 描述                                     | 示例 |
|--------------|-------------------------------------------------|---------|
| `filename:`  | 文件名                                        | `filename:*spec.rb` |
| `path:`      | 代码仓库位置（完全或部分匹配）   | `path:spec/workers/` |
| `extension:` | 不带 `.` 的文件扩展名（仅精确匹配） | `extension:js` |
| `blob:`      | Git 对象 ID（仅精确匹配）              | `blob:998707*` |

<a id="examples"></a>

### 示例

| 查询                                 | 描述 |
|---------------------------------------|-------------|
| `rails -filename:gemfile.lock`        | 返回除 `gemfile.lock` 文件之外的所有文件中的 `rails`。 |
| `RSpec.describe Resolvers -*builder`  | 返回不以 `builder` 开头的 `RSpec.describe Resolvers`。 |
| `bug \| (display +banner)`            | 返回 `bug` 或同时包含 `display` 和 `banner`。 |
| `helper -extension:yml -extension:js` | 返回除扩展名为 `.yml` 或 `.js`的文件之外的所有文件中的 `helper`。 |
| `helper path:lib/git`                 | 返回路径为 `lib/git*` 的所有文件中的 `helper`（例如 `spec/lib/gitlab`）。 |

<a id="known-issues"></a>

## 已知问题

- 您只能搜索小于 1 MB 的文件。
  对于极狐GitLab 私有化部署，管理员可以设置
  [已建立索引的最大文件大小](../../administration/instance_limits.md#maximum-file-size-indexed)限制。
- 您只能在项目的默认分支上使用高级搜索。
  更多信息，请参见[议题 229966](https://gitlab.com/gitlab-org/gitlab/-/issues/229966)。
- 搜索查询不得包含以下任何字符：

  ```plaintext
  . , : ; / ` ' = ? $ & ^ | < > ( ) { } [ ] @
  ```

- 搜索结果仅显示文件中的第一个匹配项。
