---
stage: AI 驱动
group: Agent 基础
info: 要确定与此页面关联的 Stage/Group 分配的技术文档工程师，请参见 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置流执行
---

{{< history >}}

- 在 GitLab 18.3 中引入。

{{< /history >}}

流使用代理来执行任务。

- 从极狐GitLab UI 执行的流使用 CI/CD。
- 在 IDE 中执行的流在本地运行。

你可以配置流使用 CI/CD 执行的环境。
你还可以选择[使用你自己的 Runner](#configure-runners)，以及
[在作业中指定变量](execution_variables.md)。

## 流安全

当流在极狐GitLab CI/CD 中执行时：

- 它们使用[复合身份](../composite_identity.md)来限制访问。
- 它们创建一个短暂的[工作负载流水线](../../../ci/pipelines/pipeline_types.md#workload-pipeline)，该流水线在流完成后被移除。
- 它们可用的工具是特定于流的目的的。这些工具可以包括在它们的执行环境中创建合并请求或运行本地 shell 命令。

默认情况下，流仅对极狐GitLab 实例具有网络访问权限。
有关网络访问规则的更多信息，请参阅[如何配置网络策略](../environment_sandbox.md#configure-a-network-policy)。
这种独立的环境可防止运行 shell 命令带来的意外后果。

要阻止流在极狐GitLab UI 中自动运行，你可以[关闭流执行](foundational_flows/_index.md#turn-foundational-flows-on-or-off)。

## 执行器架构

当流在 CI/CD 中运行时，Runner 会：

1. 从 npm 注册表下载 `@gitlab/duo-cli` 软件包。
1. 运行 GitLab Duo CLI，它使用 WebSocket 连接到 GitLab Duo 工作流服务。
1. 根据 AI 模型的指示执行工具（文件操作、Git 命令）。

执行器版本由极狐GitLab 管理，并作为常规发布的一部分进行更新。

> [!note]
> `@gitlab/duo-cli` npm 软件包被标记为“实验性”，用于独立 CLI 使用。
> 当在流中使用时，相关功能享有与流相同的支持级别。

## 配置 CI/CD 执行

你可以通过在你的项目中创建代理配置文件来自定义流在 CI/CD 中的执行方式。

> [!note]
> 在此场景中你无法使用预定义的 CI/CD 变量。
> 请参阅[可用变量列表](execution_variables.md#available-variables)。

## 创建配置文件

1. 在你的项目代码仓中，如果 `.gitlab/duo/` 文件夹不存在，请创建它。
1. 在该文件夹中，创建一个名为 `agent-config.yml` 的配置文件。
1. 添加你所需的配置选项（请参阅以下部分）。
1. 提交并将文件推送到你的默认分支。

当流在你的项目中通过 CI/CD 运行时，配置将被应用。

### 更改默认 Docker 镜像

默认情况下，所有使用 CI/CD 执行的流都使用极狐GitLab 提供的标准 Docker 镜像。

你可以更改 Docker 镜像并指定你自己的镜像。
你自己的镜像对于需要特定依赖项或工具的复杂项目非常有用。

要更改默认 Docker 镜像，请在 `agent-config.yml` 文件中添加以下配置：

```yaml
image: YOUR_DOCKER_IMAGE
```

例如：

```yaml
image: python:3.11-slim
```

或者对于 Node.js 项目：

```yaml
image: node:20-alpine
```

#### 自定义镜像要求

如果你使用自定义 Docker 镜像，请确保代理正常运行所需以下命令可用：

- `git`
- 带有与 `@gitlab/duo-cli` 兼容的 Node.js 版本的 `npm`。有关更多信息，请参阅 [GitLab Duo CLI 先决条件](../../gitlab_duo_cli/_index.md#install)。

大多数基础镜像默认包含这些命令。但是，最小镜像（如 `alpine` 变体）可能需要你显式安装它们。如果需要，你可以在[安装脚本配置](#configure-setup-scripts)中安装缺失的命令。

> [!note]
> 在极狐GitLab 18.9 及更早版本中，存在[一个已知问题 (587996)](https://gitlab.com/gitlab-org/gitlab/-/work_items/587996)，在使用较新版本 `git` 的自定义镜像时，流可能会失败。此问题已在 `@gitlab/duo-cli` 版本 8.71.0 中解决。
>
> 如果你使用的是 `@gitlab/duo-cli` 版本 8.71.0 或更早版本，为避免因较新的 Git 版本导致流失败，你可以执行以下任一操作：
>
> - 在你的自定义镜像中使用 Git 版本 `2.43.7` 或更早版本
> - 使用 `@gitlab/duo-cli` 版本 8.71.0。

此外，根据流执行期间代理发出的工具调用，可能还需要其他常用工具。

例如，如果你使用基于 Alpine 的镜像：

```yaml
image: python:3.11-alpine
setup_script:
  - apk add --update git nodejs npm
```

#### 安全和性能

当你使用自定义 Docker 镜像时，环境沙盒不会被应用。
你的流可以访问从 Runner 可达的任何域以及完整的文件系统。

如果你需要自定义镜像的网络隔离，请在你的 Runner 上配置网络级别的控制（例如，防火墙规则或网络策略）。

为了减少作业启动时间约 15-20 秒，请在自定义镜像中包含 `@gitlab-org/duo-cli` npm 软件包和 `glab` CLI。这样可以跳过流启动时对这些项的下载步骤。

### 配置安装脚本

你可以定义在流执行之前运行的安装脚本。这对于安装依赖项、配置环境或执行任何必要的初始化非常有用。

要添加安装脚本，请在 `agent-config.yml` 文件中添加以下命令：

```yaml
setup_script:
  - apt-get update && apt-get install -y curl
  - pip install -r requirements.txt
  - echo "Setup complete"
```

这些命令完成以下操作：

- 在主工作流命令之前运行。
- 按指定顺序执行。
- 可以是单个命令或命令数组。

> [!note]
> `setup_script` 的用户上下文取决于 Docker 镜像。默认的极狐GitLab 镜像以 `root` 身份运行。自定义镜像以镜像 `USER` 指令中定义的用户身份运行。如果你的 `setup_script` 需要 root 访问权限（例如，安装系统软件包），请确保你的自定义镜像已相应配置。

### 配置缓存

要配置缓存以加快后续的流运行，可以配置 `agent-config.yml` 文件以在执行之间保留文件和目录。缓存对于 `node_modules` 或 Python 虚拟环境等依赖项文件夹非常有用。

#### 基本缓存配置

要缓存特定路径，请在你的 `agent-config.yml` 文件中添加以下内容：

```yaml
cache:
  paths:
    - node_modules/
    - .npm/
```

#### 带键的缓存

你可以使用缓存键为不同场景创建不同的缓存。缓存键有助于确保缓存基于你的项目状态。

##### 使用字符串键

```yaml
cache:
  key: my-project-cache
  paths:
    - vendor/
    - .bundle/
```

##### 使用基于文件的缓存键

根据文件内容（如锁定文件）创建动态缓存键。当这些文件发生变化时，将创建新的缓存。这将生成指定文件的 SHA 校验和：

```yaml
cache:
  key:
    files:
      - package-lock.json
      - yarn.lock
  paths:
    - node_modules/
```

##### 将前缀与基于文件的键一起使用

将前缀与为缓存键文件计算的 SHA 结合使用：

```yaml
cache:
  key:
    files:
      - package-lock.json
    prefix: $CI_JOB_NAME
  paths:
    - node_modules/
    - .npm/
```

在此示例中，如果作业名称为 `test` 且 SHA 校验和为 `abc123`，则缓存键为 `test-abc123`。

#### 缓存限制

- 你可以指定最多两个用于生成缓存键的文件。如果指定更多文件，则仅使用前两个。
- 缓存 `paths` 字段是必需的。没有路径的缓存配置无效。
- 缓存键支持 `prefix` 字段中的 CI/CD 变量。

### 完整配置示例

以下是使用所有可用选项的 `agent-config.yml` 文件示例：

```yaml
# 自定义 Docker 镜像
image: python:3.11

# 流运行前执行的安装脚本
setup_script:
  - apt-get update && apt-get install -y build-essential
  - pip install --upgrade pip
  - pip install -r requirements.txt

# 缓存配置
cache:
  key:
    files:
      - requirements.txt
      - Pipfile.lock
    prefix: python-deps
  paths:
    - .cache/pip
    - venv/

# 网络配置
network_policy:
  include_recommended_allowed: true
  allow_all_unix_sockets: true
  allowed_domains:
    - my-own-site.com
  denied_domains:
    - malicious.com
```

此配置：

- 使用 Python 3.11 作为基础镜像。
- 在流运行前安装构建工具和 Python 依赖项。
- 缓存 pip 和虚拟环境目录。
- 当 `requirements.txt` 或 `Pipfile.lock` 更改时，使用前缀 `python-deps` 创建新缓存。

## 配置 Runner

使用 CI/CD 的流在 Runner 上执行。这些 Runner 必须：

- 使用支持 Docker 镜像的[执行器](https://docs.gitlab.cn/docs/runner/executors/)。
  例如，`docker`、`docker-autoscaler`、`kubernetes` 或其他。
  不支持 `shell` 执行器。
- 具有 `gitlab--duo` 标签，以便 Runner 知道要获取正确的作业。
- 是实例 Runner 或分配给顶层群组。流无法使用为子群组或项目配置的 Runner。在私有化部署的极狐GitLab 上，可以通过禁用 `duo_runner_restrictions` 功能标志来取消此限制。

此外，以下要求适用于私有化部署的极狐GitLab 上的 Runner：

- Runner 必须允许网络流量到达为极狐GitLab 实例配置的 GitLab Duo Agent Platform 服务。
  - GitLab Duo Agent Platform 服务与 [AI Gateway](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist) 一起提供。如果你自托管 AI Gateway 且未为 Agent Platform 设置本地 URL，则代理功能会将流量路由到 `duo-workflow-svc.runway.gitlab.net` 上的 `443` 端口。
- Runner 必须能够从 `registry.gitlab.com` 下载默认镜像，或者能够访问[你指定的 Docker 镜像](#change-the-default-docker-image)。

对于证书链中包含自签名证书的极狐GitLab 实例，GitLab Duo CLI 需要[额外配置](../../gitlab_duo_cli/_index.md#custom-ssl-certificates)。

> [!note]
> Runner 与 GitLab Duo Agent Platform 服务的连接是通过极狐GitLab 实例进行路由的。Runner 不会直接连接到 `duo-workflow-svc.runway.gitlab.net`。对 `duo-workflow-svc.runway.gitlab.net` 端口 `443` 的防火墙要求适用于极狐GitLab 实例，而不是 Runner。你的 Runner 网络配置必须允许到极狐GitLab 实例的出站 HTTPS 流量。

在 JihuLab.com 上，流可以使用：

- 极狐GitLab 提供的[托管 Runner](../../../ci/runners/hosted_runners/_index.md)。

> [!note]
> 如果你的顶层群组启用了 [IP 地址限制](../../group/access_and_permissions.md#restrict-group-access-by-ip-address)，则无法将托管 Runner 用于流。托管 Runner 使用来自云提供商池的动态 IP 地址，这些地址无法添加到你的群组 IP 允许列表中。相反，请在顶层群组级别配置自己的带有 `gitlab--duo` 标签的群组 Runner，并确保其 IP 地址包含在群组的允许列表中。

### Runner 特权模式

特权模式为[环境沙盒](../environment_sandbox.md)提供保护。
此要求适用于你使用默认的极狐GitLab 提供的镜像时。
如果你使用自定义 Docker 镜像，则不需要特权模式，因为无法应用沙盒。

| 配置 | 需要特权模式 | 沙盒激活 |
|---------------|------------------------|----------------|
| 默认镜像 | 是 | 是 |
| 自定义镜像 | 否 | 否 |