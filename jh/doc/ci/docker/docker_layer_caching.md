---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page,
  see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Speed up Docker-in-Docker builds by caching image layers across pipeline runs
  with inline or registry cache backends.
title: 在 Docker-in-Docker 构建中缓存 Docker 层
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当使用 Docker-in-Docker 时，Docker 在每次构建时都会下载镜像的所有层。
从 Docker 1.13 开始，可以在 `docker build` 步骤中使用已有镜像作为缓存，
从而显著加快构建过程。

当 Docker 运行 `docker build` 时，每条 `Dockerfile` 命令都会创建一个层。
Docker 会保留这些层作为缓存，并在没有任何变化时重用它们。
某一层的变更会导致所有后续层被重建。
要将已标记的镜像用作 `docker build` 的缓存源，请传递 `--cache-from` 参数。
要指定多个缓存源，可多次使用 `--cache-from`。

<a id="prerequisites"></a>

## 前提条件

从 Docker 27.0.1 开始，默认的 `docker` 构建驱动仅在启用 `containerd` 镜像存储时支持缓存后端。请执行以下操作之一：

- 在 Docker 守护进程配置中启用 `containerd` 镜像存储。
- 选择其他构建驱动。

<a id="use-inline-caching"></a>

## 使用内联缓存

将 `inline` 缓存后端与默认的 `docker build` 命令配合使用。这是开始使用缓存的最简单方式。缓存存储在镜像内部，无需单独的缓存镜像。对于复杂的构建流程或多阶段构建，请改用[注册表缓存](#use-registry-caching)。
有关更多信息，请参阅[内联缓存选项](https://docs.docker.com/build/cache/backends/inline/)。

> [!note]
> `--build-arg BUILDKIT_INLINE_CACHE=1` 参数是必需的。它指示 Docker 将缓存元数据嵌入镜像中，以便后续构建可以通过 `--cache-from` 将其用作缓存源。如果没有此参数，缓存会静默失败。

要在流水线中使用内联缓存：

1. 将以下 `.gitlab-ci.yml` 配置添加到你的项目中：

   ```yaml
   default:
     image: docker:27.4.1-cli
     services:
       - docker:27.4.1-dind
     before_script:
       - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

   variables:
     # 使用 TLS https://gitlab.cn/docs/ci/docker/using_docker_build/#tls-enabled
     DOCKER_HOST: tcp://docker:2376
     DOCKER_TLS_CERTDIR: "/certs"

   build:
     stage: build
     script:
       - docker pull $CI_REGISTRY_IMAGE:latest || true
       - docker build --build-arg BUILDKIT_INLINE_CACHE=1 --cache-from $CI_REGISTRY_IMAGE:latest
         --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --tag $CI_REGISTRY_IMAGE:latest .
       - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
       - docker push $CI_REGISTRY_IMAGE:latest
   ```

   在 `build` 作业的 `script` 中：

   - 第一个命令尝试从注册表中拉取镜像以用作缓存源。任何与 `--cache-from` 一起使用的镜像都必须先用 `docker pull` 拉取。
   - 第二个命令使用拉取的镜像作为缓存（通过 `--cache-from $CI_REGISTRY_IMAGE:latest`）构建 Docker 镜像，然后为其打标签。`--build-arg BUILDKIT_INLINE_CACHE=1` 标志将构建缓存嵌入到镜像中。
   - 最后两个命令将两个已标记的镜像推送到容器镜像仓库，以便后续构建将其用作缓存。

<a id="use-registry-caching"></a>

## 使用注册表缓存

将 `registry` 缓存后端与 `docker buildx build` 配合使用，将构建缓存存储在专用的缓存镜像中，与应用镜像分离。与内联缓存相比，这种方式在多阶段构建和复杂构建流程中具有更好的可扩展性。
有关更多信息，请参阅[缓存后端选项](https://docs.docker.com/build/cache/backends/)。

要在流水线中使用注册表缓存：

1. 将以下 `.gitlab-ci.yml` 配置添加到你的项目中：

   ```yaml
   default:
     image: docker:27.4.1-cli
     services:
       - docker:27.4.1-dind
     before_script:
       - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

   variables:
     # 使用 TLS https://gitlab.cn/docs/ci/docker/using_docker_build/#tls-enabled
     DOCKER_HOST: tcp://docker:2376
     DOCKER_TLS_CERTDIR: "/certs"

   build:
     stage: build
     script:
       - docker context create my-builder
       - docker buildx create my-builder --driver docker-container --use
       - docker buildx build --push -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
         --cache-to type=registry,ref=$CI_REGISTRY_IMAGE/cache-image,mode=max
         --cache-from type=registry,ref=$CI_REGISTRY_IMAGE/cache-image .
   ```

   在 `build` 作业的 `script` 中：

   - 前两个命令创建并配置 `docker-container` BuildKit 驱动，该驱动支持 `registry` 缓存后端。
   - 第三个命令构建并推送 Docker 镜像。它通过 `--cache-from` 从专用缓存镜像中读取缓存，并通过 `--cache-to` 更新缓存。`max` 模式会缓存所有中间层。