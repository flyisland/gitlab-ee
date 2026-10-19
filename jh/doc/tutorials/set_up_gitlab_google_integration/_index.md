---
stage: Verify
group: Tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：设置 Google Cloud 集成'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程介绍如何将 Google Cloud 与极狐GitLab 集成，
以便您可以直接部署到 Google Cloud。

要设置 Google Cloud 集成：

1. [使用 Google Cloud Identity and Access Management (IAM) 保护您的使用](#secure-your-usage-with-google-cloud-identity-and-access-management-iam)
1. [连接到 Google 制品仓库](#connect-to-a-google-artifact-registry-repository)
1. [设置极狐GitLab Runner 以在 Google Cloud 上执行 CI/CD 作业](#set-up-gitlab-runner-to-execute-your-cicd-jobs-on-google-cloud)
1. [使用 CI/CD 组件部署到 Google Cloud](#deploy-to-google-cloud-with-cicd-components)

<a id="before-you-begin"></a>

## 开始之前

要设置该集成，您必须：

- 拥有一个您在其中具有维护者或所有者角色的极狐GitLab 项目。
- 在您要使用的 Google Cloud 项目上拥有 [Owner](https://cloud.google.com/iam/docs/understanding-roles#owner) IAM 角色。
- [为您的 Google Cloud 项目启用结算](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled#confirm_billing_is_enabled_on_a_project)。
- 拥有一个 Docker 格式、标准模式的 Google 制品仓库。
- 安装 [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
  和 [Terraform](https://developer.hashicorp.com/terraform/install)。

<a id="secure-your-usage-with-google-cloud-identity-and-access-management-iam"></a>

## 使用 Google Cloud Identity and Access Management (IAM) 保护您的使用

要保护您对 Google Cloud 的使用，您必须设置 Google Cloud IAM 集成。
完成此步骤后，您的极狐GitLab 群组或项目即连接到 Google Cloud。您可以借助工作负载身份联合，管理 Google Cloud 资源的权限，而无需服务账号密钥及其相关风险。

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组或项目。如果在群组上配置此项，设置默认应用于该群组内的所有项目。
1. 选择**设置** > **集成**。
1. 选择 **Google Cloud IAM**。
1. 选择**引导式设置**并按照说明操作。

<a id="connect-to-a-google-artifact-registry-repository"></a>

## 连接到 Google 制品仓库

现在 Google IAM 集成已设置完成，您可以连接到 Google 制品仓库。完成此步骤后，您可以在极狐GitLab 中查看您的 Google Cloud 产物。

1. 在您的极狐GitLab 项目中，在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Google 制品仓库**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 填写以下字段：
   - **[Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)**：
     您的制品仓库所在的 Google Cloud 项目的 ID。
   - **仓库名称**：您的制品仓库的名称。
   - **仓库位置**：您的制品仓库的位置。
1. 在**配置 Google Cloud IAM 策略**中，按照屏幕上的说明
   在 Google Cloud 中设置 IAM 策略。在您的极狐GitLab 项目中使用
   制品仓库需要这些策略。
1. 选择**保存更改**。
1. 要查看您的 Google Cloud 产物，请在左侧边栏中，
   选择**部署** > **Google 制品仓库**。

在后续步骤中，您将把容器镜像推送到 Google 制品仓库。

<a id="set-up-gitlab-runner-to-execute-your-cicd-jobs-on-google-cloud"></a>

## 设置极狐GitLab Runner 以在 Google Cloud 上执行 CI/CD 作业

您可以设置极狐GitLab Runner 以在 Google Cloud 上运行 CI/CD 作业。
完成此步骤后，您的极狐GitLab 项目将拥有一个自动扩缩的 Runner 集群，其中包含一个 Runner 管理器，它会创建临时 Runner 以同时执行多个作业。

1. 在您的极狐GitLab 项目中，在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Runner** 部分。
1. 选择**新建项目 Runner**。
1. 填写以下字段。
   - 在**平台**部分，选择 **Google Cloud**。
   - 在**标签**部分，在**标签**字段中，输入作业标签以指定该 Runner 可以运行的作业。
     如果此 Runner 没有作业标签，请选择**运行未打标签的作业**。
   - 可选。在 **Runner 描述**字段中，添加将在极狐GitLab 中显示的
     Runner 描述。
   - 可选。在**配置**部分，添加其他配置。
1. 选择**创建 Runner**。
1. 填写**第 1 步：指定环境**部分中的字段，以指定 Runner 在
   Google Cloud 中执行 CI/CD 作业的环境。
1. 在**第 2 步：设置极狐GitLab Runner** 下，选择**设置说明**。
1. 按照模态窗口中的说明操作。您只需为 Google Cloud 项目执行一次**第 1 步**，即可准备好预配 Runner。

按照说明操作后，您的 Runner 可能需要一分钟才能上线并准备好运行作业。

<a id="deploy-to-google-cloud-with-cicd-components"></a>

## 使用 CI/CD 组件部署到 Google Cloud

开发的一项最佳实践是复用语法，例如使用 CI/CD 组件来保持您的流水线的一致性。

您可以使用来自 GitLab 和 Google 的组件库，让您的极狐GitLab 项目
与 Google Cloud 资源交互。
请参阅[来自 Google 的 CI/CD 组件](https://gitlab.com/google-gitlab-components)。

<a id="copy-container-images-to-google-artifact-registry"></a>

### 将容器镜像复制到 Google 制品仓库

开始之前，您必须拥有一个可正常工作的 CI/CD 配置，用于构建容器镜像并将其推送到您的极狐GitLab 容器镜像仓库。

要将容器镜像从您的极狐GitLab 容器镜像仓库复制到您的 Google 制品仓库，请在您的流水线中包含[来自 Google 的 CI/CD 组件](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry)。完成此步骤后，每当有新的容器镜像被推送到您的极狐GitLab 容器镜像仓库时，它也会被推送到您的 Google 制品仓库。

1. 在您的极狐GitLab 项目中，在左侧边栏中，选择**构建** > **流水线编辑器**。
1. 在现有配置中，按如下方式添加该组件。
   - 将 `<your_stage>` 替换为该作业运行的阶段。
     它必须位于镜像构建并推送到极狐GitLab 容器镜像仓库之后。

   ```yaml
   include:
     - component: gitlab.com/google-gitlab-components/artifact-registry/upload-artifact-registry@main
       inputs:
         stage: <your_stage>
         source: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
         target: $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/$CI_PROJECT_NAME:$CI_COMMIT_SHORT_SHA
   ```

1. 添加描述性的提交信息。**目标分支**必须是您的默认分支。
1. 选择**提交更改**。
1. 转到**构建** > **流水线**，并确认有新的流水线运行。
1. 在流水线成功完成后，要查看已复制到 Google 制品仓库的容器镜像，
   请在左侧边栏中，选择**部署** > **Google 制品仓库**。

<a id="create-a-google-cloud-deploy-release"></a>

### 创建 Google Cloud Deploy 发布

要将您的流水线与 Google Cloud Deploy 集成，请在您的流水线中包含[来自 Google 的 CI/CD 组件](https://gitlab.com/explore/catalog/google-gitlab-components/cloud-deploy)。
完成此步骤后，您的流水线将使用您的应用程序创建 Google Cloud Deploy 发布。

1. 在您的极狐GitLab 项目中，在左侧边栏中，选择**构建** > **流水线编辑器**。
1. 在现有配置中，添加 [Google Cloud Deploy 组件](https://gitlab.com/explore/catalog/google-gitlab-components/cloud-deploy)。
1. 编辑该组件的 `inputs`。
1. 添加描述性的提交信息。**目标分支**必须是您的默认分支。
1. 选择**提交更改**。
1. 转到**构建** > **流水线**，并确认有新的流水线通过。
1. 在流水线成功完成后，要查看该发布，
   请参阅 [Google Cloud 文档](https://docs.cloud.google.com/deploy/docs/view-release)。

就是这样！您现在已经将 Google Cloud 与极狐GitLab 集成，您的极狐GitLab 项目可以无缝
部署到 Google Cloud。
