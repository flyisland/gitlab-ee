---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: An example deployment of a model with vLLM, using GPT OSS 120B, from GPU selection through production monitoring.
title: 使用 vLLM 部署模型示例
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

GPT OSS 120B 作为使用 vLLM 部署的示例模型，涵盖了从 GPU 选型到生产环境监控的完整流程。

<a id="gpu-selection"></a>

## GPU 选型

GPT OSS 120B 在 NVIDIA H100 上训练，在 H100 或更新的数据中心 GPU 上运行效果最佳。其混合专家（MoE）架构仅为每个 Token 激活网络的一个子集，因此该模型能够装入单个 H100 80 GB GPU。

<a id="determine-a-parallelism-strategy"></a>

### 确定并行策略

您的 GPU 连接方式决定了以下并行策略：

- 如果您的 GPU 通过 NVLink 连接（数百 GB/s），请在单个节点内使用张量并行。张量并行会将每一层拆分到各个 GPU 上，并且需要高带宽。
- 如果您的 GPU 带宽较低并通过 PCIe 工作（约 64 GB/s），请使用流水线并行。流水线并行会按顺序将层拆分到各个 GPU 上。

如果您已达到张量并行的最大限制，但需要更多的模型分布，可以结合使用这两种并行策略。例如，在节点内使用张量并行，并在跨节点使用流水线并行。

<a id="plan-vram-requirements"></a>

## 规划 VRAM 需求

您所需的 VRAM 取决于上下文长度和预期的并发量。

vLLM 为以下目的分配 VRAM：

| 类别 | 大小 | 备注 |
| --- | --- | --- |
| 模型权重 | 约 61 GB | 固定 |
| 框架开销 | 约 2 GB | 固定 |
| KV 缓存 | 剩余部分 | 随并发量和上下文长度扩展 |

KV 缓存是为每个请求中已处理的 Token 存储的预计算向量的集合。每个 Token 仅计算一次，所有变量都驻留于此。

<a id="example-single-h100-80-gb"></a>

### 示例：单个 H100 80 GB

使用 `--gpu-memory-utilization 0.95`，您将获得 76 GB 的可用 VRAM：

```plaintext
76 GB 可用
├── 61 GB  模型权重          ← 固定
├──  2 GB  框架开销         ← 固定
└── 13 GB  KV 缓存           ← 随着请求的到来而填充
```

按每个缓存 Token 约 36 KB 计算，13 GB 可在完整注意力层上容纳约 370K Token 的上下文。如果每个 Agentic 请求约使用 32K Token，您大约可以运行 _10 个并发请求_。

当您启动 vLLM 时，日志会确认确切的数字：

```plaintext
可用 KV 缓存内存：N GiB
GPU KV 缓存大小：Y tokens
每个请求 Y tokens 的最大并发数：Nx
```

<a id="install"></a>

## 安装

选择与您环境匹配的选项：

下列出的版本号是运行 GPT OSS 120B 所需的最低版本。建议使用最新的 vLLM 版本，因为它包含了性能改进、错误修复和更广泛的硬件支持。

- 安装脚本：一台尚未安装 CUDA 或 GPU 驱动程序的全新 Ubuntu 或 Debian 机器。
- 仅 vLLM：CUDA 和驱动程序已存在（例如 GCP 上的 NVIDIA 深度学习虚拟机、AWS 深度学习 AMI 或现有的 GPU 机器）。
- Docker：完全跳过所有主机级别的设置。

如果您有不同的硬件，请参阅 [GPT OSS - vLLM Recipes](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html#installation-vllm) 获取其他配置。

<a id="option-1-installation-script-from-scratch"></a>

### 选项 1：安装脚本（从零开始）

更新技术栈时，请为每个变量使用以下版本：

| 变量 | 版本 |
|---|---|
| CUDA toolkit | 12.9 |
| 最低驱动 | 575.x |
| Python | 3.12 |
| vLLM | 0.18.0 |

```shell
#!/bin/bash
# vLLM + CUDA 安装，用于 gpt-oss-120b
# 目标：Ubuntu 22.04 / Debian 12, x86_64

CUDA_VERSION="12-9"           # apt 包后缀  →  cuda-toolkit-12-9
MIN_DRIVER_VERSION="575"      # CUDA 12.9 的最低驱动版本
PYTHON_VERSION="3.12"
VLLM_VERSION="0.18.0"
VENV_DIR="${HOME}/vllm-env"

set -e

# ===========================================================================
# 第 1 部分 — 系统前置条件
# ===========================================================================
echo "--- 第 1 部分：系统前置条件 ---"

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y \
    build-essential \
    dkms \
    linux-headers-$(uname -r) \
    wget curl gnupg2 \
    software-properties-common \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python${PYTHON_VERSION}-dev \
    python3-pip git

# 安装 uv — vLLM 文档推荐；它为额外索引 URL 提供比 PyPI 更高的优先级，
# 这是 gpt-oss fork 正确解析所必需的。
curl --location --silent --show-error --fail "https://astral.sh/uv/install.sh" | sh
source "${HOME}/.local/bin/env"

# ===========================================================================
# 第 2 部分 — NVIDIA 驱动和 CUDA toolkit
# 此部分完成后需要重启，才能继续第 3 部分。
# ===========================================================================
echo "--- 第 2 部分：NVIDIA 驱动和 CUDA ${CUDA_VERSION//-/.} ---"

# 添加 NVIDIA 的软件包仓库。
# 对于 Debian 12，请将 URL 中的 ubuntu2204 替换为 debian12。
# 当前的密钥环 URL：https://developer.nvidia.com/cuda-downloads
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# cuda-drivers（无版本后缀）是一个元包 — apt 会自动解析
# 与固定 toolkit 版本兼容的最新驱动程序。
sudo apt-get install -y \
    cuda-drivers \
    cuda-toolkit-${CUDA_VERSION} \
    nvidia-gds-${CUDA_VERSION}

echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# 在作业之间保持 GPU 初始化（减少冷启动延迟）
sudo systemctl enable nvidia-persistenced

echo "正在重启以加载 NVIDIA 内核模块..."
echo "重启后，请运行：bash install.sh --post-reboot"

if [[ "${1:-}" != "--post-reboot" ]]; then
    sudo reboot
fi

# ===========================================================================
# 第 3 部分 — Python 环境和 vLLM
# 重启后从这里开始，或者如果您使用的是云托管镜像。
# ===========================================================================
echo "--- 第 3 部分：验证驱动程序 ---"

nvidia-smi       # 确认驱动 >= ${MIN_DRIVER_VERSION} 且 GPU 可见
nvcc --version   # 确认 CUDA ${CUDA_VERSION//-/.}

echo "--- 第 3 部分：Python 环境 ---"

uv venv "$VENV_DIR" --python ${PYTHON_VERSION} --seed
source "$VENV_DIR/bin/activate"

python --version   # 应显示 Python 3.12.x

echo "--- 第 3 部分：PyTorch ---"

# --torch-backend=auto 会在运行时检查您安装的 CUDA 驱动，并
# 自动选择匹配的 PyTorch 索引。这取代了硬编码的
# --index-url 标志，并在 CUDA 版本更新时保持正确。
uv pip install torch torchvision torchaudio --torch-backend=auto

echo "--- 第 3 部分：vLLM ---"

uv pip install "vllm==${VLLM_VERSION}" --torch-backend=auto


echo ""
echo "安装完成。"
echo "激活环境：source ${VENV_DIR}/bin/activate"
echo "验证 vLLM 版本：python -c \"import vllm; print(vllm.__version__)\""
```

<a id="option-2-vllm-only"></a>

### 选项 2：仅 vLLM

当 CUDA 和驱动程序已安装时（云托管镜像和现有 GPU 机器），使用以下命令安装 vLLM。

```shell
uv venv
source .venv/bin/activate
uv pip install vllm --torch-backend=auto
```

<a id="option-3-docker"></a>

### 选项 3：Docker

使用以下命令安装 GPT OSS 120B Docker 镜像。`vllm/vllm-openai:v0.18.0` 镜像包含 CUDA、驱动程序和 vLLM。

```shell
docker run \
  --gpus all \
  -p 8000:8000 \
  --ipc=host \
  vllm/vllm-openai:v0.18.0 \
  --model openai/gpt-oss-120b
```

<a id="vllm-configuration"></a>

## vLLM 配置

您的 vLLM 配置中的值取决于您的流量模式。从下面的预设方案开始，然后调整这些控制变量。

| 标志 | 默认值 | 描述 |
|---|---|---|
| `--gpu-memory-utilization` | `0.90` | vLLM 声明的 GPU 内存占比。增加到 `0.95` 以扩展 KV 缓存并提高吞吐量。如果在负载下遇到 OOM 错误，请降低此值。 |
| `--max-model-len` | 模型最大值（GPT OSS 120B 为 128K） | 限制每个请求的最大上下文长度。降低此值可增加并发容量。 |
| `--max-num-seqs` | `256` | 单个批次中的最大请求数。值越高，GPU 利用率和吞吐量越高，但会牺牲每个请求的延迟。实际并发量仍受可用 KV 缓存的限制。 |
| `--max-num-batched-tokens` | 无 | 每次迭代处理的 Token 总数。与 `--max-num-seqs` 一起使用；vLLM 会以先达到限制的那个为准进行批处理。 |
| `--tensor-parallel-size` | 无 | 在 N 个 GPU 上水平拆分模型层。需要高带宽；在通过 NVLink 连接的单个节点内使用。 |
| `--pipeline-parallel-size` | 无 | 在 N 个 GPU 上按顺序拆分模型层。可容忍较低带宽；适用于通过 PCIe 跨节点连接。 |

<a id="prescriptive-setups"></a>

## 预设方案

下表列出了每种硬件的预设方案。选择与您的硬件和预期流量模式匹配的行，然后使用相应的配置。

“约并发请求数” 列显示的是在所列上下文长度下，受 KV 缓存限制的约并发数，而不是 `--max-num-seqs` 值。

| 硬件 | 最大上下文 | 约并发请求数 | 最适合的场景 |
| ------------- | ----------- | -------------------- | ------------------------------------ |
| 单个 H100 80 GB | 32K | 10 | 开发/测试、低流量服务 |
| 2× H100 80 GB | 64K | 34 | 中等生产负载 |
| 4× H100 80 GB | 128K | 51 | 完整上下文窗口、高吞吐量 |
| 2× A100 40 GB | 32K | 3 | 最小可行 A100 设置 |
| 4× A100 40 GB | 32K | 69 | 更高的 A100 吞吐量 |
| 2× L40S / RTX A6000 Ada 48 GB | 32K | 19 | 经济实惠的 Ada Lovelace 选项 |

<a id="single-h100-80-gb"></a>

### 单个 H100 80 GB

在此设置中，提高 `--gpu-memory-utilization`（0.95 对比默认的 0.90）是为了规避[单个 H100 上已知的 CUDA OOM 问题](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html#known-limitations)。

```shell
vllm serve openai/gpt-oss-120b \
  --gpu-memory-utilization 0.95 \
  --max-model-len 32768 \
  --max-num-seqs 16 \
  --max-num-batched-tokens 4096
```

<a id="2-h100-80-gb"></a>

### 2× H100 80 GB

在此设置中，更大的合并 KV 缓存池支持更高的上下文窗口和更多的并发请求。

```shell
vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 2 \
  --max-model-len 65536 \
  --max-num-seqs 32 \
  --max-num-batched-tokens 8192
```

<a id="4-h100-80-gb"></a>

### 4× H100 80 GB

此设置提供完整的 128K 上下文窗口。

```shell
vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 4 \
  --gpu-memory-utilization 0.95 \
  --max-model-len 131072 \
  --max-num-seqs 64 \
  --max-num-batched-tokens 16384
```

<a id="2-a100-40-gb"></a>

### 2× A100 40 GB

在此设置中，单个 A100 40 GB 无法容纳 61 GB 的模型权重。两个 GPU 是最低要求。

```shell
vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 2 \
  --max-model-len 32768 \
  --max-num-seqs 24 \
  --max-num-batched-tokens 4096
```

<a id="4-a100-40-gb"></a>

### 4× A100 40 GB

```shell
vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 4 \
  --max-model-len 32768 \
  --max-num-seqs 128 \
  --max-num-batched-tokens 16384
```

<a id="2-l40s-48gb-or-rtx-a6000-ada-48-gb"></a>

### 2× L40S 48GB 或 RTX A6000 Ada 48 GB

两种设置都使用 Ada Lovelace 架构与 48 GB 显存。

```shell
vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 2 \
  --max-model-len 32768 \
  --max-num-seqs 16 \
  --max-num-batched-tokens 4096
```

有关额外的 NVIDIA Blackwell 和 Hopper 优化，请参阅 [GPT OSS - vLLM Recipes: Recipe for NVIDIA Blackwell & Hopper Hardware](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html#recipe-for-nvidia-blackwell-hopper-hardware)。

<a id="verify-the-server"></a>

## 验证服务器

启动 vLLM 后，使用以下请求确认其服务正常：

```shell
curl "http://localhost:8000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }'
```

您应该会看到一个带有模型补全内容的 JSON 响应。如果服务器尚未就绪，您会收到连接被拒绝的错误。vLLM 首次启动时需要时间加载模型权重，这可能需要几分钟，具体取决于您的存储速度。

<a id="monitoring"></a>

## 监控

vLLM 暴露了一个与 Prometheus 兼容的 `/metrics` 端点。有关完整列表，请参阅 [Production Metrics - vLLM](https://docs.vllm.ai/en/stable/usage/metrics/)。

要监控 vLLM，请查看面向用户延迟和容量压力的指标。

| 指标 | 描述 |
|---|---|
| **面向用户的延迟** | |
| `time_to_first_token` | 用户感受到的响应速度。 |
| `time_per_output_token_seconds` | 流式输出的流畅程度。 |
| **容量压力** | |
| `kv_cache_usage_perc` | KV 池正在使用的比例。主要的内存压力信号。持续高于 0.85 的值表明您正在接近容量上限。 |
| `num_requests_waiting` | 因 KV 缓存已满而排队的请求。持续增长的队列意味着您已超出容量。请扩容 GPU、减小 `--max-model-len` 或降低 `--max-num-seqs`。 |
| `num_requests_running` | 您的实际并发数。 |

<a id="troubleshooting"></a>

## 故障排除

<a id="clients-are-timing-out-or-numrequestswaiting-keeps-growing"></a>

### 客户端超时或 `num_requests_waiting` 持续增长

传入的请求超出了 KV 缓存的容量。vLLM 会将新请求加入队列，直到缓存空间被释放，而队列永远不会排空。

要解决此问题：

1. 检查 `kv_cache_usage_perc`。持续高于 0.85 的值确认您受内存限制。
1. 减小 `--max-model-len` 以降低每个请求的 KV 分配，这可为更多并发请求腾出空间。
1. 减小 `--max-num-seqs` 以限制同时竞争缓存的请求数量。
1. 如果您已用尽单节点调优，请水平扩展：增加 GPU 或节点，并在多个 vLLM 实例之间进行负载均衡。

<a id="server-crashes-with-cuda-oom-errors"></a>

### 服务器崩溃并出现 CUDA OOM 错误

服务器在高负载下耗尽 GPU 内存。

要解决此问题，请按以下顺序进行调整：

1. 减小 `--max-num-seqs` 以限制并发批处理大小。
1. 减小 `--max-model-len` 以缩减每个请求的 KV 分配。
1. 如果在启动时出现 OOM，请降低 `--gpu-memory-utilization`。

<a id="token-generation-is-slower-than-expected"></a>

### Token 生成速度比预期慢

`time_per_output_token_seconds` 很高，而整体的 Tokens/s 很低。GPU 每次迭代处理的工作量不足。

要解决此问题：

1. 增加 `--max-num-batched-tokens` 以让 vLLM 每次迭代处理更多 Token。
1. 增加 `--max-num-seqs` 以便更多请求一起批处理，这可以提高 GPU 利用率。