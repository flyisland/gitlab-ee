---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 工作区是用于创建和管理极狐GitLab 开发环境的虚拟沙盒环境。
title: 工作区
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

工作区是极狐GitLab 中用于您的代码的虚拟沙盒环境。您可以使用工作区为极狐GitLab 项目创建和管理隔离的开发环境。这些环境可确保不同项目之间互不干扰。

每个工作区都包含自己的一组依赖项、库和工具，您可以根据每个项目的具体需求进行自定义。

工作区最多可存在约一个日历年，即 `8760` 小时。超过此时间后，它会被自动终止。

如需查看点击式演示，请参见 [GitLab 工作区](https://tech-marketing.gitlab.io/static-demos/workspaces/ws_html.html)。

> [!note]
> 工作区可运行在任何支持极狐GitLab Kubernetes Agent（`agentk`）的 `linux/amd64` Kubernetes 集群上。如果您需要运行 `sudo` 命令，或
> 在工作区中构建并运行容器，可能会有特定于平台的要求。
>
> 更多信息，请参见[平台兼容性](configuration.md#platform-compatibility)。

<a id="workspaces-and-projects"></a>

## 工作区和项目

工作区的作用域限定为项目。创建工作区时，您必须：

- 将工作区分配给特定项目。
- 选择一个带有 [devfile](#devfile)的项目。

工作区可以与极狐GitLab API 交互，访问级别由当前用户权限决定。即使用户权限随后被撤销，正在运行的工作区仍可供该用户访问。

<a id="manage-workspaces-from-a-project"></a>

### 从项目管理工作区

要从项目管理工作区：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在右上角，选择**代码**。
1. 从下拉列表中，在**您的工作区**下，您可以：
   - 重启、停止或终止现有工作区。
   - 创建新工作区。

> [!warning]
> 当您终止工作区时，极狐GitLab 会删除该工作区中所有未保存或未提交的数据。
> 这些数据无法恢复。

<a id="deleting-resources-associated-with-a-workspace"></a>

### 删除与工作区关联的资源

当您终止工作区时，您会删除与该工作区关联的所有资源。当您删除与正在运行的工作区关联的项目、`agentk`、用户或令牌时：

- 该工作区会从用户界面中删除。
- 在 Kubernetes 集群中，正在运行的工作区资源会变为孤立资源，且不会被自动删除。

要清理孤立资源，管理员必须在 Kubernetes 中手动删除该工作区。

[史诗 11452](https://gitlab.com/groups/gitlab-org/-/work_items/11452) 提议更改此行为。

<a id="manage-workspaces-at-the-agent-level"></a>

## 在 Agent 级别管理工作区

要管理与 `agentk` 关联的所有工作区：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**。
1. 选择为远程开发配置的 Agent。
1. 选择**工作区**标签页。
1. 从列表中，您可以重启、停止或终止现有工作区。

> [!warning]
> 当您终止工作区时，极狐GitLab 会删除该工作区中所有未保存或未提交的数据。
> 这些数据无法恢复。

<a id="identify-an-agent-from-a-running-workspace"></a>

### 从正在运行的工作区识别 Agent

在包含多个 `agentk` 安装的部署中，您可能希望从正在运行的工作区识别 Agent。

要从正在运行的工作区识别关联的 Agent，请使用以下 GraphQL 端点之一：

- `agent-id` 返回该 Agent 所属的项目。
- `Query.workspaces` 返回：
  - 与该工作区关联的集群 Agent。
  - 该 Agent 所属的项目。

<a id="devfile"></a>

## Devfile

工作区内置支持 devfile。Devfile 是定义开发环境的文件，它通过指定极狐GitLab 项目所需的工具、语言、运行时和其他组件来定义开发环境。使用它们可以按照您定义的规范自动配置开发环境。无论您使用何种机器或平台，它们都能创建一致且可复现的开发环境。

工作区同时支持极狐GitLab 默认 devfile 和自定义 devfile。

<a id="gitlab-default-devfile"></a>

### 极狐GitLab 默认 devfile

创建工作区时，所有项目都可以使用极狐GitLab 默认 devfile。
此 devfile 包含：

```yaml
schemaVersion: 2.2.0
components:
  - name: development-environment
    attributes:
      gl/inject-editor: true
    container:
      image: "registry.gitlab.com/gitlab-org/gitlab-build-images/workspaces/ubuntu-24.04:[VERSION_TAG]"
```

> [!note]
> 此容器 `image` 会定期更新。`[VERSION_TAG]` 仅为占位符。如需最新版本，请参见
> [默认 `default_devfile.yaml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/remote_development/settings/default_devfile.yaml)。

工作区默认镜像包含 Ruby、Node.js、Rust、Go、Python、
Java、PHP、GCC 等开发工具及其对应的包管理器。这些工具会定期更新。

极狐GitLab 默认 devfile 可能不适用于所有开发环境配置。在这些情况下，您可以创建[自定义 devfile](#custom-devfile)。

<a id="custom-devfile"></a>

### 自定义 devfile

如果您需要特定的开发环境配置，请创建自定义 devfile。您可以相对于项目根目录，在以下位置定义 devfile：

```plaintext
- /.devfile.yaml
- /.devfile.yml
- /.devfile/{devfile_name}.yaml
- /.devfile/{devfile_name}.yml
```

> [!note]
> Devfile 必须直接放在 `.devfile` 文件夹中。不支持嵌套子文件夹。
> 例如，`.devfile/subfolder/devfile.yaml` 不会被识别。

<a id="validation-rules"></a>

### 验证规则

- devfile 大小不得超过 3 MB。

| 属性        | 显式规则                                                                                                                                                                                                                                                                                                          |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `schemaVersion` | 必须为 [`2.2.0`](https://devfile.io/docs/2.2.0/devfile-schema)。                                                                                                                                                                                                                                                       |
| `components`    | - devfile 必须至少有一个组件。<br/>- 名称不得以 `gl-` 开头。<br/>- 仅支持 `container` 和 `volume`。<br/>- 不支持 `mountSources` 和 `sourceMapping`。                                                                                                                  |
| `commands`      | - ID 不得以 `gl-` 开头。<br/>- 仅支持 `exec` 和 `apply` 命令类型。<br/>- 对于 `exec` 命令，仅支持以下选项：`commandLine`、`component`、`label` 和 `hotReloadCapable`。<br/>- 当为 `exec` 命令指定 `hotReloadCapable` 时，必须将其设置为 `false`。 |
| `events`        | - 名称不得以 `gl-` 开头。<br/>- 仅支持 `preStart` 和 `postStart`。<br/>- Devfile 标准仅允许将 exec 命令链接到 `postStart` 事件。如果您想要使用 apply 命令，则必须使用 `preStart` 事件。                                                                        |
| `parent`        | 不支持。                                                                                                                                                                                                                                                                                                      |
| `projects`           | 不支持。                                                                                                                                                                                                                                                                                                      |
| `starterProjects`     | 不支持。                                                                                                                                                                                                                                                                                                      |
| `variables`  | 键不得以 `gl-`、`gl_`、`GL-` 或 `GL_` 开头。                                                                                                                                                                                                                                                                |
| `attributes`       | - 不得在根级别或 `components`中设置 `pod-overrides`。<br/>- 不得在 `components`中设置 `container-overrides`。                                                                                                                                                                                   |

<a id="container-component-type"></a>

### `container` 组件类型

使用 `container` 组件类型可将容器镜像定义为工作区的执行环境。您可以指定基础镜像、依赖项和其他设置。

`container` 组件类型仅支持以下 schema 属性：

| 属性             | 描述 |
|----------------------|-------------|
| `image` <sup>1</sup> | 用于工作区的容器镜像名称。 |
| `memoryRequest`      | 容器可以使用的最小内存量。 |
| `memoryLimit`        | 容器可以使用的最大内存量。 |
| `cpuRequest`         | 容器可以使用的最小 CPU 量。 |
| `cpuLimit`           | 容器可以使用的最大 CPU 量。 |
| `env`                | 容器中要使用的环境变量。名称不得以 `gl-` 开头。 |
| `endpoints`          | 要从容器公开的端口映射。名称不得以 `gl-` 开头。 |
| `volumeMounts`       | 要在容器中挂载的存储卷。 |
| `command`            | 用于覆盖容器入口点的命令。请参见 [`overrideCommand` 属性](#overridecommand-attribute)。 |
| `args`               | 容器命令的参数。请参见 [`overrideCommand` 属性](#overridecommand-attribute)。 |

**脚注**：

1. 当您为 `image` 属性创建自定义容器镜像时，您可以使用
   [工作区基础镜像](#workspace-base-image)作为基础。
   它包含 SSH 访问、用户权限和工作区兼容性所需的关键配置。
   如果您选择不使用基础镜像，请确保您的自定义镜像满足所有工作区要求。

<a id="overridecommand-attribute"></a>

#### `overrideCommand` 属性

`overrideCommand` 属性是一个布尔值，用于控制工作区如何处理容器入口点。此属性决定是保留容器的原始入口点，还是将其替换为
keep-alive 命令。

`overrideCommand`的默认值取决于组件类型：

- 带有 `gl/inject-editor: true` 属性的主组件：未指定时默认为 `true`。
- 所有其他组件：未指定时默认为 `false`。

当为 `true` 时，容器入口点会被替换为 `tail -f /dev/null`，以保持容器运行。当为 `false` 时，容器使用 devfile 组件的 `command`/`args` 或已构建容器镜像的 `Entrypoint`/`Cmd`。

下表显示了 `overrideCommand` 如何影响容器行为。为清晰起见，表中使用以下术语：

- Devfile 组件：devfile 组件条目中的 `command` 和 `args` 属性。
- 容器镜像：OCI 容器镜像中的 `Entrypoint` 和 `Cmd` 字段。

| `overrideCommand` | Devfile 组件 | 容器镜像 | 结果 |
|-------------------|-------------------|-----------------|--------|
| `true`            | 已指定         | 已指定       | 验证错误：当 `overrideCommand` 为 `true` 时，不能指定 Devfile 组件的 `command`/`args`。 |
| `true`            | 已指定         | 未指定   | 验证错误：当 `overrideCommand` 为 `true` 时，不能指定 Devfile 组件的 `command`/`args`。 |
| `true`            | 未指定     | 已指定       | 容器入口点被替换为 `tail -f /dev/null`。 |
| `true`            | 未指定     | 未指定   | 容器入口点被替换为 `tail -f /dev/null`。 |
| `false`           | 已指定         | 已指定       | 使用 Devfile 组件的 `command`/`args` 作为入口点。 |
| `false`           | 已指定         | 未指定   | 使用 Devfile 组件的 `command`/`args` 作为入口点。 |
| `false`           | 未指定     | 已指定       | 使用容器镜像的 `Entrypoint`/`Cmd`。 |
| `false`           | 未指定     | 未指定   | 容器提前退出（`CrashLoopBackOff`）。 <sup>1</sup> |

**脚注**：

1. 创建工作区时，它无法访问容器镜像的详细信息，例如来自私有
   或内部镜像仓库的信息。当 `overrideCommand` 为 `false` 且 Devfile 未指定 `command`
   或 `args` 时，极狐GitLab 不会验证容器镜像，也不会检查必需的 `Entrypoint` 或 `Cmd` 字段。
   您必须确保 Devfile 或容器指定了这些字段，否则容器会提前退出，
   工作区将无法启动。

<a id="user-defined-poststart-events"></a>

### 用户定义的 `postStart` 事件

您可以在 devfile 中定义自定义 `postStart` 事件，以便在工作区启动后运行命令。这些 `postStart` 事件不会阻止工作区可访问。内部初始化完成后，工作区立即可用，即使您的自定义 `postStart` 命令仍在运行或等待运行。

使用此类事件可以：

- 设置开发依赖项。
- 配置工作区环境。
- 运行初始化脚本。

`postStart` 事件名称不得以 `gl-` 开头，并且只能引用 `exec` 类型的命令。

有关如何配置 `postStart` 事件的示例，请参见[示例配置](#example-configurations)。

<a id="working-directory-for-poststart-commands"></a>

#### `postStart` 命令的工作目录

默认情况下，`postStart` 命令会因组件不同而在不同的工作目录中运行：

- 带有 `gl/inject-editor: true` 属性的主组件：命令在项目目录（`/projects/<project-path>`）中运行。
- 其他组件：命令在容器的默认工作目录中运行。

您可以在命令定义中指定 `workingDir` 来覆盖默认行为：

```yaml
commands:
  - id: install-dependencies
    exec:
      component: tooling-container
      commandLine: "npm install"
      workingDir: "/custom/path"
  - id: setup-project
    exec:
      component: tooling-container
      commandLine: "echo 'Setting up in project directory'"
      # Runs in project directory by default
```

<a id="monitor-poststart-event-progress"></a>

#### 监控 `postStart` 事件进度

当您的工作区运行 `postStart` 事件时，您可以监控其进度并查看工作区日志。要检查 `postStart` 脚本的进度：

1. 在工作区中打开终端。
1. 转到工作区日志目录：

   ```shell
   cd /tmp/workspace-logs/
   ```

1. 查看输出日志以了解命令结果：

   ```shell
   tail -f poststart-stdout.log
   ```

所有 `postStart` 命令输出都会捕获到位于[工作区日志目录](#workspace-logs-directory)中的日志文件里。

<a id="example-configurations"></a>

### 示例配置

以下是一个 devfile 配置示例：

```yaml
schemaVersion: 2.2.0
variables:
  registry-root: registry.gitlab.com
components:
  - name: tooling-container
    attributes:
      gl/inject-editor: true
    container:
      image: "{{registry-root}}/gitlab-org/remote-development/gitlab-remote-development-docs/ubuntu:22.04"
      env:
        - name: KEY
          value: VALUE
      endpoints:
        - name: http-3000
          targetPort: 3000
  - name: database-container
    attributes:
      overrideCommand: false
    container:
      image: mysql
      command: ["echo"]
      args: ["-n", "user-defined entrypoint command"]
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "my-secret-pw"
commands:
  # Command 1: Container 1, no working directory (uses project directory)
  - id: install-dependencies
    exec:
      component: tooling-container
      commandLine: "npm install"

  # Command 2: Container 1, with working directory
  - id: setup-environment
    exec:
      component: tooling-container
      commandLine: "echo 'Setting up development environment'"
      workingDir: "/home/gitlab-workspaces"

  # Command 3: Container 2, no working directory (uses container default)
  - id: init-database
    exec:
      component: database-container
      commandLine: "echo 'Database initialized' > db-init.log"

  # Command 4: Container 2, with working directory
  - id: setup-database
    exec:
      component: database-container
      commandLine: "mkdir -p /var/lib/mysql/logs && echo 'DB setup complete' > setup.log"
      workingDir: "/var/lib/mysql"

events:
  postStart:
    - install-dependencies
    - setup-environment
    - init-database
    - setup-database
```

> [!note]
> 此容器 `image` 仅用于演示目的。

其他示例请参见 [`examples` 项目](https://gitlab.com/gitlab-org/workspaces/examples)。

<a id="workspace-container-requirements"></a>

## 工作区容器要求

默认情况下，工作区会在 devfile 中定义了 `gl/inject-editor` 属性的容器中
注入并启动 [GitLab VS Code fork](https://gitlab.com/gitlab-org/gitlab-web-ide-vscode-fork)。
注入 GitLab VS Code fork的工作区容器
必须满足以下系统要求：

- 系统架构：AMD64
- 系统库：
  - `glibc` 2.28 及更高版本
  - `glibcxx` 3.4.25 及更高版本

这些要求已在 Debian 10.13 和 Ubuntu 20.04 上测试。

> [!note]
> 极狐GitLab 始终从 GitLab registry（`registry.gitlab.com`）拉取工作区工具注入器镜像。
> 此镜像无法覆盖。
>
> 如果您为其他镜像使用私有容器镜像仓库，极狐GitLab 会从 GitLab registry 获取这些
> 特定镜像。此要求可能会影响具有严格网络
> 控制的环境，例如离线环境。

<a id="workspace-base-image"></a>

## 工作区基础镜像

极狐GitLab 提供工作区基础镜像
（`registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base`），
作为所有工作区环境的基础。

基础镜像包含：

- 稳定的 Linux 操作系统基础。
- 预配置的用户，具有适合工作区操作的相应权限。
- 必要的开发工具和系统库。
- 编程语言和工具的版本管理。
- 用于远程访问的 SSH 服务器配置。
- 支持任意用户 ID 的安全配置。

如果您不想使用工作区基础镜像，可以创建自定义工作区镜像。为确保极狐GitLab 能够正确初始化并连接到您的自定义镜像，请将必要的配置命令从[基础镜像 Dockerfile](https://gitlab.com/gitlab-org/gitlab-build-images/-/blob/master/Dockerfile.workspaces-base)
复制到您自己的 Dockerfile 中。

<a id="extend-the-base-image"></a>

### 扩展基础镜像

您可以基于工作区基础镜像创建自定义工作区镜像。例如：

```dockerfile
FROM registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base

# Install additional tools
RUN sudo apt-get update && sudo apt-get install -y \
    your-additional-package \
    && sudo rm -rf /var/lib/apt/lists/*

# Install specific language versions
RUN mise install python@3.11 && mise use python@3.11
```

<a id="workspace-add-ons"></a>

## 工作区附加组件

工作区中默认配置了 GitLab for VS Code 扩展。

使用此扩展，您可以查看议题、创建合并请求并管理 CI/CD 流水线。
此扩展还为极狐GitLab Duo 代码建议和极狐GitLab Duo Chat 等 AI 功能提供支持。

<a id="extension-marketplace"></a>

## 扩展市场

{{< details >}}

- Status: 测试版

{{< /details >}}

VS Code 扩展市场提供对扩展的访问，这些扩展可增强
Web IDE 的功能。默认情况下，极狐GitLab Web IDE 连接到 [Open VSX Registry](https://open-vsx.org/)。

更多信息，请参见[配置 VS Code 扩展市场](../../administration/settings/vscode_extension_marketplace.md)。

<a id="personal-access-token"></a>

## 个人访问令牌

创建工作区时，您会获得一个个人访问令牌，该令牌在 365 天后过期，具有 `write_repository` 和 `api` 权限。此令牌用于在启动工作区时初始克隆项目，
以及配置 GitLab for VS Code 扩展。

您在工作区中执行的任何 Git 操作都使用此令牌进行身份验证和授权。终止工作区会撤销该令牌。

使用 `GIT_CONFIG_COUNT`、`GIT_CONFIG_KEY_n` 和 `GIT_CONFIG_VALUE_n` [环境变量](https://git-scm.com/docs/git-config/#Documentation/git-config.txt-GITCONFIGCOUNT)在工作区中进行 Git 身份验证。这些变量要求工作区容器中的 Git 为 2.31 或更高版本。

<a id="pod-interaction-in-a-cluster"></a>

## 集群中的 Pod 交互

工作区在 Kubernetes 集群中以 Pod 形式运行。
极狐GitLab 不对 Pod 之间的交互方式施加任何限制。

由于此要求，请考虑将此功能与集群中的其他容器隔离。

<a id="network-access-and-workspace-authorization"></a>

## 网络访问和工作区授权

限制对 Kubernetes 控制平面的网络访问是客户的责任，因为极狐GitLab 无法控制该 API。

只有工作区创建者可以访问该工作区以及该工作区中公开的任何端点。工作区创建者只有在通过 OAuth 进行用户身份验证后，才有权访问该工作区。

<a id="compute-resources-and-volume-storage"></a>

## 计算资源和卷存储

当您停止工作区时，极狐GitLab 会将该工作区的计算资源缩减到零。但是，为该工作区预配的卷仍然存在。

要删除已预配的卷，您必须终止该工作区。

<a id="automatic-workspace-stop-and-termination"></a>

## 工作区自动停止和终止

默认情况下，工作区会自动：

- 在最后一次启动或重启工作区 36 小时后停止。
- 在最后一次停止工作区 722 小时后终止。

<a id="arbitrary-user-ids"></a>

## 任意用户 ID

您可以提供自己的容器镜像，它可以以任意 Linux 用户 ID 运行。

极狐GitLab 无法预测容器镜像的 Linux 用户 ID。极狐GitLab 使用 Linux `root` 组 ID 权限在容器中创建、更新或删除文件。Kubernetes 集群使用的容器运行时必须确保所有容器都具有默认的 Linux 组 ID `0`。

如果您的容器镜像不支持任意用户 ID，您将无法在工作区中创建、更新或删除文件。要创建支持任意用户 ID 的容器镜像，请参见[创建支持任意用户 ID 的自定义工作区镜像](create_image.md)。

<a id="workspace-logs-directory"></a>

## 工作区日志目录

工作区启动时，极狐GitLab 会创建一个日志目录，用于捕获各种初始化和启动过程的输出。

工作区日志存储在 `/tmp/workspace-logs/` 中。

此目录可帮助您监控工作区启动进度，并对 `postStart` 事件、开发工具和其他工作区组件的问题进行故障排除。更多信息，请参见[调试 `postStart` 事件](workspaces_troubleshooting.md#debug-poststart-events)。

<a id="available-log-files"></a>

### 可用的日志文件

日志目录包含以下日志文件：

| 日志文件               | 用途                    | 内容 |
|------------------------|----------------------------|---------|
| `poststart-stdout.log` | `postStart` 命令输出 | 所有 `postStart` 命令的标准输出，包括用户定义的命令和极狐GitLab 内部启动任务。 |
| `poststart-stderr.log` | `postStart` 命令错误 | `postStart` 命令的错误输出和 `stderr`。您可以使用这些日志对失败的启动脚本进行故障排除。 |
| `start-vscode.log`     | VS Code 服务器启动     | 来自 GitLab VS Code fork 服务器初始化的日志。 |
| `start-sshd.log`       | SSH 守护进程启动         | SSH 守护进程初始化的输出，包括服务器启动和配置详细信息。 |
| `clone-unshallow.log`  | Git 代码仓库转换  | 来自后台进程的日志，该进程将浅克隆转换为完整克隆，并检索项目的完整 Git 历史。 |

> [!note]
> 每次重启工作区时都会重新创建日志文件。当您停止并重启工作区时，
> 之前的日志文件不会被保留。

<a id="shallow-cloning"></a>

## 浅克隆

创建工作区时，极狐GitLab 会使用浅克隆来提高性能。浅克隆仅下载最新的提交历史，而不是完整的 Git 历史，这大大缩短了大型代码仓库的初始克隆时间。

工作区启动后，Git 会在后台将浅克隆转换为完整克隆。此过程是透明的，不会影响您的开发工作流。
