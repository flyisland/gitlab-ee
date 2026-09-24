---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查极狐GitLab 容器镜像仓库问题
description: 排查极狐GitLab 容器镜像仓库常见错误的技巧。
---

您必须以管理员权限登录极狐GitLab 才能排查大部分极狐GitLab 容器镜像仓库问题。

您可以在极狐GitLab 容器镜像仓库管理文档中找到[更多故障排查信息](../../../administration/packages/container_registry_troubleshooting.md)。

<a id="migrating-oci-container-images-to-gitlab-container-registry"></a>

## 将 OCI 容器镜像迁移到极狐GitLab 容器镜像仓库

不支持将容器镜像迁移到极狐GitLab 容器镜像仓库，但有[史诗](https://gitlab.com/groups/gitlab-org/-/epics/5210)提议改变此行为。

您可以使用第三方工具迁移容器镜像。例如，[skopeo](https://github.com/containers/skopeo) 可以在各种存储机制之间[复制容器镜像](https://github.com/containers/skopeo#copying-images)。您可以使用 skopeo 从容器镜像仓库、容器存储后端、本地目录和本地 OCI 布局目录复制镜像到极狐GitLab 容器镜像仓库。

<a id="docker-connection-error"></a>

## Docker 连接错误

当群组、项目或分支名称中包含特殊字符时，可能会发生 Docker 连接错误。特殊字符包括：

- 前导下划线。
- 尾部连字符或破折号。

要解决此错误，您可以更改[群组路径](../../group/manage.md#change-a-groups-path)、[项目路径](../../project/working_with_projects.md#rename-a-repository)或分支名称。

如果您使用 Docker Engine 17.11 或更早版本，可能会收到 `404 Not Found` 或 `Unknown Manifest` 错误信息。当前版本的 Docker Engine 使用 [v2 API](https://distribution.github.io/distribution/spec/manifest-v2-2/)。

您的极狐GitLab 容器镜像仓库中的镜像必须使用 Docker v2 API。有关如何将版本 1 镜像更新为版本 2 的信息，请参阅 [Docker 文档](https://distribution.github.io/distribution/spec/deprecated-schema-v1/)。

<a id="blob-unknown-to-registry-error-when-pushing-a-manifest-list"></a>

## 推送 Manifest 列表时出现 `Blob unknown to registry` 错误

当[推送 Docker manifest 列表](https://docs.docker.com/reference/cli/docker/manifest/#create-and-push-a-manifest-list)到极狐GitLab 容器镜像仓库时，您可能会收到错误 `manifest blob unknown: blob unknown to registry`。此错误通常是因为多个具有不同架构的镜像分散在多个仓库中，而不是放在同一个仓库中。

例如，您可能有两个镜像，分别代表一种架构：

- `amd64` 平台。
- `arm64v8` 平台。

要使用这些镜像构建多架构镜像，您必须将它们推送到与多架构镜像相同的仓库中。

要解决 `Blob unknown to registry` 错误，请在各个镜像的标签名称中包含架构信息。例如，使用 `mygroup/myapp:1.0.0-amd64` 和 `mygroup/myapp:1.0.0-arm64v8`。然后您可以将 manifest 列表标记为 `mygroup/myapp:1.0.0`。

<a id="unable-to-change-project-path-or-transfer-a-project"></a>

## 无法更改项目路径或转移项目

如果您尝试更改项目路径或将项目转移到新的命名空间，可能会收到以下错误之一：

- 无法转移项目，因为其容器镜像仓库中存在标签。
- 无法移动命名空间，因为至少有一个项目在容器镜像仓库中有标签。

此错误发生在项目在容器镜像仓库中有镜像时。在更改路径或转移项目之前，您必须删除或移动这些镜像。

以下步骤使用这些示例项目名称：

- 当前项目：`gitlab.example.com/org/build/sample_project/cr:v2.9.1`。
- 新项目：`gitlab.example.com/new_org/build/new_sample_project/cr:v2.9.1`。

1. 将 Docker 镜像下载到您的计算机：

   ```shell
   docker login gitlab.example.com
   docker pull gitlab.example.com/org/build/sample_project/cr:v2.9.1
   ```

   > [!note]
   > 使用[个人访问令牌](../../profile/personal_access_tokens.md)或[部署令牌](../../project/deploy_tokens/_index.md)来验证您的用户账户。

1. 重命名镜像以匹配新项目名称：

   ```shell
   docker tag gitlab.example.com/org/build/sample_project/cr:v2.9.1 gitlab.example.com/new_org/build/new_sample_project/cr:v2.9.1
   ```

1. 使用 [UI](delete_container_registry_images.md) 或 [API](../../../api/packages.md#delete-a-project-package) 删除旧项目中的镜像。镜像排队和删除期间可能会有延迟。
1. 更改路径或转移项目：

   1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
   1. 选择 **设置** > **通用**。
   1. 展开 **高级** 部分。
   1. 在 **更改路径** 文本框中，编辑路径。
   1. 选择 **更改路径**。

1. 恢复镜像：

   ```shell
   docker push gitlab.example.com/new_org/build/new_sample_project/cr:v2.9.1
   ```

详情请参见此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18383)。

<a id="failed-to-pull-image-messages"></a>

## `Failed to pull image` 信息

当 CI/CD 作业因为项目限制了 [CI/CD 作业令牌范围](../../../ci/jobs/ci_job_token.md#limit-job-token-scope-for-public-or-internal-projects)而无法拉取容器镜像时，您可能会收到 [`Failed to pull image`](../../../ci/debugging.md#failed-to-pull-image-messages) 错误信息。

<a id="oci-manifest-found-but-accept-header-does-not-support-oci-manifests-error"></a>

## `OCI manifest found, but accept header does not support OCI manifests` 错误

如果您无法拉取镜像，仓库日志中可能会出现类似以下的错误：

```plaintext
manifest unknown: OCI manifest found, but accept header does not support OCI manifests
```

此错误发生在客户端未提交正确的 `Accept: application/vnd.oci.image.manifest.v1+json` 标头时。请确保您的 Docker 客户端版本是最新的。如果您使用第三方工具，请确保它可以处理 OCI 清单。