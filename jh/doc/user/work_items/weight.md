---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Assign a numerical weight to GitLab work items to represent their estimated effort, value, or complexity and help with planning and prioritization.
title: 工作项权重
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 史诗的工作项权重在极狐GitLab 18.11 引入。

{{< /history >}}

当您拥有大量工作项时，很难获得全局概览。
通过为工作项设置权重，您可以更好地了解特定工作项所需的时间、
价值或复杂度。您也可以[按权重排序](_index.md#sort-work-items)
来查看哪些工作项需要优先处理。

<a id="view-the-work-item-weight"></a>

## 查看工作项权重

您可以在工作项页面本身或整个 UI 中的多个相关面板和列表中查看工作项的权重。

要查看单个工作项的权重：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 选择一个工作项。
1. 在右侧边栏中，在 **权重** 下，查看工作项权重。

要在 **工作项** 列表中查看工作项权重：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 在筛选框中，选择 **权重** ({{< icon name="weight" >}}) 筛选器并添加一个值，例如 `1`。
1. 查看工作项及其权重。

要在议题板上查看工作项权重：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **议题板**。
1. 在单个工作项上，将鼠标悬停在 **权重** ({{< icon name="weight" >}}) 上以查看工作项权重。

要在 **里程碑** 页面上查看工作项权重：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **里程碑**。
1. 选择一个里程碑。
1. 在 **里程碑** 页面上，在右侧边栏的 **总权重** 下，查看工作项权重的总和。

<a id="view-the-work-item-roll-up-weight"></a>

## 查看工作项汇总权重

工作项汇总权重是所有子工作项权重向上汇总到其父项的总和。

例如，如果一个工作项的显式权重为 7，并且有两个子工作项，权重分别为 4 和 5，那么汇总权重将为 9。

要查看工作项的汇总权重：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 选择一个父工作项。
1. 在 **子工作项** 旁边，查看工作项汇总 **权重** ({{< icon name="weight" >}})。

在列表和面板上，仅显示为工作项直接设置的权重。

<a id="set-the-work-item-weight"></a>

## 设置工作项权重

{{< history >}}

- 设置工作项权重的最低角色在极狐GitLab 17.7 从报告者更改为计划者。

{{< /history >}}

前提条件：

- 您必须对父项目或群组具有计划者、报告者、开发者、维护者或所有者角色。

以下规则适用：

- 您可以在创建工作项或编辑工作项时设置工作项权重。
- 您必须输入正整数。
- 当您更改工作项的权重时，新值将覆盖之前的值。

<a id="when-you-create-a-work-item"></a>

### 创建工作项时

要在创建工作项时设置工作项权重，请在 **权重** 下输入一个数字。

<a id="from-an-existing-work-item"></a>

### 从现有工作项

要从现有工作项设置工作项权重：

1. 转到工作项。
1. 在右侧边栏中，在 **权重** 部分，选择 **编辑**。
1. 输入新的权重。
1. 选择下拉列表外的任意区域。

<a id="from-an-issue-board"></a>

### 从议题板

要在[从议题板编辑议题](../project/issue_board.md#edit-an-issue)时设置议题权重：

1. 转到您的议题板。
1. 选择一个议题卡片（不是其标题）。
1. 在右侧边栏中，在 **权重** 部分，选择 **编辑**。
1. 输入新的权重。
1. 选择下拉列表外的任意区域。

<a id="remove-work-item-weight"></a>

## 移除工作项权重

{{< history >}}

- 移除工作项权重的最低角色在极狐GitLab 17.7 从报告者更改为计划者。

{{< /history >}}

前提条件：

- 您必须对父项目或群组具有计划者、报告者、开发者、维护者或所有者角色。

要移除工作项权重，请遵循与[设置工作项权重](#set-the-work-item-weight)相同的步骤，
并选择 **移除权重**。