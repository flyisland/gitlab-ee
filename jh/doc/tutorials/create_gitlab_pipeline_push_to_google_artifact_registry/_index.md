---
stage: Verify
group: tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：创建极狐GitLab 流水线以推送到 Google 制品仓库'
---

了解如何将极狐GitLab 连接到 Google Cloud，并使用 Compute Engine 上的 Runner 创建极狐GitLab 流水线，以将镜像推送到制品仓库。

<a id="before-you-begin"></a>

## 开始之前

1. 要运行本页面中的命令，请在以下任一开发环境中设置 `gcloud` CLI：

   - [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)
   - [本地 Shell](https://cloud.google.com/sdk/docs/install)

1. 创建或选择一个 Google Cloud 项目。

   > [!note]
   > 如果您不打算保留此过程中创建的资源，请创建新的 Google Cloud 项目，而不要选择现有项目。完成这些步骤后，您可以删除该项目，从而移除与该项目的所有关联资源。

   要创建 Google Cloud 项目，请运行以下命令：

   ```shell
   gcloud projects create PROJECT_ID
   ```

   将 `PROJECT_ID` 替换为您要创建的 Google Cloud 项目的名称。
1. 选择您创建的 Google Cloud 项目：

   ```shell
   gcloud config set project PROJECT_ID
   ```

   将 `PROJECT_ID` 替换为您的 Google Cloud 项目名称。
1. [确保您的 Google Cloud 项目已启用结算功能](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled#console)。
1. 启用 Compute Engine 和制品仓库 API：

   ```shell
   gcloud services enable compute.googleapis.com artifactregistry.googleapis.com
   ```

1. 按照
   [Google Cloud 工作负载身份联合和 IAM 策略](../../integration/google_cloud_iam.md)中的说明，
   设置 Google Cloud 上的极狐GitLab 集成。
1. [创建标准模式 Docker 格式的制品仓库](https://cloud.google.com/artifact-registry/docs/repositories/create-repos#create)。
1. 按照
   [在极狐GitLab 项目中设置 Google 制品仓库](../../user/project/integrations/google_artifact_management.md)中的说明，
   将您的制品仓库连接到您的极狐GitLab 项目。

<a id="clone-your-gitlab-repository"></a>

## 克隆您的极狐GitLab 代码仓库

1. 要使用 SSH 或
   HTTPS 将您的极狐GitLab 代码仓库克隆到您的工作环境，请按照
   [将 Git 代码仓库克隆到本地计算机](../../topics/git/clone.md)中的说明操作。
1. 如果您在本地 Shell 中工作，请
   [安装 Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)。Cloud Shell 中已安装 Terraform。

<a id="create-a-dockerfile"></a>

## 创建 Dockerfile

1. 在您克隆的代码仓库中，创建一个名为 `Dockerfile`的新文件。
1. 将以下内容复制并粘贴到您的 `Dockerfile`中。

   ```dockerfile
   # Dockerfile for test purposes. Generates a new random image in every build.
   FROM alpine:3.15.11
   RUN dd if=/dev/urandom of=random bs=10 count=1
   ```

1. 将您的 `Dockerfile` 添加到 Git，提交并推送到您的极狐GitLab 代码仓库。

   ```shell
   git add Dockerfile
   git commit -m "add dockerfile"
   git push
   ```

   系统会提示您输入用户名和
   [个人访问令牌](../../user/profile/personal_access_tokens.md)。

该 Dockerfile 会为每次构建生成一个新的随机镜像，仅用于测试目的。

<a id="enable-continuous-integration-ci-runners-on-google-compute-engine"></a>

## 在 Google Compute Engine 上启用持续集成（CI）Runner

[极狐GitLab Runner](https://gitlab.cn/docs/runner/) 是一个与极狐GitLab CI/CD 配合使用的应用程序，
用于在流水线中运行作业。Google Cloud 上的极狐GitLab 集成可帮助您在 Compute Engine 上设置
自动扩缩的 Runner 集群，其中的 Runner 管理器会创建临时 Runner 以同时执行多个作业。

要设置自动扩缩的 Runner 集群，请按照
[设置极狐GitLab Runner 以在 Google Cloud 上执行您的 CI/CD 作业](../set_up_gitlab_google_integration/_index.md#set-up-gitlab-runner-to-execute-your-cicd-jobs-on-google-cloud)中的说明操作。
选择 Google Cloud 作为您希望 Runner 执行 CI/CD 作业的环境，并填写其余配置详情。

输入 Runner 的详细信息后，您可以按照设置说明配置您的 Google Cloud 项目、安装并注册极狐GitLab Runner，并在您的工作环境中应用提供的 Terraform 以应用该配置。

<a id="create-a-pipeline"></a>

## 创建流水线

创建一个流水线，用于构建您的 Docker 镜像、将其推送到极狐GitLab 容器镜像仓库，并将该镜像复制到 Google 制品仓库。

1. 在您的极狐GitLab 项目中，创建一个
   [`.gitlab-ci.yml` 文件](../../ci/quick_start/_index.md#create-a-gitlab-ciyml-file)。
1. 要创建一个流水线，用于构建您的镜像、将其推送到极狐GitLab 容器镜像仓库，
   并将其复制到 Google 制品仓库，请修改您的
   `.gitlab-ci.yml` 文件内容，使其与以下内容类似。

   在示例中，替换以下内容：

   - `LOCATION`：您创建 Google 制品仓库所在的
     Google Cloud 区域。
   - `PROJECT`：您的
     Google Cloud 项目 ID。
   - `REPOSITORY`：您的 Google 制品仓库的
     仓库 ID。

   ```yaml
   stages:
     - build
     - deploy

   variables:
     GITLAB_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

   build-sample-image:
     image: docker:24.0.5-cli
     stage: build
     services:
       - docker:24.0.5-dind
     before_script:
       - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
     script:
       - docker build -t $GITLAB_IMAGE .
       - docker push $GITLAB_IMAGE

   include:
     - component: gitlab.com/google-gitlab-components/artifact-registry/upload-artifact-registry@0.1.0
       inputs:
         stage: deploy
         source: $GITLAB_IMAGE
         target: LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/image:v1.0.0
   ```

该流水线使用 Docker in Docker 构建镜像 `docker:24.0.5`，将其
存储在极狐GitLab 容器镜像仓库中，然后使用
[Google 制品仓库 GitLab 组件](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry)
将其以版本 `v1.0.0` 推送到您的 Google 制品仓库。

<a id="view-your-artifacts"></a>

## 查看您的产物

要在极狐GitLab 中查看您的产物：

1. 在您的极狐GitLab 项目中，在左侧边栏中，选择
   **构建** > **产物**。
1. 选择产物的名称以查看构建的详细信息。

要在 Google 制品仓库中查看您的产物：

1. [在 Google Cloud 控制台中打开**仓库**页面](https://console.cloud.google.com/artifacts)。
1. 选择您所链接仓库的名称。
1. 选择镜像的名称以查看版本名称和标签。
1. 选择镜像版本的名称以查看该版本的构建、拉取和
   清单信息。

<a id="clean-up"></a>

## 清理

为避免本页面所用资源向您的 Google Cloud 账号产生费用，您可以删除您的 Google Cloud 项目。如果您想保留项目，可以删除您的 Google 制品仓库。

有关极狐GitLab 和 Google 制品仓库的定价和项目管理信息，请参阅以下资源：

- [极狐GitLab 定价](https://about.gitlab.com/free-trial/devsecops)
- [删除极狐GitLab 项目](../../user/project/working_with_projects.md#delete-a-project)
- [Google 制品仓库定价](https://cloud.google.com/artifact-registry/pricing)

<a id="delete-your-google-artifact-registry-repository"></a>

### 删除您的 Google 制品仓库

如果您想保留您的 Google Cloud 项目，仅删除 Google 制品仓库资源，请按照本节中的步骤操作。如果您想删除
整个 Google Cloud 项目，请按照
[删除您的项目](#delete-your-google-cloud-project)中的步骤操作。

在移除仓库之前，请确保您想保留的任何镜像在其他位置可用。

要删除您的仓库，请运行以下命令：

```shell
gcloud artifacts repositories delete REPOSITORY \
    --location=LOCATION
```

替换以下内容：

- 将 `REPOSITORY` 替换为您的 Google 制品仓库 ID
- 将 `LOCATION` 替换为您仓库的位置

<a id="delete-your-google-cloud-project"></a>

### 删除您的 Google Cloud 项目

**警告**：删除项目会产生以下影响：

- 项目中的所有内容都会被删除。如果您将现有项目用于本文档中的任务，当
  您删除它时，也会删除您在该项目中所做的任何其他工作。
- 自定义项目 ID 会丢失。创建此项目时，您可能创建了一个希望
  将来使用的自定义项目 ID。要保留使用项目 ID 的 URL（例如 appspot.com URL），请改为删除项目内的选定
  资源，而不是删除整个项目。

如果您计划在 Google Cloud 上探索多个架构、教程或快速入门教程，复用项目可以帮助您避免超出项目配额限制。

1. 在 Google Cloud 控制台中，转到 [**管理资源**页面](https://console.cloud.google.com/iam-admin/projects)。
1. 在项目列表中，选择您要删除的项目，然后选择**删除**。
1. 在对话框中，输入项目 ID，然后选择**关闭**以删除该项目。
