---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google 工件管理
description: 将 Google 制品仓库连接到您的极狐GitLab 项目，以查看、推送和拉取 Docker 和 OCI 镜像。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

您可以使用 Google 工件管理集成，将 [Google 制品仓库](https://docs.cloud.google.com/artifact-registry/docs)中的仓库配置并连接到您的极狐GitLab 项目。

将 Google 制品仓库连接到项目后，您可以在 [Google 制品仓库](https://docs.cloud.google.com/artifact-registry/docs)中的仓库中查看、推送和拉取 Docker 和 [OCI](https://opencontainers.org/) 镜像。

<a id="set-up-the-google-artifact-registry-in-a-gitlab-project"></a>

## 在极狐GitLab 项目中设置 Google 制品仓库

先决条件：

- 您必须拥有该极狐GitLab 项目的维护者或所有者角色。
- 您必须拥有[所需权限](https://cloud.google.com/iam/docs/granting-changing-revoking-access#required-permissions)，以管理对包含该制品仓库中的仓库的 Google Cloud 项目的访问权限。
- 必须配置[工作负载身份联合](../../../integration/google_cloud_iam.md)（WLIF）池和提供商，以便向 Google Cloud 进行身份验证。
- 一个具有以下配置的 [Google 制品仓库中的仓库](https://docs.cloud.google.com/artifact-registry/docs/repositories)：
  - [Docker](https://docs.cloud.google.com/artifact-registry/docs/supported-formats) 格式。
  - [Standard](https://docs.cloud.google.com/artifact-registry/docs/repositories/create-repos) 模式。不支持其他仓库格式和模式。

要将 Google 制品仓库中的仓库连接到极狐GitLab 项目：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Google 工件管理**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 填写以下字段：
   - **Google Cloud 项目 ID**：在制品仓库中，该仓库所属的 [Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
   - **仓库名称**：该仓库在制品仓库中的名称。
   - **仓库位置**：该仓库在制品仓库中的 [Google Cloud 位置](https://cloud.google.com/about/locations)。
1. 按照屏幕上的说明设置 Google Cloud Identity and Access Management (IAM) 策略。有关策略类型的更多信息，请参见 [IAM 策略](#iam-policies)。
1. 选择**保存更改**。

现在，您应该会在边栏的**部署**下看到 **Google 制品仓库**条目。

<a id="view-images-stored-in-the-google-artifact-registry"></a>

## 查看存储在 Google 制品仓库中的镜像

先决条件：

- 必须在项目中[配置](#set-up-the-google-artifact-registry-in-a-gitlab-project) Google 制品仓库。

要在极狐GitLab UI 中查看制品仓库中已连接仓库的镜像列表：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **Google 制品仓库**。
1. 要查看镜像详情，请选择一个镜像。
1. 要在 Google Cloud 控制台中查看该镜像，请选择**在 Google Cloud 中打开**。您必须拥有[所需权限](https://cloud.google.com/artifact-registry/docs/repositories/list-repos#required_roles)才能查看该制品仓库中的仓库。

<a id="cicd"></a>

## CI/CD

<a id="predefined-variables"></a>

### 预定义变量

制品仓库集成激活后，CI/CD 中可以使用以下预定义环境变量。您可以使用这些环境变量与制品仓库交互，例如向已连接的仓库拉取或推送镜像。

| 变量                                       | 极狐GitLab | Runner | 描述 |
|------------------------------------------------|--------|--------|-------------|
| `GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID`          | 16.10  | 16.10  | 制品仓库中的仓库所在的 Google Cloud 项目 ID。 |
| `GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME`     | 16.10  | 16.10  | 已连接的制品仓库中的仓库的名称。 |
| `GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION` | 16.10  | 16.10  | 已连接的制品仓库中的仓库的 Google Cloud 位置。 |

<a id="authenticate-with-the-google-artifact-registry"></a>

### 向 Google 制品仓库进行身份验证

您可以配置一个流水线，使其在流水线执行期间向 Google 制品仓库进行身份验证。极狐GitLab 使用已配置的[工作负载身份池](../../../integration/google_cloud_iam.md) IAM 策略，并填充 `GOOGLE_APPLICATION_CREDENTIALS` 和 `CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE` 环境凭据。这些环境凭据会被客户端工具自动检测到，
例如 [gcloud CLI](https://docs.cloud.google.com/sdk/gcloud) 和 [crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md)。

要向 Google 制品仓库进行身份验证，请在项目的 `.gitlab-ci.yml` 文件中，使用设置为 `google_cloud`的 [`identity`](../../../ci/yaml/_index.md#identity) 关键字。

<a id="iam-policies"></a>

#### IAM 策略

您的 Google Cloud 项目必须具有特定的 IAM 策略，才能使用 Google 工件管理集成。
当您[设置此集成](#set-up-the-google-artifact-registry-in-a-gitlab-project)时，屏幕上的说明会提供在您的 Google Cloud 项目中创建以下 IAM 策略的步骤：

- 为具有[访客](../../permissions.md#roles)角色或更高角色的极狐GitLab 项目成员授予[制品仓库 Reader](https://cloud.google.com/iam/docs/understanding-roles#artifactregistry.reader) 角色。
- 为具有[开发者](../../permissions.md#roles)角色或更高角色的极狐GitLab 项目成员授予[制品仓库 Writer](https://cloud.google.com/iam/docs/understanding-roles#artifactregistry.writer) 角色。

要手动创建这些 IAM 策略，请使用以下 `gcloud` 命令。替换以下值：

- 将 `<your_google_cloud_project_id>` 替换为制品仓库中的仓库所在的 Google Cloud 项目的 [ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
- 将 `<your_workload_identity_pool_id>` 替换为工作负载身份池的 ID。这与 [Google Cloud IAM 集成](../../../integration/google_cloud_iam.md)使用的值相同。
- 将 `<your_google_cloud_project_number>` 替换为工作负载身份池所在的 Google Cloud 项目的[编号](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。这与 [Google Cloud IAM 集成](../../../integration/google_cloud_iam.md)使用的值相同。

```shell
gcloud projects add-iam-policy-binding '<your_google_cloud_project_id>' \
  --member='principalSet://iam.googleapis.com/projects/<your_google_cloud_project_number>/locations/global/workloadIdentityPools/<your_workload_identity_pool_id>/attribute.guest_access/true' \
  --role='roles/artifactregistry.reader'

gcloud projects add-iam-policy-binding '<your_google_cloud_project_id>' \
  --member='principalSet://iam.googleapis.com/projects/<your_google_cloud_project_number>/locations/global/workloadIdentityPools/<your_workload_identity_pool_id>/attribute.developer_access/true' \
  --role='roles/artifactregistry.writer'
```

有关可用声明的列表，请参见 [OIDC 自定义声明](../../../integration/google_cloud_iam.md#oidc-custom-claims)。

<a id="examples"></a>

### 示例

<a id="use-gcloud-cli-to-list-images"></a>

#### 使用 gcloud CLI 列出镜像

```yaml
list-images:
  image: gcr.io/google.com/cloudsdktool/google-cloud-cli:466.0.0-alpine
  identity: google_cloud
  script:
    - gcloud artifacts docker images list $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app
```

<a id="use-crane-to-list-images"></a>

#### 使用 crane 列出镜像

```yaml
list-images:
  image:
    name: gcr.io/go-containerregistry/crane:debug
    entrypoint: [""]
  identity: google_cloud
  before_script:
    # Temporary workaround for https://github.com/google/go-containerregistry/issues/1886
    - wget -q "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.22/docker-credential-gcr_linux_amd64-2.1.22.tar.gz" -O - | tar xz -C /tmp && chmod +x /tmp/docker-credential-gcr && mv /tmp/docker-credential-gcr /usr/bin/
    - docker-credential-gcr configure-docker --registries=$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - crane ls $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app
```

<a id="pull-an-image-with-docker"></a>

#### 使用 Docker 拉取镜像

以下示例展示了如何使用 Google 提供的[独立 Docker 凭据助手](https://cloud.google.com/artifact-registry/docs/docker/authentication#standalone-helper)为 Docker 设置身份验证。

```yaml
pull-image:
  image: docker:24.0.5-cli
  identity: google_cloud
  services:
    - docker:24.0.5-dind
  variables:
    # The following two variables ensure that the DinD service starts in TLS
    # mode and that the Docker CLI is properly configured to communicate with
    # the API. More details about the importance of this can be found at
    # https://docs.gitlab.com/ci/docker/using_docker_build/#use-the-docker-executor-with-docker-in-docker
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - wget -q "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.22/docker-credential-gcr_linux_amd64-2.1.22.tar.gz" -O - | tar xz -C /tmp && chmod +x /tmp/docker-credential-gcr && mv /tmp/docker-credential-gcr /usr/bin/
    - docker-credential-gcr configure-docker --registries=$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - docker pull $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app:v0.1.0
```

<a id="copy-an-image-by-using-a-cicd-component"></a>

#### 使用 CI/CD 组件复制镜像

Google 提供了 [`upload-artifact-registry`](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry) CI/CD 组件，您可以使用它将镜像从极狐GitLab 容器镜像仓库复制到制品仓库。

要使用 `upload-artifact-registry` 组件，请将以下内容添加到您的 `.gitlab-ci.yml`：

```yaml
include:
  - component: gitlab.com/google-gitlab-components/artifact-registry/upload-artifact-registry@main
    inputs:
      stage: deploy
      source: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
      target: $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/$CI_PROJECT_NAME:$CI_COMMIT_SHORT_SHA
```

有关详情，请参见[该组件文档](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry)。

使用 `upload-artifact-registry` 组件可简化将镜像复制到制品仓库的过程，并且是此集成的推荐方法。如果您想使用 Docker 或 Crane，请参见以下示例。

<a id="copy-an-image-by-using-docker"></a>

#### 使用 Docker 复制镜像

在以下示例中，使用 `gcloud` CLI 设置 Docker 身份验证，作为[独立 Docker 凭据助手](https://cloud.google.com/artifact-registry/docs/docker/authentication#standalone-helper)的替代方案。

```yaml
copy-image:
  image: gcr.io/google.com/cloudsdktool/google-cloud-cli:466.0.0-alpine
  identity: google_cloud
  services:
    - docker:24.0.5-dind
  variables:
    SOURCE_IMAGE: $CI_REGISTRY_IMAGE:v0.1.0
    TARGET_IMAGE: $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app:v0.1.0
    DOCKER_HOST: tcp://docker:2375
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - gcloud auth configure-docker $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - docker pull $SOURCE_IMAGE
    - docker tag $SOURCE_IMAGE $TARGET_IMAGE
    - docker push $TARGET_IMAGE
```

<a id="copy-an-image-by-using-crane"></a>

#### 使用 Crane 复制镜像

```yaml
copy-image:
  image:
    name: gcr.io/go-containerregistry/crane:debug
    entrypoint: [""]
  identity: google_cloud
  variables:
    SOURCE_IMAGE: $CI_REGISTRY_IMAGE:v0.1.0
    TARGET_IMAGE: $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app:v0.1.0
  before_script:
    # Temporary workaround for https://github.com/google/go-containerregistry/issues/1886
    - wget -q "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.22/docker-credential-gcr_linux_amd64-2.1.22.tar.gz" -O - | tar xz -C /tmp && chmod +x /tmp/docker-credential-gcr && mv /tmp/docker-credential-gcr /usr/bin/
    - docker-credential-gcr configure-docker --registries=$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - crane auth login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - crane copy $SOURCE_IMAGE $TARGET_IMAGE
```
