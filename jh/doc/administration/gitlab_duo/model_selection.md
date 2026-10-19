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

极狐GitLab 可以更新此默认模型以优化功能性能。因此，功能的模型可能会在您未采取任何操作的情况下发生变化。

模型变更来自极狐GitLab AI 网关，除非另有说明，否则无论您的极狐GitLab 版本如何都会生效。

如果您不想为每个功能使用默认模型，或有特定要求，可以从一系列其他可用的受支持模型中进行选择。

如果您为某个功能选择了特定模型，该功能会一直使用该模型，直到您选择另一个模型。

<a id="select-a-model-for-the-instance"></a>

## 为实例选择模型

您可以为某个功能选择默认模型，该默认值将应用于整个实例。如果您未选择特定模型，所有极狐GitLab Duo 功能都会使用极狐GitLab 默认模型。

> [!note]
> 对于使用离线许可证的极狐GitLab 私有化部署实例，极狐GitLab 托管模型不可用。
> 离线许可证无法连接到为其提供服务的 JihuLab.com AI 网关，因此
> 模型选择列表不包含极狐GitLab 托管模型，也不会显示错误。
> 要更改极狐GitLab Duo Agent Platform 中功能的模型，您必须拥有
> [极狐GitLab Duo Agent Platform 自部署版本](../../subscriptions/subscription-add-ons.md)附加组件
> 并[配置自部署模型](../gitlab_duo_self_hosted/configure_duo_features.md)。

先决条件：

- 您必须是管理员。

> [!note]
> 对于极狐GitLab 19.0 或更早版本，代码评审任务流和极狐GitLab Duo 代码评审共用同一个模型设置。
> 您对模型所做的更改会同时影响这两个功能。

要为某个功能选择模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在**模型选择**下，选择**管理模型**。如果未显示**模型选择**，请确认您的实例已配置极狐GitLab Duo Enterprise 附加组件。
1. 对于您要配置的功能，从下拉列表中选择一个模型
   以将其设置为默认模型。
1. 可选。要将某个模型应用于某个部分中的多个功能，请从**批量更新**下拉列表中选择一个模型。
   该模型仅应用于与其兼容的功能。
1. 可选。要将某个部分中的所有功能切换回其默认模型，请选择**重置为默认值**。

   > [!note]
   > 当您重置为默认值时，每个功能都会使用其各自的极狐GitLab
   > 默认模型，不同功能之间可能有所不同。

<a id="select-a-model-for-agentic-chat"></a>

### 为 Agentic Chat 选择模型

要为 Agentic Chat 选择模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在**模型选择**下，选择**管理模型**。
1. 转到 **极狐GitLab Duo Agentic 聊天** 部分。
1. 从**默认模型**下拉列表中，选择一个模型。
   默认情况下该模型会被固定，用户无法更改，
   除非您选择了极狐GitLab 默认模型。
   在这种情况下，所有极狐GitLab 托管模型都可供用户使用。
1. 可选。要将 Agentic Chat 限制为特定模型：

   1. 在**默认模型**下拉列表下，选择**配置**。
   1. 在**可用模型：Agentic Chat** 对话框中，选中
      **限制为特定模型**复选框。
   1. 选择您希望 Agentic Chat 使用的模型。
      要选择所有模型，请选中**选择所有模型**复选框。
      要清除所有已选模型，请选择**清除所有模型**。

      > [!note]
      > 默认模型始终可供用户使用，且无法清除。
      > 要保存更改，除默认模型外，您还必须至少选择一个模型。

   1. 选择**保存**。

   > [!note]
   > 要将 Agentic Chat 限制为特定模型，您必须选择一个极狐GitLab 托管模型
   > 作为默认模型。

<a id="select-a-model-for-code-review-flow"></a>

### 为代码评审任务流选择模型

对于代码评审任务流，模型选择的设置因您的极狐GitLab 版本而异。

{{< tabs >}}

{{< tab title="GitLab 19.1 or later" >}}

要为代码评审任务流选择模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在**模型选择**下，选择**管理模型**。
1. 在**极狐GitLab Duo Agent Platform** 下，找到 **Agentic 代码评审**。
1. 从下拉列表中选择一个模型以将其设置为默认模型。

有关可用模型的列表，请参阅 [Agent Platform AI 模型](../../user/duo_agent_platform/model_selection.md#supported-models)。

{{< /tab >}}

{{< tab title="GitLab 19.0 or earlier" >}}

代码评审任务流与极狐GitLab Duo 代码评审（该功能的非 Agentic 版本）共用同一个模型设置。
您选择的模型会同时应用于这两个功能，并且您只能从非 Agentic 功能
[可用的模型](../../user/gitlab_duo/model_selection.md#gitlab-duo-for-merge-requests)中进行选择。

要为代码评审任务流选择模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在**模型选择**下，选择**管理模型**。
1. 在 **极狐GitLab Duo 用于合并请求** 下，找到 **代码评审**。
1. 从下拉列表中选择一个模型以将其设置为默认模型。

{{< /tab >}}

{{< /tabs >}}
