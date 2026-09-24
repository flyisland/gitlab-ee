---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 谷歌构件管理
description: Connect a Google Artifact Registry to your GitLab project to view, push, and pull Docker and OCI images.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 GitLab 16.10 引入，带有功能标志 `google_cloud_support_feature_flag`。此功能处于 beta 阶段。
- 在 GitLab 17.1 已启用。功能标志 `google_cloud_support_feature_flag` 已移除。

{{< /history >}}

您可以使用谷歌构件管理集成来配置一个[谷歌构件注册表](https://cloud.google.com/artifact-registry)仓库并将其连接到您的极狐GitLab 项目。

将谷歌构件注册表连接到项目后，您可以在[谷歌构件注册表](https://cloud.google.com/artifact-registry)仓库中查看、推送和拉取 Docker 和 [OCI](https://opencontainers.org/) 镜像。

<a id="set-up-the-google-artifact-registry-in-a-gitlab-project"></a>

## 在极狐GitLab 项目中设置谷歌构件注册表

先决条件：

- 您必须具有该极狐GitLab 项目的**维护者**或**所有者**角色。
- 您必须拥有管理包含构件注册表仓库的谷歌云项目访问权所需的[权限](https://cloud.google.com/iam/docs/granting-changing-revoking-access#required-permissions)。
- 必须配置[工作负载身份联合](../../../integration/google_cloud_iam.md) (WLIF) 池和提供程序以向谷歌云进行身份验证。
- 一个具有以下配置的[谷歌构件注册表仓库](https://cloud.google.com/artifact-registry/docs/repositories)：
  - [Docker](https://cloud.google.com/artifact-registry/docs/supported-formats) 格式。
  - [标准](https://cloud.google.com/artifact-registry/docs/repositories/create-repos)模式。不支持其他仓库格式和模式。

要将谷歌构件注册表仓库连接到极狐GitLab 项目：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择**谷歌构件管理**。
1. 在**启用集成**下，勾选**活跃**复选框。
1. 填写字段：
   - **谷歌云项目 ID**：构件注册表仓库所在的[谷歌云项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
   - **仓库名称**：构件注册表仓库的名称。
   - **仓库位置**：构件注册表仓库的[谷歌云位置](https://cloud.google.com/about/locations)。
1. 按照屏幕上的说明设置谷歌云身份和访问管理 (IAM) 策略。有关策略类型的更多信息，请参见 [IAM 策略](#iam-policies)。
1. 选择**保存更改**。

您现在应该会在**部署**下的侧边栏中看到**谷歌构件注册表**条目。

<a id="view-images-stored-in-the-google-artifact-registry"></a>

## 查看存储在谷歌构件注册表中的镜像

先决条件：

- 必须在项目中[配置](google_artifact_management.md#set-up-the-google-artifact-registry-in-a-gitlab-project)了谷歌构件注册表。

要在极狐GitLab UI 中查看已连接构件注册表仓库中的镜像列表：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**部署** > **谷歌构件注册表**。
1. 要查看镜像详细信息，选择某个镜像。
1. 要在谷歌云控制台中查看镜像，选择**在谷歌云中打开**。您必须拥有[所需权限](https://cloud.google.com/artifact-registry/docs/repositories/list-repos#required_roles)才能查看该构件注册表仓库。

<a id="ci-cd"></a>

## CI/CD

<a id="predefined-variables"></a>

### 预定义变量

激活构件注册表集成后，CI/CD 中将提供以下预定义环境变量。
您可以使用这些环境变量与构件注册表交互，例如拉取或推送镜像到已连接的仓库。

| 变量 | 极狐GitLab | Runner | 描述 |
|------|------------|--------|------|
| `GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID` | 16.10 | 16.10 | 构件注册表仓库所在的谷歌云项目 ID。 |
| `GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME` | 16.10 | 16.10 | 已连接构件注册表仓库的名称。 |
| `GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION` | 16.10 | 16.10 | 已连接构件注册表仓库的谷歌云位置。 |

<a id="authenticate-with-the-google-artifact-registry"></a>

### 使用谷歌构件注册表进行身份验证

您可以配置流水线以在流水线执行期间向谷歌构件注册表进行身份验证。极狐GitLab 使用配置的[工作负载身份池](../../../integration/google_cloud_iam.md) IAM 策略，并填充 `GOOGLE_APPLICATION_CREDENTIALS` 和 `CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE` 环境凭证。这些环境凭证会被客户端工具自动检测到，例如 [gcloud CLI](https://cloud.google.com/sdk/gcloud) 和 [crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md)。

要在谷歌构件注册表中进行身份验证，请在项目的 `.gitlab-ci.yml` 文件中使用 `identity` 关键字设置为 `google_cloud`。

<a id="iam-policies"></a>

#### IAM 策略

您的谷歌云项目必须具有特定的 IAM 策略才能使用谷歌构件管理集成。
在[设置此集成](#set-up-the-google-artifact-registry-in-a-gitlab-project)时，屏幕上的说明提供了在您的谷歌云项目中创建以下 IAM 策略的步骤：

- 对具有[访客](../../permissions.md#roles)角色或更高级别角色的极狐GitLab 项目成员授予 [Artifact Registry Reader](https://cloud.google.com/iam/docs/understanding-roles#artifactregistry.reader) 角色。
- 对具有[开发者](../../permissions.md#roles)角色或更高级别角色的极狐GitLab 项目成员授予 [Artifact Registry Writer](https://cloud.google.com/iam/docs/understanding-roles#artifactregistry.writer) 角色。

要手动创建这些 IAM 策略，请使用以下 `gcloud` 命令。替换这些值：

- `<your_google_cloud_project_id>` 用构件注册表仓库所在谷歌云项目的 [ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects) 替换。
- `<your_workload_identity_pool_id>` 用工作负载身份池的 ID 替换。这与 [Google Cloud IAM 集成](../../../integration/google_cloud_iam.md)中使用的值相同。
- `<your_google_cloud_project_number>` 用工作负载身份池所在谷歌云项目的[编号](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)替换。这与 [Google Cloud IAM 集成](../../../integration/google_cloud_iam.md)中使用的值相同。

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
    # 针对 https://github.com/google/go-containerregistry/issues/1886 的临时解决方案
    - wget -q "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.22/docker-credential-gcr_linux_amd64-2.1.22.tar.gz" -O - | tar xz -C /tmp && chmod +x /tmp/docker-credential-gcr && mv /tmp/docker-credential-gcr /usr/bin/
    - docker-credential-gcr configure-docker --registries=$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - crane ls $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app
```

<a id="pull-an-image-with-docker"></a>

#### 使用 Docker 拉取镜像

下面的示例展示了如何使用谷歌提供的[独立 Docker 凭据助手](https://cloud.google.com/artifact-registry/docs/docker/authentication#standalone-helper)为 Docker 设置身份验证。

```yaml
pull-image:
  image: docker:24.0.5-cli
  identity: google_cloud
  services:
    - docker:24.0.5-dind
  variables:
    # 以下两个变量确保 DinD 服务以 TLS 模式启动，
    # 并且 Docker CLI 正确配置为与 API 通信。
    # 关于此重要性的更多详细信息，请参见
    # https://gitlab.cn/docs/ci/docker/using_docker_build/#use-the-docker-executor-with-docker-in-docker
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - wget -q "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.22/docker-credential-gcr_linux_amd64-2.1.22.tar.gz" -O - | tar xz -C /tmp && chmod +x /tmp/docker-credential-gcr && mv /tmp/docker-credential-gcr /usr/bin/
    - docker-credential-gcr configure-docker --registries=$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - docker pull $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/app:v0.1.0
```

<a id="copy-an-image-by-using-a-ci-cd-component"></a>

#### 使用 CI/CD 组件复制镜像

谷歌提供了 `upload-artifact-registry` CI/CD 组件，您可以使用它将镜像从极狐GitLab 容器镜像仓库复制到构件注册表。

要使用 `upload-artifact-registry` 组件，请将以下内容添加到您的 `.gitlab-ci.yml` 中：

```yaml
include:
  - component: gitlab.com/google-gitlab-components/artifact-registry/upload-artifact-registry@main
    inputs:
      stage: deploy
      source: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
      target: $GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev/$GOOGLE_ARTIFACT_REGISTRY_PROJECT_ID/$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_NAME/$CI_PROJECT_NAME:$CI_COMMIT_SHORT_SHA
```

详细信息，请参见[组件文档](https://gitlab.com/explore/catalog/google-gitlab-components/artifact-registry)。

使用 `upload-artifact-registry` 组件简化了将镜像复制到构件注册表的过程，也是此集成的预期方法。如果您想使用 Docker 或 Crane，请参见以下示例。

<a id="copy-an-image-by-using-docker"></a>

#### 使用 Docker 复制镜像

在以下示例中，使用 `gcloud` CLI 设置 Docker 身份验证，作为使用[独立 Docker 凭据助手](https://cloud.google.com/artifact-registry/docs/docker/authentication#standalone-helper)的替代方法。

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
    # 针对 https://github.com/google/go-containerregistry/issues/1886 的临时解决方案
    - wget -q "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.22/docker-credential-gcr_linux_amd64-2.1.22.tar.gz" -O - | tar xz -C /tmp && chmod +x /tmp/docker-credential-gcr && mv /tmp/docker-credential-gcr /usr/bin/
    - docker-credential-gcr configure-docker --registries=$GOOGLE_ARTIFACT_REGISTRY_REPOSITORY_LOCATION-docker.pkg.dev
  script:
    - crane auth login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - crane copy $SOURCE_IMAGE $TARGET_IMAGE
```