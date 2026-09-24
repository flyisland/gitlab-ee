---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：设置具有多个项目的群组进行议题分类'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

议题分类是根据类型和严重程度进行分类的过程。
随着项目增长和人们创建的议题越来越多，为如何分类传入的议题创建工作流是值得的。

在本教程中，您将学习如何为此场景设置一个包含多个项目的极狐GitLab 群组。

要在项目中设置极狐GitLab 进行议题分类：

1. [创建一个群组](#create-a-group)
1. [在群组内创建项目](#create-projects-inside-a-group)
1. [决定类型、严重性和优先级的标准](#decide-on-the-criteria-for-types-severity-and-priority)
1. [记录您的标准](#document-your-criteria)
1. [创建范围标记](#create-scoped-labels)
1. [设置新标记的优先级](#prioritize-the-new-labels)
1. [创建群组议题分类看板](#create-a-group-issue-triage-board)
1. [为功能创建议题](#create-issues-for-features)

## 开始之前

- 如果您在此教程中使用现有项目，请确保您对该项目具有报告者、开发者、维护者或所有者角色。
  - 如果您现有的项目没有父群组，请创建一个群组并将[项目标记提升为群组标记](../../user/project/labels.md#promote-a-project-label-to-a-group-label)。

<a id="create-a-group"></a>

## 创建一个群组

[群组](../../user/group/_index.md)本质上是一个包含多个项目的容器。它允许用户管理多个项目并与群组成员一次性沟通。

要创建一个新的群组：

1. 在右上角，选择 **创建新项目** ({{< icon name="plus" >}}) 然后选择 **新建群组**。
1. 选择 **创建群组**。
1. 输入群组详细信息。
   - 对于 **群组名称**，输入 `triage-tutorial`。
1. 选择页面底部的 **创建群组**。

<a id="create-projects-inside-a-group"></a>

## 在群组内创建项目

要管理跨多个项目的议题跟踪，您需要在您的群组内创建至少两个项目。

要创建一个新的项目：

1. 在右上角，选择 **创建新项目** ({{< icon name="plus" >}}) 然后 **新建项目/代码仓**。
1. 选择 **创建空白项目**。
1. 输入项目详细信息：
   - 对于 **项目名称**，输入 `test-project-1`。有关更多信息，请参见项目[命名规则](../../user/reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)。
1. 选择页面底部的 **创建项目**。
1. 重复此过程以创建第二个名为 `test-project-2` 的项目。

<a id="decide-on-the-criteria-for-types-severity-and-priority"></a>

## 决定类型、严重性和优先级的标准

接下来，您需要确定：

- 您想要识别的议题的 **类型**。如果您需要更精细的方法，也可以为每种类型创建子类型。类型有助于对工作进行分类，从而了解请求团队的工作种类。
- **优先级** 和 **严重性** 的级别，用于定义传入工作对最终用户的影响，并协助确定优先级。

对于本教程，假设您已决定如下内容：

- 类型：`Bug`、`Feature` 和 `Maintenance`
- 优先级：`1`、`2`、`3` 和 `4`
- 严重性：`1`、`2`、`3` 和 `4`

为了获得灵感，请参见我们在极狐GitLab 如何定义这些：

- [类型和子类型](https://handbook.gitlab.com/handbook/engineering/metrics/#work-type-classification)
- [优先级](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/#priority)
- [严重性](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/#severity)

<a id="document-your-criteria"></a>

## 记录您的标准

在就所有标准达成一致后，将其写下来，放在您的团队成员可以随时访问的地方。

例如，将其添加到您项目中的 [Wiki](../../user/project/wiki/_index.md) 中，或添加到通过 [极狐GitLab Pages](../../user/project/pages/_index.md) 发布的公司手册中。

<!-- Idea for expanding this tutorial:
     Add steps for [creating a wiki page](../../user/project/wiki/_index.md#create-a-new-wiki-page). -->

<a id="create-scoped-labels"></a>

## 创建范围标记

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

接下来，您将创建标记以添加到议题中对其进行分类。

最佳工具是[范围标记](../../user/project/labels.md#scoped-labels)，您可以使用它来设置互斥的属性。

根据您[之前](#decide-on-the-criteria-for-types-severity-and-priority)汇总的类型、严重性和优先级列表，您将需要创建匹配的范围标记。

范围标记名称中的双冒号 (`::`) 阻止两个相同范围的标记被同时使用。
例如，如果您将 `type::feature` 标记添加到一个已经拥有 `type::bug` 的议题，则前一个标记将被移除。

> [!note]
> 范围标记在专业版和旗舰版中可用。
> 如果您使用的是基础版，则可以改用普通标记。
> 但是，它们不是互斥的。

要创建每个标记：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **管理** > **标记**。
1. 选择 **新建标记**。
1. 在 **标题** 字段中，输入标记的名称。从 `type::bug` 开始。
1. 可选。从可用颜色中选择一种颜色，或在 **背景色** 字段中输入特定颜色的十六进制颜色值。
1. 选择 **创建标记**。

重复步骤 3-6 以创建您需要的所有标记。
以下是一些示例：

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

## 设置新标记的优先级

现在，将新标记设置为优先标记。
这样做可以确保如果您按优先级或标记优先级排序，最重要的议题会显示在议题列表的顶部。

要了解按优先级或标记优先级排序时会发生什么，请参见
[议题列表的排序和排列](../../user/project/issues/sorting_issue_lists.md)。

要设置标记的优先级：

1. 在标记页面上，在您想要设置优先级的标记旁边，选择 **优先标记** ({{< icon name="star-o" >}})。
   此标记现在会显示在标记列表的顶部，位于 **优先标记** 下方。
1. 要更改这些标记的相对优先级，请在列表中上下拖动它们。
   列表中位置越高的标记获得越高的优先级。
1. 为您之前创建的所有标记设置优先级。
   确保优先级和严重性较高的标记比那些值较低的标记在列表中位置更高。

![包含十一个已设置优先级的范围标记的列表](img/priority_labels_v16_3.png)

<a id="create-a-group-issue-triage-board"></a>

## 创建群组议题分类看板

为了应对即将到来的议题积压工作，创建一个按标记组织议题的[议题看板](../../user/project/issue_board.md)。
您将使用它来快速创建议题，并通过将卡片拖放到不同的列表中来为议题添加标记。

要设置您的议题看板：

1. 确定看板的范围。
   例如，[创建一个群组议题看板](../../user/project/issue_board.md#group-issue-boards)，您将用它来为议题分配严重性。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的 **triage-tutorial** 群组。
1. 选择 **计划** > **议题看板**。
1. 在议题看板页面的左上角，选择带有当前看板名称的下拉列表。
1. 选择 **创建新看板**。
1. 在 **标题** 字段中，输入 `Issue triage (by severity)`。
1. 保持 **显示开放列表** 复选框被选中，并清除 **显示已关闭列表** 复选框。
1. 选择 **创建看板**。您应该看到一个空看板。
1. 为 `severity::1` 标记创建一个列表：
   1. 在议题看板页面的右上角，选择 **创建列表**。
   1. 在出现的列中，从 **值** 下拉列表中选择 `severity::1` 标记。
   1. 在列表底部，选择 **添加到看板**。
1. 为 `severity::2`、`severity::3` 和 `severity::4` 标记重复上一步。

目前，您看板中的列表应为空。接下来，您将用一些议题填充它们。

<a id="create-issues-for-features"></a>

## 为功能创建议题

要跟踪即将推出的功能和错误，您必须创建一些议题。
议题属于项目，但您也可以直接从您的群组议题看板创建它们。

首先为您计划的功能创建一些议题。
您可以在发现错误时为错误创建议题（希望不会太多！）。

要从您的 **Issue triage (by severity)** 看板创建议题：

1. 转到 **开放** 列表。
   此列表显示不适合任何其他看板列表的议题。
   如果您已经知道您的议题应具有哪个严重性标记，则可以直接从该标记的列表创建它。
   请记住，从标记列表创建的每个议题都会被赋予该标记。

   目前，我们将继续使用 **开放** 列表。
1. 在 **开放** 列表中，选择 **创建新议题** 图标 ({{< icon name="plus" >}})。
1. 填写字段：
   - 在 **标题** 下，输入 `User registration`。
   - 选择此议题适用的项目。我们将选择 `test-project-1`。
1. 选择 **创建议题**。
1. 重复这些步骤以创建更多议题。

   例如，如果您正在构建一个应用程序，假设 `test-project-1` 和 `test-project-2` 指的是应用程序的后端和前端。
   创建以下议题，并根据您的判断分配给项目：

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

您的第一个议题分类看板已就绪！
通过将一些议题从 **开放** 列表拖到其中一个标记列表来尝试一下，以添加一个严重性标记。

![包含未标记议题和已设置优先级的“严重性”标记的议题看板，用于标记议题](img/triage_board_v16_3.png)

## 后续步骤

接下来，您可以：

- 调整您使用议题看板的方式。一些选项包括：
  - 编辑您当前的议题看板，使其也包含优先级和类型标记的列表。
    这样，您将使看板更宽，并且可能需要进行一些水平滚动。
  - 创建名为 `Issue triage (by priority)` 和 `Issue triage (by type)` 的单独议题看板。
    这样，您将使不同类型的分类工作保持独立，但需要在看板之间切换。
  - [为团队交接设置议题看板](../boards_for_teams/_index.md)。
- 在议题列表中按优先级或严重性浏览议题，
  [按每个标记过滤](../../user/project/issues/managing_issues.md#filter-the-list-of-issues)。
  如果您可以使用，请利用
  ["是其中之一" 过滤操作符](../../user/project/issues/managing_issues.md#filter-the-list-of-issues)。
- 将议题分解为[任务](../../user/tasks.md)。
- 创建策略，帮助使用 [`gitlab-triage` gem](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage) 自动化项目中的议题分类。
  生成包含如下热图的摘要报告：

  ![针对带有“优先级”和“严重性”标记的议题的对角热图](img/triage_report_v16_3.png)

要了解有关极狐GitLab 议题分类的更多信息，请参见[议题分类](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/)
和[分类操作](https://handbook.gitlab.com/handbook/engineering/infrastructure-platforms/developer-experience/triage-operations/)。