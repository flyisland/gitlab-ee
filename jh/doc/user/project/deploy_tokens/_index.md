---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署令牌
description: 仓库克隆、令牌创建和容器镜像仓库。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

部署令牌提供对极狐GitLab 资源的安全访问，无需将权限绑定到单个用户账户。配合 Git 操作、容器镜像仓库和软件包仓库使用，为部署自动化提供其所需的精确访问权限。

使用部署令牌，您可以获得：

- 通过从自动化系统中移除个人凭证，实现更安全的部署
- 为每个令牌指定特定权限的细粒度访问控制
- 通过内置的身份验证变量简化 CI/CD 流水线
- 不会因团队成员变更而中断的可靠部署流程
- 通过专用令牌身份追踪部署，实现更好的审计跟踪
- 与外部构建系统和部署工具的无缝集成

部署令牌由一对值组成：

- **用户名**：HTTP 身份验证框架中的 `username`。默认用户名格式为 `gitlab+deploy-token-{n}`。您可以在创建部署令牌时指定自定义用户名。
- **令牌**：HTTP 身份验证框架中的 `password`。

部署令牌不支持 [SSH 身份验证](../../ssh.md)。

您可以将部署令牌用于对以下端点的 [HTTP 身份验证](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)：

- 极狐GitLab 软件包仓库公开 API。
- [Git 命令](https://git-scm.com/docs/gitcredentials#_description)。
- [极狐GitLab 虚拟仓库软件包操作](../../../api/maven_virtual_registries.md#manage-package-operations)。

您可以在项目或群组级别创建部署令牌：

- **项目部署令牌**：权限仅适用于该项目。
- **群组部署令牌**：权限适用于群组中的所有项目。

默认情况下，部署令牌不会过期。您可以在创建令牌时根据需要设置到期日期。到期时间为该日期的 UTC 午夜。

> [!warning]
> 如果启用了[外部授权](../../../administration/settings/external_authorization.md)，则无法将新的或现有的部署令牌用于 Git 操作和软件包仓库操作。

<a id="scope"></a>

## 作用域

部署令牌的作用域决定了它可以执行的操作。

| 作用域 | 描述 |
|-------|------|
| `read_repository` | 使用 `git clone` 对仓库进行只读访问。 |
| `read_registry` | 对项目的[容器镜像仓库](../../packages/container_registry/_index.md)中的镜像具有只读访问权限。 |
| `write_registry` | 对项目的[容器镜像仓库](../../packages/container_registry/_index.md)具有写入（推送）权限。您需要同时拥有读写权限才能推送镜像。 |
| `read_virtual_registry` | 通过群组级依赖代理和虚拟注册表授予对容器镜像的只读（拉取）访问权限。不授予对项目容器镜像仓库的直接访问权限。仅在启用依赖代理时可用。 |
| `write_virtual_registry` | 授予对群组级依赖代理缓存的写入权限，并隐式允许通过该缓存进行拉取。不授予对项目容器镜像仓库的推送或删除访问权限。仅在启用依赖代理时可用。 |
| `read_package_registry` | 对项目的软件包仓库具有只读访问权限。 |
| `write_package_registry` | 对项目的软件包仓库具有写入权限。 |

<a id="gitlab-deploy-token"></a>

## 极狐GitLab 部署令牌

{{< history >}}

- 群组级别的 `gitlab-deploy-token` 支持在 极狐GitLab 15.1 中引入，使用功能标志 `ci_variable_for_group_gitlab_deploy_token`。默认启用。
- 功能标志 `ci_variable_for_group_gitlab_deploy_token` 在 极狐GitLab 15.4 中移除。

{{< /history >}}

极狐GitLab 部署令牌是一种特殊的部署令牌。如果您创建名为 `gitlab-deploy-token` 的部署令牌，该令牌会自动作为变量暴露给项目 CI/CD 任务：

- `CI_DEPLOY_USER`：用户名
- `CI_DEPLOY_PASSWORD`：令牌

例如，使用极狐GitLab 令牌登录您的极狐GitLab 容器镜像仓库：

```shell
echo "$CI_DEPLOY_PASSWORD" | docker login $CI_REGISTRY -u $CI_DEPLOY_USER --password-stdin
```

> [!note]
> 在 极狐GitLab 15.0 及更早版本中，对 `gitlab-deploy-token` 部署令牌的特殊处理不适用于群组部署令牌。要使群组部署令牌可用于 CI/CD 任务，请在 **设置** > **CI/CD** > **变量** 中将 `CI_DEPLOY_USER` 和 `CI_DEPLOY_PASSWORD` CI/CD 变量设置为群组部署令牌的名称和令牌。

当群组中定义了 `gitlab-deploy-token` 时，`CI_DEPLOY_USER` 和 `CI_DEPLOY_PASSWORD` CI/CD 变量仅对该群组的直接子项目可用。

<a id="deploy-token-expiration"></a>

## 部署令牌过期

{{< history >}}

- 部署令牌过期邮件通知在 极狐GitLab 18.3 中引入，使用功能标志 `project_deploy_token_expiring_notifications`。默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参阅历史记录。

部署令牌在您定义的日期 UTC 时间 00:00 过期。

极狐GitLab 每天 UTC 时间 01:00 检查即将过期的部署令牌。项目所有者和维护者会在令牌过期前 60、30 和 7 天收到电子邮件通知。

这些邮件通知仅为活跃（未撤销）的部署令牌按每段时间发送一次。

<a id="gitlab-deploy-token-security"></a>

### 极狐GitLab 部署令牌安全性

极狐GitLab 部署令牌生命周期长，容易成为攻击者的目标。

为防止泄露部署令牌，您还应将[Runner](../../../ci/runners/_index.md)配置为安全：

- 如果机器被重复使用，请避免使用 Docker `privileged` 模式。
- 当作业在同一台机器上运行时，避免使用 [`shell` 执行器](https://gitlab.cn/docs/runner/executors/shell/)。

不安全的极狐GitLab Runner 配置会增加攻击者从其他作业窃取令牌的风险。

<a id="gitlab-public-api"></a>

### 极狐GitLab 公共 API

部署令牌不能用于极狐GitLab 公共 API。但是，您可以将部署令牌用于某些端点，例如来自软件包仓库的端点。因为 URL 中包含字符串 `packages/<format>`，所以您可以判断端点属于软件包仓库。例如：`https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/0.0.1/file.txt`。更多信息，请参阅[使用仓库进行身份验证](../../packages/package_registry/supported_functionality.md#authenticate-with-the-registry)。

<a id="create-a-deploy-token"></a>

## 创建部署令牌

创建部署令牌以自动化部署任务，使其可独立于用户账户运行。

先决条件：

- 要创建群组部署令牌，您必须对该群组具有所有者角色。
- 要创建项目部署令牌，您必须对该项目具有维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署令牌**。
1. 选择 **添加令牌**。
1. 填写字段，并选择所需的[作用域](#scope)。
1. 选择 **创建部署令牌**。

记录部署令牌的值。离开或刷新页面后，**您将无法再次访问它们**。

<a id="revoke-a-deploy-token"></a>

## 撤销部署令牌

在不再需要令牌时将其撤销。

先决条件：

- 要撤销群组部署令牌，您必须对该群组具有所有者角色。
- 要撤销项目部署令牌，您必须对该项目具有维护者或所有者角色。

要撤销部署令牌：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **部署令牌**。
1. 在 **活跃的部署令牌** 部分，找到您要撤销的令牌，选择 **撤销**。

<a id="clone-a-repository"></a>

## 克隆仓库

您可以使用部署令牌克隆仓库。

先决条件：

- 具有 `read_repository` 作用域的部署令牌。

使用部署令牌克隆仓库的示例：

```shell
git clone https://<username>:<deploy_token>@gitlab.example.com/tanuki/awesome_project.git
```

<a id="pull-images-from-a-container-registry"></a>

## 从容器镜像仓库拉取镜像

您可以使用部署令牌从容器镜像仓库拉取镜像。

先决条件：

- 具有 `read_registry` 作用域的部署令牌。

使用部署令牌从容器镜像仓库拉取镜像的示例：

```shell
echo "$DEPLOY_TOKEN" | docker login -u <username> --password-stdin registry.example.com
docker pull $CONTAINER_TEST_IMAGE
```

<a id="push-images-to-a-container-registry"></a>

## 推送镜像至容器镜像仓库

您可以使用部署令牌将镜像推送到容器镜像仓库。

先决条件：

- 具有 `read_registry` 和 `write_registry` 作用域的部署令牌。

使用部署令牌将镜像推送到容器镜像仓库的示例：

```shell
echo "$DEPLOY_TOKEN" | docker login -u <username> --password-stdin registry.example.com
docker push $CONTAINER_TEST_IMAGE
```

<a id="pull-packages-from-a-package-registry"></a>

## 从软件包仓库拉取软件包

您可以使用部署令牌从软件包仓库拉取软件包。

先决条件：

- 具有 `read_package_registry` 作用域的部署令牌。

对于您选择的[软件包类型](../../packages/package_registry/supported_functionality.md#authenticate-with-the-registry)，请遵循部署令牌的身份验证说明。

从极狐GitLab 仓库安装 NuGet 软件包的示例：

```shell
nuget source Add -Name GitLab -Source "https://gitlab.example.com/api/v4/projects/10/packages/nuget/index.json" -UserName <username> -Password <deploy_token>
nuget install mypkg.nupkg
```

<a id="push-packages-to-a-package-registry"></a>

## 推送软件包至软件包仓库

您可以使用部署令牌将软件包推送到极狐GitLab 软件包仓库。

先决条件：

- 具有 `write_package_registry` 作用域的部署令牌。

对于您选择的[软件包类型](../../packages/package_registry/supported_functionality.md#authenticate-with-the-registry)，请遵循部署令牌的身份验证说明。

将 NuGet 软件包发布到软件包仓库的示例：

```shell
nuget source Add -Name GitLab -Source "https://gitlab.example.com/api/v4/projects/10/packages/nuget/index.json" -UserName <username> -Password <deploy_token>
nuget push mypkg.nupkg -Source GitLab
```

<a id="pull-images-from-the-dependency-proxy"></a>

## 从依赖代理拉取镜像

您可以使用部署令牌从依赖代理拉取镜像。

先决条件：

- 对于依赖代理：`read_registry` 和 `write_registry` 作用域。
- 对于虚拟注册表：`read_virtual_registry` 和 `write_virtual_registry` 作用域。

请遵循依赖代理的[身份验证说明](../../packages/dependency_proxy/_index.md)。