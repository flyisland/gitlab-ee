---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 容器镜像仓库
description: Use the GitLab Container Registry to store container images for your GitLab project.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以使用集成的容器镜像仓库为每个极狐GitLab 项目存储容器镜像。

管理员必须为你的极狐GitLab 实例启用容器镜像仓库。更多信息，请参阅[极狐GitLab 容器镜像仓库管理](../../../administration/packages/container_registry.md)。

> [!note]
> 如果你从 Docker Hub 拉取容器镜像，可以使用[极狐GitLab 依赖代理](../dependency_proxy/_index.md#use-the-dependency-proxy-for-docker-images)来避免速率限制并加速你的流水线。

<a id="view-the-container-registry"></a>

## 查看容器镜像仓库

你可以查看项目或群组的容器镜像仓库。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **部署** > **容器镜像仓库**。

你可以搜索、排序、过滤以及[删除](delete_container_registry_images.md#use-the-gitlab-ui)你的容器镜像。你可以通过复制浏览器中的 URL 来分享过滤后的视图。

<a id="view-the-tags-of-a-specific-container-image-in-the-container-registry"></a>

### 在容器镜像仓库中查看特定容器镜像的标签

你可以使用容器镜像仓库的 **标签详情** 页面来查看与给定容器镜像关联的标签列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **部署** > **容器镜像仓库**。
1. 选择你的容器镜像。

你可以查看每个标签的详细信息，例如发布时间、占用的存储空间以及清单和配置摘要。

你可以在此页面上搜索、排序（按标签名称）和删除标签。你可以通过复制浏览器中的 URL 来分享过滤后的视图。

<a id="storage-usage"></a>

### 存储用量

查看容器镜像仓库存储用量，以跟踪和管理跨项目和群组的容器仓库大小。

更多信息，请参阅[查看容器镜像仓库用量](reduce_container_registry_storage.md#view-container-registry-usage)。

<a id="use-container-images-from-the-container-registry"></a>

## 使用容器镜像仓库中的容器镜像

要下载并运行托管在容器镜像仓库中的容器镜像：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **部署** > **容器镜像仓库**。
1. 找到你想要使用的容器镜像，然后选择 **复制镜像路径** （{{< icon name="copy-to-clipboard" >}}）。
1. 使用 `docker run` 命令并附上复制的链接：

   ```shell
   docker run [options] registry.example.com/group/project/image [arguments]
   ```

> [!note]
> 你必须通过容器镜像仓库的身份验证，才能从私有仓库下载容器镜像。
> 更多信息，请参阅[容器镜像仓库身份验证](authenticate_with_container_registry.md)。

<a id="naming-convention-for-your-container-images"></a>

## 容器镜像的命名约定

你的容器镜像必须遵循以下命名约定：

```plaintext
<registry server>/<namespace>/<project>[/<optional path>]
```

例如，如果你的项目是 `gitlab.example.com/mynamespace/myproject`，那么你的容器镜像必须命名为 `gitlab.example.com/mynamespace/myproject`。

你可以在容器镜像名称的末尾追加额外的名称，最多两级深度。

例如，以下都是项目 `myproject` 中容器镜像的有效名称：

```plaintext
registry.example.com/mynamespace/myproject:some-tag
```

```plaintext
registry.example.com/mynamespace/myproject/image:latest
```

```plaintext
registry.example.com/mynamespace/myproject/my/image:rc1
```

<a id="move-or-rename-container-registry-repositories"></a>

## 移动或重命名容器镜像仓库

{{< history >}}

- 在极狐GitLab 16.7 中在 JihuLab.com 上启用。

{{< /history >}}

容器仓库的路径始终与相关项目的仓库路径匹配，因此无法仅重命名或移动容器镜像仓库。你可以选择：

- [重命名项目的仓库](../../project/working_with_projects.md#rename-a-repository)。
- [转移项目](../../project/working_with_projects.md#transfer-a-project)。

出于性能原因，重命名包含容器仓库的项目仅限于最多拥有 1,000 个容器仓库的项目。

在私有化部署实例上，你可以在移动或重命名群组或项目之前删除所有容器镜像。

<a id="disable-the-container-registry-for-a-project"></a>

## 为项目禁用容器镜像仓库

容器镜像仓库默认启用。

但是，你可以为项目移除容器镜像仓库：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **可见性、项目功能、权限** 部分，然后禁用 **容器镜像仓库**。
1. 选择 **保存更改**。

**部署** > **容器镜像仓库** 条目将从项目的侧边栏中移除。

<a id="change-visibility-of-the-container-registry"></a>

## 更改容器镜像仓库的可见性

默认情况下，容器镜像仓库对所有有权访问项目的人可见。但是，你可以更改项目的容器镜像仓库可见性。

有关此设置授予用户的权限的更多信息，请参阅[容器镜像仓库可见性权限](#container-registry-visibility-permissions)。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **可见性、项目功能、权限** 部分。
1. 在 **容器镜像仓库** 下，从下拉列表中选择一个选项：

   - **所有有访问权限的人**（默认）：容器镜像仓库对所有有权访问项目的人可见。如果项目是公开的，容器镜像仓库也是公开的。如果项目是内部或私有的，容器镜像仓库也是内部或私有的。

   - **仅项目成员**：容器镜像仓库仅对具有报告者、开发者、维护者或所有者角色的项目成员可见。此可见性类似于将容器镜像仓库可见性设置为 **所有有访问权限的人** 的私有项目的行为。

1. 选择 **保存更改**。

<a id="container-registry-visibility-permissions"></a>

## 容器镜像仓库可见性权限

查看容器镜像仓库和拉取容器镜像的能力由容器镜像仓库的可见性权限控制。你可以通过 UI 上的可见性设置或 [API](../../../api/container_registry.md#change-the-visibility-of-the-container-registry) 来更改可见性。

其他权限，例如更新容器镜像仓库以及推送或删除容器镜像，不受此设置影响。但是，禁用容器镜像仓库会禁用所有容器镜像仓库操作。更多信息，请参阅[角色和权限](../../permissions.md)。

|                                                                                                                   |                                               | 匿名用户<br/>（互联网上的任何人） | 访客 | 报告者、开发者、维护者、所有者 |
|-------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|--------------------------------------|-------|----------------------------------------|
| 公开项目，容器镜像仓库可见性 <br/> 设置为 **所有有访问权限的人**（UI）或 `enabled`（API）   | 查看容器镜像仓库 <br/> 并拉取镜像 | 是                                  | 是   | 是                                    |
| 公开项目，容器镜像仓库可见性 <br/> 设置为 **仅项目成员**（UI）或 `private`（API）   | 查看容器镜像仓库 <br/> 并拉取镜像 | 否                                   | 否    | 是                                    |
| 内部项目，容器镜像仓库可见性 <br/> 设置为 **所有有访问权限的人**（UI）或 `enabled`（API） | 查看容器镜像仓库 <br/> 并拉取镜像 | 否                                   | 是   | 是                                    |
| 内部项目，容器镜像仓库可见性 <br/> 设置为 **仅项目成员**（UI）或 `private`（API） | 查看容器镜像仓库 <br/> 并拉取镜像 | 否                                   | 否    | 是                                    |
| 私有项目，容器镜像仓库可见性 <br/> 设置为 **所有有访问权限的人**（UI）或 `enabled`（API）  | 查看容器镜像仓库 <br/> 并拉取镜像 | 否                                   | 否    | 是                                    |
| 私有项目，容器镜像仓库可见性 <br/> 设置为 **仅项目成员**（UI）或 `private`（API）  | 查看容器镜像仓库 <br/> 并拉取镜像 | 否                                   | 否    | 是                                    |
| 任何项目，容器镜像仓库 `disabled`                                                                    | 容器镜像仓库上的所有操作          | 否                                   | 否    | 否                                     |

<a id="supported-image-types"></a>

## 支持的镜像类型

{{< history >}}

- OCI 合规性在极狐GitLab 16.6 中引入。

{{< /history >}}

容器镜像仓库支持 [Docker V2](https://distribution.github.io/distribution/spec/manifest-v2-2/) 和 [Open Container Initiative (OCI)](https://github.com/opencontainers/image-spec/blob/main/spec.md) 镜像格式。此外，容器镜像仓库[符合 OCI 分发规范](https://conformance.opencontainers.org/#gitlab-container-registry)。

OCI 支持意味着你可以在镜像仓库中托管基于 OCI 的镜像格式，例如 Helm 3+ chart 软件包。在极狐GitLab API 和 UI 中，镜像格式之间没有区别。

<a id="container-image-signatures"></a>

## 容器镜像签名

{{< history >}}

- 容器镜像签名显示在极狐GitLab 17.1 中引入。

{{< /history >}}

在极狐GitLab 容器镜像仓库中，你可以使用 [OCI 1.1 manifest `subject` 字段](https://github.com/opencontainers/image-spec/blob/v1.1.0/manifest.md)将容器镜像与 [Cosign 签名](../../../ci/yaml/signing_examples.md)关联起来。然后，你可以查看签名信息及其关联的容器镜像，而无需搜索该签名的标签。

查看容器镜像的标签时，你会看到每个具有关联签名的标签旁边显示一个图标。要查看签名的详细信息，请选择该图标。

先决条件：

- 要签名容器镜像，需要 Cosign v2.0 或更高版本。
- 对于私有化部署，你需要一个配置了元数据数据库的极狐GitLab 容器镜像仓库才能显示签名。更多信息，请参阅[容器镜像仓库元数据数据库](../../../administration/packages/container_registry_metadata_database.md)。

<a id="sign-container-images-with-oci-referrer-data"></a>

### 使用 OCI 引用数据签名容器镜像

要使用 Cosign 向签名添加引用数据，你必须：

- 将 `COSIGN_EXPERIMENTAL` 环境变量设置为 `1`。
- 在签名命令中添加 `--registry-referrers-mode oci-1-1`。

例如：

```shell
COSIGN_EXPERIMENTAL=1 cosign sign --registry-referrers-mode oci-1-1 <container image>
```

> [!note]
> 虽然极狐GitLab 容器镜像仓库支持 OCI 1.1 manifest `subject` 字段，但它并未完全实现 [OCI 1.1 Referrers API](https://github.com/opencontainers/distribution-spec/blob/v1.1.0/spec.md#listing-referrers)。