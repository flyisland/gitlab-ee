---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在离线环境中部署自托管极狐GitLab Duo Agent Platform
description: 将容器镜像和 LLM 模型权重传输至内部基础设施，以便在无互联网连接的情况下运行自托管极狐GitLab Duo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.9 中，自部署模型支持已 GA。
- 在极狐GitLab 18.9 中，离线流执行支持已引入。

{{< /history >}}

> [!note]  
> 要设置离线环境，必须在购买前获得  
> [云许可的离线豁免](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#offline-cloud-licensing)。  
> 详情请联系你的极狐GitLab 销售代表。

你可以在离线环境中部署自托管的极狐GitLab Duo Agent Platform，  
此时你的极狐GitLab 实例和 runner 均无法访问公网。  
这些说明同样适用于网络受限或防火墙策略严格的环境。

在离线环境中，你必须手动将 AI Gateway 容器镜像、LLM 模型权重、vLLM 推理服务器镜像  
以及 Agent Platform Flows 执行器镜像传输至你的内部基础设施。

要在离线环境中部署 Agent Platform，请完成以下步骤：

1. 将容器镜像传输至内部镜像仓库
1. 将 LLM 模型权重传输至离线文件系统
1. 启动 AI Gateway
1. 启动 vLLM
1. 在极狐GitLab 管理员界面配置 AI Gateway
1. 添加自部署模型
1. 配置离线流执行
1. 验证部署

<a id="prerequisites"></a>

## 先决条件  

- 极狐GitLab 18.9 或更高版本，并持有[离线云许可](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#offline-cloud-licensing)。  
- 一台能够连接互联网的机器，用于下载所需组件。  
- 在联网机器和离线主机上均已安装 [skopeo](https://github.com/containers/skopeo) 和  
  [jq](https://jqlang.github.io/jq/)（在 Red Hat 系统上执行 `dnf install --assumeyes skopeo jq`）。  
- 一种将文件传输到离线环境的方法（例如物理介质、跨网闸系统或跳板机）。  
- 离线环境中的容器镜像仓库。例如，  
  [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)、  
  Harbor 或 Nexus。  
- 对于 vLLM：在推理主机上已安装 NVIDIA GPU 驱动、CUDA 库以及  
  [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)。  
  有关离线安装选项，请参阅  
  [NVIDIA CUDA 安装指南](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)。

> [!note]  
> 本页所有命令均可用于 Docker 和 Podman。  
> 请根据实际情况将 `docker` 替换为 `podman`。

<a id="required-artifacts"></a>

## 所需组件  

除 LLM 模型权重外，所有组件均为 OCI 容器镜像。

<a id="container-images"></a>

### 容器镜像  

| 组件 | 源镜像仓库 | 标签格式 | 大约大小 |
|----------|----------------|------------|-----------------|
| AI Gateway | `registry.gitlab.cn/model-gateway/model-gateway-self-hosted` | `self-hosted-vX.Y.Z-jh` | 340 MB |
| Agent Platform Flows 执行器 | `registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image` | `vX.Y.Z` | 2-3 GB |
| vLLM 推理服务器 | `docker.io/vllm/vllm-openai` | `vX.Y.Z`（v0.18.1 或更高） | 2-4 GB |

AI Gateway 标签使用你的极狐GitLab 版本号：  
`self-hosted-v<你的极狐gitlab版本>-jh`。

要查看当前执行器镜像的版本，请运行以下命令：

```shell
skopeo list-tags \
  docker://registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image \
  | jq --raw-output '.Tags[]' | grep --extended-regexp '^v[0-9]' | sort --version-sort | tail --lines=1
```

极狐GitLab Duo Agentic Chat、代码建议、极狐GitLab Duo Code Review 以及 Agent Platform 流不需要 ClickHouse。  
如果你需要关于极狐GitLab Duo 使用情况的分析数据，则必须同时传输并配置  
[ClickHouse](../../integration/clickhouse.md)（`docker.io/clickhouse/clickhouse-server`）。

对于 FIPS 验证环境，请使用 AI Gateway 的 FIPS 镜像，  
而非标准镜像。  
FIPS 镜像使用相同的 `self-hosted-vX.Y.Z-ee` 标签格式。  
从极狐GitLab 18.10 起提供带有 FIPS 的版本标签。  
更多信息请参见  
[FIPS 验证镜像](../../install/install_ai_gateway.md#fips-validated-images)。

<a id="llm-model-weights"></a>

### LLM 模型权重  

LLM 模型权重是 vLLM 直接从文件系统读取的大型文件。  
这些文件不以容器镜像的形式分发。

本页示例使用 Mistral Small 24B（约 48 GB）。  
它同时支持代码建议和极狐GitLab Duo Chat。  
有关其他模型选项和 GPU 要求的信息，请参见  
[支持的模型与硬件要求](supported_models_and_hardware_requirements.md)。

<a id="transfer-container-images"></a>

## 传输容器镜像  

在联网机器上，先将所需镜像保存为归档文件，  
然后在离线侧将其加载到内部镜像仓库中。

<a id="save-images-on-the-connected-machine"></a>

### 在联网机器上保存镜像  

在已连接互联网的机器上，使用 `skopeo` 运行以下命令：

```shell
GITLAB_VERSION="18.10.0"
EXECUTOR_VERSION="v0.0.6"
VLLM_VERSION="v0.18.1"

skopeo copy \
  docker://registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-v${GITLAB_VERSION}-jh \
  docker-archive:aigw.tar

skopeo copy \
  docker://registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:${EXECUTOR_VERSION} \
  docker-archive:executor.tar

skopeo copy \
  docker://docker.io/vllm/vllm-openai:${VLLM_VERSION} \
  docker-archive:vllm.tar
```

如果联网机器使用了代理，请先设置 `HTTPS_PROXY` 再运行 `skopeo`：

```shell
export HTTPS_PROXY="http://proxy.example.com:8080"
```

如果无法使用 skopeo，也可使用 `docker save`：

```shell
GITLAB_VERSION="18.10.0"

docker pull registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-v${GITLAB_VERSION}-jh
docker save \
  registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-v${GITLAB_VERSION}-jh \
  --output aigw.tar
```

<a id="load-images-into-the-internal-registry"></a>

### 将镜像加载到内部镜像仓库  

将归档文件传输到离线环境后，再将其加载到内部镜像仓库。

> [!note]  
> Shell 变量不会跨机器保留。  
> 请在离线主机上重新设置 `INTERNAL_REGISTRY`、`GITLAB_VERSION`、  
> `EXECUTOR_VERSION` 和 `VLLM_VERSION`。

如果内部镜像仓库使用自签名证书，请配置 skopeo 以信任该证书：

```shell
mkdir --parents /etc/containers/certs.d/<registry-host>
cp ca.crt /etc/containers/certs.d/<registry-host>/ca.crt
```

然后加载镜像：

```shell
INTERNAL_REGISTRY="registry.internal.example.com/duo"
GITLAB_VERSION="18.10.0"
EXECUTOR_VERSION="v0.0.6"
VLLM_VERSION="v0.18.1"

skopeo copy \
  docker-archive:aigw.tar \
  docker://${INTERNAL_REGISTRY}/ai-gateway:self-hosted-v${GITLAB_VERSION}-ee

skopeo copy \
  docker-archive:executor.tar \
  docker://${INTERNAL_REGISTRY}/workflow-generic-image:${EXECUTOR_VERSION}

skopeo copy \
  docker-archive:vllm.tar \
  docker://${INTERNAL_REGISTRY}/vllm-openai:${VLLM_VERSION}
```

<a id="transfer-llm-model-weights"></a>

## 传输 LLM 模型权重  

在联网机器上，可使用 Hugging Face CLI 或 `git lfs` 下载模型权重。

使用 Hugging Face CLI：

```shell
pip install huggingface_hub
huggingface-cli download mistralai/Mistral-Small-3.2-24B-Instruct-2506 \
  --local-dir ./mistral-small-3.2-24b
```

如果你的 `huggingface_hub` 版本中没有 `huggingface-cli`，  
可使用 `hf download` 及相同参数。

使用 `git lfs`（无需 Python）：

```shell
dnf install --assumeyes git-lfs  # 对于 Debian/Ubuntu：apt-get install git-lfs
git lfs install
git clone https://huggingface.co/mistralai/Mistral-Small-3.2-24B-Instruct-2506
```

将下载的目录传输到离线环境，  
并放置在 vLLM 容器可访问的文件系统路径下  
（例如 `/data/models/mistral-small-3.2-24b`）。

<a id="start-the-ai-gateway"></a>

## 启动 AI Gateway  

要使用内部镜像仓库的镜像运行 AI Gateway 容器：

1. 生成必需的 JWT 签名密钥：

   ```shell
   openssl genrsa -out aigw_signing.key 2048
   openssl genrsa -out aigw_validation.key 2048
   openssl genrsa -out duo_workflow_jwt.key 2048
   openssl genrsa -out duo_workflow_validation.key 2048
   ```

1. 使用内部镜像仓库的镜像运行 AI Gateway 容器：

   ```shell
   INTERNAL_REGISTRY="registry.internal.example.com/duo"
   GITLAB_VERSION="18.10.0"
   GITLAB_DOMAIN="gitlab.internal.example.com"

   docker run --detach \
     --publish 5052:5052 \
     --publish 50052:50052 \
     --env AIGW_GITLAB_URL=https://${GITLAB_DOMAIN} \
     --env AIGW_GITLAB_API_URL=https://${GITLAB_DOMAIN}/api/v4/ \
     --env AIGW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat aigw_signing.key)" \
     --env AIGW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat aigw_validation.key)" \
     --env DUO_WORKFLOW_AUTH__ENABLED="true" \
     --env DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat duo_workflow_jwt.key)" \
     --env DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat duo_workflow_validation.key)" \
     --env DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL= \
     ${INTERNAL_REGISTRY}/ai-gateway:self-hosted-v${GITLAB_VERSION}-ee
   ```

将 `DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL=` 设置为空字符串，  
可以防止 AI Gateway 尝试访问 CustomersDot 服务（该服务在离线环境中不可用）。  
如果不设置此项，每个请求都会产生 20 秒的延迟。

有关 TLS 终止和其他配置选项，请参见  
[安装极狐GitLab AI Gateway](../../install/install_ai_gateway.md)。

<a id="start-vllm"></a>

## 启动 vLLM  

运行 vLLM 以提供你已传输的模型权重：

```shell
INTERNAL_REGISTRY="registry.internal.example.com/duo"
VLLM_VERSION="v0.18.1"

docker run --detach \
  --gpus all \
  --volume /data/models/mistral-small-3.2-24b:/model \
  --publish 8000:8000 \
  ${INTERNAL_REGISTRY}/vllm-openai:${VLLM_VERSION} \
  --model /model \
  --served_model_name custom_openai/mistral-small-3.2-24b \
  --tensor-parallel-size <number-of-gpus>
```

将 `<number-of-gpus>` 替换为可用的 GPU 数量。  
单 GPU 则使用 `--tensor-parallel-size 1`。  
若使用 Podman，请将 `--gpus all` 替换为  
`--device nvidia.com/gpu=all --security-opt label=disable`。  
在启用 SELinux 的系统上，必须使用 `--security-opt label=disable` 标志才能访问 GPU 设备。

启动后，验证模型是否已加载：

```shell
curl --silent "http://localhost:8000/v1/models"
```

- 有关 vLLM 配置的更多信息，请参见  
  [支持的 LLM 推理平台](supported_llm_serving_platforms.md)。  
- 有关如何部署 vLLM 的信息，请参见  
  [vLLM 模型部署示例](vllm_gpt_oss_120b.md)。

<a id="configure-the-ai-gateway-in-gitlab"></a>

## 在极狐GitLab 中配置 AI Gateway  

AI Gateway 和 vLLM 启动后，配置极狐GitLab 以使用它们：

1. 在右上角选择 **管理员**。
1. 在左侧边栏中选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **本地 AI Gateway URL** 中输入 `http://<ai-gateway-host>:5052`。
1. 在 **极狐GitLab Duo Agent Platform 服务的本地 URL** 中，  
   输入 `<ai-gateway-host>:50052`。
1. 打开 **极狐GitLab Duo Agent Platform**。  
   开启后，**流执行** 部分会展开。
1. 在 **镜像仓库** 中输入你的内部镜像仓库 URL  
   （例如 `registry.internal.example.com/duo`）。
1. 选择 **保存更改**。

<a id="add-the-self-hosted-model"></a>

## 添加自部署模型  

将自部署模型部署添加到你的极狐GitLab 实例中：

1. 在右上角选择 **管理员**。
1. 在左侧边栏中选择 **极狐GitLab Duo**。
1. 选择 **为极狐GitLab Duo 配置模型**。
1. 选择 **添加自部署模型**。
1. 填写字段：
   - 在 **端点** 中输入你的 vLLM 服务器 URL。
   - 在 **模型标识符** 中输入  
     `custom_openai/mistral-small-3.2-24b`。
1. 可选。选择 **测试连接** 以验证 AI Gateway  
   能否连接到 vLLM 端点。
1. 选择 **添加自部署模型**。

<a id="configure-offline-flow-execution"></a>

## 配置离线流执行  

对于离线流执行，需要使用预装 `duo-cli` 的自定义执行器镜像。

1. 在联网机器上构建自定义镜像：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:v0.0.6
   RUN npm install --global @gitlab/duo-cli@8.86.0
   ```

   要查找当前的 `duo-cli` 版本，可查看极狐GitLab Rails 源代码中的 `DUO_CLI_VERSION` 常量，  
   或访问 [极狐GitLab Duo CLI npm 页面](https://www.npmjs.com/package/@gitlab/duo-cli)。

1. 使用上述 `skopeo copy` 相同的流程将镜像传输到内部镜像仓库，  
   然后在你的项目 `agent-config.yml` 中引用它：

   ```yaml
   image: registry.internal.example.com/duo/duo-executor:v0.0.6
   ```

<a id="verify-the-deployment"></a>

## 验证部署  

1. 确认 AI Gateway 正在运行：

   ```shell
   curl --silent "http://<ai-gateway-host>:5052/monitoring/healthz"
   ```

1. 运行极狐GitLab Duo 健康检查：
   1. 在右上角选择 **管理员**。
   1. 在左侧边栏中选择 **极狐GitLab Duo**。
   1. 选择 **运行健康检查**。

   健康检查会验证 AI Gateway 的连通性和许可状态，  
   但不会测试模型推理。

1. 要验证模型推理，可在极狐GitLab UI 或 IDE 中通过  
   极狐GitLab Duo Chat 或代码建议发送测试请求。

1. 要验证 Agent Platform 流，请触发一个流，  
   并确认执行器镜像是从你的内部镜像仓库拉取的，  
   且 `duo-cli` 不是从 npm 下载的。

有关常见问题，请参见  
[故障排查](troubleshooting.md)。

<a id="update-artifacts"></a>

## 更新组件  

升级极狐GitLab 实例时，请使用相同流程传输更新后的容器镜像。  
确保使用与新极狐GitLab 版本匹配的 AI Gateway 镜像标签。

升级极狐GitLab 时无需更新模型权重。  
仅当你更换到其他模型时才需要更新。

<a id="related-topics"></a>

## 相关主题  

- [离线极狐GitLab](../../topics/offline/_index.md)
- [自部署模型](_index.md)