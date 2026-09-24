---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 软件包仓库中的 Composer 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

> [!warning]
> 极狐GitLab 的 Composer 软件包仓库正在开发中，由于功能有限，尚未准备好用于生产环境。
> 该史诗详细说明了使其达到生产就绪状态的剩余工作和时间表。

在项目的软件包仓库中发布 [Composer](https://getcomposer.org/) 软件包。然后，在需要将它们作为依赖项时安装这些软件包。

有关 Composer 客户端使用的特定 API 端点的文档，请参见 [Composer API 文档](../../../api/packages/composer.md)。

推荐使用 Composer v2.0。支持 Composer v1.0，但在包含大量软件包的群组中工作时性能较低。

了解如何[构建 Composer 软件包](../workflows/build_packages.md#composer)。

<a id="publish-a-composer-package-by-using-the-api"></a>

## 通过 API 发布 Composer 软件包

将 Composer 软件包发布到软件包仓库，以便可以访问该项目的任何人都可将该软件包用作依赖项。

先决条件：

- 极狐GitLab 仓库中的软件包。Composer 软件包应根据 [Composer 规范](https://getcomposer.org/doc/04-schema.md#version)进行版本控制。
  如果版本无效，例如，它有三个点 (`1.0.0.0`)，则发布时会发生错误 (`Validation failed: Version is invalid`)。
- 项目根目录中有一个有效的 `composer.json` 文件。
- 在极狐GitLab 仓库中启用了软件包功能。
- 项目 ID，显示在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)。
- 以下令牌类型之一：
  - 范围设置为 `api` 的[个人访问令牌](../../profile/personal_access_tokens.md)。
  - 范围设置为 `write_package_registry` 的[部署令牌](../../project/deploy_tokens/_index.md)。

使用个人访问令牌发布软件包：

- 向 [Packages API](../../../api/packages.md) 发送 `POST` 请求。

  例如，你可以使用 `curl`：

  ```shell
  curl --fail-with-body --data tag=<tag> "https://__token__:<personal-access-token>@gitlab.example.com/api/v4/projects/<project_id>/packages/composer"
  ```

  - `<personal-access-token>` 是你的个人访问令牌。
  - `<project_id>` 是你的项目 ID。
  - `<tag>` 是要发布的版本的 Git 标签名称。
    要发布分支，请使用 `branch=<branch>` 而不是 `tag=<tag>`。

使用部署令牌发布软件包：

- 向 [Packages API](../../../api/packages.md) 发送 `POST` 请求。

  例如，你可以使用 `curl`：

  ```shell
  curl --fail-with-body --data tag=<tag> --header "Deploy-Token: <deploy-token>" "https://gitlab.example.com/api/v4/projects/<project_id>/packages/composer"
  ```

  - `<deploy-token>` 是你的部署令牌
  - `<project_id>` 是你的项目 ID。
  - `<tag>` 是要发布的版本的 Git 标签名称。
    要发布分支，请使用 `branch=<branch>` 而不是 `tag=<tag>`。

你可以通过前往 **部署** > **软件包仓库** 并选择 **Composer** 选项卡来查看已发布的软件包。

<a id="publish-a-composer-package-by-using-cicd"></a>

## 通过 CI/CD 发布 Composer 软件包

你可以将 Composer 软件包作为 CI/CD 流程的一部分发布到软件包仓库。

1. 在你的 `.gitlab-ci.yml` 文件中指定 `CI_JOB_TOKEN`：

   ```yaml
   stages:
     - deploy

   deploy:
     stage: deploy
     script:
       - apk add curl
       - 'curl --fail-with-body --header "Job-Token: $CI_JOB_TOKEN" --data tag=<tag> "${CI_API_V4_URL}/projects/$CI_PROJECT_ID/packages/composer"'
     environment: production
   ```

1. 运行流水线。

要查看已发布的软件包，请前往 **部署** > **软件包仓库** 并选择 **Composer** 选项卡。

<a id="use-a-cicd-template"></a>

### 使用 CI/CD 模板

一个更详细的 Composer CI/CD 文件也可作为 `.gitlab-ci.yml` 模板使用：

1. 在左侧边栏中，选择 **项目概览**。
1. 在文件列表上方，选择 **设置 CI/CD**。如果此按钮不可用，请选择 **CI/CD 配置**，然后选择 **编辑**。
1. 从 **应用模板** 列表中，选择 **Composer**。

> [!warning]
> 除非你想要覆盖现有的 CI/CD 文件，否则请勿保存。

<a id="publishing-packages-with-the-same-name-or-version"></a>

## 发布同名或同版本的软件包

当你发布时：

- 具有不同数据的相同软件包，它会覆盖现有软件包。
- 具有相同数据的相同软件包，会发生 `400 Bad request` 错误。

<a id="install-a-composer-package"></a>

## 安装 Composer 软件包

从软件包仓库安装软件包，以便你可以将其用作依赖项。

先决条件：

- 软件包仓库中的软件包。
- 在负责发布该软件包的项目中启用了软件包仓库。
- 群组 ID，位于群组的主页上。
- 以下令牌类型之一：
  - 范围至少设置为 `api` 的[个人访问令牌](../../profile/personal_access_tokens.md)。
  - 范围设置为 `read_package_registry`、`write_package_registry` 或两者都有的[部署令牌](../../project/deploy_tokens/_index.md)。
  - [CI/CD Job 令牌](../../../ci/jobs/ci_job_token.md)

要安装软件包：

1. 将软件包仓库 URL 以及你要安装的软件包名称和版本添加到项目的 `composer.json` 文件中：

   - 连接到你的群组的软件包仓库：

     ```shell
     composer config repositories.<group_id> composer https://gitlab.example.com/api/v4/group/<group_id>/-/packages/composer/packages.json
     ```

   - 设置所需的软件包版本：

     ```shell
     composer require <package_name>:<version>
     ```

   生成的 `composer.json` 文件内容：

   ```json
   {
     ...
     "repositories": {
       "<group_id>": {
         "type": "composer",
         "url": "https://gitlab.example.com/api/v4/group/<group_id>/-/packages/composer/packages.json"
       },
       ...
     },
     "require": {
       ...
       "<package_name>": "<version>"
     },
     ...
   }
   ```

   你可以使用以下命令取消此设置：

   ```shell
   composer config --unset repositories.<group_id>
   ```

   - `<group_id>` 是群组 ID。
   - `<package_name>` 是在你的软件包的 `composer.json` 文件中定义的软件包名称。
   - `<version>` 是软件包版本。

1. 使用你的极狐GitLab 凭据创建一个 `auth.json` 文件：

   使用个人访问令牌：

   ```shell
   composer config gitlab-token.<DOMAIN-NAME> <personal_access_token>
   ```

   生成的 `auth.json` 文件内容：

   ```json
   {
     ...
     "gitlab-token": {
       "<DOMAIN-NAME>": "<personal_access_token>",
       ...
     }
   }
   ```

   使用部署令牌：

   ```shell
   composer config gitlab-token.<DOMAIN-NAME> <deploy_token_username> <deploy_token>
   ```

   生成的 `auth.json` 文件内容：

   ```json
   {
     ...
     "gitlab-token": {
       "<DOMAIN-NAME>": {
         "username": "<deploy_token_username>",
         "token": "<deploy_token>",
       ...
     }
   }
   ```

   使用 CI/CD Job 令牌：

   ```shell
   composer config -- gitlab-token.<DOMAIN-NAME> gitlab-ci-token "${CI_JOB_TOKEN}"
   ```

   生成的 `auth.json` 文件内容：

   ```json
   {
     ...
     "gitlab-token": {
       "<DOMAIN-NAME>": {
         "username": "gitlab-ci-token",
         "token": "<ci-job-token>",
       ...
     }
   }
   ```

   你可以使用以下命令取消此设置：

   ```shell
   composer config --unset --auth gitlab-token.<DOMAIN-NAME>
   ```

   - `<DOMAIN-NAME>` 是 极狐GitLab 实例 URL `jihulab.com` 或 `gitlab.example.com`。
   - `<personal_access_token>` 范围设置为 `api`，或 `<deploy_token>` 范围设置为 `read_package_registry` 和/或 `write_package_registry`。

1. 如果你使用的是极狐GitLab 私有化部署，请将 `gitlab-domains` 添加到 `composer.json`。

   ```shell
   composer config gitlab-domains gitlab01.example.com gitlab02.example.com
   ```

   生成的 `composer.json` 文件内容：

   ```json
   {
     ...
     "repositories": [
       { "type": "composer", "url": "https://gitlab.example.com/api/v4/group/<group_id>/-/packages/composer/packages.json" }
     ],
     "config": {
       ...
       "gitlab-domains": ["gitlab01.example.com", "gitlab02.example.com"]
     },
     "require": {
       ...
       "<package_name>": "<version>"
     },
     ...
   }
   ```

   你可以使用以下命令取消此设置：

   ```shell
   composer config --unset gitlab-domains
   ```

   > [!note]
   > 在 JihuLab.com 上，Composer 默认使用 `auth.json` 中的极狐GitLab 令牌作为私有令牌。
   > 如果在 `composer.json` 中没有定义 `gitlab-domains`，Composer 会将极狐GitLab 令牌用作基本认证，令牌作为用户名，密码为空。这会导致 401 错误。

1. 配置好 `composer.json` 和 `auth.json` 文件后，你可以通过运行以下命令来安装软件包：

   ```shell
   composer update
   ```

   或者只安装单个软件包：

   ```shell
   composer req <package-name>:<package-version>
   ```

> [!warning]
> 永远不要将 `auth.json` 文件提交到你的仓库中。要从 CI/CD 作业安装软件包，
> 请考虑使用 [`composer config`](https://getcomposer.org/doc/articles/handling-private-packages.md#satis) 工具，并将你的访问令牌存储在
> [极狐GitLab CI/CD 变量](../../../ci/variables/_index.md) 或 [HashiCorp Vault](../../../ci/secrets/_index.md) 中。

<a id="install-from-source"></a>

### 从源代码安装

你可以通过直接拉取 Git 仓库来从源代码安装。为此，可以执行以下任一操作：

- 使用 `--prefer-source` 选项：

  ```shell
  composer update --prefer-source
  ```

- 在 `composer.json` 中，使用 [`config` 键下的 `preferred-install` 字段](https://getcomposer.org/doc/06-config.md#preferred-install)：

  ```json
  {
    ...
    "config": {
      "preferred-install": {
        "<package name>": "source"
      }
    }
    ...
   }
  ```

<a id="ssh-access"></a>

#### SSH 访问

{{< history >}}

- 在极狐GitLab 16.4 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/119739)，带有一个名为 `composer_use_ssh_source_urls` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 16.5 [在私有化部署版上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/329246)。
- 在极狐GitLab 16.6 [GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/135467)。功能标志 `composer_use_ssh_source_urls` 被移除。

{{< /history >}}

当你从源代码安装时，`composer` 会配置对项目 Git 仓库的访问权限。
根据项目的可见性，访问类型有所不同：

- 在公开项目上，使用 `https` Git URL。确保你可以[使用 HTTPS 克隆仓库](../../../topics/git/clone.md#clone-with-https)。
- 在内部或私有项目上，使用 `ssh` Git URL。确保你可以[使用 SSH 克隆仓库](../../../topics/git/clone.md#clone-with-ssh)。

你可以[通过极狐GitLab CI/CD 使用 SSH 密钥](../../../ci/jobs/ssh_keys.md) 从 CI/CD 作业访问 `ssh` Git URL。

<a id="working-with-deploy-tokens"></a>

### 使用部署令牌

尽管 Composer 软件包在群组级别访问，但可以使用群组或项目部署令牌来访问它们：

- 群组部署令牌可以访问发布到该群组或其子群组中项目的所有软件包。
- 项目部署令牌只能访问发布到该特定项目的软件包。

<a id="delete-a-composer-package"></a>

## 删除 Composer 软件包

先决条件：

- 你必须具有维护者或所有者角色。

在删除软件包之前，请确保你了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="troubleshooting"></a>

## 故障排除

<a id="caching"></a>

### 缓存

为了提高性能，Composer 会缓存与软件包相关的文件。Composer 不会自行删除数据。随着新软件包的安装，缓存会增长。如果遇到问题，请使用以下命令清除缓存：

```shell
composer clearcache
```

<a id="authorization-requirement-when-using-composer-install"></a>

### 使用 `composer install` 时的授权要求

[下载软件包存档](../../../api/packages/composer.md#download-a-package-archive) 端点需要授权。如果在使用 `composer install` 时遇到凭据提示，请按照[安装 Composer 软件包](#install-a-composer-package) 部分的说明创建 `auth.json` 文件。

<a id="publish-fails-with-the-file-composerjson-was-not-found"></a>

### 发布失败并提示 `The file composer.json was not found`

你可能会看到错误信息 `The file composer.json was not found`。

当未满足[发布软件包的配置要求](#publish-a-composer-package-by-using-the-api)时，会出现此问题。

要解决此错误，请将 `composer.json` 文件提交到项目根目录。

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab Composer 仓库支持以下 Composer CLI 命令：

- `composer install`：安装 Composer 依赖项。
- `composer update`：安装最新版本的 Composer 依赖项。