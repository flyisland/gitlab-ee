---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Workspaces are virtual sandbox environments for creating and managing your GitLab development environments.
title: 工作空间
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 功能标志 `remote_development_feature_flag` 在 极狐GitLab 16.0 中[在 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/391543)。
- 在 极狐GitLab 16.7 [GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/136744)。功能标志 `remote_development_feature_flag` 被移除。

{{< /history >}}

工作空间是 极狐GitLab 中为你的代码提供的虚拟沙盒环境。
你可以使用工作空间为 极狐GitLab 项目创建和管理隔离的开发环境。
这些环境确保不同项目之间不会相互干扰。

每个工作空间都包含自己的一套依赖项、库和工具，
你可以根据每个项目的特定需求进行自定义。

工作空间最长可存在大约一个日历年，即 `8760` 小时。此后，它将被自动终止。

如需点击式演示，请参见[极狐GitLab 工作空间](https://tech-marketing.gitlab.io/static-demos/workspaces/ws_html.html)。

> [!note]
> 工作空间运行在任何支持 极狐GitLab Kubernetes Agent (`agentk`) 的 `linux/amd64` Kubernetes 集群上。如果你需要运行 `sudo` 命令，或者
> 在工作空间中构建和运行容器，可能存在平台特定的要求。
>
> 更多信息，请参见[平台兼容性](configuration.md#platform-compatibility)。

## 工作空间和项目

工作空间的作用域是一个项目。
当你创建工作空间时，必须：

- 将该工作空间分配给一个特定的项目。
- 选择一个带有[devfile](#devfile) 的项目。

工作空间可以与 极狐GitLab API 交互，其访问级别由当前用户权限定义。
即使后来撤销了用户权限，运行中的工作空间对用户仍然可访问。

### 从项目管理工作空间

{{< history >}}

- [引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/125331) 极狐GitLab 16.2。

{{< /history >}}

要从项目管理工作空间：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在右上角，选择 **代码**。
1. 在下拉列表中，在 **你的工作空间** 下，你可以：
   - 重启、停止或终止现有工作空间。
   - 创建一个新工作空间。

> [!warning]
> 当你终止一个工作空间时，极狐GitLab 会删除该工作空间中所有未保存或未提交的数据。
> 这些数据无法恢复。

### 删除与工作空间关联的资源

当你终止一个工作空间时，你会删除与该工作空间关联的所有资源。
当你删除与运行中工作空间关联的项目、`agentk`、用户或令牌时：

- 该工作空间将从用户界面中删除。
- 在 Kubernetes 集群中，运行中的工作空间资源将变为孤立资源，且不会被自动删除。

要清理孤立资源，管理员必须手动删除 Kubernetes 中的工作空间。

[史诗 11452](https://gitlab.com/groups/gitlab-org/-/work_items/11452) 提议更改此行为。

## 在 Agent 级别管理工作空间

{{< history >}}

- [引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/419281) 极狐GitLab 16.8。

{{< /history >}}

要管理所有与 `agentk` 关联的工作空间：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 选择为远程开发配置的 Agent。
1. 选择 **工作空间** 选项卡。
1. 从列表中，你可以重启、停止或终止现有工作空间。

> [!warning]
> 当你终止一个工作空间时，极狐GitLab 会删除该工作空间中所有未保存或未提交的数据。
> 这些数据无法恢复。

### 从运行中的工作空间识别 Agent

在包含多个 `agentk` 安装的部署中，你可能想从正在运行的工作空间中识别一个 Agent。

要识别与正在运行的工作空间关联的 Agent，请使用以下 GraphQL 端点之一：

- `agent-id` 返回该 Agent 所属的项目。
- `Query.workspaces` 返回：
  - 与工作空间关联的集群 Agent。
  - 该 Agent 所属的项目。

## Devfile

工作空间内置了对 devfile 的支持。Devfile 是通过指定 极狐GitLab 项目的必要工具、语言、运行时和其他组件来定义开发环境的文件。
使用它们，你可以根据定义的规范自动配置开发环境。
它们可以创建一致且可重现的开发环境，无论你使用何种机器或平台。

工作空间同时支持 极狐GitLab 默认 devfile 和自定义 devfile。

### 极狐GitLab 默认 devfile

{{< history >}}

- [在 极狐GitLab 17.8 中引入，支持 Go](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/171230)。
- [在 极狐GitLab 17.9 中添加了对 Node、Ruby 和 Rust 的支持](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/185393)。
- [在 极狐GitLab 18.0 中添加了对 Python、PHP、Java 和 GCC 的支持](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/188199)。

{{< /history >}}

当你创建一个工作空间时，所有项目都可以使用 极狐GitLab 默认 devfile。
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
> 此容器 `image` 会定期更新。`[VERSION_TAG]` 仅为占位符。有关最新版本，请参见
> [默认 `default_devfile.yaml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/remote_development/settings/default_devfile.yaml)。

工作空间默认镜像包含开发工具，如 Ruby、Node.js、Rust、Go、Python、
Java、PHP、GCC 及其对应的包管理器。这些工具会定期更新。

极狐GitLab 默认 devfile 可能不适用于所有开发环境配置。
在这些情况下，你可以创建一个[自定义 devfile](#custom-devfile)。

### 自定义 devfile

如果你需要特定的开发环境配置，请创建自定义 devfile。
你可以在相对于项目根目录的以下位置定义 devfile：

```plaintext
- /.devfile.yaml
- /.devfile.yml
- /.devfile/{devfile_name}.yaml
- /.devfile/{devfile_name}.yml
```

> [!note]
> Devfile 必须直接放在 `.devfile` 文件夹中。不支持嵌套子文件夹。
> 例如，`.devfile/subfolder/devfile.yaml` 不会被识别。

### 验证规则

- Devfile 大小不能超过 3 MB。

| 属性 | 显式规则                                                                                                                                                                                                                                                                                                     |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `schemaVersion` | 必须为 [`2.2.0`](https://devfile.io/docs/2.2.0/devfile-schema)。                                                                                                                                                                                                                                                      |
| `components`    | - Devfile 必须至少有一个组件。<br/>- 名称不能以 `gl-` 开头。<br/>- 仅支持 `container` 和 `volume`。<br/>- 不支持 `mountSources` 和 `sourceMapping`。                                                                                                                                                          |
| `commands`      | - ID 不能以 `gl-` 开头。<br/>- 仅支持 `exec` 和 `apply` 命令类型。<br/>- 对于 `exec` 命令，仅支持以下选项：`commandLine`、`component`、`label` 和 `hotReloadCapable`。<br/>- 当为 `exec` 命令指定 `hotReloadCapable` 时，必须将其设置为 `false`。 |
| `events`        | - 名称不能以 `gl-` 开头。<br/>- 仅支持 `preStart` 和 `postStart`。<br/>- Devfile 标准仅允许将 exec 命令链接到 `postStart` 事件。如果需要 apply 命令，则必须使用 `preStart` 事件。                                                                                                  |
| `parent`        | 不支持。                                                                                                                                                                                                                                                                                                               |
| `projects`           | 不支持。                                                                                                                                                                                                                                                                                                             |
| `starterProjects`     | 不支持。                                                                                                                                                                                                                                                                                                             |
| `variables`  | 键不能以 `gl-`、`gl_`、`GL-` 或 `GL_` 开头。                                                                                                                                                                                                                                                              |
| `attributes`       | - `pod-overrides` 不能在根级别或 `components` 中设置。<br/>- `container-overrides` 不能在 `components` 中设置。                                                                                                                                                                                      |

### `container` 组件类型

使用 `container` 组件类型将容器镜像定义为工作空间的执行环境。
你可以指定基础镜像、依赖项和其他设置。

`container` 组件类型仅支持以下架构属性：

| 属性 | 描述 |
|----------------------|-------------|
| `image` <sup>1</sup> | 用于工作空间的容器镜像名称。 |
| `memoryRequest`      | 容器可以使用的最小内存量。 |
| `memoryLimit`        | 容器可以使用的最大内存量。 |
| `cpuRequest`         | 容器可以使用的最小 CPU 量。 |
| `cpuLimit`           | 容器可以使用的最大 CPU 量。 |
| `env`                | 容器中使用的环境变量。名称不能以 `gl-` 开头。 |
| `endpoints`          | 从容器公开的端口映射。名称不能以 `gl-` 开头。 |
| `volumeMounts`       | 在容器中挂载的存储卷。 |
| `command`            | 用于覆盖容器入口点的命令。参见[`overrideCommand` 属性](#overridecommand-attribute)。 |
| `args`               | 容器命令的参数。参见[`overrideCommand` 属性](#overridecommand-attribute)。 |

**脚注**：

1. 当你为 `image` 属性创建自定义容器镜像时，可以使用
   [工作空间基础镜像](#workspace-base-image)作为你的基础。
   它包含 SSH 访问、用户权限和工作空间兼容性的关键配置。
   如果你选择不使用基础镜像，请确保你的自定义镜像满足所有工作空间要求。

#### `overrideCommand` 属性

`overrideCommand` 属性是一个布尔值，用于控制工作空间如何处理容器入口点。
此属性决定是保留容器的原始入口点，还是用保持活动状态的命令替换它。

`overrideCommand` 的默认值取决于组件类型：

- 带有属性 `gl/inject-editor: true` 的主组件：未指定时默认为 `true`。
- 所有其他组件：未指定时默认为 `false`。

当为 `true` 时，容器入口点被替换为 `tail -f /dev/null` 以保持容器运行。
当为 `false` 时，容器使用 devfile 组件 `command`/`args` 或构建的容器镜像的 `Entrypoint`/`Cmd`。

下表显示了 `overrideCommand` 如何影响容器行为。为清晰起见，表中使用了以下术语：

- Devfile 组件：devfile 组件条目中的 `command` 和 `args` 属性。
- 容器镜像：OCI 容器镜像中的 `Entrypoint` 和 `Cmd` 字段。

| `overrideCommand` | Devfile 组件 | 容器镜像 | 结果 |
|-------------------|-------------------|-----------------|--------|
| `true`            | 已指定 | 已指定 | 验证错误：当 `overrideCommand` 为 `true` 时，不能指定 Devfile 组件 `command`/`args`。 |
| `true`            | 已指定 | 未指定 | 验证错误：当 `overrideCommand` 为 `true` 时，不能指定 Devfile 组件 `command`/`args`。 |
| `true`            | 未指定 | 已指定 | 容器入口点替换为 `tail -f /dev/null`。 |
| `true`            | 未指定 | 未指定 | 容器入口点替换为 `tail -f /dev/null`。 |
| `false`           | 已指定 | 已指定 | Devfile 组件 `command`/`args` 用作入口点。 |
| `false`           | 已指定 | 未指定 | Devfile 组件 `command`/`args` 用作入口点。 |
| `false`           | 未指定 | 已指定 | 使用容器镜像 `Entrypoint`/`Cmd`。 |
| `false`           | 未指定 | 未指定 | 容器过早退出 (`CrashLoopBackOff`)。<sup>1</sup> |

**脚注**：

1. 当你创建一个工作空间时，它无法访问容器镜像的详细信息，例如来自私有或内部镜像仓库的。
   当 `overrideCommand` 为 `false` 且 Devfile 未指定 `command` 或 `args` 时，极狐GitLab 不会验证容器镜像或检查必需的 `Entrypoint` 或 `Cmd` 字段。
   你必须确保 Devfile 或容器指定了这些字段，否则容器会过早退出，工作空间将无法启动。

### 用户定义的 `postStart` 事件

你可以在 devfile 中定义自定义 `postStart` 事件，以便在工作空间启动后运行命令。
这些 `postStart` 事件不会阻止工作空间的可用性。即使你的自定义 `postStart` 命令仍在运行或等待运行，只要内部初始化完成，工作空间就会变为可用状态。

使用此类事件来：

- 设置开发依赖项。
- 配置工作空间环境。
- 运行初始化脚本。

`postStart` 事件名称不能以 `gl-` 开头，并且只能引用 `exec` 类型的命令。

有关展示如何配置 `postStart` 事件的示例，
请参见[示例配置](#example-configurations)。

#### `postStart` 命令的工作目录

默认情况下，`postStart` 命令的运行工作目录取决于组件：

- 带有属性 `gl/inject-editor: true` 的主组件：命令在项目目录 (`/projects/<project-path>`) 中运行。
- 其他组件：命令在容器的默认工作目录中运行。

你可以通过在命令定义中指定 `workingDir` 来覆盖默认行为：

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
      # 默认在项目目录中运行
```

#### 监控 `postStart` 事件进度

当你的工作空间运行 `postStart` 事件时，你可以监控其进度并检查工作空间日志。要检查 `postStart` 脚本的进度：

1. 在你的工作空间中打开一个终端。
1. 转到工作空间日志目录：

   ```shell
   cd /tmp/workspace-logs/
   ```

1. 查看输出日志以查看命令结果：

   ```shell
   tail -f poststart-stdout.log
   ```

所有 `postStart` 命令输出都捕获在位于[工作空间日志目录](#workspace-logs-directory)的日志文件中。

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
  # 命令 1：容器 1，无工作目录（使用项目目录）
  - id: install-dependencies
    exec:
      component: tooling-container
      commandLine: "npm install"

  # 命令 2：容器 1，指定工作目录
  - id: setup-environment
    exec:
      component: tooling-container
      commandLine: "echo 'Setting up development environment'"
      workingDir: "/home/gitlab-workspaces"

  # 命令 3：容器 2，无工作目录（使用容器默认目录）
  - id: init-database
    exec:
      component: database-container
      commandLine: "echo 'Database initialized' > db-init.log"

  # 命令 4：容器 2，指定工作目录
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
> 此容器 `image` 仅供演示目的。

其他示例，请参见 [`examples` 项目](https://gitlab.com/gitlab-org/remote-development/examples)。

## 工作空间容器要求

默认情况下，工作空间会将 [GitLab VS Code fork](https://gitlab.com/gitlab-org/gitlab-web-ide-vscode-fork) 注入并启动到 devfile 中定义了 `gl/inject-editor` 属性的容器中。
注入 极狐GitLab VS Code fork 的工作空间容器必须满足以下系统要求：

- 系统架构：AMD64
- 系统库：
  - `glibc` 2.28 及更高版本
  - `glibcxx` 3.4.25 及更高版本

这些要求已在 Debian 10.13 和 Ubuntu 20.04 上测试过。

> [!note]
> 极狐GitLab 始终从 极狐GitLab 镜像仓库 (`registry.gitlab.com`) 拉取工作空间工具注入器镜像。
> 此镜像不可被覆盖。
>
> 如果你为其他镜像使用私有容器镜像仓库，极狐GitLab 会从 极狐GitLab 镜像仓库获取这些特定镜像。
> 此要求可能会影响具有严格网络控制的环境，例如离线环境。

## 工作空间基础镜像

{{< history >}}

- [引入于](https://gitlab.com/gitlab-org/gitlab-build-images/-/merge_requests/983) 极狐GitLab 18.3。

{{< /history >}}

极狐GitLab 提供了一个工作空间基础镜像
(`registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base`)
作为所有工作空间环境的基础。

基础镜像包括：

- 稳定的 Linux 操作系统基础。
- 预配置了适合工作空间操作权限的用户。
- 必要的开发工具和系统库。
- 适用于编程语言和工具的版本管理。
- 用于远程访问的 SSH 服务器配置。
- 支持任意用户 ID 的安全配置。

如果你不希望使用工作空间基础镜像，可以创建一个自定义工作空间镜像。为确保 极狐GitLab 能够正确初始化并连接到你的自定义镜像，请将必要的配置命令从[基础镜像 Dockerfile](https://gitlab.com/gitlab-org/gitlab-build-images/-/blob/master/Dockerfile.workspaces-base) 复制到你自己的 Dockerfile 中。

### 扩展基础镜像

你可以基于工作空间基础镜像创建自定义工作空间镜像。例如：

```dockerfile
FROM registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base

# 安装其他工具
RUN sudo apt-get update && sudo apt-get install -y \
    your-additional-package \
    && sudo rm -rf /var/lib/apt/lists/*

# 安装特定的语言版本
RUN mise install python@3.11 && mise use python@3.11
```

## 工作空间插件

{{< history >}}

- [引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/385157) 极狐GitLab 17.2。

{{< /history >}}

极狐GitLab for VS Code 扩展默认为工作空间配置。

通过此扩展，你可以查看议题、创建合并请求和管理 CI/CD 流水线。
此扩展还为 AI 功能提供支持，如 CodeRider 代码建议和 CodeRider Chat。

## 扩展市场

{{< details >}}

- 状态：测试版

{{< /details >}}

{{< history >}}

- 作为[测试版](../../policy/development_stages_support.md#beta) [引入于](https://gitlab.com/gitlab-org/gitlab/-/issues/438491) 极狐GitLab 16.9，[附带一个功能标志](../../administration/feature_flags/_index.md) 名为 `allow_extensions_marketplace_in_workspace`。默认禁用。
- 功能标志 `allow_extensions_marketplace_in_workspace` 在 极狐GitLab 17.6 [移除](https://gitlab.com/gitlab-org/gitlab/-/issues/454669)。

{{< /history >}}

VS Code 扩展市场提供了对增强 Web IDE 功能的扩展的访问。默认情况下，极狐GitLab Web IDE 连接到 [Open VSX Registry](https://open-vsx.org/)。

更多信息，请参见[配置 VS Code 扩展市场](../../administration/settings/vscode_extension_marketplace.md)。

## 个人访问令牌

{{< history >}}

- [引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/129715) 极狐GitLab 16.4。
- [在 极狐GitLab 17.2 中添加了](https://gitlab.com/gitlab-org/gitlab/-/issues/385157)`api` 权限。

{{< /history >}}

当你创建工作空间时，你会获得一个有效期为 365 天、具有 `write_repository` 和 `api` 权限的个人访问令牌。
此令牌用于在启动工作空间时初始克隆项目，并配置 极狐GitLab for VS Code 扩展。

你在工作空间中执行的任何 Git 操作都会使用此令牌进行身份验证和授权。
终止工作空间会撤销该令牌。

在工作空间中使用 `GIT_CONFIG_COUNT`、`GIT_CONFIG_KEY_n` 和 `GIT_CONFIG_VALUE_n` 这些[环境变量](https://git-scm.com/docs/git-config/#Documentation/git-config.txt-GITCONFIGCOUNT) 进行 Git 身份验证。这些变量要求工作空间容器中的 Git 版本为 2.31 或更高。

## 集群中的 Pod 交互

工作空间在 Kubernetes 集群中作为 Pod 运行。
极狐GitLab 不会对 Pod 之间的交互方式施加任何限制。

由于此要求，建议将此功能与集群中的其他容器隔离。

## 网络访问和工作空间授权

客户端有责任限制对 Kubernetes 控制平面的网络访问，因为 极狐GitLab 无法控制 API。

只有工作空间创建者才能访问工作空间以及该工作空间中公开的任何端点。
工作空间创建者只有在通过 OAuth 进行用户身份验证后才能访问工作空间。

## 计算资源和卷存储

当你停止一个工作空间时，极狐GitLab 会将该工作空间的计算资源缩减为零。
但是，为工作空间配置的卷仍然存在。

要删除已配置的卷，你必须终止工作空间。

## 工作空间的自动停止和终止

{{< history >}}

- [引入于](https://gitlab.com/groups/gitlab-org/-/epics/14910) 极狐GitLab 17.6。

{{< /history >}}

默认情况下，工作空间会自动：

- 在上次启动或重启后的 36 小时停止。
- 在上次停止后的 722 小时终止。
<a id="arbitrary-user-ids"></a>

## 任意用户 ID

您可以提供自己的容器镜像，它可以以任何 Linux 用户 ID 运行。

极狐GitLab 无法预测容器镜像的 Linux 用户 ID。
极狐GitLab 使用 Linux `root` 组 ID 权限在容器中创建、更新或删除文件。
Kubernetes 集群使用的容器运行时必须确保所有容器都具有默认的 Linux 组 ID `0`。

如果您的容器镜像不支持任意用户 ID，则无法在工作空间中创建、更新或删除文件。
要创建支持任意用户 ID 的容器镜像，请参阅 [创建支持任意用户 ID 的自定义工作空间镜像](create_image.md)。

<a id="workspace-logs-directory"></a>

## 工作空间日志目录

当工作空间启动时，极狐GitLab 会创建一个日志目录，用于捕获各种初始化和启动过程的输出。

工作空间日志存储在 `/tmp/workspace-logs/` 中。

此目录有助于您监控工作空间启动进度并排查 `postStart` 事件、开发工具和其他工作空间组件的问题。有关更多信息，请参阅 [调试 `postStart` 事件](workspaces_troubleshooting.md#debug-poststart-events)。

<a id="available-log-files"></a>

### 可用的日志文件

日志目录包含以下日志文件：

| 日志文件 | 目的 | 内容 |
|------------------------|----------------------------|---------|
| `poststart-stdout.log` | `postStart` 命令输出 | 所有 `postStart` 命令的标准输出，包括用户定义的命令和极狐GitLab 内部启动任务。 |
| `poststart-stderr.log` | `postStart` 命令错误 | `postStart` 命令的错误输出和 `stderr`。您可以使用这些日志来排查失败的启动脚本。 |
| `start-vscode.log` | VS Code 服务器启动 | 来自极狐GitLab VS Code fork 服务器初始化的日志。 |
| `start-sshd.log` | SSH 守护进程启动 | SSH 守护进程初始化的输出，包括服务器启动和配置详情。 |
| `clone-unshallow.log` | Git 仓库转换 | 从后台进程生成的日志，该进程将浅克隆转换为完整克隆并检索项目的完整 Git 历史记录。 |

> [!note]
> 每次重启工作空间时，日志文件都会重新创建。停止并重启工作空间时，不会保留以前的日志文件。

<a id="shallow-cloning"></a>

## 浅克隆

{{< history >}}

- 在极狐GitLab 18.2 [引入]，带有一个[功能标志](../../administration/feature_flags/_index.md)命名为 `workspaces_shallow_clone_project`。默认禁用。
- 在极狐GitLab 18.3 [启用于 JihuLab.com]。
- 在极狐GitLab 18.4 [GA]。功能标志 `workspaces_shallow_clone_project` 已移除。

{{< /history >}}

当您创建工作空间时，极狐GitLab 使用浅克隆来提高性能。
浅克隆仅下载最新的提交历史，而不是完整的 Git 历史，这显著缩短了大型仓库的初始克隆时间。

工作空间启动后，Git 会在后台将浅克隆转换为完整克隆。
此过程透明，不影响您的开发工作流。