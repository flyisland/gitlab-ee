---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从容器镜像仓库删除容器镜像
description: 在极狐GitLab 中删除容器镜像的自动和手动方法。
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以从容器镜像仓库中删除容器镜像。

要根据特定条件自动删除容器镜像，请使用[垃圾回收](#garbage-collection)。
或者，你也可以使用第三方工具[创建 CI/CD 作业](#use-gitlab-cicd)
来删除特定项目中的容器镜像。

要删除项目或群组中的特定容器镜像，你可以使用[极狐GitLab UI](#use-the-gitlab-ui)
或[极狐GitLab API](#use-the-gitlab-api)。

> [!warning]
> 删除容器镜像是破坏性操作，无法撤销。要恢复
> 已删除的容器镜像，必须重建并重新上传它。

<a id="garbage-collection"></a>

## 垃圾回收

在极狐GitLab 私有化部署实例上删除容器镜像并不会释放存储空间，它只会将该镜像标记为符合删除条件。要真正删除未被引用的容器镜像并回收存储空间，极狐GitLab 私有化部署实例管理员必须运行[垃圾回收](../../../administration/packages/container_registry.md#container-registry-garbage-collection)。

JihuLab.com 上的容器镜像仓库包含自动在线垃圾回收器。利用自动垃圾回收器，如果以下内容在 24 小时后仍未被引用，则会自动调度删除：

- 未被任何镜像清单引用的层。
- 没有标签并且未被其他清单引用的镜像清单（例如多架构镜像）。

在线垃圾回收器是实例范围的功能，适用于所有命名空间。

<a id="use-the-gitlab-ui"></a>

## 使用极狐GitLab UI

要使用极狐GitLab UI 删除容器镜像：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 对于：
   - 群组，选择 **运维** > **容器镜像仓库**。
   - 项目，选择 **部署** > **容器镜像仓库**。
1. 在 **容器镜像仓库** 页面，你可以选择要删除的内容，通过以下方式：

   - 删除整个仓库及其包含的所有标签，可选红色的 {{< icon name="remove" >}} **垃圾桶** 图标。
   - 进入仓库，并通过选择要删除的标签旁边的红色 {{< icon name="remove" >}} **垃圾桶** 图标来单独或批量删除标签。

1. 在对话框中，选择 **删除标签**。

[删除失败超过 10 次](../../../administration/packages/container_registry.md#max-retries-for-deleting-container-images) 的容器仓库会自动停止尝试删除镜像。

<a id="use-the-gitlab-api"></a>

## 使用极狐GitLab API

你可以使用 API 自动执行删除容器镜像的过程。有关更多信息，请参阅以下端点：

- [删除仓库](../../../api/container_registry.md#delete-registry-repository)
- [删除单个仓库标签](../../../api/container_registry.md#delete-a-registry-repository-tag)
- [批量删除仓库标签](../../../api/container_registry.md#delete-registry-repository-tags-in-bulk)

<a id="use-gitlab-cicd"></a>

## 使用极狐GitLab CI/CD

> [!note]
> 极狐GitLab CI/CD 不提供内置删除容器镜像的方法。本示例使用名为 [`regctl`](https://github.com/regclient/regclient) 的第三方工具，该工具与极狐GitLab Registry API 通信。如果需要此第三方工具帮助，请参阅 [regclient 议题跟踪](https://github.com/regclient/regclient/issues)。

下面的例子定义了两个阶段：`build` 和 `clean`。`build_image` 作业为该分支构建容器镜像，而 `delete_image` 作业则将其删除。下载 `reg` 可执行文件，用于删除与 `$CI_PROJECT_PATH:$CI_COMMIT_REF_SLUG` [预定义 CI/CD 变量](../../../ci/variables/predefined_variables.md) 匹配的容器镜像。

要使用此示例，请根据你的需要修改 `IMAGE_TAG` 变量。

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
> 你可以从[发布页面](https://github.com/regclient/regclient/releases)下载最新的 `regctl` 版本，然后通过修改 `delete_image` 作业中定义的 `REGCTL_VERSION` 变量来更新代码示例。

<a id="use-a-cleanup-policy"></a>

## 使用清理策略

你可以创建每个项目的[清理策略](reduce_container_registry_storage.md#cleanup-policy)，以确保旧标签和镜像定期从容器镜像仓库中移除。

