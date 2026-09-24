---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：为创意管理设置项目'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<!-- vale gitlab_base.FutureTense = NO -->

创意管理是指在组织或社区中收集、组织、评估和实施创意。
创意可以来自各种相关人员，例如员工、客户或合作伙伴。

独立的创意待办列表允许团队在完全细化之前捕捉并确定潜在概念和建议的优先级。
拥有此独立待办列表可实现原始创意的高效管理。
这样就不会让未完善或未验证的概念干扰主待办列表。

在本教程中，您将学习如何为创意管理设置极狐GitLab 项目。

要在项目中为创意管理设置极狐GitLab：

1. [创建项目](#create-a-project)
1. [定义创意工作流](#define-the-idea-workflow)
1. [记录您的标准](#document-your-criteria)
1. [创建作用域标签](#create-scoped-labels)
1. [创建创意状态看板](#create-an-idea-status-board)
1. [相关人员提交创意并投票](#stakeholders-submit-and-vote-on-ideas)
1. [分类新创意](#triage-new-ideas)

<a id="before-you-begin"></a>

## 准备工作

- 如果您在本教程中使用现有项目，请确保您拥有该项目的 报告者、开发者、维护者或所有者 角色。
- 如果您按照以下步骤操作后决定为您的项目创建父群组，为了最佳利用标签，您将不得不将项目标签提升为群组标签。

<a id="create-a-project"></a>

## 创建项目

项目包含将用于跟踪创意的议题。

要创建空白项目：

1. 在右上角，选择 **创建新** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 选择 **创建空白项目**。
1. 输入项目详细信息。
   - 对于 **项目名称**，输入 `创意管理教程`。
1. 选择 **创建项目**。

<a id="define-the-idea-workflow"></a>

## 定义创意工作流

接下来，您需要确定创意将遵循的 **状态工作流**。
传达创意的状态有助于设定相关人员的正确期望。

对于本教程，假设您决定采用以下状态工作流：

- `审核中`
- `待办`
- `进行中`
- `已完成`
- `已拒绝`

<a id="document-your-criteria"></a>

## 记录您的标准

在商定状态工作流后，请将其记录在团队成员随时可以访问的地方。

例如，将其添加到您项目的[维基](../../user/project/wiki/_index.md)中，或者添加到使用[极狐GitLab Pages](../../user/project/pages/_index.md)发布的公司手册中。

<!-- Idea for expanding this tutorial:
     Add steps for [creating a wiki page](../../user/project/wiki/_index.md#create-a-new-wiki-page). -->

<a id="create-scoped-labels"></a>

## 创建作用域标签

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

接下来，您将创建标签，添加到创意中以表示状态工作流。

最适合此用途的工具是[作用域标签](../../user/project/labels.md#scoped-labels)，您可以使用它们来设置互斥属性。

对照您[之前](#define-the-idea-workflow)汇总的状态列表，您需要创建匹配的作用域标签。

作用域标签名称中的双冒号（`::`）可防止同一作用域的两个标签同时使用。
例如，如果您将 `status::backlog` 标签添加到一个已有 `status::in review` 标签的议题，则前一个标签将被移除。

> [!note]
> 作用域标签在专业版和旗舰版中可用。
> 如果您使用的是基础版，则可以改用普通标签。
> 但是，它们不是互斥的。

要创建每个标签：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **管理** > **标签**。
1. 选择 **新建标签**。
1. 在 **标题** 字段中，输入标签名称。从 `status::in review` 开始。
1. 可选。通过从可用颜色中选择来选择一种颜色，或在 **背景颜色** 字段中为特定颜色输入十六进制颜色值。
1. 选择 **创建标签**。

重复这些步骤以创建您需要的所有标签：

- `status::backlog`
- `status::in progress`
- `status::complete`
- `status::rejected`

<a id="create-an-idea-status-board"></a>

## 创建创意状态看板

为了应对即将到来的创意，创建一个按标签组织创意的[议题看板](../../user/project/issue_board.md)。
您将使用它通过将卡片拖到各个列表来快速创建议题并为其添加标签。

要设置您的议题看板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的 **创意管理教程** 项目。
1. 选择 **计划** > **议题看板**。
1. 在议题看板页面的左上角，选择包含当前看板名称的下拉列表。
1. 选择 **创建新看板**。
1. 在 **标题字段** 中，输入 `创意状态工作流`。
1. 保持选中 **显示开放列表** 复选框，并清除 **显示关闭列表** 复选框。
1. 选择 **创建看板**。您应该会看到一个空看板。
1. 为 `status::in review` 标签创建列表：
   1. 在议题看板页面的左上角，选择 **创建列表**。
   1. 在出现的列中，从 **值** 下拉列表中选择 `status::in review` 标签。
   1. 选择 **添加到看板**。
1. 对标签 `status::backlog`、`status::in progress`、`status::complete` 和 `status::rejected` 重复上一步。

目前，您看板中的列表应为空。接下来，您将用一些议题填充它们。

![创意状态看板](img/blank_idea_board_v16_10.png)

<a id="stakeholders-submit-and-vote-on-ideas"></a>

## 相关人员提交创意并投票

与相关人员分享您的创意管理项目，并邀请他们记录他们的创意！

要邀请您的相关人员：

1. 在左侧边栏中，选择 **管理** > **成员**
1. 选择 **邀请成员**
1. 输入您的相关人员的电子邮件地址。
1. 选择 **报告者** 角色。

您的相关人员现在可以访问您的项目来创建新创意：

1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 在右上角，选择 **新建工作项**。
1. 从 **类型** 下拉列表中，选择 **议题**（如果尚未选择）。
1. 输入标题和描述。
1. 选择 **创建议题**。

相关人员还可以对现有创意进行赞成投票，以表明他们对某个创意感兴趣：

1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 按 **类型** = **议题** 过滤列表，然后选择一个议题。
1. 在议题描述下方选择 **赞** [表情符号反应](../../user/emoji_reactions.md)。

<a id="triage-new-ideas"></a>

## 分类新创意

通过将一些议题从 **Open** 列表拖到某个标签列表中来尝试设置工作流状态。

![带有示例议题的创意看板](img/populated_idea_board_v16_10.png)

<a id="next-steps"></a>

## 后续步骤

接下来，您可以：

- 创建一个[议题模板](../../user/project/description_templates.md)，以收集您相关人员所有重要详细信息。
- 使用[评论和讨论串](../../user/discussions/_index.md)收集有关创意的更多信息。
- 将团队待办列表中的议题与创意项目中的议题[关联](../../user/project/issues/related_issues.md)。