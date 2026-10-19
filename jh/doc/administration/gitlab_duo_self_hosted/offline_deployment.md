---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在离线环境中部署极狐GitLab Duo Agent Platform 自部署版本
description: 将容器镜像和 LLM 模型权重传输到您的内部基础设施，以便在无互联网访问的情况下运行极狐GitLab Duo 自部署版本
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 要设置离线环境，您必须在购买前获得
> [云许可的退出豁免](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#offline-cloud-licensing)。
> 如需了解更多详情，请联系您的极狐GitLab 销售代表。

您可以在离线环境中部署极狐GitLab Duo Agent Platform 自部署版本，
此时您的极狐GitLab 实例和 Runner 无法访问公共互联网。这些说明同样适用于连接受限或防火墙策略严格的环境。

在离线环境中，您必须手动将 AI 网关容器镜像、LLM 模型权重、vLLM 推理服务器镜像
以及 Agent Platform Flows 执行器镜像传输到您的内部
基础设施。

要在离线环境中部署 Agent Platform，请完成以下步骤：

1. 将容器镜像传输到内部镜像仓库
1. 将 LLM 模型权重传输到离线文件系统
1. 启动 AI 网关
1. 启动 vLLM
1. 在极狐GitLab 管理区域中配置 AI 网关
1. 添加自部署模型
1. 配置离线任务流执行
1. 验证部署

<a id="prerequisites"></a>

## 先决条件

- 极狐GitLab 18.9 或更高版本，并具有[离线云许可](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#offline-cloud-licensing)。
- 一台可连接互联网以下载产物的机器。
- 在联网机器和离线主机上安装 [skopeo](https://github.com/containers/skopeo) 和
  [jq](https://jqlang.org/)
  （在 Red Hat 系统上运行 `dnf install --assumeyes skopeo jq`）。
- 一种将文件传输到离线环境的方法
  （物理介质、跨域解决方案或堡垒主机）。
- 离线环境中的容器镜像仓库。例如，
  [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)、
  Harbor 或 Nexus。
- 对于 vLLM：在推理主机上安装 NVIDIA GPU 驱动、CUDA 库和
  [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)。
  有关离线安装选项，请参阅
  [NVIDIA CUDA 安装指南](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)。

> [!note]
> 本页面上的所有命令均适用于 Docker 和 Podman。
> 在适用的情况下，将 `docker` 替换为 `podman`。

<a id="required-artifacts"></a>

## 所需产物

除 LLM 模型权重外，所有产物均为 OCI 容器镜像。

您的极狐GitLab 实例自身运行的容器镜像需要单独传输。有关更多信息，请参阅[离线极狐GitLab](../../topics/offline/_index.md)。

<a id="container-images"></a>

### 容器镜像

| 产物 | 源镜像仓库 | 标签格式 | 大致压缩后大小 |
|----------|----------------|------------|-----------------|
| AI 网关 | `registry.gitlab.cn/model-gateway/model-gateway-self-hosted` | `self-hosted-vX.Y.Z-jh` | 0.6 GiB |
| Agent Platform Flows 执行器 | `registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image` | `vX.Y.Z` | 0.5 GiB |
| vLLM 推理服务器 | `docker.io/vllm/vllm-openai` | `vX.Y.Z`（v0.18.1 或更高版本） | 9 GiB |

这些大小是您传输时的压缩后大小。每个镜像在加载到镜像仓库或拉取到主机后都会更大。要在传输前检查大小，请运行 `skopeo inspect --raw docker://<image>:<tag>`，并将它报告的 `config` 和 `layers` 大小相加。

AI 网关标签使用您的极狐GitLab 版本号：
`self-hosted-v<your-gitlab-version>-jh`。

执行器标签必须与您的极狐GitLab 版本在启动任务流时所请求的标签一致。该标签按版本固定。要查找该标签，请在 `ee/app/services/ai/duo_workflows/start_workflow_service.rb`中，查看您对应版本的 `IMAGE_PATH` 常量。该标签也会作为任务流所创建的 CI/CD 作业上的镜像出现。镜像仓库中最新的标签通常领先于您的版本所请求的标签，因此不要通过列出镜像仓库来选择标签。

在离线环境中，请将实例固定为您传输的镜像，而不是跟踪版本默认值。使用以下任一方式：

- 项目 `.gitlab/duo/agent-config.yml` 文件中的 `image` 键，它
  适用于该项目中的任务流。
- `duo_workflows_default_image_registry` 应用设置，它
  接受完整的镜像引用（包括标签），并适用于每个
  项目。

极狐GitLab Duo Agentic Chat、代码建议、极狐GitLab Duo 代码评审和 Agent Platform 任务流不需要 ClickHouse。
如果您需要有关极狐GitLab Duo 使用情况的分析，还必须传输并配置
[ClickHouse](../../integration/clickhouse.md)
（`docker.io/clickhouse/clickhouse-server`）。

<a id="llm-model-weights"></a>

### LLM 模型权重

LLM 模型权重是 vLLM 直接从文件系统读取的大文件。这些文件不以容器镜像的形式分发。

本页示例中使用的是 Mistral Small 24B（约 48 GB）。
它同时支持代码建议和极狐GitLab Duo Chat。
有关其他模型选项和 GPU 要求，请参阅[支持的模型和硬件要求](supported_models_and_hardware_requirements.md)。

<a id="transfer-container-images"></a>

## 传输容器镜像

在联网机器上，将所需镜像保存为归档文件，然后在离线端将它们加载到您的内部镜像仓库中。

<a id="save-images-on-the-connected-machine"></a>

### 在联网机器上保存镜像

要保存镜像，请在连接互联网的机器上使用以下命令运行 `skopeo`：

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

如果您的联网机器使用代理，请在运行 `skopeo` 之前设置 `HTTPS_PROXY`：

```shell
export HTTPS_PROXY="http://proxy.example.com:8080"
```

或者，如果 skopeo 不可用，可使用 `docker save`：

```shell
GITLAB_VERSION="18.10.0"

docker pull registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-v${GITLAB_VERSION}-jh
docker save \
  registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-v${GITLAB_VERSION}-jh \
  --output aigw.tar
```

<a id="load-images-into-the-internal-registry"></a>

### 将镜像加载到内部镜像仓库

将归档文件传输到离线环境，然后将它们加载到您的内部镜像仓库中。

> [!note]
> Shell 变量不会跨机器保留。
> 请在离线主机上重新设置 `INTERNAL_REGISTRY`、`GITLAB_VERSION`、`EXECUTOR_VERSION`
> 和 `VLLM_VERSION`。

如果您的内部镜像仓库使用自签名证书，请配置
skopeo 信任该证书：

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
  docker://${INTERNAL_REGISTRY}/ai-gateway:self-hosted-v${GITLAB_VERSION}-jh

skopeo copy \
  docker-archive:executor.tar \
  docker://${INTERNAL_REGISTRY}/workflow-generic-image:${EXECUTOR_VERSION}

skopeo copy \
  docker-archive:vllm.tar \
  docker://${INTERNAL_REGISTRY}/vllm-openai:${VLLM_VERSION}
```

<a id="transfer-llm-model-weights"></a>

## 传输 LLM 模型权重

在联网机器上，要下载模型权重，可使用
Hugging Face CLI 或 `git lfs`。

使用 Hugging Face CLI：

```shell
pip install huggingface_hub
huggingface-cli download mistralai/Mistral-Small-3.2-24B-Instruct-2506 \
  --local-dir ./mistral-small-3.2-24b
```

如果您的 `huggingface_hub` 版本中没有 `huggingface-cli`，请使用 `hf download` 并传入相同的参数。

使用 `git lfs`（无需 Python）：

```shell
dnf install --assumeyes git-lfs  # On Debian/Ubuntu: apt-get install git-lfs
git lfs install
git clone https://huggingface.co/mistralai/Mistral-Small-3.2-24B-Instruct-2506
```

将下载的目录传输到离线环境，并将其放置在 vLLM 容器可访问的文件系统路径上（例如 `/data/models/mistral-small-3.2-24b`）。

<a id="start-the-ai-gateway"></a>

## 启动 AI 网关

要使用您的内部镜像仓库镜像运行 AI 网关容器：

1. 生成所需的 JWT 签名密钥：

   ```shell
   openssl genrsa -out aigw_signing.key 2048
   openssl genrsa -out aigw_validation.key 2048
   openssl genrsa -out duo_workflow_jwt.key 2048
   openssl genrsa -out duo_workflow_validation.key 2048
   ```

1. 使用您的内部镜像仓库镜像运行 AI 网关容器：

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
     --env DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL=https://${GITLAB_DOMAIN} \
     --env AIGW_CUSTOMER_PORTAL_URL=https://${GITLAB_DOMAIN} \
     ${INTERNAL_REGISTRY}/ai-gateway:self-hosted-v${GITLAB_VERSION}-jh
   ```

将 `DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL` 和 `AIGW_CUSTOMER_PORTAL_URL` 设置为您的极狐GitLab 实例 URL，以确保以下事项：

- AI 网关不会尝试访问客户门户，
  因为离线环境无法访问该门户。
- 每个请求不会出现 20 秒的延迟。

有关 TLS 终止和其他配置选项，请参阅
[安装极狐GitLab AI 网关](../../install/install_ai_gateway.md)。

<a id="start-vllm"></a>

## 启动 vLLM

运行 vLLM 以提供您传输的模型权重：

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

将 `<number-of-gpus>` 替换为可用的 GPU 数量。对于单个 GPU，请使用 `--tensor-parallel-size 1`。对于 Podman，请将 `--gpus all` 替换为
`--device nvidia.com/gpu=all --security-opt label=disable`。
在强制 SELinux 的系统上，访问 GPU 设备需要 `--security-opt label=disable` 标志。

启动后，验证模型已加载：

```shell
curl --silent "http://localhost:8000/v1/models"
```

- 有关 vLLM 配置的更多信息，请参阅
  [支持的 LLM 服务平台](supported_llm_serving_platforms.md)。
- 有关如何部署 vLLM 的信息，请参阅
  [使用 vLLM 的模型部署示例](vllm_gpt_oss_120b.md)。

<a id="configure-the-ai-gateway-in-gitlab"></a>

## 在极狐GitLab 中配置 AI 网关

在 AI 网关和 vLLM 运行后，配置极狐GitLab 以使用它们：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**本地 AI 网关 URL** 下，输入 `http://<ai-gateway-host>:5052`。
1. 在**极狐GitLab Duo Agent Platform 服务的本地 URL** 下，
   输入 `<ai-gateway-host>:50052`。
1. 开启**极狐GitLab Duo Agent Platform**。
   开启后，**任务流执行**部分会展开。
1. 在**镜像仓库**下，输入您加载的执行器镜像的完整引用
   及其标签
   （例如 `registry.internal.example.com/duo/workflow-generic-image:<executor_version>`）。
   极狐GitLab 会按原样使用完整镜像引用。
   如果您只输入镜像仓库主机名，则未设置自身镜像的任务流会拉取
   `<hostname>/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image`，
   并使用您的极狐GitLab 版本所请求的标签。
1. 选择**保存更改**。

<a id="add-the-self-hosted-model"></a>

## 添加自部署模型

将自部署模型部署添加到您的极狐GitLab 实例：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**为极狐GitLab Duo 配置模型**。
1. 选择**添加自部署模型**。
1. 填写字段：
   - 对于**端点**，输入您的 vLLM 服务器 URL。
   - 对于**模型标识符**，输入
     `custom_openai/mistral-small-3.2-24b`。
1. 可选。选择**测试连接**以验证 AI 网关
   可以访问 vLLM 端点。
1. 选择**添加自部署模型**。

<a id="configure-offline-flow-execution"></a>

## 配置离线任务流执行

执行器镜像 `v0.0.11` 及更高版本在 `/usr/local/bin/duo`中包含 `duo-cli`。当镜像中已有 `duo` 时，任务流的 CI/CD 作业会跳过下载，并且不会为 `duo-cli` 访问 `gitlab.com`。

早于 `v0.0.11`的执行器镜像不包含 `duo-cli`。如果您的极狐GitLab 版本请求这些标签之一，或者您需要不同的 `duo-cli` 版本，请构建自定义执行器镜像：

1. 在联网机器上，下载 `duo-cli` 二进制文件：

   ```shell
   curl --location "https://gitlab.com/api/v4/projects/46519181/packages/generic/duo-cli/9.25.0/duo-linux-x64" \
     --output duo-linux-x64
   ```

   要查找当前的 `duo-cli` 版本，请查看 GitLab Rails 源代码中的
   `DUO_CLI_VERSION` 常量，或
   [GitLab 软件包仓库中的 `duo-cli` 软件包](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/packages)。

1. 构建包含该二进制文件的自定义镜像：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:v0.0.19
   COPY duo-linux-x64 /usr/local/bin/duo
   RUN chmod +x /usr/local/bin/duo
   ```

   将 `v0.0.19` 替换为您的极狐GitLab 版本所请求的标签。

1. 使用上述相同的 `skopeo copy` 过程将镜像传输到您的内部镜像仓库，
   然后在您项目的 `agent-config.yml`中引用它：

   ```yaml
   image: registry.internal.example.com/duo/duo-executor:v0.0.19
   ```

如果镜像位于此极狐GitLab 实例上某个项目的容器镜像仓库中，任务流的 CI/CD 作业会跨项目拉取它。该作业以外部账号运行，而内部项目对外部账号来说看起来是私有的，因此镜像仓库会拒绝拉取。有关宿主项目必须授予的访问权限，请参阅[配置任务流以从极狐GitLab 容器镜像仓库拉取镜像](../../user/duo_agent_platform/flows/execution/images.md#configure-flows-to-pull-the-image-from-the-gitlab-container-registry)。如果镜像仓库需要凭据，请在 Runner 上配置它们。默认情况下，任务流的作业不会接收在项目、群组或实例级别配置的 CI/CD 变量，因此在那里定义的 `DOCKER_AUTH_CONFIG` 变量不会生效。有关更多信息，请参阅[为镜像拉取提供凭据](../../user/duo_agent_platform/flows/execution/images.md#provide-credentials-for-the-image-pull)。

<a id="verify-the-deployment"></a>

## 验证部署

1. 确认 AI 网关正在运行：

   ```shell
   curl --silent "http://<ai-gateway-host>:5052/monitoring/healthz"
   ```

1. [为您要使用的每个极狐GitLab Duo 功能选择自部署模型](configure_duo_features.md#select-a-self-hosted-model-for-a-feature)，
   包括极狐GitLab Duo Agent Platform 功能。

   在您为极狐GitLab Duo Agent Platform 功能分配自部署模型之前，
   健康检查不会通过。

1. 运行极狐GitLab Duo 健康检查：
   1. 在右上角，选择**管理员**。
   1. 在左侧边栏中，选择**极狐GitLab Duo**。
   1. 选择**运行健康检查**。

   健康检查会验证 AI 网关连接性和许可
   状态。
   它不会测试极狐GitLab Duo Chat 或代码建议的模型推理。

1. 要验证模型推理，请通过极狐GitLab UI 或 IDE 中的极狐GitLab Duo Chat
   或代码建议发送测试请求。

1. 要验证 Agent Platform Flows，请触发一个任务流，并确认
   执行器镜像从您的内部镜像仓库拉取，且
   `duo-cli` 不是从 `gitlab.com` 下载的。

有关常见问题，请参阅[故障排除](troubleshooting.md)。

<a id="update-artifacts"></a>

## 更新产物

当您升级极狐GitLab 实例时，请使用相同的过程传输更新后的容器镜像。使用与新极狐GitLab 版本匹配的 AI 网关镜像标签。

升级还可能更改新版本所请求的执行器标签。请在升级前检查该标签，并随 AI 网关镜像一起传输匹配的执行器镜像。

升级极狐GitLab 时无需更新模型权重。仅在更换为其他模型时才需要更新。
