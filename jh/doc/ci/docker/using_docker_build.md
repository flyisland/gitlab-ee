---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Docker 构建 Docker 镜像
description: 在极狐GitLab CI/CD 中使用 shell 执行器、Docker-in-Docker、套接字绑定或管道绑定构建并推送容器镜像。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将极狐GitLab CI/CD 与 Docker 结合使用，以构建、测试和推送容器镜像。
要在 CI/CD 作业中运行 Docker 命令，您必须配置极狐GitLab Runner 以支持 `docker` 命令。

您选择的方法取决于您的基础设施、执行器类型和安全要求。某些方法需要在 Runner 上启用 `privileged` 模式。
如果您无法启用 `privileged` 模式，请使用 [Docker 替代方案](#docker-alternatives)。

| 方法                                            | 执行器           | 特权模式      | 操作系统      |
|-----------------------------------------------------|--------------------|-----------------|---------|
| [Shell 执行器](#use-the-shell-executor)           | Shell              | 否              | Linux   |
| [Docker-in-Docker](docker_in_docker.md)             | Docker、Kubernetes | 是             | Linux   |
| [Docker 套接字绑定](#use-docker-socket-binding) | Docker、Kubernetes | 否              | Linux   |
| [Docker 管道绑定](#use-docker-pipe-binding)     | Docker、Kubernetes | 否              | Windows |

<a id="use-the-shell-executor"></a>

## 使用 Shell 执行器

要在 CI/CD 作业中包含 Docker 命令，您可以将 Runner 配置为使用 `shell` 执行器。在此配置中，`gitlab-runner` 用户运行 Docker 命令，但需要拥有相应权限。

1. [安装](https://jihulab.com/gitlab-cn/gitlab-runner#installation) 极狐GitLab Runner。
1. [注册](https://gitlab.cn/docs/runner/register/) Runner。
   选择 `shell` 执行器。例如：

   ```shell
   sudo gitlab-runner register -n \
     --url "https://gitlab.com/" \
     --registration-token REGISTRATION_TOKEN \
     --executor shell \
     --description "My Runner"
   ```

1. 在安装了极狐GitLab Runner 的服务器上，安装 Docker Engine。
   查看[受支持平台](https://docs.docker.com/engine/install/)列表。

1. 将 `gitlab-runner` 用户添加到 `docker` 组：

   ```shell
   sudo usermod -aG docker gitlab-runner
   ```

1. 验证 `gitlab-runner` 是否有权访问 Docker：

   ```shell
   sudo -u gitlab-runner -H docker info
   ```

1. 在极狐GitLab 中，将 `docker info` 添加到 `.gitlab-ci.yml` 以验证 Docker 是否正常工作：

   ```yaml
   default:
     before_script:
       - docker info
   build_image:
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

您现在可以使用 `docker` 命令（如果需要，还可以安装 Docker Compose）。

当您将 `gitlab-runner` 添加到 `docker` 组时，实际上授予了 `gitlab-runner` 完全的 root 权限。
有关更多信息，请参阅 [`docker` 组的安全性](https://blog.zopyx.com/on-docker-security-docker-group-considered-harmful/)。

<a id="use-docker-in-docker"></a>

## 使用 Docker-in-Docker

Docker-in-Docker (`dind`) 意味着您注册的 Runner 使用 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/) 或 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)，并且执行器使用 [Docker 容器镜像](https://hub.docker.com/_/docker/) 来运行您的 CI/CD 作业。

每个作业都有自己独立的 Docker 守护进程，因此并发作业不会冲突。当您的 Runner 支持 `privileged` 模式时，请使用此方法。

有关设置说明，请参阅 [使用 Docker-in-Docker](docker_in_docker.md)。

<a id="use-docker-socket-binding"></a>

## 使用 Docker 套接字绑定

要在 CI/CD 作业中使用 Docker 命令，您可以将 `/var/run/docker.sock` 绑定挂载到构建容器中。然后，Docker 在镜像的上下文中可用。

如果您绑定了 Docker 套接字，则不能将 `docker:24.0.5-dind` 用作服务。卷绑定也会影响服务，使其不兼容。

<a id="use-the-docker-executor-with-docker-socket-binding"></a>

### 将 Docker 执行器与 Docker 套接字绑定一起使用

要使用 Docker 执行器挂载 Docker 套接字，请将 `"/var/run/docker.sock:/var/run/docker.sock"` 添加到 [`[runners.docker]` 部分中的卷](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#volumes-in-the-runnersdocker-section)。

1. 要在注册 Runner 时挂载 `/var/run/docker.sock`，请包含以下选项：

   ```shell
   sudo gitlab-runner register \
     --non-interactive \
     --url "https://gitlab.com/" \
     --registration-token REGISTRATION_TOKEN \
     --executor "docker" \
     --description "docker-runner" \
     --tag-list "socket-binding-docker-runner" \
     --docker-image "docker:24.0.5-cli" \
     --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
   ```

   上述命令会创建一个类似于以下示例的 `config.toml` 条目：

   ```toml
   [[runners]]
     url = "https://gitlab.com/"
     token = RUNNER_TOKEN
     executor = "docker"
     [runners.docker]
       tls_verify = false
       image = "docker:24.0.5-cli"
       privileged = false
       disable_cache = false
       volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
     [runners.cache]
       Insecure = false
   ```

1. 在作业脚本中使用 Docker：

   ```yaml
   default:
     image: docker:24.0.5-cli
     before_script:
       - docker info

   build:
     stage: build
     tags:
       - socket-binding-docker-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="use-the-kubernetes-executor-with-docker-socket-binding"></a>

### 将 Kubernetes 执行器与 Docker 套接字绑定一起使用

要使用 Kubernetes 执行器挂载 Docker 套接字，请将 `"/var/run/docker.sock"` 添加到 [`[[runners.kubernetes.volumes.host_path]]` 部分中的卷](https://gitlab.cn/docs/runner/executors/kubernetes/index/#hostpath-volume)。

1. 要指定卷挂载，请使用 [Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/) 更新 [`values.yml` 文件](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/00c1a2098f303dffb910714752e9a981e119f5b5/values.yaml#L133-137)。

   ```yaml
   runners:
     tags: "socket-binding-kubernetes-runner"
     config: |
       [[runners]]
         [runners.kubernetes]
           image = "ubuntu:20.04"
           privileged = false
         [runners.kubernetes]
           [[runners.kubernetes.volumes.host_path]]
             host_path = '/var/run/docker.sock'
             mount_path = '/var/run/docker.sock'
             name = 'docker-sock'
             read_only = true
   ```

1. 在作业脚本中使用 Docker：

   ```yaml
   default:
     image: docker:24.0.5-cli
     before_script:
       - docker info
   build:
     stage: build
     tags:
       - socket-binding-kubernetes-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="known-issues-with-docker-socket-binding"></a>

### Docker 套接字绑定的已知问题

当您使用 Docker 套接字绑定时，可以避免在特权模式下运行 Docker。但是，此方法的影响包括：

- 当您共享 Docker 守护进程时，实际上禁用了容器的安全机制，并使您的主机暴露于权限提升的风险中。这可能导致容器逃逸。例如，如果您在项目中运行 `docker rm -f $(docker ps -a -q)`，它会删除极狐GitLab Runner 容器。
- 并发作业可能无法正常工作。如果您的测试创建了具有特定名称的容器，它们可能会相互冲突。
- Docker 命令创建的任何容器都是 Runner 的兄弟容器，而不是 Runner 的子容器。这可能会给您的工作流带来复杂性。
- 将源代码仓库中的文件和目录共享到容器中可能无法按预期工作。卷挂载是在主机机器的上下文中完成的，而不是在构建容器中。例如：

  ```shell
  docker run --rm -t -i -v $(pwd)/src:/home/app/src test-image:latest run_app_tests
  ```

您不需要像使用 Docker-in-Docker 执行器时那样包含 `docker:24.0.5-dind` 服务：

```yaml
default:
  image: docker:24.0.5-cli
  before_script:
    - docker info

build:
  stage: build
  script:
    - docker build -t my-docker-image .
    - docker run my-docker-image /script/to/run/tests
```

对于复杂的 Docker-in-Docker 设置，例如 [使用 CodeClimate 进行代码质量扫描](../testing/code_quality_codeclimate_scanning.md)，您必须匹配主机和容器路径才能正确执行。有关更多详细信息，请参阅 [使用私有 Runner 进行基于 CodeClimate 的扫描](../testing/code_quality_codeclimate_scanning.md#use-private-runners)。

<a id="use-docker-pipe-binding"></a>

## 使用 Docker 管道绑定

Windows 容器运行针对 Windows Server 内核和用户态（Windows Server Core 或 Nano Server）编译的 Windows 可执行文件。要构建和运行 Windows 容器，需要支持容器功能的 Windows 系统。
有关更多信息，请参阅 [Windows 容器](https://learn.microsoft.com/en-us/virtualization/windowscontainers/)。

由于 Windows 容器[不支持 Docker-in-Docker](https://github.com/docker-library/docker/issues/49) 方法，因此您无法在容器内运行嵌套的 Docker Engine。
要在 Windows 容器内构建或管理 Docker 镜像，请使用 Docker 管道绑定（也称为 Docker-outside-of-Docker 或 DooD）。

> [!warning]
> Docker 管道绑定具有安全影响。当您绑定挂载 `\\\\.\\pipe\\docker_engine` 时，容器对主机的 Docker 守护进程拥有完全的管理访问权限。容器内的进程可以启动或停止其他容器、管理镜像，并可能获得主机系统上的提升权限。

要使用 Docker 管道绑定，您必须在主机 Windows Server 操作系统上安装并运行 Docker Engine。
有关更多信息，请参阅 [在 Windows Server 上安装 Docker Community Edition (CE)](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-server-1)。

要在基于 Windows 的容器 CI/CD 作业中使用 Docker 命令，您可以将 `\\\\.\\pipe\\docker_engine` 绑定挂载到启动的执行器容器中。然后，Docker 在镜像的上下文中可用。

[Windows 中的 Docker 管道绑定](#use-docker-pipe-binding) 类似于 [Linux 中的 Docker 套接字绑定](#use-docker-socket-binding)。[Docker 管道绑定的已知问题](#known-issues-with-docker-pipe-binding) 类似于 [Docker 套接字绑定的已知问题](#known-issues-with-docker-socket-binding)。

使用 Docker 管道绑定的一个强制先决条件是在主机 Windows Server 操作系统上安装并运行 Docker Engine。
请参阅：[在 Windows Server 上安装 Docker Community Edition (CE)](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-server-2)

<a id="use-the-docker-executor-with-docker-pipe-binding"></a>

### 将 Docker 执行器与 Docker 管道绑定一起使用

您可以使用 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/) 在基于 Windows 的容器中运行作业。

要使用 Docker 执行器挂载 Docker 管道，请将 `"\\\\.\\pipe\\docker_engine:\\\\.\\pipe\\docker_engine"` 添加到 [`[runners.docker]` 部分中的卷](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#volumes-in-the-runnersdocker-section)。

1. 要在注册 Runner 时挂载 `\\\\.\\pipe\\docker_engine`，请包含以下选项：

   ```powershell
   .\gitlab-runner.exe register \
     --non-interactive \
     --url "https://gitlab.com/" \
     --registration-token REGISTRATION_TOKEN \
     --executor "docker-windows" \
     --description "docker-windows-runner"
     --tag-list "docker-windows-runner" \
     --docker-image "docker:25-windowsservercore-ltsc2022" \
     --docker-volumes "\\\\.\\pipe\\docker_engine:\\\\.\\pipe\\docker_engine"
   ```

   上述命令会创建一个类似于以下示例的 `config.toml` 条目：

   ```toml
   [[runners]]
     url = "https://gitlab.com/"
     token = RUNNER_TOKEN
     executor = "docker-windows"
     [runners.docker]
       tls_verify = false
       image = "docker:25-windowsservercore-ltsc2022"
       privileged = false
       disable_cache = false
       volumes = ["\\\\.\\pipe\\docker_engine:\\\\.\\pipe\\docker_engine"]
   ```

1. 在作业脚本中使用 Docker：

   ```yaml
   default:
     image: docker:25-windowsservercore-ltsc2022
     before_script:
       - docker version
       - docker info

   build:
     stage: build
     tags:
       - docker-windows-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="use-the-kubernetes-executor-with-docker-pipe-binding"></a>

### 将 Kubernetes 执行器与 Docker 管道绑定一起使用

您可以使用 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/) 在基于 Windows 的容器中运行作业。

要将 Kubernetes 执行器用于基于 Windows 的容器，您必须在 Kubernetes 集群中包含 Windows 节点。
有关更多信息，请参阅 [Kubernetes 中的 Windows 容器](https://kubernetes.io/docs/concepts/windows/intro/)。

您可以使用 [在 Linux 环境中运行但以 Windows 节点为目标的 Runner](https://gitlab.cn/docs/runner/executors/kubernetes/#example-for-windowsamd64)

要使用 Kubernetes 执行器挂载 Docker 管道，请将 `"\\.\pipe\docker_engine"` 添加到 [`[[runners.kubernetes.volumes.host_path]]` 部分中的卷](https://gitlab.cn/docs/runner/executors/kubernetes/index/#hostpath-volume)。

1. 要指定卷挂载，请使用 [Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/) 更新 [`values.yml` 文件](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/00c1a2098f303dffb910714752e9a981e119f5b5/values.yaml#L133-137)。

   ```yaml
   runners:
     tags: "kubernetes-windows-runner"
     config: |
       [[runners]]
         executor = "kubernetes"

         # The FF_USE_POWERSHELL_PATH_RESOLVER feature flag has to be enabled for PowerShell
         # to resolve paths for Windows correctly when Runner is operating in a Linux environment
         # but targeting Windows nodes.
         [runners.feature_flags]
           FF_USE_POWERSHELL_PATH_RESOLVER = true

         [runners.kubernetes]
           [[runners.kubernetes.volumes.host_path]]
             host_path = '\\\\.\\pipe\\docker_engine'
             mount_path = '\\\\.\\pipe\\docker_engine'
             name = 'docker-pipe'
             read_only = true

           [runners.kubernetes.node_selector]
             "kubernetes.io/arch" = "amd64"
             "kubernetes.io/os" = "windows"
             "node.kubernetes.io/windows-build" = "10.0.20348"
   ```

1. 在作业脚本中使用 Docker：

   ```yaml
   default:
     image: docker:25-windowsservercore-ltsc2022
     before_script:
       - docker version
       - docker info

   build:
     stage: build
     tags:
       - kubernetes-windows-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="known-issues-with-aws-eks-kubernetes-cluster"></a>

#### AWS EKS Kubernetes 集群的已知问题

当您从 `dockerd` 迁移到 `containerd` 时，AWS EKS 引导脚本 `Start-EKSBootstrap.ps1` 会停止并禁用 Docker 服务。要解决此问题，请在 [在 Windows Server 上安装 Docker Community Edition (CE)](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-server-1) 后使用此脚本重命名 Docker 服务：

```powershell
Write-Output "Rename the just installed Docker Engine Service from docker to dockerd"
Write-Output "because the Start-EKSBootstrap.ps1 stops and disables the docker Service as part of migration from dockerd to containerd"
Stop-Service -Name docker
dockerd --register-service --service-name dockerd
Start-Service -Name dockerd
Write-Output "Ready to do Docker pipe binding on Windows EKS Node! :-)"
```

<a id="known-issues-with-docker-pipe-binding"></a>

### Docker 管道绑定的已知问题

Docker 管道绑定具有与 [Docker 套接字绑定的已知问题](#known-issues-with-docker-socket-binding) 相同的一组安全和隔离问题。

<a id="enable-registry-mirror-for-dockerdind-service"></a>

## 为 `docker:dind` 服务启用镜像仓库镜像

当 Docker 守护进程在服务容器内启动时，它使用默认配置。您可能希望配置一个 [镜像仓库镜像](https://docs.docker.com/docker-hub/mirror/) 以提高性能并确保不超过 Docker Hub 速率限制。

<a id="the-service-in-the-gitlab-ciyml-file"></a>

### `.gitlab-ci.yml` 文件中的服务

您可以向 `dind` 服务附加额外的 CLI 标志来设置镜像仓库镜像：

```yaml
services:
  - name: docker:24.0.5-dind
    command: ["--registry-mirror", "https://registry-mirror.example.com"]  # Specify the registry mirror to use
```

<a id="the-service-in-the-gitlab-runner-configuration-file"></a>

### 极狐GitLab Runner 配置文件中的服务

如果您是极狐GitLab Runner 管理员，您可以指定 `command` 来为 Docker 守护进程配置镜像仓库镜像。必须为 [Docker](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runnersdockerservices-section) 或 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/#define-a-list-of-services) 定义 `dind` 服务。

Docker：

```toml
[[runners]]
  ...
  executor = "docker"
  [runners.docker]
    ...
    privileged = true
    [[runners.docker.services]]
      name = "docker:24.0.5-dind"
      command = ["--registry-mirror", "https://registry-mirror.example.com"]
```

Kubernetes：

```toml
[[runners]]
  ...
  name = "kubernetes"
  [runners.kubernetes]
    ...
    privileged = true
    [[runners.kubernetes.services]]
      name = "docker:24.0.5-dind"
      command = ["--registry-mirror", "https://registry-mirror.example.com"]
```

<a id="the-docker-executor-in-the-gitlab-runner-configuration-file"></a>

### 极狐GitLab Runner 配置文件中的 Docker 执行器

如果您是极狐GitLab Runner 管理员，您可以为每个 `dind` 服务使用镜像。更新 [配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 以指定 [卷挂载](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#volumes-in-the-runnersdocker-section)。

例如，如果您有一个包含以下内容的 `/opt/docker/daemon.json` 文件：

```json
{
  "registry-mirrors": [
    "https://registry-mirror.example.com"
  ]
}
```

更新 `config.toml` 文件以将该文件挂载到 `/etc/docker/daemon.json`。这会为极狐GitLab Runner 创建的每个容器挂载该文件。`dind` 服务会检测到此配置。

```toml
[[runners]]
  ...
  executor = "docker"
  [runners.docker]
    image = "alpine:3.12"
    privileged = true
    volumes = ["/opt/docker/daemon.json:/etc/docker/daemon.json:ro"]
```

<a id="the-kubernetes-executor-in-the-gitlab-runner-configuration-file"></a>

### 极狐GitLab Runner 配置文件中的 Kubernetes 执行器

如果您是极狐GitLab Runner 管理员，您可以为每个 `dind` 服务使用镜像。更新 [配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 以指定 [ConfigMap 卷挂载](https://gitlab.cn/docs/runner/executors/kubernetes/#configmap-volume)。

例如，如果您有一个包含以下内容的 `/tmp/daemon.json` 文件：

```json
{
  "registry-mirrors": [
    "https://registry-mirror.example.com"
  ]
}
```

使用此文件的内容创建一个 [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/)。您可以使用如下命令执行此操作：

```shell
kubectl create configmap docker-daemon --namespace gitlab-runner --from-file /tmp/daemon.json
```

> [!note]
> 您必须使用极狐GitLab Runner 的 Kubernetes 执行器用于创建作业 Pod 的命名空间。

创建 ConfigMap 后，您可以更新 `config.toml` 文件以将该文件挂载到 `/etc/docker/daemon.json`。此更新会为极狐GitLab Runner 创建的每个容器挂载该文件。`dind` 服务会检测到此配置。

```toml
[[runners]]
  ...
  executor = "kubernetes"
  [runners.kubernetes]
    image = "alpine:3.12"
    privileged = true
    [[runners.kubernetes.volumes.config_map]]
      name = "docker-daemon"
      mount_path = "/etc/docker/daemon.json"
      sub_path = "daemon.json"
```

<a id="authenticate-with-registry-in-docker-in-docker"></a>

## 在 Docker-in-Docker 中向镜像仓库进行身份验证

当您使用 Docker-in-Docker 时，[标准身份验证方法](using_docker_images.md#access-an-image-from-a-private-container-registry) 不起作用，因为服务会启动一个新的 Docker 守护进程。您应该 [向镜像仓库进行身份验证](authenticate_registry.md)。

<a id="docker-layer-caching"></a>

## Docker 层缓存

您可以缓存 Docker 层以加快构建速度。
有关更多信息，请参阅 [在 Docker-in-Docker 构建中缓存 Docker 层](docker_layer_caching.md)。

<a id="use-the-overlayfs-driver"></a>

## 使用 OverlayFS 驱动

> [!note]
> JihuLab.com 上的实例 Runner 默认使用 `overlay2` 驱动。

默认情况下，使用 `docker:dind` 时，Docker 使用 `vfs` 存储驱动，它会在每次运行时复制文件系统。您可以通过使用不同的驱动（例如 `overlay2`）来避免这种磁盘密集型操作。

<a id="requirements"></a>

### 要求

1. 确保使用较新的内核，最好为 `>= 4.2`。
1. 检查 `overlay` 模块是否已加载：

   ```shell
   sudo lsmod | grep overlay
   ```

   如果没有看到结果，则说明模块未加载。要加载模块，请使用：

   ```shell
   sudo modprobe overlay
   ```

   如果模块已加载，您必须确保模块在重启时加载。
   在 Ubuntu 系统上，可以通过将以下行添加到 `/etc/modules` 来实现：

   ```plaintext
   overlay
   ```

<a id="use-the-overlayfs-driver-per-project"></a>

### 按项目使用 OverlayFS 驱动

您可以通过在 `.gitlab-ci.yml` 中使用 `DOCKER_DRIVER` [CI/CD 变量](../yaml/_index.md#variables) 为每个项目单独启用驱动：

```yaml
variables:
  DOCKER_DRIVER: overlay2
```

<a id="use-the-overlayfs-driver-for-every-project"></a>

### 为每个项目使用 OverlayFS 驱动

如果您使用自己的 [Runner](https://gitlab.cn/docs/runner/)，您可以通过在 [`[[runners]]` 部分中的 `config.toml` 文件](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section) 中设置 `DOCKER_DRIVER` 环境变量来为每个项目启用驱动：

```toml
environment = ["DOCKER_DRIVER=overlay2"]
```

如果您运行多个 Runner，则必须修改所有配置文件。

详细了解 [Runner 配置](https://gitlab.cn/docs/runner/configuration/) 和 [使用 OverlayFS 存储驱动](https://docs.docker.com/engine/storage/drivers/overlayfs-driver/)。

<a id="docker-alternatives"></a>

## Docker 替代方案

您可以在不启用 Runner 特权模式的情况下构建容器镜像：

- [BuildKit](using_buildkit.md)：包含无根 BuildKit 选项，消除了 Docker 守护进程依赖。
- [Buildah](#buildah-example)：无需 Docker 守护进程即可构建符合 OCI 标准的镜像。

<a id="buildah-example"></a>

### Buildah 示例

要将 Buildah 与极狐GitLab CI/CD 一起使用，您需要一个具有以下执行器之一的 [Runner](https://gitlab.cn/docs/runner/)：

- [Kubernetes](https://gitlab.cn/docs/runner/executors/kubernetes/)。
- [Docker](https://gitlab.cn/docs/runner/executors/docker/)。
- [Docker Machine](https://gitlab.cn/docs/runner/executors/docker_machine/)。

在此示例中，您使用 Buildah 来：

1. 构建 Docker 镜像。
1. 将其推送到 [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)。

在最后一步中，Buildah 使用项目根目录下的 `Dockerfile` 来构建 Docker 镜像。最后，它将镜像推送到项目的容器镜像仓库：

```yaml
build:
  stage: build
  image: quay.io/buildah/stable
  variables:
    # Use vfs with buildah. Docker offers overlayfs as a default, but Buildah
    # cannot stack overlayfs on top of another overlayfs filesystem.
    STORAGE_DRIVER: vfs
    # Write all image metadata in the docker format, not the standard OCI format.
    # Newer versions of docker can handle the OCI format, but older versions, like
    # the one shipped with Fedora 30, cannot handle the format.
    BUILDAH_FORMAT: docker
    FQ_IMAGE_NAME: "$CI_REGISTRY_IMAGE/test"
  before_script:
    # GitLab container registry credentials taken from the
    # [predefined CI/CD variables](../variables/_index.md#predefined-cicd-variables)
    # to authenticate to the registry.
    - echo "$CI_REGISTRY_PASSWORD" | buildah login -u "$CI_REGISTRY_USER" --password-stdin $CI_REGISTRY
  script:
    - buildah images
    - buildah build -t $FQ_IMAGE_NAME
    - buildah images
    - buildah push $FQ_IMAGE_NAME
```

如果您使用部署到 OpenShift 集群的极狐GitLab Runner Operator，请尝试 [使用 Buildah 在无根容器中构建镜像的教程](buildah_rootless_tutorial.md)。

要为多种 CPU 架构构建镜像，请参阅 [使用 Buildah 进行多平台构建](buildah_rootless_multi_arch.md)。

<a id="use-the-gitlab-container-registry"></a>

## 使用极狐GitLab 容器镜像仓库

构建 Docker 镜像后，您可以将其推送到 [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/build_and_push_images.md#use-gitlab-cicd)。

<a id="troubleshooting"></a>

## 故障排除

<a id="open-pipedocker_engine-the-system-cannot-find-the-file-specified"></a>

### `open //./pipe/docker_engine: The system cannot find the file specified`

当您在 PowerShell 脚本中运行 `docker` 命令以访问挂载的 Docker 管道时，可能会出现以下错误：

```powershell
PS C:\> docker version
Client:
 Version:           25.0.5
 API version:       1.44
 Go version:        go1.21.8
 Git commit:        5dc9bcc
 Built:             Tue Mar 19 15:06:12 2024
 OS/Arch:           windows/amd64
 Context:           default
error during connect: this error may indicate that the docker daemon is not running: Get "http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.44/version": open //./pipe/docker_engine: The system cannot find the file specified.
```

该错误表明 Docker Engine 未在 Windows EKS 节点上运行，并且无法在基于 Windows 的执行器容器中使用 Docker 管道绑定。

要解决此问题，请使用 [将 Kubernetes 执行器与 Docker 管道绑定一起使用](#use-the-kubernetes-executor-with-docker-pipe-binding) 中描述的变通方法。
