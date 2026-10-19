---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Dpl 作为部署工具
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Dpl](https://github.com/travis-ci/dpl)（读音同字母 D-P-L）是一款为持续部署而打造的部署工具，由 Travis CI 开发和使用，但也可以与极狐GitLab CI/CD 配合使用。

Dpl 可用于部署到任何[受支持的提供商](https://github.com/travis-ci/dpl#supported-providers)。

<a id="prerequisite"></a>

## 先决条件

要使用 Dpl，您至少需要 Ruby 1.9.3，并具有安装 gem 的权限。

<a id="basic-usage"></a>

## 基本用法

Dpl 可以通过以下命令安装到任何机器上：

```shell
gem install dpl
```

这样您就可以在本地终端中测试所有命令，而不必在 CI 服务器上进行测试。

如果您没有安装 Ruby，可以在兼容 Debian 的 Linux 上执行以下操作：

```shell
apt-get update
apt-get install ruby-dev
```

Dpl 支持多种服务，包括 Heroku、Cloud Foundry 和 AWS/S3。
要使用它，请定义 provider（提供商）以及该提供商所需的任何其他参数。

例如，如果您想用它把应用程序部署到 Heroku，需要将 `heroku` 指定为提供商，并指定 `api_key` 和 `app`。所有可用参数都可以在 [Heroku API 部分](https://github.com/travis-ci/dpl#heroku-api)中找到。

```yaml
staging:
  stage: deploy
  script:
    - gem install dpl
    - dpl heroku api --app=my-app-staging --api_key=$HEROKU_STAGING_API_KEY
  environment: staging
```

上一个示例使用 Dpl 将 `my-app-staging` 部署到 Heroku 服务器，其中 API 密钥存储在 `HEROKU_STAGING_API_KEY` 安全变量中。

要使用其他提供商，请参阅[受支持的提供商](https://github.com/travis-ci/dpl#supported-providers)。

<a id="using-dpl-with-docker"></a>

## 在 Docker 中使用 Dpl

在大多数情况下，您会将[极狐GitLab Runner](https://gitlab.cn/docs/runner/) 配置为使用服务器的 shell 命令。这意味着所有命令都在本地用户（例如 `gitlab_runner` 或 `gitlab_ci_multi_runner`）的上下文中运行。这也意味着您的 Docker 容器中很可能没有安装 Ruby 运行时。您必须安装它：

```yaml
staging:
  stage: deploy
  script:
    - apt-get update -yq
    - apt-get install -y ruby-dev
    - gem install dpl
    - dpl heroku api --app=my-app-staging --api_key=$HEROKU_STAGING_API_KEY
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: staging
```

第一行 `apt-get update -yq` 更新可用软件包列表，第二行 `apt-get install -y ruby-dev` 在系统上安装 Ruby 运行时。上一个示例适用于所有兼容 Debian 的系统。

<a id="usage-in-staging-and-production"></a>

## 在预发布环境和生产环境中使用

在开发工作流中，同时拥有预发布（开发）环境和生产环境是很常见的。

请看以下示例：您希望将 `main` 分支部署到 `staging`，并将所有标签部署到 `production` 环境。该配置最终的 `.gitlab-ci.yml` 如下所示：

```yaml
staging:
  stage: deploy
  script:
    - gem install dpl
    - dpl heroku api --app=my-app-staging --api_key=$HEROKU_STAGING_API_KEY
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: staging

production:
  stage: deploy
  script:
    - gem install dpl
    - dpl heroku api --app=my-app-production --api_key=$HEROKU_PRODUCTION_API_KEY
  rules:
    - if: $CI_COMMIT_TAG
  environment: production
```

您创建了两个在不同事件上执行的部署作业：

- `staging`：针对推送到 `main` 分支的所有提交执行
- `production`：针对所有推送的标签执行

这些作业还使用了两个安全变量：

- `HEROKU_STAGING_API_KEY`：用于部署预发布应用的 Heroku API 密钥
- `HEROKU_PRODUCTION_API_KEY`：用于部署生产应用的 Heroku API 密钥

<a id="storing-api-keys"></a>

## 存储 API 密钥

要将 API 密钥存储为安全变量：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开**变量**。

在项目设置中定义的变量会随构建脚本一起发送给 runner。安全变量存储在代码仓库之外。切勿将密钥存储在项目的 `.gitlab-ci.yml` 文件中。同样重要的是，密钥的值要在作业日志中隐藏。

您可以通过在变量名称前加上 `$`（在非 Windows runner 上）
或 `%`（对于 Windows Batch runner）来访问所添加的变量：

- `$VARIABLE`：用于非 Windows runner
- `%VARIABLE%`：用于 Windows Batch runner

阅读更多关于 [CI/CD 变量](../../variables/_index.md)的内容。
