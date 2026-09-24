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

[Dpl](https://github.com/travis-ci/dpl)（发音类似字母 D-P-L）是一个用于持续部署的部署工具，最初由 Travis CI 开发并为其所用，但也可以与极狐GitLab CI/CD 一起使用。

Dpl 可以部署到任何[支持的提供商](https://github.com/travis-ci/dpl#supported-providers)。

<a id="prerequisite"></a>

## 先决条件

使用 Dpl，你需要至少 Ruby 1.9.3，并能够安装 gems。

<a id="basic-usage"></a>

## 基本用法

Dpl 可以在任何机器上通过以下命令安装：

```shell
gem install dpl
```

这样你可以在本地终端测试所有命令，而无需在 CI 服务器上测试。

如果你没有安装 Ruby，可以在基于 Debian 的 Linux 上执行：

```shell
apt-get update
apt-get install ruby-dev
```

Dpl 支持大量服务，包括：Heroku、Cloud Foundry、AWS/S3 等。
要使用它，需要指定 provider（提供商）以及该提供商所需的任何额外参数。

例如，如果你想用它把应用程序部署到 Heroku，需要指定 `heroku` 作为提供商，并指定 `api_key` 和 `app`。
所有可能的参数可以在 [Heroku API 部分](https://github.com/travis-ci/dpl#heroku-api) 找到。

```yaml
staging:
  stage: deploy
  script:
    - gem install dpl
    - dpl heroku api --app=my-app-staging --api_key=$HEROKU_STAGING_API_KEY
  environment: staging
```

上述示例使用 Dpl 将 `my-app-staging` 部署到 Heroku 服务器，其 API 密钥存储在 `HEROKU_STAGING_API_KEY` 安全变量中。

要使用其他提供商，请参阅[支持的提供商](https://github.com/travis-ci/dpl#supported-providers)的长列表。

<a id="using-dpl-with-docker"></a>

## 使用 Dpl 与 Docker

在大多数情况下，你配置了[极狐GitLab Runner](https://gitlab.cn/docs/runner) 以使用服务器 shell 命令。
这意味着所有命令都在本地用户（例如 `gitlab_runner` 或 `gitlab_ci_multi_runner`）的上下文中运行。
这也意味着你的 Docker 容器中很可能没有安装 Ruby 运行时。
你必须安装它：

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

第一行 `apt-get update -yq` 更新可用软件包列表，
第二行 `apt-get install -y ruby-dev` 在系统上安装 Ruby 运行时。
前面的示例适用于所有基于 Debian 的系统。

<a id="usage-in-staging-and-production"></a>

## 在 staging 和 production 中使用

开发工作流中很常见 staging（开发）和 production 环境。

考虑以下示例：你希望将 `main` 分支部署到 `staging`，并将所有标签部署到 `production` 环境。
最终的 `.gitlab-ci.yml` 配置如下：

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

你创建了两个部署作业，它们在不同的条件下执行：

- `staging`：对所有推送到 `main` 分支的提交执行
- `production`：对所有推送的标签执行

这两个作业还使用了两个安全变量：

- `HEROKU_STAGING_API_KEY`：用于部署 staging 应用程序的 Heroku API 密钥
- `HEROKU_PRODUCTION_API_KEY`：用于部署 production 应用程序的 Heroku API 密钥

<a id="storing-api-keys"></a>

## 存储 API 密钥

要将 API 密钥存储为安全变量：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。

项目设置中定义的变量会随构建脚本一起发送给 runner。
安全变量存储在仓库之外。切勿将密钥存储在项目的 `.gitlab-ci.yml` 文件中。同样重要的是，密钥的值在作业日志中是隐藏的。

你通过在变量名前加上 `$`（非 Windows runner）或 `%`（Windows Batch runner）来访问添加的变量：

- `$VARIABLE`：用于非 Windows runner
- `%VARIABLE%`：用于 Windows Batch runner

阅读更多关于 [CI/CD 变量](../../variables/_index.md) 的信息。