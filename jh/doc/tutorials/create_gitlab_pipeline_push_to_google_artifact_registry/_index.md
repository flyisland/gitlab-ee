---
stage: Verify
group: tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：创建极狐GitLab 流水线以推送至 Google Artifact Registry'
---

<a id="before-you-begin"></a>

## 准备工作

1. 要运行本页的命令，请在以下开发环境中之一设置 `gcloud` CLI：

   - [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)
   - [本地 shell](https://cloud.google.com/sdk/docs/install)

1. 创建或选择一个 Google Cloud 项目。

   > [!note]
   > 如果您不打算保留在此过程中创建的资源，请创建一个新的 Google Cloud 项目，而不是选择现有项目。完成这些步骤后，您可以删除该项目，同时删除与该项目关联的所有资源。

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
1. [确保已为您的 Google Cloud 项目启用结算功能](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled#console)。
1. 启用 Compute Engine 和 Artifact Registry API：

   ```shell
   gcloud services enable compute.googleapis.com artifactregistry.googleapis.com
   ```

1. 按照 [Google Cloud Workload Identity Federation 和 IAM 策略](../../integration/google_cloud_iam.md) 中的说明设置极狐GitLab 与 Google Cloud 的集成。
1. [创建一个标准模式的 Docker 格式 Artifact Registry 仓库](https://cloud.google.com/artifact-registry/docs/repositories/create-repos#create)。
1. 按照 [在极狐GitLab 项目中设置 Google Artifact Registry](../../user/project/integrations/google_artifact_management.md) 中的说明，将您的 Artifact Registry 仓库连接到极狐GitLab 项目。

<a id="clone-your-gitlab-repository"></a>

## 克隆极狐GitLab 仓库

1. 要使用 SSH 或 HTTPS 将极狐GitLab 仓库克隆到您的工作环境，请按照 [将 Git 仓库克隆到本地计算机](../../topics/git/clone.md) 中的说明操作。
1. 如果您在本地 shell 中工作，请 [安装 Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)。Terraform 已安装在 Cloud Shell 中。

<a id="create-a-dockerfile"></a>

## 创建 Dockerfile

1. 在克隆的仓库中，创建一个名为 `Dockerfile` 的新文件。
1. 将以下内容复制并粘贴到您的 `Dockerfile` 中。

   ```dockerfile
   # Dockerfile for test purposes. Generates a new random image in every build.
   FROM alpine:3.15.11
   RUN dd if=/dev/urandom of=random bs=10 count=1
   ```

1. 将您的 `Dockerfile` 添加到 Git，提交并推送到极狐GitLab 仓库。

   ```shell
   git add Dockerfile
   git commit -m "add dockerfile"
   git push
   ```

   系统会提示您输入用户名和 [个人访问令牌](../../user/profile/personal_access_tokens.md)。

此 Dockerfile 每次构建都会生成一个新的随机镜像，仅用于测试目的。

<a id="enable-continuous-integration-ci-runners-on-google-compute-engine"></a>

## 在 Google Compute Engine 上启用持续集成（CI）runner

[极狐GitLab Runner](https://gitlab.cn/docs/runner) 是一个与极狐GitLab CI/CD 配合使用的应用程序，用于在流水线中运行作业。极狐GitLab 与 Google Cloud 的集成可帮助您在 Compute Engine 上设置一个自动伸缩的 runner 机群，其中包含一个 runner 管理器，该管理器会创建临时 runner 以同时执行多个作业。

要设置自动伸缩的 runner 机群，请按照 [设置极狐GitLab Runner 以在 Google Cloud 上执行您的 CI/CD 作业](../set_up_gitlab_google_integration/_index.md#set-up-gitlab-runner-to-execute-your-cicd-jobs-on-google-cloud) 中的说明操作。选择 Google Cloud 作为您希望 runner 执行 CI/CD 作业的环境，并填写其余的配置详细信息。

输入 runner 的详细信息后，您可以按照设置说明来配置您的 Google Cloud 项目，安装并注册极狐GitLab Runner，然后在您的工作环境中应用提供的 Terraform 配置以应用配置。

<a id="create-a-pipeline"></a>

## 创建流水线

创建一个流水线，用于构建 Docker 镜像，将其推送到极狐GitLab 容器镜像仓库，并将该镜像复制到 Google Artifact Registry。

1. 在您的极狐GitLab 项目中，创建一个 [`.gitlab-ci.yml` 文件](../../ci/quick_start/_index.md#create-a-gitlab-ciyml-file)。
1. 要创建一个能够构建镜像、将其推送到极狐GitLab 容器镜像仓库并将其复制到 Google Artifact Registry 的流水线，请将 `.gitlab-ci.yml` 文件的内容修改为类似以下内容。

   在示例中，替换以下内容：

   - `LOCATION`：您创建 Google Artifact Registry 仓库所在的 Google Cloud 区域。
   - `PROJECT`：您的 Google Cloud 项目 ID。
   - `REPOSITORY`：您的 Google Artifact Registry 仓库的仓库 ID。

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

此流水线使用 Docker-in-Docker 构建 `docker:24.0.5` 镜像，将其存储在极狐GitLab 容器镜像仓库中，然后使用 [Google Artifact Registry 极狐GitLab 组件](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry) 将其以版本 `v1.0.0` 推送到您的 Google Artifact Registry 仓库。

<a id="view-your-artifacts"></a>

## 查看产物

要在极狐GitLab 中查看产物：

1. 在您的极狐GitLab 项目中，在左侧边栏中，选择 **构建** > **产物**。
1. 选择产物名称以查看构建的详细信息。

要在 Google Artifact Registry 中查看产物：

1. [在 Google Cloud 控制台中打开 **仓库** 页面](https://console.cloud.google.com/artifacts)。
1. 选择您关联仓库的名称。
1. 选择镜像名称以查看版本名称和标签。
1. 选择镜像版本名称以查看该版本的构建、拉取和清单信息。

<a id="clean-up"></a>

## 清理

为避免因使用本页中使用的资源而产生 Google Cloud 账户费用，您可以删除您的 Google Cloud 项目。如果您想保留项目，可以删除您的 Google Artifact Registry 仓库。

有关极狐GitLab 和 Google Artifact Registry 定价及项目管理的信息，请参阅以下资源：

- [极狐GitLab 定价](https://gitlab.cn/free-trial/devsecops)
- [删除极狐GitLab 项目](../../user/project/working_with_projects.md#delete-a-project)
- [Google Artifact Registry 定价](https://cloud.google.com/artifact-registry/pricing)

<a id="delete-your-google-artifact-registry-repository"></a>

### 删除 Google Artifact Registry 仓库

如果您想保留 Google Cloud 项目而仅删除 Google Artifact Registry 仓库资源，请按照本节中的步骤操作。如果您想删除整个 Google Cloud 项目，请按照 [删除项目](#delete-your-google-cloud-project) 中的步骤操作。

在删除仓库之前，请确保您要保留的任何镜像在其他位置可用。

要删除仓库，请运行以下命令：

```shell
gcloud artifacts repositories delete REPOSITORY \
    --location=LOCATION
```

替换以下内容：

- 将 `REPOSITORY` 替换为您的 Google Artifact Registry 仓库 ID
- 将 `LOCATION` 替换为您的仓库所在位置

<a id="delete-your-google-cloud-project"></a>

### 删除 Google Cloud 项目

**警告**：删除项目会产生以下影响：

- **项目中的所有内容都将被删除**。如果您为此文档中的任务使用了现有项目，则删除该项目时，也会删除您在该项目中所做的任何其他工作。
- **自定义项目 ID 将丢失**。创建此项目时，您可能创建了一个将来想使用的自定义项目 ID。为了保留使用该项目 ID 的 URL，例如 appspot.com URL，请删除项目内的选定资源，而不是删除整个项目。

如果您计划在 Google Cloud 上探索多种架构、教程或快速入门教程，重复使用项目可以帮助您避免超出项目配额限制。

1. 在 Google Cloud 控制台中，转到 [**管理资源** 页面](https://console.cloud.google.com/iam-admin/projects)。
1. 在项目列表中，选择要删除的项目，然后选择 **删除**。
1. 在对话框中，输入项目 ID，然后选择 **关闭** 以删除项目。

