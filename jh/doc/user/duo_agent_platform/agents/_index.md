---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn about foundational, custom, and external agents available in the GitLab Duo Agent Platform.
title: Agent
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../model_selection.md#default-models)

{{< /collapsible >}}

{{< history >}}

- 在 GitLab 18.5 中引入，使用功能标志 `global_ai_catalog`。在 JihuLab.com 上启用。
- 内置 Agent 和自定义 Agent 在 GitLab 18.7 中变更为测试版。
- 内置 Agent、外部 Agent 和自定义 Agent 在 GitLab 18.8 中达到 GA。
- 功能标志 `global_ai_catalog` 在 18.10 中被移除。
- 在 GitLab 18.10 中，JihuLab.com 上的基础版层可通过 极狐GitLab 点数使用。

{{< /history >}}

<a id="agents"></a>

# Agent

Agent 是 AI 驱动的助手，可帮助您完成特定任务并回答复杂问题。

极狐GitLab 提供了三种类型的 Agent：

- [内置 Agent](foundational_agents/_index.md) 是预构建的、生产就绪的 Agent，由 极狐GitLab 为常见工作流创建。这些 Agent 具有针对特定领域的专业知识和工具。内置 Agent 默认开启，因此您可以直接通过 极狐GitLab Duo Chat 开始使用它们。
- [自定义 Agent](custom.md) 是您为团队特定需求创建和配置的 Agent。您可以通过系统提示定义其行为，并选择它们可以访问的工具。当您需要内置 Agent 未涵盖的专业工作流时，自定义 Agent 非常合适。要与自定义 Agent 交互，请在一个群组或项目中启用它，以便在 Chat 中使用它。
- [外部 Agent](external.md) 集成 极狐GitLab 外部的 AI 模型提供商。使用外部 Agent 让模型提供商在 极狐GitLab 中操作。您可以直接从讨论、议题或合并请求触发外部 Agent。

