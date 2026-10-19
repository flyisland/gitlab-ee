---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在群组及其子群组和项目中设置范围标记和议题看板，以便按类型、严重程度和优先级对议题进行排查。
title: '教程：设置一个包含子群组的复杂群组以进行议题排查'
---

<!-- vale gitlab_base.FutureTense = NO -->

议题排查是指按类型和严重程度进行分类的过程。随着项目的发展以及人们创建越来越多的议题，有必要建立一个工作流，用于对传入的议题进行排查。

在本教程中，您将学习如何为此场景设置一个包含子群组的极狐GitLab 群组。

要为包含子群组的复杂群组设置极狐GitLab 以进行议题排查：

1. [创建群组](#create-a-group)
1. [在群组内创建子群组](#create-subgroups-inside-a-group)
1. [在子群组内创建项目](#create-projects-inside-subgroups)
1. [确定类型、严重程度和优先级的判定标准](#decide-on-the-criteria-for-types-severity-and-priority)
1. [记录您的判定标准](#document-your-criteria)
1. [创建范围标记](#create-scoped-labels)
1. [为新标记设置优先级](#prioritize-the-new-labels)
1. [创建父群组议题排查看板](#create-a-parent-group-issue-triage-board)
1. [为功能创建议题](#create-issues-for-features)

<a id="before-you-begin"></a>

## 先决条件

- 如果您使用现有项目来完成本教程，请确保您拥有该项目的报告者、开发者、维护者或所有者角色。
  - 如果您现有的项目没有父群组，请创建一个群组并[将项目标记提升为群组标记](../../user/project/labels.md#promote-a-project-label-to-a-group-label)。

<a id="create-a-group"></a>

## 创建群组

[群组](../../user/group/_index.md)本质上是一个用于容纳多个项目的容器。通过群组，您可以管理多个项目，并一次性与群组成员沟通。

要创建新群组：

1. 在右上角，选择**创建新内容** ({{< icon name="plus" >}})，然后选择**新建群组**。
1. 选择**创建群组**。
1. 输入群组详细信息：
   - 在**群组名称**中，输入 `Web App Dev` 或其他值。
1. 在页面底部，选择**创建群组**。

<a id="create-subgroups-inside-a-group"></a>

## 在群组内创建子群组

[子群组](../../user/group/subgroups/_index.md)是群组中的群组。子群组有助于组织大型项目并管理权限。

要创建新子群组：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的 **Web App Dev** 群组。
1. 选择**创建新内容** ({{< icon name="plus" >}}) 和**新建子群组**。
1. 输入子群组详细信息：
   - 在**子群组名称**中，输入 `Frontend` 或其他值。
1. 选择**创建子群组**。
1. 重复此过程，创建第二个名为 `Backend` 或其他值的子群组。

<a id="create-projects-inside-subgroups"></a>

## 在子群组内创建项目

要跨多个项目管理议题跟踪，您需要在子群组中创建项目。

要创建新项目：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的 `Frontend` 子群组。
1. 在右上角，选择**创建新内容** ({{< icon name="plus" >}})，然后选择**新建项目/代码仓库**。
1. 选择**创建空白项目**。
1. 输入项目详细信息：
   - 在**项目名称**中，输入 `Web UI`。有关更多信息，请参阅项目
     [命名规则](../../user/reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)。
1. 在页面底部，选择**创建项目**。
1. 重复此过程，在 `Frontend`
   子群组中创建第二个名为 `Accessibility Audit`的项目，并在 `Backend` 子群组中创建第三个名为 `API`的项目。

<a id="decide-on-the-criteria-for-types-severity-and-priority"></a>

## 确定类型、严重程度和优先级的判定标准

接下来，您需要确定：

- 您想要识别的议题**类型**。如果您需要更细粒度的方式，还可以
  为每种类型创建子类型。类型有助于对工作进行分类，以了解
  团队被请求处理的工作种类。
- **优先级**和**严重程度**的级别，用于定义传入工作对最终
  用户的影响，并协助确定优先级。

在本教程中，假设您已确定以下内容：

- 类型：`Bug`、`Feature` 和 `Maintenance`
- 优先级：`1`、`2`、`3` 和 `4`
- 严重程度：`1`、`2`、`3` 和 `4`

如需灵感，请参阅极狐GitLab 如何定义这些内容：

- [类型和子类型](https://handbook.gitlab.com/handbook/engineering/metrics/#work-type-classification)
- [优先级](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/#priority)
- [严重程度](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/#severity)

<a id="document-your-criteria"></a>

## 记录您的判定标准

在您就所有判定标准达成一致后，请将其记录下来，放在队友随时可以访问的地方。

例如，将其添加到项目的 [Wiki](../../user/project/wiki/_index.md)中，或添加到使用
[GitLab Pages](../../user/project/pages/_index.md) 发布的公司手册中。

<!-- Idea for expanding this tutorial:
     Add steps for [creating a wiki page](../../user/project/wiki/_index.md#create-a-new-wiki-page). -->

<a id="create-scoped-labels"></a>

## 创建范围标记

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

接下来，您将创建标记以添加到议题中，从而对它们进行分类。

最适合此操作的工具是[范围标记](../../user/project/labels.md#scoped-labels)，您可以使用它来设置互斥的属性。

对照您[之前](#decide-on-the-criteria-for-types-severity-and-priority)汇总的类型、严重程度和优先级列表，您需要创建相匹配的范围标记。

范围标记名称中的双冒号 (`::`) 可防止同一范围的两个标记一起使用。例如，如果您向一个已有 `type::bug`的议题添加 `type::feature` 标记，则前一个标记会被移除。

> [!note]
> 范围标记在专业版和旗舰版中可用。
> 如果您使用的是基础版，可以改用普通标记。
> 但是，它们不是互斥的。

要使标记可用于每个子群组中的所有项目，请先转到包含您子群组的父群组。如果您希望标记仅可用于某个子群组中的项目，请在子群组内按照以下步骤操作。

要创建每个标记：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的 **Web App Dev** 群组。
1. 选择**管理** > **标记**。
1. 选择**新建标记**。
1. 在**标题**文本框中，输入标记的名称。从 `type::bug` 开始。
1. 可选。从可用颜色中选择一种颜色，或在**背景颜色**文本框中输入十六进制颜色值以
   指定特定颜色。
1. 选择**创建标记**。

重复步骤 3-6 以创建您需要的所有标记。以下是一些示例：

- `type::bug`
- `type::feature`
- `type::maintenance`
- `priority::1`
- `priority::2`
- `priority::3`
- `priority::4`
- `severity::1`
- `severity::2`
- `severity::3`
- `severity::4`

<a id="prioritize-the-new-labels"></a>

## 为新标记设置优先级

现在，将新标记设置为优先级标记。这样做可确保在按优先级或标记优先级排序时，最重要的议题显示在议题列表的顶部。

要了解按优先级或标记优先级排序时会发生什么，请参阅[议题列表的排序和排列](../../user/project/issues/sorting_issue_lists.md)。

要为标记设置优先级：

1. 在标记页面上，在您想要设置优先级的标记旁边，选择**设置优先级** ({{< icon name="star-o" >}})。
   该标记现在会显示在标记列表的顶部，位于**已设置优先级的标记**下。
1. 要更改这些标记的相对优先级，请在列表中上下拖动它们。
   列表中位置越靠上的标记优先级越高。
1. 为您之前创建的所有标记设置优先级。
   确保优先级和严重程度较高的标记在列表中的位置高于值较低的标记。

![十一个已设置优先级的范围标记列表。](img/priority_labels_v16_3.png)

<a id="create-a-parent-group-issue-triage-board"></a>

## 创建父群组议题排查看板

为应对即将到来的议题积压，请创建一个按标记组织议题的[议题看板](../../user/project/issue_board.md)。您将使用它来快速创建议题，并通过将卡片拖到各个列表来为它们添加标记。

要设置您的议题看板：

1. 确定看板的范围。
   例如，创建一个[群组议题看板](../../user/project/issue_board.md#group-issue-boards)来为
   议题分配严重程度。
1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的 **Web App Dev** 群组。
1. 选择**计划** > **议题看板**。
1. 在议题看板页面的左上角，选择带有当前看板名称的下拉列表。
1. 选择**创建新看板**。
1. 在**标题**文本框中，输入 `Issue triage (by severity)`。
1. 保持选中**显示打开列表**复选框，并清除**显示已关闭列表**复选框。
1. 选择**创建看板**。您应该会看到一个空看板。
1. 为 `severity::1` 标记创建一个列表：
   1. 在议题看板页面的右上角，选择**创建列表**。
   1. 在出现的列中，从**值**下拉列表中，选择 `severity::1` 标记。
   1. 在列表底部，选择**添加到看板**。
1. 对标记 `severity::2`、`severity::3` 和 `severity::4` 重复上一步骤。

要创建子群组议题看板，请在子群组内按照步骤 3-10 操作。

目前，您看板中的列表应该是空的。接下来，您将用一些议题来填充它们。

<a id="create-issues-for-features"></a>

## 为功能创建议题

要跟踪即将推出的功能和缺陷，您必须创建一些议题。议题属于项目，但您也可以直接从群组议题看板创建它们。

首先为计划中的功能创建一些议题。您可以在发现缺陷时为其创建议题（希望不要太多！）。

要从您的 **Issue triage (by severity)** 看板创建议题：

1. 转到**打开**列表。
   此列表显示不适合任何其他看板列表的议题。
   如果您已经知道您的议题应具有哪个严重程度标记，可以直接从
   该标记的列表创建它。
   请记住，从标记列表创建的每个议题都会被赋予该标记。

   现在，请继续使用**打开**列表。
1. 在**打开**列表上，选择**创建新议题**图标 ({{< icon name="plus" >}})。
1. 填写字段：
   - 在**标题**下，输入 `Dark mode toggle`。
   - 选择此议题适用的项目。本示例使用 `Frontend / Web UI`。
1. 选择**创建议题**。
1. 重复这些步骤以创建更多议题。

   例如，如果您正在构建一个 Web API 应用，`Frontend` 和 `Backend` 指的是不同的
   工程团队。这些项目指的是技术栈开发的不同方面。
   创建以下议题，并根据您认为合适的方式分配给项目：

   - `User registration`
   - `Profile creation`
   - `Search functionality`
   - `Add to favorites`
   - `Push notifications`
   - `Social sharing`
   - `In-app messaging`
   - `Track progress`
   - `Feedback and ratings`
   - `Settings and preferences`

> [!note]
> 一个项目议题看板中的议题无法从其他项目的议题看板中看到。
> 同样，一个子群组中项目的议题只能在该子群组的
> 议题看板上看到。要查看父群组中每个项目的所有议题，您必须位于
> 父群组的议题看板中。

您的第一个排查议题看板已准备就绪！尝试将一些议题从**打开**列表拖到某个标记列表中，以添加某个严重程度标记。

![包含未标记议题和用于标记议题的已设置优先级的“severity”标记的议题看板。](img/triage_board_v16_3.png)

<a id="next-steps"></a>

## 后续步骤

接下来，您可以：

- 调整您使用议题看板的方式。一些选项包括：
  - 编辑您当前的议题看板，使其也包含优先级和类型标记的列表。
    这样，看板会变得更宽，可能需要一些水平滚动。
  - 创建名为 `Issue triage (by priority)` 和 `Issue triage (by type)`的单独议题看板。
    这样，您可以将各种类型的排查工作分开，但需要在
    看板之间切换。
  - [为团队交接设置议题看板](../boards_for_teams/_index.md)。
- 在议题列表中按优先级或严重程度浏览议题，
  [按每个标记筛选](../../user/project/issues/managing_issues.md#filter-the-list-of-issues)。
  如果可用，请使用
  [“is one of”筛选运算符](../../user/project/issues/managing_issues.md#filter-the-list-of-issues)。
- 将议题分解为[任务](../../user/tasks.md)。
- 使用 [`gitlab-triage` gem](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage) 创建有助于在项目中自动进行议题排查的策略。
  生成带有如下热力图的摘要报告：

  ![带有“priority”和“severity”标记的议题的对角热力图。](img/triage_report_v16_3.png)

要了解有关极狐GitLab 议题排查的更多信息，请参阅[议题排查](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/)和[排查操作](https://handbook.gitlab.com/handbook/engineering/infrastructure-platforms/developer-experience/triage-operations/)。
