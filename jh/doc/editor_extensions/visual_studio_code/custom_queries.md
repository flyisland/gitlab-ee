---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: VS Code 扩展中的自定义查询
---

极狐 GitLab VS Code 扩展为 VS Code 添加了一个 [侧边栏](projects.md#view-issues-and-merge-requests)。此侧边栏显示每个项目的默认搜索查询：

- 指派给我的议题
- 我创建的议题
- 指派给我的合并请求
- 我创建的合并请求
- 我正在审查的合并请求

除了默认查询外，您还可以 [创建自定义查询](#create-a-custom-query)。

<a id="view-search-query-results-in-vs-code"></a>

## 在 VS Code 中查看搜索查询结果

前提条件：

- 您是极狐 GitLab 项目的成员。
- 您已 [安装扩展](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow)。
- 您已登录到您的极狐 GitLab 实例，如 [设置](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/-/tree/main/#setup) 中所述。

查看项目中的搜索结果：

1. 在左侧垂直菜单栏上，选择 **极狐 GitLab**（{{< icon name="tanuki" >}}）以显示扩展侧边栏。
1. 在侧边栏中，展开 **议题和合并请求**。
1. 选择一个项目以查看其查询，然后选择要运行的查询。
1. 在查询标题下方，选择要查看的搜索结果。
1. 如果您的搜索结果是合并请求，选择在 VS Code 中查看的内容：
   - **概览**：此合并请求的描述、状态和任何评论。
   - 此合并请求中更改的所有文件的文件名。选择一个文件以查看其更改的差异。
1. 如果您的搜索结果是议题，选择它以在 VS Code 中查看其描述、历史和评论。

<a id="create-a-custom-query"></a>

## 创建自定义查询

您定义的任何自定义查询都将覆盖 [VS Code 侧边栏](projects.md#view-issues-and-merge-requests) 中显示的默认查询，位于 **议题和合并请求** 下。

覆盖扩展的默认查询并将其替换为您自己的查询：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 在右上角，选择 **打开设置 (JSON)** 以编辑您的 `settings.json` 文件。
1. 在文件中，定义 `gitlab.customQueries`，如下例所示。每个查询都应是 `gitlab.customQueries` JSON 数组中的一个条目：

   ```json
   {
     "gitlab.customQueries": [
       {
         "name": "指派给我的议题",
         "type": "issues",
         "scope": "assigned_to_me",
         "noItemText": "没有指派给你的议题。",
         "state": "opened"
       }
     ]
   }
   ```

1. 可选。当您自定义 `gitlab.customQueries` 时，您的定义将覆盖所有默认查询。要恢复任何默认查询，请从扩展的 [`desktop.package.json` 文件](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/-/blob/8e4350232154fe5bf0ef8a6c0765b2eac0496dc7/desktop.package.json#L955-998) 中的 `default` 数组复制它们。
1. 保存您的更改。

<a id="supported-parameters-for-all-queries"></a>

### 所有查询支持的参数

并非所有项目类型都支持所有参数。这些参数适用于所有查询类型：

| 参数    | 必填    | 默认           | 定义 |
|--------------|-------------|-------------------|------------|
| `name`       | {{< yes >}} | 不适用    | 要在极狐 GitLab 面板中显示的标签。 |
| `noItemText` | {{< no >}}  | `未找到项目。` | 如果查询未返回任何项目则显示的文本。 |
| `type`       | {{< no >}}  | `merge_requests`  | 要返回的项目类型。可能值：`issues`、`merge_requests`、`epics`、`snippets`、`vulnerabilities`。代码片段 [不支持](../../api/project_snippets.md) 任何其他过滤器。史诗仅在极狐 GitLab 专业版和旗舰版上可用。 |

<a id="supported-parameters-for-issue-epic-and-merge-request-queries"></a>

### 议题、史诗和合并请求查询支持的参数

所有这些参数都是可选的。

| 参数          | 默认        | 定义 |
|--------------------|----------------|------------|
| `assignee`         | 不适用 | 返回指派给给定用户名的项目。`None` 返回未指派的极狐 GitLab 项目。`Any` 返回有指派人的极狐 GitLab 项目。不适用于史诗和漏洞。 |
| `author`           | 不适用 | 返回由给定用户名创建的项目。 |
| `confidential`     | 不适用 | 过滤机密或公开议题。仅适用于议题。 |
| `createdAfter`     | 不适用 | 返回给定日期之后创建的项目。 |
| `createdBefore`    | 不适用 | 返回给定日期之前创建的项目。 |
| `draft`            | `no`           | 根据其草稿状态过滤合并请求：`yes` 仅返回处于 [草稿状态](../../user/project/merge_requests/drafts.md) 的合并请求，`no` 仅返回未处于草稿状态的合并请求。仅适用于合并请求。 |
| `excludeAssignee`  | 不适用 | 返回未指派给给定用户名的项目。仅适用于议题。对于当前用户，设置为 `<current_user>`。 |
| `excludeAuthor`    | 不适用 | 返回未由给定用户名创建的项目。仅适用于议题。对于当前用户，设置为 `<current_user>`。 |
| `excludeLabels`    | `[]`           | 标签名称数组。仅适用于议题。返回的项目不具有数组中的任何标签。预定义名称不区分大小写。 |
| `excludeMilestone` | 不适用 | 要排除的里程碑标题。仅适用于议题。 |
| `excludeSearch`    | 不适用 | 搜索标题或描述中不包含搜索键的极狐 GitLab 项目。仅适用于议题。 |
| `labels`           | `[]`           | 标签名称数组。返回的项目具有数组中的所有标签。`None` 返回没有标签的项目。`Any` 返回至少有一个标签的项目。预定义名称不区分大小写。 |
| `maxResults`       | 20             | 要显示的结果数量。 |
| `milestone`        | 不适用 | 里程碑标题。`None` 列出所有没有里程碑的项目。`Any` 列出所有有指派里程碑的项目。不适用于史诗和漏洞。 |
| `orderBy`          | `created_at`   | 返回按选定值排序的实体。可能值：`created_at`、`updated_at`、`priority`、`due_date`、`relative_position`、`label_priority`、`milestone_due`、`popularity`、`weight`。某些值特定于议题，某些特定于合并请求。有关更多信息，请参阅 [列出合并请求](../../api/merge_requests.md#list-merge-requests)。 |
| `reviewer`         | 不适用 | 返回指派给此用户名进行审查的合并请求。对于当前用户，设置为 `<current_user>`。`None` 返回没有审查者的项目。`Any` 返回有审查者的项目。 |
| `scope`            | `all`          | 返回给定范围的极狐 GitLab 项目。不适用于史诗。可能值：`assigned_to_me`、`created_by_me`、`all`。 |
| `search`           | 不适用 | 针对标题和描述搜索极狐 GitLab 项目。 |
| `searchIn`         | `all`          | 更改 `excludeSearch` 搜索属性的范围。可能值：`all`、`title`、`description`。仅适用于议题。 |
| `sort`             | `desc`         | 返回按升序或降序排序的议题。可能值：`asc`、`desc`。 |
| `state`            | `opened`       | 返回所有议题，或仅返回匹配特定状态的议题。可能值：`all`、`opened`、`closed`。 |
| `updatedAfter`     | 不适用 | 返回给定日期之后更新的项目。 |
| `updatedBefore`    | 不适用 | 返回给定日期之前更新的项目。 |

<a id="supported-parameters-for-vulnerability-report-queries"></a>

### 漏洞报告查询支持的参数

漏洞报告与其他条目类型不共享 [任何通用查询参数](../../api/vulnerability_findings.md)。此表中列出的每个参数仅适用于漏洞报告，并且所有参数都是可选的：

| 参数          | 默认        | 定义 |
|--------------------|----------------|------------|
| `confidenceLevels` | `all`          | 返回属于指定置信度级别的漏洞。可能值：`undefined`、`ignore`、`unknown`、`experimental`、`low`、`medium`、`high`、`confirmed`。 |
| `reportTypes`      | 不适用 | 返回属于指定报告类型的漏洞。可能值：`sast`、`dast`、`dependency_scanning`、`container_scanning`。 |
| `scope`            | `dismissed`    | 返回给定范围的漏洞发现。可能值：`all`、`dismissed`。有关更多信息，请参阅 [漏洞发现 API](../../api/vulnerability_findings.md)。 |
| `severityLevels`   | `all`          | 返回属于指定严重程度级别的漏洞。可能值：`undefined`、`info`、`unknown`、`low`、`medium`、`high`、`critical`。 |
