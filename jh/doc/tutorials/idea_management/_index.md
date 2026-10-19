---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 设置一个包含范围标记和议题看板的项目，以便利益相关者可以提交、投票和排查想法。
title: '教程：为想法管理设置项目'
---

<!-- vale gitlab_base.FutureTense = NO -->

想法管理是指在组织或社区中收集、整理、评估和实施想法。想法可以来自各种利益相关者，例如员工、客户或合作伙伴。

单独的想法待办列表使团队能够在潜在概念和建议完全成形之前对其进行捕获和优先级排序。拥有这个单独的待办列表可以让原始想法更易于管理。它不会用未完善或未经验证的概念弄乱主待办列表。

在本教程中，您将学习如何为想法管理设置极狐GitLab 项目。

要在项目中为想法管理设置极狐GitLab：

1. [创建项目](#create-a-project)
1. [定义想法工作流](#define-the-idea-workflow)
1. [记录您的标准](#document-your-criteria)
1. [创建范围标记](#create-scoped-labels)
1. [创建想法状态看板](#create-an-idea-status-board)
1. [利益相关者提交想法并投票](#stakeholders-submit-and-vote-on-ideas)
1. [排查新想法](#triage-new-ideas)

<a id="before-you-begin"></a>

## 开始之前

- 如果您使用现有项目来完成本教程，请确保您拥有该项目的报告者、开发者、维护者或所有者角色。
- 如果您按照以下步骤操作，并且之后决定为您的项目创建一个
  父群组，为了
  充分利用标记，您必须将项目标记提升为群组标记。

<a id="create-a-project"></a>

## 创建项目

项目包含将用于跟踪想法的议题。

要创建空白项目：

1. 在右上角，选择**新建** ({{< icon name="plus" >}}) 和**新建项目/代码仓库**。
1. 选择**创建空白项目**。
1. 输入项目详细信息。
   - 对于**项目名称**，输入 `Idea management tutorial`。
1. 选择**创建项目**。

<a id="define-the-idea-workflow"></a>

## 定义想法工作流

接下来，您需要确定想法将遵循的**状态工作流**。传达想法的状态有助于与利益相关者设定正确的期望。

对于本教程，假设您已确定以下状态工作流：

- `In Review`
- `Backlog`
- `In Progress`
- `Complete`
- `Rejected`

<a id="document-your-criteria"></a>

## 记录您的标准

在就状态工作流达成一致后，将其写下来，放在您的队友随时可以访问的地方。

例如，将其添加到项目中的 [Wiki](../../user/project/wiki/_index.md)，或使用 [GitLab Pages](../../user/project/pages/_index.md) 发布到您的公司手册中。

<!-- Idea for expanding this tutorial:
     Add steps for [creating a wiki page](../../user/project/wiki/_index.md#create-a-new-wiki-page). -->

<a id="create-scoped-labels"></a>

## 创建范围标记

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

接下来，您将创建标记以添加到想法中，用来表示状态工作流。

最适合此目的的工具是[范围标记](../../user/project/labels.md#scoped-labels)，您可以使用它来设置互斥的属性。

对照您[之前](#define-the-idea-workflow)整理的状态列表进行检查，您需要创建匹配的范围标记。

范围标记名称中的双冒号 (`::`) 可防止同一范围的两个标记一起使用。例如，如果您将 `status::backlog` 标记添加到一个已有 `status::in review`的议题，则前一个标记会被移除。

> [!note]
> 范围标记在专业版和旗舰版中可用。
> 如果您使用的是基础版，可以改用常规标记。
> 但是，它们不是互斥的。

要创建每个标记：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**管理** > **标记**。
1. 选择**新建标记**。
1. 在**标题**文本框中，输入标记的名称。从 `status::in review` 开始。
1. 可选。通过从可用颜色中选择来选择颜色，或在**背景颜色**文本框中输入特定颜色的十六进制颜色值。
1. 选择**创建标记**。

重复这些步骤以创建您需要的所有标记：

- `status::backlog`
- `status::in progress`
- `status::complete`
- `status::rejected`

<a id="create-an-idea-status-board"></a>

## 创建想法状态看板

为了准备接收传入的想法，创建一个[议题看板](../../user/project/issue_board.md)，按标记组织想法。您将使用它通过将卡片拖到各个列表来快速创建议题并为其添加标记。

要设置您的议题看板：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的 **Idea management tutorial** 项目。
1. 选择**计划** > **议题看板**。
1. 在议题看板页面的左上角，选择带有当前看板名称的下拉列表。
1. 选择**创建新看板**。
1. 在**标题字段**中，输入 `Idea status workflow`。
1. 保持选中**显示打开列表**复选框，并清除**显示已关闭列表**复选框。
1. 选择**创建看板**。您应该会看到一个空看板。
1. 为 `status::in review` 标记创建一个列表：
   1. 在议题看板页面的左上角，选择**创建列表**。
   1. 在出现的列中，从**值**下拉列表中，选择 `status::in review` 标记。
   1. 选择**添加到看板**。
1. 对标记 `status::backlog`、`status::in progress`、`status::complete` 和 `status::rejected` 重复上一步骤。

目前，您看板中的列表应该是空的。接下来，您将用一些议题填充它们。

![想法状态看板。](img/blank_idea_board_v16_10.png)

<a id="stakeholders-submit-and-vote-on-ideas"></a>

## 利益相关者提交想法并投票

与利益相关者分享您的想法管理项目，并邀请他们记录他们的想法！

要邀请您的利益相关者：

1. 在左侧边栏中，选择**管理** > **成员**
1. 选择**邀请成员**
1. 输入您利益相关者的电子邮件地址。
1. 选择**报告者**角色。

您的利益相关者现在可以访问您的项目来创建新想法：

1. 在左侧边栏中，选择**计划** > **工作项**。
1. 在右上角，选择**新建项**。
1. 从**类型**下拉列表中，如果尚未选择**议题**，请选择它。
1. 输入标题和描述。
1. 选择**创建议题**。

利益相关者还可以对现有想法点赞，以表示他们对某个想法感兴趣：

1. 在左侧边栏中，选择**计划** > **工作项**。
1. 按**类型** = **议题**筛选列表，然后选择一个议题。
1. 在议题描述下方选择**点赞**[表情回应](../../user/emoji_reactions.md)。

<a id="triage-new-ideas"></a>

## 排查新想法

通过将一些议题从**打开**列表拖到某个标记列表来设置工作流状态，试一试。

![带有示例议题的想法议题看板。](img/populated_idea_board_v16_10.png)

<a id="next-steps"></a>

## 后续步骤

接下来，您可以：

- 创建一个[议题模板](../../user/project/description_templates.md)，以收集来自利益相关者的所有重要
  详细信息。
- 使用[评论和讨论串](../../user/discussions/_index.md)收集有关某个想法的更多信息。
- 将团队待办列表中的议题[关联](../../user/project/issues/related_issues.md)到您的
  想法项目中的议题。
