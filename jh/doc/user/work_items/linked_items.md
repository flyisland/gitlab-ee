---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "在极狐GitLab中连接和跟踪工作项之间的关系。管理依赖关系，将战略目标与执行联系起来，并协调跨职能计划。"
title: 链接项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

链接项在工作项之间创建双向关系，帮助您可视化和管理工作流程中的依赖关系。

通过链接项，您可以连接各种工作项，包括议题、史诗、任务和目标，以显示它们之间的关系。

这些连接帮助每个人理解各个工作如何相互关联以及与更大的战略计划的关系。

<a id="ways-to-use-linked-items"></a>

## 使用链接项的方法

您可以使用链接项来解决多个规划和协调难题。

以下示例展示了链接项如何帮助团队更有效地合作。

<a id="track-dependencies"></a>

### 跟踪依赖项

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

清楚标识出阻塞或被其他项阻塞的工作。

当您以阻塞关系链接项时：

- 团队可以立即看到他们依赖的其他工作。
- 状态更新会在链接项之间自动流动。
- 关闭还有未解决阻塞项的项时，会出现警告。
- 团队可以通过主动处理依赖关系来避免延误。

这种可见性有助于跨团队协调工作并减少瓶颈。

<a id="connect-strategic-goals-with-implementation-details"></a>

### 将战略目标与实施细节连接

使用链接项将高级规划与日常执行连接起来。

当您将战略目标与战术任务链接起来时：

- 团队理解他们的工作如何为更大的目标做出贡献。
- 利益相关者可以追踪从战略到实施的进展。
- 每个人都能看到个人努力如何支持更广泛的愿景。
- 战略的变化可以迅速追溯到受影响的实施工作。

这种层级间的连接能够在整个组织内创造对齐和目标感。

<a id="organize-cross-functional-initiatives"></a>

### 组织跨职能计划

将不同团队和项目中的相关工作链接起来，以协调复杂的计划。

当您为跨职能工作使用链接项时：

- 每个团队可以在自己的领域中工作，同时保持与相关工作的联系。
- 专业团队之间的依赖关系变得可见。
- 状态更新在相关项之间自动流动。
- 团队可以协调努力，而无需频繁开会。

这种协调有助于打破孤岛，并确保计划的所有方面保持同步。

<a id="types-of-linked-items"></a>

## 链接项的类型

极狐GitLab 支持链接各种类型的工作项：

- [议题](../project/issues/related_issues.md) 帮助您跟踪任务、缺陷和功能，并可以链接以显示离散工作片段之间的依赖关系。
- [史诗](../group/epics/linked_epics.md) 让您管理跨职能计划，显示依赖关系，并将战略规划与跨多个团队或项目的执行联系起来。在旗舰版中可用。
- [任务](../tasks.md#linked-items-in-tasks) 为较小的工作单元提供轻量级跟踪，并可以链接到其他项以显示关系或项目中的依赖关系。
- [目标和关键结果](../okrs.md#linked-items-in-okrs) 帮助将战略目标与执行细节连接起来，确保日常工作与更高级别的组织优先级保持一致。
- [事件](../../operations/incident_management/incidents.md) 代表需要紧急恢复的服务中断或故障，并可以链接到相关工作项，以更好地跟踪操作问题及其对计划工作的影响。
- [测试用例](../../ci/test_cases/_index.md) 将测试规划直接集成到您的极狐GitLab 工作流中，让团队在管理代码的同一平台上记录测试场景并跟踪需求。在旗舰版中可用。

<a id="relationship-types"></a>

## 关系类型

当链接项时，您可以指定关系类型：

- **关联**：表示项之间的一般关系。
- **阻塞**：表示一个项阻碍了另一个项的进展。
- **被阻塞**：表示一个项在另一个项解决之前无法继续。

<a id="common-tasks-with-linked-items"></a>

## 链接项的常见任务

通过这些常见步骤学习如何创建和管理工作项之间的关系。

<a id="add-a-linked-item"></a>

### 添加链接项

先决条件：

- 您必须对两个项所在的项目或群组具有访客、计划者、报告者、开发者、维护者或所有者角色。

添加链接项的一般过程在所有工作项类型中类似：

1. 转到您想要修改的工作项。
1. 在描述底部，找到工作项的 **链接项** 部分。
1. 选择 **添加**。
1. 选择关系类型：**关联**、**阻塞** 或 **被阻塞**。
1. 输入要链接的项的引用。您可以：
   - 输入 `#` 或 `&`（取决于项类型），后跟项的编号。
   - 输入文本按标题搜索该项。
   - 粘贴该项的完整 URL。
1. 选择 **添加** 以确认。

或者，您可以使用[快速操作](../project/quick_actions.md)添加链接项：

- `/relate`
- `/blocks`
- `/blocked_by`

有关针对每种工作项类型的详细信息，请参阅相关文档：

- [链接议题](../project/issues/related_issues.md#add-a-linked-issue)
- [链接史诗](../group/epics/linked_epics.md#add-a-linked-item)
- [链接任务](../tasks.md#linked-items-in-tasks)
- [链接 OKR](../okrs.md#linked-items-in-okrs)

<a id="remove-a-linked-item"></a>

### 删除链接项

先决条件：

- 您必须对两个项所在的项目或群组具有访客、计划者、报告者、开发者、维护者或所有者角色。

要删除链接项：

1. 转到您想要修改的工作项。
1. 在描述底部，找到工作项的 **链接项** 部分。
1. 对于每个链接项，选择 **移除** ({{< icon name="close" >}})。

双向关系会从两个项中移除。

或者，您可以使用 [`/unlink` 快速操作](../project/quick_actions.md#unlink) 删除链接项。

<a id="configure-linked-item-display-preferences"></a>

### 配置链接项显示偏好

{{< history >}}

- 在极狐GitLab 18.10 中扩展了链接项的显示选项。

{{< /history >}}

您可以配置 **链接项** 部分显示哪些信息，以便专注于对您工作流最重要的内容。

> [!note]
> 当您更改工作项中显示的信息时，您将为其所在项目和群组中的所有工作项更改此设置。

1. 在 **链接项** 部分标题的右上角，选择 **显示选项** ({{< icon name="preferences" >}})。

   默认情况下，所有选项和字段都可见。
1. 要更改显示的信息，请打开或关闭以下开关：

   - 对于显示选项：
     - **显示已关闭的项**
   - 对于显示的字段：
     - **状态**
     - **指派人**
     - **标签**
     - **权重**
     - **里程碑**
     - **迭代**
     - **日期**
     - **健康状况**
     - **阻塞/被阻塞**