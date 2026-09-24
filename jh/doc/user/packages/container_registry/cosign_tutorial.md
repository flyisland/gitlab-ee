---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用构建来源数据注释容器镜像'
description: 在 极狐GitLab CI/CD 流水线中，使用 Cosign 对容器镜像进行签名并附加构建来源数据作为注释。
---

注释提供了有关构建过程的宝贵元数据。这些信息用于审计和可追溯性。在安全事件中，拥有详细的来源数据可以显著加快调查和修复过程。

本教程介绍了如何设置一个 极狐GitLab 流水线，以自动执行使用 Cosign 构建、签名和注释容器镜像的过程。
您可以配置 `.gitlab-ci.yml` 文件来构建、推送和签名 Docker 镜像，并将其推送到 极狐GitLab 容器镜像仓库。

注释容器镜像的步骤：

1. [设置镜像和服务镜像](#set-image-and-service-image)。
1. [定义 CI/CD 变量](#define-cicd-variables)。
1. [准备 OIDC 令牌](#prepare-oidc-token)。
1. [准备容器](#prepare-the-container)。
1. [构建和推送镜像](#build-and-push-the-image)。
1. [使用 Cosign 签名镜像](#sign-the-image-with-cosign)。
1. [验证签名和注释](#verify-the-signature-and-annotations)。

当您将所有步骤组合在一起时，您的 `.gitlab-ci.yml` 文件应该看起来与本教程末尾提供的[示例配置](#example-gitlab-ciyml-configuration)类似。

## 准备工作

您必须具备：

- 已安装 Cosign v2.0 或更高版本。
- 对于 极狐GitLab 私有化部署，极狐GitLab 容器镜像仓库已[配置元数据数据库](../../../administration/packages/container_registry_metadata_database.md)以显示签名。

<a id="set-image-and-service-image"></a>

## 设置镜像和服务镜像

在 `.gitlab-ci.yml` 文件中，使用 `docker:cli` 镜像并启用 Docker-in-Docker 服务，以便在 CI/CD 作业中运行 Docker 命令。

```yaml
build_and_sign:
  stage: build
  image: docker:cli
  services:
    - docker:dind  # 启用 Docker-in-Docker 服务，以允许在容器内执行 Docker 命令
```

<a id="define-cicd-variables"></a>

## 定义 CI/CD 变量

使用 极狐GitLab CI/CD 预定义变量来定义镜像标签和 URI 的变量。

```yaml
variables:
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA  # 使用提交的短 SHA 作为镜像标签
  IMAGE_URI: $CI_REGISTRY_IMAGE:$IMAGE_TAG  # 使用镜像仓库、项目路径和标签构建完整的镜像 URI
  COSIGN_YES: "true"  # 在 Cosign 中自动确认操作，无需用户交互
  FF_SCRIPT_SECTIONS: "true"  # 启用 极狐GitLab 的 CI 脚本分段功能，以获得更好的多行脚本输出
```

<a id="prepare-oidc-token"></a>

## 准备 OIDC 令牌

为 Cosign 的无密钥签名设置一个 OIDC 令牌。

```yaml
id_tokens:
  SIGSTORE_ID_TOKEN:
    aud: sigstore  # 为 Cosign 的无密钥签名提供 OIDC 令牌
```

<a id="prepare-the-container"></a>

## 准备容器

在 `.gitlab-ci.yml` 文件的 `before_script` 部分：

- 安装 Cosign 和 jq（用于 JSON 处理）：`apk add --no-cache cosign jq`
- 使用 CI/CD 作业令牌登录 极狐GitLab 容器镜像仓库：`docker login -u "gitlab-ci-token" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"`

流水线从设置必要的环境开始。

<a id="build-and-push-the-image"></a>

## 构建和推送镜像

在 `.gitlab-ci.yml` 文件的 `script` 部分，输入以下命令来构建 Docker 镜像并将其推送到 极狐GitLab 容器镜像仓库。

```yaml
- docker build --pull -t "$IMAGE_URI" .
- docker push "$IMAGE_URI"
```

此命令使用当前目录的 Dockerfile 创建镜像，并将其推送到镜像仓库。

<a id="sign-the-image-with-cosign"></a>

## 使用 Cosign 签名镜像

在构建镜像并将其推送到 极狐GitLab 容器镜像仓库之后，使用 Cosign 对其进行签名。

在 `.gitlab-ci.yml` 文件的 `script` 部分，输入以下命令：

```yaml
- IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_URI")
- |
  cosign sign "$IMAGE_DIGEST" \
    --registry-referrers-mode oci-1-1 \
    --annotations "com.gitlab.ci.user.name=$GITLAB_USER_NAME" \
    --annotations "com.gitlab.ci.pipeline.id=$CI_PIPELINE_ID" \
    # 为便于阅读，省略了其他注释
    --annotations "tag=$IMAGE_TAG"
```

此步骤获取镜像摘要。然后使用 Cosign 对镜像进行签名，并添加多个注释。

<a id="verify-the-signature-and-annotations"></a>

## 验证签名和注释

对镜像进行签名后，验证签名及其添加的注释非常重要。

在 `.gitlab-ci.yml` 文件中，包含一个使用 `cosign verify` 命令的验证步骤：

```yaml
- |
  cosign verify \
    --annotations "tag=$IMAGE_TAG" \
    --certificate-identity "$CI_PROJECT_URL//.gitlab-ci.yml@refs/heads/$CI_COMMIT_REF_NAME" \
    --certificate-oidc-issuer "$CI_SERVER_URL" \
    "$IMAGE_URI" | jq .
```

验证步骤确保附加到镜像的来源数据是正确的，并且未被篡改。
`cosign verify` 命令验证签名并检查注释。输出显示了您在签名过程中添加到镜像的所有注释。

在输出中，您可以看到之前添加的所有注释，包括：

- 极狐GitLab 用户名
- 流水线 ID 和 URL
- 作业 ID 和 URL
- 提交 SHA 和引用名称
- 项目路径
- 镜像源和修订版

通过验证这些注释，您可以确保镜像的来源数据是完整的，并且符合您基于构建过程的预期。

<a id="example-gitlab-ciyml-configuration"></a>

## `.gitlab-ci.yml` 配置示例

当您完成前面所有步骤后，`.gitlab-ci.yml` 文件应如下所示：

```yaml
stages:
  - build

build_and_sign:
  stage: build
  image: docker:cli
  services:
    - docker:dind  # 启用 Docker-in-Docker 服务，以允许在容器内执行 Docker 命令
  variables:
    IMAGE_TAG: $CI_COMMIT_SHORT_SHA  # 使用提交的短 SHA 作为镜像标签
    IMAGE_URI: $CI_REGISTRY_IMAGE:$IMAGE_TAG  # 使用镜像仓库、项目路径和标签构建完整的镜像 URI
    COSIGN_YES: "true"  # 在 Cosign 中自动确认操作，无需用户交互
    FF_SCRIPT_SECTIONS: "true"  # 启用 极狐GitLab 的 CI 脚本分段功能，以获得更好的多行脚本输出
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore  # 为 Cosign 的无密钥签名提供 OIDC 令牌
  before_script:
    - apk add --no-cache cosign jq  # 安装 Cosign（必需）和 jq（可选）
    - docker login -u "gitlab-ci-token" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"  # 使用 极狐GitLab CI 令牌登录 Docker 镜像仓库
  script:
    # 使用指定的标签构建 Docker 镜像并将其推送到镜像仓库
    - docker build --pull -t "$IMAGE_URI" .
    - docker push "$IMAGE_URI"

    # 获取已推送镜像的摘要，以便在签名步骤中使用
    - IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_URI")

    # 使用 Cosign 对镜像进行签名，并添加注释以提供有关构建的元数据和标签注释，从而允许验证
    # 标签到摘要的映射 (https://github.com/sigstore/cosign?tab=readme-ov-file#tag-signing)
    - |
      cosign sign "$IMAGE_DIGEST" \
        --registry-referrers-mode oci-1-1 \
        --annotations "com.gitlab.ci.user.name=$GITLAB_USER_NAME" \
        --annotations "com.gitlab.ci.pipeline.id=$CI_PIPELINE_ID" \
        --annotations "com.gitlab.ci.pipeline.url=$CI_PIPELINE_URL" \
        --annotations "com.gitlab.ci.job.id=$CI_JOB_ID" \
        --annotations "com.gitlab.ci.job.url=$CI_JOB_URL" \
        --annotations "com.gitlab.ci.commit.sha=$CI_COMMIT_SHA" \
        --annotations "com.gitlab.ci.commit.ref.name=$CI_COMMIT_REF_NAME" \
        --annotations "com.gitlab.ci.project.path=$CI_PROJECT_PATH" \
        --annotations "org.opencontainers.image.source=$CI_PROJECT_URL" \
        --annotations "org.opencontainers.image.revision=$CI_COMMIT_SHA" \
        --annotations "tag=$IMAGE_TAG"

    # 使用 Cosign 验证镜像签名，以确保其与预期的注释和证书身份匹配
    - |
      cosign verify \
        --annotations "tag=$IMAGE_TAG" \
        --certificate-identity "$CI_PROJECT_URL//.gitlab-ci.yml@refs/heads/$CI_COMMIT_REF_NAME" \
        --certificate-oidc-issuer "$CI_SERVER_URL" \
        "$IMAGE_URI" | jq .  # 使用 jq 格式化验证输出，以提高可读性
```