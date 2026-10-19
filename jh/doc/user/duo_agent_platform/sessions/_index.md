---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 查看并管理您运行过的 Agent 和任务流的状态与执行数据。
title: 会话
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

会话会显示您运行过的 Agent 和任务流的状态与执行数据。

会话由极狐GitLab Duo Agentic Chat 和 IDE 或 UI 中的内置任务流创建。例如：

- 在 Runner 上执行的任务流，例如[修复 CI/CD 流水线任务流](../flows/foundational_flows/fix_pipeline.md)。
  这些会话可在 UI 中的 **AI** > **会话**下查看。
- 在 IDE 中运行的任务流，例如 [软件开发任务流](../flows/foundational_flows/software_development.md)。
  这些会话可在 IDE 的 **任务流** 标签页中的 **会话** 下查看。
- 由极狐GitLab Duo Chat 创建的会话。选择 **极狐GitLab Duo Chat 聊天历史**，
  即可在右侧边栏中查看这些会话。
- 由触发器调用的任务流。这些会话可在 UI 中的 **AI** > **会话**下查看。

<a id="view-sessions-for-your-project"></a>

## 查看项目的会话

先决条件：

- 您必须拥有该项目的开发者、维护者或所有者角色。

查看项目的会话：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **会话**。
1. 选择任意会话以查看更多详情。

<a id="view-sessions-youve-triggered"></a>

## 查看您触发的会话

查看您触发的会话：

1. 在右侧边栏中，选择 **极狐GitLab Duo 会话**。
1. 选择任意会话以查看更多详情。
1. 可选。筛选详情，以显示所有日志或仅显示精简的子集。

<a id="gitlab-duo-agentic-chat-sessions"></a>

## 极狐GitLab Duo Agentic Chat 会话

由于聊天是交互式的，因此需要在 UI 中进行更清晰的区分。您可以将聊天历史视为一种仅针对聊天存在的、经过筛选的会话视图。

要在极狐GitLab Duo CLI 中浏览和切换聊天会话，请参阅[切换会话](../../gitlab_duo_cli/use.md#switch-sessions)。

<a id="cancel-a-running-session"></a>

## 取消正在运行的会话

您可以取消正在运行或等待输入的会话。取消会话：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **会话**。
1. 在**详情**标签页上，滚动到底部。
1. 选择**取消会话**。
1. 在确认对话框中，选择**取消会话**以确认。

取消后：

- 会话状态变为**已停止**。
- 该会话无法恢复或重新启动。

<a id="review-and-control-agent-actions"></a>

## 审查和控制 Agent 操作

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 您的自定义任务流必须在其任务流定义 YAML 中包含 [`HumanInputComponent`](https://jihulab.com/gitlab-cn/modelops/ai-assist/-/blob/main/docs/flow_registry/v1.md#humaninputcomponent)。

当任务流到达人工交互检查点时，执行会暂停，会话将等待您的输入。

<a id="approval-notifications"></a>

### 审批通知

当任务流在检查点暂停时，极狐GitLab 会通过两种方式通知您：

- **待办事项**：一个标记为 **Duo 工作流需要审批**的待办事项会添加到
  **您的工作** > **待办事项列表**。该事项会直接链接到会话，您可以在其中采取操作。
  当您批准、拒绝或修改请求时，或者当工作流被取消或停止时，极狐GitLab 会自动将该待办事项标记为已完成。
- **电子邮件**：系统会发送一封电子邮件通知，其中包含工作流名称、所属项目、
  已完成操作和待处理请求的摘要，以及审批 UI 的直接链接。

<a id="respond-to-an-agent-checkpoint"></a>

### 响应 Agent 检查点

审查并响应 Agent 检查点：

1. 在极狐GitLab Duo 边栏中，选择 **会话**。
1. 选择正在等待您审查的会话。
1. 审查 Agent 已完成的操作及其建议的后续步骤。
1. 选择以下选项之一：
   - **批准**：允许 Agent 继续执行其计划的操作。
   - **拒绝**：立即停止任务流执行。
   - **修改**：向 Agent 发送反馈或建议。Agent 会返回检查点以进行再次审查。

<a id="session-retention"></a>

## 会话保留

会话会在最后一次活动 30 天后自动删除。每次您与会话交互时，保留期都会重置。例如，如果您每 20 天与会话交互一次，该会话就永远不会被自动删除。

在 IDE 中，您也可以在 30 天保留期到期之前手动删除会话。
