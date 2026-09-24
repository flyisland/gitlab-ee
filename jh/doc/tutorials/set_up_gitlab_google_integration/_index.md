---
stage: Verify
group: Tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：设置 Google Cloud 集成'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程向您展示如何将 Google Cloud 与 极狐GitLab 集成，以便您可以直接部署到 Google Cloud。

要设置 Google Cloud 集成：

1. [使用 Google Cloud Identity and Access Management (IAM) 保护您的使用](#secure-your-usage-with-google-cloud-identity-and-access-management-iam)
1. [连接到 Google Artifact Registry 仓库](#connect-to-a-google-artifact-registry-repository)
1. [设置 GitLab Runner 以在 Google Cloud 上执行您的 CI/CD 作业](#set-up-gitlab-runner-to-execute-your-cicd-jobs-on-google-cloud)
1. [使用 CI/CD 组件部署到 Google Cloud](#deploy-to-google-cloud-with-cicd-components)

<a id="before-you-begin"></a>

## 开始之前

要设置此集成，您必须：

- 拥有一个 极狐GitLab 项目，且您在该项目中具有维护者或所有者角色。
- 在您要使用的 Google Cloud 项目上拥有 [所有者](https://cloud.google.com/iam/docs/understanding-roles#owner) IAM 角色。
- 已为您的 Google Cloud 项目 [启用付费](https://cloud.google.com/billing/docs/how-to/verify-billing-enabled#confirm_billing_is_enabled_on_a_project)。
- 拥有一个采用 Docker 格式和标准模式的 Google Artifact Registry 仓库。
- 安装 [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) 和 [Terraform](https://developer.hashicorp.com/terraform/install)。

<a id="secure-your-usage-with-google-cloud-identity-and-access-management-iam"></a>

## 使用 Google Cloud Identity and Access Management (IAM) 保护您的使用

为了保护您对 Google Cloud 的使用，您必须设置 Google Cloud IAM 集成。
完成此步骤后，您的 极狐GitLab 群组或项目将连接到 Google Cloud。您可以使用工作负载身份联合来管理 Google Cloud 资源的权限，而无需服务账号密钥及其相关风险。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。如果您在群组级别进行配置，设置将默认应用于其中的所有项目。
1. 选择 **设置** > **集成**。
1. 选择 **Google Cloud IAM**。
1. 选择 **引导式设置** 并按照说明操作。

<a id="connect-to-a-google-artifact-registry-repository"></a>

## 连接到 Google Artifact Registry 仓库

现在 Google IAM 集成已设置完毕，您可以连接到 Google Artifact Registry 仓库。
完成此步骤后，您可以在 极狐GitLab 中查看您的 Google Cloud 产物。

1. 在您的 极狐GitLab 项目中，在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Google Artifact Registry**。
1. 在 **启用集成** 下，选择 **启用** 复选框。
1. 填写以下字段：
   - **[Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)**：
     您的 Artifact Registry 仓库所在的 Google Cloud 项目的 ID。
   - **仓库名称**：您的 Artifact Registry 仓库的名称。
   - **仓库位置**：您的 Artifact Registry 仓库的位置。
1. 在 **配置 Google Cloud IAM 策略** 中，按照屏幕上的说明在 Google Cloud 中设置 IAM 策略。要在您的 极狐GitLab 项目中使用 Artifact Registry 仓库，需要这些策略。
1. 选择 **保存更改**。
1. 要查看您的 Google Cloud 产物，在左侧边栏中，选择 **部署** > **Google Artifact Registry**。

在稍后的步骤中，您将把容器镜像推送到 Google Artifact Registry。

<a id="set-up-gitlab-runner-to-execute-your-cicd-jobs-on-google-cloud"></a>

## 设置 GitLab Runner 以在 Google Cloud 上执行您的 CI/CD 作业

您可以设置 GitLab Runner 以在 Google Cloud 上运行 CI/CD 作业。
完成此步骤后，您的 极狐GitLab 项目将拥有一个可自动伸缩的 Runner 队列，其中一个 Runner 管理器会创建临时 Runner 以同时执行多个作业。

1. 在您的 极狐GitLab 项目中，在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **Runners** 部分。
1. 选择 **新建项目 Runner**。
1. 填写字段。
   - 在 **平台** 部分，选择 **Google Cloud**。
   - 在 **标签** 部分，在 **标签** 字段中输入作业标签，以指定 Runner 可以运行的作业。如果此 Runner 没有作业标签，请选择 **运行未标记的作业**。
   - 可选。在 **Runner 描述** 字段中，添加在 极狐GitLab 中显示的 Runner 描述。
   - 可选。在 **配置** 部分，添加其他配置。
1. 选择 **创建 Runner**。
1. 在 **第 1 步：指定环境** 部分中填写字段，以指定在 Google Cloud 中 Runner 执行 CI/CD 作业的环境。
1. 在 **第 2 步：设置 GitLab Runner** 下，选择 **设置说明**。
1. 按照模态框中的说明操作。您只需对 Google Cloud 项目执行一次 **第 1 步**，以便其准备好配置 Runner。

按照说明操作后，您的 Runner 可能需要一分钟才能上线并准备好运行作业。

<a id="deploy-to-google-cloud-with-cicd-components"></a>

## 使用 CI/CD 组件部署到 Google Cloud

开发的最佳实践是重用语法，例如使用 CI/CD 组件在整个流水线中保持一致性。

您可以使用来自 极狐GitLab 和 Google 的组件库，使您的 极狐GitLab 项目与 Google Cloud 资源交互。
请参阅 [来自 Google 的 CI/CD 组件](https://gitlab.com/google-gitlab-components)。

### 将容器镜像复制到 Google Artifact Registry

在开始之前，您必须拥有一个可正常工作的 CI/CD 配置，该配置可构建容器镜像并将其推送到您的 极狐GitLab 容器镜像仓库。

要将容器镜像从您的 极狐GitLab 容器镜像仓库复制到 Google Artifact Registry，
请在您的流水线中包含 [来自 Google 的 CI/CD 组件](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry)。
完成此步骤后，每当新的容器镜像推送到您的 极狐GitLab 容器镜像仓库时，它也会同时推送到您的 Google Artifact Registry。

1. 在您的 极狐GitLab 项目中，在左侧边栏中，选择 **构建** > **流水线编辑器**。
1. 在现有配置中，按如下方式添加组件。
   - 将 `<your_stage>` 替换为此作业运行的阶段。它必须位于镜像构建并推送到 极狐GitLab 容器镜像仓库之后。

   ```yaml
   include:
     - component: gitlab.com/google-gitlab-components/artifact-registry/upload-artifact-registry@main
       inputs:
         stage: <your_stage>
         source: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
         target: $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/$CI_PROJECT_NAME:$CI_COMMIT_SHORT_SHA
   ```

1. 添加描述性的提交消息。**目标分支** 必须是您的默认分支。
1. 选择 **提交更改**。
1. 转到 **构建** > **流水线** 并确保新的流水线运行。
1. 流水线成功完成后，要查看已复制到 Google Artifact Registry 的容器镜像，在左侧边栏中，选择 **部署** > **Google Artifact Registry**。

### 创建 Google Cloud Deploy 发布版本

要将您的流水线与 Google Cloud Deploy 集成，请在您的流水线中包含 [来自 Google 的 CI/CD 组件](https://gitlab.com/explore/catalog/google-gitlab-components/cloud-deploy)。
完成此步骤后，您的流水线会为您的应用程序创建一个 Google Cloud Deploy 发布版本。

1. 在您的 极狐GitLab 项目中，在左侧边栏中，选择 **构建** > **流水线编辑器**。
1. 在现有配置中，添加 [Google Cloud Deploy 组件](https://gitlab.com/explore/catalog/google-gitlab-components/cloud-deploy)。
1. 编辑组件 `inputs`。
1. 添加描述性的提交消息。**目标分支** 必须是您的默认分支。
1. 选择 **提交更改**。
1. 转到 **构建** > **流水线** 并确保新的流水线通过。
1. 流水线成功完成后，要查看发布版本，请参阅 [Google Cloud 文档](https://cloud.google.com/deploy/docs/view-release)。

就这样！您现在已经将 Google Cloud 与 极狐GitLab 集成，并且您的 极狐GitLab 项目可以无缝部署到 Google Cloud。