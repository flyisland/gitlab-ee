---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 托管您自己的 AI 网关和语言模型。
title: 自部署模型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

托管您自己的 AI 基础设施，以便使用您选择的 LLM 来使用极狐GitLab Duo 功能。使用自部署 AI 网关将所有请求和响应数据保留在您自己的环境中，避免外部 API 调用，并管理对 LLM 后端请求的完整生命周期。

<a id="deployment-options"></a>

## 部署选项

您可以在不同的部署选项中使用自部署模型。

<a id="gitlab-duo-agent-platform"></a>

### 极狐GitLab Duo Agent Platform

在极狐GitLab Duo Agent Platform 中，使用极狐GitLab Duo Agent Platform 自部署版本以支持本地模型或私有云托管的模型。

对于拥有离线许可证的客户，计费使用极狐GitLab Duo 的企业许可协议，并且您必须拥有[极狐GitLab Duo Agent Platform 自部署版本](../../subscriptions/subscription-add-ons.md#gitlab-duo-agent-platform-self-hosted)附加组件。

对于拥有在线许可证的客户，计费基于[用量](../../subscriptions/gitlab_credits.md)。您还可以在混合部署中使用极狐GitLab 托管模型。

<a id="gitlab-duo"></a>

### 极狐GitLab Duo

极狐GitLab Duo 自部署版本适用于使用极狐GitLab Duo 功能的极狐GitLab Duo Enterprise 客户。您可以使用：

- 本地模型或私有云托管的模型
- 混合部署中的极狐GitLab 托管模型

此选项使用基于席位的定价。

<a id="feature-versions-and-status"></a>

### 功能版本和状态

下表列出了：

- 使用该功能所需的极狐GitLab 版本。
- 功能状态。部署中的功能状态可能与功能中列出的状态不同。

要将极狐GitLab Duo 功能与极狐GitLab Duo 自部署版本一起使用，您必须拥有
极狐GitLab Duo Enterprise 附加组件。即使极狐GitLab 托管并连接这些模型时使用基于云的 [AI 网关](../gitlab_duo/gateway.md)，且这些功能可在极狐GitLab Duo Core 或极狐GitLab Duo Pro 中使用，此要求仍然适用。

| 功能                                                                                                                                | 极狐GitLab 版本          | 状态              |
|----------------------------------------------------------------------------------------------------------------------------------------|-------------------------|---------------------|
| [极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md)                                                                   | 极狐GitLab 18.8 及更高版本   | 正式发布 |
| **极狐GitLab Duo** | | |
| [代码建议](../../user/project/repository/code_suggestions/_index.md)                                                 | 极狐GitLab 17.9 及更高版本   | 正式发布 |
| [GitLab Duo Non-Agentic Chat](../../user/gitlab_duo_chat/_index.md)                                                                      | 极狐GitLab 17.9 及更高版本   | 正式发布 |
| [代码解释](../../user/gitlab_duo_chat/examples.md#explain-selected-code)                                                       | 极狐GitLab 17.9 及更高版本   | 正式发布 |
| [测试生成](../../user/gitlab_duo_chat/examples.md#write-tests-in-the-ide)                                                       | 极狐GitLab 17.9 及更高版本   | 正式发布 |
| [重构代码](../../user/gitlab_duo_chat/examples.md#refactor-code-in-the-ide)                                                       | 极狐GitLab 17.9 及更高版本   | 正式发布 |
| [修复代码](../../user/gitlab_duo_chat/examples.md#fix-code-in-the-ide)                                                                 | 极狐GitLab 17.9 及更高版本   | 正式发布 |
| [代码评审](../../user/project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)                           | 极狐GitLab 18.3 及更高版本   | 正式发布 |
| [根因分析](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)                   | 极狐GitLab 17.10 及更高版本  | 测试版                |
| [漏洞解释](../../user/application_security/analyze/duo.md)                                                            | 极狐GitLab 18.1.2 及更高版本 | 测试版                |
| [合并提交消息生成](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message)          | 极狐GitLab 18.1.2 及更高版本 | 测试版                |
| [合并请求摘要](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes) | 极狐GitLab 18.1.2 及更高版本 | 测试版                |
| [讨论摘要](../../user/discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat)                                | 极狐GitLab 18.1.2 及更高版本 | 测试版                |
| [用于 CLI 的极狐GitLab Duo](https://gitlab.cn/docs/cli/)                                                                                 | 极狐GitLab 18.1.2 及更高版本 | 测试版                |
| [漏洞解决](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution)                         | 极狐GitLab 18.1.2 及更高版本 | 测试版                |
| [极狐GitLab Duo 和 SDLC 趋势仪表板](../../user/analytics/duo_and_sdlc_trends.md)                                                    | 极狐GitLab 17.9 及更高版本   | 测试版                |
| [代码评审摘要](../../user/project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review)                              | 极狐GitLab 18.1.2 及更高版本 | 实验          |

<a id="internet-connectivity-requirements-for-the-agent-platform"></a>

## Agent Platform 的互联网连接要求

互联网连接要求取决于您的订阅拥有在线许可证还是离线许可证。

如果您的订阅拥有在线许可证，用量计费需要出站互联网连接。如果您的防火墙或网络策略阻止以下任何组件，用量计费将失败，您将无法使用极狐GitLab Duo Agent Platform 功能。

如果您的订阅拥有离线许可证，您的实例不会连接到以下组件。您将根据企业许可协议而非用量计费进行计费。有关更多信息，请参阅[离线部署](offline_deployment.md)。

| 组件 | 端点 | 端口 | 用途 |
|-----------|----------|------|---------|
| CustomersDot | `customers.jihulab.com` | `443` | 保持许可证和订阅信息同步。 |
| 云端 AI 网关 | `cloud.jihulab.com` | `443` | 对 Agent Platform 功能执行用量配额检查。 |
| 云端 AI 网关[^requires-http2] | `cloud.jihulab.com` | `443` | 发送极狐GitLab Duo Agent Platform 功能的用量计费元数据。 |

[^requires-http2]: 需要 HTTP/2

仅向这些组件发送计费元数据。提示、代码输入和模型响应不会离开您的网络。有关所传输数据类型的更多信息，请参阅[数据传输](#data-transmission)。

<a id="data-transmission"></a>

## 数据传输

以下计费元数据以 JSON 对象形式发送到极狐GitLab 以进行用量计费：

- 实例 ID
- 用户 ID
- 调用次数
- 时间戳

例如：

```json
{
  "InstanceId": "ccbb3949-9836-471c-b2nb-32a38e8cca99",
  "GlobalUserId": "KWDTe17sGSADiAzEGJ6IuL1D7RAzsXqa2wun3aX1YuA=",
  "Quantity": 1,
  "Timestamp": "2026-05-04 18:04:30.969000000"
}
```

> [!note]
> `GlobalUserId` 是一个确定性的但已去标识化的标识符。`GlobalUserId` 在极狐GitLab 代码中由实例 ID 和用户 ID 通过 SHA-256 生成。如果客户构建查找表，则有可能将其映射回特定用户。

推理数据（包括代码输入、模型提示和模型响应）不会离开客户网络。

极狐GitLab 不会捕获客户使用哪个模型或模型提供商。

<a id="ai-gateway-configurations"></a>

## AI 网关配置

选择产品选项后，配置您的 AI 网关如何连接到 LLM：

- **自部署 AI 网关和 LLM**：使用您自己的 AI 网关和模型，以完全控制您的 AI 基础设施。
- **混合 AI 网关和模型配置**：对于每项功能，使用您的自部署 AI 网关搭配自部署模型，或使用 JihuLab.com AI 网关搭配极狐GitLab 托管模型。极狐GitLab 托管模型不适用于离线许可证。
- **JihuLab.com AI 网关搭配默认的极狐GitLab 外部厂商 LLM**：使用极狐GitLab 托管的 AI 基础设施。

| 配置               | 自部署 AI 网关                                                                    | 混合 AI 网关和模型配置                                                                                                        | JihuLab.com AI 网关                    |
|-----------------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| 基础设施要求 | 需要托管您自己的 AI 网关和模型                                           | 需要托管您自己的 AI 网关和模型                                                                                                  | 无需额外基础设施      |
| 模型选项               | 从[支持的自部署模型](supported_models_and_hardware_requirements.md)中选择 | 为每项极狐GitLab Duo 功能从[支持的自部署模型](supported_models_and_hardware_requirements.md)或极狐GitLab 托管模型中选择 | 使用默认的极狐GitLab 托管模型 |
| 网络要求        | 可在完全隔离的网络中运行                                                    | 使用极狐GitLab 托管模型的极狐GitLab Duo 功能需要互联网连接                                                          | 需要互联网连接           |
| 责任            | 您设置您的基础设施，并自行维护                               | 您设置您的基础设施，自行维护，并选择哪些功能使用极狐GitLab 托管模型和 AI 网关                    | 极狐GitLab 负责设置和维护   |

<a id="self-hosted-ai-gateway-and-llms"></a>

### 自部署 AI 网关和 LLM

在完全自部署配置中，您部署自己的 AI 网关，并仅使用您基础设施中[支持的 LLM](supported_models_and_hardware_requirements.md)，而不使用极狐GitLab 基础设施或 AI 厂商模型。这使您可以完全控制您的数据和安全性。

> [!note]
> 此配置仅包含通过您的自部署 AI 网关配置的模型。如果您为任何功能使用[极狐GitLab 托管模型](configure_duo_features.md#select-a-gitlab-managed-model-for-a-feature)，这些功能将连接到极狐GitLab 托管的 AI 网关而不是您的自部署网关，使其成为混合配置而非完全自部署。

虽然您部署自己的 AI 网关，您仍然可以使用基于云的 LLM 服务（如 [AWS Bedrock](https://aws.amazon.com/bedrock/) 或 Azure OpenAI）作为您的模型后端，它们将继续通过您的自部署 AI 网关连接。

如果您的离线环境存在物理屏障或阻止或限制互联网访问的安全策略，且您具备全面的 LLM 控制，则应使用此完全自部署配置。

有关更多信息，请参阅：

- [自部署 AI 网关配置图](configuration_types.md#self-hosted-ai-gateway)。

<a id="hybrid-ai-gateway-and-model-configuration"></a>

### 混合 AI 网关和模型配置

在此混合配置中，您为大多数功能部署自己的 AI 网关和自部署模型，但配置特定功能使用极狐GitLab 托管模型。当某项功能配置为使用极狐GitLab 托管模型时，该功能的请求将发送到极狐GitLab 托管的 AI 网关而不是您的自部署 AI 网关。

此选项通过允许您执行以下操作来提供灵活性：

- 在您希望完全控制的功能中使用您自己的自部署模型。
- 在您偏好极狐GitLab 精选的模型的特定功能中使用极狐GitLab 托管的厂商模型。

> [!note]
> 当功能配置为使用极狐GitLab 托管模型时：
>
> - 对这些功能的所有调用都使用极狐GitLab 托管的 AI 网关，而不是自部署 AI 网关。
> - 这些功能需要互联网连接。
> - 这不是完全自部署或隔离的配置。

<a id="gitlab-managed-models"></a>

#### 极狐GitLab 托管模型

使用极狐GitLab 托管模型连接到 AI 模型，无需自部署基础设施。这些模型完全由极狐GitLab 管理。

您可以选择默认的极狐GitLab 模型与 AI 原生功能一起使用。对于默认模型，极狐GitLab 会根据可用性、质量和可靠性选择最佳模型。用于某项功能的模型可能会在不另行通知的情况下更改。

当您选择特定的极狐GitLab 托管模型时，该功能的所有请求都专门使用该模型。如果该模型变得不可用，对 AI 网关的请求将失败，用户将无法使用该功能，直到选择另一个模型。

> [!note]
> 当您将功能配置为使用极狐GitLab 托管模型时：
>
> - 对这些功能的调用使用极狐GitLab 托管的 AI 网关，而不是自部署 AI 网关。
> - 这些功能需要互联网连接。
> - 该配置不是完全自部署或隔离的。

<a id="gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms"></a>

### JihuLab.com AI 网关搭配默认的极狐GitLab 外部厂商 LLM

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

如果您不符合极狐GitLab Duo 自部署版本的用例标准，您可以使用
JihuLab.com AI 网关搭配默认的极狐GitLab 外部厂商 LLM。

JihuLab.com AI 网关是默认的企业版产品，并非自部署。在此配置中，您将您的实例连接到极狐GitLab 托管的 AI 网关，该网关与外部厂商 LLM 提供商集成，包括：

- [PPIO](https://ppio.com/)
- [万界](https://fangzhou.wanjiedata.com/)
- [网宿](https://online.wangsu.com/)

这些 LLM 通过极狐GitLab Cloud Connector 通信，
提供开箱即用的 AI 解决方案，无需本地基础设施。

有关更多信息，请参阅 [JihuLab.com AI 网关配置图](configuration_types.md#gitlabcom-ai-gateway)。

要设置此基础设施，请参阅[如何在极狐GitLab 私有化部署实例上配置极狐GitLab Duo](../gitlab_duo/configure/_index.md)。

<a id="set-up-private-infrastructure"></a>

## 设置私有基础设施

如果您拥有离线许可证，您可以设置完全私有的基础设施：

1. 安装大型语言模型（LLM）服务基础设施。

   - 查看[支持的 LLM 平台](supported_llm_serving_platforms.md)以选择
     服务和托管平台，例如 vLLM、AWS Bedrock 或 Azure OpenAI。
   - 查看[支持的模型和硬件要求](supported_models_and_hardware_requirements.md)
     以确认您的模型和硬件选择。

1. [安装 AI 网关](../../install/install_ai_gateway.md)以访问极狐GitLab Duo 功能。
1. [配置您的极狐GitLab 实例](configure_duo_features.md)以使用自部署模型。
1. [启用日志记录](logging.md)以跟踪和管理您系统的性能。
