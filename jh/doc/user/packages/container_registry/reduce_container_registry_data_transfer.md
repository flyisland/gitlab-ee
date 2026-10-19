---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少容器镜像仓库数据传输量
description: 减少通过极狐GitLab 容器镜像仓库传输的数据量的技巧。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

根据从容器镜像仓库下载镜像或标签的频率，数据传输量可能会相当高。本页提供了一些建议和技巧，帮助您减少通过容器镜像仓库传输的数据量。

<a id="check-data-transfer-use"></a>

## 检查数据传输使用情况

极狐GitLab UI 中不提供传输使用情况。[GitLab-#350905](https://gitlab.com/gitlab-org/gitlab/-/issues/350905) 是跟踪展示此信息工作的史诗。

<a id="determine-image-size"></a>

## 确定镜像大小

使用以下工具和技术来确定镜像的大小：

- [Skopeo](https://github.com/podman-container-tools/skopeo)：
  使用 Skopeo `inspect` 命令通过 API 调用检查层数和大小。因此，您可以在运行 `docker pull IMAGE` 之前检查这些数据。

- CI 中的 Docker：在使用 Docker 推送镜像之前，使用极狐GitLab CI 时检查并记录镜像大小。例如：

  ```shell
  docker inspect "$CI_REGISTRY_IMAGE:$IMAGE_TAG" \
        | awk '/"Size": ([0-9]+)[,]?/{ printf "Final Image Size: %d\n", $2 }'
  ```

- [Dive](https://github.com/wagoodman/dive) 是一款用于探索 Docker 镜像、层内容并发现减小其大小方法的工具。

<a id="reduce-image-size"></a>

## 减小镜像大小

<a id="use-a-smaller-base-image"></a>

### 使用更小的基础镜像

考虑使用更小的基础镜像，例如 [Alpine Linux](https://alpinelinux.org/)。Alpine 镜像大约为 5 MB，比 [Debian](https://hub.docker.com/_/debian) 等常用基础镜像小好几倍。如果您的应用以自包含静态二进制文件的形式分发，例如 Go 应用，您也可以考虑使用 Docker [scratch](https://hub.docker.com/_/scratch/) 基础镜像。

如果您需要使用特定的基础镜像操作系统，请查找 `-slim` 或 `-minimal` 变体，因为这有助于减小镜像大小。

另外，请注意您在基础镜像之上安装的操作系统软件包。这些软件包可能会增加数百兆字节。请尽量将安装的软件包数量保持在最低限度。

[多阶段构建](#use-multi-stage-builds)可以成为清理临时构建依赖的强大帮手。

您也可以考虑使用以下工具：

- [DockerSlim](https://github.com/docker-slim/docker-slim) 提供了一组命令来减小容器镜像的大小。
- [Distroless](https://github.com/GoogleContainerTools/distroless) 镜像仅包含您的应用及其运行时依赖。它们不包含软件包管理器、shell 或您在标准 Linux 发行版中预期会找到的任何其他程序。

<a id="minimize-layers"></a>

### 尽量减少层数

Dockerfile 中的每条指令都会产生一个新层，该层记录在此类指令期间应用的文件系统更改。一般来说，层数越多或层越大，镜像就越大。请尽量减少 Dockerfile 中安装软件包的层数。否则，这可能会导致构建过程中的每个步骤都增加镜像大小。

有多种策略可以减少层数和层大小。例如，与其为要安装的每个操作系统软件包使用一条 `RUN` 命令（这会导致每个软件包一个层），您可以在单条 `RUN` 命令中安装所有软件包，以减少构建过程中的步骤数并减小镜像大小。

另一个有用的策略是确保在安装软件包前后移除所有临时构建依赖，并禁用或清空操作系统软件包管理器缓存。

在构建镜像时，请确保只复制相关文件。对于 Docker，使用 [`.dockerignore`](https://docs.docker.com/reference/dockerfile/#dockerignore-file) 有助于确保构建过程忽略无关文件。

您可以使用其他第三方工具来精简镜像，例如 [DockerSlim](https://github.com/docker-slim/docker-slim)。请注意，如果使用不当，此类工具可能会移除您的应用在某些条件下运行所需的依赖。因此，最好在构建过程中力求获得更小的镜像，而不是事后尝试精简镜像。

<a id="use-multi-stage-builds"></a>

### 使用多阶段构建

通过[多阶段构建](https://docs.docker.com/build/building/multi-stage/)，您可以在 Dockerfile 中使用多条 `FROM` 语句。每条 `FROM` 指令可以使用不同的基础镜像，并且每条指令都会开始一个新的构建阶段。您可以选择性地将产物从一个阶段复制到另一个阶段，将您不希望在最终镜像中保留的所有内容都留下。当您需要安装构建依赖，但不需要它们出现在最终镜像中时，这尤其有用。

<a id="use-an-image-pull-policy"></a>

## 使用镜像拉取策略

使用 `docker` 或 `docker+machine` 执行器时，您可以在 runner `config.toml`中设置 [`pull_policy`](https://gitlab.cn/docs/runner/executors/docker/#using-the-if-not-present-pull-policy) 参数，以定义 runner 在拉取 Docker 镜像时的工作方式。为避免在使用大型且很少更新的镜像时传输数据，从远程镜像仓库拉取镜像时，请考虑使用 `if-not-present` 拉取策略。

<a id="use-docker-layer-caching"></a>

## 使用 Docker 层缓存

Docker 层缓存可以加快构建速度并减少传输的数据量。有关更多信息，请参阅[在 Docker-in-Docker 构建中缓存 Docker 层](../../../ci/docker/docker_layer_caching.md)。

<a id="check-automation-frequency"></a>

## 检查自动化频率

我们经常创建打包到容器镜像中的自动化脚本，以按特定间隔执行常规任务。如果自动化是将容器镜像从极狐GitLab 容器镜像仓库拉取到 JihuLab.com 之外的服务，您可以降低这些间隔的频率。

<a id="related-issues"></a>

## 相关议题

- 当基础 Docker 镜像更新时，您可能希望重新构建镜像。但是，[流水线订阅限制太低](https://gitlab.com/gitlab-org/gitlab/-/issues/225278)，无法利用此功能。作为变通方法，您可以每天或每天多次重新构建。[GitLab-#225278](https://gitlab.com/gitlab-org/gitlab/-/issues/225278) 提议提高该限制以帮助此工作流。
