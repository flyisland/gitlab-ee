---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create a custom workspace image to support any workspace you create in 极狐GitLab.
title: '教程：创建支持任意用户 ID 的自定义工作区镜像'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将指导您创建满足项目需求的自定义工作区镜像。完成后，您可以在极狐GitLab 中创建的任何[工作区](_index.md)中使用此自定义镜像。

要创建支持任意用户 ID 的自定义工作区镜像，请执行以下操作：

1. [创建 Dockerfile](#create-a-dockerfile)。
1. [构建自定义工作区镜像](#build-the-custom-workspace-image)。
1. [将自定义工作区镜像推送到极狐GitLab 容器镜像仓库](#push-the-custom-workspace-image-to-the-gitlab-container-registry)。
1. [在极狐GitLab 中使用自定义工作区镜像](#use-the-custom-workspace-image-in-gitlab)。

<a id="before-you-begin"></a>

## 准备工作

您需要准备以下内容：

- 一个具有向极狐GitLab 容器镜像仓库创建和推送容器镜像权限的极狐GitLab 账户。
- 在本地机器上安装 Docker。

<a id="create-a-dockerfile"></a>

## 创建 Dockerfile

创建一个使用来自极狐GitLab 容器镜像仓库的[工作区基础镜像](_index.md#workspace-base-image)（`registry.gitlab.com/gitlab-org/gitlab-build-images:workspaces-base`）作为起点的 Dockerfile：

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

根据项目的具体需求自定义这些步骤。接下来，构建自定义工作区镜像。

<a id="build-the-custom-workspace-image"></a>

## 构建自定义工作区镜像

Dockerfile 完成后，您就可以构建自定义工作区镜像了：

1. 在创建 Dockerfile 的目录中运行以下命令：

   ```shell
   docker build -t my-gitlab-workspace .
   ```

   这可能需要几分钟，具体取决于您的互联网连接和系统速度。

1. 构建过程完成后，在本地测试镜像：

   ```shell
   docker run -ti my-gitlab-workspace sh
   ```

现在，您应该有权以 `gitlab-workspaces` 用户身份运行命令。完美！您的镜像在本地运行正常。接下来，您将使其在极狐GitLab 中可用。

<a id="push-the-custom-workspace-image-to-the-gitlab-container-registry"></a>

## 将自定义工作区镜像推送到极狐GitLab 容器镜像仓库

将自定义工作区镜像推送到极狐GitLab 容器镜像仓库，以便在项目中使用：

1. 登录您的极狐GitLab 账户：

   ```shell
   docker login registry.gitlab.com
   ```

1. 使用极狐GitLab 容器镜像仓库 URL 标记镜像：

   ```shell
   docker tag my-gitlab-workspace registry.gitlab.com/your-namespace/my-gitlab-workspace:latest
   ```

   请记得将 `your-namespace` 替换为您实际的极狐GitLab 命名空间。

1. 将镜像推送到极狐GitLab 容器镜像仓库：

   ```shell
   docker push registry.gitlab.com/your-namespace/my-gitlab-workspace:latest
   ```

   此上传可能需要一些时间，具体取决于您的互联网连接速度。

做得好！您的自定义工作区镜像现在已安全存储在极狐GitLab 容器镜像仓库中，并可供使用。

<a id="use-the-custom-workspace-image-in-gitlab"></a>

## 在极狐GitLab 中使用自定义工作区镜像

最后一步，您将配置项目以使用自定义工作区镜像：

1. 更新项目 `.devfile.yaml` 中的容器镜像：

   ```yaml
   schemaVersion: 2.2.0
   components:
     - name: tooling-container
       attributes:
         gl/inject-editor: true
       container:
         image: registry.gitlab.com/your-namespace/my-gitlab-workspace:latest
   ```

   请记得将 `your-namespace` 替换为您实际的极狐GitLab 命名空间。

恭喜！您已成功创建并配置了支持任意用户 ID 的自定义工作区镜像。现在，您可以在极狐GitLab 中创建的任何[工作区](_index.md)中使用此自定义镜像。

<a id="related-topics"></a>

## 相关主题

- [工作区故障排除](workspaces_troubleshooting.md)