---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义 Auto DevOps
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以自定义 Auto DevOps 的各个组件，以满足您的需求。例如，您可以：

- 添加自定义 [buildpack](#custom-buildpacks)、[Dockerfile](#custom-dockerfiles) 和 [Helm chart](#custom-helm-chart)。
- 使用自定义 [CI/CD 配置](#customize-gitlab-ciyml)启用预发布和灰度部署。
- 通过[极狐GitLab API](#extend-auto-devops-with-the-api) 扩展 Auto DevOps。

<a id="custom-buildpacks"></a>

## 自定义 buildpack

在以下任一情况下，您可以自定义 buildpack：

- 项目自动检测 buildpack 失败。
- 您需要对构建过程进行更多控制。

<a id="customize-buildpacks-with-cloud-native-buildpacks"></a>

### 使用 Cloud Native Buildpacks 自定义 buildpack

指定以下任一项：

- CI/CD 变量 `BUILDPACK_URL`，使用 [`pack`的 URI 规范格式](https://buildpacks.io/docs/app-developer-guide/specify-buildpacks/)中的任意一种。
- 一个 [`project.toml` 项目描述符](https://buildpacks.io/docs/app-developer-guide/using-project-descriptor/)，其中包含您想要包含的 buildpack。

<a id="multiple-buildpacks"></a>

### 多个 buildpack

由于 Auto Test 无法使用 `.buildpacks` 文件，Auto DevOps
不支持多个 buildpack。后端用于解析 `.buildpacks` 文件的 buildpack
[heroku-buildpack-multi](https://github.com/heroku/heroku-buildpack-multi/)
不提供必要的命令 `bin/test-compile` 和 `bin/test`。

若要仅使用单个自定义 buildpack，您应改为提供项目 CI/CD 变量
`BUILDPACK_URL`。

<a id="custom-dockerfiles"></a>

## 自定义 Dockerfile

如果您的项目代码仓库根目录中有 Dockerfile，Auto
DevOps 会基于该 Dockerfile 构建 Docker 镜像。这可能比使用 buildpack
更快，也可能生成更小的镜像，
尤其是当您的 Dockerfile 基于
[Alpine](https://hub.docker.com/_/alpine/) 时。

如果您设置了 `DOCKERFILE_PATH` CI/CD 变量，Auto Build 会在该位置查找 Dockerfile。

<a id="pass-arguments-to-docker-build"></a>

### 向 `docker build` 传递参数

您可以使用 `AUTO_DEVOPS_BUILD_IMAGE_EXTRA_ARGS` 项目 CI/CD 变量向 `docker build` 传递参数。

例如，要基于 `ruby:alpine` 而不是默认的 `ruby:latest` 构建 Docker 镜像：

1. 将 `AUTO_DEVOPS_BUILD_IMAGE_EXTRA_ARGS` 设置为 `--build-arg=RUBY_VERSION=alpine`。
1. 将以下内容添加到自定义 Dockerfile 中：

   ```dockerfile
   ARG RUBY_VERSION=latest
   FROM ruby:$RUBY_VERSION

   # Include your content here
   ```

要传递空格和换行等复杂值，请使用 Base64 编码。未编码的复杂值可能会导致字符转义问题。

> [!warning]
> 不要将密钥作为 Docker 构建参数传递。密钥可能会保留在您的镜像中。有关更多信息，请参阅
> [关于密钥最佳实践的这一讨论](https://github.com/moby/moby/issues/13490)。

<a id="custom-container-image"></a>

## 自定义容器镜像

默认情况下，[Auto Deploy](stages.md#auto-deploy) 会部署由 [Auto Build](stages.md#auto-build) 构建并推送到极狐GitLab 镜像仓库的容器镜像。您可以通过定义特定变量来覆盖此行为：

| 条目 | 默认值 | 可被覆盖为 |
| ----- | -----   | -----    |
| 镜像路径 | 分支流水线使用 `$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG`。标签流水线使用 `$CI_REGISTRY_IMAGE`。 | `$CI_APPLICATION_REPOSITORY` |
| 镜像标签 | 分支流水线使用 `$CI_COMMIT_SHA`。标签流水线使用 `$CI_COMMIT_TAG`。 | `$CI_APPLICATION_TAG` |

这些变量还会影响 Auto Build 和自动容器扫描。如果您不想构建镜像并将其推送到 `$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG`，请仅包含 `Jobs/Deploy.gitlab-ci.yml`，或[跳过 `build` 作业](cicd_variables.md#job-skipping-variables)。

如果您使用自动容器扫描并为 `$CI_APPLICATION_REPOSITORY` 设置了值，那么您还应更新 `$CS_DEFAULT_BRANCH_IMAGE`。有关更多信息，请参阅[设置默认分支镜像](../../user/application_security/container_scanning/_index.md#setting-the-default-branch-image)。

以下是在 `.gitlab-ci.yml`中的示例设置：

```yaml
variables:
  CI_APPLICATION_REPOSITORY: <your-image-repository>
  CI_APPLICATION_TAG: <the-tag>
```

<a id="extend-auto-devops-with-the-api"></a>

## 使用 API 扩展 Auto DevOps

您可以使用极狐GitLab API 扩展和管理您的 Auto DevOps 配置：

- [使用 API 调用访问设置](../../api/settings.md#available-settings)，
  其中包括 `auto_devops_enabled`，可默认在项目上启用 Auto DevOps。
- [创建新项目](../../api/projects.md#create-a-project)。
- [编辑群组](../../api/groups.md#update-group-attributes)。
- [编辑项目](../../api/projects.md#update-a-project)。

<a id="forward-cicd-variables-to-the-build-environment"></a>

## 将 CI/CD 变量转发到构建环境

要将 CI/CD 变量转发到构建环境，请将要转发的变量名称添加到 `AUTO_DEVOPS_BUILD_IMAGE_FORWARDED_CI_VARIABLES` CI/CD 变量中。多个变量之间用逗号分隔。

例如，要转发变量 `CI_COMMIT_SHA` 和 `CI_ENVIRONMENT_NAME`：

```yaml
variables:
  AUTO_DEVOPS_BUILD_IMAGE_FORWARDED_CI_VARIABLES: CI_COMMIT_SHA,CI_ENVIRONMENT_NAME
```

如果您使用 buildpack，转发的变量会自动作为环境变量提供。

如果您使用 Dockerfile：

1. 要激活实验性 Dockerfile 语法，请将以下内容添加到您的 Dockerfile 中：

   ```dockerfile
   # syntax = docker/dockerfile:experimental
   ```

1. 要使密钥在 `Dockerfile`中的任何 `RUN $COMMAND`中可用，请挂载
   密钥文件，并在运行 `$COMMAND` 之前加载它：

   ```dockerfile
   RUN --mount=type=secret,id=auto-devops-build-secrets . /run/secrets/auto-devops-build-secrets && $COMMAND
   ```

当设置了 `AUTO_DEVOPS_BUILD_IMAGE_FORWARDED_CI_VARIABLES` 时，Auto DevOps
会启用实验性的 [Docker BuildKit](https://docs.docker.com/build/buildkit/)
功能，以使用 `--secret` 标志。

<a id="custom-helm-chart"></a>

## 自定义 Helm chart

Auto DevOps 使用 [Helm](https://helm.sh/) 将您的应用部署到 Kubernetes。
您可以通过在项目代码仓库中捆绑 chart，或指定项目 CI/CD 变量，
来覆盖所使用的 Helm chart：

- **捆绑的 chart** - 如果您的项目有一个 `./chart` 目录，其中包含 `Chart.yaml`
  文件，Auto DevOps 会检测到该 chart 并使用它，而不是
  [默认 chart](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/tree/master/assets/auto-deploy-app)。
- **项目变量** - 创建一个[项目 CI/CD 变量](../../ci/variables/_index.md)
  `AUTO_DEVOPS_CHART`，其值为自定义 chart 的 URL。您还可以创建五个项目
  变量：

  - `AUTO_DEVOPS_CHART_REPOSITORY` - 自定义 chart 仓库的 URL。
  - `AUTO_DEVOPS_CHART` - chart 的路径。
  - `AUTO_DEVOPS_CHART_REPOSITORY_INSECURE` - 设置为非空值，以向 Helm 命令添加 `--insecure-skip-tls-verify` 参数。
  - `AUTO_DEVOPS_CHART_CUSTOM_ONLY` - 设置为非空值，以仅使用自定义 chart。默认情况下，会从极狐GitLab 下载最新的 chart。
  - `AUTO_DEVOPS_CHART_VERSION` - 部署 chart 的版本。

<a id="customize-helm-chart-values"></a>

### 自定义 Helm chart 值

要覆盖[默认 Helm chart](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/tree/master/assets/auto-deploy-app)中 `values.yaml` 文件的默认值，您可以：

- 在代码仓库中添加一个名为 `.gitlab/auto-deploy-values.yaml`的文件。默认情况下，Helm 升级会使用此文件。
- 在代码仓库中添加一个名称或路径不同的文件。将
  `HELM_UPGRADE_VALUES_FILE` [CI/CD 变量](cicd_variables.md)设置为该文件的路径和名称。

有些值无法通过上述选项覆盖，但[此议题](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/issues/31)提议更改此行为。要覆盖 `replicaCount` 等设置，请使用 `REPLICAS` [构建和部署](cicd_variables.md#build-and-deployment-variables) CI/CD 变量。

<a id="customize-helm-upgrade"></a>

### 自定义 `helm upgrade`

[auto-deploy-image](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image) 使用 `helm upgrade` 命令。
要自定义此命令，请使用 `HELM_UPGRADE_EXTRA_ARGS` CI/CD 变量向其传递选项。

例如，要在 `helm upgrade` 运行时禁用升级前和升级后的钩子：

```yaml
variables:
  HELM_UPGRADE_EXTRA_ARGS: --no-hooks
```

有关选项的完整列表，请参阅[官方 `helm upgrade` 文档](https://helm.sh/docs/helm/helm_upgrade/)。

<a id="limit-a-helm-chart-to-one-environment"></a>

### 将 Helm chart 限制到一个环境

要将自定义 chart 限制到一个环境，请将环境范围添加到您的 CI/CD 变量中。有关更多信息，请参阅[限制 CI/CD 变量的环境范围](../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

<a id="customize-gitlab-ciyml"></a>

## 自定义 `.gitlab-ci.yml`

Auto DevOps 具有高度可自定义性，因为 [Auto DevOps 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml)
是 `.gitlab-ci.yml` 文件的一种实现。该模板仅使用任何 `.gitlab-ci.yml` 实现都可用的功能。

要向 Auto DevOps 使用的 CI/CD 流水线添加自定义行为：

1. 在代码仓库的根目录中添加一个 `.gitlab-ci.yml` 文件，内容如下：

   ```yaml
   include:
     - template: Auto-DevOps.gitlab-ci.yml
   ```

1. 将您的更改添加到 `.gitlab-ci.yml` 文件中。您的更改会与 Auto DevOps 模板合并。有关
   `include` 如何合并您的更改的更多信息，请参阅 [`include` 文档](../../ci/yaml/_index.md#include)。

要从 Auto DevOps 流水线中移除行为：

1. 将 [Auto DevOps 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml)
   复制到您的项目中。
1. 根据需要编辑您复制的模板。

<a id="use-individual-components-of-auto-devops"></a>

### 使用 Auto DevOps 的各个组件

如果您只需要 Auto DevOps 提供的部分功能，可以在您自己的 `.gitlab-ci.yml`中包含各个 Auto DevOps 作业。请务必在您的 `.gitlab-ci.yml` 文件中也定义每个作业所需的阶段。

例如，要使用 [Auto Build](stages.md#auto-build)，您可以将以下内容添加到您的 `.gitlab-ci.yml`中：

```yaml
stages:
  - build

include:
  - template: Jobs/Build.gitlab-ci.yml
```

有关可用作业的列表，请参阅 [Auto DevOps 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml)。

<a id="use-multiple-kubernetes-clusters"></a>

## 使用多个 Kubernetes 集群

请参阅[用于 Auto DevOps 的多个 Kubernetes 集群](multiple_clusters_auto_devops.md)。

<a id="customizing-the-kubernetes-namespace"></a>

## 自定义 Kubernetes 命名空间

您以前可以使用 `environment:kubernetes:namespace` 为环境指定命名空间。但是，此功能已[弃用](https://gitlab.com/groups/gitlab-org/configure/-/work_items/8)，与基于证书的集成一同弃用。

您现在应使用 `KUBE_NAMESPACE` 环境变量，并[限制其环境范围](../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)。

<a id="use-images-hosted-in-a-local-docker-registry"></a>

## 使用托管在本地 Docker 镜像仓库中的镜像

您可以将许多 Auto DevOps 作业配置为在[离线环境](../../user/application_security/offline_deployments/_index.md)中运行：

1. 将所需的 Auto DevOps Docker 镜像从 Docker Hub 和 `registry.gitlab.com` 复制到其本地极狐GitLab 容器镜像仓库。
1. 镜像在本地镜像仓库中托管并可用后，编辑 `.gitlab-ci.yml` 以指向本地托管的镜像。例如：

   ```yaml
   include:
     - template: Auto-DevOps.gitlab-ci.yml

   variables:
     REGISTRY_URL: "registry.gitlab.example"

   build:
     image: "$REGISTRY_URL/docker/auto-build-image:v0.6.0"
     services:
       - name: "$REGISTRY_URL/greg/docker/docker:20.10.16-dind"
         command: ['--tls=false', '--host=tcp://0.0.0.0:2375']
   ```

<a id="postgresql-database-support"></a>

## PostgreSQL 数据库支持

> [!warning]
> 默认预配 PostgreSQL 数据库的做法已[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/387766)，
> 且不再是默认行为。要启用数据库预配，请设置
> 相关的 [CI/CD 变量](cicd_variables.md#database-variables)。

为支持需要数据库的应用，
默认会预配 [PostgreSQL](https://www.postgresql.org/)。
访问数据库的凭据已预先配置。

要自定义凭据，请设置相关的 [CI/CD 变量](cicd_variables.md)。您还可以定义自定义 `DATABASE_URL`：

```yaml
postgres://user:password@postgres-host:postgres-port/postgres-database
```

<a id="upgrading-postgresql"></a>

### 升级 PostgreSQL

极狐GitLab 默认使用 chart 版本 8.2.1 来预配 PostgreSQL。
您可以将版本设置为 0.7.1 到 8.2.1 之间的值。

如果您使用较旧的 chart 版本，应将[数据库迁移](upgrading_postgresql.md)
到较新的 PostgreSQL。

控制默认预配 PostgreSQL 的 CI/CD 变量 `AUTO_DEVOPS_POSTGRES_CHANNEL` 设置为 `2`。
要使用旧版 PostgreSQL，请将 `AUTO_DEVOPS_POSTGRES_CHANNEL` 变量设置为
`1`。

<a id="customize-values-for-postgresql-helm-chart"></a>

### 自定义 PostgreSQL Helm Chart 的值

要设置自定义值，请执行以下任一操作：

- 在代码仓库中添加一个名为 `.gitlab/auto-deploy-postgres-values.yaml`的文件。如果找到该文件，
  会自动使用它。默认情况下，PostgreSQL Helm 升级会使用此文件。
- 在代码仓库中添加一个名称或路径不同的文件，并将
  `POSTGRES_HELM_UPGRADE_VALUES_FILE` [环境变量](cicd_variables.md#database-variables)设置为该路径
  和名称。
- 设置 `POSTGRES_HELM_UPGRADE_EXTRA_ARGS` [环境变量](cicd_variables.md#database-variables)。

<a id="use-external-postgresql-database-providers"></a>

### 使用外部 PostgreSQL 数据库提供商

Auto DevOps 为生产环境开箱即用地支持 PostgreSQL 容器。
但是，您可能希望使用
AWS Relational Database Service 等外部托管提供商。

要使用外部托管提供商：

1. 使用环境范围的 [CI/CD 变量](../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)
   为所需环境禁用内置 PostgreSQL 安装。
   由于用于评审应用和预发布的内置 PostgreSQL 设置已足够，您可能只需
   为 `production` 禁用安装。

   ![Auto Metrics](img/disable_postgres_v12_4.png)
1. 将 `DATABASE_URL` 变量定义为环境范围的变量，
   供您的应用使用。它应为以下格式的 URL：

   ```yaml
   postgres://user:password@postgres-host:postgres-port/postgres-database
   ```

1. 确保您的 Kubernetes 集群可以网络访问 PostgreSQL 的托管位置。
