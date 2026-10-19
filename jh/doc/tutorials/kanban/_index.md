---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab 实施看板'
description: 进行中的工作、流动和分布。
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将指导您完成使用极狐GitLab 议题看板在看板工作流中管理任务的各个步骤。通过设置群组、项目、看板并组织议题，您可以提升透明度、协作和交付效率。

要使用极狐GitLab 议题看板在看板工作流中管理任务：

- [设置群组和项目](#set-up-groups-and-projects)
- [创建标记](#create-labels)
- [设置看板](#set-up-kanban-board)
- [可视化流动和分布](#visualize-flow-and-distribution)

其他信息，请参阅本页底部的[高级技巧和提示](#advanced-tips-and-tricks)。

<a id="set-up-groups-and-projects"></a>

## 设置群组和项目

按照相应步骤[创建群组](../../user/group/_index.md#create-a-group)和[项目](../../user/project/_index.md)。

如果您的团队跨多个代码仓库工作，请为群组中的每个代码仓库创建一个项目。

议题通常位于各自的项目中，但您的看板将位于群组中，以便您能够保持对所有项目的可见性。如果您只在单个代码仓库中工作，可以跳过此步骤。

<a id="create-labels"></a>

## 创建标记

接下来，让我们创建一些标记来表示看板生命周期中的每个步骤：

- 如果您在单个项目中工作，请在该项目中创建标记。
- 如果您跨多个项目工作，请在群组中创建标记。
  这样您就可以在所有项目中使用同一组标记。

在这两种情况下，[创建标记](../../user/project/labels.md#create-a-label)的流程都是相同的。
为 **status::to do**、**status::doing** 和 **status::done** 创建[范围标记](../../user/project/labels.md#scoped-labels)。

<a id="set-up-kanban-board"></a>

## 设置看板

创建标记后，下一步是创建看板：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组或项目。
1. 选择**计划** > **议题看板**。
1. 在议题看板的左上角，选择带有当前看板名称的下拉列表。
1. 选择**创建新看板**。
1. 输入新看板的名称，然后选择**创建看板**。
1. 通过选择 **+ 新建列表**创建新的标记列表。
1. 将列表范围设置为**标记**，值设置为 **status::to do**。
1. 重复相同的标记列表创建流程，再创建两个标记列表：**status::doing** 和 **status::done**。

恭喜，您现在拥有了一个看板。您现在可以在每个列表中创建新议题，将议题从一个工作流步骤拖放到另一个步骤，并将议题指派给团队成员。

您还可以为看板上的每个标记列表开启[进行中的工作 (WIP) 限制](../../user/project/issue_board.md#work-in-progress-limits)。为此：

1. 选择标记列表右上角的**编辑列表设置**齿轮图标。
1. 选择**进行中的工作限制** > **编辑**。
1. 输入相应列表允许的最大议题数，然后按 **Enter** 键。

当达到限制时，您的列表背景现在会自动变为红色。列表中还会显示一条“进行中的工作限制”分界线，以直观地显示分界线以下所有超出限制的议题。

<a id="visualize-flow-and-distribution"></a>

## 可视化流动和分布

看板传统上使用累积流图来可视化负载并帮助识别瓶颈。在极狐GitLab 中，这可以通过[价值流分析 (VSA)](../../user/group/value_stream_analytics/_index.md) 来实现。接下来，创建一个与您的看板工作流匹配的自定义 VSA 报告。

<a id="visualize-flow"></a>

### 可视化流动

要可视化流动：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组或项目。
1. 在侧边导航中，选择**分析** > **价值流分析**。
1. 选择页面左上角的**价值流**下拉列表，然后选择**新建价值流**。
1. 输入 VSA 报告所需的名称，然后选择**从模板创建**。
1. 为阶段名称输入 **To do**。
1. 对于开始事件，选择**添加议题标记**，然后选择 **status::to do** 标记。
1. 对于结束事件，选择**移除议题标记**，然后选择 **status::to do** 标记。
1. 接下来，选择**添加阶段**。
1. 重复相同的流程，为 **status::in progress** 和 **status::done** 创建阶段。
1. 添加完所有三个阶段后，选择**新建价值流**。

通过您的自定义 VSA 报告（与您的看板工作流相匹配），极狐GitLab 会自动计算每个议题在每个阶段花费的时间，并汇总所有阶段的数据。因此，您可以得到前置时间和周期时间。您可以深入查看每个阶段，了解各个议题的具体时间。

<a id="visualize-distribution"></a>

### 可视化分布

要可视化分布：

1. 在您创建的 VSA 报告中，向下滚动到**按类型划分的任务**图表。
1. 选择右上角的齿轮图标下拉列表，然后搜索并选择代表议题类型的标记。
1. 如果您还没有创建 **type::...** 范围标记或类似标记，现在正是将工作项类型纳入工作流的好时机（例如 **feature**、**bug** 和 **maintenance**）。
1. 选择**显示议题**，然后选择下拉列表外的任意位置以应用更改。
1. **按类型划分的任务**图表现在会显示随时间推移与所选标记匹配的议题分布。

<a id="advanced-tips-and-tricks"></a>

## 高级技巧和提示

- 要创建根据指定条件自动更新议题的策略，请设置 [`gitlab-triage`](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage)。例如，您可以创建一个策略，在应用 **status::done** 标记时自动关闭议题，或在创建议题时自动添加 **status::to do** 标记。开源 `gitlab-triage` gem 旨在与极狐GitLab 流水线无缝协作。
- 为了更高效、更标准化地创建不同类型的议题，请创建[描述模板](../../user/project/description_templates.md)。
- 要可视化群组或项目中每个团队成员的负载，请创建一个带有**指派人列表**的额外议题看板。
- 为 T 恤尺码议题创建一个范围标记集。例如 **size::small**、**size::medium** 和 **size::large**。
