---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为极狐GitLab Duo 功能配置大语言模型。
title: 模型选择
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise
- Offering: 私有化部署

{{< /details >}}

每个极狐GitLab Duo 功能都有一个由极狐GitLab 选择的默认大语言模型（LLM）。

极狐GitLab 可以更新此默认模型以优化功能性能。因此，功能使用的模型可能会在您不采取任何操作的情况下发生变化。

模型变更来自极狐GitLab AI 网关，并且无论您的极狐GitLab 版本如何，都会生效，除非另有说明。

如果您不想为每个功能使用默认模型，或者有特定要求，您可以从一系列其他受支持的模型中进行选择。

如果您为某个功能选择了特定模型，则该功能会一直使用该模型，直到您选择其他模型。

<a id="select-a-model-for-the-instance"></a>

## 为实例选择模型

您可以为某个功能选择默认模型，该默认值将应用于整个实例。如果您未选择特定模型，则所有极狐GitLab Duo 功能都将使用极狐GitLab 的默认模型。

> [!note]
> 对于使用离线许可证的极狐GitLab 私有化部署实例，要更改极狐GitLab Duo Agent Platform 中功能的模型，您必须拥有 [极狐GitLab Duo Agent Platform 自部署版本](../../subscriptions/subscription-add-ons.md) 附加组件。

先决条件：

- 您必须是管理员。

> [!note]
> 对于极狐GitLab 19.0 或更早版本，代码评审任务流和极狐GitLab Duo 代码评审共享相同的模型设置。您对模型所做的更改会影响这两个功能。

要为某个功能选择模型：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **模型选择** 下，选择 **管理模型**。如果未显示 **模型选择**，请验证是否为您的实例配置了极狐GitLab Duo Enterprise 附加组件。
1. 对于您要配置的功能，从下拉列表中选择一个模型作为默认模型。
1. 可选。要将该模型应用于该部分中的所有功能，请选择 **全部应用**。

   > [!note]
   > 如果您为所有功能选择 **默认**，则每个功能将使用各自的极狐GitLab 默认模型，不同功能之间可能有所不同。

<a id="select-a-model-for-agentic-chat"></a>

### 为 Agentic Chat 选择模型

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **模型选择** 下，选择 **管理模型**。
1. 转到 **极狐GitLab Duo Agentic Chat** 部分。
1. 从下拉列表中选择一个模型作为默认模型。如果您计划限制对其他模型的访问，请选择极狐GitLab 托管的模型作为默认模型。
1. 可选。要限制用户可以为 Agentic Chat 选择的其他模型：

   1. 在 **可用模型** 下，选择 **配置**。
   1. 在 **可用模型：Agentic Chat** 对话框中，选中 **限制为特定模型** 复选框。
   1. 选择您希望 Agentic Chat 能够使用的模型。要选择所有模型，请选中 **选择所有模型** 复选框。当所有模型都被选中时，选择 **清除所有模型** 以清除选择。

      > [!note]
      > 默认模型始终对用户可用，且无法清除。要保存您的更改，您必须至少选择一个除默认模型之外的模型。

   1. 选择 **保存**。

   > [!note]
   > 要将 Agentic Chat 限制为特定模型，您必须选择极狐GitLab 托管的模型作为默认模型。如果您不将 Agentic Chat 限制为特定模型，用户可以从所有极狐GitLab 托管的模型中进行选择。

<a id="select-a-model-for-code-review-flow"></a>

### 为代码评审任务流选择模型

对于代码评审任务流，模型选择的设置因您的极狐GitLab 版本而异。

{{< tabs >}}

{{< tab title="GitLab 19.1 or later" >}}

要为代码评审任务流选择模型：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **模型选择** 下，选择 **管理模型**。
1. 在 **极狐GitLab Duo Agent Platform** 下，找到 **Agentic 代码评审**。
1. 从下拉列表中选择一个模型作为默认模型。

有关可用模型的列表，请参阅 [Agent Platform AI 模型](../../user/duo_agent_platform/model_selection.md#supported-models)。

{{< /tab >}}

{{< tab title="GitLab 19.0 or earlier" >}}

代码评审任务流与极狐GitLab Duo 代码评审（该功能的非 Agentic 版本）共享模型设置。您选择的模型适用于这两个功能，并且您只能从[可用模型](../../user/gitlab_duo/model_selection.md#gitlab-duo-for-merge-requests)中选择，这些模型适用于非 Agentic 功能。

要为代码评审任务流选择模型：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **模型选择** 下，选择 **管理模型**。
1. 在 **极狐GitLab Duo for merge requests** 下，找到 **代码评审**。
1. 从下拉列表中选择一个模型作为默认模型。

{{< /tab >}}

{{< /tabs >}}
