---
stage: Application Security Testing
group: Composition Analysis
info: 如需此教程的帮助，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>。
title: 教程：扫描 Docker 容器中的漏洞
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以使用[容器扫描](../../user/application_security/container_scanning/_index.md)来检查存储在[容器镜像仓库](../../user/packages/container_registry/_index.md)中的容器镜像的漏洞。

容器扫描的配置会添加到项目的流水线配置中。在本教程中，你将：

1. [创建一个新项目](#create-a-new-project)。
1. 向项目中[添加一个 `Dockerfile` 文件](#add-a-dockerfile-to-new-project)。该 `Dockerfile` 包含了创建 Docker 镜像所需的最小配置。
1. 为新项目创建[流水线配置](#create-pipeline-configuration)，以从 `Dockerfile` 创建 Docker 镜像，构建并将 Docker 镜像推送到容器镜像仓库，然后扫描该 Docker 镜像以查找漏洞。
1. 检查[报告的漏洞](#check-for-reported-vulnerabilities)。
1. [更新 Docker 镜像](#update-the-docker-image)并扫描更新后的镜像。

<a id="create-a-new-project"></a>

## 创建一个新项目

要创建新项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 选择 **创建空白项目**。
1. 在 **项目名称** 中，输入 `Tutorial container scanning project`。
1. 在 **项目 URL** 中，为项目选择一个命名空间。
1. 选择 **创建项目**。

<a id="add-a-dockerfile-to-new-project"></a>

## 向新项目添加一个 `Dockerfile`

为了给容器扫描提供一些内容，创建一个配置最简单的 `Dockerfile`：

1. 在你的 `Tutorial container scanning project` 项目中，选择 {{< icon name="plus" >}} > **新建文件**。
1. 输入文件名 `Dockerfile`，并为文件提供以下内容：

   ```Dockerfile
   FROM hello-world:latest
   ```

由此 `Dockerfile` 创建的 Docker 镜像基于 [`hello-world`](https://hub.docker.com/_/hello-world) Docker 镜像。

1. 选择 **提交更改**。

<a id="create-pipeline-configuration"></a>

## 创建流水线配置

现在准备创建流水线配置。该流水线配置：

1. 从 `Dockerfile` 文件构建 Docker 镜像，并将该 Docker 镜像推送到容器镜像仓库。`build-image` 作业使用 [Docker-in-Docker](../../ci/docker/using_docker_build.md) 作为 [CI/CD 服务](../../ci/services/_index.md)来构建 Docker 镜像。
1. 包含 `Container-Scanning.gitlab-ci.yml` 模板，以扫描存储在容器镜像仓库中的 Docker 镜像。

要创建流水线配置：

1. 在项目的根目录中，选择 {{< icon name="plus" >}} > **新建文件**。
1. 输入文件名 `.gitlab-ci.yml`，并为文件提供以下内容：

   ```yaml
   include:
     - template: Jobs/Container-Scanning.gitlab-ci.yml

   container_scanning:
     variables:
       CS_IMAGE: $CI_REGISTRY_IMAGE/tutorial-image

   build-image:
     image: docker:24.0.2-cli
     stage: build
     services:
       - docker:24.0.2-dind
     script:
       - docker build --tag $CI_REGISTRY_IMAGE/tutorial-image --file Dockerfile .
       - docker login --username gitlab-ci-token --password $CI_JOB_TOKEN $CI_REGISTRY
       - docker push $CI_REGISTRY_IMAGE/tutorial-image
   ```

1. 选择 **提交更改**。

你几乎完成了。提交文件后，会使用此配置启动一个新流水线。完成后，你可以检查扫描结果。

<a id="check-for-reported-vulnerabilities"></a>

## 检查报告的漏洞

扫描的漏洞位于运行扫描的流水线上。要检查报告的漏洞：

1. 选择 **CI/CD** > **流水线**，然后选择最近的流水线。此流水线应包含一个 `test` 阶段中名为 `container_scanning` 的作业。
1. 如果 `container_scanning` 作业成功，选择 **安全** 选项卡。如果发现任何漏洞，它们会列在该页面上。

<a id="update-the-docker-image"></a>

## 更新 Docker 镜像

基于 `hello-world:latest` 的 Docker 镜像不太可能显示任何漏洞。要查看扫描报告漏洞的示例：

1. 在项目的根目录中，选择现有的 `Dockerfile` 文件。
1. 选择 **编辑**。
1. 将 `FROM hello-world:latest` 替换为另一个用于 [`FROM`](https://docs.docker.com/reference/dockerfile/#from) 指令的 Docker 镜像。最能演示容器扫描的 Docker 镜像应包含：
   - 操作系统软件包，例如来自 Debian、Ubuntu、Alpine 或 Red Hat 的软件包。
   - 编程语言软件包，例如 NPM 软件包或 Python 软件包。
1. 选择 **提交更改**。

对文件提交更改后，会使用更新后的 `Dockerfile` 启动一个新流水线。完成后，你可以检查新扫描的结果。