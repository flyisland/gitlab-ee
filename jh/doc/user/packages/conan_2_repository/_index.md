---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Conan 2 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/519741)，[带有功能标志](../../../administration/feature_flags/_index.md)，名称为 `conan_package_revisions_support`。默认禁用。
- 在极狐GitLab 18.3 中[在 JihuLab.com 上启用](https://gitlab.com/groups/gitlab-org/-/epics/14896)。功能标志 `conan_package_revisions_support` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。更多信息，请参见历史记录。

将 Conan 2 软件包发布到您项目的软件包仓库中。然后，在需要将它们用作依赖项时进行安装。

> [!warning]
> 极狐GitLab 的 Conan 2 软件包仓库仍在开发中，由于功能有限，尚未准备好用于生产环境。此[史诗](https://gitlab.com/groups/gitlab-org/-/epics/8258)详细说明了使其达到生产就绪状态所需完成的剩余工作和时间表。

要将 Conan 2 软件包发布到软件包仓库，请将软件包仓库添加为远程仓库并对其进行认证。

然后，您可以运行 `conan` 命令并将软件包发布到软件包仓库。

> [!note]
> Conan 仓库不符合 FIPS 标准，并且在启用 FIPS 模式时会被禁用。

有关 Conan 2 软件包管理器客户端使用的特定 API 端点的文档，请参见 [Conan v2 API](../../../api/packages/conan_v2.md)。

了解如何[构建 Conan 2 软件包](../workflows/build_packages.md#conan-2)。

<a id="add-the-package-registry-as-a-conan-remote"></a>

## 将软件包仓库添加为 Conan 远程仓库

要运行 `conan` 命令，您必须将软件包仓库添加为您项目或实例的 Conan 远程仓库。然后，您就可以将软件包发布到软件包仓库并从软件包仓库安装软件包。

<a id="add-a-remote-for-your-project"></a>

### 为您的项目添加远程仓库

设置一个远程仓库，这样您就可以在项目中处理软件包，而无需在每个命令中指定远程仓库名称。

当您为项目设置远程仓库时，软件包名称必须为小写。此外，您的命令必须包含完整的 recipe，包括用户和频道，例如 `package_name/version@user/channel`。

要添加远程仓库：

1. 在您的终端中，运行此命令：

   ```shell
   conan remote add gitlab https://gitlab.example.com/api/v4/projects/<project_id>/packages/conan
   ```

1. 通过在 Conan 2 命令末尾添加 `--remote=gitlab` 来使用此远程仓库。

   例如：

   ```shell
   conan search hello* --remote=gitlab
   ```

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库进行认证

极狐GitLab 要求进行认证才能上传软件包，以及从私有和内部项目安装软件包。（但是，您无需认证即可从公开项目安装软件包。）

要向软件包仓库进行认证，您需要以下其中一项：

- 一个[个人访问令牌](../../profile/personal_access_tokens.md)，其范围设置为 `api`。
- 一个[部署令牌](../../project/deploy_tokens/_index.md)，其范围设置为 `read_package_registry`、`write_package_registry` 或两者皆有。
- 一个 [CI 作业令牌](#publish-a-conan-2-package-by-using-cicd)。

> [!note]
> 如果您未认证，私有和内部项目中的软件包将被隐藏。如果您在未认证的情况下尝试从私有或内部项目搜索或下载软件包，您将在 Conan 2 客户端中收到错误 `无法在远程中找到软件包`。

<a id="add-your-credentials-to-the-gitlab-remote"></a>

### 将您的凭证添加到极狐GitLab 远程仓库

将您的令牌与极狐GitLab 远程仓库关联，这样您就不必为每个 Conan 2 命令显式添加令牌。

先决条件：

- 您必须拥有认证令牌。
- 必须[已配置 Conan 远程仓库](#add-the-package-registry-as-a-conan-remote)。

在终端中，运行此命令。在此示例中，远程仓库名称为 `gitlab`。请使用您远程仓库的名称。

```shell
conan remote login -p <personal_access_token or deploy_token> gitlab <gitlab_username or deploy_token_username>
```

现在，当您使用 `--remote=gitlab` 运行命令时，您的用户名和密码将包含在请求中。

> [!note]
> 由于您对极狐GitLab 的认证会定期过期，您可能偶尔需要重新输入您的个人访问令牌。

<a id="publish-a-conan-2-package"></a>

## 发布 Conan 2 软件包

将 Conan 2 软件包发布到软件包仓库，这样任何可以访问该项目的人都可以将该软件包用作依赖项。

先决条件：

- 必须[已配置 Conan 远程仓库](#add-the-package-registry-as-a-conan-remote)。
- 必须配置与软件包仓库的[认证](#authenticate-to-the-package-registry)。
- 必须存在一个本地的 [Conan 2 软件包](../workflows/build_packages.md#conan-2)。
- 您必须拥有项目 ID，该 ID 显示在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上。

要发布软件包，请使用 `conan upload` 命令：

```shell
conan upload hello/0.1@mycompany/beta -r gitlab
```

<a id="publish-a-conan-2-package-by-using-cicd"></a>

## 使用 CI/CD 发布 Conan 2 软件包

要在[极狐GitLab CI/CD](../../../ci/_index.md) 中使用 Conan 2 命令，您可以在命令中使用 `CI_JOB_TOKEN` 代替个人访问令牌。

您可以在 `.gitlab-ci.yml` 文件中为每个 Conan 命令提供 `CONAN_LOGIN_USERNAME` 和 `CONAN_PASSWORD`。例如：

```yaml
create_package:
  image: <conan 2 image>
  stage: deploy
  script:
    - conan remote add gitlab ${CI_API_V4_URL}/projects/$CI_PROJECT_ID/packages/conan
    - conan new <package-name>/0.1
    - conan create . --channel=stable --user=mycompany
    - CONAN_LOGIN_USERNAME=ci_user CONAN_PASSWORD=${CI_JOB_TOKEN} conan upload <package-name>/0.1@mycompany/stable --remote=gitlab
  environment: production
```

请遵循[官方指南](https://docs.conan.io/2.17/examples/runners/docker/basic.html)创建一个合适的 Conan 2 镜像，作为您 CI 文件的基础。

<a id="re-publishing-a-package-with-the-same-recipe"></a>

### 使用相同 recipe 重新发布软件包

当您发布与现有软件包具有相同 recipe（`package-name/version@user/channel`）的软件包时，Conan 会跳过上传，因为它们已存在于服务器中。

<a id="install-a-conan-2-package"></a>

## 安装 Conan 2 软件包

从软件包仓库安装 Conan 2 软件包，以便将其用作依赖项。您可以从项目范围的上下文中安装软件包。
如果多个软件包具有相同的 recipe，当您安装软件包时，将检索最近发布的软件包。

Conan 2 软件包通常通过 `conanfile.txt` 文件作为依赖项进行安装。

先决条件：

- 必须[已配置 Conan 远程仓库](#add-the-package-registry-as-a-conan-remote)。
- 对于私有和内部项目，您必须配置与软件包仓库的[认证](#authenticate-to-the-package-registry)。

1. 按照 [Conan 2 软件包](../workflows/build_packages.md#conan-2)指南创建另一个软件包。在项目的根目录中，创建一个名为 `conanfile.txt` 的文件。

1. 将 Conan recipe 添加到文件的 `[requires]` 部分：

   ```plaintext
   [requires]
   hello/0.1@mycompany/beta
   ```

1. 在项目的根目录中，创建一个 `build` 目录并切换到该目录：

   ```shell
   mkdir build && cd build
   ```

1. 安装 `conanfile.txt` 中列出的依赖项：

   ```shell
   conan install ../conanfile.txt
   ```

> [!note]
> 如果您尝试安装在本教程中创建的软件包，安装命令不会产生任何效果，因为该软件包已存在。
> 使用此命令在本地删除现有软件包，然后重试：
>
> ```shell
> conan remove hello/0.1@mycompany/beta
> ```

<a id="remove-a-conan-2-package"></a>

## 删除 Conan 2 软件包

从极狐GitLab 软件包仓库中删除 Conan 2 软件包有两种方法。

- 使用 Conan 2 客户端从命令行删除：

  ```shell
  conan remove hello/0.1@mycompany/beta --remote=gitlab
  ```

  您必须在此命令中显式包含远程仓库，否则只会从本地系统缓存中删除该软件包。

  > [!note]
  > 此命令会从软件包仓库中删除所有 recipe 和二进制软件包文件。

- 从极狐GitLab 用户界面删除：

  前往您项目的 **部署** > **软件包仓库**。通过选择 **删除仓库**（{{< icon name="remove" >}}）来删除软件包。

<a id="search-for-conan-2-packages-in-the-package-registry"></a>

## 在软件包仓库中搜索 Conan 2 软件包

要按完整或部分软件包名称，或按精确的 recipe 进行搜索，请运行 `conan search` 命令。

- 要搜索特定名称的所有软件包：

  ```shell
  conan search hello --remote=gitlab
  ```

- 要搜索部分名称，例如所有以 `he` 开头的软件包：

  ```shell
  conan search "he*" --remote=gitlab
  ```

您的搜索范围取决于您的 Conan 远程仓库配置。只要您有权访问，您的搜索就包含目标项目中的所有软件包。

搜索结果限制为 500 个软件包，并且结果按最近发布的软件包排序。

> [!note]
> 搜索软件包时，Conan v2 CLI 仅显示使用 Conan v2 上传的软件包的软件包详细信息。使用 Conan v1 上传的软件包会出现在搜索结果中，但不会显示其详细信息。这是因为 Conan v2 期望软件包引用不包含 `recipe_hash` 字段，而使用 Conan v1 上传的软件包中包含该字段。

<a id="download-a-conan-2-package"></a>

## 下载 Conan 2 软件包

您可以使用 `conan download` 命令，在不使用设置的情况下将 Conan 2 软件包的 recipe 和二进制文件下载到本地缓存。

先决条件：

- 必须[已配置 Conan 远程仓库](#add-the-package-registry-as-a-conan-remote)。
- 对于私有和内部项目，您必须配置与软件包仓库的[认证](#authenticate-to-the-package-registry)。

<a id="download-all-binary-packages"></a>

### 下载所有二进制软件包

您可以从软件包仓库下载与 recipe 关联的所有二进制软件包。

要下载所有二进制软件包，请运行以下命令：

```shell
conan download hello/0.1@mycompany/beta --remote=gitlab
```

<a id="download-recipe-files"></a>

### 下载 recipe 文件

您可以仅下载 recipe 文件，不包含任何二进制软件包。

要下载 recipe 文件，请运行以下命令：

```shell
conan download hello/0.1@mycompany/beta --remote=gitlab --only-recipe
```

<a id="download-a-specific-binary-package"></a>

### 下载特定的二进制软件包

您可以通过引用其软件包引用（在 Conan 2 文档中称为 `package_id`）来下载单个二进制软件包。

要下载特定的二进制软件包，请运行以下命令：

```shell
conan download Hello/0.1@foo+bar/stable:<package_reference> --remote=gitlab
```

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab Conan 仓库支持以下 Conan 2 CLI 命令：

- `conan upload`：将您的 recipe 和软件包文件上传到软件包仓库。
- `conan install`：从软件包仓库安装 Conan 2 软件包，包括使用 `conanfile.txt` 文件。
- `conan download`：在不使用设置的情况下，将软件包 recipe 和二进制文件下载到本地缓存。
- `conan search`：在软件包仓库中搜索公开软件包以及您有权查看的私有软件包。
- `conan list`：列出现有的 recipe、修订版本或软件包。
- `conan remove`：从软件包仓库中删除软件包。

<a id="conan-revisions"></a>

## Conan 修订版本

Conan 修订版本在软件包仓库中提供软件包不可变性。当您更改 recipe 或软件包而不更改其版本时，Conan 会计算一个唯一标识符（修订版本）来跟踪这些更改。

<a id="types-of-revisions"></a>

### 修订版本的类型

Conan 使用两种类型的修订版本：

- **Recipe 修订版本（RREV）**：在导出 recipe 时生成。默认情况下，Conan 使用 recipe 清单的校验和哈希来计算 recipe 修订版本。
- **软件包修订版本（PREV）**：在构建软件包时生成。Conan 使用软件包内容的哈希来计算软件包修订版本。

<a id="reference-revisions"></a>

### 引用修订版本

您可以使用以下格式引用软件包：

| 引用 | 描述 |
| --- | --- |
| `lib/1.0@conan/stable` | `lib/1.0@conan/stable` 的最新 RREV。 |
| `lib/1.0@conan/stable#RREV` | `lib/1.0@conan/stable` 的特定 RREV。 |
| `lib/1.0@conan/stable#RREV:PACKAGE_REFERENCE` | 属于特定 RREV 的二进制软件包。 |
| `lib/1.0@conan/stable#RREV:PACKAGE_REFERENCE#PREV` | 属于特定 RREV 的二进制软件包修订版本 PREV。 |

<a id="upload-revisions"></a>

### 上传修订版本

要将所有修订版本及其二进制文件上传到极狐GitLab 软件包仓库：

```shell
conan upload "hello/0.1@mycompany/beta#*" --remote=gitlab
```

当您上传多个修订版本时，它们会从最旧到最新上传。相对顺序在仓库中得以保留。

<a id="list-revisions"></a>

### 列出修订版本

要在 Conan 2 中列出特定 recipe 的所有修订版本：

```shell
conan list "hello/0.1@mycompany/beta#*" --remote=gitlab
```

此命令显示指定 recipe 的所有可用修订版本及其修订版本哈希和创建日期。

要获取有关特定修订版本的详细信息：

```shell
conan list "hello/0.1@mycompany/beta#revision_hash:*#*" --remote=gitlab
```

此命令向您显示该修订版本可用的特定二进制软件包和软件包修订版本。

<a id="delete-packages-with-revisions"></a>

### 使用修订版本删除软件包

您可以在不同粒度级别删除软件包：

<a id="delete-a-specific-recipe-revision"></a>

#### 删除特定的 recipe 修订版本

要删除特定的 recipe 修订版本及其所有关联的二进制软件包：

```shell
conan remove "hello/0.1@mycompany/beta#revision_hash" --remote=gitlab
```

<a id="delete-packages-for-a-specific-recipe-revision"></a>

#### 删除特定 recipe 修订版本的软件包

要删除与特定 recipe 修订版本关联的所有软件包：

```shell
conan remove "hello/0.1@mycompany/beta#revision_hash:*" --remote=gitlab
```

<a id="delete-a-specific-package-in-a-revision"></a>

#### 删除修订版本中的特定软件包

要删除 recipe 修订版本中的特定软件包，您可以使用：

```shell
conan remove "package_name/version@user/channel#revision_hash:package_id" --remote=gitlab
```

<a id="immutable-revisions-workflow"></a>

### 不可变修订版本工作流

修订版本被设计为不可变的。当您修改 recipe 或其源代码时：

- 当您导出 recipe 时，会创建一个新的 recipe 修订版本。
- 属于先前 recipe 修订版本的任何现有二进制文件不会被包含在内。您必须为新的 recipe 修订版本构建新的二进制文件。
- 当您安装软件包时，除非您指定了修订版本，否则 Conan 2 会自动检索最新的修订版本。

对于软件包二进制文件，每个 recipe 修订版本和软件包引用（在 Conan 2 文档中称为 `package_id`）应该只包含一个软件包修订版本。针对相同 recipe 修订版本和软件包 ID 出现多个软件包修订版本，表示软件包被不必要地重新构建了。