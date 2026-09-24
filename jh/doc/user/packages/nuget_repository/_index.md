---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 NuGet 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在您的项目软件包仓库中发布 NuGet 软件包。然后在需要将其用作依赖项时安装它们。

该软件包仓库可与以下工具配合使用：

- [NuGet CLI](https://learn.microsoft.com/en-us/nuget/reference/nuget-exe-cli-reference)
- [.NET Core CLI](https://learn.microsoft.com/en-us/dotnet/core/tools/)

要了解这些客户端使用的具体 API 端点，请参阅 [NuGet API 参考](../../../api/packages/nuget.md)。

了解如何[安装 NuGet](../workflows/build_packages.md#nuget)。

<a id="authenticate-to-the-package-registry"></a>

## 认证到软件包仓库

您需要一个认证令牌来访问极狐GitLab 软件包仓库。根据您的目标，可使用不同的令牌。有关更多信息，请查阅[令牌使用指南](../package_registry/supported_functionality.md#authenticate-with-the-registry)。

- 如果您的组织使用双因素认证（2FA），则必须使用范围设置为 `api` 的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 如果您使用 CI/CD 流水线发布软件包，则可以结合使用 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md) 和私有 Runner。您还可以为实例 Runner [注册一个变量](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)。

<a id="use-the-gitlab-endpoint-for-nuget-packages"></a>

## 使用极狐GitLab 端点操作 NuGet 软件包

您可以使用项目端点或群组端点与极狐GitLab 软件包仓库交互：

- 项目端点：当您有一些不在同一群组中的 NuGet 软件包时使用。
- 群组端点：当您在同一群组的不同项目中有许多 NuGet 软件包时使用。

某些操作（如发布软件包）仅可在项目端点上进行。

由于 NuGet 处理凭据的方式，软件包仓库会拒绝对公共群组的匿名请求。

<a id="add-the-package-registry-as-a-source-for-nuget-packages"></a>

## 将软件包仓库添加为 NuGet 软件包的源

必备条件：

- 您的极狐GitLab 用户名
- 一个认证令牌（以下部分假设使用个人访问令牌）
- 您的源名称
- 项目或群组 ID

<a id="with-the-project-endpoint"></a>

### 使用项目端点

{{< tabs >}}

{{< tab title="NuGet CLI" >}}

要使用 NuGet CLI 将软件包仓库添加为源，请运行以下命令：

```shell
nuget source Add -Name <source_name> -Source "https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/index.json" -UserName <gitlab_username> -Password <personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<project_id>` 为在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)找到的项目 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

例如：

```shell
nuget source Add -Name "GitLab" -Source "https://gitlab.example.com/api/v4/projects/10/packages/nuget/index.json" -UserName carol -Password <your_access_token>
```

{{< /tab >}}

{{< tab title=".NET CLI" >}}

要使用 .NET CLI 将软件包仓库添加为源，请运行以下命令：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/index.json" --name <source_name> --username <gitlab_username> --password <personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<project_id>` 为在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)找到的项目 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

根据您的操作系统，您可能需要追加 `--store-password-in-clear-text` 标志。

例如：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/projects/10/packages/nuget/index.json" --name gitlab --username carol --password <your_access_token> --store-password-in-clear-text
```

{{< /tab >}}

{{< tab title="Chocolatey CLI" >}}

您可以使用 Chocolatey CLI 将软件包仓库添加为源。如果您使用的是 Chocolatey CLI v1.X，则只能添加 NuGet v2 源。

要使用 Chocolatey 将软件包仓库添加为源，请运行以下命令：

```shell
choco source add -n=<source_name> -s "'https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/v2'" -u=<gitlab_username> -p=<personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<project_id>` 为在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)找到的项目 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

例如：

```shell
choco source add -n=gitlab -s "'https://gitlab.example.com/api/v4/projects/10/packages/nuget/v2'" -u=carol -p=<your_access_token>
```

{{< /tab >}}

{{< tab title="配置文件" >}}

要使用 .NET 配置文件将软件包仓库添加为源：

1. 在项目根目录中，创建一个名为 `nuget.config` 的文件。
1. 添加以下配置：

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <configuration>
    <packageSources>
        <clear />
        <add key="gitlab" value="https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/index.json" />
    </packageSources>
    <packageSourceCredentials>
        <gitlab>
            <add key="Username" value="%GITLAB_PACKAGE_REGISTRY_USERNAME%" />
            <add key="ClearTextPassword" value="%GITLAB_PACKAGE_REGISTRY_PASSWORD%" />
        </gitlab>
    </packageSourceCredentials>
   </configuration>
   ```

1. 配置必需的环境变量：

   ```shell
   export GITLAB_PACKAGE_REGISTRY_USERNAME=<gitlab_username>
   export GITLAB_PACKAGE_REGISTRY_PASSWORD=<personal_access_token>
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 以上示例命令添加了一个名为 `gitlab` 的源。后续示例命令均引用源名称（`gitlab`），而非源 URL。

<a id="with-the-group-endpoint"></a>

### 使用群组端点

{{< tabs >}}

{{< tab title="NuGet CLI" >}}

要使用 NuGet CLI 添加源：

```shell
nuget source Add -Name <source_name> -Source "https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/index.json" -UserName <gitlab_username> -Password <personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<group_id>` 为在[群组概览页面](../../group/_index.md#find-the-group-id)找到的群组 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

例如：

```shell
nuget source Add -Name "GitLab" -Source "https://gitlab.example.com/api/v4/groups/23/-/packages/nuget/index.json" -UserName carol -Password <your_access_token>
```

{{< /tab >}}

{{< tab title=".NET CLI" >}}

要使用 .NET CLI 添加源：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/index.json" --name <source_name> --username <gitlab_username> --password <personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<group_id>` 为在[群组概览页面](../../group/_index.md#find-the-group-id)找到的群组 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

根据您的操作系统，可能需要 `--store-password-in-clear-text` 标志。

例如：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/groups/23/-/packages/nuget/index.json" --name gitlab --username carol --password <your_access_token> --store-password-in-clear-text
```

{{< /tab >}}

{{< tab title="Chocolatey CLI" >}}

Chocolatey CLI 仅兼容[项目端点](#with-the-project-endpoint)。

{{< /tab >}}

{{< tab title="配置文件" >}}

要使用 .NET 配置文件添加源：

1. 在项目根目录中，创建一个名为 `nuget.config` 的文件。
1. 添加以下配置：

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <configuration>
    <packageSources>
        <clear />
        <add key="gitlab" value="https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/index.json" />
    </packageSources>
    <packageSourceCredentials>
        <gitlab>
            <add key="Username" value="%GITLAB_PACKAGE_REGISTRY_USERNAME%" />
            <add key="ClearTextPassword" value="%GITLAB_PACKAGE_REGISTRY_PASSWORD%" />
        </gitlab>
    </packageSourceCredentials>
   </configuration>
   ```

1. 配置必需的环境变量：

   ```shell
   export GITLAB_PACKAGE_REGISTRY_USERNAME=<gitlab_username>
   export GITLAB_PACKAGE_REGISTRY_PASSWORD=<personal_access_token>
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 以上示例命令添加了一个名为 `gitlab` 的源。后续示例命令均引用源名称（`gitlab`），而非源 URL。

<a id="publish-a-package"></a>

## 发布软件包

必备条件：

- 将软件包仓库设置为[源](#add-the-package-registry-as-a-source-for-nuget-packages)。
- 配置 [NuGet 软件包的极狐GitLab 项目端点](#with-the-project-endpoint)。

发行软件包时：

- 查看您的极狐GitLab 实例的最大文件大小限制：
  - [JihuLab.com 实例的软件包仓库限制](../../jihulab_com/_index.md#package-registry-limits)按文件格式有所不同，且不可配置。
  - [私有化部署实例的软件包仓库限制](../../../administration/instance_limits.md#file-size-limits)按文件格式有所不同，并且可配置。
- 如果允许重复，并且您多次发布同名同版本的软件包，每次连续上传都会保存为单独的文件。安装软件包时，极狐GitLab 会提供最新的文件。
- 大多数上传的软件包应立即在 **软件包仓库** 页面中可见。少数软件包如果需要在后台处理，则可能需要长达 10 分钟才能显示。

<a id="with-nuget-cli"></a>

### 使用 NuGet CLI

必备条件：

- [使用 NuGet CLI 创建的 NuGet 软件包](https://learn.microsoft.com/en-us/nuget/create-packages/creating-a-package)。

要发布软件包，运行：

```shell
nuget push <package_file> -Source <source_name>
```

替换：

- `<package_file>` 为您的软件包文件名，以 `.nupkg` 结尾。
- `<source_name>` 为您的源名称。

例如：

```shell
nuget push MyPackage.1.0.0.nupkg -Source gitlab
```

<a id="with-net-cli"></a>

### 使用 .NET CLI

{{< history >}}

- 在极狐GitLab 16.1 中引入了使用 `--api-key` 发布软件包的功能。

{{< /history >}}

必备条件：

- [使用 .NET CLI 创建的 NuGet 软件包](https://learn.microsoft.com/en-us/nuget/create-packages/creating-a-package-dotnet-cli)。

发布命令：

```shell
dotnet nuget push <package_file> --source <source_name>
```

替换：

- `<package_file>` 为您的软件包文件名，以 `.nupkg` 结尾。
- `<source_name>` 为您的源名称。

例如：

```shell
dotnet nuget push MyPackage.1.0.0.nupkg --source gitlab
```

您也可以使用 `--api-key` 选项而不是 `username` 和 `password` 来发布软件包：

```shell
dotnet nuget push <package_file> --source <source_url> --api-key <personal_access_token>
```

替换：

- `<package_file>` 为您的软件包文件名，以 `.nupkg` 结尾。
- `<source_url>` 为 NuGet 软件包仓库的 URL。

例如：

```shell
dotnet nuget push MyPackage.1.0.0.nupkg --source https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/index.json --api-key <personal_access_token>
```

<a id="with-chocolatey-cli"></a>

### 使用 Chocolatey CLI

{{< history >}}

- 在极狐GitLab 16.2 中引入了对 NuGet v2 和 Chocolatey CLI 的支持。

{{< /history >}}

必备条件：

- 使用[项目端点](#with-the-project-endpoint)的源。

发布命令：

```shell
choco push <package_file> --source <source_url> --api-key <gitlab_personal_access_token, deploy_token or job token>
```

替换：

- `<package_file>` 为您的软件包文件名，以 `.nupkg` 结尾。
- `<source_url>` 为 NuGet v2 源软件包仓库的 URL。

例如：

```shell
choco push MyPackage.1.0.0.nupkg --source "https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/v2" --api-key <personal_access_token>
```

<a id="with-a-cicd-pipeline"></a>

### 使用 CI/CD 流水线

如果您使用极狐GitLab CI/CD 发布 NuGet 软件包，则可以使用 [`CI_JOB_TOKEN` 预定义变量](../../../ci/jobs/ci_job_token.md) 代替个人访问令牌或部署令牌。作业令牌继承生成流水线的用户或成员的权限。

以下各节中的示例介绍了使用 CI/CD 流水线发布 NuGet 软件包的常见工作流。

<a id="publish-packages-when-the-default-branch-is-updated"></a>

#### 默认分支更新时发布软件包

若要在每次 `main` 分支更新时发布新软件包：

1. 在项目的 `.gitlab-ci.yml` 文件中，添加以下 `deploy` 作业：

   ```yaml
   default:
     # 更新到较新的 SDK 版本
     image: mcr.microsoft.com/dotnet/sdk:7.0

   stages:
     - deploy

   deploy:
     stage: deploy
     script:
       # 在 Release 配置下构建软件包
       - dotnet pack -c Release
       # 将极狐GitLab 软件包仓库配置为 NuGet 源
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # 将软件包推送到项目的软件包仓库
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # 仅在 main 分支上运行
     environment: production
   ```

1. 提交更改并将其推送到极狐GitLab 仓库以触发新的 CI/CD 构建。

<a id="publish-versioned-packages-with-git-tags"></a>

#### 使用 Git 标签发布带版本号的软件包

要使用 [Git 标签](../../project/repository/tags/_index.md)发布带版本号的 NuGet 软件包：

1. 在项目的 `.gitlab-ci.yml` 文件中，添加以下 `deploy` 作业：

   ```yaml
   publish-tagged-version:
     stage: deploy
     script:
       # 使用 Git 标签作为软件包版本
       - dotnet pack -c Release /p:Version=${CI_COMMIT_TAG} /p:PackageVersion=${CI_COMMIT_TAG}
       # 将极狐GitLab 软件包仓库配置为 NuGet 源
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # 将软件包推送到项目的软件包仓库
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_TAG  # 仅在推送标签时运行
   ```

1. 提交更改并将其推送到极狐GitLab 仓库。
1. 推送一个 Git 标签以触发新的 CI/CD 构建。

<a id="publish-conditionally-for-different-environments"></a>

#### 按环境条件发布

您可以将 CI/CD 流水线配置为根据您的用例有选择地将 NuGet 软件包发布到不同环境。

要分别为 `development` 和 `production` 环境有条件地发布 NuGet 软件包：

1. 在项目的 `.gitlab-ci.yml` 文件中，添加以下 `deploy` 作业：

   ```yaml
     # 发布开发/预览版软件包
   publish-dev:
     stage: deploy
     script:
       # 创建带有流水线 ID 的开发版本以确保唯一性
       - VERSION="0.0.1-dev.${CI_PIPELINE_IID}"
       - dotnet pack -c Release /p:Version=$VERSION /p:PackageVersion=$VERSION
       # 将极狐GitLab 软件包仓库配置为 NuGet 源
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # 将软件包推送到项目的软件包仓库
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_BRANCH == "develop"
     environment: development

     # 发布稳定版软件包
   publish-release:
     stage: deploy
     script:
       - dotnet pack -c Release
       # 将极狐GitLab 软件包仓库配置为 NuGet 源
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # 将软件包推送到项目的软件包仓库
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
     environment: production
   ```

1. 提交更改并将其推送到极狐GitLab 仓库。

   使用此 CI/CD 配置：

   - 将 NuGet 软件包推送到 `develop` 分支会将软件包发布到您的 `development` 环境的软件包仓库。
   - 将 NuGet 软件包推送到 `main` 分支会将 NuGet 软件包发布到您的 `production` 环境的软件包仓库。

<a id="turn-off-duplicate-nuget-packages"></a>

### 关闭重复的 NuGet 软件包

{{< history >}}

- 在极狐GitLab 16.3 中引入，并带有功能标志 `nuget_duplicates_option`，默认禁用。
- 在极狐GitLab 16.6 中 GA。功能标志 `nuget_duplicates_option` 已移除。
- 在极狐GitLab 17.0 中，所需角色从维护者变更为所有者。

{{< /history >}}

您可以发布多个同名和同版本的软件包。

要阻止群组成员和用户发布重复的 NuGet 软件包，请关闭 **允许重复** 设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像仓库**。
1. 在 **重复软件包** 表的 **NuGet** 行中，关闭 **允许重复** 切换开关。
1. 可选。在 **例外** 文本框中，输入匹配允许的软件包名称和版本的正则表达式。

您也可以使用 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings) 中的 `nuget_duplicates_allowed` 设置来关闭重复的 NuGet 软件包。

> [!warning]
> 如果 `.nuspec` 文件不在软件包的根目录或存档的开头，则该软件包可能不会立即被识别为重复。当它最终被识别为重复时，**软件包管理器** 页面将显示错误。

<a id="install-a-package"></a>

## 安装软件包

极狐GitLab 软件包仓库可以包含多个同名和同版本的软件包。如果您安装了一个重复的软件包，则会获取最新发布的软件包。

必备条件：

- 将软件包仓库设置为[源](#add-the-package-registry-as-a-source-for-nuget-packages)。
- 配置 [NuGet 软件包的极狐GitLab 端点](#use-the-gitlab-endpoint-for-nuget-packages)。

<a id="from-the-command-line"></a>

### 从命令行安装

{{< tabs >}}

{{< tab title="NuGet CLI" >}}

通过运行以下命令安装软件包的最新版本：

```shell
nuget install <package_id> -OutputDirectory <output_directory> \
  -Version <package_version> \
  -Source <source_name>
```

- `<package_id>`：软件包 ID。
- `<output_directory>`：输出目录，软件包将安装到此目录。
- `<package_version>`：可选。软件包版本。
- `<source_name>`：可选。源名称。
  - `nuget` 会首先在 `nuget.org` 上查找请求的软件包。如果极狐GitLab 软件包仓库中存在与 `nuget.org` 同名的 NuGet 软件包，则您必须指定源名称才能安装正确的软件包。

{{< /tab >}}

{{< tab title=".NET CLI" >}}

> [!note]
> 如果极狐GitLab 软件包仓库中有一个与其它源同名的 NuGet 软件包，请验证 `dotnet` 在安装期间检查源的顺序。此行为由 `nuget.config` 文件定义。

通过运行以下命令安装软件包的最新版本：

```shell
dotnet add package <package_id> \
       -v <package_version>
```

- `<package_id>`：软件包 ID。
- `<package_version>`：可选。软件包版本。

{{< /tab >}}

{{< /tabs >}}

<a id="with-nuget-v2-feed"></a>

### 使用 NuGet v2 源

{{< history >}}

- 在极狐GitLab 16.5 中引入了对 NuGet v2 安装端点的支持。

{{< /history >}}

必备条件：

- 为 Chocolatey 配置了一个 [v2 源源](#with-the-project-endpoint)。
- 使用 NuGet v2 源安装或升级软件包时，必须提供软件包版本。

要使用 Chocolatey CLI 安装软件包：

```shell
choco install <package_id> -Source <source_url> -Version <package_version>
```

- `<package_id>`：软件包 ID。
- `<source_url>`：NuGet v2 源软件包仓库的 URL 或名称。
- `<package_version>`：软件包版本。

例如：

```shell
choco install MyPackage -Source gitlab -Version 1.0.2

# 或

choco install MyPackage -Source "https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/v2" -u <username> -p <personal_access_token> -Version 1.0.2
```

要使用 Chocolatey CLI 升级软件包：

```shell
choco upgrade <package_id> -Source <source_url> -Version <package_version>
```

- `<package_id>`：软件包 ID。
- `<source_url>`：NuGet v2 源软件包仓库的 URL 或名称。
- `<package_version>`：软件包版本。

例如：

```shell
choco upgrade MyPackage -Source gitlab -Version 1.0.3
```

<a id="delete-a-package"></a>

## 删除软件包

{{< history >}}

- 在极狐GitLab 16.5 中引入了对 NuGet 软件包删除的支持。

{{< /history >}}

> [!warning]
> 删除软件包是永久性操作，无法撤消。

必备条件：

- 您必须在项目中至少具有[维护者](../../permissions.md#project-permissions)角色。
- 您必须同时知道软件包名称和版本。

要使用 NuGet CLI 删除软件包：

```shell
nuget delete <package_id> <package_version> -Source <source_name> -ApiKey <personal_access_token>
```

- `<package_id>`：软件包 ID。
- `<package_version>`：软件包版本。
- `<source_name>`：源名称。

例如：

```shell
nuget delete MyPackage 1.0.0 -Source gitlab -ApiKey <personal_access_token>
```

<a id="symbol-packages"></a>

## 符号包
极狐GitLab 可以从 NuGet 软件包仓库使用符号文件。
您可以将极狐GitLab 软件包仓库用作符号服务器来调试您的 NuGet 软件包。

每当您发布 NuGet 软件包文件（`.nupkg`）时，符号包文件（`.snupkg`）会自动上传到 NuGet 软件包仓库。

您也可以手动推送它们：

```shell
nuget push My.Package.snupkg -Source <source_name>
```

<a id="use-the-gitlab-endpoint-for-symbol-files"></a>

### 使用极狐GitLab 端点获取符号文件

{{< history >}}

- 在极狐GitLab 16.7 中引入。

{{< /history >}}

极狐GitLab 软件包仓库提供了一个特殊的 `symbolfiles` 端点，您可以使用项目或群组端点进行配置：

- 项目端点：

  ```plaintext
  https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/symbolfiles
  ```

  - 将 `<project_id>` 替换为项目 ID。
- 群组端点：

  ```plaintext
  https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/symbolfiles
  ```

  - 将 `<group_id>` 替换为群组 ID。

`symbolfiles` 端点是已配置调试器可以推送符号文件的源。

<a id="use-the-package-registry-as-a-symbol-server"></a>

### 将软件包仓库用作符号服务器

要将软件包仓库用作符号服务器：

1. 使用 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings) 启用 `nuget_symbol_server_enabled` 命名空间设置。
1. 配置调试器以使用符号服务器。

例如，要将 Visual Studio 配置为调试器：

1. 选择 **工具** > **首选项**。
1. 选择 **调试器** > **符号源**。
1. 选择 **添加**。
1. 输入符号服务器 URL。
1. 选择 **添加源**。

配置调试器后，您可以像往常一样调试应用程序。如果符号 PDB 文件可用，调试器会自动从软件包仓库下载它们。

<a id="consume-symbol-packages"></a>

#### 使用符号包

当调试器配置为使用符号包时，调试器会在请求中发送以下信息：

- `Symbolchecksum` 标头：符号文件的 SHA-256 校验和。
- `file_name` 请求参数：符号文件的名称。例如，`mypackage.pdb`。
- `signature` 请求参数：PDB 文件的 GUID 和 age。

极狐GitLab 服务器将此信息与符号文件匹配并返回它。

请注意：

- 仅支持可移植 PDB 文件。
- 由于调试器无法提供身份验证令牌，符号服务器端点不支持典型的身份验证方法。极狐GitLab 服务器需要 `signature` 和 `Symbolchecksum` 来返回正确的符号文件。

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

{{< history >}}

- 在极狐GitLab 16.5 中引入 `nuget delete` 和 `dotnet nuget delete` 命令。

{{< /history >}}

极狐GitLab NuGet 仓库支持以下 NuGet CLI (`nuget`) 和 .NET CLI (`dotnet`) 的命令：

| NuGet | .NET | 描述 |
|-----------|----------|-------------|
| `nuget push` | `dotnet nuget push` | 将软件包上传到仓库。 |
| `nuget install` | `dotnet add` | 从仓库安装软件包。 |
| `nuget delete` | `dotnet nuget delete` | 从仓库删除软件包。 |

<a id="troubleshooting"></a>

## 故障排除

使用 NuGet 软件包时，您可能会遇到以下问题。

<a id="clear-the-nuget-cache"></a>

### 清除 NuGet 缓存

为了提高性能，NuGet 会缓存软件包文件。如果遇到存储问题，请使用以下命令清除缓存：

```shell
nuget locals all -clear
```

<a id="errors-when-publishing-nuget-packages-in-a-docker-based-gitlab-installation"></a>

### 在基于 Docker 的极狐GitLab 安装中发布 NuGet 软件包时的错误

发布 NuGet 软件包时，您可能会收到以下错误消息：

- `Error publishing`
- `Invalid Package: Failed metadata extraction error`

为了防止利用内部 Web 服务，对本地网络地址的 Webhook 请求被阻止。

要解决这些错误，请更改网络设置以[允许 Webhook 和集成请求访问本地网络](../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。