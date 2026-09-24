---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab 助力看板管理'
description: 进行中的工作、流程和分布情况。
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将指导你如何使用 极狐GitLab 议题看板，在看板工作流中管理任务。
通过设置群组、项目、看板并组织议题，你可以提升透明度、协作效率和交付能力。

要使用 极狐GitLab 议题看板管理看板工作流中的任务：

- [设置群组和项目](#set-up-groups-and-projects)
- [创建标签](#create-labels)
- [设置看板](#set-up-kanban-board)
- [可视化流程与分布](#visualize-flow-and-distribution)

有关其他信息，请参阅本页底部的[高级技巧](#advanced-tips-and-tricks)。

<a id="set-up-groups-and-projects"></a>

## 设置群组和项目

按照相应步骤[创建你的群组](../../user/group/_index.md#create-a-group)和[项目](../../user/project/_index.md)。

如果你的团队在多个仓库中协作，请为群组中的每个仓库创建一个项目。

议题通常归属于各自的项目，但你的看板将设置在群组中，
这样你就能在所有项目中保持可见性。
如果你在单个仓库中工作，可以跳过此步骤。

<a id="create-labels"></a>

## 创建标签

接下来，让我们创建一些标签来代表看板生命周期中的每个步骤：

- 如果你在单个项目中工作，请在该项目中创建标签。
- 如果你在多个项目中工作，请在群组中创建标签。
  这样你就能在所有项目中使用同一套标签。

在两种情况下，[创建标签](../../user/project/labels.md#create-a-label)的流程是相同的。
请为 **status::to do**、**status::doing** 和 **status::done** 创建[限定标签](../../user/project/labels.md#scoped-labels)。

<a id="set-up-kanban-board"></a>

## 设置看板

创建标签后，下一步是创建看板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组或项目。
1. 选择 **计划** > **议题看板**。
1. 在议题看板的左上角，选择带有当前看板名称的下拉列表。
1. 选择 **创建新看板**。
1. 输入新看板的名称，然后选择 **创建看板**。
1. 通过选择 **+ 新列表** 创建一个新的标签列表。
1. 将列表范围设置为 **标签**，值设置为 **status::to do**。
1. 重复相同的标签列表创建流程，再创建两个标签列表：**status::doing** 和 **status::done**。

恭喜，你现在拥有一个看板了。现在，你可以在每个列表中创建新议题，将议题从一个工作流步骤拖放到另一个步骤，并将议题分配给团队成员。

或者，你也可以为看板上的每个标签列表启用[进行中的工作限制](../../user/project/issue_board.md#work-in-progress-limits)。
操作步骤如下：

1. 选择标签列表右上角的 **编辑列表设置** 齿轮图标。
1. 选择 **进行中的工作限制** > **编辑**。
1. 输入对应列表中允许的最大议题数量，然后按 **Enter** 键。

当达到限制时，你的列表背景将自动变为红色。
列表中还会显示一条“进行中的工作限制”分割线，以可视化的方式将所有超出限制的议题显示在该线下方。

<a id="visualize-flow-and-distribution"></a>

## 可视化流程与分布

传统看板通常使用累积流图来可视化负载并帮助识别瓶颈。
在 极狐GitLab 中，这可以通过[价值流分析](../../user/group/value_stream_analytics/_index.md)来实现。
接下来，我们将创建一个与你的看板工作流相匹配的自定义价值流分析报告。

<a id="visualize-flow"></a>

### 可视化流程

要可视化流程：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组或项目。
1. 在侧边导航栏中，选择 **分析** > **价值流分析**。
1. 选择页面左上角的 **价值流** 下拉菜单，然后选择 **新建价值流**。
1. 为价值流分析报告输入所需名称，然后选择 **从模板创建** 选项。
1. 输入 **To do** 作为阶段名称。
1. 对于开始事件，选择 **议题标签已添加**，然后选择 **status::to do** 标签。
1. 对于结束事件，选择 **议题标签已移除**，然后选择 **status::to do** 标签。
1. 接下来，选择 **添加阶段**。
1. 重复相同的流程，为 **status::in progress** 和 **status::done** 创建阶段。
1. 添加完所有三个阶段后，选择 **新建价值流**。

通过创建与看板工作流相匹配的自定义价值流分析报告，极狐GitLab
会自动计算每个议题在每个阶段所花费的时间，并汇总所有阶段的数据。
因此，你可以获得前置时间和周期时间。
你可以深入每个阶段，查看单个议题的具体时间。

<a id="visualize-distribution"></a>

### 可视化分布

要可视化分布：

1. 在你创建的价值流分析报告中，向下滚动到 **按类型划分的任务** 图表。
1. 选择右上角的齿轮图标下拉菜单，然后搜索并选择代表议题类型的标签。
1. 如果你尚未创建 **type::...** 限定标签或类似标签，现在是开始将工作项类型（例如，**feature**、**bug** 和 **maintenance**）纳入工作流的好时机。
1. 选择 **显示议题**，然后选择下拉列表之外的任意位置以应用更改。
1. **按类型划分的任务** 图表现在将显示与所选标签匹配的议题随时间变化的分布情况。

<a id="advanced-tips-and-tricks"></a>

## 高级技巧

- 要创建根据指定条件自动更新议题的策略，请设置 [`gitlab-triage`](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage)。例如，你可以创建策略，在应用 **status::done** 标签时自动关闭议题，或在创建议题时自动添加 **status::to do** 标签。开源的 `gitlab-triage` gem 设计用于与 极狐GitLab 流水线无缝协作。
- 为使创建不同类型的议题更高效、更标准化，请创建[描述模板](../../user/project/description_templates.md)。
- 要可视化群组或项目中每个团队成员的负载情况，请创建一个带有 **指派人列表** 的额外议题看板。
- 为 T 恤尺码估算的议题创建一套限定标签。例如，**size::small**、**size::medium** 和 **size::large**。