---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用构建来源数据为容器镜像添加注解'
description: 在极狐GitLab CI/CD 流水线中使用 Cosign 为容器镜像添加构建来源数据注解并签名。
---

注解提供了关于构建过程的宝贵元数据。这些信息可用于审计和可追溯性。在安全事件中，拥有详细的来源数据可以显著加快调查和修复过程。

本教程介绍如何设置极狐GitLab 流水线，通过使用 Cosign 自动完成构建、签名和注解容器镜像的过程。您可以配置 `.gitlab-ci.yml` 文件来构建、推送和签名 Docker 镜像，并将其推送到极狐GitLab 容器镜像仓库。

为容器镜像添加注解：

1. [设置镜像和服务镜像](#set-image-and-service-image)。
1. [定义 CI/CD 变量](#define-cicd-variables)。
1. [准备 OIDC 令牌](#prepare-oidc-token)。
1. [准备容器](#prepare-the-container)。
1. [构建并推送镜像](#build-and-push-the-image)。
1. [使用 Cosign 为镜像签名](#sign-the-image-with-cosign)。
1. [验证签名和注解](#verify-the-signature-and-annotations)。

将所有内容整合在一起后，您的 `.gitlab-ci.yml` 应与本教程末尾提供的[示例配置](#example-gitlab-ciyml-configuration)类似。

<a id="before-you-begin"></a>

## 开始之前

您必须具备：

- 已安装 Cosign v2.0 或更高版本。
- 对于极狐GitLab 私有化部署，极狐GitLab 容器镜像仓库需[配置元数据数据库](../../../administration/packages/container_registry_metadata_database.md)
  才能显示签名。

<a id="set-image-and-service-image"></a>

## 设置镜像和服务镜像

在 `.gitlab-ci.yml` 文件中，使用 `docker:cli` 镜像并启用 Docker-in-Docker 服务，以允许 Docker 命令在 CI/CD 作业中运行。

```yaml
build_and_sign:
  stage: build
  image: docker:cli
  services:
    - docker:dind  # Enable Docker-in-Docker service to allow Docker commands inside the container
```

<a id="define-cicd-variables"></a>

## 定义 CI/CD 变量

使用极狐GitLab CI/CD 预定义变量为镜像标签和 URI 定义变量。

```yaml
variables:
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA  # Use the commit short SHA as the image tag
  IMAGE_URI: $CI_REGISTRY_IMAGE:$IMAGE_TAG  # Construct the full image URI with the registry, project path, and tag
  COSIGN_YES: "true"  # Automatically confirm actions in Cosign without user interaction
  FF_SCRIPT_SECTIONS: "true"  # Enables GitLab's CI script sections for better multi-line script output
```

<a id="prepare-oidc-token"></a>

## 准备 OIDC 令牌

为使用 Cosign 进行无密钥签名设置 OIDC 令牌。

```yaml
id_tokens:
  SIGSTORE_ID_TOKEN:
    aud: sigstore  # Provide an OIDC token for keyless signing with Cosign
```

<a id="prepare-the-container"></a>

## 准备容器

在 `.gitlab-ci.yml` 文件的 `before_script` 部分中：

- 安装 Cosign 和 jq（用于 JSON 处理）：`apk add --no-cache cosign jq`
- 使用 CI/CD 作业令牌启用极狐GitLab 容器镜像仓库登录：`docker login -u "gitlab-ci-token" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"`

流水线首先设置必要的环境。

<a id="build-and-push-the-image"></a>

## 构建并推送镜像

在 `.gitlab-ci.yml` 文件的 `script` 部分中，输入以下命令来构建 Docker 镜像并将其推送到极狐GitLab 容器镜像仓库。

```yaml
- docker build --pull -t "$IMAGE_URI" .
- docker push "$IMAGE_URI"
```

此命令使用当前目录的 Dockerfile 创建镜像，并将其推送到镜像仓库。

<a id="sign-the-image-with-cosign"></a>

## 使用 Cosign 为镜像签名

在构建镜像并将其推送到极狐GitLab 容器镜像仓库后，使用 Cosign 为其签名。

在 `.gitlab-ci.yml` 文件的 `script` 部分中，输入以下命令：

```yaml
- IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_URI")
- |
  cosign sign "$IMAGE_DIGEST" \
    --registry-referrers-mode oci-1-1 \
    --annotations "com.gitlab.ci.user.name=$GITLAB_USER_NAME" \
    --annotations "com.gitlab.ci.pipeline.id=$CI_PIPELINE_ID" \
    # Additional annotations removed for readability
    --annotations "tag=$IMAGE_TAG"
```

此步骤会获取镜像摘要。然后使用 Cosign 为镜像签名，并添加若干注解。

<a id="verify-the-signature-and-annotations"></a>

## 验证签名和注解

为镜像签名后，验证签名和所添加的注解至关重要。

在 `.gitlab-ci.yml` 文件中，使用 `cosign verify` 命令添加验证步骤：

```yaml
- |
  cosign verify \
    --annotations "tag=$IMAGE_TAG" \
    --certificate-identity "$CI_PROJECT_URL//.gitlab-ci.yml@refs/heads/$CI_COMMIT_REF_NAME" \
    --certificate-oidc-issuer "$CI_SERVER_URL" \
    "$IMAGE_URI" | jq .
```

验证步骤可确保附加到镜像的来源数据正确无误，且未被篡改。`cosign verify` 命令会验证签名并检查注解。输出会显示您在签名过程中添加到镜像的所有注解。

在输出中，您可以看到之前添加的所有注解，包括：

- 极狐GitLab 用户名
- 流水线 ID 和 URL
- 作业 ID 和 URL
- 提交 SHA 和引用名称
- 项目路径
- 镜像来源和修订版本

通过验证这些注解，您可以确保镜像的来源数据完好无损，并与您根据构建过程所预期的内容一致。

<a id="example-gitlab-ciyml-configuration"></a>

## 示例 `.gitlab-ci.yml` 配置

当您完成前面所有步骤后，`.gitlab-ci.yml` 文件应如下所示：

```yaml
stages:
  - build

build_and_sign:
  stage: build
  image: docker:cli
  services:
    - docker:dind  # Enable Docker-in-Docker service to allow Docker commands inside the container
  variables:
    IMAGE_TAG: $CI_COMMIT_SHORT_SHA  # Use the commit short SHA as the image tag
    IMAGE_URI: $CI_REGISTRY_IMAGE:$IMAGE_TAG  # Construct the full image URI with the registry, project path, and tag
    COSIGN_YES: "true"  # Automatically confirm actions in Cosign without user interaction
    FF_SCRIPT_SECTIONS: "true"  # Enables GitLab's CI script sections for better multi-line script output
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore  # Provide an OIDC token for keyless signing with Cosign
  before_script:
    - apk add --no-cache cosign jq  # Install Cosign (mandatory) and jq (optional)
    - docker login -u "gitlab-ci-token" -p "$CI_JOB_TOKEN" "$CI_REGISTRY"  # Log in to the Docker registry using GitLab CI token
  script:
    # Build the Docker image using the specified tag and push it to the registry
    - docker build --pull -t "$IMAGE_URI" .
    - docker push "$IMAGE_URI"

    # Retrieve the digest of the pushed image to use in the signing step
    - IMAGE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE_URI")

    # Sign the image using Cosign with annotations that provide metadata about the build and tag annotation to allow verifying
    # the tag->digest mapping (https://github.com/sigstore/cosign?tab=readme-ov-file#tag-signing)
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

    # Verify the image signature using Cosign to ensure it matches the expected annotations and certificate identity
    - |
      cosign verify \
        --annotations "tag=$IMAGE_TAG" \
        --certificate-identity "$CI_PROJECT_URL//.gitlab-ci.yml@refs/heads/$CI_COMMIT_REF_NAME" \
        --certificate-oidc-issuer "$CI_SERVER_URL" \
        "$IMAGE_URI" | jq .  # Use jq to format the verification output for easier readability
```
