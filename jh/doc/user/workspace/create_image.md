---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 创建自定义工作区镜像，以支持您在极狐GitLab 中创建的任何工作区。
title: '教程：创建支持任意用户 ID 的自定义工作区镜像'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将指导您创建满足项目需求的自定义工作区镜像。完成后，您可以将此自定义镜像用于您在极狐GitLab 中创建的任何[工作区](_index.md)。

要创建支持任意用户 ID 的自定义工作区镜像：

1. [创建 Dockerfile](#create-a-dockerfile)。
1. [构建自定义工作区镜像](#build-the-custom-workspace-image)。
1. [将自定义工作区镜像推送到 GitLab.com 容器镜像仓库](#push-the-custom-workspace-image-to-the-gitlab-container-registry)。
1. [在极狐GitLab 中使用自定义工作区镜像](#use-the-custom-workspace-image-in-gitlab)。

<a id="before-you-begin"></a>

## 先决条件

您需要具备以下条件：

- 一个 GitLab.com 账号，并拥有创建容器镜像并将其推送到 GitLab.com 容器镜像仓库的权限。
- 本地机器上已安装 Docker。

<a id="create-a-dockerfile"></a>

## 创建 Dockerfile

创建一个 Dockerfile，以 GitLab.com 容器镜像仓库中的[工作区基础镜像](_index.md#workspace-base-image) (`registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base`) 作为起点：

```Dockerfile
FROM registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base

# Install additional tools your project needs
RUN sudo apt-get update && \
    sudo apt-get install -y tree && \
    sudo rm -rf /var/lib/apt/lists/*

# Install project-specific tools using mise
# For example, install Node.js version 20
RUN mise install node@20 && \
    mise use node@20

# Install global packages
RUN npm install -g @angular/cli

# Set up your project environment
ENV NODE_ENV=development

# Create project directories
RUN mkdir -p /home/gitlab-workspaces/projects
```

请根据项目的具体需求自定义这些步骤。接下来，构建自定义工作区镜像。

<a id="build-the-custom-workspace-image"></a>

## 构建自定义工作区镜像

Dockerfile 完成后，您就可以构建自定义工作区镜像了：

1. 在创建 Dockerfile 的目录中运行以下命令：

   ```shell
   docker build -t my-gitlab-workspace .
   ```

   这可能需要几分钟，具体取决于您的网络连接和系统速度。

1. 构建过程完成后，在本地测试该镜像：

   ```shell
   docker run -ti my-gitlab-workspace sh
   ```

现在，您应该拥有以 `gitlab-workspaces` 用户身份运行命令的权限。很好！您的镜像已在本地正常运行。接下来，您将使其在极狐GitLab 中可用。

<a id="push-the-custom-workspace-image-to-the-gitlab-container-registry"></a>

## 将自定义工作区镜像推送到 GitLab.com 容器镜像仓库

将您的自定义工作区镜像推送到 GitLab.com 容器镜像仓库，以便在您的项目中使用：

1. 登录您的 GitLab.com 账号：

   ```shell
   docker login registry.gitlab.com
   ```

1. 使用 GitLab.com 容器镜像仓库 URL 为镜像打标签：

   ```shell
   docker tag my-gitlab-workspace registry.gitlab.com/your-namespace/my-gitlab-workspace:latest
   ```

   请记得将 `your-namespace` 替换为您实际的 GitLab.com 命名空间。

1. 将镜像推送到 GitLab.com 容器镜像仓库：

   ```shell
   docker push registry.gitlab.com/your-namespace/my-gitlab-workspace:latest
   ```

   此上传可能需要一段时间，具体取决于您的网络连接速度。

做得好！您的自定义工作区镜像现已安全存储在 GitLab.com 容器镜像仓库中，随时可以使用。

<a id="use-the-custom-workspace-image-in-gitlab"></a>

## 在极狐GitLab 中使用自定义工作区镜像

最后一步，您将配置项目以使用您的自定义工作区镜像：

1. 更新项目 `.devfile.yaml`中的容器镜像：

   ```yaml
   schemaVersion: 2.2.0
   components:
     - name: tooling-container
       attributes:
         gl/inject-editor: true
       container:
         image: registry.gitlab.com/your-namespace/my-gitlab-workspace:latest
   ```

   请记得将 `your-namespace` 替换为您实际的 GitLab.com 命名空间。

恭喜！您已成功创建并配置了支持任意用户 ID 的自定义工作区镜像。现在，您可以将此自定义镜像用于您在极狐GitLab 中创建的任何[工作区](_index.md)。
