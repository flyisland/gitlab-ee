---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在软件包仓库中的 Debian 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验性

{{< /details >}}

{{< history >}}

- 部署在功能标志后，默认未启用。

{{< /history >}}

> [!warning]
> 用于极狐GitLab 的 Debian 软件包仓库仍在开发中，无法用于生产环境。此[史诗](https://jihulab.com/groups/gitlab-cn/-/epics/6057)详细说明了使其达到生产就绪所需的工作和时间线。对[Debian 软件包的支持仍是实验性功能](../package_registry/supported_functionality.md)，并且存在已知的安全漏洞。

在您项目的软件包仓库中发布 Debian 软件包。然后可以在需要时将它们作为依赖项进行安装。

支持项目和群组软件包。

有关 Debian 软件包管理器客户端使用的特定 API 端点的文档，请参阅 [Debian API 文档](../../../api/packages/debian.md)。

前提条件：

- `dpkg-deb` 二进制文件必须安装在极狐GitLab 实例上。此二进制文件通常由 [`dpkg` 软件包](https://wiki.debian.org/Teams/Dpkg/Downstream) 提供，默认安装在 Debian 及其衍生版本上。
- 推荐。使用 `dpkg-deb` 1.22.21 或更高版本。在 `dpkg-deb` 1.22.20 及更早版本中，该二进制文件无法从包含不可写目录的压缩包中删除临时文件。这些文件会占用磁盘空间，并可能导致拒绝服务攻击。
- 对压缩算法 ZStandard 的支持需要 Debian 12 Bookworm 的 `dpkg >= 1.21.18` 或 Ubuntu 18.04 Bionic Beaver 的 `dpkg >= 1.19.0.5ubuntu2`。

<a id="enable-the-debian-api"></a>

## 启用 Debian API

Debian 仓库支持仍处于开发阶段。它受默认禁用的功能标志控制。
[有权访问极狐GitLab Rails 控制台的极狐GitLab 管理员](../../../administration/feature_flags/_index.md)
可以选择启用它。

> [!warning]
> 了解[启用仍在开发中的功能的稳定性和安全风险](../../../administration/feature_flags/_index.md#risks-when-enabling-features-still-in-development)。

要启用它：

```ruby
Feature.enable(:debian_packages)
```

要禁用它：

```ruby
Feature.disable(:debian_packages)
```

<a id="enable-the-debian-group-api"></a>

## 启用 Debian 群组 API

Debian 群组仓库也受另一个默认禁用的功能标志控制。

> [!warning]
> 了解[启用仍在开发中的功能的稳定性和安全风险](../../../administration/feature_flags/_index.md#risks-when-enabling-features-still-in-development)。

要启用它：

```ruby
Feature.enable(:debian_group_packages)
```

要禁用它：

```ruby
Feature.disable(:debian_group_packages)
```

<a id="build-a-debian-package"></a>

## 构建 Debian 软件包

创建 Debian 软件包的方法记录在 [Debian Wiki](https://wiki.debian.org/Packaging) 上。

<a id="authenticate-to-the-debian-endpoints"></a>

## 向 Debian 端点进行身份验证

[发行版 API](#authenticate-to-the-debian-distributions-apis) 和
[软件包仓库](#authenticate-to-the-debian-package-repositories) 的身份验证方法不同。

<a id="authenticate-to-the-debian-distributions-apis"></a>

### 向 Debian 发行版 API 进行身份验证

要创建、读取、更新或删除发行版，您需要以下之一：

- [个人访问令牌](../../profile/personal_access_tokens.md)，使用 `--header "PRIVATE-TOKEN: <personal_access_token>"`
- [部署令牌](../../project/deploy_tokens/_index.md)，使用 `--header "Deploy-Token: <deploy_token>"`
- [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)，使用 `--header "Job-Token: <job_token>"`

<a id="authenticate-to-the-debian-package-repositories"></a>

### 向 Debian 软件包仓库进行身份验证

要发布软件包或安装私有软件包，您需要使用基本身份验证，使用以下之一：

- [个人访问令牌](../../profile/personal_access_tokens.md)，使用 `<username>:<personal_access_token>`
- [部署令牌](../../project/deploy_tokens/_index.md)，使用 `<deploy_token_name>:<deploy_token>`
- [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)，使用 `gitlab-ci-token:<job_token>`

<a id="create-a-distribution"></a>

## 创建发行版

在项目级别，Debian 软件包随 Debian 发行版一起发布。在群组级别，Debian 软件包来自群组内的项目，前提是：

- 项目可见性设置为 `public`。
- 群组的 Debian `codename` 与项目的 Debian `codename` 相匹配。

使用个人访问令牌创建项目级发行版：

```shell
curl --fail-with-body --request POST --header "PRIVATE-TOKEN: <personal_access_token>" \
  "https://gitlab.example.com/api/v4/projects/<project_id>/debian_distributions?codename=<codename>"
```

`codename=sid` 的响应示例：

```json
{
  "id": 1,
  "codename": "sid",
  "suite": null,
  "origin": null,
  "label": null,
  "version": null,
  "description": null,
  "valid_time_duration_seconds": null,
  "components": [
    "main"
  ],
  "architectures": [
    "all",
    "amd64"
  ]
}
```

有关 Debian 发行版 API 的更多信息：

- [Debian 项目发行版 API](../../../api/packages/debian_project_distributions.md)
- [Debian 群组发行版 API](../../../api/packages/debian_group_distributions.md)

<a id="publish-a-package"></a>

## 发布软件包

构建完成后，会创建多个文件：

- `.deb` 文件：二进制软件包
- `.udeb` 文件：精简的 .deb 文件，用于 Debian 安装程序（如果需要）
- `.ddeb` 文件：Ubuntu 调试 .deb 文件（如果需要）
- `.tar.{gz,bz2,xz,...}` 文件：源代码文件
- `.dsc` 文件：源代码元数据及源文件列表（含哈希值）
- `.buildinfo` 文件：用于可重现构建（可选）
- `.changes` 文件：上传元数据及已上传文件列表（包含上述所有文件）

要上传这些文件，您可以使用 `dput-ng >= 1.32`（Debian bullseye）。
`<username>` 和 `<password>` 的定义方式如[Debian 软件包仓库](#authenticate-to-the-debian-package-repositories)中所述：

```shell
cat <<EOF > dput.cf
[gitlab]
method = https
fqdn = <username>:<password>@gitlab.example.com
incoming = /api/v4/projects/<project_id>/packages/debian
EOF

dput --config=dput.cf --unchecked --no-upload-log gitlab <your_package>.changes
```

<a id="upload-a-package-with-explicit-distribution-and-component"></a>

## 使用显式发行版和组件上传软件包

{{< history >}}

- 在极狐GitLab 15.9 中引入。

{{< /history >}}

当您无法访问 `.changes` 文件时，可以直接通过传递发行版 `codename` 和目标 `component` 作为参数，并使用您的[凭据](#authenticate-to-the-debian-package-repositories)来上传 `.deb` 文件。
例如，使用个人访问令牌将文件上传到发行版 `sid` 的 `main` 组件：

```shell
curl --fail-with-body --request PUT --user "<username>:<personal_access_token>" \
  "https://gitlab.example.com/api/v4/projects/<project_id>/packages/debian/your.deb?distribution=sid&component=main" \
  --upload-file  /path/to/your.deb
```

<a id="install-a-package"></a>

## 安装软件包

要安装软件包：

1. 配置仓库：

   如果您使用的是私有项目，请将您的[凭据](#authenticate-to-the-debian-package-repositories)添加到 apt 配置中：

   ```shell
   echo 'machine gitlab.example.com login <username> password <password>' \
     | sudo tee /etc/apt/auth.conf.d/gitlab_project.conf
   ```

   使用您的[凭据](#authenticate-to-the-debian-distributions-apis)下载发行版密钥：

   ```shell
   sudo mkdir -p /etc/apt/keyrings
   sudo curl --fail --silent --show-error --header "PRIVATE-TOKEN: <your_access_token>" \
        --output /etc/apt/keyrings/<codename>-archive-keyring.asc \
        --url "https://gitlab.example.com/api/v4/projects/<project_id>/debian_distributions/<codename>/key.asc"
   ```

   将您的项目添加为源：

   ```shell
   echo 'deb [ signed-by=/etc/apt/keyrings/<codename>-archive-keyring.asc ] https://gitlab.example.com/api/v4/projects/<project_id>/packages/debian <codename> <component1> <component2>' |
       sudo tee /etc/apt/sources.list.d/gitlab_project.list
   sudo apt-get update
   ```

1. 安装软件包：

   ```shell
   sudo apt-get -y install -t <codename> <package-name>
   ```

<a id="download-a-source-package"></a>

## 下载源代码软件包

要下载源代码软件包：

1. 配置仓库：

   如果您使用的是私有项目，请将您的[凭据](#authenticate-to-the-debian-package-repositories)添加到 apt 配置中：

   ```shell
   echo 'machine gitlab.example.com login <username> password <password>' \
     | sudo tee /etc/apt/auth.conf.d/gitlab_project.conf
   ```

   使用您的[凭据](#authenticate-to-the-debian-distributions-apis)下载发行版密钥：

   ```shell
   sudo mkdir -p /etc/apt/keyrings
   sudo curl --fail --silent --show-error --header "PRIVATE-TOKEN: <your_access_token>" \
        --output /etc/apt/keyrings/<codename>-archive-keyring.asc \
        --url "https://gitlab.example.com/api/v4/projects/<project_id>/debian_distributions/<codename>/key.asc"
   ```

   将您的项目添加为源：

   ```shell
   echo 'deb-src [ signed-by=/etc/apt/keyrings/<codename>-archive-keyring.asc ] https://gitlab.example.com/api/v4/projects/<project_id>/packages/debian <codename> <component1> <component2>' |
       sudo tee /etc/apt/sources.list.d/gitlab_project-sources.list
   sudo apt-get update
   ```

1. 下载源代码软件包：

   ```shell
   sudo apt-get source -t <codename> <package-name>
   ```

<a id="delete-a-debian-package"></a>

## 删除 Debian 软件包

前提条件：

- 您必须具有维护者或所有者角色。

在删除软件包之前，请确保您了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，您可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。