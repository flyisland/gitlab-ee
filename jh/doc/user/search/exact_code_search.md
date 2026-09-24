---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "Use exact code search to find code in a specific project or across all of GitLab."
title: 精确代码搜索
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 有限可用性

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 中作为[测试版](../../policy/development_stages_support.md#beta)引入，带有名为 `index_code_with_zoekt` 和 `search_code_with_zoekt` 的[功能标志](../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 16.6 中[在 JihuLab.com 和极狐GitLab 私有化部署上启用]。
- 在极狐GitLab 16.11 中[引入]全局代码搜索，带有名为 `zoekt_cross_namespace_search` 的[功能标志](../../administration/feature_flags/_index.md)。默认禁用。
- 功能标志 `index_code_with_zoekt` 和 `search_code_with_zoekt` 在极狐GitLab 17.1 中[移除]。
- 在极狐GitLab 18.6 中从测试版[更改为]有限可用性。
- 功能标志 `zoekt_cross_namespace_search` 在极狐GitLab 18.7 中[移除]。

{{< /history >}}

> [!warning]
> 此功能处于[有限可用性](../../policy/development_stages_support.md#limited-availability)阶段。
> 更多信息，请参见 [epic 9404](https://jihulab.com/groups/gitlab-cn/-/epics/9404)。
> 在 [issue 420920](https://jihulab.com/gitlab-cn/gitlab/-/issues/420920) 中提供反馈。

通过精确代码搜索，你可以使用精确匹配和正则表达式模式
在极狐GitLab 所有项目或特定项目中搜索代码。

精确代码搜索由 Zoekt 驱动，在启用了该功能的群组中默认使用。

<a id="use-exact-code-search"></a>

## 使用精确代码搜索

前提条件：

- 必须启用精确代码搜索：
  - 对于 JihuLab.com，精确代码搜索在付费订阅中默认启用。
  - 对于极狐GitLab 私有化部署，管理员必须
    [安装 Zoekt](../../integration/zoekt/_index.md#install-zoekt) 并
    [启用精确代码搜索](../../integration/zoekt/_index.md#enable-exact-code-search)。

要使用精确代码搜索：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 在搜索框中，输入你的搜索词。
1. 在左侧边栏中，选择 **代码**。

你也可以在项目或群组中使用精确代码搜索。

<a id="available-scopes"></a>

## 可用的范围

范围描述了你正在搜索的数据类型。
精确代码搜索支持以下范围：

| 范围 | 全局 <sup>1</sup> <sup>2</sup> |    群组    | 项目     |
|-------|:--------------------------------:|:-----------:|:-----------:|
| 代码  |           {{< no >}}             | {{< yes >}} | {{< yes >}} |

**脚注**：

1. 管理员可以[禁用全局搜索范围](_index.md#disable-global-search-scopes)。
   在极狐GitLab 18.6 及更早版本中，要在极狐GitLab 私有化部署上启用全局搜索，
   管理员还必须启用 `zoekt_cross_namespace_search` 功能标志。
1. 在 JihuLab.com 上，全局搜索未启用。

<a id="zoekt-search-api"></a>

## Zoekt 搜索 API

{{< history >}}

- 在极狐GitLab 16.9 中[引入]，带有名为 `zoekt_search_api` 的[功能标志](../../administration/feature_flags/_index.md)。默认启用。
- 在极狐GitLab 18.4 中[GA]。功能标志 `zoekt_search_api` 已移除。

{{< /history >}}

通过 Zoekt 搜索 API，你可以使用搜索 API 进行精确代码搜索。
要改用高级搜索或基本搜索，请[指定搜索类型](_index.md#specify-a-search-type)。

<a id="search-modes"></a>

## 搜索模式

{{< history >}}

- 在极狐GitLab 16.8 中[引入]，带有名为 `zoekt_exact_search` 的[功能标志](../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 17.3 中[GA]。功能标志 `zoekt_exact_search` 已移除。

{{< /history >}}

极狐GitLab 有两种搜索模式：

- **精确匹配模式**：返回与查询完全匹配的结果。
- **正则表达式模式**：支持正则表达式和布尔表达式。

默认使用精确匹配模式。
要切换到正则表达式模式，在搜索框右侧，
选择 **使用正则表达式** ({{< icon name="regular-expression" >}})。

<a id="syntax"></a>

### 语法

{{< history >}}

- `repo:` 过滤器在极狐GitLab 19.0 中[引入]。

{{< /history >}}

<!-- 记得同时更新 `doc/drawers/exact_code_search_syntax.md` 中的表格 -->

此表格展示了精确匹配和正则表达式模式的一些查询示例。

| 查询                | 精确匹配模式                                                                | 正则表达式模式                                                         |
|----------------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `"foo"`              | `"foo"`                                                                         | `foo`                                                                           |
| `foo file:^doc/`     | 在目录以 `/doc` 开头的文件中的 `foo`                                     | 在目录以 `/doc` 开头的文件中的 `foo`                                     |
| `"class foo"`        | `"class foo"`                                                                   | `class foo`                                                                     |
| `class foo`          | `class foo`                                                                     | `class` 和 `foo`                                                               |
| `foo or bar`         | `foo or bar`                                                                    | `foo` 或 `bar`                                                                  |
| `class Foo`          | `class Foo`（区分大小写）                                                    | `class`（不区分大小写）和 `Foo`（区分大小写）                           |
| `class Foo case:yes` | `class Foo`（区分大小写）                                                    | `class` 和 `Foo`（均区分大小写）                                         |
| `foo -bar`           | `foo -bar`                                                                      | `foo` 但不包含 `bar`                                                             |
| `foo file:js`        | 文件名包含 `js` 的文件中的 `foo`                                     | 文件名包含 `js` 的文件中的 `foo`                                     |
| `foo -file:test`     | 文件名不包含 `test` 的文件中的 `foo`                            | 文件名不包含 `test` 的文件中的 `foo`                            |
| `foo lang:ruby`      | Ruby 源代码中的 `foo`                                                       | Ruby 源代码中的 `foo`                                                       |
| `foo file:\.js$`     | 文件名以 `.js` 结尾的文件中的 `foo`                                   | 文件名以 `.js` 结尾的文件中的 `foo`                                   |
| `foo.*bar`           | `foo.*bar`（字面量）                                                            | `foo.*bar`（正则表达式）                                                 |
| `sym:foo`            | 类、方法和变量名等符号中的 `foo`                         | 类、方法和变量名等符号中的 `foo`                         |
| `test repo:(?i)foo`  | 项目名包含 `foo`（不区分大小写）的项目中的 `test` | 项目名包含 `foo`（不区分大小写）的项目中的 `test` |

<a id="known-issues"></a>

## 已知问题

- 你只能搜索小于 1 MB 且三元组少于 `20_000` 个的文件。
  更多信息，请参见 [issue 455073](https://jihulab.com/gitlab-cn/gitlab/-/issues/455073)。
- 你只能在项目的默认分支上使用精确代码搜索。
  更多信息，请参见 [issue 403307](https://jihulab.com/gitlab-cn/gitlab/-/issues/403307)。
- 同一行上的多个匹配项计为一个结果。
- 如果你遇到换行符显示不正确的结果，
  请将 `gitlab-zoekt` 更新到 1.5.0 或更高版本。