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

在项目的软件包仓库中发布 NuGet 软件包。之后，当您需要将它们用作依赖项时，可以随时安装这些软件包。

软件包仓库可与以下工具配合使用：

- [NuGet CLI](https://learn.microsoft.com/en-us/nuget/reference/nuget-exe-cli-reference)
- [.NET Core CLI](https://learn.microsoft.com/en-us/dotnet/core/tools/)
- [Visual Studio](https://visualstudio.microsoft.com/vs/)

要了解这些客户端使用的具体 API 端点，请参阅 [NuGet API 参考](../../../api/packages/nuget.md)。

了解如何[安装 NuGet](../workflows/build_packages.md#nuget)。

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库进行身份验证

您需要一个身份验证令牌才能访问极狐GitLab 软件包仓库。根据您要实现的目标，可以使用不同的令牌。有关更多信息，请查看[令牌相关指南](../package_registry/supported_functionality.md#authenticate-with-the-registry)。

- 如果您的组织使用双重身份验证（2FA），则必须使用作用域设置为 `api`的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 如果您使用 CI/CD 流水线发布软件包，则可以在私有 runner 上使用 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。您还可以为实例 runner [注册变量](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)。

<a id="use-the-gitlab-endpoint-for-nuget-packages"></a>

## 使用极狐GitLab 端点处理 NuGet 软件包

您可以使用项目端点或群组端点与极狐GitLab 软件包仓库交互：

- 项目端点：当您只有少量 NuGet 软件包，且它们不在同一个群组中时使用。
- 群组端点：当您在同一群组下的不同项目中有许多 NuGet 软件包时使用。

某些操作（例如发布软件包）仅在项目端点上可用。

由于 NuGet 处理凭据的方式，软件包仓库会拒绝向公开群组发出的匿名请求。

<a id="add-the-package-registry-as-a-source-for-nuget-packages"></a>

## 将软件包仓库添加为 NuGet 软件包的源

要将软件包发布到软件包仓库并从其中安装软件包，您必须将软件包仓库添加为软件包的源。

先决条件：

- 您的极狐GitLab 用户名
- 一个身份验证令牌（以下各节假定使用个人访问令牌）
- 源的名称
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
- `<project_id>` 为在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上找到的项目 ID
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
- `<project_id>` 为在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上找到的项目 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

根据您的操作系统，您可能需要在该命令后追加 `--store-password-in-clear-text`。

例如：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/projects/10/packages/nuget/index.json" --name gitlab --username carol --password <your_access_token> --store-password-in-clear-text
```

{{< /tab >}}

{{< tab title="Chocolatey CLI" >}}

您可以使用 Chocolatey CLI 将软件包仓库添加为源。如果您使用 Chocolatey CLI v1.X，则只能添加 NuGet v2 源。

要将软件包仓库添加为 Chocolatey 的源，请运行以下命令：

```shell
choco source add -n=<source_name> -s "'https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/v2'" -u=<gitlab_username> -p=<personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<project_id>` 为在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上找到的项目 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

例如：

```shell
choco source add -n=gitlab -s "'https://gitlab.example.com/api/v4/projects/10/packages/nuget/v2'" -u=carol -p=<your_access_token>
```

{{< /tab >}}

{{< tab title="Visual Studio" >}}

要使用 Visual Studio 将软件包仓库添加为源：

1. 打开 [Visual Studio](https://visualstudio.microsoft.com/vs/)。
1. 在 Windows 上，选择**工具** > **选项**。在 macOS 上，选择 **Visual Studio** > **首选项**。
1. 在 **NuGet** 部分中，选择**源**以查看所有 NuGet 源的列表。
1. 选择**添加**。
1. 填写以下字段：

   - **名称**：源的名称。
   - **源**：`https://gitlab.example.com/api/v4/projects/<project_id>/packages/nuget/index.json`，
     其中 `<project_id>` 是您的项目 ID，`gitlab.example.com` 是
     您的域名。

1. 选择**保存**。
1. 当您访问该软件包时，必须输入您的**用户名**和**密码**：

   - **用户名**：您的极狐GitLab 用户名。
   - **密码**：您的个人访问令牌。

该源会显示在您的列表中。

如果您收到警告，请确保**源**、**用户名**和
**密码**均正确。

{{< /tab >}}

{{< tab title="配置文件" >}}

要使用 .NET 配置文件将软件包仓库添加为源：

1. 在项目的根目录中，创建一个名为 `nuget.config`的文件。
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

1. 配置必要的环境变量：

   ```shell
   export GITLAB_PACKAGE_REGISTRY_USERNAME=<gitlab_username>
   export GITLAB_PACKAGE_REGISTRY_PASSWORD=<personal_access_token>
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 前面的示例命令添加了一个名为 `gitlab`的源。后续示例命令引用的是源名称（`gitlab`），而不是源 URL。

<a id="with-the-group-endpoint"></a>

### 使用群组端点

{{< tabs >}}

{{< tab title="NuGet CLI" >}}

要使用 NuGet CLI 将软件包仓库添加为源：

```shell
nuget source Add -Name <source_name> -Source "https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/index.json" -UserName <gitlab_username> -Password <personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<group_id>` 为在[群组概览页面](../../group/_index.md#find-the-group-id)上找到的群组 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

例如：

```shell
nuget source Add -Name "GitLab" -Source "https://gitlab.example.com/api/v4/groups/23/-/packages/nuget/index.json" -UserName carol -Password <your_access_token>
```

{{< /tab >}}

{{< tab title=".NET CLI" >}}

要使用 .NET CLI 将软件包仓库添加为源：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/index.json" --name <source_name> --username <gitlab_username> --password <personal_access_token>
```

替换：

- `<source_name>` 为您的源名称
- `<group_id>` 为在[群组概览页面](../../group/_index.md#find-the-group-id)上找到的群组 ID
- `<gitlab_username>` 为您的极狐GitLab 用户名
- `<personal_access_token>` 为您的个人访问令牌

根据您的操作系统，可能需要使用 `--store-password-in-clear-text` 标志。

例如：

```shell
dotnet nuget add source "https://gitlab.example.com/api/v4/groups/23/-/packages/nuget/index.json" --name gitlab --username carol --password <your_access_token> --store-password-in-clear-text
```

{{< /tab >}}

{{< tab title="Chocolatey CLI" >}}

Chocolatey CLI 仅与[项目端点](#with-the-project-endpoint)兼容。

{{< /tab >}}

{{< tab title="Visual Studio" >}}

要使用 Visual Studio 将软件包仓库添加为源：

1. 打开 [Visual Studio](https://visualstudio.microsoft.com/vs/)。
1. 在 Windows 上，选择**工具** > **选项**。在 macOS 上，选择 **Visual Studio** > **首选项**。
1. 在 **NuGet** 部分中，选择**源**以查看所有 NuGet 源的列表。
1. 选择**添加**。
1. 填写以下字段：

   - **名称**：源的名称。
   - **源**：`https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/nuget/index.json`，
     其中 `<group_id>` 是您的群组 ID，`gitlab.example.com` 是
     您的域名。

1. 选择**保存**。
1. 当您访问该软件包时，必须输入您的**用户名**和**密码**。

   - **用户名**：您的极狐GitLab 用户名。
   - **密码**：您的个人访问令牌。

该源会显示在您的列表中。

如果您收到警告，请确保**源**、**用户名**和
**密码**均正确。

{{< /tab >}}

{{< tab title="配置文件" >}}

要使用 .NET 配置文件将软件包仓库添加为源：

1. 在项目的根目录中，创建一个名为 `nuget.config`的文件。
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

1. 配置必要的环境变量：

   ```shell
   export GITLAB_PACKAGE_REGISTRY_USERNAME=<gitlab_username>
   export GITLAB_PACKAGE_REGISTRY_PASSWORD=<personal_access_token>
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 前面的示例命令添加了一个名为 `gitlab`的源。后续示例命令引用的是源名称（`gitlab`），而不是源 URL。

<a id="publish-a-package"></a>

## 发布软件包

先决条件：

- 将软件包仓库设置为[源](#add-the-package-registry-as-a-source-for-nuget-packages)。
- 配置[用于 NuGet 软件包的极狐GitLab 项目端点](#with-the-project-endpoint)。

发布软件包时：

- 查看您的极狐GitLab 实例的最大文件大小限制：
  - [JihuLab.com 实例上的软件包仓库限制](../../jihulab_com/_index.md#package-registry-limits)因文件格式而异，且不可配置。
  - [极狐GitLab 私有化部署实例上的软件包仓库限制](../../../administration/instance_limits.md#file-size-limits)因文件格式而异，且可配置。
- 如果允许重复，并且您多次发布具有相同名称和版本的同一软件包，则每次
  连续上传都会保存为单独的文件。安装软件包时，
  极狐GitLab 会提供最近上传的文件。
- 大多数上传的软件包应立即显示在**软件包仓库**页面中。少数软件包如果需要
  在后台处理，可能需要最多 10 分钟才会显示。

<a id="with-nuget-cli"></a>

### 使用 NuGet CLI

先决条件：

- [使用 NuGet CLI 创建的 NuGet 软件包](https://learn.microsoft.com/en-us/nuget/create-packages/creating-a-package)。

要发布软件包，请运行以下命令：

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

先决条件：

- [使用 .NET CLI 创建的 NuGet 软件包](https://learn.microsoft.com/en-us/nuget/create-packages/creating-a-package-dotnet-cli)。

要发布软件包，请运行以下命令：

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

您可以使用 `--api-key` 选项代替 `username` 和 `password` 来发布软件包：

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

先决条件：

- 使用[项目端点](#with-the-project-endpoint)的源。

要使用 Chocolatey CLI 发布软件包，请运行以下命令：

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

如果您使用极狐GitLab CI/CD 发布 NuGet 软件包，可以使用
[`CI_JOB_TOKEN` 预定义变量](../../../ci/jobs/ci_job_token.md)代替
个人访问令牌或部署令牌。作业令牌会继承生成该流水线的用户或成员的权限。

以下各节中的示例介绍了使用 CI/CD 流水线时常见的 NuGet 发布工作流。

<a id="publish-packages-when-the-default-branch-is-updated"></a>

#### 在默认分支更新时发布软件包

要在每次 `main` 分支更新时发布新软件包：

1. 在项目的 `.gitlab-ci.yml` 文件中，添加以下 `deploy` 作业：

   ```yaml
   default:
     # Updated to a more current SDK version
     image: mcr.microsoft.com/dotnet/sdk:7.0

   stages:
     - deploy

   deploy:
     stage: deploy
     script:
       # Build the package in Release configuration
       - dotnet pack -c Release
       # Configure GitLab package registry as a NuGet source
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # Push the package to the project's package registry
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH  # Only run on the main branch
     environment: production
   ```

1. 提交更改并将其推送到您的极狐GitLab 代码仓库，以触发新的 CI/CD 构建。

<a id="publish-versioned-packages-with-git-tags"></a>

#### 使用 Git 标签发布带版本的软件包

要使用 [Git 标签](../../project/repository/tags/_index.md)发布带版本的 NuGet 软件包：

1. 在项目的 `.gitlab-ci.yml` 文件中，添加以下 `deploy` 作业：

   ```yaml
   publish-tagged-version:
     stage: deploy
     script:
       # Use the Git tag as the package version
       - dotnet pack -c Release /p:Version=${CI_COMMIT_TAG} /p:PackageVersion=${CI_COMMIT_TAG}
       # Configure GitLab package registry as a NuGet source
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # Push the package to the project's package registry
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_TAG  # Only run when a tag is pushed
   ```

1. 提交更改并将其推送到您的极狐GitLab 代码仓库。
1. 推送一个 Git 标签以触发新的 CI/CD 构建。

<a id="publish-conditionally-for-different-environments"></a>

#### 针对不同环境进行条件发布

您可以配置 CI/CD 流水线，根据您的用例有条件地将 NuGet 软件包发布到不同环境。

要针对 `development` 和 `production` 环境有条件地发布 NuGet 软件包：

1. 在项目的 `.gitlab-ci.yml` 文件中，添加以下 `deploy` 作业：

   ```yaml
     # Publish development/preview packages
   publish-dev:
     stage: deploy
     script:
       # Create a development version with pipeline ID for uniqueness
       - VERSION="0.0.1-dev.${CI_PIPELINE_IID}"
       - dotnet pack -c Release /p:Version=$VERSION /p:PackageVersion=$VERSION
       # Configure GitLab package registry as a NuGet source
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # Push the package to the project's package registry
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_BRANCH == "develop"
     environment: development

     # Publish stable release packages
   publish-release:
     stage: deploy
     script:
       - dotnet pack -c Release
       # Configure GitLab package registry as a NuGet source
       - dotnet nuget add source "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/nuget/index.json" --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
       # Push the package to the project's package registry
       - dotnet nuget push "bin/Release/*.nupkg" --source gitlab
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
     environment: production
   ```

1. 提交更改并将其推送到您的极狐GitLab 代码仓库。

   使用此 CI/CD 配置：

   - 将 NuGet 软件包推送到 `develop` 分支会将软件包发布到您的 `development` 环境的软件包仓库。
   - 将 NuGet 软件包推送到 `main` 分支会将 NuGet 软件包发布到您的 `production` 环境的软件包仓库。

<a id="turn-off-duplicate-nuget-packages"></a>

### 关闭重复的 NuGet 软件包

您可以发布多个具有相同名称和版本的软件包。

要阻止群组成员和用户发布重复的 NuGet 软件包，请关闭**允许重复**设置：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **软件包和镜像仓库**。
1. 在**重复软件包**表格的 **NuGet** 行中，关闭**允许重复**开关。
1. 可选。在**例外**文本框中，输入一个与要允许的软件包名称和版本匹配的正则表达式。

您还可以使用 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings)中的
`nuget_duplicates_allowed` 设置来关闭重复的 NuGet 软件包。

> [!warning]
> 如果 `.nuspec` 文件不在软件包的根目录中，
> 也不在归档文件的开头，则该软件包可能
> 不会立即被识别为重复项。当它最终被识别为
> 重复项时，**软件包管理器**页面中会显示错误。

<a id="install-a-package"></a>

## 安装软件包

极狐GitLab 软件包仓库可以包含多个具有相同名称和版本的软件包。如果您安装重复的软件包，则会获取最近发布的软件包。

先决条件：

- 将软件包仓库设置为[源](#add-the-package-registry-as-a-source-for-nuget-packages)。
- 配置[用于 NuGet 软件包的极狐GitLab 端点](#use-the-gitlab-endpoint-for-nuget-packages)。

<a id="from-the-command-line"></a>

### 从命令行

{{< tabs >}}

{{< tab title="NuGet CLI" >}}

运行以下命令以安装软件包的最新版本：

```shell
nuget install <package_id> -OutputDirectory <output_directory> \
  -Version <package_version> \
  -Source <source_name>
```

- `<package_id>`：软件包 ID。
- `<output_directory>`：输出目录，即安装软件包的位置。
- `<package_version>`：可选。软件包版本。
- `<source_name>`：可选。源名称。
  - `nuget` 会先在 `nuget.org`中查找所请求的软件包。
    如果极狐GitLab 软件包仓库中有与 `nuget.org`中某个软件包同名的 NuGet 软件包，
    则必须指定源名称才能安装正确的软件包。

{{< /tab >}}

{{< tab title=".NET CLI" >}}

> [!note]
> 如果极狐GitLab 软件包仓库中有与
> 其他源中某个软件包同名的 NuGet 软件包，请确认 `dotnet` 在
> 安装期间检查源的顺序。此行为在 `nuget.config` 文件中定义。

运行以下命令以安装软件包的最新版本：

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

先决条件：

- 用于 Chocolatey 的 [v2 源](#with-the-project-endpoint)。
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

# or

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

> [!warning]
> 删除软件包是永久性操作，无法撤销。

先决条件：

- 您在项目中必须至少具有[维护者](../../permissions.md#project-permissions)角色。
- 您必须同时拥有软件包名称和版本。

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

## 符号软件包

极狐GitLab 可以使用 NuGet 软件包仓库中的符号文件。您可以将极狐GitLab 软件包仓库用作符号服务器，以调试您的 NuGet 软件包。

每当您发布 NuGet 软件包文件（`.nupkg`）时，符号软件包文件（`.snupkg`）会自动上传到 NuGet 软件包仓库。

您也可以手动推送它们：

```shell
nuget push My.Package.snupkg -Source <source_name>
```

<a id="use-the-gitlab-endpoint-for-symbol-files"></a>

### 使用极狐GitLab 端点处理符号文件

极狐GitLab 软件包仓库提供了一个特殊的 `symbolfiles` 端点，您可以使用项目端点或群组端点对其进行配置：

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

`symbolfiles` 端点是配置好的调试器
可以推送符号文件的源。

<a id="use-the-package-registry-as-a-symbol-server"></a>

### 将软件包仓库用作符号服务器

要使用符号服务器：

1. 使用 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings) 启用 `nuget_symbol_server_enabled` 命名空间设置。
1. 配置您的调试器以使用符号服务器。

例如，要将 Visual Studio 配置为您的调试器：

1. 选择**工具** > **首选项**。
1. 选择**调试器** > **符号源**。
1. 选择**添加**。
1. 输入符号服务器 URL。
1. 选择**添加源**。

配置调试器后，您可以像往常一样调试应用程序。如果符号 PDB 文件可用，调试器会自动从软件包仓库下载它们。

<a id="consume-symbol-packages"></a>

#### 使用符号软件包

当调试器配置为使用符号软件包时，调试器会在请求中发送以下信息：

- `Symbolchecksum` 请求头：符号文件的 SHA-256 校验和。
- `file_name` 请求参数：符号文件的名称。例如，`mypackage.pdb`。
- `signature` 请求参数：PDB 文件的 GUID 和 age。

极狐GitLab 服务器会将此信息与符号文件进行匹配并返回该文件。

请记住：

- 仅支持可移植 PDB 文件。
- 由于调试器无法提供身份验证令牌，符号服务器端点不支持典型的身份验证方法。
  极狐GitLab 服务器需要 `signature` 和 `Symbolchecksum` 才能返回正确的符号文件。

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab NuGet 仓库支持以下用于 NuGet CLI（`nuget`）和 .NET
CLI（`dotnet`）的命令：

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

为提高性能，NuGet 会缓存软件包文件。如果您遇到存储问题，请使用以下命令清除缓存：

```shell
nuget locals all -clear
```

<a id="errors-when-publishing-nuget-packages-in-a-docker-based-gitlab-installation"></a>

### 在基于 Docker 的极狐GitLab 安装中发布 NuGet 软件包时出错

发布 NuGet 软件包时，您可能会收到以下错误消息：

- `Error publishing`
- `Invalid Package: Failed metadata extraction error`

为防止内部 Web 服务被利用，发往本地网络地址的
Webhook 请求会被阻止。

要解决这些错误，请更改您的网络设置，以
[允许 Webhook 和集成请求访问本地网络](../../../security/webhooks.md#allow-requests-to-the-local-network-from-webhooks-and-integrations)。
