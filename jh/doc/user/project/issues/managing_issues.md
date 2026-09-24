---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何管理极狐GitLab 议题，包括编辑、移动、关闭、批量操作，以及使用指派人、健康状态和自动化等各种议题功能。
title: 管理议题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 议题可帮助您跟踪工作并与团队协作。
您可以管理议题以：

- 编辑标题、描述、指派人和元数据等详细信息。
- 在项目之间移动议题，同时保留其上下文和历史记录。
- 关闭已完成的议题，并在需要时重新打开。
- 使用批量编辑高效更新多个议题。
- 跟踪议题健康状态以监控进度并识别风险。

有关管理议题子项的信息，请参阅[子项](../../work_items/child_items.md)。

<a id="edit-an-issue"></a>

## 编辑议题

您可以编辑议题的标题和描述。

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色，是议题的作者，或被指派到该议题。

要编辑议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在标题右侧，选择 **编辑**。
1. 编辑可用字段。
1. 选择 **保存更改**。

<a id="populate-an-issue-with-issue-description-generation"></a>

### 使用议题描述生成功能填充议题

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Enterprise
- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

{{< collapsible title="Model information" >}}

- LLM: 国内 SOTA 模型
- 不适用于自部署模型的极狐GitLab Duo

{{< /collapsible >}}

根据您提供的简短摘要，为议题生成详细描述。

先决条件：

- 您必须属于至少一个已启用[实验和测试版功能设置](../../gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)的群组。
- 您必须具有创建议题的权限。
- 仅适用于纯文本编辑器。
- 仅在创建新议题时可用。
  有关在编辑现有议题时支持生成描述的建议，请参阅
  [议题 474141](https://gitlab.com/gitlab-org/gitlab/-/issues/474141)。

要生成议题描述：

1. 创建新议题。
1. 在 **描述** 字段上方，选择 **极狐GitLab Duo** ({{< icon name="tanuki-ai" >}}) > **生成议题描述**。
1. 编写简短描述并选择 **提交**。

议题描述将被 AI 生成的文本替换。

请在 [议题 409844](https://gitlab.com/gitlab-org/gitlab/-/issues/409844) 中提供有关此实验功能的反馈。

**数据使用**：使用此功能时，您输入的文本将发送给大语言模型。

<a id="bulk-edit-issues"></a>

## 批量编辑议题

当您位于群组或项目中时，可以一次编辑多个议题。

先决条件：

- 您必须拥有群组或项目的计划者、报告者、开发者、维护者或所有者角色。

要同时编辑多个议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。
1. 选择 **批量编辑**。右侧会出现一个包含可编辑字段的侧边栏。
1. 选中您要编辑的每个议题旁边的复选框。
1. 从侧边栏中，编辑可用字段。
1. 选择 **更新所选**。

批量编辑议题时，您可以编辑以下属性：

- 打开/关闭状态
- [状态](../../work_items/status.md)
- [指派人](#assignees)
- [标记](../labels.md)
- [健康状态](#health-status)
- [通知](../../profile/notifications.md) 订阅
- [机密性](confidential_issues.md)
- [迭代](../../group/iterations/_index.md)
- [里程碑](../milestones/_index.md)
- 父项
- [移动到另一个项目](#move-an-issue)

<a id="move-an-issue"></a>

## 移动议题

当您移动议题时，它会被关闭并复制到目标项目。
原始议题不会被删除。两个议题上都会添加一条[系统评论](../system_notes.md)，指明其来源和去向。

极狐GitLab 还会将议题描述或评论中附加的文件复制到目标项目。由于[上传文件的作用域限定在项目内](../../../security/user_file_uploads.md)，极狐GitLab 会在目标项目中为每个副本创建新的 URL 密钥：

- 指向原始附件 URL 的直接链接会返回 `404` 错误。
- 复制的文件会列在目标项目的 [Markdown 上传](../../../api/project_markdown_uploads.md) 中，而不是源项目的。

将议题移动到具有不同访问规则的项目时请务必小心。移动议题前，请确保其不包含敏感数据。

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色。

要移动议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}}) > **移动**。
1. 搜索要将议题移动到的项目。
1. 选择 **移动**。

您还可以在评论或描述中使用 [`/move` 快速操作](../quick_actions.md#move)。

<a id="bulk-move-issues"></a>

### 批量移动议题

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="from-the-work-items-list"></a>

#### 从工作项列表

当您位于项目中时，可以同时移动多个议题。
您不能移动任务或测试用例。

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色。

要同时移动多个议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。
1. 选择 **批量编辑**。右侧会出现一个包含可编辑字段的侧边栏。
1. 选中您要移动的每个议题旁边的复选框。
1. 从 **移动** 下拉列表中，选择目标项目。
1. 选择 **移动项**。

<a id="from-the-rails-console"></a>

#### 从 Rails 控制台

您可以将一个项目中的所有打开议题移动到另一个项目。

先决条件：

- 您必须能够访问极狐GitLab 实例的 Rails 控制台。

操作步骤：

1. 可选（但建议）。在控制台中进行任何更改之前，[创建备份](../../../administration/backup_restore/_index.md)。
1. 打开 [Rails 控制台](../../../administration/operations/rails_console.md)。
1. 运行以下脚本。确保将 `project`、`admin_user` 和 `target_project` 更改为您的值。

   ```ruby
   project = Project.find_by_full_path('full path of the project where issues are moved from')
   issues = project.issues
   admin_user = User.find_by_username('username of admin user') # make sure user has permissions to move the issues
   target_project = Project.find_by_full_path('full path of target project where issues moved to')

   issues.each do |issue|
      if issue.state != "closed" && issue.moved_to.nil?
         Issues::MoveService.new(container: project, current_user: admin_user).execute(issue, target_project)
      else
         puts "issue with id: #{issue.id} and title: #{issue.title} was not moved"
      end
   end; nil
   ```

1. 要退出 Rails 控制台，请输入 `quit`。

<a id="description-lists-and-task-lists"></a>

## 描述列表和任务列表

在议题描述中使用有序列表、无序列表或任务列表时，您可以：

- 通过拖放重新排序所有列表项。
- 删除任务列表项。
- [将任务列表项转换为任务工作项](../../tasks.md#from-a-task-list-item)。

<a id="delete-a-task-list-item"></a>

### 删除任务列表项

先决条件：

- 您必须拥有项目的报告者、开发者、维护者或所有者角色，或者是议题的作者或指派人。

在包含任务列表项的议题描述中：

1. 将鼠标悬停在任务列表项上，然后选择选项菜单 ({{< icon name="ellipsis_v" >}})。
1. 选择 **删除**。

该任务列表项将从议题描述中移除。
任何嵌套的任务列表项都会上移一个嵌套级别。

<a id="reorder-list-items-in-the-issue-description"></a>

### 重新排序议题描述中的列表项

当您查看描述中包含列表的议题时，您也可以重新排序列表项。

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色，是议题的作者，或被指派到该议题。
- 议题的描述必须包含[有序、无序](../../markdown.md#lists)或[任务](../../markdown.md#task-lists)列表。

要重新排序列表项，请在查看议题时：

1. 将鼠标悬停在列表项行上，使拖动手柄图标 ({{< icon name="grip" >}}) 可见。
1. 选择并按住拖动手柄图标。
1. 将行拖到列表中的新位置。
1. 松开拖动手柄图标。

要取消重新排序，请在松开拖动手柄图标之前按 <kbd>Esc</kbd>。

<a id="close-an-issue"></a>

## 关闭议题

当您确定议题已解决或不再需要时，可以将其关闭。
该议题会被标记为已关闭，但不会被删除。

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色，是议题的作者，或被指派到该议题。

要关闭议题，您可以：

- 在[议题看板](../issue_board.md)中，将议题卡片从其列表拖到 **已关闭** 列表中。
- 从极狐GitLab UI 的任何其他页面：
  1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
  1. 选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
  1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **关闭议题**。

您还可以在评论或描述中使用 [`/close` 快速操作](../quick_actions.md#close)。

<a id="reopen-a-closed-issue"></a>

### 重新打开已关闭的议题

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色，是议题的作者，或被指派到该议题。

要重新打开已关闭的议题，请在右上角选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **重新打开议题**。
重新打开的议题与任何其他打开的议题没有区别。

您还可以在评论或描述中使用 [`/reopen` 快速操作](../quick_actions.md#reopen)。

<a id="closing-issues-automatically"></a>

### 自动关闭议题

您可以通过在提交消息或合并请求描述中使用某些词语（称为_关闭模式_）来自动关闭议题。极狐GitLab 私有化部署管理员可以[更改默认关闭模式](../../../administration/issue_closing_pattern.md)。

如果提交消息或合并请求描述包含与[关闭模式](#default-closing-pattern)匹配的文本，则匹配文本中引用的所有议题将在以下任一情况下关闭：

- 提交被推送到项目的 [**默认** 分支](../repository/branches/default.md)。
- 提交或合并请求被合并到默认分支。

例如，如果您在合并请求描述中包含 `Closes #4, #6, Related to #5`：

- 当合并请求被合并时，议题 `#4` 和 `#6` 会自动关闭。
- 议题 `#5` 会被标记为[相关议题](related_issues.md)，但不会自动关闭。

或者，当您[从议题创建合并请求](../merge_requests/creating_merge_requests.md#from-an-issue)时，它会继承该议题的里程碑和标记。

出于性能原因，对于现有代码仓库的首次推送，自动关闭议题功能会被禁用。

<a id="user-responsibility-when-merging"></a>

#### 合并时的用户责任

当您合并合并请求时，您有责任检查关闭任何目标议题是否合适。用户可以在合并请求描述以及提交消息正文中包含议题关闭模式。提交消息中的关闭消息很容易被忽略。在这两种情况下，合并请求小组件都会在合并时显示有关要关闭的议题的信息：

![此合并请求关闭议题 #2754。](img/closing_pattern_v17_4.png)

当您合并合并请求时，极狐GitLab 会检查您是否有权限关闭目标议题。在公共代码仓库中，此检查非常重要，因为外部用户可以创建包含关闭模式的合并请求和提交。当您是执行合并的用户时，务必了解合并对项目中代码和议题的影响。

当为合并请求启用[自动合并](../merge_requests/auto_merge.md)时，无法再更改将自动关闭的议题列表。

<a id="default-closing-pattern"></a>

#### 默认关闭模式

要自动关闭议题，请使用以下关键字，后跟议题引用。

可用关键字：

- `Close`, `Closes`, `Closed`, `Closing`, `close`, `closes`, `closed`, `closing`
- `Fix`, `Fixes`, `Fixed`, `Fixing`, `fix`, `fixes`, `fixed`, `fixing`
- `Resolve`, `Resolves`, `Resolved`, `Resolving`, `resolve`, `resolves`, `resolved`, `resolving`
- `Implement`, `Implements`, `Implemented`, `Implementing`, `implement`, `implements`, `implemented`, `implementing`

可用的议题引用格式：

- 本地议题 (`#123`)。
- 跨项目议题 (`group/project#123`)。
- 议题的完整 URL (`https://gitlab.example.com/<project_full_path>/-/issues/123`)。
- 工作项（例如任务、目标或关键结果）的完整 URL：
  - 在项目中 (`https://gitlab.example.com/<project_full_path>/-/work_items/123`)。
  - 在群组中 (`https://gitlab.example.com/groups/<group_full_path>/-/work_items/123`)。

例如：

```plaintext
Awesome commit message

Fix #20, Fixes #21 and Closes group/otherproject#22.
This commit is also related to #17 and fixes #18, #19
and https://gitlab.example.com/group/otherproject/-/issues/23.
```

之前的提交消息会关闭提交推送到的项目中的 `#18`、`#19`、`#20` 和 `#21`，以及 `group/otherproject` 中的 `#22` 和 `#23`。`#17` 不会被关闭，因为它不匹配该模式。

您可以在多行提交消息或使用 `git commit -m` 从命令行执行的一行提交消息中使用关闭模式。

默认议题关闭模式正则表达式：

```shell
\b((?:[Cc]los(?:e[sd]?|ing)|\b[Ff]ix(?:e[sd]|ing)?|\b[Rr]esolv(?:e[sd]?|ing)|\b[Ii]mplement(?:s|ed|ing)?)(:?) +(?:(?:issues? +)?%{issue_ref}(?:(?: *,? +and +| *,? *)?)|([A-Z][A-Z0-9_]+-\d+))+)
```

<a id="disable-automatic-issue-closing"></a>

#### 禁用自动关闭议题

您可以在[项目设置](#disable-automatic-issue-closing)中按项目禁用自动关闭议题功能。

先决条件：

- 您必须拥有项目的维护者或所有者角色。

要禁用自动关闭议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓库**。
1. 展开 **分支默认设定**。
1. 清除 **在默认分支上自动关闭引用的议题** 复选框。
1. 选择 **保存更改**。

被引用的议题仍会显示，但不会自动关闭。

更改此设置仅适用于新的合并请求或提交。已关闭的议题保持原样。
禁用自动关闭议题仅适用于在禁用该设置的项目中的议题。此项目中的合并请求和提交仍然可以关闭另一个项目的议题。

<a id="customize-the-issue-closing-pattern"></a>

#### 自定义议题关闭模式

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须对您的极狐GitLab 实例拥有[管理员访问权限](../../../administration/_index.md)。

了解如何更改安装的默认[议题关闭模式](../../../administration/issue_closing_pattern.md)。

<a id="prevent-truncating-descriptions-with-read-more"></a>

## 防止描述被 **阅读更多** 截断

如果议题描述很长，极狐GitLab 只显示其中的一部分。
要查看完整描述，您必须选择 **阅读更多**。
这种截断使您无需滚动长文本即可更轻松地找到页面上的其他元素。

要更改描述是否被截断：

1. 在议题上，在右上角选择 **更多操作** ({{< icon name="ellipsis_v" >}})。
1. 根据您的偏好切换 **截断描述**。

此设置会被记住，并影响所有议题、任务、史诗、目标和关键结果。

<a id="hide-the-right-sidebar"></a>

## 隐藏右侧边栏

当空间允许时，议题属性会显示在描述右侧的边栏中。

要隐藏侧边栏并为描述增加空间：

1. 在议题上，在右上角选择 **更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **隐藏侧边栏**。

此设置会被记住，并影响所有议题、任务、史诗、目标和关键结果。

要再次显示侧边栏：

- 重复上述步骤并选择 **显示侧边栏**。

<a id="delete-an-issue"></a>

## 删除议题

先决条件：

- 您必须拥有项目的计划者或所有者角色。

要删除议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **删除议题**。

<a id="change-the-issue-type"></a>

## 更改议题类型

先决条件：

- 您必须是议题作者，或拥有项目的计划者、报告者、开发者、维护者或所有者角色，是议题的作者，或被指派到该议题。

要更改议题类型：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **更改类型**。
1. 从 **类型** 下拉列表中选择新类型：

   - 关键结果
   - 目标
   - 任务
   - 史诗（将议题移动到父群组）
     有关更多信息，请参阅[将议题升级为史诗](#promote-an-issue-to-an-epic)。

1. 选择 **更改类型**。

要将议题升级为事件，请参阅[将议题升级为事件](#promote-an-issue-to-an-incident)

<a id="promote-an-issue-to-an-epic"></a>

### 将议题升级为史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将议题升级为直接父群组中的[史诗](../../group/epics/_index.md)。

将机密议题升级为史诗会创建[机密史诗](../../group/epics/manage_epics.md#make-an-epic-confidential)，并保留机密性。

当议题升级为史诗时：

- 会在议题项目所在的群组中创建一个史诗。
- 议题的订阅者会收到已创建史诗的通知。

以下议题元数据会复制到史诗：

- 标题、描述、活动和评论讨论串。
- 赞同和反对。
- 参与者。
- 议题拥有的群组标记。
- 父项。

先决条件：

- 议题所属的项目必须位于群组中。
- 您必须拥有项目直接父群组的计划者、报告者、开发者、维护者或所有者角色。
- 您必须满足以下条件之一：
  - 拥有项目的计划者、报告者、开发者、维护者或所有者角色。
  - 是议题的作者。
  - 被指派到该议题。

要将议题升级为史诗：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选，并选择您的议题。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **更改类型**
1. 从 **类型** 下拉列表中选择 **史诗**。
1. 选择 **更改类型**。

或者，您可以使用 [`/promote_to Epic` 快速操作](../quick_actions.md#promote_to)。

<a id="promote-an-issue-to-an-incident"></a>

### 将议题升级为事件

您可以使用 [`/promote_to Incident` 快速操作](../quick_actions.md#promote_to) 将议题升级为[事件](../../../operations/incident_management/incidents.md)。

<a id="add-an-issue-to-an-iteration"></a>

## 将议题添加到迭代

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要将议题添加到[迭代](../../group/iterations/_index.md)：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右侧边栏的 **迭代** 部分，选择 **编辑**。
1. 从下拉列表中，选择要将此议题添加到的迭代。
1. 选择下拉列表外部的任何区域。

要将议题添加到迭代，您还可以：

- 使用 [`/iteration` 快速操作](../quick_actions.md#iteration)。
- 在看板中将议题拖入迭代列表。
- 从 **工作项** 列表批量编辑议题。

<a id="view-all-issues-assigned-to-you"></a>

## 查看分配给您的所有议题

要查看分配给您的所有议题：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 从下拉列表中，选择 **分配给我的议题**。

或者：

- 要使用[键盘快捷键](../../shortcuts.md)，请按 <kbd>Shift</kbd>+<kbd>i</kbd>。
- 在右上角，选择 **分配给我的工作项** ({{< icon name="work-items" >}})。

<a id="issue-list"></a>

## 议题列表

议题列表显示您的项目或群组中的所有议题。
您可以使用它来查看、排序和管理议题。

要查看议题列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。

要设置 **工作项** 列表中显示的属性，请[配置显示偏好](../../work_items/_index.md#configure-list-display-preferences)。

从议题列表中，您可以：

- 查看议题详细信息，如标题、指派人、标记和里程碑。
- 按各种条件[对议题排序](sorting_issue_lists.md)。
- 筛选议题以查找特定议题。
- 单独或批量编辑议题。
- 创建新议题。

以下部分介绍如何使用议题列表。

<a id="filter-the-list-of-issues"></a>

### 筛选议题列表

要筛选议题列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。
1. 根据需要选择其他筛选器、运算符和值。
   以下筛选器可用：
   - 指派人
   - 作者
   - 机密
   - [联系人](../../crm/_index.md)
   - [健康](#health-status)
   - 迭代
   - 标记
   - 里程碑
   - 我的反应
   - [组织](../../crm/_index.md)
   - [父项](../../group/epics/_index.md)
   - 版本
   - 搜索范围（标题或描述）
   - 状态
   - 已订阅
   - 类型
   - 权重
   - [自定义字段](../../work_items/custom_fields.md)
1. 选择或输入用于筛选属性的运算符。以下运算符可用：
   - `=`：是
   - `!=`：不是其中之一
   - `||`：是其中之一（适用于指派人、作者、标记、类型）。
     类似于包含性 OR。
     例如，如果您按 `Assignee is one of Sidney Jones` 和 `Assignee is one of Zhang Wei` 筛选，极狐GitLab 会显示指派人包含 `Sidney`、`Zhang` 或两者的议题。
1. 输入用于筛选属性的文本。
   您可以通过 **无** 或 **任意** 筛选某些属性。
1. 重复此过程以按多个属性筛选。多个属性通过逻辑 `AND` 连接。
1. 按 <kbd>Enter</kbd> 或选择搜索图标 ({{< icon name="search" >}})。

<a id="filter-by-title-or-description"></a>

#### 按标题或描述筛选

要按标题或描述中的文本筛选议题列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。
1. 在筛选栏中，输入您的搜索短语。
1. 在出现的下拉列表中，选择 **搜索此文本**。
1. 按 <kbd>Enter</kbd> 或选择搜索图标 ({{< icon name="search" >}})。

筛选议题使用 [PostgreSQL 全文搜索](https://www.postgresql.org/docs/16/textsearch-intro.html) 来匹配有意义且重要的词语以回答查询。

例如，如果您搜索 `I am securing information for M&A`，极狐GitLab 可以返回标题或描述中包含 `securing`、`secured` 或 `information` 的结果。但是，极狐GitLab 不会精确匹配该句子或词语 `I`、`am` 或 `M&A`，因为它们不被视为在词汇上有意义或重要。这是 PostgreSQL 全文搜索的一个限制。

<a id="filter-issues-by-id"></a>

#### 按 ID 筛选议题

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选。
1. 在筛选栏中，输入 `#` 后跟议题 ID。
   例如，输入 `#362255` 以仅返回议题 362255。
1. 选择 **搜索此文本**。
1. 按 <kbd>Enter</kbd> 或选择搜索图标 ({{< icon name="search" >}})。

<a id="open-issues-in-a-panel"></a>

### 在面板中打开议题

当您从列表或议题看板中选择一个议题时，它会在详细信息面板中打开。

然后您可以查看和编辑其详细信息，而不会丢失列表或看板的上下文。

使用面板时：

- 从列表中选择一个议题以在面板中打开它。
- 面板出现在屏幕右侧。
- 您可以直接在面板中编辑议题。
- 要关闭面板，请选择关闭图标 ({{< icon name="close" >}}) 或按 **Escape**。

<a id="open-an-issue-in-full-page-view"></a>

#### 在完整页面视图中打开议题

要以完整视图打开议题：

- 在新标签页中打开议题。从议题列表中，执行以下任一操作：
  - 右键单击议题并在新的浏览器标签页中打开。
  - 按住 <kbd>Command</kbd> 或 <kbd>Control</kbd> 并选择该议题。
- 选择一个议题，然后从面板中，执行以下任一操作：
  - 在左上角，选择议题引用，例如 `my_project#123`。
  - 在右上角，选择 **在完整页面中打开** ({{< icon name="maximize" >}})。

要始终在完整页面视图中打开议题，请[配置您的列表显示偏好](../../work_items/_index.md#configure-list-display-preferences)。

<a id="copy-issue-reference"></a>

## 复制议题引用

要在极狐GitLab 的其他位置引用议题，您可以使用其完整 URL 或短引用，其格式类似于 `namespace/project-name#123`，其中 `namespace` 是群组或用户名。

要将议题引用复制到剪贴板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}}) > **复制引用**。

您现在可以将引用粘贴到另一个描述或评论中。

有关更多信息，请参阅[极狐GitLab 特定引用](../../markdown.md#gitlab-specific-references)。

<a id="copy-issue-email-address"></a>

## 复制议题电子邮件地址

您可以通过发送电子邮件在议题中创建评论。
向此地址发送电子邮件会创建一条包含电子邮件正文的评论。

有关通过发送电子邮件创建评论以及必要配置的更多信息，请参阅[通过发送电子邮件回复评论](../../discussions/_index.md#reply-to-a-comment-by-sending-email)。

要复制议题的电子邮件地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}}) > **复制议题电子邮件地址**。

<a id="assignees"></a>

## 指派人

一个议题可以分配给一个或[多个用户](multiple_assignees_for_issues.md)。

指派人可以根据需要随时更改。其理念是，指派人是对议题负责的人员。
当议题分配给某人时，它会出现在他们的 **分配给我的工作项** 页面中。

如果用户不是项目成员，则只有在该用户自己创建议题或另一个项目成员指派他们时，才能将议题分配给他们。

<a id="change-assignee-on-an-issue"></a>

### 更改议题的指派人

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色。

要更改议题的指派人：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右侧边栏的 **指派人** 部分，选择 **编辑**。
1. 从下拉列表中，选择要添加为指派人的用户。
1. 选择下拉列表外部的任何区域。

指派人会立即更改，无需刷新页面。

<a id="similar-issues"></a>

## 相似议题

为防止相同主题的议题重复，当您创建新议题时，极狐GitLab 会搜索相似议题。

当您在 **新议题** 页面的标题文本框中输入时，极狐GitLab 会搜索当前项目中所有议题的标题和描述。仅返回您有权访问的议题。标题文本框下方最多显示五个相似议题，按最近更新时间排序。

<a id="health-status"></a>

## 健康状态

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为了更好地跟踪实现计划的风险，您可以为每个议题分配健康状态。您可以使用健康状态向组织中的其他人表明议题是否按计划进行，或是否需要关注以保持进度。

将议题健康状态审查纳入您的每日站会、项目状态报告或每周会议中，以应对按时交付计划工作的风险。

<a id="change-health-status-of-an-issue"></a>

### 更改议题的健康状态

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色。

要编辑议题的健康状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右侧边栏的 **健康状态** 部分，选择 **编辑**。
1. 从下拉列表中，选择要添加到此议题的状态：

   - 按计划进行
   - 需要关注
   - 有风险

您可以在以下位置查看议题的健康状态：

- **工作项** 列表
- 史诗的 **子项** 部分
- 议题看板中的议题卡片

议题关闭后，其健康状态无法编辑，**编辑** 按钮将变为禁用状态，直到议题重新打开。

您还可以使用 [`/health_status`](../quick_actions.md#health_status) 和 [`/clear_health_status`](../quick_actions.md#clear_health_status) 快速操作来设置和清除健康状态。

<a id="status"></a>

## 状态

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<!-- Turn off the future tense test because of "won't do". -->
<!-- vale gitlab_base.FutureTense = NO -->

您可以为议题分配状态，以跟踪其在工作流中的进度。
状态比基本的打开/关闭状态提供更细粒度的跟踪，因此您可以使用 **进行中**、**已完成** 或 **不执行** 等特定阶段。

有关如何配置自定义状态的更多信息，请参阅[状态部分](../../work_items/status.md)。

<!-- vale gitlab_base.FutureTense = YES -->

<a id="change-status"></a>

### 更改状态

先决条件：

- 您必须拥有项目的计划者、报告者、开发者、维护者或所有者角色，是议题的作者，或被指派到该议题。

要更改议题的状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在右侧边栏的 **状态** 部分，选择 **编辑**。
1. 从下拉列表中，选择状态。

议题的状态会立即更新。

您可以在以下位置查看议题的状态：

- **工作项** 列表
- 史诗的 **子项** 部分
- 议题看板上的卡片

您还可以使用 [`/status` 快速操作](../quick_actions.md#status) 来设置状态。

<a id="participants"></a>

## 参与者

参与者是与议题交互过的用户。
有关查看参与者的信息，请参阅[参与者](../../participants.md)。

<a id="publish-an-issue"></a>

## 发布议题

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

如果项目关联了状态页应用程序，您可以使用 [`/publish` 快速操作](../quick_actions.md#publish) 来发布议题。

有关更多信息，请参阅[极狐GitLab 状态页](../../../operations/incident_management/status_page.md)。

<a id="issue-related-quick-actions"></a>

## 议题相关快速操作

您还可以使用快速操作来管理议题。

某些操作还没有对应的 UI 按钮。
您**只能通过快速操作**执行以下操作：

- [添加或移除 Zoom 会议](associate_zoom_meeting.md) ([`/zoom` 和 `/remove_zoom`](../quick_actions.md#zoom))。
- [发布议题](#publish-an-issue) ([`/publish`](../quick_actions.md#publish))。
- 将议题克隆到相同或其他项目 ([`/clone`](../quick_actions.md#clone))。
- 关闭议题并将其标记为另一个议题的重复项 ([`/duplicate`](../quick_actions.md#duplicate))。
- 从项目中的另一个合并请求或议题复制标记和里程碑 ([`/copy_metadata`](../quick_actions.md#copy_metadata))。
