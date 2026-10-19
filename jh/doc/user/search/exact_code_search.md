---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "使用精确代码搜索在特定项目或整个极狐GitLab 中查找代码。"
title: 精确代码搜索
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 有限可用性

{{< /details >}}

> [!warning]
> 此功能处于[限量提供](../../policy/development_stages_support.md#limited-availability)阶段。
> 更多信息，请参见[史诗 9404](https://gitlab.com/groups/gitlab-org/-/work_items/9404)。
> 请在[议题 420920](https://gitlab.com/gitlab-org/gitlab/-/issues/420920)中提供反馈。

使用精确代码搜索，您可以使用精确匹配和正则表达式模式，在整个极狐GitLab 或特定项目中搜索代码。

精确代码搜索由 Zoekt 提供支持，在已启用该功能的群组中默认使用。

<a id="use-exact-code-search"></a>

## 使用精确代码搜索

先决条件：

- 必须启用精确代码搜索：
  - 对于 JihuLab.com，付费订阅默认启用精确代码搜索。
  - 对于极狐GitLab 私有化部署，管理员必须
    [安装 Zoekt](../../integration/zoekt/_index.md#install-zoekt) 并
    [启用精确代码搜索](../../integration/zoekt/_index.md#enable-exact-code-search)。

要使用精确代码搜索：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 在搜索框中，输入您的搜索词。
1. 在左侧边栏中，选择**代码**。

您也可以在项目或群组中使用精确代码搜索。

<a id="available-scopes"></a>

## 可用范围

范围描述您正在搜索的数据类型。精确代码搜索可使用以下范围：

| 范围 | 全局[^disable-global-search-scopes]、[^com-global-search] |    群组    | 项目     |
|-------|:--------------------------------:|:-----------:|:-----------:|
| 代码  |           {{< no >}}             | {{< yes >}} | {{< yes >}} |

[^disable-global-search-scopes]: 管理员可以[禁用全局搜索范围](_index.md#disable-global-search-scopes)。
    在极狐GitLab 18.6 及更早版本中，要在极狐GitLab 私有化部署上启用全局搜索，
    管理员还必须启用 `zoekt_cross_namespace_search` 功能标志。
[^com-global-search]: 在 JihuLab.com 上，未启用全局搜索。

<a id="zoekt-search-api"></a>

## Zoekt 搜索 API

使用 Zoekt 搜索 API，您可以将搜索 API 用于精确代码搜索。如需改用高级搜索或基础搜索，请[指定搜索类型](_index.md#specify-a-search-type)。

<a id="search-modes"></a>

## 搜索模式

极狐GitLab 有两种搜索模式：

- **精确匹配模式**：返回与查询完全匹配的结果。
- **正则表达式模式**：支持正则表达式和布尔表达式。

默认使用精确匹配模式。要切换到正则表达式模式，请在搜索框右侧选择**使用正则表达式**（{{< icon name="regular-expression" >}}）。

<a id="syntax"></a>

### 语法

<!-- Remember to also update the table in `doc/drawers/exact_code_search_syntax.md` -->

下表展示了精确匹配模式和正则表达式模式的一些示例查询。

| 查询                | 精确匹配模式                                                                | 正则表达式模式                                                         |
|----------------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `"foo"`              | `"foo"`                                                                         | `foo`                                                                           |
| `foo file:^doc/`     | 在以 `/doc` 开头的目录中的 `foo`                                     | 在以 `/doc` 开头的目录中的 `foo`                                     |
| `"class foo"`        | `"class foo"`                                                                   | `class foo`                                                                     |
| `class foo`          | `class foo`                                                                     | `class` 和 `foo`                                                               |
| `foo or bar`         | `foo or bar`                                                                    | `foo` 或 `bar`                                                                  |
| `class Foo`          | `class Foo`（区分大小写）                                                    | `class`（不区分大小写）和 `Foo`（区分大小写）                           |
| `class Foo case:yes` | `class Foo`（区分大小写）                                                    | `class` 和 `Foo`（均区分大小写）                                         |
| `foo -bar`           | `foo -bar`                                                                      | `foo` 但不包含 `bar`                                                             |
| `foo file:js`        | 在名称包含 `js`的文件中的 `foo`                                     | 在名称包含 `js`的文件中的 `foo`                                     |
| `foo -file:test`     | 在名称不包含 `test`的文件中的 `foo`                            | 在名称不包含 `test`的文件中的 `foo`                            |
| `foo lang:ruby`      | Ruby 源代码中的 `foo`                                                       | Ruby 源代码中的 `foo`                                                       |
| `foo file:\.js$`     | 在名称以 `.js` 结尾的文件中的 `foo`                                   | 在名称以 `.js` 结尾的文件中的 `foo`                                   |
| `foo.*bar`           | `foo.*bar`（字面量）                                                            | `foo.*bar`（正则表达式）                                                 |
| `sym:foo`            | 在类、方法和变量名等符号中的 `foo`                         | 在类、方法和变量名等符号中的 `foo`                         |
| `test repo:(?i)foo`  | 在名称中包含 `foo`的项目中的 `test`（不区分大小写） | 在名称中包含 `foo`的项目中的 `test`（不区分大小写） |

<a id="known-issues"></a>

## 已知问题

- 您只能搜索小于 1 MB 且三元组少于 `20_000`的文件。
  更多信息，请参见[议题 455073](https://gitlab.com/gitlab-org/gitlab/-/issues/455073)。
- 您只能在项目的默认分支上使用精确代码搜索。
  更多信息，请参见[议题 403307](https://gitlab.com/gitlab-org/gitlab/-/issues/403307)。
- 单行上的多个匹配项计为一个结果。
- 如果您遇到换行符显示不正确的结果，
  请将 `gitlab-zoekt` 更新到 1.5.0 或更高版本。
