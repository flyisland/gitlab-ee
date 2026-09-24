---
stage: Verify
group: tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 Google Cloud Run 组件创建和部署 Web 服务'
---

了解如何使用 [Google Cloud Run 组件](https://gitlab.com/google-gitlab-components/cloud-run) 从存储在 Artifact Registry 中的容器镜像部署 Web 服务。

<a id="before-you-begin"></a>

## 开始之前

1. 按照 [设置 Google Cloud 集成](../set_up_gitlab_google_integration/_index.md) 中的说明操作：
   - 设置 Google Cloud IAM。
   - 将极狐GitLab 连接到 Google Artifact Registry。
   - 设置极狐GitLab Runner 以在 Google Cloud 上执行 CI/CD 作业。
1. 要运行本页的命令，请在以下开发环境之一中设置 `gcloud` CLI：
   - [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)
   - [本地 shell](https://cloud.google.com/sdk/docs/install)
1. 通过运行以下命令设置默认 Google Cloud 项目：

   ```shell
   gcloud config set project PROJECT_ID
   ```

   设置默认项目后，无需在 `gcloud` 命令中传递 `--project` 标志。
1. 启用 Compute Engine 和 Cloud Run API：

   ```shell
   gcloud services enable compute.googleapis.com artifactregistry.googleapis.com run.googleapis.com
   ```

1. 为工作负载身份池授予以下角色：
   - Cloud Storage Admin（`roles/run.admin`）用于获取、创建和更新服务。
   - Service Account users（`roles/iam.serviceAccountUser`）用于以服务帐号身份运行操作

   运行以下命令，为工作负载身份池中与 `developer_access=true` 属性映射匹配的所有主体授予 `roles/run.admin` 和 `roles/iam.serviceAccountUser` 角色：

   ```shell
   # 将下面的 ${PROJECT_ID}, ${PROJECT_NUMBER}, ${LOCATION}, ${POOL_ID} 替换为您的值
   WORKLOAD_IDENTITY=principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.developer_access/true
   gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="${WORKLOAD_IDENTITY}" --role="roles/run.admin"
   gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="${WORKLOAD_IDENTITY}" --role="roles/iam.serviceAccountUser"
   ```

<a id="configure-the-iam-integration-in-a-new-gitlab-project"></a>

## 在新极狐GitLab 项目中配置 IAM 集成

为组织或群组设置好集成所需的 Google IAM 后，您可以在该组织或群组的新项目中重用此集成：

1. 在您的组织或群组中[创建一个新的极狐GitLab 项目](../../user/project/_index.md)。
1. 在您的极狐GitLab 项目中，选择 **设置** > **集成**。
1. 选择 **Google Cloud IAM**。
1. 在 **Google Cloud project** 部分，输入以下信息：
   - **Project ID**：工作负载身份池的 Google Cloud 项目 ID
   - **Project number**：同一个项目的 Google Cloud 项目编号

   要查找 Google Cloud 项目 ID 和编号，请参阅[识别项目](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
1. 在 **Workload identity federation** 部分，输入以下信息：
   - **Pool ID**：您为工作负载身份池指定的名称。
   - **Provider ID**：您为 OIDC 提供者指定的名称。

   提示：您可以从最初用于设置集成的极狐GitLab 项目中复制这些值。
1. 选择 **保存更改**。不要运行提供的脚本，因为脚本会创建工作负载身份池，而您已经拥有一个。

<a id="configure-the-google-artifact-registry-integration-in-a-new-gitlab-project"></a>

## 在新极狐GitLab 项目中配置 Google Artifact Registry 集成

您可以在 Artifact Registry 中存储多个容器镜像。要在新极狐GitLab 项目中重用同一个仓库，请在项目中配置 Google Artifact Management 集成。

1. 在您的极狐GitLab 项目中，选择 **设置** > **集成**。
1. 选择 **Google Artifact Management**。
1. 在 **Repository** 部分，输入以下信息：
   - **Google Cloud project ID**：要使用的 Artifact Registry 仓库的项目 ID
   - **Repository name**：仓库名称
   - **Repository location**：仓库位置
1. 选择 **保存更改**。不要运行提供的脚本，因为您的工作负载身份池已经为群组或组织中的极狐GitLab 用户授予了 Artifact Registry Reader 和 Writer 角色。

<a id="clone-your-gitlab-repository"></a>

## 克隆您的极狐GitLab 仓库

要使用 SSH 或 HTTPS 将极狐GitLab 仓库克隆到工作环境，请按照[将 Git 仓库克隆到本地计算机](../../topics/git/clone.md)中的说明操作。

<a id="create-a-dockerfile"></a>

## 创建 Dockerfile

1. 在克隆的仓库中，创建一个名为 `Dockerfile` 的新文件。
1. 将以下内容复制并粘贴到 `Dockerfile` 中：

   ```dockerfile
   FROM python:3.12.4

   ARG name

   RUN mkdir web

   RUN cat <<EOF > web/index.html
   <!DOCTYPE html>
   <html>
       <head>
           <title>首页</title>
       </head>
       <body>
           <h1 color="green">欢迎来到 $name</h1>
       </body>
   </html>
   EOF

   CMD ["python3", "-m", "http.server", "8080", "-d", "web"]
   ```

1. 将 `Dockerfile` 添加到 Git，提交并推送到极狐GitLab 仓库：

   ```shell
   git add Dockerfile
   git commit -m "add dockerfile"
   git push
   ```

   系统会提示您输入用户名和[个人访问令牌](../../user/profile/personal_access_tokens.md)。

该 Dockerfile 创建一个 HTTP Web 服务。

<a id="create-a-pipeline"></a>

## 创建流水线

创建一个流水线，用于构建 Docker 镜像，将其推送到极狐GitLab 容器镜像仓库，将镜像复制到 Google Artifact Registry，并使用 Cloud Run 在 Google Cloud 基础设施上部署。

1. 在您的极狐GitLab 项目中，创建一个 [`.gitlab-ci.yml` 文件](../../ci/quick_start/_index.md#create-a-gitlab-ciyml-file)。
1. 要创建构建镜像、推送到极狐GitLab 容器镜像仓库、复制到 Google Artifact Registry 并使用 Cloud Run 部署的流水线，请将 `.gitlab-ci.yml` 文件的内容修改为类似以下内容。

   在以下示例中，替换以下内容：

   - `LOCATION`：创建 Google Artifact Registry 仓库的 Google Cloud 区域。
   - `PROJECT`：您的 Artifact Registry 仓库的 Google Cloud 项目 ID。
   - `REPOSITORY`：您的 Google Artifact Registry 仓库的仓库 ID。

   ```yaml
   variables:
     IMAGE_TAG: v$CI_PIPELINE_ID
     AR_IMAGE: LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/python-service

   stages:
     - build
     - push
     - deploy

   build-job:
     stage: build
     services:
       - docker:24.0.5-dind
     image: docker:git
     before_script:
       - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
     script:
       - docker build -t $CI_REGISTRY_IMAGE:$IMAGE_TAG --build-arg="name=Cloud Run" .
       - docker push $CI_REGISTRY_IMAGE:$IMAGE_TAG

   include:
     - component: gitlab.com/google-gitlab-components/artifact-registry/upload-artifact-registry@0.1.0
       inputs:
         stage: push
         source: $CI_REGISTRY_IMAGE:$IMAGE_TAG
         target: $AR_IMAGE:$IMAGE_TAG

     - component: gitlab.com/google-gitlab-components/cloud-run/deploy-cloud-run@0.1.0
       inputs:
         stage: deploy
         image: $AR_IMAGE:$IMAGE_TAG
         project_id: PROJECT
         region: LOCATION
         service: python-service
   ```

1. 将 `.gitlab-ci.yml` 文件添加到 Git，提交并推送到极狐GitLab 仓库。

该流水线完成以下任务：

- 使用 Docker-in-Docker 构建镜像 `python-service`。
- 将镜像存储在极狐GitLab 容器镜像仓库中。
- 使用 [Google Artifact Registry 极狐GitLab 组件](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry) 将镜像推送到 Google Artifact Registry。
- 使用 [Google Cloud Run 组件](https://gitlab.com/google-gitlab-components/cloud-run) 部署 `python-service`。

<a id="view-your-service-in-google-cloud-run"></a>

## 在 Google Cloud Run 中查看您的服务

1. 在 Google Cloud Console 中，转到 [Cloud Run 页面](https://console.cloud.google.com/run)。
1. 在 **服务** 选项卡中选择您创建的服务。

   系统将显示服务的 **指标** 选项卡，您可以查看服务区域、URL 和其他详细信息。

<a id="proxy-your-service-to-view"></a>

## 代理服务进行查看

该服务是私有的，因此未经身份验证无法从 Google Cloud Console 中列出的 URL 进行查看。要测试服务，您可以使用 `gcloud` CLI 进行身份验证并将服务代理到 `http://localhost:8080`。

运行以下命令在本地代理服务：

```shell
gcloud run services proxy SERVICE \
    --project PROJECT_ID \
    --region=LOCATION
```

您可以在 `http://localhost:8080` 查看欢迎页面。

<a id="clean-up"></a>

## 清理

为避免因本页使用的资源而产生 Google Cloud 帐户费用，您可以删除 Google Cloud 资源或整个 Google Cloud 项目。

如果删除包含工作负载身份池的项目，则除非重新执行所有设置说明，否则无法使用该集成。

有关极狐GitLab 和 Google 的定价与项目管理的信息，请参阅以下资源：

- [极狐GitLab 定价](https://gitlab.cn/free-trial/devsecops)
- [Google 定价](https://cloud.google.com/pricing)
- [删除极狐GitLab 项目](../../user/project/working_with_projects.md#delete-a-project)

<a id="delete-your-google-artifact-registry-repository"></a>

### 删除您的 Google Artifact Registry 仓库

要删除 Google Artifact Registry 仓库，请按照本节步骤操作。如果要删除整个 Google Cloud 项目，请按照[删除项目](#delete-your-google-cloud-project)中的步骤操作。

在删除仓库之前，确保要保留的任何镜像在其他位置有备份。

要删除仓库，请运行以下命令：

```shell
gcloud artifacts repositories delete REPOSITORY \
    --location=LOCATION
```

替换以下内容：

- `REPOSITORY`：您的 Google Artifact Registry 仓库 ID
- `LOCATION`：仓库的位置

<a id="delete-your-cloud-run-service"></a>

### 删除 Cloud Run 服务

1. 在 Google Cloud Console 中，转到 [Cloud Run 页面](https://console.cloud.google.com/run)。
1. 勾选服务旁边的复选框。
1. 选择 **删除**。

<a id="delete-your-google-cloud-project"></a>

### 删除您的 Google Cloud 项目

**注意**：删除项目会产生以下影响：

- **项目中的所有内容都会被删除**。如果您使用了现有项目执行本文档中的任务，删除项目时也会删除您在项目中完成的所有其他工作。
- **自定义项目 ID 会丢失**。创建此项目时，您可能创建了日后想要使用的自定义项目 ID。要保留使用项目 ID 的 URL（例如 appspot.com URL），请删除项目中的特定资源，而不是删除整个项目。

如果您计划探索 Google Cloud 上的多种架构、教程或快速入门教程，重复使用项目有助于避免超出项目配额限制。

1. 在 Google Cloud 控制台中，转到 [**管理资源** 页面](https://console.cloud.google.com/iam-admin/projects)。
1. 在项目列表中，选择要删除的项目，然后选择 **删除**。
1. 在对话框中，输入项目 ID，然后选择 **关闭** 以删除项目。

<a id="related-topics"></a>

## 相关主题

- [了解有关 Cloud Run 的更多信息](https://cloud.google.com/run/docs/overview/what-is-cloud-run)。