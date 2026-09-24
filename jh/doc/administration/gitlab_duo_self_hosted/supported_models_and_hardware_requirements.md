---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Supported models and hardware requirements.
title: 模型和硬件要求
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.4 引入，[使用功能标志](../feature_flags/_index.md) 名为 `ai_custom_model`。默认禁用。
- 在极狐GitLab 17.6 对私有化部署启用。
- 在极狐GitLab 17.6 及之后版本改为需要极狐GitLab Duo 附加组件。
- 功能标志 `ai_custom_model` 在极狐GitLab 17.8 移除。
- 在极狐GitLab 17.9 达到 GA。
- 在极狐GitLab 18.0 改为包含专业版。

{{< /history >}}

您可以通过您偏好的服务平台，集成来自业内领先模型。

您可以使用：

- 受支持的模型，以满足您特定的性能需求和用例。
- 在极狐GitLab 18.3 及更高版本中，使用您自己的兼容模型，体验官方支持选项之外的模型。
- 极狐GitLab 托管模型，无需托管自己的基础设施即可连接到 AI 模型。这些模型完全由极狐GitLab 管理。

<a id="supported-models"></a>

## 支持的模型

极狐GitLab 支持的模型为极狐GitLab Duo 功能提供不同级别的功能，
具体取决于特定的模型和功能组合。

- {{< icon name="check-circle-filled" >}} 完整功能：该模型很可能能够处理该功能，且没有质量损失。
- {{< icon name="check-circle-dashed" >}} 部分功能：该模型支持该功能，但可能存在妥协或限制。
- {{< icon name="dash-circle" >}} 有限功能：该模型不适合该功能，可能会导致显著的质量下降或性能问题。
  对于某功能具有有限功能的模型，极狐GitLab 将不会为该特定功能提供支持。

<!-- vale gitlab_base.Spelling = NO -->

| 模型家族 | 模型 | 代码补全 | 代码生成 | 极狐GitLab Duo 非 Agentic 聊天 | 极狐GitLab Duo Agent Platform |
|--------------|-------|-----------------|-----------------|---------------------------|---------------------------|
| Claude 4 | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| Claude 4 | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| Claude 4 | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| Claude 4 | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="dash-circle" >}} 有限功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="dash-circle" >}} 有限功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-dashed" >}} 部分功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 |
| GPT | 国内 SOTA 模型 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Mistral Codestral | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Mistral | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Llama | 国内 SOTA 模型 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Llama | 国内 SOTA 模型 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Llama | 国内 SOTA 模型 | {{< icon name="check-circle-dashed" >}} 部分功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Llama | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 |
| Llama | 国内 SOTA 模型 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="check-circle-filled" >}} 完整功能 | {{< icon name="dash-circle" >}} 有限功能 |

<a id="compatible-models"></a>

### 兼容模型

{{< details >}}

- 状态：Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 [引入](https://gitlab.com/groups/gitlab-org/-/epics/18556) 作为 [beta](../../policy/development_stages_support.md#beta)。

{{< /history >}}

您可以将自己的兼容模型和平台与极狐GitLab Duo 功能结合使用。对于未包含在支持模型家族中的兼容模型，请使用通用模型家族。这包括您自己托管的模型（例如，通过 vLLM 或 LiteLLM 提供服务），但要求它们通过 OpenAI API 兼容的 `/v1` 端点对外暴露。

兼容模型不在 [AI 功能条款](https://handbook.gitlab.com/handbook/legal/ai-functionality-terms/) 中定义的客户集成模型的定义范围内。兼容模型和平台必须遵守 OpenAI API 规范。先前被标记为实验性或 beta 的模型和平台现在视为兼容模型。

此功能处于 beta 阶段，因此可能会随着我们收集反馈和改进集成而发生变化：

- 极狐GitLab 不为您选择的特定模型或平台问题提供技术支持。
- 并非所有极狐GitLab Duo 功能都能保证与每个兼容模型最优地配合工作。
- 响应质量、速度和整体性能可能因您的模型选择而显著不同。

| 模型家族 | 模型 |
|----------------|-------|
| 通用 | 任何与 [OpenAI API 规范](https://platform.openai.com/docs/api-reference) 兼容的模型 |
| CodeGemma | 国内 SOTA 模型 |
| CodeGemma | 国内 SOTA 模型 |
| CodeGemma | 国内 SOTA 模型 |
| Code Llama | 国内 SOTA 模型 |
| DeepSeek Coder | [DeepSeek Coder 33b Instruct](https://huggingface.co/deepseek-ai/deepseek-coder-33b-instruct) |
| DeepSeek Coder | [DeepSeek Coder 33b Base](https://huggingface.co/deepseek-ai/deepseek-coder-33b-base) |
| Devstral 2 | 国内 SOTA 模型 |
| GLM | [GLM-5.1-FP8](https://huggingface.co/zai-org/GLM-5.1-FP8) |
| Kimi K2 | [Kimi K2.5](https://huggingface.co/moonshotai/Kimi-K2.5) |
| Kimi K2 | [Kimi K2.6](https://huggingface.co/moonshotai/Kimi-K2.6) |
| MiniMax | [MiniMax-M2.7](https://huggingface.co/MiniMaxAI/MiniMax-M2.7) |

<!-- vale gitlab_base.Spelling = YES -->

<a id="gitlab-managed-models"></a>

## 极狐GitLab 托管模型

{{< history >}}

- 在极狐GitLab 18.3 引入，作为一个 [beta](../../policy/development_stages_support.md#beta) 功能，并带有 [功能标志](../feature_flags/_index.md) 名为 `ai_self_hosted_vendored_features`。默认禁用。
- 在极狐GitLab 18.7 [默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/214030)。
- 功能标志 `ai_self_hosted_vendored_features` [在极狐GitLab 18.9 移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/218595)。

{{< /history >}}

极狐GitLab 托管模型与极狐GitLab 托管的 AI 网关基础设施集成，以提供由极狐GitLab 精选和提供的 AI 模型访问。您可以选择为特定的极狐GitLab Duo 功能使用极狐GitLab 托管模型，而不使用您自己的自部署模型。

要选择哪些功能使用极狐GitLab 托管模型，请参见 [为功能选择极狐GitLab 托管模型](configure_duo_features.md#select-a-gitlab-managed-model-for-a-feature)。

当为特定功能启用时：

- 所有配置了极狐GitLab 托管模型的功能调用都将使用极狐GitLab 托管的 AI 网关，而不是自托管的 AI 网关。
- 即使 [启用了 AI 日志](logging.md#turn-on-data-collection-for-gitlab-duo)，极狐GitLab 托管的 AI 网关中也不会生成详细日志。这可以防止敏感信息意外泄露。

<a id="hardware-requirements"></a>

## 硬件要求

以下硬件规格是在本地运行自托管极狐GitLab Duo 的最低要求。要求因模型规模和预期用途而异：

<a id="base-system-requirements"></a>

### 基础系统要求

- **CPU**：
  - 最低：8 核（16 线程）
  - 推荐：生产环境 16+ 核
- **内存**：
  - 最低：32 GB
  - 推荐：大多数模型为 64 GB
- **存储**：
  - 具有足够空间存放模型权重和数据的 SSD。

<a id="gpu-requirements-by-model-size"></a>

### 按模型规模的 GPU 要求

| 模型规模 | 最低 GPU 配置 | 最低显存要求 |
|--------------------------------------------|---------------------------|-----------------------|
| 7B 模型<br>（例如 Mistral 7B）  | 1x NVIDIA A100 (40 GB)    | 35 GB                 |
| 22B 模型<br>（例如 Codestral 22B） | 2x NVIDIA A100 (80 GB)    | 110 GB                |
| Mixtral 8x7B                               | 2x NVIDIA A100 (80 GB)    | 220 GB                |
| Mixtral 8x22B                              | 8x NVIDIA A100 (80 GB)    | 526 GB                |

使用 [Hugging Face 的内存工具](https://huggingface.co/spaces/hf-accelerate/model-memory-usage) 验证内存需求。

<a id="response-time-by-model-size-and-gpu"></a>

### 按模型规模和 GPU 的响应时间

<a id="small-machine"></a>

#### 小型机器

使用 `a2-highgpu-2g`（2x NVIDIA A100 40 GB - 150 GB vRAM）或同等配置：

| 模型名称 | 请求数量 | 每个请求平均时间（秒） | 响应平均 token 数 | 每个请求平均每秒 token 数 | 请求总时间 | 总 TPS |
|--------------------------|--------------------|------------------------------|----------------------------|---------------------------------------|-------------------------|-----------|
| Mistral-7B-Instruct-v0.3 | 1                  | 7.09                         | 717.0                      | 101.19                                | 7.09                    | 101.17    |
| Mistral-7B-Instruct-v0.3 | 10                 | 8.41                         | 764.2                      | 90.35                                 | 13.70                   | 557.80    |
| Mistral-7B-Instruct-v0.3 | 100                | 13.97                        | 693.23                     | 49.17                                 | 20.81                   | 3331.59   |

<a id="medium-machine"></a>

#### 中型机器

使用 `a2-ultragpu-4g`（4x NVIDIA A100 40 GB - 340 GB vRAM）机器（在 GCP 或同等配置上）：

| 模型名称 | 请求数量 | 每个请求平均时间（秒） | 响应平均 token 数 | 每个请求平均每秒 token 数 | 请求总时间 | 总 TPS |
|----------------------------|--------------------|------------------------------|----------------------------|---------------------------------------|-------------------------|-----------|
| Mistral-7B-Instruct-v0.3   | 1                  | 3.80                         | 499.0                      | 131.25                                | 3.80                    | 131.23    |
| Mistral-7B-Instruct-v0.3   | 10                 | 6.00                         | 740.6                      | 122.85                                | 8.19                    | 904.22    |
| Mistral-7B-Instruct-v0.3   | 100                | 11.71                        | 695.71                     | 59.06                                 | 15.54                   | 4477.34   |
| Mixtral-8x7B-Instruct-v0.1 | 1                  | 6.50                         | 400.0                      | 61.55                                 | 6.50                    | 61.53     |
| Mixtral-8x7B-Instruct-v0.1 | 10                 | 16.58                        | 768.9                      | 40.33                                 | 32.56                   | 236.13    |
| Mixtral-8x7B-Instruct-v0.1 | 100                | 25.90                        | 767.38                     | 26.87                                 | 55.57                   | 1380.68   |

<a id="large-machine"></a>

#### 大型机器

使用 `a2-ultragpu-8g`（8 x NVIDIA A100 80 GB - 1360 GB vRAM）机器（在 GCP 或同等配置上）：

| 模型名称 | 请求数量 | 每个请求平均时间（秒） | 响应平均 token 数 | 每个请求平均每秒 token 数 | 请求总时间（秒） | 总 TPS |
|-----------------------------|--------------------|------------------------------|----------------------------|---------------------------------------|-----------------------------|-----------|
| Mistral-7B-Instruct-v0.3    | 1                  | 3.23                         | 479.0                      | 148.41                                | 3.22                        | 148.36    |
| Mistral-7B-Instruct-v0.3    | 10                 | 4.95                         | 678.3                      | 135.98                                | 6.85                        | 989.11    |
| Mistral-7B-Instruct-v0.3    | 100                | 10.14                        | 713.27                     | 69.63                                 | 13.96                       | 5108.75   |
| Mixtral-8x7B-Instruct-v0.1  | 1                  | 6.08                         | 709.0                      | 116.69                                | 6.07                        | 116.64    |
| Mixtral-8x7B-Instruct-v0.1  | 10                 | 9.95                         | 645.0                      | 63.68                                 | 13.40                       | 481.06    |
| Mixtral-8x7B-Instruct-v0.1  | 100                | 13.83                        | 585.01                     | 41.80                                 | 20.38                       | 2869.12   |
| Mixtral-8x22B-Instruct-v0.1 | 1                  | 14.39                        | 828.0                      | 57.56                                 | 14.38                       | 57.55     |
| Mixtral-8x22B-Instruct-v0.1 | 10                 | 20.57                        | 629.7                      | 30.24                                 | 28.02                       | 224.71    |
| Mixtral-8x22B-Instruct-v0.1 | 100                | 27.58                        | 592.49                     | 21.34                                 | 36.80                       | 1609.85   |

<a id="ai-gateway-hardware-requirements"></a>

### AI 网关硬件要求

有关 AI 网关的硬件建议，请参见 [AI 网关扩展建议](../../install/install_ai_gateway.md#scaling-recommendations)。