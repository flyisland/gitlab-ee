---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少容器镜像仓库数据传输
description: 减少极狐GitLab 容器镜像仓库数据传输的技巧。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

根据从容器镜像仓库下载镜像或标签的频率，数据传输量可能会很高。本页面提供了几种减少容器镜像仓库数据传输的建议和技巧。

<a id="check-data-transfer-use"></a>

## 检查数据传输用量

传输用量无法在极狐GitLab UI 中查看。GitLab-#350905 是跟踪公开此信息工作的史诗。

<a id="determine-image-size"></a>

## 确定镜像大小

使用以下工具和技术来确定镜像大小：

- [Skopeo](https://github.com/containers/skopeo)：使用 Skopeo 的 `inspect` 命令通过 API 调用来检查层数和大小。因此，你可以在运行 `docker pull IMAGE` 之前检查这些数据。
- Docker in CI：在使用 GitLab CI 时，在通过 Docker 推送镜像之前检查和记录镜像大小。例如：

  ```shell
  docker inspect "$CI_REGISTRY_IMAGE:$IMAGE_TAG" \
        | awk '/"Size": ([0-9]+)[,]?/{ printf "Final Image Size: %d\n", $2 }'
  ```

- [Dive](https://github.com/wagoodman/dive) 是一个用于探索 Docker 镜像、层内容以及发现减小其大小的方法的工具。

<a id="reduce-image-size"></a>

## 减小镜像大小

<a id="use-a-smaller-base-image"></a>

### 使用更小的基础镜像

考虑使用更小的基础镜像，例如 [Alpine Linux](https://alpinelinux.org/)。Alpine 镜像大小约为 5 MB，比 [Debian](https://hub.docker.com/_/debian) 等流行基础镜像小数倍。如果你的应用以自包含静态二进制文件的形式分发，例如 Go 应用，你还可以考虑使用 Docker 的 [scratch](https://hub.docker.com/_/scratch/) 基础镜像。

如果你需要使用特定的基础镜像操作系统，请查找 `-slim` 或 `-minimal` 变体，因为这有助于减小镜像大小。

还要注意安装在基础镜像之上的操作系统软件包。这些软件包可能增加数百兆字节。尽量将安装的软件包数量保持在最低限度。

[多阶段构建](#use-multi-stage-builds) 可以是清理临时构建依赖项的有力助手。

你还可以考虑使用以下工具：

- [DockerSlim](https://github.com/docker-slim/docker-slim) 提供了一组命令来减小容器镜像的大小。
- [Distroless](https://github.com/GoogleContainerTools/distroless) 镜像仅包含你的应用程序及其运行时依赖项。它们不包含软件包管理器、shell 或任何你期望在标准 Linux 发行版中找到的其他程序。

<a id="minimize-layers"></a>

### 最小化层数

Dockerfile 中的每条指令都会生成一个新层，该层记录了该指令期间应用的文件系统更改。通常，更多或更大的层会导致更大的镜像。尝试最小化安装软件包的 Dockerfile 中的层数。否则，这可能导致构建过程中的每个步骤都增加镜像大小。

有多种策略可以减少层数的数量和大小。例如，与其为每个要安装的操作系统软件包使用一个 `RUN` 命令（这将导致每个软件包一个层），你可以在一个 `RUN` 命令中安装所有软件包，以减少构建过程中的步骤数量并减小镜像的大小。

另一个有用的策略是确保在安装软件包之前和之后删除所有临时构建依赖项，并禁用或清空操作系统软件包管理器缓存。

在构建镜像时，确保只复制相关文件。对于 Docker，使用 [`.dockerignore`](https://docs.docker.com/reference/dockerfile/#dockerignore-file) 文件有助于确保构建过程忽略无关文件。

你可以使用其他第三方工具来压缩镜像，例如 [DockerSlim](https://github.com/docker-slim/docker-slim)。请注意，如果使用不当，此类工具可能会删除你的应用程序在某些条件下运行所需的依赖项。因此，最好在构建过程中努力生成更小的镜像，而不是在之后尝试压缩镜像。

<a id="use-multi-stage-builds"></a>

### 使用多阶段构建

使用[多阶段构建](https://docs.docker.com/build/building/multi-stage/)，你可以在 Dockerfile 中使用多个 `FROM` 语句。每个 `FROM` 指令可以使用不同的基础镜像，并且每个指令开始一个新的构建阶段。你可以选择性地将构建产物从一个阶段复制到另一个阶段，留下你不想在最终镜像中出现的一切。当需要安装构建依赖项，但不需要它们出现在最终镜像中时，这特别有用。

<a id="use-an-image-pull-policy"></a>

## 使用镜像拉取策略

当使用 `docker` 或 `docker+machine` 执行器时，你可以在 runner 的 `config.toml` 中设置一个 [`pull_policy`](https://gitlab.cn/docs/runner/executors/docker/#using-the-if-not-present-pull-policy) 参数，该参数定义了拉取 Docker 镜像时 runner 的工作方式。为了避免在使用较大且很少更新的镜像时进行数据传输，请考虑在从远程仓库拉取镜像时使用 `if-not-present` 拉取策略。

<a id="use-docker-layer-caching"></a>

## 使用 Docker 层缓存

Docker 层缓存可以加速你的构建并减少传输的数据量。有关更多信息，请参见[在 Docker-in-Docker 构建中缓存 Docker 层](../../../ci/docker/docker_layer_caching.md)。

<a id="check-automation-frequency"></a>

## 检查自动化频率

我们经常创建捆绑在容器镜像中的自动化脚本，以特定的时间间隔执行定期任务。当自动化从极狐GitLab 容器镜像仓库拉取容器镜像到 JihuLab.com 之外的服务时，你可以减少这些间隔的频率。

<a id="related-issues"></a>

## 相关议题

- 你可能希望在基础 Docker 镜像更新时重建你的镜像。然而，流水线订阅限制太低，无法利用此功能。作为变通方法，你可以每天或每天多次重建。GitLab-#225278 提议提高限制以帮助此工作流程。

