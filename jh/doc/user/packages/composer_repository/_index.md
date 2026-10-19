---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Composer 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!warning]
> 极狐GitLab 的 Composer 软件包仓库仍在开发中，由于功能有限，尚不适用于生产环境。此[史诗](https://gitlab.com/groups/gitlab-org/-/work_items/6817)详细说明了使其可用于生产环境所需的剩余工作和时间线。

在项目的软件包仓库中发布 [Composer](https://getcomposer.org/) 软件包。之后，当您需要将其用作依赖项时，即可安装这些软件包。

有关 Composer 客户端使用的特定 API 端点的文档，请参见 [Composer API 文档](../../../api/packages/composer.md)。

建议使用 Composer v2.0。Composer v1.0 受支持，但在软件包数量非常多的群组中工作时性能较低。

了解如何[构建 Composer 软件包](../workflows/build_packages.md#composer)。

<a id="publish-a-composer-package-by-using-the-api"></a>

## 使用 API 发布 Composer 软件包

将 Composer 软件包发布到软件包仓库，以便任何可以访问该项目的人都能将该软件包用作依赖项。

先决条件：

- 极狐GitLab 代码仓库中有一个软件包。Composer 软件包应根据
  [Composer 规范](https://getcomposer.org/doc/04-schema.md#version)进行版本控制。
  如果版本无效，例如包含三个点（`1.0.0.0`），
  发布时会出现错误（`Validation failed: Version is invalid`）。
- 项目根目录中有一个有效的 `composer.json` 文件。
- 极狐GitLab 代码仓库中已启用软件包功能。
- 项目 ID，显示在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上。
- 以下令牌类型之一：
  - 作用域设置为 `api`的[个人访问令牌](../../profile/personal_access_tokens.md)。
  - 作用域设置为 `write_package_registry`的[部署令牌](../../project/deploy_tokens/_index.md)。

使用个人访问令牌发布软件包：

- 向[软件包 API](../../../api/packages.md) 发送 `POST` 请求。

  例如，您可以使用 `curl`：

  ```shell
  curl --fail-with-body --data tag=<tag> "https://__token__:<personal-access-token>@gitlab.example.com/api/v4/projects/<project_id>/packages/composer"
  ```

  - `<personal-access-token>` 是您的个人访问令牌。
  - `<project_id>` 是您的项目 ID。
  - `<tag>` 是您要发布的版本的 Git 标签名称。
    要发布分支，请使用 `branch=<branch>` 代替 `tag=<tag>`。

使用部署令牌发布软件包：

- 向[软件包 API](../../../api/packages.md) 发送 `POST` 请求。

  例如，您可以使用 `curl`：

  ```shell
  curl --fail-with-body --data tag=<tag> --header "Deploy-Token: <deploy-token>" "https://gitlab.example.com/api/v4/projects/<project_id>/packages/composer"
  ```

  - `<deploy-token>` 是您的部署令牌
  - `<project_id>` 是您的项目 ID。
  - `<tag>` 是您要发布的版本的 Git 标签名称。
    要发布分支，请使用 `branch=<branch>` 代替 `tag=<tag>`。

您可以前往**部署** > **软件包仓库**，然后选择 **Composer** 标签页，查看已发布的软件包。

<a id="publish-a-composer-package-by-using-cicd"></a>

## 使用 CI/CD 发布 Composer 软件包

您可以将 Composer 软件包作为 CI/CD 流程的一部分发布到软件包仓库。

1. 在 `.gitlab-ci.yml` 文件中指定 `CI_JOB_TOKEN`：

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

要查看已发布的软件包，请前往**部署** > **软件包仓库**，然后选择 **Composer** 标签页。

<a id="use-a-cicd-template"></a>

### 使用 CI/CD 模板

更详细的 Composer CI/CD 文件也可作为 `.gitlab-ci.yml` 模板使用：

1. 在左侧边栏中，选择**项目概览**。
1. 在文件列表上方，选择**设置 CI/CD**。如果此按钮不可用，请选择 **CI/CD 配置**，然后选择**编辑**。
1. 从**应用模板**列表中，选择 **Composer**。

> [!warning]
> 除非您想覆盖现有的 CI/CD 文件，否则请勿保存。

<a id="publishing-packages-with-the-same-name-or-version"></a>

## 发布同名或同版本的软件包

当您发布时：

- 数据不同的同名软件包，会覆盖现有软件包。
- 数据相同的同名软件包，会出现 `400 Bad request` 错误。

<a id="install-a-composer-package"></a>

## 安装 Composer 软件包

从软件包仓库安装软件包，以便将其用作依赖项。

先决条件：

- 软件包仓库中有一个软件包。
- 负责发布该软件包的项目中已启用软件包仓库。
- 群组 ID，位于群组主页上。
- 以下令牌类型之一：
  - 作用域至少设置为 `api`的[个人访问令牌](../../profile/personal_access_tokens.md)。
  - 作用域设置为 `read_package_registry`、`write_package_registry` 或两者的[部署令牌](../../project/deploy_tokens/_index.md)。
  - [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)

安装软件包：

1. 将软件包仓库 URL 以及您要安装的软件包名称和版本添加到项目的 `composer.json` 文件中：

   - 连接到您群组的软件包仓库：

     ```shell
     composer config repositories.<group_id> composer https://gitlab.example.com/api/v4/group/<group_id>/-/packages/composer/packages.json
     ```

   - 设置所需的软件包版本：

     ```shell
     composer require <package_name>:<version>
     ```

   `composer.json` 文件中的结果：

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

   您可以使用以下命令取消设置：

   ```shell
   composer config --unset repositories.<group_id>
   ```

   - `<group_id>` 是群组 ID。
   - `<package_name>` 是软件包的 `composer.json` 文件中定义的软件包名称。
   - `<version>` 是软件包版本。

1. 使用您的极狐GitLab 凭据创建 `auth.json` 文件：

   使用个人访问令牌：

   ```shell
   composer config gitlab-token.<DOMAIN-NAME> <personal_access_token>
   ```

   `auth.json` 文件中的结果：

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

   `auth.json` 文件中的结果：

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

   使用 CI/CD 作业令牌：

   ```shell
   composer config -- gitlab-token.<DOMAIN-NAME> gitlab-ci-token "${CI_JOB_TOKEN}"
   ```

   `auth.json` 文件中的结果：

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

   您可以使用以下命令取消设置：

   ```shell
   composer config --unset --auth gitlab-token.<DOMAIN-NAME>
   ```

   - `<DOMAIN-NAME>` 是极狐GitLab 实例 URL `gitlab.com` 或 `gitlab.example.com`。
   - `<personal_access_token>` 的作用域设置为 `api`，或者 `<deploy_token>` 的作用域设置
     为 `read_package_registry` 和/或 `write_package_registry`。

1. 如果您使用的是极狐GitLab 私有化部署，请将 `gitlab-domains` 添加到 `composer.json`。

   ```shell
   composer config gitlab-domains gitlab01.example.com gitlab02.example.com
   ```

   `composer.json` 文件中的结果：

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

   您可以使用以下命令取消设置：

   ```shell
   composer config --unset gitlab-domains
   ```

   > [!note]
   > 在 JihuLab.com 上，Composer 默认将 `auth.json`中的极狐GitLab 令牌用作私有令牌。
   > 如果 `composer.json`中没有定义 `gitlab-domains`，Composer 会将极狐GitLab 令牌
   > 用作基本认证，其中令牌作为用户名，密码为空。这会导致 401 错误。

1. 配置好 `composer.json` 和 `auth.json` 文件后，您可以通过运行以下命令来安装软件包：

   ```shell
   composer update
   ```

   或者安装单个软件包：

   ```shell
   composer req <package-name>:<package-version>
   ```

> [!warning]
> 切勿将 `auth.json` 文件提交到您的代码仓库。要从 CI/CD 作业安装软件包，
> 请考虑使用 [`composer config`](https://getcomposer.org/doc/articles/handling-private-packages.md#satis) 工具，并将您的访问令牌
> 存储在[极狐GitLab CI/CD 变量](../../../ci/variables/_index.md)或
> [HashiCorp Vault](../../../ci/secrets/_index.md)中。

<a id="install-from-source"></a>

### 从源代码安装

您可以通过直接拉取 Git 代码仓库来从源代码安装。为此，您可以：

- 使用 `--prefer-source` 选项：

  ```shell
  composer update --prefer-source
  ```

- 在 `composer.json`中，使用 [`config` 键下的 `preferred-install` 字段](https://getcomposer.org/doc/06-config.md#preferred-install)：

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

当您从源代码安装时，`composer` 会配置对项目 Git 代码仓库的访问。根据项目可见性，访问类型有所不同：

- 在公开项目中，使用 `https` Git URL。请确保您能够[使用 HTTPS 克隆代码仓库](../../../topics/git/clone.md#clone-with-https)。
- 在内部或私有项目中，使用 `ssh` Git URL。请确保您能够[使用 SSH 克隆代码仓库](../../../topics/git/clone.md#clone-with-ssh)。

您可以在 CI/CD 作业中使用[极狐GitLab CI/CD 的 SSH 密钥](../../../ci/jobs/ssh_keys.md)访问 `ssh` Git URL。

<a id="working-with-deploy-tokens"></a>

### 使用部署令牌

尽管 Composer 软件包是在群组级别访问的，但群组或项目部署令牌均可用于访问它们：

- 群组部署令牌可以访问发布到该群组或其
  子群组中项目的所有软件包。
- 项目部署令牌只能访问发布到该特定项目的软件包。

<a id="delete-a-composer-package"></a>

## 删除 Composer 软件包

先决条件：

- 您必须具有维护者或所有者角色。

在删除软件包之前，请确保您了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，您可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="troubleshooting"></a>

## 故障排除

<a id="caching"></a>

### 缓存

为提高性能，Composer 会缓存与软件包相关的文件。Composer 不会自行删除数据。随着新软件包的安装，缓存会不断增长。如果遇到问题，请使用以下命令清除缓存：

```shell
composer clearcache
```

<a id="authorization-requirement-when-using-composer-install"></a>

### 使用 `composer install` 时的授权要求

[下载软件包归档](../../../api/packages/composer.md#download-a-package-archive)端点需要授权。如果您在使用 `composer install` 时遇到凭据提示，请按照[安装 Composer 软件包](#install-a-composer-package)一节的说明创建 `auth.json` 文件。

<a id="publish-fails-with-the-file-composerjson-was-not-found"></a>

### 发布失败并显示 `The file composer.json was not found`

您可能会看到错误信息 `The file composer.json was not found`。

当[发布软件包的配置要求](#publish-a-composer-package-by-using-the-api)未满足时，会出现此问题。

要解决该错误，请将 `composer.json` 文件提交到项目根目录。

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab Composer 仓库支持以下 Composer CLI 命令：

- `composer install`：安装 Composer 依赖项。
- `composer update`：安装最新版本的 Composer 依赖项。
