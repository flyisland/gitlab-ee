---
stage: Verify
group: tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 Google Cloud Run 组件创建并部署 Web 服务'
---

了解如何使用 [Google Cloud Run 组件](https://gitlab.com/google-gitlab-components/cloud-run)从存储在制品仓库中的容器镜像部署 Web 服务。

<a id="before-you-begin"></a>

## 开始之前

1. 按照[设置 Google Cloud 集成](../set_up_gitlab_google_integration/_index.md)中的说明操作，以：

   - 设置 Google Cloud IAM。
   - 将极狐GitLab 连接到 Google 制品仓库。
   - 设置极狐GitLab Runner，以便在 Google Cloud 上执行 CI/CD 作业。

1. 要运行本页面中的命令，请在以下任一开发环境中设置 `gcloud` CLI：

   - [Cloud Shell](https://docs.cloud.google.com/shell/docs/using-cloud-shell)
   - [本地 shell](https://cloud.google.com/sdk/docs/install)

1. 运行以下命令设置默认的 Google Cloud 项目：

   ```shell
   gcloud config set project PROJECT_ID
   ```

   设置默认项目后，您无需在使用 `gcloud` 命令时传递 `--project` 标志。
1. 启用 Compute Engine 和 Cloud Run API：

   ```shell
   gcloud services enable compute.googleapis.com artifactregistry.googleapis.com run.googleapis.com
   ```

1. 为工作负载身份池授予以下角色：

   - Cloud Storage Admin（`roles/run.admin`），用于获取、创建和更新服务。
   - Service Account users（`roles/iam.serviceAccountUser`），用于以服务账号身份运行操作

   运行以下命令，为工作负载身份池中所有匹配 `developer_access=true` 属性映射的主体授予 `roles/run.admin` 和 `roles/iam.serviceAccountUser` 角色：

   ```shell
   # Replace ${PROJECT_ID}, ${PROJECT_NUMBER}, ${LOCATION}, ${POOL_ID} with your values below
   WORKLOAD_IDENTITY=principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.developer_access/true
   gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="${WORKLOAD_IDENTITY}" --role="roles/run.admin"
   gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="${WORKLOAD_IDENTITY}" --role="roles/iam.serviceAccountUser"
   ```

<a id="configure-the-iam-integration-in-a-new-gitlab-project"></a>

## 在新的极狐GitLab 项目中配置 IAM 集成

为您的组织或群组设置好用于集成的 Google IAM 后，您可以在该组织或群组的新项目中复用该集成：

1. 在您的组织或群组中[创建一个新的极狐GitLab 项目](../../user/project/_index.md)。
1. 在您的极狐GitLab 项目中，选择**设置** > **集成**。
1. 选择 **Google Cloud IAM**。
1. 在 **Google Cloud 项目**部分，输入以下内容：

   - **项目 ID**：您的工作负载身份池对应的 Google Cloud 项目 ID
   - **项目编号**：同一项目的 Google Cloud 项目编号

   要查找 Google Cloud 项目 ID 和编号，请参阅[识别项目](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。

1. 在**工作负载身份联合**部分，输入以下内容：

   - **池 ID**：您为工作负载身份池指定的名称。
   - **提供程序 ID**：您为 OIDC 提供商指定的名称。

   提示：您可以从最初用于设置该集成的极狐GitLab 项目中复制这些值。

1. 选择**保存更改**。不要运行提供的脚本，因为它会创建工作负载身份池，而您已经有一个了。

<a id="configure-the-google-artifact-registry-integration-in-a-new-gitlab-project"></a>

## 在新的极狐GitLab 项目中配置 Google 制品仓库集成

您可以在制品仓库中存储多个容器镜像。要为新的极狐GitLab 项目复用同一制品仓库，请在您的项目中配置 Google Artifact Management 集成。

1. 在您的极狐GitLab 项目中，选择**设置** > **集成**。
1. 选择 **Google 工件管理**
1. 在**仓库**部分，输入以下内容：

   - **Google Cloud 项目 ID**：您要使用的制品仓库的项目 ID
   - **仓库名称**：制品仓库名称
   - **仓库位置**：制品仓库的位置

1. 选择**保存更改**。不要运行提供的脚本，因为您的工作负载身份池已为群组或组织中的极狐GitLab 用户授予了制品仓库 Reader 和 Writer 角色。

<a id="clone-your-gitlab-repository"></a>

## 克隆您的极狐GitLab 代码仓库

要使用 SSH 或 HTTPS 将您的极狐GitLab 代码仓库克隆到工作环境，请按照[将 Git 代码仓库克隆到本地计算机](../../topics/git/clone.md)中的说明操作。

<a id="create-a-dockerfile"></a>

## 创建 Dockerfile

1. 在克隆的代码仓库中，创建一个名为 `Dockerfile`的新文件。
1. 将以下内容复制并粘贴到您的 `Dockerfile`中：

   ```dockerfile
   FROM python:3.12.4

   ARG name

   RUN mkdir web

   RUN cat <<EOF > web/index.html
   <!DOCTYPE html>
   <html>
       <head>
           <title>Home</title>
       </head>
       <body>
           <h1 color="green">Welcome to $name</h1>
       </body>
   </html>
   EOF

   CMD ["python3", "-m", "http.server", "8080", "-d", "web"]
   ```

1. 将您的 `Dockerfile` 添加到 Git，提交并推送到您的极狐GitLab 代码仓库：

   ```shell
   git add Dockerfile
   git commit -m "add dockerfile"
   git push
   ```

   系统会提示您输入用户名和
   [个人访问令牌](../../user/profile/personal_access_tokens.md)。

该 Dockerfile 会创建一个 HTTP Web 服务。

<a id="create-a-pipeline"></a>

## 创建流水线

创建一个流水线，用于构建 Docker 镜像、将其推送到极狐GitLab 容器镜像仓库、将镜像复制到 Google 制品仓库，并使用 Cloud Run 在 Google Cloud 基础设施上部署。

1. 在您的极狐GitLab 项目中，创建一个
   [`.gitlab-ci.yml` 文件](../../ci/quick_start/_index.md#create-a-gitlab-ciyml-file)。
1. 要创建一个流水线来构建镜像、将其推送到极狐GitLab 容器镜像仓库、复制到 Google 制品仓库，并使用 Cloud Run 进行部署，请修改 `.gitlab-ci.yml` 文件的内容，使其与以下内容类似。

   在以下示例中，替换以下内容：

   - `LOCATION`：您创建 Google 制品仓库所在的 Google Cloud 区域。
   - `PROJECT`：您的制品仓库对应的 Google Cloud 项目 ID。
   - `REPOSITORY`：您的 Google 制品仓库 ID。

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

1. 将您的 `.gitlab-ci.yml` 文件添加到 Git，提交并推送到您的极狐GitLab 代码仓库。

该流水线会完成以下操作：

- 使用 Docker-in-Docker 构建镜像 `python-service`。
- 将镜像存储在极狐GitLab 容器镜像仓库中。
- 使用 [Google 制品仓库 GitLab 组件](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry)将镜像推送到 Google 制品仓库。
- 使用 [Google Cloud Run 组件](https://gitlab.com/google-gitlab-components/cloud-run)部署 `python-service`。

<a id="view-your-service-in-google-cloud-run"></a>

## 在 Google Cloud Run 中查看您的服务

1. 在 Google Cloud 控制台中，转到 [Cloud Run 页面](https://console.cloud.google.com/run)。
1. 在**服务**选项卡中选择您创建的服务。

   系统会显示该服务的**指标**选项卡，您可以查看服务区域、URL 和其他详细信息。

<a id="proxy-your-service-to-view"></a>

## 代理您的服务以进行查看

该服务是私有的，因此如果不进行身份验证，您无法通过 Google Cloud 控制台中列出的 URL 查看它。要测试该服务，您可以使用 `gcloud` CLI 进行身份验证，并将该服务代理到 `http://localhost:8080`。

运行以下命令在本地代理您的服务：

```shell
gcloud run services proxy SERVICE \
    --project PROJECT_ID \
    --region=LOCATION
```

您可以在 `http://localhost:8080` 查看欢迎页面。

<a id="clean-up"></a>

## 清理

为避免本页面所用资源对您的 Google Cloud 账号产生费用，您可以删除您的 Google Cloud 资源，或删除整个 Google Cloud 项目。

如果您删除了包含工作负载身份池的项目，除非您重新执行所有设置说明，否则将无法使用该集成。

有关极狐GitLab 和 Google 的定价及项目管理信息，请参阅以下资源：

- [极狐GitLab 定价](https://about.gitlab.com/free-trial/devsecops/)
- [Google 定价](https://cloud.google.com/pricing)
- [删除极狐GitLab 项目](../../user/project/working_with_projects.md#delete-a-project)

<a id="delete-your-google-artifact-registry-repository"></a>

### 删除您的 Google 制品仓库

要删除您的 Google 制品仓库，请按照本节中的步骤操作。如果您想删除整个 Google Cloud 项目，请按照[删除您的项目](#delete-your-google-cloud-project)中的步骤操作。

在移除制品仓库之前，请确保您想保留的任何镜像在另一位置可用。

要删除您的代码仓库，请运行以下命令：

```shell
gcloud artifacts repositories delete REPOSITORY \
    --location=LOCATION
```

替换以下内容：

- 将 `REPOSITORY` 替换为您的 Google 制品仓库 ID
- 将 `LOCATION` 替换为您的制品仓库位置

<a id="delete-your-cloud-run-service"></a>

### 删除您的 Cloud Run 服务

1. 在 Google Cloud 控制台中，转到 [Cloud Run 页面](https://console.cloud.google.com/run)。
1. 选中您的服务旁边的复选框。
1. 选择**删除**。

<a id="delete-your-google-cloud-project"></a>

### 删除您的 Google Cloud 项目

**注意**：删除项目会产生以下影响：

- 项目中的所有内容都会被删除。如果您使用现有项目来完成本文档中的任务，那么删除该项目时，您在该项目中所做的其他工作也会一并删除。
- 自定义项目 ID 会丢失。创建此项目时，您可能创建了希望将来使用的自定义项目 ID。要保留使用项目 ID 的 URL（例如 appspot.com URL），请删除项目内的选定资源，而不是删除整个项目。

如果您计划在 Google Cloud 上探索多个架构、教程或快速入门教程，复用项目有助于避免超出项目配额限制。

1. 在 Google Cloud 控制台中，转到[**管理资源**页面](https://console.cloud.google.com/iam-admin/projects)。
1. 在项目列表中，选择要删除的项目，然后选择**删除**。
1. 在对话框中，输入项目 ID，然后选择**关闭**以删除该项目。
