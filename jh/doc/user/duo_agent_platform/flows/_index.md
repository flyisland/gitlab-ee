---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use foundational and custom flows to automate complex development tasks with multiple agents.
title: 流程
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- LLM：国内 SOTA 大模型

{{< /collapsible >}}

{{< history >}}

- 作为[实验](../../../policy/development_stages_support.md)在极狐GitLab 18.4 中引入，[带有功能标志](../../../administration/feature_flags/_index.md) `ai_catalog_flows`，默认禁用。
- 在极狐GitLab 18.7 中变更为[测试版](../../../policy/development_stages_support.md)。
- 在 JihuLab.com 上于极狐GitLab 18.7 中启用。
- 在私有化部署上于极狐GitLab 18.8 中启用。
- 内置任务流需要额外的功能标志。
- 内置任务流于极狐GitLab 18.8 [GA]。
- 自定义流程于极狐GitLab 18.8 [变更]为测试版。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。

流程是一个或多个代理协同工作以解决复杂问题的组合。

极狐GitLab 提供两种类型的流程：

- [内置任务流](foundational_flows/_index.md) 是极狐GitLab 为常见开发任务创建的预构建、生产就绪的工作流。
- [自定义流程](custom.md) 是您为自动化团队特定流程而创建的工作流。您定义工作流步骤和代理，并定义触发器来控制流程运行的时间。

流程在 IDE 和极狐GitLab UI 中可用。

- 在 UI 中，它们直接在极狐GitLab CI/CD 中运行，帮助您自动化常见开发任务，无需离开浏览器。

有关流程如何在 CI/CD 中执行的更多信息，请参见[流程执行文档](execution.md)。
有关流程安全性的信息，请参见[复合身份文档](../composite_identity.md)。

<a id="prerequisites"></a>

## 先决条件

要使用流程：

- 您必须满足[先决条件](../_index.md#prerequisites)。

要在极狐GitLab UI 中执行流程：

- 您必须使用[极狐GitLab Duo 设置](../../gitlab_duo/turn_on_off.md)开启流程。
- 要使用创建代码的流程，您必须[配置推送规则以允许服务账户](../troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
- 要么[配置您自己的 runner](execution.md#configure-runners)，要么确保[极狐GitLab 托管 runner](../../../ci/runners/hosted_runners/_index.md) 在您的项目中启用并正常工作。

<a id="monitor-running-flows-in-the-gitlab-ui"></a>

## 在极狐GitLab UI 中监控正在运行的流程

要查看为您的项目运行的流程：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **会话**。

<a id="customize-flows-with-agentsmd"></a>

## 使用 `AGENTS.md` 自定义流程

使用 `AGENTS.md` 文件为极狐GitLab Duo 在执行内置任务流和自定义流程时提供上下文和指令。

更多信息，请参见[`AGENTS.md` 自定义文件](../../gitlab_duo/customize_duo/agents_md.md)。

<a id="give-feedback"></a>

## 提供反馈

流程是极狐GitLab AI 驱动的开发平台的一部分。您的反馈有助于我们改进这些工作流。

要报告问题或提出流程改进建议，请[完成此调查](https://gitlab.fra1.qualtrics.com/jfe/form/SV_9GmCPTV7oH9KNuu)。

