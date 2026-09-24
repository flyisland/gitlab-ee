---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Docker-in-Docker
description: 使用 Docker 或 Kubernetes 执行器，为极狐GitLab CI/CD 作业配置 Docker-in-Docker。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Docker-in-Docker (`dind`) 意味着您注册的 Runner 使用 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/) 或
[Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/)。
执行器使用由 Docker 提供的 [Docker 容器镜像](https://hub.docker.com/_/docker/) 来运行您的 CI/CD 作业。

该 Docker 镜像包含所有 `docker` 工具，并可以在特权模式下于镜像上下文中运行作业脚本。

始终固定镜像的特定版本，例如 `docker:24.0.5`。
如果您使用类似 `docker:latest` 的标签，则无法控制所使用的版本。
当新版本发布时，此操作可能导致不兼容问题。

<a id="use-with-docker-executor"></a>

## 与 Docker 执行器一起使用

您可以使用 Docker 执行器在 Docker 容器中运行作业。

<a id="docker-in-docker-with-tls-enabled-in-the-docker-executor-recommended"></a>

### 在 Docker 执行器中启用 TLS 的 Docker-in-Docker（推荐）

Docker 守护进程支持通过 TLS 进行连接。尽可能使用 TLS。
TLS 是 Docker 19.03.12 及更高版本的默认配置，并受
[JihuLab.com 实例 Runner](../runners/_index.md) 支持。

> [!warning]
> 此任务启用 `--docker-privileged`，这会有效禁用容器的安全机制，并使您的主机暴露于权限提升的风险中。
> 此操作可能导致容器逃逸。有关更多信息，请参阅
> [运行时权限和 Linux 能力](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities)。

要使用启用 TLS 的 Docker-in-Docker：

1. 安装 [极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。
1. 从命令行注册极狐GitLab Runner。使用 `docker` 和 `privileged`
   模式：

   ```shell
   sudo gitlab-runner register -n \
     --url "https://gitlab.com/" \
     --registration-token REGISTRATION_TOKEN \
     --executor docker \
     --description "My Docker Runner" \
     --tag-list "tls-docker-runner" \
     --docker-image "docker:24.0.5-cli" \
     --docker-privileged \
     --docker-volumes "/certs/client"
   ```

   - 此命令注册一个新的 Runner，以使用 `docker:24.0.5-cli` 镜像（如果作业级别未指定镜像）。
     要启动构建和服务容器，它使用 `privileged` 模式。
     如果您想使用 Docker-in-Docker，
     则必须在您的 Docker 容器中始终使用 `privileged = true`。
   - 此命令为服务容器和构建容器挂载 `/certs/client`，
     这是 Docker 客户端使用该目录中的证书所必需的。有关更多信息，请参阅 [Docker 镜像文档](https://hub.docker.com/_/docker/)。

   上述命令会创建一个类似于以下示例的 `config.toml` 条目：

   ```toml
   [[runners]]
     url = "https://gitlab.com/"
     token = TOKEN
     executor = "docker"
     [runners.docker]
       tls_verify = false
       image = "docker:24.0.5-cli"
       privileged = true
       disable_cache = false
       volumes = ["/certs/client", "/cache"]
     [runners.cache]
       [runners.cache.s3]
       [runners.cache.gcs]
   ```

1. 您现在可以在作业脚本中使用 `docker`。包含 `docker:24.0.5-dind` 服务：

   ```yaml
   default:
     image: docker:24.0.5-cli
     services:
       - docker:24.0.5-dind
     before_script:
       - docker info

   variables:
     # When you use the dind service, you must instruct Docker to talk with
     # the daemon started inside of the service. The daemon is available
     # with a network connection instead of the default
     # /var/run/docker.sock socket. Docker 19.03 does this automatically
     # by setting the DOCKER_HOST in
     # https://github.com/docker-library/docker/blob/d45051476babc297257df490d22cbd806f1b11e4/19.03/docker-entrypoint.sh#L23-L29
     #
     # The 'docker' hostname is the alias of the service container as described at
     # https://docs.gitlab.com/ci/services/#accessing-the-services.
     #
     # Specify to Docker where to create the certificates. Docker
     # creates them automatically on boot, and creates
     # `/certs/client` to share between the service and job
     # container, thanks to volume mount from config.toml
     DOCKER_TLS_CERTDIR: "/certs"

   build:
     stage: build
     tags:
       - tls-docker-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="docker-in-docker-with-tls-disabled-in-the-docker-executor"></a>

### 在 Docker 执行器中禁用 TLS 的 Docker-in-Docker

有时存在禁用 TLS 的合理原因。
例如，您无法控制所使用的极狐GitLab Runner 配置。

1. 从命令行注册极狐GitLab Runner。使用 `docker` 和 `privileged` 模式：

   ```shell
   sudo gitlab-runner register -n \
     --url "https://gitlab.com/" \
     --registration-token REGISTRATION_TOKEN \
     --executor docker \
     --description "My Docker Runner" \
     --tag-list "no-tls-docker-runner" \
     --docker-image "docker:24.0.5-cli" \
     --docker-privileged
   ```

   上述命令会创建一个类似于以下示例的 `config.toml` 条目：

   ```toml
   [[runners]]
     url = "https://gitlab.com/"
     token = TOKEN
     executor = "docker"
     [runners.docker]
       tls_verify = false
       image = "docker:24.0.5-cli"
       privileged = true
       disable_cache = false
       volumes = ["/cache"]
     [runners.cache]
       [runners.cache.s3]
       [runners.cache.gcs]
   ```

1. 在作业脚本中包含 `docker:24.0.5-dind` 服务：

   ```yaml
   default:
     image: docker:24.0.5-cli
     services:
       - docker:24.0.5-dind
     before_script:
       - docker info

   variables:
     # When using dind service, you must instruct docker to talk with the
     # daemon started inside of the service. The daemon is available with
     # a network connection instead of the default /var/run/docker.sock socket.
     #
     # The 'docker' hostname is the alias of the service container as described at
     # https://docs.gitlab.com/ci/services/#accessing-the-services
     #
     DOCKER_HOST: tcp://docker:2375
     #
     # This instructs Docker not to start over TLS.
     DOCKER_TLS_CERTDIR: ""

   build:
     stage: build
     tags:
       - no-tls-docker-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="use-a-unix-socket-on-a-shared-volume-between-docker-in-docker-and-build-container"></a>

### 在 Docker-in-Docker 和构建容器之间使用共享卷上的 Unix 套接字

在
[Docker 执行器中启用 TLS 的 Docker-in-Docker](#docker-in-docker-with-tls-enabled-in-the-docker-executor-recommended)
方法中定义的 `volumes = ["/certs/client", "/cache"]` 目录在[构建之间是持久的](https://gitlab.cn/docs/runner/executors/docker/#persistent-storage)。
如果多个使用 Docker 执行器 Runner 的 CI/CD 作业启用了 Docker-in-Docker 服务，则每个作业
都会写入该目录路径。此方法可能导致冲突。

要解决此冲突，请在 Docker-in-Docker 服务和构建容器之间共享的卷上使用 Unix 套接字。
此方法可提高性能，并在服务与客户端之间建立安全连接。

以下是一个示例 `config.toml`，其中包含在构建容器和服务容器之间共享的临时卷：

```toml
[[runners]]
  url = "https://gitlab.com/"
  token = TOKEN
  executor = "docker"
  [runners.docker]
    image = "docker:24.0.5-cli"
    privileged = true
    volumes = ["/runner/services/docker"] # Temporary volume shared between build and service containers.
```

Docker-in-Docker 服务会创建一个 `docker.sock`。Docker 客户端通过 Docker Unix 套接字卷连接到 `docker.sock`。

```yaml
job:
  variables:
    # This variable is shared by both the DinD service and Docker client.
    # For the service, it will instruct DinD to create `docker.sock` here.
    # For the client, it tells the Docker client which Docker Unix socket to connect to.
    DOCKER_HOST: "unix:///runner/services/docker/docker.sock"
  services:
    - docker:24.0.5-dind
  image: docker:24.0.5-cli
  script:
    - docker version
```

<a id="docker-in-docker-with-proxy-enabled-in-the-docker-executor"></a>

### 在 Docker 执行器中启用代理的 Docker-in-Docker

您可能需要配置代理设置才能使用 `docker push` 命令。

有关更多信息，请参阅 [使用 `dind` 服务时的代理设置](https://gitlab.cn/docs/runner/configuration/proxy/#proxy-settings-when-using-dind-service)。

<a id="use-with-kubernetes-executor"></a>

## 与 Kubernetes 执行器一起使用

您可以使用 [Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/) 在 Docker 容器中运行作业。

<a id="docker-in-docker-with-tls-enabled-in-kubernetes-recommended"></a>

### 在 Kubernetes 中启用 TLS 的 Docker-in-Docker（推荐）

要在 Kubernetes 中使用启用 TLS 的 Docker-in-Docker：

1. 使用
   [Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/)，更新
   [`values.yml` 文件](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/00c1a2098f303dffb910714752e9a981e119f5b5/values.yaml#L133-137)
   以指定卷挂载。

   ```yaml
   runners:
     tags: "tls-dind-kubernetes-runner"
     config: |
       [[runners]]
         [runners.kubernetes]
           image = "ubuntu:20.04"
           privileged = true
         [[runners.kubernetes.volumes.empty_dir]]
           name = "docker-certs"
           mount_path = "/certs/client"
           medium = "Memory"
   ```

1. 在作业中包含 `docker:24.0.5-dind` 服务：

   ```yaml
   default:
     image: docker:24.0.5-cli
     services:
       - name: docker:24.0.5-dind
         variables:
           HEALTHCHECK_TCP_PORT: "2376"
     before_script:
       - docker info

   variables:
     # When using dind service, you must instruct Docker to talk with
     # the daemon started inside of the service. The daemon is available
     # with a network connection instead of the default
     # /var/run/docker.sock socket.
     DOCKER_HOST: tcp://docker:2376
     #
     # The 'docker' hostname is the alias of the service container as described at
     # https://docs.gitlab.com/ci/services/#accessing-the-services.
     #
     # Specify to Docker where to create the certificates. Docker
     # creates them automatically on boot, and creates
     # `/certs/client` to share between the service and job
     # container, thanks to volume mount from config.toml
     DOCKER_TLS_CERTDIR: "/certs"
     # These are usually specified by the entrypoint, however the
     # Kubernetes executor doesn't run entrypoints
     # https://gitlab.com/gitlab-org/gitlab-runner/-/issues/4125
     DOCKER_TLS_VERIFY: 1
     DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"

   build:
     stage: build
     tags:
       - tls-dind-kubernetes-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="docker-in-docker-with-tls-disabled-in-kubernetes"></a>

### 在 Kubernetes 中禁用 TLS 的 Docker-in-Docker

要在 Kubernetes 中使用禁用 TLS 的 Docker-in-Docker，您必须调整前面的示例：

- 从 `values.yml` 文件中删除 `[[runners.kubernetes.volumes.empty_dir]]` 部分。
- 使用 `DOCKER_HOST: tcp://docker:2375` 将端口从 `2376` 更改为 `2375`。
- 使用 `DOCKER_TLS_CERTDIR: ""` 指示 Docker 在禁用 TLS 的情况下启动。

例如：

1. 使用
   [Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/)，更新
   [`values.yml` 文件](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/00c1a2098f303dffb910714752e9a981e119f5b5/values.yaml#L133-137)：

   ```yaml
   runners:
     tags: "no-tls-dind-kubernetes-runner"
     config: |
       [[runners]]
         [runners.kubernetes]
           image = "ubuntu:20.04"
           privileged = true
   ```

1. 您现在可以在作业脚本中使用 `docker`。包含
   `docker:24.0.5-dind` 服务：

   ```yaml
   default:
     image: docker:24.0.5-cli
     services:
       - name: docker:24.0.5-dind
         variables:
           HEALTHCHECK_TCP_PORT: "2375"
     before_script:
       - docker info

   variables:
     # When using dind service, you must instruct Docker to talk with
     # the daemon started inside of the service. The daemon is available
     # with a network connection instead of the default
     # /var/run/docker.sock socket.
     DOCKER_HOST: tcp://docker:2375
     #
     # The 'docker' hostname is the alias of the service container as described at
     # https://docs.gitlab.com/ci/services/#accessing-the-services.
     #
     # This instructs Docker not to start over TLS.
     DOCKER_TLS_CERTDIR: ""
   build:
     stage: build
     tags:
       - no-tls-dind-kubernetes-runner
     script:
       - docker build -t my-docker-image .
       - docker run my-docker-image /script/to/run/tests
   ```

<a id="known-issues-with-docker-in-docker"></a>

## Docker-in-Docker 的已知问题

Docker-in-Docker 是推荐的配置，但您应该注意以下问题：

- `docker-compose` 命令：此命令在此配置中默认不可用。
  要在作业脚本中使用 `docker-compose`，请遵循 Docker Compose
  [安装说明](https://docs.docker.com/compose/install/)。
- 缓存：每个作业都在新环境中运行。因为每次构建都有自己的 Docker 引擎实例，所以并发作业不会导致冲突。
  但是，由于没有层缓存，作业可能会更慢。请参阅 [Docker 层缓存](using_docker_build.md#docker-layer-caching)。
- 存储驱动：默认情况下，早期版本的 Docker 使用 `vfs` 存储驱动，
  它会为每个作业复制文件系统。Docker 17.09 及更高版本使用 `--storage-driver overlay2`，这是
  推荐的存储驱动。有关详细信息，请参阅 [使用 OverlayFS 驱动](using_docker_build.md#use-the-overlayfs-driver)。
- 根文件系统：由于 `docker:24.0.5-dind` 容器和 Runner 容器不共享它们的
  根文件系统，您可以将作业的工作目录用作子容器的挂载点。
  例如，如果您有要与子容器共享的文件，您可以在 `/builds/$CI_PROJECT_PATH` 下创建子目录
  并将其用作挂载点。有关更详细的说明，请参阅
  [议题 #41227](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/41227)。

  ```yaml
  variables:
    MOUNT_POINT: /builds/$CI_PROJECT_PATH/mnt
  script:
    - mkdir -p "$MOUNT_POINT"
    - docker run -v "$MOUNT_POINT:/mnt" my-docker-image
  ```
