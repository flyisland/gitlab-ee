---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 支持的 LLM 服务平台。
title: 配置 LLM 平台
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

AI 网关通过 [LiteLLM](https://docs.litellm.ai/docs/providers) 支持多个 LLM 提供商。每个平台都有独特的功能和优势，可以满足不同的需求。以下文档汇总了我们已经验证和测试过的提供商。如果您想使用的平台不在本文档中，请在[平台请求议题（议题 526144）](https://gitlab.com/gitlab-org/gitlab/-/issues/526144)中提供反馈。

<a id="use-multiple-models-and-platforms"></a>

## 使用多个模型和平台

您可以在同一个极狐GitLab 实例中使用多个模型和平台。

例如，您可以配置一个功能使用 Azure OpenAI，另一个功能使用 AWS Bedrock，或者使用 vLLM 提供的自部署模型。

这种设置让您可以灵活地为每个用例选择最佳的模型和平台。模型必须受支持，并通过兼容的平台提供服务。

<a id="self-hosted-model-deployments"></a>

## 自部署模型部署

<a id="vllm"></a>

### vLLM

[vLLM](https://docs.vllm.ai/en/latest/index.html) 是一个高性能推理服务器，针对以内存高效的方式提供 LLM 服务进行了优化。它支持模型并行，并且可以轻松集成到现有工作流中。

要安装 vLLM，请参阅 [vLLM 安装指南](https://docs.vllm.ai/en/latest/getting_started/installation/)。您应安装 [v0.18.1 版本](https://github.com/vllm-project/vllm/releases/tag/v0.18.1)或更高版本。

有关使用 vLLM 提供 GPT OSS 120B 服务的规范性设置指南，请参阅[使用 vLLM 提供 GPT OSS 120B 服务](vllm_gpt_oss_120b.md)。

<a id="configuring-the-endpoint-url"></a>

#### 配置端点 URL

在极狐GitLab 中为任何兼容 OpenAI API 的平台（例如 vLLM）配置端点 URL 时：

- URL 必须以 `/v1` 为后缀
- 如果使用默认的 vLLM 配置，端点 URL 为 `https://<hostname>:8000/v1`
- 如果您的服务器配置在代理或负载均衡器后面，您可能不需要指定端口，此时 URL 为 `https://<hostname>/v1`

<a id="find-the-model-name"></a>

#### 查找模型名称

模型部署完成后，要获取极狐GitLab 中模型标识符字段所需的模型名称，请查询 vLLM 服务器的 `/v1/models` 端点：

```shell
curl \
  --header "Authorization: Bearer API_KEY" \
  --header "Content-Type: application/json" \
  http://your-vllm-server:8000/v1/models
```

模型名称是响应中 `data.id` 字段的值。

响应示例：

```json
{
  "object": "list",
  "data": [
    {
      "id": "Mixtral-8x22B-Instruct-v0.1",
      "object": "model",
      "created": 1739421415,
      "owned_by": "vllm",
      "root": "mistralai/Mixtral-8x22B-Instruct-v0.1",
      // Additional fields removed for readability
    }
  ]
}
```

在此示例中，如果模型的 `id` 为 `Mixtral-8x22B-Instruct-v0.1`，您应在极狐GitLab 中将模型标识符设置为 `custom_openai/Mixtral-8x22B-Instruct-v0.1`。

有关更多信息，请参阅以下文档：

- vLLM 支持的模型，请参阅 [vLLM 支持的模型文档](https://docs.vllm.ai/en/latest/models/supported_models/)。
- 使用 vLLM 运行模型时的可用选项，请参阅 [vLLM 引擎参数文档](https://docs.vllm.ai/en/stable/configuration/engine_args/)。

<a id="mistral-7b-instruct-v02"></a>

#### Mistral-7B-Instruct-v0.2

1. 从 HuggingFace 下载模型：

   ```shell
   git clone https://<your-hugging-face-username>:<your-hugging-face-token>@huggingface.co/mistralai/Mistral-7B-Instruct-v0.3
   ```

1. 运行服务器：

   ```shell
   vllm serve <path-to-model>/Mistral-7B-Instruct-v0.3 \
      --served_model_name <choose-a-name-for-the-model>  \
      --tokenizer_mode mistral \
      --tensor_parallel_size <number-of-gpus> \
      --load_format mistral \
      --config_format mistral \
      --tokenizer <path-to-model>/Mistral-7B-Instruct-v0.3
   ```

<a id="mixtral-8x7b-instruct-v01"></a>

#### Mixtral-8x7B-Instruct-v0.1

1. 从 HuggingFace 下载模型：

   ```shell
   git clone https://<your-hugging-face-username>:<your-hugging-face-token>@huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1
   ```

1. 重命名令牌配置：

   ```shell
   cd <path-to-model>/Mixtral-8x7B-Instruct-v0.1
   cp tokenizer.model tokenizer.model.v3
   ```

1. 运行模型：

   ```shell
   vllm serve <path-to-model>/Mixtral-8x7B-Instruct-v0.1 \
     --tensor_parallel_size 4 \
     --served_model_name <choose-a-name-for-the-model> \
     --tokenizer_mode mistral \
     --load_format safetensors \
     --tokenizer <path-to-model>/Mixtral-8x7B-Instruct-v0.1
   ```

<a id="disable-request-logging-to-reduce-latency"></a>

#### 禁用请求日志记录以降低延迟

在生产环境中运行 vLLM 时，您可以使用 `--disable-log-requests` 标志禁用请求日志记录，从而显著降低延迟。

> [!note]
> 仅在不需要详细请求日志记录时使用此标志。

禁用请求日志记录可以最大限度地减少详细日志带来的开销，尤其是在高负载下，并有助于提升性能水平。

```shell
vllm serve <path-to-model>/<model-version> \
--served_model_name <choose-a-name-for-the-model>  \
--disable-log-requests
```

在内部基准测试中，已观察到此更改可显著改善响应时间。

<a id="cloud-hosted-model-deployments"></a>

## 云托管模型部署

极狐GitLab 已验证并测试了以下提供商。AI 网关支持与 [LiteLLM](https://docs.litellm.ai/docs/providers) 兼容的 LLM 提供商。

- [AWS Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)
- [Amazon Bedrock Mantle](#configure-amazon-bedrock-mantle)
- Gemini Enterprise Agent Platform
- [Azure OpenAI](#configure-azure-openai)
- Anthropic
- OpenAI

<a id="configure-authentication-with-aws-bedrock"></a>

### 配置 AWS Bedrock 身份验证

您可以使用多种方法为您的 AI 网关配置 AWS Bedrock 身份验证。

先决条件：

- 模型在首次调用时会在 Bedrock 中自动启用。有关更多信息，
  请参阅 [Bedrock 模型访问](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)。
- 已配置具有适当 IAM 权限的 AWS 凭证。

<a id="amazon-eks-with-helm-chart-recommended"></a>

#### 使用 Helm Chart 的 Amazon EKS（推荐）

为您的 AI 网关 pod 使用 IRSA（IAM Roles for Service Accounts）向 AWS Bedrock 进行身份验证，无需存储静态凭证。

在使用 IRSA 对 Amazon EKS 进行身份验证后，
AI 网关会自动从 IRSA 角色获取临时凭证。

要使用 IRSA 对 Amazon EKS 进行身份验证：

1. 创建一个授予 Bedrock 模型访问权限的 IAM 策略。如果您需要更高的安全性，可以将其范围限定为特定模型：

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "bedrock:InvokeModel",
           "bedrock:InvokeModelWithResponseStream"
         ],
         "Resource": "arn:aws:bedrock:*::foundation-model/*"
       }
     ]
   }
   ```

   ```shell
   aws iam create-policy \
     --policy-name bedrock-ai-gateway-access \
     --policy-document file://bedrock-policy.json \
     --description "Bedrock access for AI Gateway"
   ```

1. 可选。如需更严格的访问控制，请将通配符资源替换为特定模型的 Amazon Resource Name (ARN)。
   这可确保即使极狐GitLab 配置发生变化，也只能访问已批准的模型。有关
   可用的模型 ARN，请参阅 [Amazon Bedrock 模型 ID](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)。

   ```json
   "Resource": [
     "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
     "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
   ]
   ```

   > [!note]
   > 某些模型可能使用不同的 ARN 格式。例如，较新的模型可能
   > 除了基础模型 ARN 之外还需要推理配置文件 ARN。要查看
   > 您特定模型的 ARN 格式，请参阅 [Amazon Bedrock 模型 ID](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)。

1. 创建一个 IAM 角色，并为其设置供您的 Amazon EKS 服务账号使用的信任策略。替换以下值：

   - `YOUR_ACCOUNT_ID`：您的 AWS 账号 ID。
   - `REGION`：您的 Amazon EKS 集群区域（例如 `us-east-1`）。
   - `YOUR_OIDC_ID`：您的 Amazon EKS 集群的 OIDC 提供商 ID。
   - `NAMESPACE`：部署 AI 网关的 Kubernetes 命名空间。

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/YOUR_OIDC_ID"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "oidc.eks.REGION.amazonaws.com/id/YOUR_OIDC_ID:sub": "system:serviceaccount:NAMESPACE:ai-gateway",
             "oidc.eks.REGION.amazonaws.com/id/YOUR_OIDC_ID:aud": "sts.amazonaws.com"
           }
         }
       }
     ]
   }
   ```

   ```shell
   # Create the role
   aws iam create-role \
     --role-name eks-ai-gateway-bedrock \
     --assume-role-policy-document file://trust-policy.json \
     --description "EKS IRSA role for AI Gateway to access Bedrock"
   ```

1. 将 Bedrock IAM 策略附加到此角色。

   ```shell
   # Attach the role
   aws iam attach-role-policy \
     --role-name eks-ai-gateway-bedrock \
     --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/bedrock-ai-gateway-access
   ```

1. 要配置 Helm chart，请使用 IAM 角色注解安装 AI 网关：

   ```yaml
   serviceAccount:
     create: true
     name: ai-gateway
     annotations:
       eks.amazonaws.com/role-arn: arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME
   extraEnvironmentVariables:
     - name: AWS_REGION
       value: us-east-1
   ```

有关更多信息，请参阅 [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)。

<a id="docker-deployments"></a>

#### Docker 部署

在启动 AI 网关容器时，通过环境变量配置 IAM 凭证：

```shell
docker run -d \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  -e AWS_REGION=us-east-1 \
  -p 5052:5052 \
  registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-vX.Y.Z-jh
```

IAM 用户或角色必须具有与您在 Amazon EKS 中使用 Helm Chart 设置的策略类似的策略。

<a id="kubernetes-deployments"></a>

#### Kubernetes 部署

对于 Amazon EKS 以外的 Kubernetes 集群，您可以使用 Kubernetes 密钥存储 AWS 凭证：

1. 创建一个 Kubernetes 密钥：

   ```shell
   kubectl create secret generic aws-credentials \
     --from-literal=access-key-id=YOUR_ACCESS_KEY_ID \
     --from-literal=secret-access-key=YOUR_SECRET_ACCESS_KEY \
     -n YOUR_NAMESPACE
   ```

1. 配置 Helm chart 以引用该密钥：

   ```yaml
   extraEnvironmentVariables:
     - name: AWS_ACCESS_KEY_ID
       valueFrom:
         secretKeyRef:
           name: aws-credentials
           key: access-key-id
     - name: AWS_SECRET_ACCESS_KEY
       valueFrom:
         secretKeyRef:
           name: aws-credentials
           key: secret-access-key
     - name: AWS_REGION
       value: us-east-1
   ```

<a id="assume-an-iam-role-with-aws-bedrock"></a>

#### 使用 AWS Bedrock 代入 IAM 角色

默认情况下，AI 网关使用其已有的凭证调用 Bedrock（例如 IRSA 角色或环境变量）。要使用不同的角色调用 Bedrock（例如另一个 AWS 账号中的角色），请为每个自部署模型提供一个 IAM 角色。AI 网关使用自己的凭证，通过
AWS Security Token Service (STS) [`AssumeRole`](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) 操作代入该角色。
然后，AI 网关使用临时凭证调用 Bedrock。

先决条件：

- 管理员访问权限。
- [AI 网关已通过 AWS 身份验证](#configure-authentication-with-aws-bedrock)。
  AI 网关运行时所使用的 AWS 身份可以对该角色调用 `sts:AssumeRole`。

要在调用 Bedrock 时代入 IAM 角色：

1. 在目标 AWS 账号中，创建一个具有以下
   信任关系策略的 IAM 角色。替换：

   - `AI_GATEWAY_PRINCIPAL_ARN` 为 AI 网关运行时所使用的 AWS 身份的 ARN
     （例如 `arn:aws:iam::AI_GATEWAY_ACCOUNT_ID:role/eks-ai-gateway-bedrock` IRSA 角色）。
   - `GITLAB_INSTANCE_ID` 为您的极狐GitLab 实例 ID，与
     **IAM role to assume** 文本框中显示的一致。

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": "AI_GATEWAY_PRINCIPAL_ARN"
         },
         "Action": "sts:AssumeRole",
         "Condition": {
           "StringEquals": {
             "sts:ExternalId": "GITLAB_INSTANCE_ID"
           }
         }
       }
     ]
   }
   ```

   AI 网关在代入角色时会将实例 ID 作为 STS 外部 ID 发送。
   该条件可防止知道角色 ARN 的其他 AI 网关客户使用
   AI 网关的身份代入您的角色（混淆代理问题）。
   实例 ID 不是密钥。

1. 要调用 Bedrock 模型，请为该角色附加权限策略。
   您可以将 `Resource`的范围限定为特定模型：

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "bedrock:InvokeModel",
           "bedrock:InvokeModelWithResponseStream"
         ],
         "Resource": "arn:aws:bedrock:*::foundation-model/*"
       }
     ]
   }
   ```

1. 如果 AI 网关与角色运行在不同的账号中，还需通过基于身份的策略允许 AI 网关
   身份对该角色调用 `sts:AssumeRole`：

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": "sts:AssumeRole",
         "Resource": "arn:aws:iam::ROLE_ACCOUNT_ID:role/YOUR_ROLE_NAME"
       }
     ]
   }
   ```

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **为极狐GitLab Duo 配置模型**。
1. 对于 **Amazon Bedrock** 平台，添加或编辑自部署模型。
1. 可选。在 **IAM role to assume** 文本框中，输入角色的 ARN
   （例如 `arn:aws:iam::123456789012:role/YOUR_ROLE_NAME`）。
   如果留空，AI 网关将使用自己的凭证。
1. 可选。选择**测试连接**。
1. 选择**添加自部署模型**。

IAM 角色和 API 密钥（持有者令牌）互斥。极狐GitLab 不接受为具有 API 密钥的模型设置 IAM 角色，并且 AI 网关会拒绝同时包含两者的请求。

> [!note]
> 要发送 STS 外部 ID，AI 网关版本必须包含
> [对 Amazon Bedrock 模型的 `AssumeRole` 支持](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/merge_requests/7210)。
> 使用较早的 AI 网关版本时，AI 网关不会发送 STS 外部 ID，
> 如果信任策略要求 `sts:ExternalId`，则角色代入会失败。

<a id="aws-bedrock-api-keys"></a>

#### AWS Bedrock API 密钥

要使用 AWS Bedrock API 密钥作为 IAM 凭证的替代方案：

1. [创建 Bedrock API 密钥](https://docs.aws.amazon.com/bedrock/latest/userguide/api-keys-generate.html)
1. 使用该 API 密钥创建一个 Kubernetes 密钥：

   ```shell
   kubectl create secret generic bedrock-api-key \
     --from-literal=token=YOUR_BEDROCK_API_KEY \
     -n YOUR_NAMESPACE
   ```

1. 配置 AI 网关（添加到您的 `values.yaml`）：

   ```yaml
   extraEnvironmentVariables:
     - name: AWS_BEARER_TOKEN_BEDROCK
       valueFrom:
         secretKeyRef:
           name: bedrock-api-key
           key: token
     - name: AWS_REGION
       value: us-east-1
   ```

<a id="private-vpc-endpoints"></a>

#### 私有 VPC 端点

要在 VPC 中使用私有 Bedrock 端点，请设置 `AWS_BEDROCK_RUNTIME_ENDPOINT` 环境变量。

对于 Helm 部署：

```yaml
extraEnvironmentVariables:
  - name: AWS_BEDROCK_RUNTIME_ENDPOINT
    value: https://bedrock-runtime.us-east-1.amazonaws.com
```

对于 Docker 部署：

```shell
docker run -d \
  -e AWS_BEDROCK_RUNTIME_ENDPOINT=https://bedrock-runtime.us-east-1.amazonaws.com \
  -e AWS_REGION=us-east-1 \
  # ... other configuration
```

对于 VPC 端点，请使用以下格式：`https://vpce-{vpc-endpoint-id}-{service-name}.{region}.vpce.amazonaws.com`

<a id="bedrock-guardrails"></a>

#### Bedrock 护栏

您可以使用 Amazon Bedrock Guardrails 为您的 Bedrock 模型请求提供安全和隐私控制。

要应用这些护栏，请将 `AIGW_BEDROCK_GUARDRAIL_CONFIG` 环境变量的值设置为一个包含以下字段的 JSON 对象：

| 字段                 | 描述 |
|-----------------------|-------------|
| `guardrailIdentifier` | 您 AWS 账号中护栏的 ID。可以是简单 ID（`abc123`），或完整 ARN（`arn:aws:bedrock:us-east-1:123456789012:guardrail/abc123`）。 |
| `guardrailVersion`    | 要应用的护栏版本。设置为 `1`。 |
| `trace`               | 是否在响应中包含跟踪信息。可以设置为 `enabled` 或 `disabled`。 |

> [!note]
> 当护栏阻止请求时，返回给用户的消息是您在 AWS Bedrock 护栏中配置的自定义阻止消息，
> 而不是极狐GitLab 提供的消息。请在 AWS 控制台中配置护栏的
> 阻止消息，以确保用户收到适当的指引。

对于 Helm 部署，请按如下方式设置环境变量：

```yaml
extraEnvironmentVariables:
  - name: AIGW_BEDROCK_GUARDRAIL_CONFIG
    value: '{"guardrailIdentifier": "<guardrail_id>", "guardrailVersion": "1", "trace": "disabled"}'
```

对于 Docker 部署：

```shell
docker run -d \
  -e AIGW_BEDROCK_GUARDRAIL_CONFIG='{"guardrailIdentifier": "<guardrail_id>", "guardrailVersion": "1", "trace": "disabled"}' \
  # ... other configuration
```

有关更多信息，请参阅 [Amazon Bedrock Guardrails](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html)。

<a id="configure-amazon-bedrock-mantle"></a>

### 配置 Amazon Bedrock Mantle

{{< details >}}

- Status: 测试版

{{< /details >}}

[Amazon Bedrock Mantle](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-mantle.html) 是 AWS 提供的
兼容 OpenAI API 的推理服务。
像配置其他兼容 OpenAI 的端点一样，使用 API 平台配置 Amazon Bedrock Mantle。

以下模型已在 Amazon Bedrock Mantle 上验证并受支持：

| 模型 | 模型标识符 |
|-------|------------------|
| GPT-5.4 | `bedrock_mantle/openai.gpt-5.4` |
| GPT-5.5 | `bedrock_mantle/openai.gpt-5.5` |
| GPT-5.6 Luna | `bedrock_mantle/openai.gpt-5.6-luna` |
| GPT-5.6 Sol | `bedrock_mantle/openai.gpt-5.6-sol` |
| GPT-5.6 Terra | `bedrock_mantle/openai.gpt-5.6-terra` |
| GPT-6 Astra | `bedrock_mantle/openai.gpt-6-astra` |
| GPT-6 Luna | `bedrock_mantle/openai.gpt-6-luna` |
| GPT-6 Sol | `bedrock_mantle/openai.gpt-6-sol` |
| GPT-6.1 Sol | `bedrock_mantle/openai.gpt-6.1-sol` |
| GPT OSS 120B | `bedrock_mantle/openai.gpt-oss-120b` |

AI 网关会将 GPT-5 及更高版本模型的请求发送到 Amazon Bedrock Mantle 的 Responses API。
所有模型都使用相同的 `bedrock_mantle/` 前缀。

Amazon Bedrock Mantle 不支持 Anthropic models。
Amazon Bedrock Mantle 仅通过 Anthropic Messages API 提供这些模型，
而 AI 网关不会为此平台使用该 API。
要在 AWS 上使用 Anthropic models，请改为[添加 Amazon Bedrock 模型](configure_duo_features.md#add-an-amazon-bedrock-model)。

要配置 Amazon Bedrock Mantle 模型，
请使用以下值[添加自部署模型](configure_duo_features.md#add-a-self-hosted-model)：

- 对于 **模型系列**，选择与模型匹配的系列。
  对于 OpenAI 模型，选择 **GPT**。
- 对于 **端点**，输入以下形式的区域端点 `https://bedrock-mantle.<region>.api.aws/v1`
  （例如 `https://bedrock-mantle.us-east-1.api.aws/v1`）。
- 对于 **模型标识符**，使用 `bedrock_mantle/` 前缀
  （例如 `bedrock_mantle/openai.gpt-oss-120b`）。
- 对于 **API 密钥**，输入 Amazon Bedrock Mantle API 密钥。
  有关更多信息，请参阅 [AWS Bedrock API 密钥](#aws-bedrock-api-keys)。

<a id="configure-azure-openai"></a>

### 配置 Azure OpenAI

Azure OpenAI
通过 Chat Completions API 和
[Responses API](https://learn.microsoft.com/en-us/azure/foundry/openai/how-to/responses) 提供模型服务。
大多数模型支持 Chat Completions API。
某些较新的模型只能通过 Responses API 使用。

要配置 Azure OpenAI 模型，
请使用以下值[添加自部署模型](configure_duo_features.md#add-a-self-hosted-model)：

- 对于 **模型系列**，选择与模型匹配的系列。
  对于 GPT-5，选择 **GPT**。
- 对于 **端点**，以
  `https://<resource-name>.openai.azure.com` 格式输入您的 Azure OpenAI 资源的端点。不要添加路径或 API 版本。
- 对于 **模型标识符**，使用 `azure/` 前缀，后跟您的部署名称
  （例如 `azure/gpt-4o`）。此标识符会将请求发送到 Chat Completions API。
  要改为将请求发送到 Responses API，
  请参阅[使用 Responses API](#use-the-responses-api)。
- 对于 **API 密钥**，输入您的 Azure OpenAI 资源的 API 密钥。

<a id="use-the-responses-api"></a>

#### 使用 Responses API

对于只能通过 Responses API 使用的部署，
请使用 `azure/responses/` 前缀。对于 **模型标识符**，输入该前缀，后跟您的部署名称（例如 `azure/responses/gpt-5`）。

AI 网关会将请求发送到您的资源的 `/openai/responses` 路径。AI 网关会将每个请求转换为 Responses API 格式，并将响应转换回来。该转换支持流式响应和工具调用。您不需要代理来在两个 API 之间进行转换。

<a id="configure-authentication-with-gemini-enterprise-agent-platform"></a>

### 配置 Gemini Enterprise Agent Platform 身份验证

要使用 Gemini Enterprise Agent Platform 中的模型，您必须对您的 AI 网关实例进行身份验证。您可以使用以下任一机制：

- 在启动 Docker 容器时导出环境变量。为此，请在运行 AI 网关容器时设置以下环境变量：

  ```shell
  GOOGLE_APPLICATION_CREDENTIALS=/path/to/application_default_credentials.json
  VERTEXAI_PROJECT=<gcp-project-id>
  VERTEXAI_LOCATION=global # or any specific location, e.g., "europe-west1"
  ```

- 在 Google Cloud Run 上运行 AI 网关容器，并使用 [Cloud Run 服务账号](https://docs.litellm.ai/docs/providers/vertex#using-gcp-service-account)访问 Gemini Enterprise Agent Platform。
