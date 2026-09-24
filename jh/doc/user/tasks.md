---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 任务
description: Task labels, confidential tasks, linked items, and task weights.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 14.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/334812)，带有一个名为 `work_items` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 15.0 中[引入](https://gitlab.com/groups/gitlab-org/-/epics/7169)了创建、编辑和删除任务的功能。
- 在极狐GitLab 15.3 中于 JihuLab.com 和私有化部署上[启用](https://gitlab.com/gitlab-org/gitlab/-/issues/334812)。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 有关更多信息，请参见历史记录。

极狐GitLab 中的任务是一种计划项，可以在议题中创建。
使用任务可将[议题](project/issues/_index.md)中捕获的用户故事分解为更小、可跟踪的条目。

在为议题做计划时，你需要一种方法来捕获并分解完成它所需的技术要求或步骤。与任务关联的议题定义得更清晰，因此你可以提供更准确的议题权重和完成标准。

有关更新，请查看[任务路线图](https://gitlab.com/groups/gitlab-org/-/epics/7103)。

任务是工作项的一种类型，是极狐GitLab 迈向[默认议题类型](https://gitlab.com/gitlab-org/gitlab/-/issues/323404)的一步。
有关将议题和[史诗](group/epics/_index.md)迁移到工作项以及添加自定义工作项类型的路线图，请参见
[史诗 6033](https://gitlab.com/groups/gitlab-org/-/epics/6033) 或
[计划方向页面](https://about.gitlab.com/direction/plan/)。

<a id="view-tasks"></a>

## 查看任务

在议题的 **子项** 部分查看任务。

你也可以[过滤工作项列表](work_items/_index.md#filter-work-items)，筛选 `类型 = 任务`。

当你从议题或 **工作项** 列表中选择一个任务时，它会在屏幕右侧的详情面板中打开。在较小的屏幕上，此面板会覆盖页面。

要在全页面视图中打开任务：

- 通过右键单击任务，或按住 <kbd>Command</kbd> 或 <kbd>Control</kbd> 并选择它，在新建浏览器标签页中打开。
- 在详情面板的右上角，选择 **全页打开**（{{< icon name="maximize" >}}）。

<a id="create-a-task"></a>

## 创建任务

{{< history >}}

- 在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/436255)了选择创建任务项目的选项。

{{< /history >}}

前置条件：

- 你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色，或者项目必须是公开的。

要创建任务：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 在右上角，选择 **新建项**。
1. 从 **类型** 下拉列表中，如果尚未选择，则选择 **任务**。
1. 完成以下内容：
   - 输入任务标题。
   - 输入任务描述。
   - 可选。在对话框侧边栏中，为新建任务选择一个 **父级** [项目](project/organize_work_with_projects.md)。
1. 选择 **创建任务**。

<a id="from-a-task-list-item"></a>

### 从任务列表项创建

{{< history >}}

- 在极狐GitLab 15.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/377307)。

{{< /history >}}

前置条件：

- 你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色。

要将议题描述中的任务列表项转换为任务：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **议题** 并选择你的议题。
1. 在议题描述中，将鼠标悬停在任务列表项上并选择选项菜单（{{< icon name="ellipsis_v" >}}）。
1. 选择 **转换为子项**。
1. 可选。编辑任务标题并添加描述。
1. 选择 **创建任务**。

任务列表项已从议题描述中移除，并添加到 **子项** 部分。
任何嵌套的任务列表项都会向上移动一个嵌套级别。

<a id="add-existing-tasks-to-an-issue"></a>

## 将现有任务添加到议题

{{< history >}}

- 在极狐GitLab 15.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/381868)。

{{< /history >}}

前置条件：

- 你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色，或者项目必须是公开的。

要将现有任务添加到议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **议题** 并选择你的议题。
1. 在议题描述的 **子项** 部分，选择 **添加**（{{< icon name="plus" >}}）。
1. 选择 **现有任务**。
1. 按标题搜索任务。
1. 选择一个或多个任务以添加到议题。
1. 选择 **添加任务**。

<a id="edit-a-task"></a>

## 编辑任务

{{< history >}}

- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

要编辑任务：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右上角，选择 **编辑**。
1. 可选。要编辑标题，在 **标题** 文本框中键入内容。
1. 可选。要编辑描述，对 **描述** 文本框进行更改。
1. 选择 **保存更改**。
1. 选择关闭图标（{{< icon name="close" >}}）。

<a id="using-the-rich-text-editor"></a>

### 使用富文本编辑器

{{< history >}}

- 在极狐GitLab 15.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/363007)了对话框视图中的富文本编辑功能，带有一个名为 `work_items_mvc` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 15.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/104533)了全页面视图中的富文本编辑功能。
- 在极狐GitLab 16.2 中[正式发布](https://gitlab.com/groups/gitlab-org/-/epics/10378)。功能标志 `work_items_mvc` 已移除。
- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

使用富文本编辑器编辑任务描述。

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

要编辑任务描述：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右上角，选择 **编辑**。
1. 在 **描述** 文本框底部，选择 **切换到富文本编辑**。
   如果控件显示 **切换到纯文本编辑**，则文本框已处于富文本模式。
1. 进行更改并选择 **保存**。

<a id="promote-a-task-to-an-issue"></a>

## 将任务提升为议题

{{< history >}}

- 在极狐GitLab 16.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/412534)。
- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

要将任务提升为议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 解除父级议题的关联并提升任务：在任务窗口中，于单独的评论中使用以下两个[快速操作](project/quick_actions.md)：

   ```plaintext
   /remove_parent
   ```

   ```plaintext
   /promote_to issue
   ```

任务将转换为议题。包含 `/work_items/` 的先前 URL 仍然有效。

<a id="convert-a-task-into-another-item-type"></a>

## 将任务转换为其他项类型

{{< history >}}

- 在极狐GitLab 17.8 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/385131)，带有一个名为 `work_items_beta` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- [移至](https://gitlab.com/gitlab-org/gitlab/-/issues/385131)名为 `okrs_mvc` 的[功能标志](../administration/feature_flags/_index.md)。有关当前标志状态，请参阅本页面顶部。

{{< /history >}}

将任务转换为其他项类型，例如：

- 议题
- 目标
- 关键结果

> [!warning]
> 如果目标类型不支持原始类型的所有字段，更改类型可能会导致数据丢失。

前置条件：

- 要转换的任务不能分配有父项。

要将任务转换为其他项类型：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 可选。如果任务分配了父级议题，则移除它。
   使用 `/remove_parent` 快速操作向任务添加评论。
1. 在右上角，选择 **更多操作**（{{< icon name="ellipsis_v" >}}），然后选择 **更改类型**。
1. 选择所需的项类型。
1. 如果满足所有条件，选择 **更改类型**。

或者，你可以在评论中使用 [`/type` 快速操作](project/quick_actions.md#type)，后跟 `issue`、`objective` 或 `key result`。

<a id="remove-a-task-from-an-issue"></a>

## 从议题中移除任务

{{< history >}}

- 在极狐GitLab 17.0 中[更改](https://gitlab.com/gitlab-org/gitlab/-/issues/404799)了最低所需角色，从报告者改为访客。

{{< /history >}}

前置条件：

- 你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色。

你可以从议题中移除任务而不删除它。
要重新连接它们，请参见[将议题设置为父级](#set-an-issue-as-a-parent)。

要使用 **子项** 部分从议题中移除任务：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **议题** 并选择你的议题。
1. 在议题描述的 **子项** 部分，选择要移除的任务旁边的选项菜单（{{< icon name="ellipsis_v" >}}）。
1. 选择 **移除任务**。

要使用任务详情面板从议题中移除任务：

1. 选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏中，在 **父级** 旁边，选择 **编辑**。
1. 在下拉列表的右上角，选择 **清除**。

<a id="delete-a-task"></a>

## 删除任务

{{< history >}}

- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从所有者改为计划者。

{{< /history >}}

前置条件：

- 你必须满足以下任一条件：
  - 是任务作者并具有项目的访客、报告者、开发者或维护者角色。
  - 具有项目的计划者或所有者角色。

要删除任务：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **删除任务**。
1. 在确认对话框中，选择 **删除任务**。

<a id="reorder-tasks"></a>

## 重新排序任务

{{< history >}}

- 在极狐GitLab 16.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/385887)。
- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

默认情况下，任务按创建日期排序。
要在议题的 **子项** 部分中对它们重新排序，将它们拖动到所需的顺序。

要在 **工作项** 列表中对任务排序：

1. 在筛选栏右侧，选择 **创建日期** 下拉列表。
1. 选择排序条件：

   - 优先级
   - 创建日期
   - 更新日期
   - 关闭日期
   - 里程碑截止日期
   - 截止日期
   - 热门程度
   - 标签优先级
   - 手动（将项目拖动到首选顺序；排序方向将被忽略）
   - 标题
   - 开始日期

1. 要在升降序之间切换，选择 **排序方向**（{{< icon name="sort-lowest" >}} 或 {{< icon name="sort-highest" >}}）。

<a id="change-status"></a>

## 更改状态

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/543862)，带有一个名为 `work_item_status_feature_flag` 的[功能标志](../administration/feature_flags/_index.md)，默认启用。
- 在极狐GitLab 18.4 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/521286)。功能标志 `work_item_status_feature_flag` 已移除。

{{< /history >}}

<!-- Turn off the future tense test because of "won't do". -->
<!-- vale gitlab_base.FutureTense = NO -->

你可以为任务分配状态，以跟踪其在你工作流程中的进展。状态提供了比基本开启/关闭状态更精细的跟踪，允许你使用特定阶段，如 **进行中**、**已完成** 或 **不做**。
<!-- vale gitlab_base.FutureTense = YES -->

有关状态的更多信息，包括如何配置自定义状态，请参见[状态](work_items/status.md)。

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色，或者是任务作者，或被分配到任务。

要更改任务的状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **状态** 部分，选择 **编辑**。
1. 从下拉列表中，选择状态。

任务的状态会立即更新。

你也可以使用 [`/status` 快速操作](project/quick_actions.md#status)来设置状态。

<a id="assign-users-to-a-task"></a>

## 分配用户到任务

{{< history >}}

- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

要显示谁负责任务，你可以为其分配用户。

极狐GitLab 基础版的用户每个任务可分配一名用户。
极狐GitLab 专业版和旗舰版的用户可以为单个任务分配多名用户。
另请参见[议题的多指派人](project/issues/multiple_assignees_for_issues.md)。

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

要更改任务的指派人：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **指派人** 部分，选择 **编辑**。
1. 从下拉列表中，选择要添加为指派人的用户。
1. 选择下拉列表外的任意区域。

<a id="assign-labels-to-a-task"></a>

## 分配标签到任务

{{< history >}}

- 在极狐GitLab 15.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/339756)。
- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

要向任务添加[标签](project/labels.md)：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **标签** 部分，选择 **编辑**。
1. 从下拉列表中，选择要添加的标签。
1. 选择下拉列表外的任意区域。

<a id="set-a-start-and-due-date"></a>

## 设置开始和截止日期

{{< history >}}

- 在极狐GitLab 15.4 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/365399)，带有一个名为 `work_items_mvc_2` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 15.5 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/365399)。功能标志 `work_items_mvc_2` 已移除。
- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

你可以为任务设置[开始和截止日期](project/issues/due_dates.md)。

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

你可以在任务上设置开始和截止日期，以显示工作应何时开始和结束。

要设置开始或截止日期：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **日期** 部分，选择 **编辑**。
1. 可选。在 **开始日期** 选择器中，选择一个日期。
1. 可选。在 **截止日期** 选择器中，选择一个日期。
   截止日期必须与开始日期相同或晚于开始日期。
1. 选择 **应用**。

<a id="add-a-task-to-a-milestone"></a>

## 将任务添加到里程碑

{{< history >}}

- 在极狐GitLab 15.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/367463)，带有一个名为 `work_items_mvc_2` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 15.7 中[移至](https://gitlab.com/gitlab-org/gitlab/-/issues/367463)名为 `work_items_mvc` 的功能标志，默认禁用。
- 在极狐GitLab 15.7 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/367463)。功能标志 `work_items_mvc` 已移除。
- 在极狐GitLab 17.7 中[更改](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/169256)了最低用户角色，从报告者改为计划者。

{{< /history >}}

你可以将任务添加到[里程碑](project/milestones/_index.md)。
当你查看任务时可以看到里程碑标题。
如果你为已属于一个里程碑的议题创建任务，新任务会继承该里程碑。

前置条件：

- 你必须具有项目的计划者、报告者、开发者、维护者或所有者角色。

要将任务添加到里程碑：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **里程碑** 部分，选择 **编辑**。
1. 从下拉列表中，选择里程碑。
   如果任务已经属于一个里程碑，下拉列表会显示当前里程碑。
1. 选择下拉列表外的任意区域。

<a id="set-task-weight"></a>

## 设置任务权重

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/362550)。
- 在极狐GitLab 16.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429137)了编辑按钮。

{{< /history >}}

前置条件：

- 你必须具有项目的报告者、开发者、维护者或所有者角色。

你可以为每个任务设置权重，以显示它所需的工作量。
此值仅在你查看任务时可见。

要设置任务的议题权重：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **权重** 部分，选择 **编辑**。
1. 输入一个正整数。
1. 选择 **应用** 或按 <kbd>Enter</kbd>。

<a id="view-count-and-weight-of-tasks-in-the-parent-issue"></a>

### 在父议题中查看任务的数量和权重

{{< history >}}

- 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)，带有一个名为 `use_cached_rolled_up_weights` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 18.4 中[于 JihuLab.com 启用](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)。
- 在极狐GitLab 18.6 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)。功能标志 `use_cached_rolled_up_weights` 已移除。

{{< /history >}}

子任务的数量及其总权重显示在议题描述的 **子项** 部分标题中。

要查看打开和关闭的任务数量：

- 在部分标题中，将鼠标悬停在总数上。

这些数字反映了与议题关联的所有子任务，包括你可能没有权限查看的任务。

<a id="view-progress-of-the-parent-issue"></a>

### 查看父议题的进度

{{< history >}}

- 在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)，带有一个名为 `use_cached_rolled_up_weights` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 18.4 中[于 JihuLab.com 启用](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)。
- 在极狐GitLab 18.6 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/520886)。功能标志 `use_cached_rolled_up_weights` 已移除。

{{< /history >}}

议题进展百分比显示在议题描述的 **子项** 部分标题中。

要查看子任务的已完成和总权重：

- 在部分标题中，将鼠标悬停在百分比上。

权重和进度反映了与议题关联的所有任务，包括你可能没有权限查看的任务。

<a id="add-a-task-to-an-iteration"></a>

## 将任务添加到迭代

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/367456)，带有一个名为 `work_items_mvc_2` 的[功能标志](../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 15.7 中[移至](https://gitlab.com/gitlab-org/gitlab/-/issues/367456)名为 `work_items_mvc` 的功能标志，默认禁用。
- 在极狐GitLab 15.7 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/367456)。功能标志 `work_items_mvc` 已移除。

{{< /history >}}

你可以将任务添加到[迭代](group/iterations/_index.md)。
你只有在查看任务时才能看到迭代标题和周期。

前置条件：

- 你必须具有项目的报告者、开发者、维护者或所有者角色。

要将任务添加到迭代：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后筛选 **类型** = **任务** 并选择你的任务。
1. 在右侧边栏的 **迭代** 部分，选择 **编辑**。
1. 从下拉列表中，选择要与任务关联的迭代。
1. 选择下拉列表外的任意区域。

<a id="estimate-and-track-spent-time"></a>

## 估算和跟踪花费的时间

{{< history >}}

- 在极狐GitLab 17.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/438577)。

{{< /history >}}

你可以估算和跟踪在任务上花费的时间。

有关更多信息，请参见[时间跟踪](project/time_tracking.md)。

<a id="prevent-truncating-descriptions-with-read-more"></a>

## 使用 **阅读更多** 防止描述被截断

{{< history >}}

- 在极狐GitLab 17.10 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181184)。

{{< /history >}}

如果任务描述很长，极狐GitLab 仅显示其中的一部分。
要查看完整描述，你必须选择 **阅读更多**。
此截断使无需滚动过长的文本即可更轻松地找到页面上的其他元素。

要更改是否截断描述：

1. 在任务上，在右上角选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 根据你的偏好切换 **截断描述**。

此设置会被记住并影响所有议题、任务、史诗、目标和关键结果。

<a id="hide-the-right-sidebar"></a>

## 隐藏右侧边栏

{{< history >}}

- 在极狐GitLab 17.10 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/181184)。

{{< /history >}}

任务属性在空间允许时显示在描述右侧的边栏中。
要隐藏边栏并为描述增加空间：

1. 在任务上，在右上角选择 **更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择 **隐藏边栏**。

此设置会被记住并影响所有议题、任务、史诗、目标和关键结果。

要再次显示边栏：

- 重复上述步骤并选择 **显示边栏**。

<a id="view-task-system-notes"></a>

## 查看任务系统笔记

{{< history >}}
{{< history >}}

- 在 GitLab 15.7 中引入，使用名为 `work_items_mvc_2` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 在 GitLab 15.8 中，功能标志名称更改为 `work_items_mvc`。默认禁用。
- 在 GitLab 15.8 中，引入了更改活动排序顺序的功能。
- 在 GitLab 15.10 中，引入了筛选活动的功能。
- 在 GitLab 15.10 中 GA。功能标志 `work_items_mvc` 已移除。

{{< /history >}}

你可以查看与该任务相关的所有系统笔记。默认按 **最旧优先** 排序。你可以随时将排序顺序更改为 **最新优先**，该设置会在会话间保留。除了默认的 **所有活动** 外，你还可以按 **仅评论** 和 **仅历史记录** 筛选活动，该设置也会在会话间保留。

## 评论和话题

你可以在任务中添加[评论](discussions/_index.md)并回复话题。

## 复制任务引用

{{< history >}}

- 在 GitLab 16.1 中引入。

{{< /history >}}

要在极狐GitLab 的其他地方引用任务，你可以使用其完整 URL 或简短引用，如 `namespace/project-name#123`，其中 `namespace` 是群组或用户名。

要将任务引用复制到剪贴板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择你的任务。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **复制引用**。

你现在可以将引用粘贴到另一个描述或评论中。

有关任务引用的更多信息，请参阅 [极狐GitLab 风格的 Markdown](markdown.md#gitlab-specific-references)。

## 复制任务电子邮件地址

{{< history >}}

- 在 GitLab 16.1 中引入。

{{< /history >}}

你可以通过发送电子邮件在任务中创建评论。向此地址发送电子邮件会创建一条包含电子邮件正文的评论。

有关通过发送电子邮件创建评论以及必要配置的更多信息，请参阅[通过发送电子邮件回复评论](discussions/_index.md#reply-to-a-comment-by-sending-email)。

要复制任务的电子邮件地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择你的任务。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **复制任务电子邮件地址**。

## 将议题设置为父项

{{< history >}}

- 在 GitLab 16.5 中引入。

{{< /history >}}

先决条件：

- 你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色。
- 议题和任务必须属于同一项目。

要将议题设置为任务的父项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择你的任务。
1. 在右侧边栏的 **父项** 部分，选择 **编辑**。
1. 从下拉列表中，选择要添加的父项。
1. 选择下拉列表外的任何区域。

要移除任务的父项：

1. 在 **父项** 部分，选择 **编辑**。
1. 在下拉列表的右上角，选择 **清除**。
1. 选择下拉列表外的任何区域。

## 参与者

参与者是与任务交互过的用户。有关查看参与者的信息，请参阅[参与者](participants.md)。

## 机密任务

{{< history >}}

- 在 GitLab 15.3 中引入。

{{< /history >}}

机密任务仅对具有[足够权限](#who-can-see-confidential-tasks)的项目成员可见。你可以使用机密任务来保持安全漏洞的私密性或防止意外泄露。

### 将任务设为机密

默认情况下，任务是公开的。你可以在创建或编辑任务时将其设为机密。

先决条件：

- 你必须具有项目的报告者、开发者、维护者或所有者角色。
- 如果任务有一个非机密的父议题，并且你想将该议题设为机密，则必须首先将所有子任务设为机密。一个[机密议题](project/issues/confidential_issues.md)只能包含机密子项。

#### 在新任务中

当你创建新任务时，文本区域下方有一个复选框可用于将任务标记为机密。选中该框并选择 **创建任务**。

#### 在现有任务中

要更改现有任务的机密性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择你的任务。
1. 在右上角，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **开启机密性**。

### 谁可以查看机密任务

当任务被设为机密后，只有具有项目报告者、开发者、维护者或所有者角色的用户才能访问它。具有访客或[最低](permissions.md#users-with-minimal-access)角色的用户无法访问该任务，即使他们之前参与过该任务。

具有访客角色的用户可以创建机密任务，但只能查看他们自己创建的任务。

具有访客角色的用户或非成员如果被分配到机密任务，则可以查看该任务。当访客用户或非成员从机密任务中取消分配后，他们将无法再查看它。

对于没有必要权限的用户，机密任务在搜索结果中是隐藏的。

### 机密任务指示器

机密任务在视觉上与常规任务有几个不同之处。在列出任务的地方，你可以看到标记为机密的任务旁边有一个机密 ({{< icon name="eye-slash" >}}) 图标。

如果你没有[足够的权限](#who-can-see-confidential-tasks)，则完全看不到机密任务。

同样，在任务内部，你可以在面包屑旁边看到机密 ({{< icon name="eye-slash" >}}) 图标。

每次从常规变为机密或反之，都会在任务的评论中通过系统笔记指示，例如：

- {{< icon name="eye-slash" >}} Jo Garcia 在 5 分钟前将该议题设为机密
- {{< icon name="eye" >}} Jo Garcia 刚刚将该议题设为对所有人可见

## 锁定讨论

{{< history >}}

- 在 GitLab 16.9 中引入，使用名为 `work_items_beta` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 在 GitLab 18.6 中，功能标志 `work_items_beta` 已移除。

{{< /history >}}

你可以阻止任务中的公开评论。当你这样做时，只有项目成员可以添加和编辑评论。

先决条件：你必须具有报告者、开发者、维护者或所有者角色。

要锁定任务：

1. 在右上角，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **锁定讨论**。

系统笔记会添加到页面详细信息中。

如果任务在讨论锁定的情况下关闭，则在讨论解锁之前你无法重新打开它。

## 任务中的关联项

{{< history >}}

- 在 GitLab 16.5 中引入，使用名为 `linked_work_items` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 在 GitLab 16.7 中，在 JihuLab.com 和私有化部署上启用。
- 在 GitLab 16.8 中，引入了通过输入 URL 和 ID 添加关联项的功能。
- 在 GitLab 17.0 中 GA。功能标志 `linked_work_items` 已移除。
- 在 GitLab 17.0 中，将所需的最低角色从报告者（如果为真）更改为访客。

{{< /history >}}

关联项是一种双向关系，并显示在表情反应部分下方的区块中。你可以在同一项目中相互关联目标、关键结果或任务。

只有当用户可以看到两个项时，该关系才会在 UI 中显示。

### 添加关联项

先决条件：你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色。

要将项关联到任务：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择你的任务。
1. 在任务的 **关联项** 部分，选择 **添加** ({{< icon name="plus" >}})。
1. 选择两个项之间的关系。可以是：
   - **关联到**
   - **阻塞**
   - **被阻塞**
1. 输入项的搜索文本、URL 或其引用 ID。
1. 添加完所有要关联的项后，选择搜索框下方的 **添加**。

添加完所有关联项后，你可以看到它们被分类，以便在视觉上更好地理解它们的关系。

![关联项区块](img/linked_items_list_v16_5.png)

### 移除关联项

先决条件：你必须具有项目的访客、计划者、报告者、开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择你的任务。
1. 在任务的 **关联项** 部分，在每个项旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **移除**。

由于是双向关系，该关系不再出现在任一项目中。

### 添加合并请求并自动关闭任务

{{< history >}}

- 在 GitLab 17.3 中引入。

{{< /history >}}

你可以设置任务在合并请求合并时关闭。

先决条件：

- 你必须具有包含合并请求的项目的开发者、维护者或所有者角色。
- 你必须具有包含任务的项目的报告者、开发者、维护者或所有者角色。

1. 编辑你的合并请求。
1. 在 **描述** 框中，找到并添加任务。
   - 使用你为向议题添加合并请求所使用的[关闭模式](project/issues/managing_issues.md#closing-issues-automatically)。
   - 如果你的任务与合并请求在同一项目中，你可以通过输入 <kbd>#</kbd> 后跟任务的 ID 或标题来搜索任务。
   - 如果你的任务在不同项目中，打开任务，从浏览器复制 URL，或通过选择右上角的垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **复制引用** 来复制任务的引用。

合并请求现在显示在正文的 **开发** 部分。

使用确切的关闭模式将合并请求添加到任务。

如果你的项目设置中启用了[自动关闭议题](project/issues/managing_issues.md#disable-automatic-issue-closing)，则在以下任一情况下任务会自动关闭：

- 添加的合并请求被合并。
- 使用关闭模式引用任务的提交被提交到项目的默认分支。

## 相关主题

- [从任务创建合并请求](project/merge_requests/creating_merge_requests.md#from-a-task)