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

您可以通过两种主要方式将 [Docker](https://www.docker.com) 集成到您的 CI/CD 工作流中：

- 在 Docker 容器中[运行 CI/CD 作业](using_docker_images.md)。

  创建作业以测试、构建或发布在 Docker 容器中运行的应用程序。
  例如，使用 Docker Hub 中的 Node 镜像，使您的作业在包含所需全部 Node 依赖项的容器中运行。

- 使用 [Docker Build](using_docker_build.md) 或 [BuildKit](using_buildkit.md) 构建 Docker 镜像。

  创建作业以构建 Docker 镜像并将其发布到容器镜像仓库。
  BuildKit 提供多种方式，包括无根构建。
