---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the GitLab for VS Code extension to work with GitLab projects directly in your IDE.
title: 在 VS Code 中使用项目
---

使用 极狐 GitLab for VS Code 扩展来处理 极狐 GitLab 项目：

- 在议题中规划和跟踪工作。
- 使用 极狐 GitLab Duo 进行 AI 原生规划和编码。
- 在合并请求中审查和讨论更改。
- 在 极狐 GitLab 中比较分支和查看文件。
- 使用代码片段存储和共享代码。

通过该扩展，你可以直接在 VS Code 中完成许多这些任务。对于其他任务，扩展会在浏览器中打开 极狐 GitLab。

<a id="prerequisites"></a>

## 前提条件

- [认证扩展](setup.md#connect-to-gitlab) 并连接到 极狐 GitLab 上的仓库。
- 对于 极狐 GitLab Duo，查看 [配置要求](setup.md#configure-gitlab-duo)。

<a id="use-gitlab-duo-as-you-work"></a>

## 工作时使用 极狐 GitLab Duo

极狐 GitLab for VS Code 扩展让你可以在处理项目时使用 极狐 GitLab Duo Agent Platform 和 极狐 GitLab Duo（非 Agentic）。

<a id="gitlab-duo-agent-platform"></a>

### 极狐 GitLab Duo Agent Platform

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要使用 极狐 GitLab Duo Agentic Chat、代理和流程：

1. 在左侧边栏中，选择 **极狐 GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
1. 要与 Agentic Chat 交互，选择聊天标签页并输入提示。
1. 要与代理一起工作，选择聊天标签页，然后使用 **新会话**（{{< icon name="duo-chat-new" >}}）
   下拉列表选择要使用的基础或自定义代理。
1. 要使用软件开发流程，选择流程标签页，然后输入提示。

要使用 极狐 GitLab Duo 代码建议：

1. 在底部状态栏中，选择 **Duo**（{{< icon name="tanuki-ai" >}}）以检查功能状态。
1. 在编写代码时审查并接受内联代码建议。

<a id="gitlab-duo"></a>

### 极狐 GitLab Duo

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐 GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要使用 极狐 GitLab Duo 非 Agentic Chat：

1. 在左侧边栏中，选择 **极狐 GitLab Duo Chat**（{{< icon name="duo-chat" >}}）。
1. 在消息框中，输入问题并按 <kbd>Enter</kbd> 或选择 **发送**。

要使用 极狐 GitLab Duo 代码建议：

1. 在底部状态栏中，选择 **Duo**（{{< icon name="tanuki-ai" >}}）以检查功能状态。
1. 在编写代码时审查并接受内联代码建议。

<a id="create-an-issue"></a>

## 创建议题

要在当前项目中创建议题：

1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 在命令面板中，搜索 **极狐 GitLab：在当前项目上创建新议题**
   并按 <kbd>Enter</kbd>。

极狐 GitLab 会在默认浏览器中打开 **新议题** 页面。

<a id="create-a-merge-request"></a>

## 创建合并请求

要在当前项目中创建合并请求，请在底部状态栏中选择
**创建合并请求**（{{< icon name="merge-request-open" >}}）。

或者，你也可以使用命令面板：

1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 在命令面板中，搜索 **极狐 GitLab：在当前项目上创建新合并请求**
   并按 <kbd>Enter</kbd>。

极狐 GitLab 会在默认浏览器中打开 **新合并请求** 页面。

<a id="view-issues-and-merge-requests"></a>

## 查看议题和合并请求

要查看特定项目的议题和合并请求：

1. 在 VS Code 中，在左侧边栏中选择 **极狐 GitLab**（{{< icon name="tanuki" >}}）。
1. 展开议题和合并请求部分。
1. 选择一个项目以展开它。
1. 选择以下选项之一来审查项目列表：
   - **指派给我的议题**
   - **我创建的议题**
   - **指派给我的合并请求**
   - **我正在审查的合并请求**
   - **我创建的合并请求**
   - **所有项目合并请求**
   - 你的 [自定义查询](custom_queries.md)
1. 选择一个议题或合并请求以在新的 VS Code 标签页中打开它。

<a id="search-issues-and-merge-requests"></a>

## 搜索议题和合并请求

使用过滤搜索或 [高级搜索](../../integration/advanced_search/elasticsearch.md) 来
直接从 VS Code 搜索项目的议题和合并请求。
使用过滤搜索时，你使用预定义的令牌来优化搜索结果。
高级搜索在整个 极狐 GitLab 实例中提供更快、更高效的搜索。

前提条件：

- 你是 极狐 GitLab 项目的成员。

要搜索项目：

1. 在 VS Code 中，打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 选择所需的搜索类型：
   - **极狐 GitLab：搜索项目议题（支持过滤）**
   - **极狐 GitLab：搜索项目合并请求（支持过滤）**
   - **极狐 GitLab：高级搜索（议题、合并请求、提交、评论...）**
1. 按照提示输入搜索值并优化搜索。

极狐 GitLab 会在浏览器标签页中打开结果。

<a id="tokens-to-filter-search-results"></a>

### 用于过滤搜索结果的令牌

在大型项目中搜索时，添加过滤器会返回更好的结果。扩展支持这些令牌
用于过滤合并请求和议题：

| 令牌     | 示例                                                 | 描述 |
|-----------|---------------------------------------------------------|-------------|
| assignee  | `assignee: sjones`                                      | 指派人的用户名，不含 `@`。 |
| author    | `author: zwei`                                          | 作者的用户名，不含 `@`。 |
| label     | `label: frontend` 或 `label:frontend label: Discussion` | 单个标签。可多次使用，并且可以在同一查询中与 `labels` 一起使用。 |
| labels    | `labels: frontend, Discussion, performance`             | 逗号分隔列表中的多个标签。可以在同一查询中与 `label` 一起使用。 |
| milestone | `milestone: 18.1`                                       | 不含 `%` 的里程碑标题。 |
| scope     | `scope: created-by-me`                                  | 议题或合并请求的范围。值：`created-by-me`（默认）、`assigned-to-me` 或 `all`。 |
| title     | `title: discussions refactor`                           | 要在标题或描述中匹配的单词。不要在短语周围添加引号。 |

令牌语法和指南：

- 每个令牌名称后面都需要一个冒号（`:`），如 `label:`。
  - 冒号前的前导空格（`label :`）无效并返回解析错误。
  - 令牌名称后的空格是可选的。`label: frontend` 和 `label:frontend` 均有效。
- 你可以多次使用 `label` 和 `labels` 令牌并将它们一起使用。这些查询返回相同的结果：
  - `labels: frontend discussion label: performance`
  - `label: frontend label: discussion label: performance`
  - `labels: frontend discussion performance`（结果，组合查询）

你可以在单个搜索查询中组合多个令牌。例如：

```plaintext
title: new merge request widget author: zwei assignee: sjones labels: frontend, performance milestone: 17.5
```

此搜索查询查找：

- 标题：`new merge request widget`
- 作者：`zwei`
- 指派人：`sjones`
- 标签：`frontend` 和 `performance`
- 里程碑：`17.5`

<a id="review-a-merge-request"></a>

## 审查合并请求

要在 VS Code 中审查、评论和批准合并请求：

1. 在左侧边栏中，选择 **极狐 GitLab**（{{< icon name="tanuki" >}}）。
1. 展开议题和合并请求部分，然后选择项目。
1. 选择要审查的合并请求。
1. 在合并请求的编号和标题下，选择 **概览** 以阅读有关合并请求的更多信息。
1. 要审查文件的建议更改，从列表中选择文件以在 VS Code 标签页中显示它。
   极狐 GitLab 会在标签页中内联显示差异评论。在列表中，删除的文件标记为红色：

   ![此合并请求中更改文件的字母顺序列表，包括更改类型。](img/vscode_view_changed_file_v17_6.png)

使用差异来：

- 审查和创建讨论。
- 解决和重新打开这些讨论。
- 删除和编辑单个评论。

<a id="use-quick-actions"></a>

## 使用快速操作

要在议题和合并请求中使用 [极狐 GitLab 快速操作](../../user/project/quick_actions.md)：

1. 按照说明在 VS Code 中查看议题或合并请求。
1. 向下滚动找到评论部分。
1. 在新评论中输入快速操作，然后按 <kbd>Enter</kbd>。例如，要向议题添加
   `bug` 标签，输入 `/label bug`。

<a id="compare-with-default-branch"></a>

## 与默认分支比较

要将分支与项目的默认分支进行比较，而不创建合并请求：

1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 在命令面板中，搜索 **极狐 GitLab：比较当前分支与默认分支** 并
   按 <kbd>Enter</kbd>。

扩展会打开一个新的浏览器标签页。它显示分支上的最近提交与
项目默认分支上的最近提交之间的差异。

<a id="open-current-file-in-gitlab-ui"></a>

## 在 极狐 GitLab UI 中打开当前文件

要在 极狐 GitLab UI 中打开当前 极狐 GitLab 项目中的文件，并高亮显示特定行：

1. 在 VS Code 中打开所需文件。
1. 选择要高亮显示的行。
1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 在命令面板中，搜索 **极狐 GitLab：在极狐 GitLab 上打开活动文件** 并按 <kbd>Enter</kbd>。

<a id="create-a-snippet"></a>

## 创建代码片段

创建 [代码片段](../../user/snippets.md) 以与其他用户存储和共享代码和文本片段。
代码片段可以是选区或整个文件。

要在 VS Code 中创建代码片段：

1. 选择代码片段的内容：
   - 要使用整个文件创建代码片段，打开文件。
   - 要使用文件选区创建代码片段，打开文件并选择要
     包含的行。
1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 在命令面板中，搜索 **极狐 GitLab：创建代码片段** 并按 <kbd>Enter</kbd>。
1. 选择代码片段的隐私级别：
   - **私有** 代码片段仅对项目成员可见。
   - **公开** 代码片段对所有人可见。
1. 选择代码片段的范围：
   - **来自文件的代码片段** 使用活动文件的全部内容。
   - **来自选区的代码片段** 使用你在活动文件中选择的行。

极狐 GitLab 会在新浏览器标签页中打开新代码片段的页面。

<a id="create-a-patch-file"></a>

### 创建补丁文件

审查合并请求时，当你想要建议多文件更改时，创建代码片段补丁。

1. 在本地计算机上，检出要提议更改的分支。
1. 在 VS Code 中，编辑要更改的所有文件。不要提交更改。
1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 在命令面板中，搜索 **极狐 GitLab：创建代码片段补丁** 并按 <kbd>Enter</kbd>。
   此命令运行 `git diff` 命令并在项目中创建 极狐 GitLab 代码片段。
1. 输入 **补丁名称** 并按 <kbd>Enter</kbd>。极狐 GitLab 使用此名称作为
   代码片段标题，并将其转换为附加了 `.patch` 的文件名。
1. 选择代码片段的隐私级别：
   - **私有** 代码片段仅对项目成员可见。
   - **公开** 代码片段对所有人可见。

VS Code 会在新浏览器标签页中打开代码片段补丁。代码片段补丁的
描述包含有关如何应用补丁的说明。

<a id="insert-a-snippet"></a>

### 插入代码片段

要插入所属项目的现有单文件或 [多文件](../../user/snippets.md#add-or-remove-multiple-files) 代码片段：

1. 将光标放在要插入代码片段的位置。
1. 打开命令面板：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 搜索 **极狐 GitLab：插入代码片段** 并按 <kbd>Enter</kbd>。
1. 选择包含代码片段的项目。
1. 选择要应用的代码片段。
1. 对于多文件代码片段，选择要应用的文件。
