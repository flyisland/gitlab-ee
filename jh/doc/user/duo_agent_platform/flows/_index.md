---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用内置任务流和自定义任务流，通过多个 Agent 自动执行复杂的开发任务。
title: 任务流
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- LLM: DeepSeek-V4-Pro-0813

{{< /collapsible >}}

任务流是一个或多个 Agent 协同工作以解决复杂问题的组合。

极狐GitLab 提供两种类型的任务流：

- [内置任务流](foundational_flows/_index.md)是由 GitLab 为常见开发任务创建的预构建、
  生产就绪的工作流。
- [自定义任务流](custom.md)是您为自动化团队特定流程而创建的工作流。您需要定义工作流步骤和 Agent，并定义触发器以控制任务流的运行时机。

任务流可在 IDE 和极狐GitLab UI 中使用。

- 在 UI 中，它们直接在极狐GitLab CI/CD 中运行，帮助您自动执行常见开发任务，无需离开浏览器。
- 在 IDE 中，软件开发任务流可在 VS Code、Visual Studio 和 JetBrains 中使用。其他任务流的支持正在提议中。

有关任务流如何在 CI/CD 中执行的更多信息，请参阅[任务流执行文档](execution/_index.md)。有关任务流安全性的信息，请参阅[复合身份文档](../composite_identity.md)。

<a id="prerequisites"></a>

## 先决条件

<!-- Note: These prerequisites are duplicated on each flow sub-page. Update all pages when editing. -->

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../_index.md#prerequisites)。
- 为顶级群组[开启**允许内置任务流**](foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- [配置推送规则以允许服务账号](../troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
- [配置您自己的 Runner](execution/_index.md#configure-runners-to-execute-flows)，或为您的项目开启[极狐GitLab 托管 Runner](../../../ci/runners/hosted_runners/_index.md)。

<a id="monitor-running-flows-in-the-gitlab-ui"></a>

## 在极狐GitLab UI 中监控正在运行的任务流

要查看项目中正在运行的任务流：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **会话**。

<a id="view-flow-history-in-the-ides"></a>

## 在 IDE 中查看任务流历史

要查看您在项目中运行过的任务流历史：

- 在**任务流**标签页上，向下滚动并查看**最近的 Agent 会话**。

<a id="customize-flows-with-agentsmd"></a>

## 使用 `AGENTS.md` 自定义任务流

使用 `AGENTS.md` 文件为极狐GitLab Duo 提供在执行内置任务流和自定义任务流时应遵循的上下文和指令。

更多信息，请参阅 [`AGENTS.md` 自定义文件](../customize/agents_md.md)。

<a id="give-feedback"></a>

## 提供反馈

任务流是极狐GitLab AI 驱动开发平台的一部分。您的反馈有助于我们改进这些工作流。要报告问题或为任务流提出改进建议，
[请完成此调查](https://gitlab.fra1.qualtrics.com/jfe/form/SV_9GmCPTV7oH9KNuu)。
