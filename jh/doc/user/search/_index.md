---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab 中搜索
description: 基础搜索、高级搜索、精确搜索、搜索范围以及提交 SHA 搜索。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在不断增长的代码库或不断扩大的组织中查找您需要的内容。通过查找项目中的特定代码、工作项、合并请求和其他内容来节省时间。您可以从三种搜索类型中选择，以满足您的需求：**基础搜索**、[**高级搜索**](advanced_search.md)和[**精确代码搜索**](exact_code_search.md)。

对于代码搜索，极狐GitLab 按以下顺序使用这些类型：

- **精确代码搜索**：您可以使用精确匹配和正则表达式模式。
- **高级搜索**：当精确代码搜索不可用时使用。
- **基础搜索**：当精确代码搜索和高级搜索都不可用，
  或者您针对非默认分支进行搜索时使用。
  此类型不支持群组搜索或全局搜索。

<a id="available-scopes"></a>

## 可用的搜索范围

> [!flag]
> 群组搜索范围的可用性由功能标志控制。

搜索范围描述您正在搜索的数据类型。基础搜索支持以下搜索范围：

| 搜索范围       | 全局 <sup>1</sup> |    群组     | 项目 |
|----------------|:-------------------:|:-----------:|:-------:|
| 代码           |     {{< no >}}      | {{< no >}}  | {{< yes >}} |
| 评论           |     {{< no >}}      | {{< no >}}  | {{< yes >}} |
| 提交           |     {{< no >}}      | {{< no >}}  | {{< yes >}} |
| 群组           |     {{< yes >}}     | {{< yes >}} | {{< no >}} |
| 工作项         |     {{< yes >}}     | {{< yes >}} | {{< yes >}} |
| 合并请求       |     {{< yes >}}     | {{< yes >}} | {{< yes >}} |
| 里程碑 <sup>2</sup> |     {{< yes >}}     | {{< yes >}} | {{< yes >}} |
| 项目           |     {{< yes >}}     | {{< yes >}} | {{< no >}} |
| 用户           |     {{< yes >}}     | {{< yes >}} | {{< yes >}} |
| Wiki           |     {{< no >}}      | {{< no >}}  | {{< yes >}} |

**脚注**：

1. 管理员可以[禁用全局搜索范围](#disable-global-search-scopes)。
1. 全局基础搜索仅返回项目里程碑，不返回群组里程碑。

<a id="specify-a-search-type"></a>

## 指定搜索类型

要指定搜索类型，请按如下方式设置 `search_type` URL 参数：

- `search_type=zoekt` 用于[精确代码搜索](exact_code_search.md)
- `search_type=advanced` 用于[高级搜索](advanced_search.md)
- `search_type=basic` 用于基础搜索

`search_type` 取代了已弃用的 `basic_search` 参数。更多信息，请参见[议题 477333](https://gitlab.com/gitlab-org/gitlab/-/issues/477333)。

<a id="restrict-search-access"></a>

## 限制搜索访问

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须具有实例的管理员访问权限。

默认情况下，未认证用户可以访问 `/search` 和全局搜索。

要将 `/search` 限制为仅认证用户可访问，请执行以下任一操作：

- 为项目或群组[限制可见性级别](../../administration/settings/visibility_and_access_controls.md#restrict-visibility-levels)。
  如果公共项目受到限制，匿名全局搜索
  会重定向到极狐GitLab 登录页面。
- 在**管理**区域中限制访问：

  1. 在右上角，选择 **管理员**。
  1. 选择 **设置** > **搜索**。
  1. 展开 **高级搜索**。
  1. 清除 **允许未认证用户使用搜索** 复选框。
  1. 选择 **保存更改**。

要将全局搜索限制为仅认证用户可访问：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **可见性与访问控制**。
1. 选中 **将全局搜索限制为仅经过身份验证的用户** 复选框。
1. 选择 **保存更改**。

<a id="disable-global-search-scopes"></a>

## 禁用全局搜索范围

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须具有实例的管理员访问权限。

要提高实例全局搜索的性能，您可以禁用一个或多个搜索范围。在极狐GitLab 私有化部署实例上，所有全局搜索范围默认启用。

要禁用一个或多个全局搜索范围：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **可见性与访问控制**。
1. 清除您要禁用的搜索范围的复选框。
1. 选择 **保存更改**。

<a id="configure-a-default-search-scope"></a>

## 配置默认搜索范围

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须具有实例的管理员访问权限。

默认情况下，当用户未选择搜索范围时，系统会根据上下文和可用性自动选择一个搜索范围。要改为配置默认搜索范围：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **搜索**。
1. 展开 **可见性与访问控制**。
1. 从 **默认搜索范围** 下拉列表中，选择一个搜索范围。
   要自动选择，请选择 **系统默认（自动）**。
1. 选择 **保存更改**。

用户可以通过选择其他搜索范围来覆盖默认搜索范围。如果默认搜索范围不可用（例如全局搜索中的代码），系统会自动选择一个搜索范围。

<a id="global-search-validation"></a>

## 全局搜索验证

全局搜索会忽略任何包含以下内容的搜索，并将其记录为滥用行为：

- 少于两个字符
- 超过 100 个字符的词条（URL 搜索词条不得超过 200 个字符）
- 仅包含停用词（例如 `the`、`and` 或 `if`）
- 未知的 `scope`
- 不完全为数字的 `group_id` 或 `project_id`
- 包含 [Git 引用名](https://git-scm.com/docs/git-check-ref-format)不允许的特殊字符的 `repository_ref` 或 `project_ref`

全局搜索只会对包含以下内容的搜索标记错误：

- 超过 4096 个字符
- 超过 64 个词条

议题搜索不支持部分匹配。例如，当您在议题中搜索 `play` 时，查询不会返回包含 `display`的议题。但是，查询会匹配该字符串的所有可能变体（例如 `plays`）。

<a id="autocomplete-suggestions"></a>

## 自动补全建议

> [!flag]
> 此功能的可用性由功能标志控制。

当您在搜索框中输入时，会显示以下内容的自动补全建议：

- 项目和群组
- 来自已授权项目和群组的用户
- 帮助页面
- 项目功能（例如里程碑）
- 设置（例如用户设置）
- 最近查看的合并请求
- 最近查看的工作项
- 项目中工作项的[极狐GitLab 风格 Markdown 引用](../markdown.md#gitlab-specific-references)

<a id="search-in-all-gitlab"></a>

## 在所有极狐GitLab 中搜索

要在所有极狐GitLab 中搜索：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 输入您的搜索查询。您必须至少输入两个字符。
1. 按 <kbd>Enter</kbd> 进行搜索，或从列表中选择。

结果会显示出来。要筛选结果，请在左侧边栏中选择一个筛选条件。

<a id="search-in-a-project"></a>

## 在项目中搜索

要在项目中搜索：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 再次选择**搜索或跳转到**并输入您要搜索的字符串。
1. 按 <kbd>Enter</kbd> 进行搜索，或从列表中选择。

结果会显示出来。要筛选结果，请在左侧边栏中选择一个筛选条件。

<a id="include-archived-projects-in-search-results"></a>

## 在搜索结果中包含已归档项目

默认情况下，已归档项目会从搜索结果中排除。要在搜索结果中包含已归档项目：

1. 在搜索页面的左侧边栏中，选中 **包括存档** 复选框。
1. 在左侧边栏中，选择 **应用**。

<a id="search-for-code"></a>

## 搜索代码

要在项目中搜索代码：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 再次选择**搜索或跳转到**并输入您要搜索的代码。
1. 按 <kbd>Enter</kbd> 进行搜索，或从列表中选择。

代码搜索仅显示文件中的第一个结果。要在所有极狐GitLab 中搜索代码，请让管理员启用[高级搜索](advanced_search.md)。

<a id="view-git-blame-from-code-search"></a>

### 从代码搜索查看 Git 追溯

找到搜索结果后，您可以查看对找到结果所在行进行最后更改的人。

1. 在代码搜索结果中，将鼠标悬停在行号上。
1. 在左侧，选择 **查看 blame**。

<a id="filter-code-search-results-by-language"></a>

### 按语言筛选代码搜索结果

要按一种或多种语言筛选代码搜索结果：

1. 在代码搜索页面的左侧边栏中，选择一种或多种语言。
1. 在左侧边栏中，选择 **应用**。

<a id="search-for-a-commit-sha"></a>

## 搜索提交 SHA

要搜索提交 SHA：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 再次选择**搜索或跳转到**并输入您要搜索的提交 SHA。
1. 按 <kbd>Enter</kbd> 进行搜索，或从列表中选择。

如果只返回一个结果，极狐GitLab 会重定向到该提交结果，并为您提供返回搜索结果页面的选项。

<a id="syntax"></a>

## 语法

基础搜索使用精确子字符串匹配，支持以下选项：

| 语法       | 描述                                     | 示例 |
|--------------|-------------------------------------------------|---------|
| `filename:`  | 文件名                                        | `filename:*spec.rb` |
| `path:`      | 代码仓库位置（完全或部分匹配）   | `path:spec/workers/` |
| `extension:` | 不带 `.` 的文件扩展名（仅精确匹配） | `extension:js` |

<a id="examples"></a>

### 示例

| 查询                                 | 描述 |
|---------------------------------------|-------------|
| `rails -filename:gemfile.lock`        | 返回除 `gemfile.lock` 文件之外所有文件中的 `rails`。 |
| `helper -extension:yml -extension:js` | 返回除扩展名为 `.yml` 或 `.js`的文件之外所有文件中的 `helper`。 |
| `helper path:lib/git`                 | 返回路径为 `lib/git*` 的所有文件（例如 `spec/lib/gitlab`）中的 `helper`。 |
