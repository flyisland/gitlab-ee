---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 受支持的 LLM 服务平台。
title: 配置 LLM 平台
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

AI 网关通过 [LiteLLM](https://docs.litellm.ai/docs/providers) 支持多个 LLM 提供商。每个平台都有独特的功能和优势，可以满足不同的需求。以下文档概述了我们已验证和测试的提供商。如果您要使用的平台不在此文档中，请在[平台请求议题（议题 526144）](https://gitlab.com/gitlab-org/gitlab/-/issues/526144)中提供反馈。

<a id="use-multiple-models-and-platforms"></a>

## 使用多个模型和平台

您可以在同一个极狐GitLab 实例中使用多个模型和平台。

例如，您可以配置一个功能使用 Azure OpenAI，另一个功能使用 AWS Bedrock，或使用 vLLM 提供服务的自部署模型。

这种设置让您可以根据每个使用场景灵活选择最佳的模型和平台。模型必须受支持，并通过兼容的平台提供服务。

<a id="self-hosted-model-deployments"></a>

## 自部署模型部署

<a id="vllm"></a>

### vLLM

[vLLM](https://docs.vllm.ai/en/latest/index.html) 是一个高性能推理服务器，针对 LLM 服务进行了内存效率优化。它支持模型并行，并且可以轻松集成到现有工作流中。

要安装 vLLM，请参阅 [vLLM 安装指南](https://docs.vllm.ai/en/latest/getting_started/installation/)。您应安装 [v0.18.1 版本](https://github.com/vllm-project/vllm/releases/tag/v0.18.1)或更高版本。

有关使用 vLLM 服务 GPT OSS 120B 的规范性设置指南，请参阅“使用 vLLM 服务 GPT OSS 120B”。

<a id="configuring-the-endpoint-url"></a>

#### 配置端点 URL

在极狐GitLab 中为任何兼容 OpenAI API 的平台（如 vLLM）配置端点 URL 时：

- URL 必须以 `/v1` 结尾
- 如果使用默认的 vLLM 配置，端点 URL 将为 `https://<hostname>:8000/v1`
- 如果您的服务器配置在代理或负载均衡器后面，您可能不需要指定端口，在这种情况下，URL 将为 `https://<hostname>/v1`

<a id="find-the-model-name"></a>

#### 查找模型名称

模型部署后，要获取极狐GitLab 中模型标识符字段的模型名称，请查询 vLLM 服务器的 `/v1/models` 端点：

```shell
curl \
  --header "Authorization: Bearer API_KEY" \
  --header "Content-Type: application/json" \
  http://your-vllm-server:8000/v1/models
```

模型名称是响应中 `data.id` 字段的值。

示例响应：

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

在此示例中，如果模型的 `id` 为 `Mixtral-8x22B-Instruct-v0.1`，您需要在极狐GitLab 中将模型标识符设置为 `custom_openai/Mixtral-8x22B-Instruct-v0.1`。

有关更多信息，请参阅以下文档：

- vLLM 支持的模型，请参阅 [vLLM 支持的模型文档](https://docs.vllm.ai/en/latest/models/supported_models/)。
- 使用 vLLM 运行模型时的可用选项，请参阅 [vLLM 关于引擎参数的文档](https://docs.vllm.ai/en/stable/configuration/engine_args/)。

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

1. 重命名 tokenizer 配置：

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
> 仅在您不需要详细的请求日志记录时使用此标志。

禁用请求日志记录可以最大限度地减少详细日志带来的开销，尤其是在高负载下，并有助于提高性能水平。

```shell
vllm serve <path-to-model>/<model-version> \
--served_model_name <choose-a-name-for-the-model>  \
--disable-log-requests
```

据观察，此更改在内部基准测试中显著改善了响应时间。

<a id="cloud-hosted-model-deployments"></a>

## 云托管模型部署

极狐GitLab 已验证并测试了以下提供商。AI 网关支持与 [LiteLLM](https://docs.litellm.ai/docs/providers) 兼容的 LLM 提供商。

- [AWS Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)
- [Amazon Bedrock Mantle](#configure-amazon-bedrock-mantle)
- Gemini Enterprise Agent Platform
- Azure OpenAI
- Anthropic
- OpenAI

<a id="configure-authentication-with-aws-bedrock"></a>

### 使用 AWS Bedrock 配置身份验证

您可以使用多种方法让您的 AI 网关向 AWS Bedrock 进行身份验证。

先决条件：

- 模型在首次调用时会自动在 Bedrock 中启用。有关更多信息，请参阅 [Bedrock 模型访问](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)。
- 已配置具有适当 IAM 权限的 AWS 凭证。

<a id="amazon-eks-with-helm-chart-recommended"></a>

#### 使用 Helm Chart 的 Amazon EKS（推荐）

为您的 AI 网关 pod 使用 IRSA（服务账号的 IAM 角色）向 AWS Bedrock 进行身份验证，而无需存储静态凭证。

使用 IRSA 验证 Amazon EKS 后，AI 网关会自动从 IRSA 角色获取临时凭证。

要使用 IRSA 验证 Amazon EKS：

1. 创建授予 Bedrock 模型访问权限的 IAM 策略。如果您需要更高的安全性，可以将其范围限定到特定模型：

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

1. 可选。要实现更严格的访问控制，请将通配符资源替换为特定的模型 Amazon Resource Name (ARN)。
   这可以确保即使极狐GitLab 配置发生更改，也只能访问已批准的模型。有关可用的模型 ARN，请参阅 [Amazon Bedrock 模型 ID](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)。

   ```json
   "Resource": [
     "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
     "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
   ]
   ```

   > [!note]
   > 某些模型可能使用不同的 ARN 格式。例如，较新的模型可能除了基础模型 ARN 之外，还需要推理配置文件 ARN。要检查您的特定模型的 ARN 格式，请参阅 [Amazon Bedrock 模型 ID](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)。

1. 创建一个 IAM 角色，并为其设置信任策略，供您的 Amazon EKS 服务账号使用。替换以下值：

   - `YOUR_ACCOUNT_ID`：您的 AWS 账户 ID。
   - `REGION`：您的 Amazon EKS 集群区域（例如，`us-east-1`）。
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

有关更多信息，请参阅 [服务账号的 IAM 角色](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)。

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

IAM 用户或角色必须具有类似于您在 Amazon EKS with Helm Chart 中设置的策略。

<a id="kubernetes-deployments"></a>

#### Kubernetes 部署

对于 Amazon EKS 以外的 Kubernetes 集群，您可以使用 Kubernetes 密钥来存储 AWS 凭证：

1. 创建 Kubernetes 密钥：

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

<a id="aws-bedrock-api-keys"></a>

#### AWS Bedrock API 密钥

要使用 AWS Bedrock API 密钥作为 IAM 凭证的替代方案：

1. [创建 Bedrock API 密钥](https://docs.aws.amazon.com/bedrock/latest/userguide/api-keys-generate.html)
1. 使用 API 密钥创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic bedrock-api-key \
     --from-literal=token=YOUR_BEDROCK_API_KEY \
     -n YOUR_NAMESPACE
   ```

1. 配置 AI 网关（添加到您的 `values.yaml` 中）：

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

#### Bedrock 防护机制

您可以使用 Amazon Bedrock Guardrails 为您的 Bedrock 模型请求提供安全和隐私控制。

要应用这些防护机制，请将 `AIGW_BEDROCK_GUARDRAIL_CONFIG` 环境变量的值设置为包含以下字段的 JSON 对象：

| 字段                 | 描述 |
|-----------------------|-------------|
| `guardrailIdentifier` | 您 AWS 账户中防护机制的 ID。可以是简单 ID（`abc123`）或完整 ARN（`arn:aws:bedrock:us-east-1:123456789012:guardrail/abc123`）。 |
| `guardrailVersion`    | 要应用的防护机制版本。设置为 `1`。 |
| `trace`               | 是否在响应中包含跟踪信息。可以设置为 `enabled` 或 `disabled`。 |

> [!note]
> 当防护机制阻止请求时，返回给用户的消息是您在 AWS Bedrock 防护机制中配置的自定义阻止消息，而不是极狐GitLab 提供的消息。请在 AWS 控制台中配置防护机制的阻止消息，以确保用户获得适当的指导。

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

[Amazon Bedrock Mantle](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-mantle.html) 是 AWS 提供的兼容 OpenAI API 的推理服务。
像其他兼容 OpenAI 的端点一样，使用 API 平台配置 Amazon Bedrock Mantle。

只有 GPT OSS 120B 在 Amazon Bedrock Mantle 上经过验证并受支持。

要配置 Amazon Bedrock Mantle 模型，请使用以下值[添加自部署模型](configure_duo_features.md#add-a-self-hosted-model)：

- 对于 **模型系列**，选择与模型匹配的系列。
  对于 GPT OSS 120B，选择 **GPT**。
- 对于 **端点**，输入区域端点，格式为 `https://bedrock-mantle.<region>.api.aws/v1`
  （例如，`https://bedrock-mantle.us-east-1.api.aws/v1`）。
- 对于 **模型标识符**，使用 `bedrock_mantle/` 前缀
  （例如，`bedrock_mantle/openai.gpt-oss-120b`）。
- 对于 **API 密钥**，输入 Amazon Bedrock Mantle API 密钥。
  有关更多信息，请参阅 [AWS Bedrock API 密钥](#aws-bedrock-api-keys)。

<a id="configure-authentication-with-gemini-enterprise-agent-platform"></a>

### 使用 Gemini Enterprise Agent Platform 配置身份验证

要使用 Gemini Enterprise Agent Platform 的模型，您必须验证您的 AI 网关实例。您可以使用以下任一机制：

- 在启动 Docker 容器时导出环境变量。为此，请在运行 AI 网关容器时设置以下环境变量：

  ```shell
  GOOGLE_APPLICATION_CREDENTIALS=/path/to/application_default_credentials.json
  VERTEXAI_PROJECT=<gcp-project-id>
  VERTEXAI_LOCATION=global # or any specific location, e.g., "europe-west1"
  ```

- 在 Google Cloud Run 上运行 AI 网关容器，并使用 [Cloud Run 服务账号](https://docs.litellm.ai/docs/providers/vertex#using-gcp-service-account) 访问 Gemini Enterprise Agent Platform。
