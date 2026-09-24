---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 当合并请求就绪时，自动将代码所有者分配为审核人。
title: 自动审核人分配
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您启用自动审核人分配时，极狐GitLab 会将变更文件的
[代码所有者](../../codeowners/_index.md)分配为合并请求上的审核人。
您无需手动从 `CODEOWNERS` 文件中选择审核人。

<a id="prerequisites"></a>

## 先决条件

- 项目必须具有 [`CODEOWNERS` 文件](../../codeowners/_index.md)。
- 项目的维护者或所有者角色。

<a id="enable-automatic-reviewer-assignment"></a>

## 启用自动审核人分配

要为项目开启自动审核人分配：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **设置** > **合并请求**。
1. 转到 **自动审核人分配** 部分。
1. 选择 **自动将所有代码所有者分配为审核人**。
1. 选择 **保存更改**。

<a id="when-gitlab-assigns-reviewers"></a>

## 极狐GitLab 何时分配审核人

开启该设置后，极狐GitLab 会在以下情况将代码所有者分配为审核人：

- 合并请求以就绪状态创建。
- 草稿合并请求被标记为就绪。

极狐GitLab 会分配与合并请求中变更文件匹配的每个代码所有者。

极狐GitLab 在以下情况跳过自动分配：

- 合并请求是草稿。
- 合并请求已有审核人。[`@GitLabDuo`](../duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code) 不在此检查范围内。
- 没有代码所有者与合并请求中变更的文件匹配。
- 合并请求作者没有权限设置合并请求元数据。

<a id="assign-reviewers-with-the-recommend-reviewers-flow"></a>

## 使用“推荐审核人”任务流分配审核人

{{< details >}}

- Status: 测试版

{{< /details >}}

“推荐审核人”任务流会推荐并分配最适合评审您的合并请求的审核人。

它不会分配每个代码所有者，而是根据可用性、工作负载和时区，分配满足每个审批规则所需的最少数量的审核人。

此功能运行在 [极狐GitLab Duo Agent Platform](../../../duo_agent_platform/_index.md) 上。

此任务流取代了极狐GitLab 19.3 及更早版本中使用的 **审核人分配策略** 项目设置。

先决条件：

- 顶级群组的所有者角色，以及项目的维护者或所有者角色。
- [极狐GitLab Duo Agent Platform 的先决条件](../../../duo_agent_platform/_index.md#prerequisites)。
- 在[顶级群组](../../../duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)上启用 **允许任务流执行**、**允许内置任务流** 和 **推荐审核人**。

<a id="use-the-flow"></a>

### 使用任务流

要使用“推荐审核人”任务流，请创建触发器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **触发器**。
1. 选择 **新建任务流触发器**。
1. 在 **描述** 中，为触发器输入描述。
1. 如果显示 **配置来源**，请选择 **任务流或外部 Agent**，然后从任务流列表中选择 **推荐审核人**。
1. 在 **条件** 部分：
   1. 选择 **添加条件**，然后选择 **在事件时**。
   1. 从 **事件** 下拉列表中，选择 **合并请求**。
   1. 从 **运行时机** 下拉列表中，选择 **标记为就绪**。
   1. 选择 **添加事件**。
1. 选择 **创建任务流触发器**。

当具有开发者或更高角色的人员将草稿合并请求标记为就绪时，任务流将运行。

有关创建和编辑触发器的更多信息，请参阅
[触发器](../../../duo_agent_platform/triggers/_index.md)。

<a id="exceptions"></a>

### 例外情况

- 仅当草稿合并请求被标记为就绪时，才会分配审核人。
  当合并请求直接以就绪状态打开时，任务流不会分配审核人。
  有关更多信息，请参阅 [议题 592452](https://gitlab.com/gitlab-org/gitlab/-/issues/592452)。
- 将合并请求标记为就绪的人员必须至少具有项目的开发者角色。当人员角色较低时，任务流不会分配审核人。

<a id="reviewer-selection"></a>

### 审核人选择

“推荐审核人”任务流会读取合并请求上所需的审批规则。
对于每条规则，它会推荐并分配满足该规则所需的最少数量的审核人。
然后，它会添加一条评论来解释这些推荐。
任务流会忽略可选的审批规则。

要在规则的合格审批人之间进行选择，任务流会考虑每个审批人的以下因素：

- 可用性，基于其[状态](../../../profile/_index.md#set-your-status)。
- 评审工作负载，基于等待其评审的未关闭合并请求数量。
- 当地时间，基于其个人资料中的时区。
- 最近的活动。

对于默认的 **所有成员** 规则（未列出审批人），任务流会从项目的直接成员中选择既能审批合并请求又能合并到目标分支的成员。当没有角色可以合并到目标分支时，候选人为所有可以审批的直接成员。从父级群组或受邀群组获得访问权限的成员不是候选人，因此没有直接成员的项目不会获得此规则的推荐。

推荐在后台运行，因此审核人可能需要片刻才能出现。
任务流将审核人分配和评论归属于在顶级群组开启任务流时设置的[服务账号](../../../duo_agent_platform/flows/foundational_flows/_index.md#service-accounts)。
它们不归属于将合并请求标记为就绪的人员。
