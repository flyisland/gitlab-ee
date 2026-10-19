---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将默认 Docker 镜像替换为自定义、加固或离线镜像，以在 CI/CD 中运行极狐GitLab Duo Agent Platform 任务流。
title: 配置任务流执行镜像
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过 CI/CD 运行的任务流在 Docker 镜像内执行。默认情况下，极狐GitLab 提供的镜像包含任务流所需的工具和网络保护。您可以将默认镜像替换为自定义或加固镜像，以添加项目依赖项、满足合规要求，或在离线环境中运行任务流。

<a id="change-the-default-docker-image"></a>

## 更改默认 Docker 镜像

所有通过 CI/CD 执行的任务流都使用极狐GitLab 提供的 Docker 镜像。该 Docker 镜像使用 [Anthropic Sandbox Runtime (`srt`)](https://github.com/anthropic-experimental/sandbox-runtime) 自动包含网络保护。

如果您的项目较为复杂，具有特定依赖项或工具，则可以更改 Docker 镜像。

要更改默认 Docker 镜像，请在 `agent-config.yml` 文件中添加以下配置：

```yaml
image: YOUR_DOCKER_IMAGE
```

例如：

{{< tabs >}}

{{< tab title="Python project" >}}

```yaml
image: python:3.11-slim
```

{{< /tab >}}

{{< tab title="Node.js project" >}}

```yaml
image: node:20-alpine
```

{{< /tab >}}

{{< /tabs >}}

<a id="add-network-protection"></a>

### 添加网络保护

要在您的镜像中使用网络保护，请将 `srt` 以您偏好的版本添加到 Docker 镜像中：

```Docker
# Install srt sandboxing with cache clearing and verification
ARG SANDBOX_RUNTIME_VERSION=0.0.63
RUN npm cache clean --force && \
    npm install -g @anthropic-ai/sandbox-runtime@${SANDBOX_RUNTIME_VERSION} && \
    test -s "$(npm root -g)/@anthropic-ai/sandbox-runtime/package.json" && \
    srt --version
```

有关 SRT 以及如何在自定义镜像上安装它的更多信息，请参阅[远程执行环境沙箱](../../environment_sandbox.md)。

<a id="use-a-custom-image"></a>

## 使用自定义镜像

如果您使用自定义 Docker 镜像，请确保以下命令可用，以便 Agent 正常运行：

- `git`
- `curl`，用于在任务流启动时下载极狐GitLab Duo CLI 二进制文件。

大多数基础镜像默认包含这些命令。但是，极简镜像（如 `alpine` 变体）可能需要您显式安装它们。如有需要，您可以在[设置脚本配置](_index.md#configure-setup-scripts)中安装缺失的命令。

> [!note]
> 在极狐GitLab 18.9 及更早版本中，存在[一个已知问题 (587996)](https://gitlab.com/gitlab-org/gitlab/-/work_items/587996)：在自定义镜像中使用较新版本的 `git` 时，任务流可能会失败。此问题已在 `@gitlab/duo-cli` 8.71.0 版本中解决。
>
> 如果您使用的是 `@gitlab/duo-cli` 8.71.0 或更早版本，为避免任务流因较新的 Git 版本而失败，您可以执行以下任一操作：
>
> - 在自定义镜像中使用 `2.43.7` 或更早版本的 Git
> - 使用 `@gitlab/duo-cli` 8.71.0 版本。

此外，根据 Agent 在任务流执行期间进行的工具调用，可能还需要其他常用实用程序。

例如，如果您使用基于 Alpine 的镜像：

```yaml
image: python:3.11-alpine
setup_script:
  - apk add --update git curl
```

<a id="security-and-performance"></a>

### 安全性与性能

当您使用自定义 Docker 镜像时，只有在自定义镜像中包含 Anthropic Sandbox Runtime (SRT) 时，才会应用[环境沙箱](../../environment_sandbox.md)。如果未包含 SRT，您的任务流可以访问从 Runner 可达的任何域以及整个文件系统。

如果您需要自定义镜像的网络隔离，请[在您的镜像上安装 SRT](../../environment_sandbox.md#install-anthropic-sandbox-runtime-srt-on-a-custom-image) 并[配置网络策略](../../environment_sandbox.md#configure-a-network-policy)，或者在您的 Runner 上配置网络级控制（例如防火墙规则或网络策略）。

要将作业启动时间缩短约 15-20 秒，请在自定义镜像中包含极狐GitLab Duo CLI 二进制文件和 `glab` CLI。加固镜像已预装这两个工具。

<a id="use-a-custom-image-in-an-offline-environment"></a>

## 在离线环境中使用自定义镜像

在 Runner 无法访问外部镜像仓库的离线环境中，您可以预构建一个包含极狐GitLab Duo CLI 的自定义执行器镜像。当极狐GitLab Duo CLI 已存在于镜像中时，任务流启动会跳过下载步骤。

先决条件：

- 管理员访问权限。
- 极狐GitLab 18.9 或更高版本。
- 可访问一台联网机器以构建镜像并下载产物。

要为离线环境配置任务流：

1. 在联网机器上，从 [GitLab 软件包仓库](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/packages)下载极狐GitLab Duo CLI 二进制文件：

   ```shell
   curl --location "https://gitlab.com/api/v4/projects/46519181/packages/generic/duo-cli/9.8.0/duo-linux-x64" \
     --output duo-linux-x64
   ```

1. 构建包含该二进制文件的自定义镜像：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:v0.0.6
   COPY duo-linux-x64 /usr/bin/duo
   RUN chmod +x /usr/bin/duo
   ```

1. 将镜像传输到您的离线环境。例如，使用 Docker 运行以下命令：

   ```shell
   # On an online machine
   docker save my-duo-executor:latest -o duo-executor.tar

   # Transfer `duo-executor.tar` to the offline environment

   # On an offline machine
   docker load -i duo-executor.tar
   ```

1. 将镜像推送到您的内部容器镜像仓库。
1. 设置自定义镜像仓库：
   1. 在右上角，选择**管理员**。
   1. 在左侧边栏中，选择**极狐GitLab Duo**。
   1. 选择**更改配置**。
   1. 在**镜像仓库**文本框中，输入您的内部仓库 URL（例如 `registry.internal.example.com`）。
1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 要使用自定义镜像，请更新 `agent-config.yml` 文件：

   ```yaml
   image: registry.internal.example.com/duo-executor:latest
   ```

<a id="use-a-red-hat-universal-base-image-9-minimal"></a>

## 使用 Red Hat Universal Base Image 9 Minimal

极狐GitLab 提供基于 Red Hat Universal Base Image (UBI) 9 Minimal 的加固、极简镜像变体。

在以下情况下使用加固镜像：

- 需要 Red Hat UBI 基础镜像。例如，用于 FedRAMP 或企业合规。
- 默认以非 root 用户运行容器。
- 最小攻击面，除 Agent Platform 自身所需外不包含任何语言运行时。
- 任务流执行时无出站互联网访问（所有 Agent Platform 依赖项均已预装）

加固镜像发布在
`registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened`

它同时为 `linux/amd64` 和 `linux/arm64` 构建，并使用以下标签方案：

- 每次构建使用 `:<short-sha>`
- 每个版本使用 `:<git-tag>`

先决条件：

- 极狐GitLab 18.10 或更高版本

要使用加固镜像，请在 `agent-config.yml`中进行设置：

```yaml
image: registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened:<tag>
```

<a id="image-contents"></a>

### 镜像内容

有关所有组件及锁定版本的权威且最新的列表，请参阅 `default-docker-image` [README](https://gitlab.com/gitlab-org/duo-workflow/default-docker-image/-/blob/main/README.md#runtime-inventory)中的运行时清单。

下表列出了当前锁定的版本：

| 组件 | 版本或来源 |
|---------------------------------------|----------------------------------------------------------|
| 基础镜像 | Red Hat UBI 9 Minimal (`ubi9-minimal:9.7-1776833838`) |
| `git` | 2.47.x（UBI 9 自带） |
| `git-lfs` | UBI 9 自带 |
| Node.js | 20（UBI 9 模块流 `nodejs:20`） |
| `npm` | 随 Node.js 20 捆绑 |
| `@gitlab/duo-cli` | 8.109.0 |
| `glab` (GitLab CLI) | 1.107.0 |
| `@anthropic-ai/sandbox-runtime` (SRT) | 0.0.63（通过 npm） |
| `bwrap` (bubblewrap) | AlmaLinux 9 EPEL（纯二进制，基于 userns 的沙箱） |
| `socat` | AlmaLinux 9 EPEL |
| `rg` (ripgrep) | AlmaLinux 9 EPEL |
| `unshare` | UBI 9 (`util-linux-core`) |
| 运行时用户 | 非 root，UID 1001 (`duo-runner`) |

该镜像包含极狐GitLab Duo CLI 和 `glab`。任务流执行时无需访问 `registry.npmjs.org` 或 `registry.gitlab.com`。

镜像中保留 Node.js 和 `npm` 仅用于安装 Anthropic Sandbox Runtime (SRT)。极狐GitLab Duo CLI 本身是预编译的二进制文件，不需要它们。当 SRT 也以预编译二进制文件形式分发时，后续版本的加固镜像将完全移除 Node.js 和 `npm`。

<a id="add-additional-packages"></a>

### 添加额外软件包

加固镜像以 UID 1001 (`duo-runner`) 运行。`setup_script` 在您的 `agent-config.yml`中也以此非 root 用户身份运行，因此无法使用 `microdnf` 安装系统软件包。

要添加语言运行时或系统软件包：

1. 使用您自己的 `FROM` 层扩展镜像：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened:<tag>

   USER root
   RUN microdnf install -y python3.12 python3.12-pip && microdnf clean all
   USER 1001
   ```

1. 对于不需要 root 访问权限的项目依赖项，使用 `setup_script`。例如 `pip install --user` 或 `npm install`。
