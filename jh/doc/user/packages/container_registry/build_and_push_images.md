---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 构建容器镜像并将其推送到容器镜像仓库
description: 使用 Docker 命令或 CI/CD 流水线构建容器镜像并将其推送到极狐GitLab 镜像仓库。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在构建并推送容器镜像之前，您必须先向容器镜像仓库[进行身份验证](authenticate_with_container_registry.md)。

<a id="use-docker-commands"></a>

## 使用 Docker 命令

您可以使用 Docker 命令构建容器镜像并将其推送到容器镜像仓库：

1. 向容器镜像仓库[进行身份验证](authenticate_with_container_registry.md)。
1. 运行 Docker 命令进行构建或推送。例如：

   - 构建：

     ```shell
     docker build -t registry.example.com/group/project/image .
     ```

   - 推送：

     ```shell
     docker push registry.example.com/group/project/image
     ```

<a id="use-gitlab-cicd"></a>

## 使用极狐GitLab CI/CD

使用[极狐GitLab CI/CD](../../../ci/_index.md) 从容器镜像仓库构建、推送、测试和部署容器镜像。

<a id="configure-your-gitlab-ciyml-file"></a>

### 配置您的 `.gitlab-ci.yml` 文件

您可以配置 `.gitlab-ci.yml` 文件，以构建容器镜像并将其推送到容器镜像仓库。

- 如果多个作业需要身份验证，请将身份验证命令放在 `before_script`中。
- 在构建之前，使用 `docker build --pull` 获取基础镜像的变更。这会稍微增加构建时间，
  但可确保您的镜像是最新的。
- 在每次 `docker run` 之前，显式执行 `docker pull` 以获取
  刚刚构建的镜像。如果您
  使用多个在本地缓存镜像的 runner，此步骤尤为重要。

  如果您在镜像标签中使用 Git SHA，则每个作业都是唯一的，
  您永远不会有过期的镜像。但是，如果您在依赖项发生变更后
  重新构建某个提交，仍有可能出现过期的镜像。
- 不要直接构建到 `latest` 标签，因为多个作业可能
  同时进行。

<a id="use-a-docker-in-docker-container-image"></a>

### 使用 Docker-in-Docker 容器镜像

您可以将自己的 Docker-in-Docker (DinD)
容器镜像与容器镜像仓库或依赖代理一起使用。

使用 DinD 从您的 CI/CD 流水线构建、测试和部署容器化应用。

先决条件：

- 设置 [Docker-in-Docker](../../../ci/docker/using_docker_build.md#use-docker-in-docker)。

{{< tabs >}}

{{< tab title="From the container registry" >}}

当您想使用存储在极狐GitLab 容器镜像仓库中的镜像时，请使用此方法。

在您的 `.gitlab-ci.yml` 文件中：

- 更新 `image` 和 `services`，使其指向您的镜像仓库。
- 添加服务[别名](../../../ci/services/_index.md#available-settings-for-services)。

您的 `.gitlab-ci.yml` 应类似如下：

```yaml
build:
  image: $CI_REGISTRY/group/project/docker:24.0.5-cli
  services:
    - name: $CI_REGISTRY/group/project/docker:24.0.5-dind
      alias: docker
  stage: build
  script:
    - docker build -t my-docker-image .
    - docker run my-docker-image /script/to/run/tests
```

{{< /tab >}}

{{< tab title="With the Dependency Proxy" >}}

使用此方法可缓存来自 Docker Hub 等外部镜像仓库的镜像，以加快构建速度并避免速率限制。

在您的 `.gitlab-ci.yml` 文件中：

- 更新 `image` 和 `services`，以使用依赖代理前缀。
- 添加服务[别名](../../../ci/services/_index.md#available-settings-for-services)。

您的 `.gitlab-ci.yml` 应类似如下：

```yaml
build:
  image: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/docker:24.0.5-cli
  services:
    - name: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/docker:24.0.5-dind
      alias: docker
  stage: build
  script:
    - docker build -t my-docker-image .
    - docker run my-docker-image /script/to/run/tests
```

{{< /tab >}}

{{< /tabs >}}

如果您忘记设置服务别名，容器镜像将无法找到 `dind` 服务，并会显示如下错误：

```plaintext
error during connect: Get http://docker:2376/v1.39/info: dial tcp: lookup docker on 192.168.0.1:53: no such host
```

<a id="container-registry-examples-with-gitlab-cicd"></a>

## 使用极狐GitLab CI/CD 的容器镜像仓库示例

如果您在 runner 上使用 DinD，您的 `.gitlab-ci.yml` 文件应类似如下：

```yaml
build:
  image: docker:24.0.5-cli
  stage: build
  services:
    - docker:24.0.5-dind
  script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin
    - docker build -t $CI_REGISTRY/group/project/image:latest .
    - docker push $CI_REGISTRY/group/project/image:latest
```

您可以在 `.gitlab-ci.yml` 文件中使用 [CI/CD 变量](../../../ci/variables/_index.md)。例如：

```yaml
build:
  image: docker:24.0.5-cli
  stage: build
  services:
    - docker:24.0.5-dind
  variables:
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
```

在上一个示例中：

- `$CI_REGISTRY_IMAGE` 解析为与此项目关联的镜像仓库地址。
- `$IMAGE_TAG` 是一个自定义变量，它将镜像仓库地址与 `$CI_COMMIT_REF_SLUG`（镜像标签）组合在一起。[`$CI_COMMIT_REF_NAME` 预定义变量](../../../ci/variables/predefined_variables.md#predefined-variables)解析为分支或标签名称，并且可能包含正斜杠。镜像标签不能包含正斜杠。请改用 `$CI_COMMIT_REF_SLUG`。

以下示例将 CI/CD 任务拆分为四个流水线阶段，其中包括两个并行运行的测试。

`build` 存储在容器镜像仓库中，并由后续阶段在需要时下载该容器镜像来使用。当您将变更推送到 `main` 分支时，流水线会将镜像标记为 `latest`，并使用特定于应用的部署脚本进行部署：

```yaml
default:
  image: docker:24.0.5-cli
  services:
    - docker:24.0.5-dind
  before_script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin

stages:
  - build
  - test
  - release
  - deploy

variables:
  # Use TLS https://docs.gitlab.com/ci/docker/using_docker_build/#use-docker-in-docker
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  CONTAINER_TEST_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  CONTAINER_RELEASE_IMAGE: $CI_REGISTRY_IMAGE:latest

build:
  stage: build
  script:
    - docker build --pull -t $CONTAINER_TEST_IMAGE .
    - docker push $CONTAINER_TEST_IMAGE

test1:
  stage: test
  script:
    - docker pull $CONTAINER_TEST_IMAGE
    - docker run $CONTAINER_TEST_IMAGE /script/to/run/tests

test2:
  stage: test
  script:
    - docker pull $CONTAINER_TEST_IMAGE
    - docker run $CONTAINER_TEST_IMAGE /script/to/run/another/test

release-image:
  stage: release
  script:
    - docker pull $CONTAINER_TEST_IMAGE
    - docker tag $CONTAINER_TEST_IMAGE $CONTAINER_RELEASE_IMAGE
    - docker push $CONTAINER_RELEASE_IMAGE
  rules:
    - if: $CI_COMMIT_BRANCH == "main"

deploy:
  stage: deploy
  script:
    - ./deploy.sh
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: production
```

> [!note]
> 上一个示例显式调用了 `docker pull`。如果您希望使用 `image:`
> 隐式拉取容器镜像，
> 无论使用 [Docker](https://gitlab.cn/docs/runner/executors/docker/) 还是 [Kubernetes](https://gitlab.cn/docs/runner/executors/kubernetes/) 执行器，
> 请确保将 [`pull_policy`](https://gitlab.cn/docs/runner/executors/docker/#set-the-always-pull-policy) 设置为 `always`。
