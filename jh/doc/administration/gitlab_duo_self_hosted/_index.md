---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Host your own AI Gateway and language models.
title: 自部署模型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中引入，有一个名为 `ai_custom_model` 的[功能标志](../feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 17.6 中，私有化部署实例上启用。
- 在极狐GitLab 17.6 及更高版本中，要求使用极狐GitLab Duo 附加组件。
- 功能标志 `ai_custom_model` 在极狐GitLab 17.8 中移除。
- 在极狐GitLab 17.9 中 GA。
- 在极狐GitLab 18.0 中，纳入专业版。
- 在极狐GitLab 18.8 中，针对离线许可证要求使用极狐GitLab Duo Agent Platform 自部署附加组件。
- 在极狐GitLab 18.9 中，针对在线许可证的极狐GitLab Duo Agent Platform 改为按量计费。

{{< /history >}}

托管自己的 AI 基础设施，以使用您选择的 LLM 来利用极狐GitLab Duo 功能。使用自部署 AI 网关将所有请求和响应数据保留在您自己的环境中，避免外部 API 调用，并管理发往您的 LLM 后端的请求的全生命周期。

<a id="deployment-options"></a>

## 部署选项

您可以使用不同的部署选项来使用自部署模型。

<a id="gitlab-duo-agent-platform"></a>

### 极狐GitLab Duo Agent Platform

使用极狐GitLab Duo Agent Platform 自部署版本，在极狐GitLab Duo Agent Platform 中用于本地模型或私有云托管模型。

对于持有离线许可证的客户，计费基于席位，您必须拥有[极狐GitLab Duo Agent Platform 自部署](../../subscriptions/subscription-add-ons.md#gitlab-duo-agent-platform-self-hosted)附加组件。

对于持有在线许可证的客户，计费是[按量计费](../../subscriptions/gitlab_credits.md)。您还可以在混合部署中使用极狐GitLab 托管的模型。

<a id="gitlab-duo"></a>

### 极狐GitLab Duo

极狐GitLab Duo 自部署适用于使用极狐GitLab Duo 功能的极狐GitLab Duo Enterprise 客户。您可以使用：

- 本地模型或私有云托管模型
- 混合部署中的极狐GitLab 托管模型

此选项采用基于席位的定价。

<a id="feature-versions-and-status"></a>

### 功能版本和状态

下表列出：

- 使用该功能所需的极狐GitLab 版本。
- 功能状态。部署中的功能状态可能与功能中列出的状态不同。

要使用极狐GitLab Duo 自部署的极狐GitLab Duo 功能，您必须拥有极狐GitLab Duo Enterprise 附加组件。即使当极狐GitLab 通过基于云的 [AI 网关](../gitlab_duo/gateway.md) 托管并连接到这些模型时，您可以使用极狐GitLab Duo Core 或极狐GitLab Duo Pro 中的这些功能，此项规定同样适用。

| 功能 | 极狐GitLab 版本 | 状态 |
| --- | --- | --- |
| [极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md) | 极狐GitLab 18.8 及更高版本 | GA |
| **极狐GitLab Duo** | | |
| [代码建议](../../user/project/repository/code_suggestions/_index.md) | 极狐GitLab 17.9 及更高版本 | GA |
| [极狐GitLab Duo 非 Agent 聊天](../../user/gitlab_duo_chat/_index.md) | 极狐GitLab 17.9 及更高版本 | GA |
| [代码解释](../../user/gitlab_duo_chat/examples.md#explain-selected-code) | 极狐GitLab 17.9 及更高版本 | GA |
| [测试生成](../../user/gitlab_duo_chat/examples.md#write-tests-in-the-ide) | 极狐GitLab 17.9 及更高版本 | GA |
| [代码重构](../../user/gitlab_duo_chat/examples.md#refactor-code-in-the-ide) | 极狐GitLab 17.9 及更高版本 | GA |
| [代码修复](../../user/gitlab_duo_chat/examples.md#fix-code-in-the-ide) | 极狐GitLab 17.9 及更高版本 | GA |
| [代码评审](../../user/project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code) | 极狐GitLab 18.3 及更高版本 | GA |
| [根因分析](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) | 极狐GitLab 17.10 及更高版本 | 测试版 |
| [漏洞解释](../../user/application_security/analyze/duo.md) | 极狐GitLab 18.1.2 及更高版本 | 测试版 |
| [合并提交消息生成](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message) | 极狐GitLab 18.1.2 及更高版本 | 测试版 |
| [合并请求摘要](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes) | 极狐GitLab 18.1.2 及更高版本 | 测试版 |
| [讨论摘要](../../user/discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat) | 极狐GitLab 18.1.2 及更高版本 | 测试版 |
| [极狐GitLab Duo for the CLI](https://docs.gitlab.com/cli/) | 极狐GitLab 18.1.2 及更高版本 | 测试版 |
| [漏洞修复](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution) | 极狐GitLab 18.1.2 及更高版本 | 测试版 |
| [极狐GitLab Duo 与 SDLC 趋势仪表板](../../user/analytics/duo_and_sdlc_trends.md) | 极狐GitLab 17.9 及更高版本 | 测试版 |
| [代码评审摘要](../../user/project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review) | 极狐GitLab 18.1.2 及更高版本 | 实验性 |

<a id="data-transmission"></a>

## 数据传输

以下计费元数据会发送给极狐GitLab 用于用量计费：

- 匿名实例 ID
- 调用次数
- 用户 ID

推理数据（包括代码输入、模型提示和模型响应）不会离开客户网络。
极狐GitLab 不会获取客户使用的模型或模型提供商。

<a id="ai-gateway-configurations"></a>

## AI 网关配置

选择产品选项后，配置 AI 网关如何连接到 LLM：

- **自部署 AI 网关和 LLM**：使用自己的 AI 网关和模型，完全控制您的 AI 基础设施。
- **混合 AI 网关和模型配置**：对于每个功能，使用自部署的自部署 AI 网关和自部署模型，或使用 JihuLab.com AI 网关和极狐GitLab 托管模型。
- **带有默认极狐GitLab 外部供应商 LLM 的 JihuLab.com AI 网关**：使用极狐GitLab 托管的 AI 基础设施。

| 配置 | 自部署 AI 网关 | 混合 AI 网关和模型配置 | JihuLab.com AI 网关 |
| --- | --- | --- | --- |
| 基础设施要求 | 需要托管自己的 AI 网关和模型 | 需要托管自己的 AI 网关和模型 | 无需额外基础设施 |
| 模型选项 | 从[受支持的自部署模型](supported_models_and_hardware_requirements.md)中选择 | 从[受支持的自部署模型](supported_models_and_hardware_requirements.md)或为每个极狐GitLab Duo 功能选择极狐GitLab 托管模型 | 使用默认的极狐GitLab 托管模型 |
| 网络要求 | 可在完全隔离的网络中运行 | 对于使用极狐GitLab 托管模型的极狐GitLab Duo 功能，需要互联网连接 | 需要互联网连接 |
| 职责 | 您设置自己的基础设施并进行维护 | 您设置自己的基础设施，进行维护，并选择哪些功能使用极狐GitLab 托管模型和 AI 网关 | 极狐GitLab 负责设置和维护 |

<a id="self-hosted-ai-gateway-and-llms"></a>

### 自部署 AI 网关和 LLM

在完全自部署的配置中，您部署自己的 AI 网关，并仅使用基础设施中的[受支持的 LLM](supported_models_and_hardware_requirements.md)，而不使用极狐GitLab 基础设施或 AI 供应商模型。这让您可以完全控制您的数据和安全。

> [!note]
> 此配置仅包含通过自部署 AI 网关配置的模型。如果您在任何功能中使用[极狐GitLab 托管模型](configure_duo_features.md#select-a-gitlab-managed-model-for-a-feature)，这些功能将连接到极狐GitLab 托管的 AI 网关，而不是您的自部署网关，使其成为混合配置而非完全自部署。

即使您部署了自己的 AI 网关，仍然可以使用基于云的 LLM 服务（例如 [AWS Bedrock](https://aws.amazon.com/bedrock/) 或 [Azure OpenAI](https://azure.microsoft.com/en-us/products/ai-services/openai-service)）作为模型后端，它们将继续通过您的自部署 AI 网关进行连接。

如果您的离线环境存在物理隔离或安全策略阻止或限制互联网访问，并且需要全面的 LLM 控制，则应使用此完全自部署配置。

更多信息，请参阅：

- [自部署 AI 网关配置图](configuration_types.md#self-hosted-ai-gateway)。

<a id="hybrid-ai-gateway-and-model-configuration"></a>

### 混合 AI 网关和模型配置

{{< history >}}

- 在极狐GitLab 18.3 中作为[测试版](../../policy/development_stages_support.md#beta)引入，有一个名为 `ai_self_hosted_vendored_features` 的[功能标志](../feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 18.7 中默认启用。
- 在极狐GitLab 18.9 中 GA。功能标志 `ai_self_hosted_vendored_features` 已移除。

{{< /history >}}

在此混合配置中，您为大多数功能部署自己的 AI 网关和自部署模型，但将特定功能配置为使用极狐GitLab 托管模型。当某个功能配置为使用极狐GitLab 托管模型时，该功能的请求会发送到极狐GitLab 托管的 AI 网关，而不是您的自部署 AI 网关。

此选项通过以下方式提供灵活性：

- 在您希望完全控制的功能中使用自己的自部署模型。
- 在您偏好极狐GitLab 精心挑选的模型的特定功能中使用极狐GitLab 托管的供应商模型。

> [!note]
> 当功能配置为使用极狐GitLab 托管模型时：
>
> - 对这些功能的所有调用都使用极狐GitLab 托管的 AI 网关，而不是自部署 AI 网关。
> - 这些功能需要互联网连接。
> - 这不是完全自部署或隔离的配置。

<a id="gitlab-managed-models"></a>

#### 极狐GitLab 托管模型

使用极狐GitLab 托管模型连接到 AI 模型，无需自托管基础设施。这些模型完全由极狐GitLab 管理。

您可以选择与 AI 原生功能一起使用的默认极狐GitLab 模型。对于默认模型，极狐GitLab 根据可用性、质量和可靠性使用最佳模型。用于某个功能的模型可能会更改，恕不另行通知。

当您选择特定的极狐GitLab 托管模型时，该功能的所有请求都专门使用该模型。如果模型不可用，对 AI 网关的请求将失败，用户无法使用该功能，直到选择了另一个模型。

> [!note]
> 当您将功能配置为使用极狐GitLab 托管模型时：
>
> - 对这些功能的调用使用极狐GitLab 托管的 AI 网关，而不是自部署 AI 网关。
> - 这些功能需要互联网连接。
> - 该配置并非完全自部署或隔离。

<a id="gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms"></a>

### 使用默认极狐GitLab 外部供应商 LLM 的 JihuLab.com AI 网关

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

如果您不符合极狐GitLab Duo 自部署的用例标准，则可以使用默认极狐GitLab 外部供应商 LLM 的 JihuLab.com AI 网关。

JihuLab.com AI 网关是默认的企业产品，并非自托管。在此配置中，您将实例连接到极狐GitLab 托管的 AI 网关，该网关集成了外部供应商的 LLM 提供商，包括国内 SOTA 大模型。

这些 LLM 通过极狐GitLab Cloud Connector 进行通信，提供即用型 AI 解决方案，无需本地基础设施。

更多信息，请参阅 [JihuLab.com AI 网关配置图](configuration_types.md#gitlabcom-ai-gateway)。

要设置此基础设施，请参阅[如何在私有化部署实例上配置极狐GitLab Duo](../gitlab_duo/configure/gitlab_self_managed.md)。

<a id="set-up-a-private-infrastructure"></a>

## 设置私有基础设施

如果您拥有离线许可证，可以设置完全私有的基础设施：

1. 安装大语言模型（LLM）服务基础设施。

   - 极狐GitLab 支持多种用于服务和托管 LLM 的平台，例如 vLLM、AWS Bedrock 和 Azure OpenAI。有关每个平台的更多信息，请参阅[支持的 LLM 平台文档](supported_llm_serving_platforms.md)。

   - 极狐GitLab 提供了一份支持模型的矩阵，包含其特定功能和硬件要求。更多信息请参阅[支持的模型和硬件要求文档](supported_models_and_hardware_requirements.md)。

1. [安装 AI 网关](../../install/install_ai_gateway.md)以访问极狐GitLab Duo 功能。
1. [配置您的极狐GitLab 实例](configure_duo_features.md)，使功能使用自部署模型。
1. [启用日志记录](logging.md)以跟踪和管理系统性能。

<a id="related-topics"></a>

## 相关主题

- [故障排除](troubleshooting.md)
- [安装极狐GitLab AI 网关](../../install/install_ai_gateway.md)
- [支持的模型](supported_models_and_hardware_requirements.md)
- [支持的平台](supported_llm_serving_platforms.md)
- [教程：AWS Bedrock BYOM 部署指南](../../solutions/integrations/aws_bedrock_byom.md)