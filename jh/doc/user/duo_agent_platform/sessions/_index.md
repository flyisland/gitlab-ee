---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: View and manage the status and execution data for agents and flows you have run.
title: 会话
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

会话显示您已运行的 Agent 和流程的状态和执行数据。

会话由极狐GitLab Duo Agentic 聊天以及在 IDE 或 UI 中的内置任务流创建。例如：

- 在 Runner 上执行的流程，例如 [修复你的 CI/CD 流水线流程](../flows/foundational_flows/fix_pipeline.md)。这些会话在 UI 中可见，位于 **AI** > **会话**下。
- 由极狐GitLab Duo Chat 创建的会话。这些会话在右侧边栏中通过选择 **极狐GitLab Duo Chat 聊天历史** 可见。
- 由触发器调用的流程。这些会话在 UI 中可见，位于 **AI** > **会话**下。

<a id="view-sessions-for-your-project"></a>

## 查看项目的会话

前提条件：

- 必须拥有项目的开发者、维护者或所有者角色。

要查看项目的会话：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **会话**。
1. 选择任意会话以查看更多详情。

<a id="view-sessions-you-ve-triggered"></a>

## 查看您触发的会话

要查看您触发的会话：

1. 在右侧边栏中，选择 **极狐GitLab Duo 会话**。
1. 选择任意会话以查看更多详情。
1. 可选。筛选详情以仅显示所有日志或简洁的子集。

<a id="gitlab-duo-agentic-chat-sessions"></a>

## 极狐GitLab Duo Agentic 聊天会话

因为聊天是交互式的，所以它们在 UI 中需要更清晰的分隔。您可以将聊天历史视为专为聊天而存在的会话过滤视图。

要在极狐GitLab Duo CLI 中浏览和切换聊天会话，请参阅 [切换会话](../../gitlab_duo_cli/_index.md#switch-sessions)。

<a id="cancel-a-running-session"></a>

## 取消正在运行的会话

您可以取消正在运行或等待输入的会话。要取消会话：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **会话**。
1. 在 **详情** 选项卡上，滚动到底部。
1. 选择 **取消会话**。
1. 在确认对话框中，选择 **取消会话** 以确认。

取消后：

- 会话状态变为 **已停止**。
- 会话无法恢复或重新开始。

<a id="session-retention"></a>

## 会话保留

会话将在最后一次活动后 30 天自动删除。保留期在您每次与会话交互时重置。例如，如果您每 20 天与会话交互一次，它将永远不会被自动删除。

