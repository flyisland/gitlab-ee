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

通过 CI/CD 运行的任务流在 Docker 镜像内执行。默认情况下，极狐GitLab 提供
一个包含任务流所需工具和网络保护的镜像。您可以将默认镜像替换为自定义或加固镜像，以添加项目依赖、满足合规要求，或在离线环境中运行任务流。

<a id="change-the-default-docker-image"></a>

## 更改默认 Docker 镜像

所有通过 CI/CD 执行的任务流都使用极狐GitLab 提供的 Docker 镜像。
该 Docker 镜像使用 Anthropic Sandbox Runtime (`srt`)
自动包含网络保护。

如果您的项目复杂且具有特定依赖或工具，您可以更改 Docker 镜像。

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

要在您的镜像中使用网络保护，请将 `srt` 添加到您的 Docker 镜像中，并使用您偏好的版本：

```Docker
# Install srt sandboxing with cache clearing and verification
ARG SANDBOX_RUNTIME_VERSION=0.0.20
RUN npm cache clean --force && \
    npm install -g @anthropic-ai/sandbox-runtime@${SANDBOX_RUNTIME_VERSION} && \
    test -s "$(npm root -g)/@anthropic-ai/sandbox-runtime/package.json" && \
    srt --version
```

有关 SRT 的更多信息以及如何在自定义镜像上安装它，请参阅[远程执行环境沙箱](../../environment_sandbox.md)。

<a id="use-a-custom-image"></a>

## 使用自定义镜像

如果您使用自定义 Docker 镜像，请确保以下命令可用，以便 Agent 正常运行：

- `git`
- `npm`，且 Node.js 版本与 `@gitlab/duo-cli` 兼容。有关更多信息，请参阅[极狐GitLab Duo CLI 先决条件](../../../gitlab_duo_cli/set_up.md#prerequisites)。

大多数基础镜像默认包含这些命令。但是，精简镜像（如 `alpine` 变体）
可能需要您显式安装它们。如有需要，您可以在[设置脚本配置](_index.md#configure-setup-scripts)中安装缺失的命令。

> [!note]
> 在极狐GitLab 18.9 及更早版本中，存在[一个已知问题 (587996)](https://gitlab.com/gitlab-org/gitlab/-/work_items/587996)，即任务流在自定义镜像中使用较新版本的 `git` 时可能会失败。此问题已在 `@gitlab/duo-cli` 8.71.0 版本中解决。
>
> 如果您使用的是 `@gitlab/duo-cli` 8.71.0 或更早版本，为避免任务流因较新的 Git 版本而失败，您可以执行以下任一操作：
>
> - 在您的自定义镜像中使用 `2.43.7` 或更早版本的 Git
> - 使用 `@gitlab/duo-cli` 8.71.0 版本。

此外，根据任务流执行期间 Agent 进行的工具调用，可能还需要其他常用工具。

例如，如果您使用基于 Alpine 的镜像：

```yaml
image: python:3.11-alpine
setup_script:
  - apk add --update git nodejs npm
```

<a id="security-and-performance"></a>

### 安全与性能

当您使用自定义 Docker 镜像时，仅当您的自定义镜像中包含 Anthropic Sandbox Runtime (SRT) 时，才会应用[环境沙箱](../../environment_sandbox.md)。如果未包含 SRT，您的任务流可以访问 Runner 可达的任何域以及完整的文件系统。

如果您需要自定义镜像的网络隔离，请在您的镜像上安装 SRT 并[配置网络策略](../../environment_sandbox.md#configure-a-network-policy)，或在您的 Runner 上配置网络级控制（例如，防火墙规则或网络策略）。

为将作业启动时间缩短约 15-20 秒，请在您的自定义镜像中包含 `@gitlab/duo-cli` npm 软件包和 `glab` CLI。加固镜像已预装这两个工具。

<a id="use-a-custom-image-in-an-offline-environment"></a>

## 在离线环境中使用自定义镜像

在 Runner 无法访问外部镜像仓库的离线环境中，您可以预构建一个包含 `@gitlab/duo-cli` 的自定义执行器镜像。当镜像中已包含极狐GitLab Duo CLI 时，任务流启动将跳过 npm 下载步骤。

先决条件：

- 管理员访问权限。
- 极狐GitLab 18.9 或更高版本。
- 访问一台在线机器以构建镜像并下载产物。

要为离线环境配置任务流：

1. 在一台在线机器上，使用极狐GitLab Duo CLI 构建自定义镜像：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:v0.0.6
   RUN npm install -g @gitlab/duo-cli@8.86.0
   ```

   或者，要完全避免使用 npm，可以从 [GitLab 软件包仓库](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/packages)下载独立二进制文件：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:v0.0.6
   COPY duo-linux-x64 /usr/bin/duo
   RUN chmod +x /usr/bin/duo
   ```

   要下载独立二进制文件，请运行以下命令：

   ```shell
   curl --location "https://gitlab.com/api/v4/projects/46519181/packages/generic/duo-cli/8.86.0/duo-linux-x64" \
     --output duo-linux-x64
   ```

1. 将镜像传输到您的离线环境。
   例如，使用 Docker，运行以下命令：

   ```shell
   # On an online machine
   docker save my-duo-executor:latest -o duo-executor.tar

   # Transfer `duo-executor.tar` to the offline environment

   # On an offline machine
   docker load -i duo-executor.tar
   ```

1. 将镜像推送到您的内部容器镜像仓库。
1. 设置自定义镜像仓库：
   1. 在右上角，选择 **管理员**。
   1. 在左侧边栏中，选择 **极狐GitLab Duo**。
   1. 选择 **更改配置**。
   1. 在 **镜像仓库** 文本框中，输入您的内部镜像仓库 URL（例如，`registry.internal.example.com`）。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 要使用自定义镜像，请更新 `agent-config.yml` 文件：

   ```yaml
   image: registry.internal.example.com/duo-executor:latest
   ```

<a id="use-a-red-hat-universal-base-image-9-minimal"></a>

## 使用 Red Hat Universal Base Image 9 Minimal

极狐GitLab 提供基于 Red Hat Universal Base Image (UBI) 9 Minimal 的加固、精简镜像变体。

当您的环境需要以下条件时，请使用加固镜像：

- Red Hat UBI 基础镜像。例如，用于 FedRAMP 或企业合规。
- 默认以非 root 用户执行容器。
- 最小攻击面，除 Agent Platform 自身所需外，不包含其他语言运行时。
- 任务流执行时无出站互联网访问（所有 Agent Platform 依赖均已预装）

加固镜像发布在
`registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened`

它同时为 `linux/amd64` 和 `linux/arm64` 构建，并使用以下标签方案：

- 每次构建使用 `:<short-sha>`
- 每个版本使用 `:<git-tag>`

先决条件：

- 极狐GitLab 18.10 或更高版本

要使用加固镜像，请在您的 `agent-config.yml` 中设置它：

```yaml
image: registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened:<tag>
```

<a id="image-contents"></a>

### 镜像内容

有关所有组件和固定版本的权威且最新的列表，请参阅 `default-docker-image` [README](https://gitlab.com/gitlab-org/duo-workflow/default-docker-image/-/blob/main/README.md#runtime-inventory) 中的运行时清单。

下表列出了当前固定的版本：

| 组件                             | 版本或来源                                        |
|---------------------------------------|----------------------------------------------------------|
| 基础镜像                            | Red Hat UBI 9 Minimal (`ubi9-minimal:9.7-1776833838`)    |
| `git`                                 | 2.47.x (UBI 9 自带)                                     |
| `git-lfs`                             | UBI 9 自带                                              |
| Node.js                               | 20 (UBI 9 模块流 `nodejs:20`)                     |
| `npm`                                 | 随 Node.js 20 捆绑                                  |
| `@gitlab/duo-cli`                     | 8.109.0                                                  |
| `glab` (GitLab CLI)                   | 1.107.0                                                  |
| `@anthropic-ai/sandbox-runtime` (SRT) | 0.0.20 (通过 npm)                                         |
| `bwrap` (bubblewrap)                  | AlmaLinux 9 EPEL (纯二进制，基于 userns 的沙箱) |
| `socat`                               | AlmaLinux 9 EPEL                                         |
| `rg` (ripgrep)                        | AlmaLinux 9 EPEL                                         |
| `unshare`                             | UBI 9 (`util-linux-core`)                                |
| 运行时用户                          | 非 root，UID 1001 (`duo-runner`)                        |

该镜像包含 `@gitlab/duo-cli` 和 `glab`。任务流执行时无需出站访问 `registry.npmjs.org` 或 `registry.gitlab.com`。

<a id="add-additional-packages"></a>

### 添加其他软件包

加固镜像以 UID 1001 (`duo-runner`) 运行。您 `agent-config.yml` 中的 `setup_script` 也以此非 root 用户运行，因此无法使用 `microdnf` 安装系统软件包。

要添加语言运行时或系统软件包：

1. 使用您自己的 `FROM` 层扩展镜像：

   ```dockerfile
   FROM registry.gitlab.com/gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened:<tag>

   USER root
   RUN microdnf install -y python3.12 python3.12-pip && microdnf clean all
   USER 1001
   ```

1. 对于不需要 root 权限的项目依赖，使用 `setup_script`。例如，`pip install --user` 或 `npm install`。
