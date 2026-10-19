---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从容器镜像仓库中删除容器镜像
description: 在极狐GitLab 中删除容器镜像的自动和手动方法。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以从容器镜像仓库中删除容器镜像。

要根据特定条件自动删除容器镜像，请使用[垃圾回收](#garbage-collection)。或者，您可以使用第三方工具[创建 CI/CD 作业](#use-gitlab-cicd)，以从特定项目中删除容器镜像。

要从项目或群组中删除特定容器镜像，您可以使用[极狐GitLab UI](#use-the-gitlab-ui)
或[极狐GitLab API](#use-the-gitlab-api)。

> [!warning]
> 删除容器镜像是一种破坏性操作，且无法撤销。要恢复已删除的
> 容器镜像，您必须重新构建并重新上传它。

<a id="garbage-collection"></a>

## 垃圾回收

在极狐GitLab 私有化部署实例上删除容器镜像不会释放存储空间，只会将该镜像标记为可删除。要真正删除未被引用的容器镜像并回收存储空间，极狐GitLab 私有化部署实例管理员必须运行[垃圾回收](../../../administration/packages/container_registry.md#container-registry-garbage-collection)。

JihuLab.com 上的容器镜像仓库包含一个自动在线垃圾回收器。借助自动垃圾回收器，以下内容如果一直未被引用，将在 24 小时内自动安排删除：

- 未被任何镜像清单引用的层。
- 没有任何标签且未被其他清单引用的镜像清单（例如多架构镜像）。

在线垃圾回收器是实例级功能，适用于所有命名空间。

<a id="use-the-gitlab-ui"></a>

## 使用极狐GitLab UI

要使用极狐GitLab UI 删除容器镜像：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 对于：
   - 群组，选择**运维** > **容器镜像仓库**。
   - 项目，选择**部署** > **容器镜像仓库**。
1. 在**容器镜像仓库**页面上，您可以通过以下任一方式选择要删除的内容：

   - 通过选择红色的 {{< icon name="remove" >}} **垃圾桶**图标，删除整个容器仓库及其包含的所有标签。
   - 通过选择要删除的标签旁边的红色 {{< icon name="remove" >}} **垃圾桶**图标，导航到该容器仓库，并逐个或批量删除标签。

1. 在对话框中，选择**移除标签**。

[删除失败超过 10 次](../../../administration/packages/container_registry.md#max-retries-for-deleting-container-images)的容器仓库会自动停止尝试删除镜像。

<a id="use-the-gitlab-api"></a>

## 使用极狐GitLab API

您可以使用 API 来自动执行删除容器镜像的过程。更多信息，请参见以下端点：

- [删除 Registry 容器仓库](../../../api/container_registry.md#delete-registry-repository)
- [删除单个 Registry 容器仓库标签](../../../api/container_registry.md#delete-a-registry-repository-tag)
- [批量删除 Registry 容器仓库标签](../../../api/container_registry.md#delete-registry-repository-tags-in-bulk)

<a id="use-gitlab-cicd"></a>

## 使用极狐GitLab CI/CD

> [!note]
> 极狐GitLab CI/CD 不提供删除容器镜像的内置方式。此示例使用一个
> 名为 [`regctl`](https://github.com/regclient/regclient)的第三方工具，它与极狐GitLab Registry API 通信。
> 有关此第三方工具的帮助，请参见 [regclient 的议题跟踪器](https://github.com/regclient/regclient/issues)。

以下示例定义了两个阶段：`build` 和 `clean`。`build_image` 作业为该分支构建一个容器镜像，而 `delete_image` 作业将其删除。`reg` 可执行文件会被下载并用于删除与 `$CI_PROJECT_PATH:$CI_COMMIT_REF_SLUG` [预定义 CI/CD 变量](../../../ci/variables/predefined_variables.md)匹配的容器镜像。

要使用此示例，请更改 `IMAGE_TAG` 变量以满足您的需求。

```yaml
stages:
  - build
  - clean

build_image:
  image: docker:20.10.16
  stage: build
  services:
    - docker:20.10.16-dind
  variables:
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
  rules:
      - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
        when: never
      - if: $CI_COMMIT_BRANCH

delete_image:
  stage: clean
  variables:
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
    REGCTL_VERSION: v0.6.1
  rules:
      - if: $CI_COMMIT_REF_NAME != $CI_DEFAULT_BRANCH
  image: alpine:latest
  script:
    - apk update
    - apk add curl
    - curl --fail-with-body --location "https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-amd64" > /usr/bin/regctl
    - chmod 755 /usr/bin/regctl
    - regctl registry login ${CI_REGISTRY} -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD}
    - regctl tag rm $IMAGE
```

> [!note]
> 您可以从[发布页面](https://github.com/regclient/regclient/releases)下载最新的 `regctl` 版本，然后通过更改
> `delete_image` 作业中定义的 `REGCTL_VERSION` 变量来更新代码示例。

<a id="use-a-cleanup-policy"></a>

## 使用清理策略

您可以创建按项目的[清理策略](reduce_container_registry_storage.md#cleanup-policy)，以确保较旧的标签和镜像定期从容器镜像仓库中移除。
