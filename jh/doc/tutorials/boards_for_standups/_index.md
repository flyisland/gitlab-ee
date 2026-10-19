---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置带有工作流标记和列表的议题看板，以便团队在每日站会期间跟踪任务。
title: '教程：为团队站会设置议题看板'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程介绍如何创建并配置议题看板，帮助团队高效开展站会。完成后，您将拥有一个支持以下工作流的看板：

1. 每次站会之前：

   - 团队成员更新各自所分配任务的状态。
   - 任务在显示其当前状态的列表中流转：规划中、开发中、受阻或已完成。

1. 站会期间：

   - 团队成员讨论进行中的工作并分享完成时间。
   - 识别受阻任务并制定解决计划。
   - 将新任务添加到就绪列表中。
   - 庆祝已完成的任务并将其移至完成。

结果：团队每次站会结束后都能就冲刺进展达成一致，明确风险并制定应对计划。

要为团队站会设置议题看板：

1. [创建群组](#create-a-group)
1. [创建项目](#create-a-project)
1. [创建标记](#create-labels)
1. [创建团队站会看板](#create-the-team-stand-up-board)
1. [配置看板列表](#configure-your-board-lists)
1. [为团队任务创建议题](#create-issues-for-team-tasks)

<a id="before-you-begin"></a>

## 开始之前

- 如果您在本教程中使用现有群组，请确保您拥有该群组的计划者、报告者、开发者、维护者或所有者角色。
- 如果您在本教程中使用现有项目，请确保您拥有该项目的计划者、报告者、开发者、维护者或所有者角色。

<a id="create-a-group"></a>

## 创建群组

首先创建一个群组来管理一个或多个相关项目。群组让您可以管理成员访问权限，并在项目之间共享设置。

要创建群组：

1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建群组**。
1. 选择**创建群组**。
1. 填写字段：
   - 在**群组名称**中，输入 `Paperclip Software Factory`。
1. 选择**创建群组**。

您已创建一个空群组。接下来，创建一个项目来存储您的议题和代码。

<a id="create-a-project"></a>

## 创建项目

项目用于存储您的代码仓库以及用于规划的议题。所有开发工作都在项目中进行。

要创建空白项目：

1. 在您的群组中，在右上角，选择**新建项目**。
1. 选择**创建空白项目**。
1. 填写字段：
   - 在**项目名称**中，输入 `Paperclip Assistant`。
1. 选择**创建项目**。

<a id="create-labels"></a>

## 创建标记

要在站会期间跟踪议题状态，您需要工作流标记。

请在 `Paperclip Software Factory` 群组中创建这些标记，而不是在项目中创建。群组标记可供群组中的所有项目使用，这有助于在团队之间建立一致的工作流。

要创建工作流标记：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的 **Paperclip Software Factory** 群组。
1. 选择**管理** > **标记**。
1. 选择**新建标记**。
1. 在**标题**文本框中，输入标记名称。
1. 可选。选择背景颜色或输入十六进制颜色值。
1. 选择**创建标记**。

重复这些步骤以创建所有工作流标记：

- `workflow::planning breakdown`
- `workflow::ready for development`
- `workflow::in development`
- `workflow::ready for review`
- `workflow::in review`
- `workflow::blocked`
- `workflow::verification`
- `workflow::complete`

<a id="create-the-team-stand-up-board"></a>

## 创建团队站会看板

在群组中创建看板，这样您就可以管理群组中任何项目的议题。

要创建群组议题看板：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的 **Paperclip Software Factory** 群组。
1. 选择**计划** > **议题看板**。
1. 在左上角，选择带有当前看板名称的下拉列表。
1. 选择**创建新看板**。
1. 填写字段：
   - 在**标题**中，输入 `Team stand-up`。
   - 同时选择**显示开启列表**和**显示已关闭列表**。
1. 选择**创建看板**。

<a id="add-workflow-lists-to-your-board"></a>

### 向看板添加工作流列表

1. 在右上角，选择**添加列表**（{{< icon name="plus" >}}）。
1. 从**新建列表**中，选择**标记**。
1. 从**值**下拉列表中，选择一个工作流标记。
1. 选择**添加到看板**。
1. 对每个工作流标记重复步骤 1-4。

您的看板现在已为每个工作流状态设置了列表，不过在后续步骤中添加议题之前，这些列表都是空的。

![名为“Team stand-up”的议题看板，带有工作流列表但没有议题。](img/team_standup_board_with_workflow_lists_v17_8.png)

<a id="configure-your-board-lists"></a>

## 配置看板列表

您可以通过设置应用于所有列表的筛选条件来自定义看板。例如，您可以只显示当前迭代中的议题或带有特定标记的议题。

要配置看板：

1. 在您的团队站会看板上，选择**配置看板**（{{< icon name="settings" >}}）。
1. 填写以下任一字段以筛选议题：
   - **里程碑**：显示特定里程碑中的议题。
   - **指派人**：显示分配给特定团队成员的议题。
   - **标记**：显示带有特定标记的议题。
   - **权重**：显示具有特定权重值的议题。
   - **迭代**：显示当前迭代中的议题。
1. 选择**创建看板**。

您的看板现在只显示与筛选条件匹配的议题。例如，如果您选择某个里程碑，则只有分配给该里程碑的议题会出现在看板列表中。

![名为“Team stand-up”的议题看板，带有工作流列表。](img/team_standup_board_with_workflow_lists_v17_8.png)

<a id="create-issues-for-team-tasks"></a>

## 为团队任务创建议题

您可以在团队站会期间直接从看板创建议题。

要创建议题：

1. 在您的团队站会看板上，在 `workflow::ready for development` 列表中，选择**创建新议题**（{{< icon name="plus" >}}）。
1. 填写字段：
   - 在**标题**中，输入 `Redesign user profile page`
   - 从**项目**下拉列表中，选择 **Paperclip Software Factory / Paperclip Assistant**
1. 选择**创建议题**。

该议题创建时带有 `workflow::ready for development` 标记，因为您是在该列表中创建的。

<a id="add-metadata-to-the-issue"></a>

### 向议题添加元数据

1. 在议题卡片上，选择标题以外的任意位置。
1. 在右侧边栏中，在要更新的字段中，选择**编辑**。
1. 选择您的更改。
1. 选择字段外的任意区域以保存。

恭喜！您已设置好一个团队站会看板，有助于跟踪工作并促进讨论。您的团队现在可以使用此看板来高效开展站会。
