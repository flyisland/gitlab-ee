---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何将自部署模型与极狐GitLab 实例集成
title: 配置极狐GitLab 以使用自部署模型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- [将极狐GitLab 升级到 17.9 或更高版本](../../update/_index.md)。
- 您必须是管理员。

要将极狐GitLab 实例配置为访问您基础设施中的自部署模型：

1. 配置极狐GitLab 实例以访问 AI 网关。
1. 在极狐GitLab 18.4 及更高版本中，配置极狐GitLab 实例以访问极狐GitLab Duo Agent Platform 服务。
1. 将自部署模型添加到极狐GitLab 实例。
1. 为某项功能选择自部署模型。

<a id="configure-access-to-the-local-ai-gateway"></a>

## 配置对本地 AI 网关的访问

要配置极狐GitLab 实例与本地 AI 网关之间的访问：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**本地 AI 网关 URL** 下，输入您的 AI 网关 URL。
1. 选择**保存更改**。

> [!note]
> 如果您的 AI 网关 URL 指向本地网络或私有 IP 地址（例如 `172.31.x.x` 或类似 `ip-172-xx-xx-xx.region.compute.internal`的内部主机名），极狐GitLab 可能出于安全原因阻止该请求。要允许向此地址发送请求，请[将该地址添加到 IP 允许名单](../../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains)。

<a id="configure-timeout-for-the-ai-gateway"></a>

### 配置 AI 网关的超时

为节省资源并防止长时间运行的查询，请配置极狐GitLab 在等待模型响应时向 AI 网关发送请求的超时时间。对于具有大上下文窗口或复杂查询的自部署模型，请使用更长的超时时间。

您可以配置 60 到 600 秒（10 分钟）之间的超时时间。如果未设置超时时间，极狐GitLab 将使用默认的 60 秒超时时间。

要配置 AI 网关超时：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在 **AI 网关请求超时**下，输入超时值（以秒为单位，介于 60 到 600 之间）。
1. 选择**保存更改**。

<a id="determine-the-timeout-value"></a>

### 确定超时值

超时值取决于您的具体部署和用例。

要确定超时值：

- 从默认的 60 秒超时时间开始，并监控超时错误。
- 监控日志中是否有 `A1000` 超时错误。如果这些错误频繁出现，请考虑增加超时时间。
- 考虑您的用例。较大的提示、复杂的代码生成任务或处理大型设计文档可能需要更长的超时时间。
- 考虑您的基础设施。模型性能取决于可用的 GPU 资源、AI 网关与模型端点之间的网络延迟，以及模型的处理能力。
- 逐步增加。如果遇到超时，请逐渐增加该值（例如，增加 30-60 秒）并监控结果。

有关超时错误故障排除的更多信息，请参阅 [`Error A1000`](troubleshooting.md#error-a1000)。如果即使使用更高的超时值，响应仍会在没有错误的情况下被截断，请参阅[响应被截断但没有错误](troubleshooting.md#responses-are-truncated-without-an-error)。

<a id="configure-the-chat-model-request-timeout"></a>

### 配置聊天模型请求超时

AI 网关请求超时控制极狐GitLab 等待 AI 网关的时长。另一个单独的超时控制 AI 网关等待自部署模型返回聊天响应的时长。默认情况下，AI 网关会在 30 秒后结束单个聊天模型请求。

大上下文窗口或针对较慢自部署模型的复杂 Agent 提示可能需要超过 30 秒。要增加此超时时间，请在 AI 网关容器上设置 `AIGW_DUO_CHAT__MODEL_REQUEST_TIMEOUT` 环境变量（以秒为单位）：

```shell
docker run -e AIGW_GITLAB_URL=<your_gitlab_instance> \
  -e AIGW_DUO_CHAT__MODEL_REQUEST_TIMEOUT=600 \
  <ai_gateway_image>
```

该值必须大于 `0`。如果模型在 `MODEL_SPECIFICATIONS`中设置了自己的超时时间，则该值优先于此默认值。

<a id="configure-user-id-header-for-your-model-endpoint"></a>

### 为模型端点配置用户 ID 请求头

默认情况下，AI 网关向您的自部署模型发送的每个请求看起来都来自同一个服务账号。如果您的模型服务平台按调用方归属或计量用量，您可以配置 AI 网关添加一个请求头，其中包含触发该请求的极狐GitLab 用户 ID。

要配置此请求头，请在 AI 网关容器中将 `AIGW_CUSTOM_MODELS__USER_ID_HEADER` 环境变量设置为您的模型端点所期望的请求头名称：

```shell
docker run -e AIGW_GITLAB_URL=<your_gitlab_instance> \
  -e AIGW_CUSTOM_MODELS__USER_ID_HEADER=x-gitlab-user-id \
  <ai_gateway_image>
```

AI 网关会将该请求头添加到它向模型端点发送的每个请求中，
包括 OpenAI 兼容端点、Amazon Bedrock 和 Google Vertex AI。
该请求头的值是您极狐GitLab 实例上用户的数字 ID。例如，在此配置中，由 ID 为 `42`的用户触发的请求到达您的模型端点时会带有以下请求头：

```plaintext
x-gitlab-user-id: 42
```

极狐GitLab 托管模型不受影响，因为这些请求不经过您的 AI 网关。

请求头名称必须满足以下条件：

- 是有效的 HTTP 请求头名称
- 不是传输或认证请求头，
  例如 `Authorization`、`Host` 或 `Content-Type`
- 不是 AI 网关已设置的请求头，
  例如 `anthropic-version`

不代表用户发出的请求（例如健康检查）永远不会包含该请求头。请仅使用该请求头来归属或计量用量，而不要用它来在模型端点上做出授权决策。

要验证配置，请触发一个使用自部署模型的极狐GitLab Duo 功能，并检查模型服务平台访问日志中的请求头。

<a id="configure-access-to-the-gitlab-duo-agent-platform"></a>

## 配置对极狐GitLab Duo Agent Platform 的访问

先决条件：

- 如果您的实例使用离线许可证，您必须拥有[极狐GitLab Duo Agent Platform 自部署版本](../../subscriptions/subscription-add-ons.md)附加组件。

要从极狐GitLab 实例访问 Agent Platform 服务：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo Agent Platform 服务的本地 URL** 下，输入本地 Agent Platform 服务的 URL。
   - 该 URL 通常与**本地 AI 网关 URL** 相同，但使用 gRPC 端口 :50052。
   - 不要包含 URL 前缀，例如 `http://` 或 `https://`。
   - 如果您已按照[建议使用 NGINX 反向代理设置 SSL](../../install/install_ai_gateway.md#set-up-docker-with-nginx-and-ssl)，或使用[启用了 Ingress 的 Helm chart](../../install/install_ai_gateway.md#install-by-using-helm-chart)，则不要指定端口。NGINX Ingress 会处理端口转发。
1. 可选。如果您的本地极狐GitLab Duo Agent Platform 端点使用 TLS，请在**安全**下选中**为极狐GitLab Duo Agent Platform 服务使用安全连接（TLS）**复选框。
1. 选择**保存更改**。

<a id="add-a-self-hosted-model"></a>

## 添加自部署模型

您必须将自部署模型添加到极狐GitLab 实例，才能将其与极狐GitLab Duo 功能一起使用。

要添加自部署模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**为极狐GitLab Duo 配置模型**。
   - 如果**为极狐GitLab Duo 配置模型**不可用，请在购买后同步您的
     订阅：
     1. 在左侧边栏中，选择**订阅**。
     1. 在**订阅详情**中，在**上次同步**右侧，选择
        同步订阅（{{< icon name="retry" >}}）。
1. 选择**添加自部署模型**。
1. 填写以下字段：
   - **部署名称**：输入用于唯一标识该模型部署的名称，例如 `Mixtral-8x7B-it-v0.1 on GCP`。
   - **模型系列**：选择该部署所属的模型系列。您可以选择受支持的模型或兼容的模型。
   - **端点**：输入托管模型的 URL。
   - **API 密钥**：可选。如果需要 API 密钥才能访问该模型，请添加 API 密钥。
   - **要代入的 IAM 角色**：可选。输入 AI 网关为调用 Amazon Bedrock 而代入的 IAM 角色的 ARN。
     该角色的信任策略必须要求将您的极狐GitLab 实例 ID 作为 `sts:ExternalId`。
     您不能同时使用 IAM 角色和 API 密钥。
     更多信息，请参阅[使用 AWS Bedrock 代入 IAM 角色](supported_llm_serving_platforms.md#assume-an-iam-role-with-aws-bedrock)。
   - **模型标识符**：根据您的部署方式输入模型标识符。模型标识符应匹配以下格式：

     | 部署方式 | 格式 | 示例 |
     |-------------|---------|---------|
     | [vLLM](supported_llm_serving_platforms.md#find-the-model-name)        | `custom_openai/<name of the model served through vLLM>` | `custom_openai/Mixtral-8x7B-Instruct-v0.1` |
     | [Amazon Bedrock - 设置模型标识符](#set-the-model-identifier) | `bedrock/<model ID of the model>` | `bedrock/mistral.mixtral-8x7b-instruct-v0:1` |
     | [Amazon Bedrock - 使用应用程序推理配置文件 ARN](#use-an-application-inference-profile-arn) | `bedrock/converse/<application inference profile ARN>` | `bedrock/converse/arn:aws:bedrock:us-east-1:123456789012:application-inference-profile/abcd1234efgh` |
     | [Amazon Bedrock Mantle](supported_llm_serving_platforms.md#configure-amazon-bedrock-mantle) | `bedrock_mantle/<model ID of the model>` | `bedrock_mantle/openai.gpt-oss-120b` |
     | Gemini Enterprise Agent Platform | `vertex_ai/<model ID of the model>` | `vertex_ai/claude-sonnet-4-6@default` |
     | Anthropic                                                             | `anthropic/<model ID of the model>`                     | `anthropic/claude-opus-4-6` |
     | OpenAI                                                                | `openai/<model ID of the model>`                        | `openai/gpt-5` |
     | [Azure OpenAI](supported_llm_serving_platforms.md#configure-azure-openai) | `azure/<deployment name>` | `azure/gpt-4o` |
     | [Azure OpenAI Responses API](supported_llm_serving_platforms.md#use-the-responses-api) | `azure/responses/<deployment name>` | `azure/responses/gpt-5` |

1. 选择**添加自部署模型**。

<a id="add-an-amazon-bedrock-model"></a>

### 添加 Amazon Bedrock 模型

添加 Amazon Bedrock 自部署模型时，您可以执行以下任一操作：

- 设置模型标识符。这是默认方式。
- 使用[应用程序推理配置文件](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-create.html) ARN。当您希望按团队或项目跟踪成本分配或支出时，请使用此方式。

<a id="set-the-model-identifier"></a>

#### 设置模型标识符

要为 Amazon Bedrock 模型设置模型标识符：

1. 设置您的 `AWS_REGION`。确保您在 AI 网关 Docker 配置中拥有对该区域中模型的访问权限。
1. 为跨区域推理，将区域前缀添加到模型的推理配置文件 ID。
1. 使用 `bedrock/` 前缀区域作为模型标识符的前缀。

   例如，对于东京区域中的 Anthropic Claude 4.0 模型：

   - `AWS_REGION` 为 `ap-northeast-1`。
   - 跨区域推理前缀为 `apac.`。
   - 模型标识符为 `bedrock/apac.anthropic.claude-sonnet-4-20250514-v1:0`。

某些区域不支持跨区域推理。对于这些区域，请不要在模型标识符中指定区域前缀。例如：

- `AWS_REGION` 为 `eu-west-2`。
- 模型标识符为 `anthropic.claude-sonnet-4-5-20250929-v1:0`。

<a id="use-an-application-inference-profile-arn"></a>

#### 使用应用程序推理配置文件 ARN

要将应用程序推理配置文件 ARN 用作模型标识符，请使用以下格式：

```plaintext
bedrock/converse/arn:aws:bedrock:<region>:<account-id>:application-inference-profile/<id>
```

例如：

```plaintext
bedrock/converse/arn:aws:bedrock:us-east-1:123456789012:application-inference-profile/abcd1234efgh
```

`converse/` 前缀会通过 Amazon Bedrock Converse API 路由请求，这是
基于 ARN 的标识符所必需的。

<a id="embedding-model"></a>

### 嵌入模型

对于嵌入模型系列，各平台支持的模型如下：

- API：使用任何 OpenAI 兼容的嵌入模型，
  并带有 `openai/` 前缀。
  LiteLLM 不支持为嵌入模型使用 `custom_openai/` 前缀。
  不带前缀的模型标识符默认为 `openai`。
- Google Vertex AI：使用任何 Vertex AI 嵌入模型。
  对于最新模型，另请参阅 Gemini Enterprise Agent Platform 文档，
  并使用**测试连接**测试配置。
- Amazon Bedrock：使用任何 [Bedrock 嵌入模型](https://docs.litellm.ai/docs/embedding/supported_embedding#bedrock-embedding)。
  对于最新模型，另请参阅
  [Amazon Bedrock 文档](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)，
  并使用**测试连接**测试配置。

要请求支持其他嵌入模型，请参阅[史诗 23917](https://gitlab.com/groups/gitlab-org/-/work_items/23917)。

<a id="turn-on-self-hosted-beta-models-and-features"></a>

## 开启自部署测试版模型和功能

> [!note]
> 开启测试版自部署模型和功能也表示接受 [GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。

要启用自部署测试版模型和功能：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**自部署测试版模型和功能**下，选中**在极狐GitLab Duo 自部署版本中使用测试版模型和功能**复选框。
1. 选择**保存更改**。

<a id="configure-gitlab-duo-features-to-use-self-hosted-models"></a>

## 配置极狐GitLab Duo 功能以使用自部署模型

<a id="view-configured-features"></a>

### 查看已配置的功能

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**为极狐GitLab Duo 配置模型**。
   - 如果**为极狐GitLab Duo 配置模型**不可用，请在购买后同步您的
     订阅：
     1. 在左侧边栏中，选择**订阅**。
     1. 在**订阅详情**中，在**上次同步**右侧，选择
        同步订阅（{{< icon name="retry" >}}）。
1. 选择 **AI 原生功能**标签页。

<a id="select-a-self-hosted-model-for-a-feature"></a>

### 为某项功能选择自部署模型

要选择自部署模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**为极狐GitLab Duo 配置模型**。
1. 选择 **AI 原生功能**标签页。
1. 对于您要为其选择自部署模型的功能，从下拉列表中选择该模型。

> [!note]
> 如果您没有为某个极狐GitLab Duo Chat 子功能指定模型，它会自动使用为**通用聊天**配置的模型。
> 这可确保所有聊天功能都能正常工作，而无需为每个子功能单独选择模型。

<a id="select-a-gitlab-managed-model-for-a-feature"></a>

### 为某项功能选择极狐GitLab 托管模型

即使您使用自部署的 AI 网关和自部署模型，您也可以为某项功能选择极狐GitLab 托管模型。

使用离线许可证时，极狐GitLab 托管模型不可用。更多信息，请参阅[模型选择](../gitlab_duo/model_selection.md)。

要为某项功能选择极狐GitLab 托管模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**为极狐GitLab Duo 配置模型**。
1. 选择 **AI 原生功能**标签页。
1. 对于您要配置的功能和子功能，从下拉列表中选择**极狐GitLab 托管模型**。

<a id="turn-off-gitlab-duo-features"></a>

### 关闭极狐GitLab Duo 功能

即使您没有为某项功能选择模型，极狐GitLab Duo 功能仍保持开启状态。

要关闭极狐GitLab Duo 功能：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**为极狐GitLab Duo 配置模型**。
1. 选择 **AI 原生功能**标签页。
1. 对于您要关闭的功能，从下拉列表中选择**已禁用**。
