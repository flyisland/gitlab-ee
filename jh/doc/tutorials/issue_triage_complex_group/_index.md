---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：为议题分类设置包含子群组的复杂群组'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

议题分类是根据类型和严重程度进行分类的过程。
随着项目的发展，人们创建的议题越来越多，为如何分类传入的议题创建一个工作流程是值得的。

在本教程中，你将学习如何为此场景设置一个包含子群组的极狐GitLab 群组。

要为议题分类设置包含子群组的复杂群组，请执行以下步骤：

1. [创建群组](#create-a-group)
1. [在群组内创建子群组](#create-subgroups-inside-a-group)
1. [在子群组内创建项目](#create-projects-inside-subgroups)
1. [确定类型、严重程度和优先级的标准](#decide-on-the-criteria-for-types-severity-and-priority)
1. [记录你的标准](#document-your-criteria)
1. [创建范围标签](#create-scoped-labels)
1. [为新标签设置优先级](#prioritize-the-new-labels)
1. [创建父群组议题分类板](#create-a-parent-group-issue-triage-board)
1. [为功能创建议题](#create-issues-for-features)

<a id="before-you-begin"></a>

## 准备工作

- 如果你在本教程中使用现有项目，请确保你在项目中具有报告者、开发者、维护者或所有者角色。
  - 如果你的现有项目没有父群组，请创建一个群组，并[将项目标签提升为群组标签](../../user/project/labels.md#promote-a-project-label-to-a-group-label)。

<a id="create-a-group"></a>

## 创建群组

[群组](../../user/group/_index.md)本质上是多个项目的容器。
它允许用户同时管理多个项目并与群组成员沟通。

要创建新群组：

1. 在右上角，选择 **创建新...** ({{< icon name="plus" >}})，然后选择 **新建群组**。
1. 选择 **创建群组**。
1. 输入群组详细信息：
   - 对于 **群组名称**，输入 `Web App Dev` 或其他值。
1. 在页面底部，选择 **创建群组**。

<a id="create-subgroups-inside-a-group"></a>

## 在群组内创建子群组

[子群组](../../user/group/subgroups/_index.md)是群组中的群组。
子群组有助于组织大型项目并管理权限。

要创建新子群组：

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的 **Web App Dev** 群组。
1. 选择 **创建新...** ({{< icon name="plus" >}})，然后选择 **新建子群组**。
1. 输入子群组详细信息：
   - 对于 **子群组名称**，输入 `Frontend` 或其他值。
1. 选择 **创建子群组**。
1. 重复此过程，创建第二个名为 `Backend` 或其他值的子群组。

<a id="create-projects-inside-subgroups"></a>

## 在子群组内创建项目

要跨多个项目管理议题跟踪，你需要在子群组中创建项目。

要创建新项目：

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的 `Frontend` 子群组。
1. 在右上角，选择 **创建新...** ({{< icon name="plus" >}})，然后选择 **新建项目/代码仓**。
1. 选择 **创建空白项目**。
1. 输入项目详细信息：
   - 对于 **项目名称**，输入 `Web UI`。有关更多信息，请参阅项目
     [命名规则](../../user/reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)。
1. 在页面底部，选择 **创建项目**。
1. 重复此过程，在 `Frontend` 子群组中创建第二个名为 `Accessibility Audit` 的项目，并在 `Backend` 子群组中创建第三个名为 `API` 的项目。

<a id="decide-on-the-criteria-for-types-severity-and-priority"></a>

## 确定类型、严重程度和优先级的标准

接下来，你需要确定：

- 你想要识别的议题**类型**。如果你需要更精细的方法，还可以为每种类型创建子类型。类型有助于对工作进行分类，以了解团队所要求的工作类型。
- **优先级**和**严重程度**的级别，以定义传入工作对最终用户的影响，并协助确定优先级。

在本教程中，假设你已确定以下内容：

- 类型：`Bug`、`Feature` 和 `Maintenance`
- 优先级：`1`、`2`、`3` 和 `4`
- 严重程度：`1`、`2`、`3` 和 `4`

有关灵感，请参阅我们在极狐GitLab 中如何定义这些：

- [类型和子类型](https://handbook.gitlab.com/handbook/engineering/metrics/#work-type-classification)
- [优先级](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/#priority)
- [严重程度](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/#severity)

<a id="document-your-criteria"></a>

## 记录你的标准

在就所有标准达成一致后，将其写下来，放在团队成员始终可以访问的地方。

例如，将其添加到项目的[维基](../../user/project/wiki/_index.md)中，或使用[极狐GitLab Pages](../../user/project/pages/_index.md)发布的公司手册中。

<!-- Idea for expanding this tutorial:
     Add steps for [creating a wiki page](../../user/project/wiki/_index.md#create-a-new-wiki-page). -->

<a id="create-scoped-labels"></a>

## 创建范围标签

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

接下来，你将创建标签以添加到议题中，以便对它们进行分类。

最好的工具是[范围标签](../../user/project/labels.md#scoped-labels)，你可以使用它来设置互斥的属性。

根据你[之前](#decide-on-the-criteria-for-types-severity-and-priority)整理的的类型、严重程度和优先级列表，你需要创建匹配的范围标签。

范围标签名称中的双冒号 (`::`) 可防止同一作用域的两个标签同时使用。
例如，如果你将 `type::feature` 标签添加到一个已有 `type::bug` 的议题，则前一个标签会被移除。

> [!note]
> 范围标签在专业版和旗舰版中可用。
> 如果你使用的是基础版，则可以改用常规标签。
> 但是，它们不是互斥的。

要使标签在所有子群组的所有项目中可用，请首先转到包含子群组的父群组。如果你希望标签仅对某个子群组中的项目可用，则从该子群组内部执行以下步骤。

要创建每个标签：

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的 **Web App Dev** 群组。
1. 选择 **管理** > **标签**。
1. 选择 **新建标签**。
1. 在 **标题** 字段中，输入标签名称。从 `type::bug` 开始。
1. 可选。从可用颜色中选择一种颜色，或在 **背景颜色** 字段中输入特定颜色的十六进制颜色值。
1. 选择 **创建标签**。

重复步骤 3-6 以创建你需要的所有标签。
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

## 为新标签设置优先级

现在，将新标签设置为优先级标签。
这样做可以确保在按优先级或标签优先级排序时，最重要的议题显示在议题列表的顶部。

要了解按优先级或标签优先级排序时会发生什么，请参阅
[排序和排列议题列表](../../user/project/issues/sorting_issue_lists.md)。

要为标签设置优先级：

1. 在标签页面上，在你想要设置优先级的标签旁边，选择 **设为优先** ({{< icon name="star-o" >}})。
   此标签现在出现在标签列表的顶部，位于 **已优先处理的标签** 下。
1. 要更改这些标签的相对优先级，请上下拖动它们。
   列表中位置越高的标签优先级越高。
1. 为你之前创建的所有标签设置优先级。
   确保优先级和严重程度较高的标签在列表中的位置高于那些值较低的标签。

![十一个已优先处理的范围标签列表](img/priority_labels_v16_3.png)

<a id="create-a-parent-group-issue-triage-board"></a>

## 创建父群组议题分类板

为了准备处理传入的议题积压，创建一个按标签组织议题的[议题板](../../user/project/issue_board.md)。
你将使用它来快速创建议题，并通过将卡片拖到各个列表来添加标签。

要设置你的议题板：

1. 确定议题板的范围。
   例如，创建一个[群组议题板](../../user/project/issue_board.md#group-issue-boards)来为议题分配严重程度。
1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的 **Web App Dev** 群组。
1. 选择 **计划** > **议题板**。
1. 在议题板页面的左上角，选择带有当前议题板名称的下拉列表。
1. 选择 **创建新议题板**。
1. 在 **标题** 字段中，输入 `Issue triage (by severity)`。
1. 保持选中 **显示开放列表** 复选框，并清除 **显示已关闭列表** 复选框。
1. 选择 **创建议题板**。你应该会看到一个空的议题板。
1. 为 `severity::1` 标签创建一个列表：
   1. 在议题板页面的右上角，选择 **创建列表**。
   1. 在出现的列中，从 **值** 下拉列表中选择 `severity::1` 标签。
   1. 在列表底部，选择 **添加到议题板**。
1. 对 `severity::2`、`severity::3` 和 `severity::4` 标签重复上一步。

要创建子群组议题板，请从子群组内部执行步骤 3-10。

目前，你的议题板中的列表应该是空的。接下来，你将用一些议题填充它们。

<a id="create-issues-for-features"></a>

## 为功能创建议题

要跟踪即将推出的功能和错误，你必须创建一些议题。
议题属于项目，但你也可以直接从群组议题板创建它们。

首先为计划的功能创建一些议题。
你可以在发现错误时为其创建议题（希望不会太多！）。

要从你的 **Issue triage (by severity)** 议题板创建议题：

1. 转到 **开放** 列表。
   此列表显示不适合任何其他议题板列表的议题。
   如果你已经知道你的议题应该具有哪个严重程度标签，则可以直接从该标签的列表创建它。
   请记住，从标签列表创建的每个议题都会被赋予该标签。

   现在，我们将继续使用 **开放** 列表。
1. 在 **开放** 列表中，选择 **创建新议题** 图标 ({{< icon name="plus" >}})。
1. 填写字段：
   - 在 **标题** 下，输入 `Dark mode toggle`。
   - 选择此议题适用的项目。我们将选择 `Frontend / Web UI`。
1. 选择 **创建议题**。
1. 重复这些步骤以创建更多议题。

   例如，如果你正在构建一个 Web API 应用，`Frontend` 和 `Backend` 指的是不同的工程团队。项目指的是堆栈开发的不同方面。
   创建以下议题，并根据需要分配给项目：

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
> 一个项目的议题板中的议题无法从其他项目的议题板中看到。
> 同样，一个子群组中的项目中的议题只能在该子群组的议题板上看到。要查看父群组中每个项目的所有议题，你必须位于父群组的议题板中。

你的第一个分类议题板已准备就绪！
尝试通过将一些议题从 **开放** 列表拖到某个标签列表，以添加其中一个严重程度标签。

![带有未标记议题和用于标记议题的已优先处理的“严重程度”标签的议题板](img/triage_board_v16_3.png)

<a id="next-steps"></a>

## 后续步骤

接下来，你可以：

- 调整你使用议题板的方式。一些选项包括：
  - 编辑你当前的议题板，使其也包含优先级和类型标签的列表。
    这样，议题板会变得更宽，可能需要一些水平滚动。
  - 创建名为 `Issue triage (by priority)` 和 `Issue triage (by type)` 的单独议题板。
    这样，你可以将不同类型的分类工作分开，但需要在议题板之间切换。
  - [为团队交接设置议题板](../boards_for_teams/_index.md)。
- 在议题列表中按优先级或严重程度浏览议题，
  [按每个标签筛选](../../user/project/issues/managing_issues.md#filter-the-list-of-issues)。
  如果你可以使用，请利用
  [“是其中之一”筛选运算符](../../user/project/issues/managing_issues.md#filter-the-list-of-issues)。
- 将议题分解为[任务](../../user/tasks.md)。
- 创建策略，帮助使用 [`gitlab-triage` gem](https://jihulab.com/gitlab-cn/ruby/gems/gitlab-triage) 自动化项目中的议题分类。
  生成带有如下热图的摘要报告：

  ![带有“优先级”和“严重程度”标签的议题的对角线热图](img/triage_report_v16_3.png)

要了解有关极狐GitLab 议题分类的更多信息，请参阅[议题分类](https://handbook.gitlab.com/handbook/product-development/how-we-work/issue-triage/)
和[分类操作](https://handbook.gitlab.com/handbook/engineering/infrastructure-platforms/developer-experience/triage-operations/)。