---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 vLLM 部署模型的示例，采用 GPT OSS 120B，涵盖从 GPU 选择到生产环境监控的全过程。
title: 使用 vLLM 的示例模型部署
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

GPT OSS 120B 作为使用 vLLM 部署的示例模型，涵盖从 GPU 选择到生产环境监控的全过程。

<a id="gpu-selection"></a>

## GPU 选择

GPT OSS 120B 在 NVIDIA H100 上训练，在 H100 或更新的数据中心 GPU 上运行效果最佳。其混合专家（MoE）架构对每个 token 仅激活网络的一部分，因此该模型可容纳在单块 H100 80 GB GPU 上。

<a id="determine-a-parallelism-strategy"></a>

### 确定并行策略

GPU 的连接方式决定了以下并行策略：

- 如果 GPU 通过 NVLink 连接（数百 GB/s），请在单个节点内使用张量并行。张量并行将每一层拆分到多个 GPU 上，需要高带宽。
- 如果 GPU 带宽较低并通过 PCIe 工作（约 64 GB/s），请使用流水线并行。流水线并行按顺序将各层拆分到多个 GPU 上。

如果您已达到张量并行的上限，但需要进一步分布模型，可以组合使用两种并行策略。例如，在节点内使用张量并行，跨节点使用流水线并行。

<a id="plan-vram-requirements"></a>

## 规划 VRAM 需求

所需的 VRAM 取决于上下文长度和预期并发量。

vLLM 为以下用途分配 VRAM：

| 类别 | 大小 | 说明 |
| --- | --- | --- |
| 模型权重 | 约 61 GB | 固定 |
| 框架开销 | 约 2 GB | 固定 |
| KV 缓存 | 剩余部分 | 随并发量和上下文长度扩展 |

KV 缓存是存储每个请求中已处理 token 的预计算向量的存储区。每个 token 只计算一次，所有可变性都集中在这里。

<a id="example-single-h100-80-gb"></a>

### 示例：单块 H100 80 GB

使用`--gpu-memory-utilization 0.95` 时，您可获得 76 GB 可用 VRAM：

```plaintext
76 GB usable
├── 61 GB  model weights          ← fixed
├──  2 GB  framework overhead     ← fixed
└──  13 GB  KV cache               ← fills as requests arrive
```

按每个缓存 token 约 36 KB 计算，13 GB 可在全注意力层中容纳约 370K token 的上下文。如果每个 Agent 请求使用约 32K token，则可运行约 *10 个并发请求*。

启动 vLLM 时，日志会确认具体数值：

```plaintext
Available KV cache memory: N GiB
GPU KV cache size: Y tokens
Maximum concurrency for Y tokens per request: Nx
```

<a id="install"></a>

## 安装

请选择与您的环境匹配的选项：

- 安装脚本：全新安装的 Ubuntu 或 Debian 机器，未安装 CUDA 或 GPU 驱动。
- 仅 vLLM：已安装 CUDA 和驱动（GCP 上的 NVIDIA Deep Learning VM、AWS Deep Learning AMI 或现有 GPU 机器）。
- Docker：完全跳过所有主机层面的设置。

如果您的硬件不同，请参阅 GPT OSS - vLLM Recipes 了解其他配置。

<a id="option-1-installation-script-from-scratch"></a>

### 选项 1：安装脚本（从零开始）

更新技术栈时，请为每个变量使用以下版本。这些版本是运行 GPT OSS 120B 所需的最低版本。您应使用最新的 vLLM 版本，因为它包含性能改进、缺陷修复和扩展的硬件支持。

| 变量 | 版本 |
|---|---|
| CUDA toolkit | 12.9 |
| 最低驱动 | 575.x |
| Python | 3.12 |
| vLLM | 0.18.0 |

```shell
#!/bin/bash
# vLLM + CUDA installation for gpt-oss-120b
# Target: Ubuntu 22.04 / Debian 12, x86_64

CUDA_VERSION="12-9"           # apt package suffix  →  cuda-toolkit-12-9
MIN_DRIVER_VERSION="575"      # minimum driver for CUDA 12.9
PYTHON_VERSION="3.12"
VLLM_VERSION="0.18.0"
VENV_DIR="${HOME}/vllm-env"

set -e

# ===========================================================================
# PART 1 — system prerequisites
# ===========================================================================
echo "--- Part 1: System prerequisites ---"

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

# Install uv — recommended by vLLM docs; gives extra index URLs higher
# priority than PyPI, which is required for the gpt-oss fork to resolve correctly.
curl --location --silent --show-error --fail "https://astral.sh/uv/install.sh" | sh
source "${HOME}/.local/bin/env"

# ===========================================================================
# PART 2 — NVIDIA drivers and CUDA toolkit
# Reboot required after this section before continuing to Part 3.
# ===========================================================================
echo "--- Part 2: NVIDIA drivers and CUDA ${CUDA_VERSION//-/.} ---"

# Add NVIDIA's package repository.
# For Debian 12, replace ubuntu2204 with debian12 in the URL.
# Current keyring URL: https://developer.nvidia.com/cuda-downloads
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# cuda-drivers (no version suffix) is a meta-package — apt resolves
# the latest driver compatible with the pinned toolkit automatically.
sudo apt-get install -y \
    cuda-drivers \
    cuda-toolkit-${CUDA_VERSION} \
    nvidia-gds-${CUDA_VERSION}

echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# Keep GPU initialized between jobs (reduces cold-start latency)
sudo systemctl enable nvidia-persistenced

echo "Rebooting to load NVIDIA kernel modules..."
echo "After reboot, run:  bash install.sh --post-reboot"

if [[ "${1:-}" != "--post-reboot" ]]; then
    sudo reboot
fi

# ===========================================================================
# PART 3 — Python environment and vLLM
# Start here after reboot, or if using a cloud managed image.
# ===========================================================================
echo "--- Part 3: Verify drivers ---"

nvidia-smi       # confirm driver >= ${MIN_DRIVER_VERSION} and GPUs visible
nvcc --version   # confirm CUDA ${CUDA_VERSION//-/.}

echo "--- Part 3: Python environment ---"

uv venv "$VENV_DIR" --python ${PYTHON_VERSION} --seed
source "$VENV_DIR/bin/activate"

python --version   # should show Python 3.12.x

echo "--- Part 3: PyTorch ---"

# --torch-backend=auto inspects your installed CUDA driver at runtime and
# selects the matching PyTorch index automatically. This replaces hardcoded
# --index-url flags and stays correct across CUDA version updates.
uv pip install torch torchvision torchaudio --torch-backend=auto

echo "--- Part 3: vLLM ---"

uv pip install "vllm==${VLLM_VERSION}" --torch-backend=auto


echo ""
echo "Installation complete."
echo "Activate environment:  source ${VENV_DIR}/bin/activate"
echo "Verify vLLM version:   python -c \"import vllm; print(vllm.__version__)\""
```

<a id="option-2-vllm-only"></a>

### 选项 2：仅 vLLM

当 CUDA 和驱动已安装（云托管镜像和现有 GPU 机器）时，使用以下命令安装 vLLM。

```shell
uv venv
source .venv/bin/activate
uv pip install vllm --torch-backend=auto
```

<a id="option-3-docker"></a>

### 选项 3：Docker

使用以下命令安装 GPT OSS 120B Docker 镜像。`vllm/vllm-openai:v0.18.0` 镜像包含 CUDA、驱动和 vLLM。

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

vLLM 配置中的取值取决于您的流量模式。请从下面的预设方案开始，然后调整以下各项。

| 标志 | 默认值 | 描述 |
|---|---|---|
| `--gpu-memory-utilization` | `0.90` | vLLM 占用的 GPU 内存比例。增加到 `0.95` 可扩大 KV 缓存并提高吞吐量。如果在负载下遇到 OOM 错误，请降低该值。 |
| `--max-model-len` | 模型最大值（GPT OSS 120B 为 128K） | 限制每个请求的最大上下文长度。降低该值可提高并发容量。 |
| `--max-num-seqs` | `256` | 单个批次中的最大请求数。较高的值可提高 GPU 利用率和吞吐量，但会增加每个请求的延迟。实际并发量仍受可用 KV 缓存限制。 |
| `--max-num-batched-tokens` | 无 | 每次迭代处理的 token 总数。与`--max-num-seqs` 配合使用；vLLM 会按先达到的限制进行批处理。 |
| `--tensor-parallel-size` | 无 | 将各层横向拆分到 N 块 GPU 上。需要高带宽；请在通过 NVLink 连接的单个节点内使用。 |
| `--pipeline-parallel-size` | 无 | 按顺序将各层拆分到 N 块 GPU 上。可容忍较低带宽；适合通过 PCIe 跨节点使用。 |

<a id="prescriptive-setups"></a>

## 预设方案

下表列出了每种硬件的预设方案。请选择与您的硬件和预期流量模式匹配的行，然后使用相应的配置。

`Approximate concurrent requests` 列显示的是在所列上下文长度下受 KV 缓存限制的近似并发量，而非`--max-num-seqs`的值。

| 硬件      | 最大上下文 | 近似并发请求数 | 最适合                             |
| ------------- | ----------- | -------------------- | ------------------------------------ |
| 单块 H100 80 GB | 32K         | 10                   | 开发/测试、低流量服务     |
| 2× H100 80 GB | 64K         | 34                   | 中等生产负载               |
| 4× H100 80 GB | 128K        | 51                   | 完整上下文窗口、高吞吐量 |
| 2× A100 40 GB | 32K         | 3                    | 最低可行的 A100 配置            |
| 4× A100 40 GB | 32K         | 69                   | 更高的 A100 吞吐量               |
| 2× L40S / RTX A6000 Ada 48 GB | 32K | 19           | 经济实惠的 Ada Lovelace 选项  |

<a id="single-h100-80-gb"></a>

### 单块 H100 80 GB

在此设置中，提高`--gpu-memory-utilization`（0.95，而默认值为 0.90）可规避[单块 H100 上已知的 CUDA OOM 问题](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html#known-limitations)。

```shell
vllm serve openai/gpt-oss-120b \
  --gpu-memory-utilization 0.95 \
  --max-model-len 32768 \
  --max-num-seqs 16 \
  --max-num-batched-tokens 4096
```

<a id="2-h100-80-gb"></a>

### 2× H100 80 GB

在此设置中，更大的合并 KV 缓存池支持更高的上下文窗口和更多并发请求。

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

在此设置中，单块 A100 40 GB 无法容纳 61 GB 的模型权重。两块 GPU 是最低要求。

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

两种配置都采用 Ada Lovelace 架构，并各配备 48 GB 显存。

```shell
vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 2 \
  --max-model-len 32768 \
  --max-num-seqs 16 \
  --max-num-batched-tokens 4096
```

有关 NVIDIA Blackwell 和 Hopper 的其他优化，请参阅 GPT OSS - vLLM Recipes: Recipe for NVIDIA Blackwell & Hopper Hardware。

<a id="verify-the-server"></a>

## 验证服务器

启动 vLLM 后，使用以下请求确认其正常提供服务：

```shell
curl "http://localhost:8000/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 64
  }'
```

您应看到包含模型补全内容的 JSON 响应。如果服务器尚未就绪，您会收到连接被拒绝错误。vLLM 在首次启动时需要时间加载模型权重，具体耗时取决于您的存储速度，可能需要几分钟。

<a id="monitoring"></a>

## 监控

vLLM 暴露一个兼容 Prometheus 的`/metrics` 端点。完整列表请参阅 [Production Metrics - vLLM](https://docs.vllm.ai/en/stable/usage/metrics/)。

要监控 vLLM，请关注面向用户的延迟和容量压力指标。

| 指标 | 描述 |
|---|---|
| **面向用户的延迟** | |
| `time_to_first_token` | 用户感受到的响应速度。 |
| `time_per_output_token_seconds` | 流式输出的流畅程度。 |
| **容量压力** | |
| `kv_cache_usage_perc` | 正在使用的 KV 池比例。主要的内存压力信号。持续高于 0.85 表示您正接近容量上限。 |
| `num_requests_waiting` | 因 KV 缓存已满而排队的请求。队列持续增长意味着您已超出容量。请扩展 GPU、降低`--max-model-len` 或调低`--max-num-seqs`。 |
| `num_requests_running` | 您的实际并发量。 |

<a id="troubleshooting"></a>

## 故障排除

<a id="clients-are-timing-out-or-num_requests_waiting-keeps-growing"></a>

### 客户端超时或 `num_requests_waiting` 持续增长

传入请求超出 KV 缓存容量。vLLM 会将新请求排队，直到缓存空间释放，而队列始终无法排空。

要解决此问题：

1. 检查 `kv_cache_usage_perc`。持续高于 0.85 确认您受内存限制。
1. 降低`--max-model-len` 以减少每个请求的 KV 分配。这会释放槽位以支持更多并发请求。
1. 降低`--max-num-seqs` 以限制同时竞争缓存的请求数量。
1. 如果单节点调优已用尽，请横向扩展：添加 GPU 或节点，并在多个 vLLM 实例之间进行负载均衡。

<a id="server-crashes-with-cuda-oom-errors"></a>

### 服务器因 CUDA OOM 错误崩溃

服务器在重负载下耗尽 GPU 内存。

要解决此问题，请按以下顺序进行调整：

1. 降低`--max-num-seqs` 以限制并发批次大小。
1. 降低`--max-model-len` 以缩小每个请求的 KV 分配。
1. 如果 OOM 发生在启动时，请降低`--gpu-memory-utilization`。

<a id="token-generation-is-slower-than-expected"></a>

### Token 生成速度低于预期

`time_per_output_token_seconds` 偏高，整体 tokens/s 偏低。GPU 每次迭代处理的工作量不足。

要解决此问题：

1. 提高`--max-num-batched-tokens`，让 vLLM 每次迭代处理更多 token。
1. 提高`--max-num-seqs`，使更多请求一起批处理。这可提高 GPU 利用率。
