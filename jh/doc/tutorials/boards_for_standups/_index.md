---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：为团队晨会设置议题看板'
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

本教程将向你展示如何创建和配置一个议题看板，帮助团队高效开展晨会。
完成后，你将拥有一个支持以下工作流的看板：

1. 每次晨会之前：

   - 团队成员更新其分配任务的状态。
   - 任务在各列表中流转，展示当前状态：规划中、开发中、阻塞或已完成。

1. 在晨会期间：

   - 团队成员讨论进行中的工作并分享完成时间线。
   - 识别出阻塞的任务并制定解决方案。
   - 将新的任务添加到就绪列表。
   - 庆祝已完成的任务并将其移至完成。

最终效果：你的团队在每次晨会后都能对冲刺进度达成一致，识别出风险并制定应对计划。

要设置团队晨会议题看板，请执行以下操作：

1. [创建群组](#创建群组)
1. [创建项目](#创建项目)
1. [创建标签](#创建标签)
1. [创建团队晨会看板](#创建团队晨会看板)
1. [配置你的看板列表](#配置你的看板列表)
1. [创建团队任务的议题](#创建团队任务的议题)

<a id="before-you-begin"></a>

## 开始之前

- 如果你在本教程中使用现有群组，请确保你拥有该群组的计划者、报告者、开发者、维护者或所有者角色。
- 如果你在本教程中使用现有项目，请确保你拥有该项目的计划者、报告者、开发者、维护者或所有者角色。

<a id="create-a-group"></a>

## 创建群组

首先创建一个群组来管理一个或多个相关项目。
群组可让你跨项目管理成员访问权限并共享设置。

要创建群组：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建群组**。
1. 选择 **创建群组**。
1. 填写字段：
   - 在 **群组名称** 中，输入 `Paperclip Software Factory`。
1. 选择 **创建群组**。

你已经创建了一个空群组。
接下来，创建一个项目来存储你的议题和代码。

<a id="create-a-project"></a>

## 创建项目

项目用于存储你的代码仓库和用于规划工作的议题。
所有的开发工作都在项目中进行。

要创建空白项目：

1. 在你的群组中，在右上角选择 **新建项目**。
1. 选择 **创建空白项目**。
1. 填写字段：
   - 在 **项目名称** 中，输入 `Paperclip Assistant`。
1. 选择 **创建项目**。

<a id="create-labels"></a>

## 创建标签

要在晨会期间跟踪议题状态，你需要工作流标签。

在你的 `Paperclip Software Factory` 群组中创建这些标签，而不是在项目中创建。
群组级别的标签可被群组内的所有项目使用，这有助于在团队间建立一致的工作流。

要创建工作流标签：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的 **Paperclip Software Factory** 群组。
1. 选择 **管理** > **标签**。
1. 选择 **新建标签**。
1. 在 **标题** 字段中，输入标签名称。
1. 可选。选择背景颜色或输入十六进制颜色值。
1. 选择 **创建标签**。

重复这些步骤以创建所有工作流标签：

- `workflow::planning breakdown`
- `workflow::ready for development`
- `workflow::in development`
- `workflow::ready for review`
- `workflow::in review`
- `workflow::blocked`
- `workflow::verification`
- `workflow::complete`

<a id="create-the-team-stand-up-board"></a>

## 创建团队晨会看板

在群组中创建你的看板，这样你就可以从群组内的任何项目管理议题。

要创建群组议题看板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的 **Paperclip Software Factory** 群组。
1. 选择 **计划** > **议题看板**。
1. 在左上角，选择显示当前看板名称的下拉列表。
1. 选择 **创建新看板**。
1. 填写字段：
   - 在 **标题** 中，输入 `Team stand-up`。
   - 同时选中 **显示开放列表** 和 **显示已关闭列表**。
1. 选择 **创建看板**。

<a id="add-workflow-lists-to-your-board"></a>

### 将工作流列表添加到看板

1. 在右上角，选择 **添加列表** ({{< icon name="plus" >}})。
1. 在 **新建列表** 中，选择 **标签**。
1. 从 **值** 下拉列表中，选择一个工作流标签。
1. 选择 **添加到看板**。
1. 为每个工作流标签重复步骤 1-4。

你的看板现在每个工作流状态都有了一个列表，但在后续步骤中添加议题之前它们将是空的。

![名为 "Team stand-up" 的议题看板，带有工作流列表但没有议题](img/team_standup_board_with_workflow_lists_v17_8.png)

<a id="configure-your-board-lists"></a>

## 配置你的看板列表

你可以通过设置应用于所有列表的筛选项来自定义你的看板。
例如，你可以仅显示当前迭代中或带有特定标签的议题。

要配置你的看板：

1. 在你的团队晨会看板上，选择 **配置看板** ({{< icon name="settings" >}})。
1. 填写以下任一字段以筛选议题：
   - **里程碑**：显示来自特定里程碑的议题。
   - **指派人**：显示分配给特定团队成员的议题。
   - **标签**：显示带有特定标签的议题。
   - **权重**：显示带有特定权重值的议题。
   - **迭代**：显示来自当前迭代的议题。
1. 选择 **创建看板**。

你的看板现在仅显示与你的筛选项匹配的议题。
例如，如果你选择了一个里程碑，则只有分配到该里程碑的议题会出现在看板列表中。

![名为 "Team stand-up" 的议题看板，带有工作流列表](img/team_standup_board_with_workflow_lists_v17_8.png)

<a id="create-issues-for-team-tasks"></a>

## 创建团队任务的议题

你可以在团队晨会期间直接从看板创建议题。

要创建议题：

1. 在你的团队晨会看板上，在 `workflow::ready for development` 列表中，选择 **创建新议题** ({{< icon name="plus" >}})。
1. 填写字段：
   - 在 **标题** 中，输入 `Redesign user profile page`
   - 从 **项目** 下拉列表中，选择 **Paperclip Software Factory / Paperclip Assistant**
1. 选择 **创建议题**。

由于你是在该列表中创建的，该议题创建时即带有 `workflow::ready for development` 标签。

<a id="add-metadata-to-the-issue"></a>

### 向议题添加元数据

1. 在议题卡片上，选择标题以外的任意位置。
1. 在右侧边栏中，在你想要更新的字段中选择 **编辑**。
1. 选择你的更改。
1. 选择字段外的任意区域以保存。

恭喜！
你已经设置好了一个团队晨会看板，它有助于跟踪工作并促进讨论。
你的团队现在可以使用此看板来开展高效的晨会了。

<a id="related-topics"></a>

## 相关主题

- [计划和跟踪工作教程](../plan_and_track.md)。
- [晨会、回顾和速率](../scrum_events/standups_retrospectives_velocity.md)