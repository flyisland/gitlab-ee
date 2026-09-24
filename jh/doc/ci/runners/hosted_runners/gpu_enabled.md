---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 支持 GPU 的托管 Runner
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

极狐GitLab 提供支持 GPU 的托管 Runner，以加速 ModelOps 或 HPC 的重计算工作负载，例如作为 ModelOps 工作负载的一部分进行大型语言模型（LLM）的训练或部署。

极狐GitLab 仅在 Linux 上提供支持 GPU 的 Runner。有关这些 Runner 如何工作的更多信息，请参见 [Linux 上的托管 Runner](linux.md)

<a id="machine-types-available-for-gpu-enabled-runners"></a>

## 支持 GPU 的 Runner 可用的机器类型

以下机器类型适用于 Linux x86-64 上支持 GPU 的 Runner。

| Runner 标签 | vCPU | 内存 | 存储 | GPU | GPU 内存 |
|----------------------------------------|-------|--------|---------|--------------------------------|------------|
| `saas-linux-medium-amd64-gpu-standard` | 4 | 15 GB | 50 GB | 1 NVIDIA Tesla T4 (or similar) | 16 GB |

<a id="container-images-with-gpu-drivers"></a>

## 包含 GPU 驱动程序的容器镜像

与 Linux 上的极狐GitLab 托管 Runner 一样，您的作业在具有自带镜像策略的隔离虚拟机（VM）中运行。极狐GitLab 将 GPU 从主机 VM 挂载到您的隔离环境中。要使用 GPU，您必须使用安装了 GPU 驱动程序的 Docker 镜像。对于 NVIDIA GPU，您可以使用其 [CUDA Toolkit](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda)。

<a id="example-.gitlab-ci.yml-file"></a>

## 示例 `.gitlab-ci.yml` 文件

在以下 `.gitlab-ci.yml` 文件示例中，使用了 NVIDIA CUDA 基础 Ubuntu 镜像。在 `script:` 部分，您安装 Python。

```yaml
gpu-job:
  stage: build
  tags:
    - saas-linux-medium-amd64-gpu-standard
  image: nvcr.io/nvidia/cuda:12.1.1-base-ubuntu22.04
  script:
    - apt-get update
    - apt-get install -y python3.10
    - python3.10 --version
```

如果您不想每次运行作业时都安装较大的库（如 Tensorflow 或 XGBoost），您可以创建自己的镜像，并预装所有必需的组件。