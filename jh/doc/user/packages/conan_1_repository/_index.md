---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Conan 1 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

> [!warning]
> 极狐GitLab 的 Conan 软件包仓库仍在开发中，由于功能有限，尚未准备好用于生产环境。此史诗详细说明了使其生产就绪的剩余工作及时间表。

将 Conan 软件包发布到项目软件包仓库中。然后在需要将它们用作依赖项时安装这些软件包。

要将 Conan 软件包发布到软件包仓库，将软件包仓库添加为远程，并向其进行身份验证。

然后你就可以运行 `conan` 命令并将你的软件包发布到软件包仓库。

> [!note]
> Conan 仓库不符合 FIPS 标准，开启 FIPS 模式后将禁用。

有关 Conan 软件包管理器客户端使用的特定 API 端点的文档，请参阅 [Conan v1 API](../../../api/packages/conan_v1.md) 或 [Conan v2 API](../../../api/packages/conan_v2.md)。

了解如何[构建 Conan 1 软件包](../workflows/build_packages.md#conan-1)。

<a id="add-the-package-registry-as-a-conan-remote"></a>

## 将软件包仓库添加为 Conan 远程

要运行 `conan` 命令，你必须将软件包仓库添加为你项目或实例的 Conan 远程。然后你就可以从软件包仓库发布和安装软件包。

<a id="add-a-remote-for-your-project"></a>

### 为你的项目添加远程

设置远程，这样你就可以使用项目中的软件包，而无需在每个命令中指定远程名称。

当你为项目设置远程时，你的软件包名称没有限制。但是，你的命令必须包含完整配方，包括 user 和 channel，例如 `package_name/version@user/channel`。

要添加远程：

1. 在终端中，运行此命令：

   ```shell
   conan remote add gitlab https://gitlab.example.com/api/v4/projects/<project_id>/packages/conan
   ```

1. 通过在 Conan 命令末尾添加 `--remote=gitlab` 来使用该远程。

   例如：

   ```shell
   conan search Hello* --remote=gitlab
   ```

<a id="add-a-remote-for-your-instance"></a>

### 为你的实例添加远程

使用单个远程访问整个极狐GitLab 实例中的软件包。

但是，在使用此远程时，你必须遵循这些[软件包配方命名限制](#package-recipe-naming-convention-for-instance-remotes)。

要添加远程：

1. 在终端中，运行此命令：

   ```shell
   conan remote add gitlab https://gitlab.example.com/api/v4/packages/conan
   ```

1. 通过在 Conan 命令末尾添加 `--remote=gitlab` 来使用该远程。

   例如：

   ```shell
   conan search 'Hello*' --remote=gitlab
   ```

<a id="package-recipe-naming-convention-for-instance-remotes"></a>

#### 实例远程的软件包配方命名约定

标准 Conan 配方约定是 `package_name/version@user/channel`，但如果你使用的是[实例远程](#add-a-remote-for-your-instance)，则配方 `user` 必须是以加号 (`+`) 分隔的项目路径。

配方名称示例：

| 项目                    | 软件包                                          | 是否支持 |
| ---------------------- | ---------------------------------------------- | ------- |
| `foo/bar`              | `my-package/1.0.0@foo+bar/stable`              | 是      |
| `foo/bar-baz/buz`      | `my-package/1.0.0@foo+bar-baz+buz/stable`      | 是      |
| `gitlab-org/gitlab-ce` | `my-package/1.0.0@gitlab-org+gitlab-ce/stable` | 是      |
| `gitlab-org/gitlab-ce` | `my-package/1.0.0@foo/stable`                  | 否      |

[项目远程](#add-a-remote-for-your-project)具有更灵活的命名约定。

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库进行身份验证

极狐GitLab 要求身份验证才能上传软件包，以及从私有和内部项目安装软件包。（不过，你可以无需身份验证从公共项目安装软件包。）

要向软件包仓库进行身份验证，你需要以下之一：

- 范围设置为 `api` 的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 范围设置为 `read_package_registry`、`write_package_registry` 或两者的[部署令牌](../../project/deploy_tokens/_index.md)。
- [CI 作业令牌](#publish-a-conan-package-by-using-cicd)。

> [!note]
> 如果你未进行身份验证，则私有和内部项目的软件包会被隐藏。如果你尝试搜索或下载私有或内部项目中的软件包而未进行身份验证，则会在 Conan 客户端中收到错误 `unable to find the package in remote`。

<a id="add-your-credentials-to-the-gitlab-remote"></a>

### 将你的凭据添加到极狐GitLab 远程

将你的令牌与极狐GitLab 远程关联，这样你就不必为每个 Conan 命令显式添加令牌。

先决条件：

- 你必须拥有一个身份验证令牌。
- 必须[配置 Conan 远程](#add-the-package-registry-as-a-conan-remote)。

在终端中，运行此命令。在此示例中，远程名称是 `gitlab`。请使用你的远程名称。

```shell
conan user <gitlab_username 或 deploy_token_username> -r gitlab -p <personal_access_token 或 deploy_token>
```

现在，当你使用 `--remote=gitlab` 运行命令时，你的用户名和密码会包含在请求中。

> [!note]
> 因为你与极狐GitLab 的身份验证会定期过期，你可能偶尔需要重新输入你的个人访问令牌。

<a id="set-a-default-remote-for-your-project-optional"></a>

### 为你的项目设置默认远程（选填）

如果你希望与极狐GitLab 软件包仓库交互而无需指定远程，你可以告诉 Conan 始终为你的软件包使用软件包仓库。

在终端中，运行此命令：

```shell
conan remote add_ref Hello/0.1@mycompany/beta gitlab
```

> [!note]
> 软件包配方包含版本，因此适用于 `Hello/0.1@user/channel` 的默认远程不适用于 `Hello/0.2@user/channel`。

如果你不设置默认 user 或 remote，你仍然可以在命令中包含 user 和 remote：

```shell
CONAN_LOGIN_USERNAME=<gitlab_username 或 deploy_token_username> CONAN_PASSWORD=<personal_access_token 或 deploy_token> <conan command> --remote=gitlab
```

<a id="publish-a-conan-package"></a>

## 发布 Conan 软件包

将 Conan 软件包发布到软件包仓库，这样任何可以访问该项目的人都可以将该软件包用作依赖项。

先决条件：

- 必须[配置 Conan 远程](#add-the-package-registry-as-a-conan-remote)。
- 必须配置与软件包仓库的[身份验证](#authenticate-to-the-package-registry)。
- 必须存在本地 [Conan 软件包](https://docs.conan.io/en/latest/creating_packages/getting_started.html)。
  - 对于实例远程，软件包必须满足[命名约定](#package-recipe-naming-convention-for-instance-remotes)。
- 你必须拥有项目 ID，它显示在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上。

要发布软件包，使用 `conan upload` 命令：

```shell
conan upload Hello/0.1@mycompany/beta --all
```

<a id="publish-a-conan-package-by-using-cicd"></a>

## 通过 CI/CD 发布 Conan 软件包

要在 [极狐GitLab CI/CD](../../../ci/_index.md) 中使用 Conan 命令，你可以在命令中使用 `CI_JOB_TOKEN` 替代个人访问令牌。

你可以在 `.gitlab-ci.yml` 文件中为每个 Conan 命令提供 `CONAN_LOGIN_USERNAME` 和 `CONAN_PASSWORD`。例如：

```yaml
create_package:
  image: conanio/gcc7
  stage: deploy
  script:
    - conan remote add gitlab ${CI_API_V4_URL}/projects/$CI_PROJECT_ID/packages/conan
    - conan new <package-name>/0.1 -t
    - conan create . <group-name>+<project-name>/stable
    - CONAN_LOGIN_USERNAME=ci_user CONAN_PASSWORD=${CI_JOB_TOKEN} conan upload <package-name>/0.1@<group-name>+<project-name>/stable --all --remote=gitlab
  environment: production
```

在 [Conan 文档](https://docs.conan.io/en/latest/howtos/run_conan_in_docker.html#available-docker-images)中可以找到可用作 CI 文件基础的其他 Conan 镜像。

<a id="re-publishing-a-package-with-the-same-recipe"></a>

### 重新发布具有相同配方的软件包

当你发布具有与现有软件包相同配方（`package-name/version@user/channel`）的软件包时，重复文件会成功上传并可以通过 UI 访问。但是，当安装该软件包时，只会返回最近发布的软件包。

<a id="install-a-conan-package"></a>

## 安装 Conan 软件包

从软件包仓库安装 Conan 软件包，以便将其用作依赖项。你可以在实例或项目范围内安装软件包。如果多个软件包具有相同配方，当你安装软件包时，会检索到最近发布的软件包。

Conan 软件包通常通过使用 `conanfile.txt` 文件作为依赖项安装。

先决条件：

- 必须[配置 Conan 远程](#add-the-package-registry-as-a-conan-remote)。
- 对于私有和内部项目，你必须配置与软件包仓库的[身份验证](#authenticate-to-the-package-registry)。

1. 在你要安装软件包作为依赖项的项目中，打开 `conanfile.txt`。或者，在你的项目根目录中，创建一个名为 `conanfile.txt` 的文件。

1. 将 Conan 配方添加到文件的 `[requires]` 部分：

   ```plaintext
   [requires]
   Hello/0.1@mycompany/beta

   [generators]
   cmake
   ```

1. 在你的项目根目录中，创建一个 `build` 目录并切换到该目录：

   ```shell
   mkdir build && cd build
   ```

1. 安装 `conanfile.txt` 中列出的依赖项：

   ```shell
   conan install .. <options>
   ```

> [!note]
> 如果你尝试安装在本教程中创建的软件包，安装命令将不会起作用，因为该软件包已经存在。
> 删除 `~/.conan/data` 以清理缓存中存储的软件包。

<a id="remove-a-conan-package"></a>

## 删除 Conan 软件包

有两种方法可以从极狐GitLab 软件包仓库中删除 Conan 软件包。

- 从命令行，使用 Conan 客户端：

  ```shell
  conan remove Hello/0.2@user/channel --remote=gitlab
  ```

  你必须在此命令中明确包含远程，否则软件包只会从你的本地系统缓存中删除。

  > [!note]
  > 此命令会从软件包仓库中删除所有配方和二进制软件包文件。

- 从极狐GitLab 用户界面：

  转到项目的 **部署** > **软件包仓库**。通过选择 **删除仓库** ({{< icon name="remove" >}}) 来删除软件包。

<a id="search-for-conan-packages-in-the-package-registry"></a>

## 在软件包仓库中搜索 Conan 软件包

要通过完整或部分软件包名称，或通过精确配方进行搜索，运行 `conan search` 命令。

- 要搜索具有特定软件包名称的所有软件包：

  ```shell
  conan search Hello --remote=gitlab
  ```

- 要搜索部分名称，例如所有以 `He` 开头的软件包：

  ```shell
  conan search He* --remote=gitlab
  ```

搜索范围取决于你的 Conan 远程配置：

- 如果你为[实例](#add-a-remote-for-your-instance)配置了远程，则你的搜索范围包括你有权限访问的所有项目。这包括你的私有项目以及所有公共项目。

- 如果你为[项目](#add-a-remote-for-your-project)配置了远程，则你的搜索范围包括目标项目中的所有软件包，前提是你有权限访问它。

搜索结果的最大限制为 500 个软件包，结果按最近发布排序。

> [!note]
> 搜索软件包时，Conan v1 CLI 仅为使用 Conan v1 上传的软件包显示软件包详情。使用 Conan v2 上传的软件包会出现在搜索结果中，但不会显示其详情。这是因为 Conan v1 期望在软件包引用元数据中包含 `recipe_hash` 字段，该字段仅存在于使用 Conan v1 上传的软件包中。

<a id="fetch-conan-package-information-from-the-package-registry"></a>

## 从软件包仓库获取 Conan 软件包信息

`conan info` 命令返回有关软件包的信息：

```shell
conan info Hello/0.1@mycompany/beta
```

<a id="download-a-conan-package"></a>

## 下载 Conan 软件包

> [!note]
> 在启用[Conan 信息元数据提取](#extract-conan-metadata)之前上传的软件包无法使用 `conan download` CLI 命令下载。

你可以使用 `conan download` 命令将 Conan 软件包的配方和二进制文件下载到本地缓存，而无需使用设置。

先决条件：

- 必须[配置 Conan 远程](#add-the-package-registry-as-a-conan-remote)。
- 对于私有和内部项目，必须配置与软件包仓库的[身份验证](#authenticate-to-the-package-registry)。

<a id="download-all-binary-packages"></a>

### 下载所有二进制软件包

你可以从软件包仓库下载与某一配方关联的所有二进制软件包。

要下载所有二进制软件包，运行以下命令：

```shell
conan download Hello/0.1@foo+bar/stable --remote=gitlab
```

<a id="download-recipe-files"></a>

### 下载配方文件

你可以仅下载配方文件而不下载任何二进制软件包。

要下载配方文件，运行以下命令：

```shell
conan download Hello/0.1@foo+bar/stable --remote=gitlab --recipe
```

<a id="download-a-specific-binary-package"></a>

### 下载特定二进制软件包

你可以通过引用其软件包引用（在 Conan 文档中称为 `package_id`）来下载单个二进制软件包。

要下载特定二进制软件包，运行以下命令：

```shell
conan download Hello/0.1@foo+bar/stable:<package_reference> --remote=gitlab
```

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab Conan 仓库支持以下 Conan CLI 命令：

- `conan upload`：将你的配方和软件包文件上传到软件包仓库。
- `conan install`：从软件包仓库安装 Conan 软件包，包括使用 `conanfile.txt` 文件。
- `conan download`：将软件包配方和二进制文件下载到本地缓存，而无需使用设置。
- `conan search`：在软件包仓库中搜索公共软件包以及你有权查看的私有软件包。
- `conan info`：查看软件包仓库中给定软件包的信息。
- `conan remove`：从软件包仓库删除软件包。

<a id="extract-conan-metadata"></a>

## 提取 Conan 元数据

{{< history >}}

- 在极狐GitLab 15.10 中引入，带有一个功能标志 `parse_conan_metadata_on_upload`，默认禁用。
- 在极狐GitLab 17.11 中正式可用。功能标志 `parse_conan_metadata_on_upload` 已移除。

{{< /history >}}

当你上传 Conan 软件包时，极狐GitLab 会自动从 `conaninfo.txt` 文件中提取元数据。此元数据包括：

- 软件包设置（如 `os`、`arch`、`compiler` 和 `build_type`）
- 软件包选项
- 软件包需求与依赖

> [!note]
> 在此功能启用之前（极狐GitLab 17.10）上传的软件包不会提取其元数据。对于这些软件包，某些搜索和下载功能会受到限制。

<a id="conan-revisions"></a>

## Conan 修订

{{< history >}}

- 在极狐GitLab 18.1 中引入，带有一个功能标志 `conan_package_revisions_support`，默认禁用。
- 在极狐GitLab 18.3 中于 JihuLab.com 启用。功能标志 `conan_package_revisions_support` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。有关更多信息，请参阅历史记录。

Conan 1 修订版在软件包仓库中提供了软件包不可变性。当你对配方或软件包进行更改而不更改其版本时，Conan 会计算一个唯一标识符（修订版）来跟踪这些更改。

> [!note]
> Conan 1 修订版仅在远程设置到[项目](#add-a-remote-for-your-project)时受支持，而不是针对整个[实例](#add-a-remote-for-your-instance)。

<a id="types-of-revisions"></a>

### 修订类型

Conan 使用两种修订类型：

- **配方修订（RREV）**：当配方被导出时生成。默认情况下，Conan 使用配方清单的校验和哈希计算配方修订。
- **软件包修订（PREV）**：当软件包被构建时生成。Conan 使用软件包内容的哈希计算软件包修订。

<a id="enable-revisions"></a>

### 启用修订

修订在 Conan 1.x 中默认不启用。要启用修订，你必须执行以下任一操作：

- 在你的 `_conan.conf_` 文件的 `[general]` 部分添加 `revisions_enabled=1`（推荐）。
- 设置 `CONAN_REVISIONS_ENABLED=1` 环境变量。

<a id="reference-revisions"></a>

### 引用修订

你可以按以下格式引用软件包：

| 引用                                                | 描述                                                     |
| -------------------------------------------------- | -------------------------------------------------------- |
| `lib/1.0@conan/stable`                             | `lib/1.0@conan/stable` 的最新 RREV。                    |
| `lib/1.0@conan/stable#RREV`                        | `lib/1.0@conan/stable` 的特定 RREV。                    |
| `lib/1.0@conan/stable#RREV:PACKAGE_REFERENCE`      | 属于该特定 RREV 的二进制软件包。                          |
| `lib/1.0@conan/stable#RREV:PACKAGE_REFERENCE#PREV` | 属于该特定 RREV 的二进制软件包修订 PREV。                |

<a id="upload-revisions"></a>

### 上传修订

要将所有修订及其二进制文件上传到极狐GitLab 软件包仓库：

```shell
conan upload package_name/version@user/channel#* --all --remote=gitlab
```

当你上传多个修订时，它们将按从旧到新的顺序上传。相对顺序在仓库中得以保留。

<a id="search-for-revisions"></a>

### 搜索修订

要在 Conan v1 中搜索特定配方的所有修订：

```shell
conan search package_name/version@user/channel --revisions --remote=gitlab
```

此命令显示指定配方的所有可用修订及其修订哈希和创建日期。

要获取有关特定修订的详细信息：

```shell
conan search package_name/version@user/channel#revision_hash --remote=gitlab
```

此命令显示该修订可用的特定二进制软件包。

<a id="delete-packages-with-revisions"></a>

### 删除带有修订的软件包

你可以按不同的粒度级别删除软件包：

<a id="delete-a-specific-recipe-revision"></a>

#### 删除特定配方修订

要删除特定配方修订及其所有关联的二进制软件包：

```shell
conan remove package_name/version@user/channel#revision_hash --remote=gitlab
```

<a id="delete-packages-for-a-specific-recipe-revision"></a>

#### 删除特定配方修订的软件包

要删除与特定配方修订关联的所有软件包：

```shell
conan remove package_name/version@user/channel#revision_hash --packages --remote=gitlab
```

<a id="delete-a-specific-package-in-a-revision"></a>

#### 删除修订中的特定软件包

要删除配方修订中的特定软件包，你可以使用以下任一命令：

```shell
conan remove package_name/version@user/channel#revision_hash -p package_id --remote=gitlab
```

或者：

```shell
conan remove package_name/version@user/channel#revision_hash:package_id --remote=gitlab
```

> [!note]
> 当你删除带有修订的软件包时，必须包含 `--remote=gitlab` 标志。否则，软件包只会从你的本地系统缓存中删除。

<a id="immutable-revisions-workflow"></a>

### 不可变修订工作流

修订被设计为不可变的。当你修改配方或其源代码时：

- 当你导出配方时，会创建一个新的配方修订。
- 任何属于先前配方修订的现有二进制文件都不包括在内。你必须为新的配方修订构建新的二进制文件。
- 当你安装软件包时，除非你指定修订，否则 Conan 会自动检索最新的修订。

对于软件包二进制文件，你应该在每个配方修订和软件包引用（在 Conan 文档中称为 `package_id`）中仅包含一个软件包修订。同一配方修订和 package ID 的多个软件包修订表明该软件包被不必要地重新构建。

<a id="troubleshooting"></a>

## 问题排查

<a id="make-output-verbose"></a>

### 使输出详细

在排查 Conan 问题时，要获得更详细的输出：

```shell
export CONAN_TRACE_FILE=/tmp/conan_trace.log # 或者在 Windows 上 SET
conan <command>
```

你可以在 [Conan 文档](https://docs.conan.io/en/latest/mastering/logging.html)中找到更多日志提示。

<a id="ssl-errors"></a>

### SSL 错误

如果你使用的是自签名证书，有两种方法可以管理 Conan 的 SSL 错误：

- 使用 `conan remote` 命令禁用 SSL 验证。
- 将你的服务器 `crt` 文件附加到 `cacert.pem` 文件中。

在 [Conan 文档](https://docs.conan.io/en/latest/howtos/use_tls_certificates.html)中阅读更多相关信息。