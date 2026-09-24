---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 软件包仓库中的 Conan 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Experiment

{{< /details >}}

{{< alert type="warning" >}}

极狐GitLab 中的 Conan 软件包仓库还在开发中，并未生产就绪，所以功能有限。

{{< /alert >}}

{{< alert type="note" >}}

Conan 仓库并不是 FIPS 兼容的，所以在[启用 FIPS 模式](../../../development/fips_gitlab.md)时，它会被禁用。
{{< /alert >}}

发布 Conan 软件包到你的项目的软件包 registry。然后在需要使用它们作为依赖项时安装这些软件包。

要将 Conan 软件包发布到软件包 registry，请将软件包 registry 添加为远程并进行身份验证。

然后，你可以运行 `conan` 命令并将你的软件包发布到软件包 registry。

有关 Conan 软件包管理器使用的特定 API 端点的文档，请参阅 [Conan v1 API](../../../api/packages/conan_v1.md) 或 [Conan v2 API](../../../api/packages/conan_v2.md)。

了解如何 [构建 Conan 软件包](../workflows/build_packages.md#conan)。

<a id="add-the-package-registry-as-a-conan-remote"></a>

## 将软件包 registry 添加为 Conan 远程

要运行 `conan` 命令，必须将软件包 registry 添加为项目或实例的 Conan 远程。然后你可以发布软件包到软件包 registry 并从中安装软件包。

<a id="add-a-remote-for-your-project"></a>

### 为你的项目添加远程

设置一个远程，以便在项目中使用软件包，而无需在每个命令中指定远程名称。

当你为项目设置远程时，对你的软件包名称没有限制。然而，你的命令必须包括完整的配方，包括用户和频道，例如 `package_name/version@user/channel`。

要添加远程：

1. 在你的终端中运行此命令：

   ```shell
   conan remote add gitlab https://gitlab.example.com/api/v4/projects/<project_id>/packages/conan
   ```

1. 通过在你的 Conan 命令末尾添加 `--remote=gitlab` 来使用远程。

   例如：

   ```shell
   conan search Hello* --remote=gitlab
   ```

<a id="add-a-remote-for-your-instance"></a>

### 为你的实例添加远程

使用单个远程访问整个极狐GitLab 实例中的软件包。

但是，在使用此远程时，必须遵循这些[软件包命名限制](#package-recipe-naming-convention-for-instance-remotes)。

要添加远程：

1. 在你的终端中运行此命令：

   ```shell
   conan remote add gitlab https://gitlab.example.com/api/v4/packages/conan
   ```

1. 通过在你的 Conan 命令末尾添加 `--remote=gitlab` 来使用远程。

   例如：

   ```shell
   conan search 'Hello*' --remote=gitlab
   ```

<a id="package-recipe-naming-convention-for-instance-remotes"></a>

#### 实例远程的软件包配方命名约定

标准的 Conan 配方约定是 `package_name/version@user/channel`，但如果你使用的是[实例远程](#add-a-remote-for-your-instance)，则配方 `user` 必须是加号 (`+`) 分隔的项目路径。

示例配方名称：

| 项目                | 软件包                                        | 支持 |
| ------------------- | --------------------------------------------- | ---- |
| `foo/bar`           | `my-package/1.0.0@foo+bar/stable`             | 是   |
| `foo/bar-baz/buz`   | `my-package/1.0.0@foo+bar-baz+buz/stable`     | 是   |
| `gitlab-org/gitlab-ce` | `my-package/1.0.0@gitlab-org+gitlab-ce/stable` | 是   |
| `gitlab-org/gitlab-ce` | `my-package/1.0.0@foo/stable`                  | 否   |

[项目远程](#add-a-remote-for-your-project)有更灵活的命名约定。

<a id="authenticate-to-the-package-registry"></a>

## 认证到软件包 registry

极狐GitLab 要求认证以上传软件包，并从私有和内部项目中安装软件包。（然而，你可以在不认证的情况下从公共项目中安装软件包。）

要认证到软件包 registry，你需要以下之一：

- 具有 `api` 范围设置的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 具有 `read_package_registry`、`write_package_registry` 或两者范围设置的[部署令牌](../../project/deploy_tokens/_index.md)。
- [CI 作业令牌](#publish-a-conan-package-by-using-cicd)。

{{< alert type="note" >}}

如果你未认证，私有和内部项目中的软件包将被隐藏。如果尝试在不认证的情况下从私有或内部项目搜索或下载软件包，你会在 Conan 客户端中收到错误 `unable to find the package in remote`。

{{< /alert >}}

<a id="add-your-credentials-to-the-gitlab-remote"></a>

### 将你的凭证添加到极狐GitLab 远程

将你的令牌与极狐GitLab 远程关联，这样你就不必在每个 Conan 命令中显式添加令牌。

前提条件：

- 必须拥有认证令牌。
- Conan 远程[必须已配置](#add-the-package-registry-as-a-conan-remote)。

在终端中运行此命令。在此示例中，远程名称是 `gitlab`。使用你的远程名称。

```shell
conan user <gitlab_username or deploy_token_username> -r gitlab -p <personal_access_token or deploy_token>
```

现在，当你运行带有 `--remote=gitlab` 的命令时，用户名和密码将包含在请求中。

{{< alert type="note" >}}

由于与极狐GitLab 的认证会定期过期，因此你可能需要偶尔重新输入你的个人访问令牌。

{{< /alert >}}

<a id="set-a-default-remote-for-your-project-optional"></a>

### 为你的项目设置默认远程（可选）

如果你希望在不指定远程的情况下与极狐GitLab 软件包 registry 进行交互，你可以告诉 Conan 始终对你的软件包使用软件包 registry。

在终端中运行此命令：

```shell
conan remote add_ref Hello/0.1@mycompany/beta gitlab
```

{{< alert type="note" >}}

软件包配方包括版本，因此 `Hello/0.1@user/channel` 的默认远程不适用于 `Hello/0.2@user/channel`。

{{< /alert >}}

如果你不设置默认用户或远程，你仍然可以在命令中包含用户和远程：

```shell
CONAN_LOGIN_USERNAME=<gitlab_username or deploy_token_username> CONAN_PASSWORD=<personal_access_token or deploy_token> <conan command> --remote=gitlab
```

<a id="publish-a-conan-package"></a>

## 发布 Conan 软件包

将 Conan 软件包发布到软件包 registry，以便任何可以访问项目的人都可以使用该软件包作为依赖项。

前提条件：

- Conan 远程[必须已配置](#add-the-package-registry-as-a-conan-remote)。
- 必须配置与软件包 registry 的[认证](#authenticate-to-the-package-registry)。
- 必须存在本地 Conan 软件包。
  - 对于实例远程，软件包必须符合[命名约定](#package-recipe-naming-convention-for-instance-remotes)。
- 必须拥有项目 ID，可以在[项目概览页面](../../project/working_with_projects.md#access-a-project-by-using-the-project-id)上查看。

要发布软件包，请使用 `conan upload` 命令：

```shell
conan upload Hello/0.1@mycompany/beta --all
```

<a id="publish-a-conan-package-by-using-cicd"></a>

## 使用 CI/CD 发布 Conan 软件包

要在[极狐GitLab CI/CD](../../../ci/_index.md)中使用 Conan 命令，你可以在命令中使用 `CI_JOB_TOKEN` 替代个人访问令牌。

你可以在 `.gitlab-ci.yml` 文件中的每个 Conan 命令中提供 `CONAN_LOGIN_USERNAME` 和 `CONAN_PASSWORD`。例如：

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

<a id="re-publishing-a-package-with-the-same-recipe"></a>

### 使用相同配方重新发布软件包

当你发布具有与现有软件包相同配方（`package-name/version@user/channel`）的软件包时，重复的文件会成功上传并可以通过 UI 访问。然而，当软件包被安装时，仅返回最近发布的软件包。

<a id="install-a-conan-package"></a>

## 安装 Conan 软件包

从软件包 registry 安装 Conan 软件包，以便可以将其作为依赖项使用。你可以从你的实例或项目范围内安装软件包。如果多个软件包具有相同的配方，当你安装软件包时，将检索最近发布的软件包。

Conan 软件包通常通过 `conanfile.txt` 文件作为依赖项安装。

前提条件：

- Conan 远程[必须已配置](#add-the-package-registry-as-a-conan-remote)。
- 对于私有和内部项目，必须配置与软件包 registry 的[认证](#authenticate-to-the-package-registry)。

1. 在你希望将软件包作为依赖项安装的项目中，打开 `conanfile.txt`。或者，在项目根目录中创建一个名为 `conanfile.txt` 的文件。

1. 将 Conan 配方添加到文件的 `[requires]` 部分：

   ```plaintext
   [requires]
   Hello/0.1@mycompany/beta

   [generators]
   cmake
   ```

1. 在项目根目录下，创建一个 `build` 目录并切换到该目录：

   ```shell
   mkdir build && cd build
   ```

1. 安装 `conanfile.txt` 中列出的依赖项：

   ```shell
   conan install .. <options>
   ```

{{< alert type="note" >}}

如果你尝试安装在本教程中创建的软件包，安装命令没有效果，因为软件包已经存在。删除 `~/.conan/data` 来清理缓存中存储的软件包。

{{< /alert >}}

<a id="remove-a-conan-package"></a>

## 移除 Conan 软件包

有两种方法可以从极狐GitLab 软件包 registry 中移除 Conan 软件包。

- 从命令行使用 Conan 客户端：

  ```shell
  conan remove Hello/0.2@user/channel --remote=gitlab
  ```

  必须在此命令中显式包含远程，否则软件包只会从本地系统缓存中移除。

  {{< alert type="note" >}}

  此命令会从软件包 registry 中移除所有配方和二进制软件包文件。

  {{< /alert >}}

- 从极狐GitLab 用户界面：

  进入项目的 **部署 > 软件包仓库**。通过选择 **移除仓库** ({{< icon name="remove" >}}) 来移除软件包。

<a id="search-for-conan-packages-in-the-package-registry"></a>

## 在软件包 registry 中搜索 Conan 软件包

要通过完整或部分软件包名称，或通过精确配方进行搜索，请运行 `conan search` 命令。

- 要搜索具有特定软件包名称的所有软件包：

  ```shell
  conan search Hello --remote=gitlab
  ```

- 要搜索部分名称，例如所有以 `He` 开头的软件包：

  ```shell
  conan search He* --remote=gitlab
  ```

搜索范围取决于你的 Conan 远程配置：

- 如果为你的[实例](#add-a-remote-for-your-instance)配置了远程，搜索包括你有权限访问的所有项目。这包括你的私有项目以及所有公共项目。

- 如果为[项目](#add-a-remote-for-your-project)配置了远程，搜索包括目标项目中的所有软件包，只要你有访问权限。

{{< alert type="note" >}}

搜索结果的限制是 500 个软件包，结果按最近发布的软件包排序。

{{< /alert >}}

<a id="fetch-conan-package-information-from-the-package-registry"></a>

## 从软件包 registry 获取 Conan 软件包信息

`conan info` 命令返回有关软件包的信息：

```shell
conan info Hello/0.1@mycompany/beta
```

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab Conan 存储库支持以下 Conan CLI 命令：

- `conan upload`：将你的配方和软件包文件上传到软件包 registry。
- `conan install`：从软件包 registry 安装 Conan 软件包，包括使用 `conanfile.txt` 文件。
- `conan search`：搜索软件包 registry 中的公共软件包，以及你有权限查看的私有软件包。
- `conan info`：查看来自软件包 registry 的给定软件包的信息。
- `conan remove`：从软件包 registry 中删除软件包。

<a id="troubleshooting"></a>

## 疑难解答

<a id="make-output-verbose"></a>

### 输出详细信息

要在解决 Conan 议题时获得更详细的输出：

```shell
export CONAN_TRACE_FILE=/tmp/conan_trace.log # 或在 Windows 中使用 SET
conan <command>
```

<a id="ssl-errors"></a>

### SSL 错误

如果你使用的是自签名证书，有两种方法可以与 Conan 一起管理 SSL 错误：

- 使用 `conan remote` 命令禁用 SSL 验证。
- 将你的服务器 `crt` 文件附加到 `cacert.pem` 文件。
