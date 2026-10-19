---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn about different AI gateway configurations and the authentication process for self-hosted models
title: 极狐GitLab AI 网关配置与认证
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中引入，附带一个名为 `ai_custom_model` 的功能标志。默认禁用。
- 在极狐GitLab 17.6 中为私有化部署启用。
- 在极狐GitLab 17.6 及更高版本中，改为需要 极狐GitLab Duo 插件。
- 功能标志 `ai_custom_model` 在极狐GitLab 17.8 中移除。
- 在极狐GitLab 17.9 中 GA。
- 在极狐GitLab 18.0 中改为包括专业版。

{{< /history >}}

对于私有化部署客户，有两种 AI 网关配置选项：

- **JihuLab.com AI 网关**：这是适用于 极狐GitLab 私有化部署客户的默认配置。使用由 极狐GitLab 管理的 AI 网关，配合 极狐GitLab 选择的外部大语言模型（LLM）提供商（例如国内 SOTA 大模型）。
- **自托管 AI 网关**：在自己的基础设施中部署和管理您自己的 AI 网关和语言模型，无需依赖 极狐GitLab 提供的外部语言提供商。

## JihuLab.com AI 网关

在此配置中，您的 极狐GitLab 实例依赖于外部 极狐GitLab AI 网关并向其发送请求，该网关与外部 AI 供应商（如国内 SOTA 大模型）通信。响应随后转发回您的 极狐GitLab 实例。

```mermaid
sequenceDiagram
    accTitle: JihuLab.com AI 网关流程
    accDescr: 用户请求通过私有化部署的极狐GitLab实例、外部AI网关和AI供应商进行处理。

    actor User as 用户
    participant SelfHostedGitLab as 私有化部署极狐GitLab（您的实例）
    participant GitLabAIGateway as 极狐GitLab AI 网关（外部）
    participant GitLabAIVendor as 极狐GitLab AI 供应商（外部）

    User ->> SelfHostedGitLab: 发送请求
    SelfHostedGitLab ->> SelfHostedGitLab: 检查是否配置了自部署模型
    SelfHostedGitLab ->> GitLabAIGateway: 转发请求进行 AI 处理
    GitLabAIGateway ->> GitLabAIVendor: 创建提示并发送请求至 AI 模型服务器
    GitLabAIVendor -->> GitLabAIGateway: 响应提示
    GitLabAIGateway -->> SelfHostedGitLab: 转发 AI 响应
    SelfHostedGitLab -->> User: 转发 AI 响应
```

## 自托管 AI 网关

在此配置中，整个系统隔离在企业内部，确保完全自托管的运行环境，保护数据隐私。

```mermaid
sequenceDiagram
    accTitle: 自托管 AI 网关流程
    accDescr: 用户请求完全在自托管基础设施内使用AI网关和模型处理。

    actor User as 用户
    participant SelfHostedGitLab as 私有化部署极狐GitLab
    participant SelfHostedAIGateway as 自托管 AI 网关
    participant SelfHostedModel as 自部署模型

    User ->> SelfHostedGitLab: 发送请求
    SelfHostedGitLab ->> SelfHostedGitLab: 检查是否配置了自部署模型
    SelfHostedGitLab ->> SelfHostedAIGateway: 转发请求进行 AI 处理
    SelfHostedAIGateway ->> SelfHostedModel: 创建提示并向 AI 模型服务器执行请求
    SelfHostedModel -->> SelfHostedAIGateway: 响应提示
    SelfHostedAIGateway -->> SelfHostedGitLab: 转发 AI 响应
    SelfHostedGitLab -->> User: 转发 AI 响应
```

## 自部署模型的认证

自部署模型的认证过程安全、高效，由以下关键组件组成：

- **自签发令牌**：在此架构中，访问凭证不与 `cloud.jihulab.com` 同步。相反，令牌以动态方式自签发，类似于 JihuLab.com 上的功能。此方法为用户提供即时访问，同时保持高水平的安全性。
- **离线环境**：在离线设置中，没有任何到 `cloud.jihulab.com` 的连接。所有请求仅路由到自托管 AI 网关。
- **令牌铸造和验证**：实例铸造令牌，然后由 AI 网关针对 极狐GitLab 实例进行验证。
- **模型配置与安全**：当管理员配置模型时，可以加入 API 密钥以认证请求。此外，您可以通过在网络中指定连接 IP 地址来增强安全性，确保只有受信任的 IP 可以与模型交互。

如下图所示：

1. 认证流程从用户通过 极狐GitLab 实例配置模型并提交访问 极狐GitLab Duo 功能的请求开始。
1. 极狐GitLab 实例铸造一个访问令牌，用户将其转发给 极狐GitLab，然后再转发给 AI 网关进行验证。
1. 确认令牌有效后，AI 网关向 AI 模型发送请求，AI 模型使用 API 密钥对请求进行认证和处理。
1. 结果随后转发回 极狐GitLab 实例，通过将响应发送给用户完成流程，整个过程设计得安全且高效。

```mermaid
sequenceDiagram
    accTitle: 极狐GitLab Duo 认证流程
    accDescr: 认证令牌被铸造、验证，并用于保护AI模型请求。

    participant User as 用户
    participant GitLab as 极狐GitLab 实例
    participant AI Gateway as AI 网关
    participant AIModel as AI 模型

    User->>GitLab: 配置模型
    User->>GitLab: 请求访问
    GitLab->>GitLab: 铸造令牌
    GitLab->>User: 发送令牌
    User->>GitLab: 转发铸造的令牌
    GitLab->>AI Gateway: 验证令牌
    AI Gateway->>GitLab: 令牌已验证
    GitLab->>AI Gateway: 向模型发送请求
    AI Gateway->>AIModel: 向模型发送请求
    AIModel->>AIModel: 使用 API 密钥认证
    AIModel->>AI Gateway: 处理请求
    AI Gateway->>GitLab: 将结果发送给极狐GitLab
    GitLab->>User: 发送响应
```