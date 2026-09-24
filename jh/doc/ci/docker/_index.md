---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Docker 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="docker-integration"></a>

Docker 集成

您可以通过两种主要方式将 [Docker](https://www.docker.com) 集成到 CI/CD 工作流中：

- [在 Docker 容器中运行 CI/CD 作业](using_docker_images.md)。

  创建在 Docker 容器中运行的用于测试、构建或发布应用程序的作业。
  例如，使用来自 Docker Hub 的 Node 镜像，让您的作业在包含所需所有 Node 依赖项的容器中运行。

- 使用 [Docker Build](using_docker_build.md) 或 [BuildKit](using_buildkit.md) 构建 Docker 镜像。

  创建构建 Docker 镜像并将其发布到容器镜像仓库的作业。
  BuildKit 提供了多种方法，包括无根构建。

