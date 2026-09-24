---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab 中搜索
description: Basic, advanced, exact, search scope, and commit SHA search.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在日益增长的代码库或不断扩展的组织中找到您所需的内容。通过查找特定代码、工作项、合并请求以及跨项目的其他内容来节省时间。根据您的需求，从三种搜索类型中进行选择：**基本搜索**、[**高级搜索**](advanced_search.md) 和 [**精确代码搜索**](exact_code_search.md)。

对于代码搜索，极狐GitLab 按如下顺序使用这些类型：

- **精确代码搜索**：您可以使用精确匹配和正则表达式模式。
- **高级搜索**：当精确代码搜索不可用时使用。
- **基本搜索**：当精确代码搜索和高级搜索不可用，或者您对非默认分支进行搜索时使用。此类型不支持群组或全局搜索。

<a id="available-scopes"></a>

## 可用范围

范围描述您正在搜索的数据类型。以下范围适用于基本搜索：

| 范围            | 全局 <sup>1</sup> |    群组    | 项目 |
|-----------------|:-----------------:|:----------:|:----:|
| 代码             |     {{< no >}}    | {{< no >}} | {{< yes >}} |
| 评论             |     {{< no >}}    | {{< no >}} | {{< yes >}} |
| 提交             |     {{< no >}}    | {{< no >}} | {{< yes >}} |
| 工作项           |     {{< yes >}}   | {{< yes >}} | {{< yes >}} |
| 合并请求         |     {{< yes >}}   | {{< yes >}} | {{< yes >}} |
| 里程碑 <sup>2</sup> |     {{< yes >}}   | {{< yes >}} | {{< yes >}} |
| 项目             |     {{< yes >}}   | {{< yes >}} | {{< no >}} |
| 用户             |     {{< yes >}}   | {{< yes >}} | {{< yes >}} |
| Wiki            |     {{< no >}}    | {{< no >}} | {{< yes >}} |

**脚注**:

1. 管理员可以[禁用全局搜索范围](#disable-global-search-scopes)。
2. 全局基本搜索只返回项目里程碑，不返回群组里程碑。

<a id="specify-a-search-type"></a>

## 指定搜索类型

{{< history >}}

- 在极狐GitLab 17.4 中引入。

{{< /history >}}

要指定搜索类型，请设置 `search_type` URL 参数，如下所示：

- 对于[精确代码搜索](exact_code_search.md)，使用 `search_type=zoekt`
- 对于[高级搜索](advanced_search.md)，使用 `search_type=advanced`
- 对于基本搜索，使用 `search_type=basic`

`search_type` 取代了已弃用的 `basic_search` 参数。

<a id="restrict-search-access"></a>

## 限制搜索访问

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 13.4 中[引入]了限制全局搜索给已认证用户的功能，并[带有功能标志](../../administration/feature_flags/_index.md)名为 `block_anonymous_global_searches`，默认禁用。
- 在极狐GitLab 16.7 中[引入]了允许未认证用户搜索的功能，并[带有功能标志](../../administration/feature_flags/_index.md)名为 `allow_anonymous_searches`，默认启用。
- 在极狐GitLab 17.11 中，限制全局搜索给已认证用户[GA]，功能标志 `block_anonymous_global_searches` 已移除。
- 在极狐GitLab 18.0 中，允许未认证用户搜索[GA]，功能标志 `allow_anonymous_searches` 已移除。

{{< /history >}}

前提条件：

- 您必须拥有实例的管理员访问权限。

默认情况下，`/search` 请求和全局搜索对未认证用户可用。

要仅限已认证用户访问 `/search`，请执行以下任一操作：

- [限制项目或群组的可见性级别](../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。如果限制了公开项目，匿名全局搜索将被重定向到极狐GitLab 登录页面。
- 在 **管理员** 区域限制访问：

  1. 在右上角，选择 **管理员**。
  1. 选择 **设置** > **搜索**。
  1. 展开 **高级搜索**。
  1. 清除 **允许未认证用户使用搜索** 复选框。
  1. 选择 **保存更改**。

要仅限已认证用户访问全局搜索：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **可见性和访问控制**。
1. 选中 **限制全局搜索为仅已认证用户** 复选框。
1. 选择 **保存更改**。

<a id="disable-global-search-scopes"></a>

## 禁用全局搜索范围

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.9 中引入。

{{< /history >}}

前提条件：

- 您必须拥有实例的管理员访问权限。

为了提高实例全局搜索的性能，您可以禁用一个或多个搜索范围。默认情况下，私有化部署实例的所有全局搜索范围均已启用。

要禁用一个或多个全局搜索范围：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **可见性和访问控制**。
1. 清除您要禁用的范围的复选框。
1. 选择 **保存更改**。

<a id="configure-a-default-search-scope"></a>

## 配置默认搜索范围

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

前提条件：

- 您必须拥有实例的管理员访问权限。

默认情况下，当用户未选择搜索范围时，会根据上下文和可用性自动选择一个范围。要改为配置默认搜索范围，请执行以下步骤：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **可见性和访问控制**。
1. 从 **默认搜索范围** 下拉列表中，选择一个范围。要进行自动选择，请选择 **系统默认（自动）**。
1. 选择 **保存更改**。

用户可以通过选择其他范围来覆盖默认范围。如果默认范围不可用（例如，全局搜索中的代码），则会自动选择一个范围。

<a id="global-search-validation"></a>

## 全局搜索验证

{{< history >}}

- 在极狐GitLab 14.9 中，移除了议题搜索中对部分匹配的支持，并[带有功能标志](../../administration/feature_flags/_index.md)名为 `issues_full_text_search`，默认禁用。
- 在极狐GitLab 16.2 中[GA]，功能标志 `issues_full_text_search` 已移除。

{{< /history >}}

全局搜索会忽略并记录为滥用任何包含以下内容的搜索：

- 少于两个字符
- 术语超过 100 个字符（URL 搜索词不得超过 200 个字符）
- 仅包含停用词（例如 `the`、`and` 或 `if`）
- 未知的 `scope`
- `group_id` 或 `project_id` 不完全是数字
- `repository_ref` 或 `project_ref` 包含 [Git 引用名称](https://git-scm.com/docs/git-check-ref-format) 不允许的特殊字符

全局搜索仅对包含超过以下内容的搜索标记错误：

- 4096 个字符
- 64 个术语

议题搜索不支持部分匹配。例如，当您在议题中搜索 `play` 时，查询不会返回包含 `display` 的议题。但是，查询会匹配字符串的所有可能变体（例如 `plays`）。

<a id="autocomplete-suggestions"></a>

## 自动补全建议

{{< history >}}

- 在极狐GitLab 17.10 中[引入]了仅显示来自授权项目和群组的用户的功能，并[带有功能标志](../../administration/feature_flags/_index.md)名为 `users_search_scoped_to_authorized_namespaces_advanced_search`、`users_search_scoped_to_authorized_namespaces_basic_search` 和 `users_search_scoped_to_authorized_namespaces_basic_search_by_ids`，默认禁用。
- 在极狐GitLab 17.11 中[GA]，功能标志 `users_search_scoped_to_authorized_namespaces_advanced_search`、`users_search_scoped_to_authorized_namespaces_basic_search` 和 `users_search_scoped_to_authorized_namespaces_basic_search_by_ids` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见上文历史记录。

当您在搜索框中输入时，会显示以下内容的自动补全建议：

- 项目和群组
- 来自授权项目和群组的用户
- 帮助页面
- 项目功能（例如，里程碑）
- 设置（例如，用户设置）
- 最近查看的合并请求
- 最近查看的工作项
- 项目中工作项的 [极狐GitLab Flavored Markdown 引用](../markdown.md#gitlab-specific-references)

<a id="search-in-all-gitlab"></a>

## 在所有极狐GitLab 中搜索

要在所有极狐GitLab 中搜索：

1. 在顶部栏，选择 **搜索或跳转到**。
2. 输入您的搜索查询。必须至少输入两个字符。
3. 按 <kbd>Enter</kbd> 键搜索，或从列表中选择。

结果显示后，要过滤结果，请在左侧边栏中选择一个过滤器。

<a id="search-in-a-project"></a>

## 在项目中搜索

要在项目中搜索：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
2. 再次选择 **搜索或跳转到** 并输入您要搜索的字符串。
3. 按 <kbd>Enter</kbd> 键搜索，或从列表中选择。

结果显示后，要过滤结果，请在左侧边栏中选择一个过滤器。

<a id="include-archived-projects-in-search-results"></a>

## 在搜索结果中包含已归档项目

{{< history >}}

- 在极狐GitLab 16.1 中针对项目搜索[引入]了该功能，并[带有功能标志](../../administration/feature_flags/_index.md)名为 `search_projects_hide_archived`，默认禁用。
- 在极狐GitLab 16.6 中，此功能已在所有搜索范围中[GA]。

{{< /history >}}

默认情况下，已归档项目将被排除在搜索结果之外。要在搜索结果中包含已归档项目：

1. 在搜索页面上，在左侧边栏中，选中 **包含已归档** 复选框。
2. 在左侧边栏中，选择 **应用**。

<a id="search-for-code"></a>

## 搜索代码

要在项目中搜索代码：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
2. 再次选择 **搜索或跳转到** 并输入您要搜索的代码。
3. 按 <kbd>Enter</kbd> 键搜索，或从列表中选择。

代码搜索仅显示文件中的第一个结果。要在所有极狐GitLab 中搜索代码，请让您的管理员启用[高级搜索](advanced_search.md)。

<a id="view-git-blame-from-code-search"></a>

### 从代码搜索查看 Git 追溯

{{< history >}}

- 在极狐GitLab 14.7 中引入。

{{< /history >}}

在找到搜索结果后，您可以查看是谁对找到结果的那一行进行了最后更改。

1. 在代码搜索结果中，将鼠标悬停在行号上。
2. 在左侧，选择 **查看追溯**。

<a id="filter-code-search-results-by-language"></a>

### 按语言过滤代码搜索结果

{{< history >}}

- 在极狐GitLab 15.10 中引入。

{{< /history >}}

要按一种或多种语言过滤代码搜索结果：

1. 在代码搜索页面上，在左侧边栏中，选择一种或多种语言。
2. 在左侧边栏中，选择 **应用**。

<a id="search-for-a-commit-sha"></a>

## 搜索提交 SHA

要搜索一个提交 SHA：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
2. 再次选择 **搜索或跳转到** 并输入您要搜索的提交 SHA。
3. 按 <kbd>Enter</kbd> 键搜索，或从列表中选择。

如果返回了单个结果，极狐GitLab 会将您重定向到该提交结果，并为您提供返回搜索结果页面的选项。

<a id="syntax"></a>

## 语法

基本搜索使用精确子字符串匹配，并提供以下选项：

| 语法         | 描述                                         | 示例                 |
|--------------|-----------------------------------------------|----------------------|
| `filename:`  | 文件名                                       | `filename:*spec.rb`  |
| `path:`      | 仓库位置（完全或部分匹配）                   | `path:spec/workers/` |
| `extension:` | 文件扩展名，不带 `.`（仅精确匹配）           | `extension:js`       |

### 示例

| 查询                                   | 描述 |
|----------------------------------------|------|
| `rails -filename:gemfile.lock`        | 返回所有文件中除 `gemfile.lock` 文件外的 `rails`。 |
| `helper -extension:yml -extension:js` | 返回所有文件中除扩展名为 `.yml` 或 `.js` 的文件外的 `helper`。 |
| `helper path:lib/git`                 | 返回所有路径为 `lib/git*`（例如 `spec/lib/gitlab`）的文件中的 `helper`。 |
