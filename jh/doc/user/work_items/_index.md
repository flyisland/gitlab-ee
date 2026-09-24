---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "用极狐GitLab工作项组织团队工作。在统一视图中追踪任务、史诗、议题和目标，将战略与实施联系起来并监控进展。"
title: 工作项
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

工作项是极狐GitLab 中规划和跟踪工作的核心元素。
规划与跟踪产品开发往往需要将工作分解为更小、更易管理的部分，同时保持与大图的关联。
工作项正是围绕这一基本需求设计的，它提供了一种统一的方式来表示任何层级的工作单元，从战略举措到单个任务。

工作项的层次结构使得不同层级的工作之间关系清晰，帮助团队理解日常任务如何贡献于更大目标，以及战略目标如何分解为可操作的组件。

这种结构支持多种规划框架，例如 Scrum、看板以及组合管理方法，同时让团队能够洞察各个层级的进展。

## 工作项类型

<a id="work-item-types"></a>

极狐GitLab 支持以下工作项类型：

- [议题](../project/issues/_index.md)：追踪任务、功能及缺陷。
- [史诗](../group/epics/_index.md)：管理跨多个里程碑和议题的大型举措。
- [任务](../tasks.md)：追踪小型工作单元。
- [目标与关键结果](../okrs.md)：追踪战略目标及其可衡量的成果。
- [测试用例](../../ci/test_cases/_index.md)：将测试规划直接集成到你的极狐GitLab 工作流中。

## 查看所有工作项

<a id="view-all-work-items"></a>

{{< history >}}

- 在极狐GitLab 18.7 中[引入](https://gitlab.com/groups/gitlab-org/-/epics/11918)，使用名为 `work_item_planning_view` 的功能标志。默认禁用。
- 在极狐GitLab 18.10 中[GA](https://gitlab.com/gitlab-org/gitlab/-/work_items/520452)。功能标志 `work_item_planning_view` 已移除。

{{< /history >}}

**工作项** 列表是查看和管理项目或群组中所有工作项类型（如议题、史诗和任务）的集中位置。使用此视图来了解项目或群组中的全部工作范围并有效排定优先级。

在早期版本的极狐GitLab 中，议题和史诗在 **规划** > **议题** 和 **规划** > **史诗** 下拥有各自独立的列表页面。在极狐GitLab 18.10 及更高版本中，这些页面被 **规划** > **工作项** 取代，后者将所有工作项类型整合到单一视图中。如果你之前将 **议题** 或 **史诗** 固定在侧边栏中，**工作项** 则会被固定在其位置上。包含 `/epics/:iid` 或 `/issues/:iid` 的 URL 会自动重定向到 `/work_items/:iid`。

要查看项目或群组的工作项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **规划** > **工作项**。

### 筛选工作项

<a id="filter-work-items"></a>

默认情况下，**工作项** 列表会显示所有工作项类型。要查看特定类型（例如，仅议题或仅史诗），请使用 **类型** 筛选器。

要筛选工作项列表：

1. 在页面顶部，从筛选栏中选择一个筛选器、操作符及其值。例如，要仅查看史诗，请选择筛选器 **类型**、操作符 **是** 以及值 **史诗**。
1. 可选。添加更多筛选器以细化搜索。
1. 按下 <kbd>Enter</kbd> 或选择搜索图标 ({{< icon name="search" >}})。

#### 可用筛选器

<a id="available-filters"></a>

{{< history >}}

- 按描述筛选在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/536876)。

{{< /history >}}

工作项可用的筛选器如下：

- 指派人
  - 操作符：`是`、`不是其中之一`、`是其中之一`
- 作者
  - 操作符：`是`、`不是其中之一`、`是其中之一`
- 机密
  - 值：`是`、`否`
- 联系人
  - 操作符：`是`
- 状态
  - 操作符：`是`
- 健康状态
  - 操作符：`是`、`不是`
- 迭代
  - 操作符：`是`、`不是`
- 标签
  - 操作符：`是`、`不是其中之一`、`是其中之一`
- 里程碑
  - 操作符：`是`、`不是`
- 我的反应
  - 操作符：`是`、`不是`
- 组织
  - 操作符：`是`
- 父项
  - 操作符：`是`、`不是`
  - 值：任何 `议题`、`史诗`、`目标`
- 发布
  - 操作符：`是`、`不是`
- 搜索范围
  - 操作符：`标题`、`描述`
- 状态
  - 值：`任意`、`开放`、`已关闭`
- 类型
  - 值：`议题`、`事件`、`任务`、`史诗`、`目标`、`关键结果`、`测试用例`
- 权重
  - 操作符：`是`、`不是`

要访问最近使用过的筛选器，请在筛选栏左侧选择 **最近搜索** ({{< icon name="history" >}}) 下拉列表。

### 排序工作项

<a id="sort-work-items"></a>

{{< history >}}

- 按状态排序在极狐GitLab 18.5 中[引入](https://gitlab.com/groups/gitlab-org/-/epics/18638)，使用名为 `work_item_status_mvc2` 的功能标志。默认启用。
- 按状态排序在极狐GitLab 18.6 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/576610)。功能标志 `work_item_status_mvc2` 已移除。

{{< /history >}}

可按以下条件对工作项列表进行排序：

- 创建日期
- 更新日期
- 开始日期
- 截止日期
- 标题
- 状态
- 权重

要更改排序条件：

- 在筛选栏右侧，选择 **创建日期** 下拉列表。

要在升序和降序之间切换排序顺序：

- 在筛选栏右侧，选择 **排序方向** ({{< icon name="sort-lowest" >}} 或 {{< icon name="sort-highest" >}})。

有关排序逻辑的更多信息，请参阅[议题列表的排序与排序规则](../project/issues/sorting_issue_lists.md)。

## 配置列表显示偏好

<a id="configure-list-display-preferences"></a>

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/393559)。
- 在极狐GitLab 18.7 中[添加](https://gitlab.com/gitlab-org/gitlab/-/issues/520791)了对议题的支持。

{{< /history >}}

通过显示或隐藏特定的元数据字段并配置查看偏好，自定义工作项在列表页面上的显示方式。

极狐GitLab 在不同层级保存你的显示偏好：

- **字段**：按命名空间保存。你可以根据工作流需求，为不同的群组和项目设置不同的字段可见性。例如，你可以在一个群组或项目中显示指派人及标签，而在另一个中隐藏它们。
- **你的偏好**：在所有项目及群组中全局保存。这确保你查看工作项的首选方式具有一致的行为。

要配置显示偏好：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **规划** > **工作项**。
1. 在筛选栏右侧，选择 **显示选项** ({{< icon name="preferences" >}})。
1. 在 **字段** 下，开启或关闭你想要显示的元数据：
   - 状态（针对议题）
   - 指派人
   - 标签
   - 权重（针对议题）
   - 里程碑
   - 迭代（针对议题）
   - 日期：截止日期和日期范围
   - 健康度：健康状态指标
   - 阻塞/被阻塞：阻塞关系指标
   - 评论：评论计数
   - 热度：热度指标
1. 在 **你的偏好** 下，开启或关闭 **在侧边面板中打开条目**，以选择选中史诗时的打开方式：
   - 开启（默认）：条目在屏幕右侧的抽屉中打开。
   - 关闭：条目以完整页面视图打开。

你的偏好会被保存，并在所有会话及设备中保留。

## 工作项 Markdown 引用

<a id="work-item-markdown-reference"></a>

{{< history >}}

- 在极狐GitLab 18.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/352861)，使用名为 `extensible_reference_filters` 的功能标志。默认禁用。
- 在极狐GitLab 18.2 中[GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/197052)。功能标志 `extensible_reference_filters` 已移除。

{{< /history >}}

你可以在极狐GitLab 风格的 Markdown 字段中通过 `[work_item:123]` 引用工作项。
更多信息，请参阅[极狐GitLab 特定引用](../markdown.md#gitlab-specific-references)。

## 合并请求中的工作项

<a id="work-items-in-merge-requests"></a>

{{< history >}}

- 在极狐GitLab 18.11 中[引入](https://gitlab.com/groups/gitlab-org/plan-stage/-/work_items/456)，使用名为 `mr_related_work_items` 的功能标志。默认禁用。
- 在极狐GitLab 19.0 中[GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/233554)。功能标志 `mr_related_work_items` 已移除。

{{< /history >}}

当你在合并请求描述中引用工作项时，它会自动出现在合并请求侧边栏的 **工作项** 小组件中。该小组件将工作项分为两类：

- **关闭中**：使用[自动关闭模式](../project/issues/managing_issues.md#closing-issues-automatically)链接的工作项，例如 `Closes #123`。这些工作项在 MR 合并时自动关闭。
- **提及**：在描述中引用但未使用关闭模式链接的工作项，例如 `Related to #456`。这些工作项在 MR 合并时不会被关闭。

如果小组件中包含超过两个工作项，它默认会折叠。选择小组件标题可将其展开。选择任一工作项可在抽屉中打开。

## 相关主题

<a id="related-topics"></a>

- [关联议题](../project/issues/related_issues.md)
- [关联史诗](../group/epics/linked_epics.md)
- [议题看板](../project/issue_board.md)
- [标签](../project/labels.md)
- [迭代](../group/iterations/_index.md)
- [里程碑](../project/milestones/_index.md)
- [自定义字段](custom_fields.md)