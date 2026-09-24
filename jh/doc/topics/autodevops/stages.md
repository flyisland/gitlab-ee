---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Auto DevOps 的各个阶段
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

以下章节介绍了 [Auto DevOps](_index.md) 的各个阶段。
请仔细阅读，以了解每个阶段的工作原理。

## Auto Build

> [!note]
> 如果极狐GitLab Runner 无法使用 Docker in Docker（例如在 OpenShift 集群中），则不支持 Auto Build。极狐GitLab 对 OpenShift 的支持跟踪于[一个专门的史诗](https://jihulab.com/groups/gitlab-cn/-/epics/2068)中。

Auto Build 使用现有的 `Dockerfile` 或 Heroku 构建包来构建应用程序。生成的 Docker 镜像会推送至[容器镜像仓库](../../user/packages/container_registry/_index.md)，并使用提交 SHA 或标签进行标记。

### 使用 Dockerfile 进行 Auto Build

如果项目的代码仓根目录中包含 `Dockerfile`，Auto Build 会使用 `docker build` 创建 Docker 镜像。

如果你同时使用 Auto Review Apps 和 Auto Deploy，并选择提供自己的 `Dockerfile`，则必须执行以下任一操作：

- 将应用程序暴露在 `5000` 端口上，因为[默认的 Helm Chart](https://jihulab.com/gitlab-cn/cluster-integration/auto-deploy-image/-/tree/master/assets/auto-deploy-app) 假定此端口可用。
- 通过[自定义 Auto Deploy Helm chart](customize.md#custom-helm-chart) 来覆盖默认值。

### 使用 Cloud Native Buildpacks 进行 Auto Build

如果项目中存在 `Dockerfile`，Auto Build 会使用它来构建应用程序。如果不存在 `Dockerfile`，Auto Build 会使用 [Cloud Native Buildpacks](https://buildpacks.io) 来检测并构建应用程序为 Docker 镜像。该功能使用了 [`pack` 命令](https://github.com/buildpacks/pack)。默认的[构建器](https://buildpacks.io/docs/for-app-developers/concepts/builder/)为 `heroku/buildpacks:22`，但可以通过 CI/CD 变量 `AUTO_DEVOPS_BUILD_IMAGE_CNB_BUILDER` 选择其它构建器。

每个构建包都要求项目的代码仓中包含特定的文件，以便 Auto Build 能够成功构建应用程序。具体的结构取决于你所选的构建器和构建包。
例如，当使用 Heroku 构建器（默认）时，应用程序的根目录必须包含适用于其语言的相应文件：

- 对于 Python 项目，需要 `Pipfile` 或 `requirements.txt` 文件。
- 对于 Ruby 项目，需要 `Gemfile` 或 `Gemfile.lock` 文件。

关于其他语言和框架的要求，请阅读 [Heroku buildpacks 文档](https://devcenter.heroku.com/articles/buildpacks#officially-supported-buildpacks)。

> [!note]
> Auto Test 仍然使用 Herokuish，因为测试套件检测尚未纳入 Cloud Native Buildpack 规范。更多信息，请参阅 [issue 212689](https://jihulab.com/gitlab-cn/gitlab/-/issues/212689)。

#### 将卷挂载到构建容器

变量 `BUILDPACK_VOLUMES` 可用于向 `pack` 命令传递卷挂载定义。这些挂载通过 `--volume` 参数传递给 `pack build`。
每个卷定义可以包含 `pack build` 提供的任何功能，例如主机路径、目标路径、卷是否可写以及一个或多个卷选项。

使用管道符 `|` 来传递多个卷。
列表中的每一项都通过单独的 `--volume` 参数传递给 `pack build`。

在以下示例中，三个卷被挂载到容器的 `/etc/foo`、`/opt/foo` 和 `/var/opt/foo`：

```yaml
buildjob:
  variables:
    BUILDPACK_VOLUMES: /mnt/1:/etc/foo:ro|/mnt/2:/opt/foo:ro|/mnt/3:/var/opt/foo:rw
```

更多关于卷定义的信息，请参阅 [`pack build` 文档](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/cli/pack_build/)。

### 从 Herokuish 迁移到 Cloud Native Buildpacks

使用 Cloud Native Buildpacks 构建的支持选项与使用 Herokuish 构建相同，但有以下注意事项：

- 构建包必须是 Cloud Native Buildpack。可以使用 Heroku 的 [`cnb-shim`](https://github.com/heroku/cnb-shim) 将 Heroku buildpack 转换为 Cloud Native Buildpack。
- `BUILDPACK_URL` 必须使用 [`pack` 支持的格式](https://buildpacks.io/docs/app-developer-guide/specify-buildpacks/)。
- 构建的镜像中不存在 `/bin/herokuish` 命令，不再需要（也不可能）在命令前添加 `/bin/herokuish procfile exec`。相反，自定义命令应添加前缀 `/cnb/lifecycle/launcher` 以获得正确的执行环境。

## Auto Test

Auto Test 通过使用 [Herokuish](https://github.com/gliderlabs/herokuish) 和 [Heroku buildpacks](https://devcenter.heroku.com/articles/buildpacks) 分析项目以检测语言和框架，为你的应用程序运行合适的测试。多种语言和框架会被自动检测，但如果你的语言未被检测到，或许可以创建一个[自定义构建包](customize.md#custom-buildpacks)。请检查[当前支持的语言](#currently-supported-languages)。

Auto Test 会使用你应用程序中已有的测试。如果没有测试，就需要自行添加。

<!-- vale gitlab_base.Spelling = NO -->

> [!note]
> 并非所有 [Auto Build](#auto-build) 支持的构建包都被 Auto Test 支持。
> Auto Test 使用 [Herokuish](https://jihulab.com/gitlab-cn/gitlab/-/issues/212689)，*而不是*
> Cloud Native Buildpacks，并且仅支持实现 [Testpack API](https://devcenter.heroku.com/articles/testpack-api) 的构建包。

<!-- vale gitlab_base.Spelling = YES -->

### 当前支持的语言

由于 Auto Test 是一个相对较新的增强功能，并非所有构建包都支持它。Heroku 的[官方支持的语言](https://devcenter.heroku.com/articles/heroku-ci#supported-languages)都支持 Auto Test。由 Heroku 的 Herokuish 构建包支持的语言均支持 Auto Test，但值得注意的是 multi-buildpack 不支持。

支持的构建包有：

```plaintext
- heroku-buildpack-multi
- heroku-buildpack-ruby
- heroku-buildpack-nodejs
- heroku-buildpack-clojure
- heroku-buildpack-python
- heroku-buildpack-java
- heroku-buildpack-gradle
- heroku-buildpack-scala
- heroku-buildpack-play
- heroku-buildpack-php
- heroku-buildpack-go
- buildpack-nginx
```

如果你的应用程序需要上述列表之外的构建包，可能需要使用[自定义构建包](customize.md#custom-buildpacks)。

## Auto Code Quality

{{< history >}}

- 在 13.2 中，从 GitLab 入门版移至 GitLab 基础版。

{{< /history >}}

Auto Code Quality 使用[代码质量镜像](https://jihulab.com/gitlab-cn/ci-cd/codequality)对当前代码进行静态分析和其他代码检查。生成报告后，它会被上传为一个产物，你可以稍后下载并查看。合并请求组件也会显示[源分支与目标分支之间的差异](../../ci/testing/code_quality.md)。

## Auto SAST

{{< history >}}

- 在 [极狐GitLab 旗舰版](https://gitlab.cn/pricing/) 10.3 中引入。
- 从 13.1 开始，部分功能在所有版本中可用。

{{< /history >}}

静态应用安全测试（SAST）对当前代码执行静态分析，并检查潜在的安全问题。Auto SAST 阶段要求 [GitLab Runner](https://gitlab.cn/docs/runner/) 11.5 或更高版本。

生成报告后，它会被上传为一个产物，你可以稍后下载并查看。合并请求组件在[旗舰版](https://gitlab.cn/pricing/)许可证下也会显示任何安全警告。

更多信息，请参阅 [SAST](../../user/application_security/sast/_index.md)。

## Auto secret detection

密钥检测使用[密钥检测 Docker 镜像](https://jihulab.com/gitlab-cn/security-products/analyzers/secrets)扫描当前代码，并检查已泄露的密钥。

生成报告后，它会被上传为一个产物，你可以稍后下载并评估。合并请求组件在[旗舰版](https://gitlab.cn/pricing/)许可证下也会显示任何安全警告。

更多信息，请参阅[密钥检测](../../user/application_security/secret_detection/_index.md)。

## Auto dependency scanning

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

依赖项扫描分析项目的依赖项，并检查潜在的安全问题。Auto dependency scanning 阶段在非[旗舰版](https://gitlab.cn/pricing/)许可证上会被跳过。

生成报告后，它会被上传为一个产物，你可以稍后下载并查看。合并请求组件会显示检测到的任何安全警告。

更多信息，请参阅[依赖项扫描](../../user/application_security/dependency_scanning/_index.md)。

## Auto container scanning

容器漏洞静态分析使用 [Trivy](https://aquasecurity.github.io/trivy/latest/) 检查 Docker 镜像中的潜在安全问题。auto container scanning 阶段在非[旗舰版](https://gitlab.cn/pricing/)许可证上会被跳过。

生成报告后，它会被上传为一个产物，你可以稍后下载并查看。合并请求会显示检测到的任何安全问题。

更多信息，请参阅[容器扫描](../../user/application_security/container_scanning/_index.md)。

## Auto Review Apps

这是一个可选步骤，因为许多项目没有可用的 Kubernetes 集群。如果未满足[要求](requirements.md)，该作业会静默跳过。

[评审应用](../../ci/review_apps/_index.md)是基于分支代码的临时应用环境，使开发人员、设计师、QA、产品经理和其他评审者能够在评审过程中实际查看和交互代码更改。Auto Review Apps 为每个分支创建一个评审应用。

Auto Review Apps 仅将你的应用部署到 Kubernetes 集群。如果没有可用的集群，则不会发生部署。

评审应用拥有基于项目 ID、分支或标签名称、唯一编号以及 Auto DevOps 基础域名的唯一 URL，例如 `13083-review-project-branch-123456.example.com`。合并请求组件会显示评审应用的链接以便于发现。当分支或标签被删除时（例如合并合并请求后），评审应用也会被删除。

评审应用使用 [auto-deploy-app](https://jihulab.com/gitlab-cn/cluster-integration/auto-deploy-image/-/tree/master/assets/auto-deploy-app) chart 通过 Helm 进行部署，你可以对其进行[自定义](customize.md#custom-helm-chart)。应用程序部署到对应环境的 [Kubernetes 命名空间](../../user/project/clusters/deploy_to_cluster.md#deployment-variables)中。

使用了[本地 Tiller](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/22036)。极狐GitLab 的早期版本中，Tiller 安装在项目命名空间中。

> [!warning]
> 不应在 Helm 之外（直接使用 Kubernetes）对应用进行操作。这会导致 Helm 无法检测到变更，从而使后续使用 Auto DevOps 进行部署时可能撤销你的更改。此外，如果你更改了某些内容并希望通过再次部署来还原，Helm 可能无法检测到之前发生过任何变更，因此不会意识到需要重新应用旧配置。

## Auto DAST

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

动态应用安全测试（DAST）使用广受欢迎的开源工具 [OWASP ZAProxy](https://github.com/zaproxy/zaproxy) 分析当前代码并检查潜在的安全问题。Auto DAST 阶段在非[旗舰版](https://gitlab.cn/pricing/)许可证上会被跳过。

- 在你的默认分支上，DAST 会扫描一个专门为此目的部署的应用，除非你[覆盖 DAST 目标](#overriding-the-dast-target)。DAST 运行后，该应用会被删除。
- 在功能分支上，DAST 会扫描[评审应用](#auto-review-apps)。

DAST 扫描完成后，所有安全警告都会显示在[安全仪表板](../../user/application_security/security_dashboard/_index.md)和合并请求组件上。

更多信息，请参阅[DAST](../../user/application_security/dast/_index.md)。

### 覆盖 DAST 目标

要使用自定义目标而不是自动部署的评审应用，请将 `DAST_WEBSITE` CI/CD 变量设置为 DAST 要扫描的 URL。

> [!warning]
> 如果启用了 [DAST Full Scan](../../user/application_security/dast/browser/_index.md)，极狐GitLab 强烈建议**不要**将 `DAST_WEBSITE` 设置为任何预发布或生产环境。DAST Full Scan 会主动攻击目标，可能导致你的应用程序宕机并造成数据丢失或损坏。

### 跳过 Auto DAST

你可以通过以下方式跳过 DAST 作业：

- 在所有分支上，将 `DAST_DISABLED` CI/CD 变量设置为 `"true"`。
- 仅在默认分支上，将 `DAST_DISABLED_FOR_DEFAULT_BRANCH` 变量设置为 `"true"`。
- 仅在功能分支上，将 `REVIEW_DISABLED` 变量设置为 `"true"`。这也会跳过评审应用。

## Auto Browser Performance Testing

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Auto [浏览器性能测试](../../ci/testing/browser_performance_testing.md) 使用 [Sitespeed.io 容器](https://hub.docker.com/r/sitespeedio/sitespeed.io/) 测量网页的浏览器性能，创建一个包含每个页面总体性能评分的 JSON 报告，并将报告上传为产物。默认情况下，它会测试你的评审环境和生产环境的根页面。如果要测试其他 URL，请将路径添加到根目录下的 `.gitlab-urls.txt` 文件中，每行一个文件。例如：

```plaintext
/
/features
/direction
```

源分支和目标分支之间的任何浏览器性能差异也会[显示在合并请求组件中](../../ci/testing/browser_performance_testing.md)。

## Auto Load Performance Testing

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Auto [负载性能测试](../../ci/testing/load_performance_testing.md) 使用 [k6 容器](https://hub.docker.com/r/loadimpact/k6/) 测量应用程序的服务器性能，创建一个包含多个关键结果指标的 JSON 报告，并将报告上传为产物。

需要进行一些初始设置。需要编写一个针对你特定应用程序量身定制的 [k6](https://k6.io/) 测试。该测试还需要配置为可以通过 CI/CD 变量获取环境的动态 URL。

源分支和目标分支之间的任何负载性能测试结果差异也会[显示在合并请求组件中](../../user/project/merge_requests/widgets.md)。

## Auto Deploy

除了 Kubernetes 集群之外，你还可以选择部署到 [Amazon Elastic Compute Cloud (Amazon EC2)](https://aws.amazon.com/ec2/)。

Auto Deploy 是 Auto DevOps 的可选步骤。如果未满足[要求](requirements.md)，则该作业会被跳过。

当分支或合并请求合并到项目的默认分支后，Auto Deploy 会将应用程序部署到 Kubernetes 集群中的 `production` 环境，其命名空间基于项目名称和唯一项目 ID，例如 `project-4321`。

默认情况下，Auto Deploy 不包括部署到预发布或金丝雀环境，但 [Auto DevOps 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml) 包含了这些任务的作业定义，如果你想启用它们的话。

你可以使用 [CI/CD 变量](cicd_variables.md) 来自动扩缩 Pod 副本，并为 Auto DevOps 的 `helm upgrade` 命令应用自定义参数。这是[自定义 Auto Deploy Helm chart](customize.md#custom-helm-chart) 的一种简便方法。

Helm 使用 [auto-deploy-app](https://jihulab.com/gitlab-cn/cluster-integration/auto-deploy-image/-/tree/master/assets/auto-deploy-app) chart 将应用程序部署到对应环境的 [Kubernetes 命名空间](../../user/project/clusters/deploy_to_cluster.md#deployment-variables)中。

使用了[本地 Tiller](https://gitlab.com/gitlab-org/gitlab-foss/-/merge_requests/22036)。极狐GitLab 的早期版本中，Tiller 安装在项目命名空间中。

> [!warning]
> 不应在 Helm 之外（直接使用 Kubernetes）对应用进行操作。这会导致 Helm 无法检测到变更，从而使后续使用 Auto DevOps 进行部署时可能撤销你的更改。此外，如果你更改了某些内容并希望通过再次部署来还原，Helm 可能无法检测到之前发生过任何变更，因此不会意识到需要重新应用旧配置。

### 极狐GitLab 部署令牌

当启用 Auto DevOps 并保存 Auto DevOps 设置时，会为内部和私有项目创建[极狐GitLab 部署令牌](../../user/project/deploy_tokens/_index.md#gitlab-deploy-token)。你可以使用部署令牌永久访问镜像仓库。手动撤销极狐GitLab 部署令牌后，它不会自动重新创建。

如果找不到极狐GitLab 部署令牌，则会使用 `CI_REGISTRY_PASSWORD`。

> [!note]
> `CI_REGISTRY_PASSWORD` 仅在部署期间有效。Kubernetes 可以在部署期间成功拉取容器镜像，但如果之后需要再次拉取镜像（例如在 Pod 被驱逐后），Kubernetes 将无法做到，因为它会尝试使用 `CI_REGISTRY_PASSWORD` 获取镜像。

### Kubernetes 1.16+

> [!warning]
> `deploymentApiVersion` 设置的默认值已从 `extensions/v1beta` 更改为 `apps/v1`。

在 Kubernetes 1.16 及更高版本中，一些 [API 已被移除](https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/)，包括对 `extensions/v1beta1` 版本中 `Deployment` 的支持。

要在 Kubernetes 1.16+ 集群上使用 Auto Deploy：

1. 如果你是在极狐GitLab 13.0 或更高版本中首次部署应用程序，则应该无需任何配置。
1. 如果你安装了集群内 PostgreSQL 数据库且 `AUTO_DEVOPS_POSTGRES_CHANNEL` 设置为 `1`，请按照[升级 PostgreSQL 指南](upgrading_postgresql.md)操作。

> [!warning]
> 在选择版本 `2` 之前，请按照[升级 PostgreSQL 指南](upgrading_postgresql.md)备份和恢复数据库。

### 迁移

你可以通过设置项目 CI/CD 变量 `DB_INITIALIZE` 和 `DB_MIGRATE` 来配置在应用程序 Pod 内运行的 PostgreSQL 数据库初始化和迁移。

如果设置了 `DB_INITIALIZE`，它会作为 Helm 的 post-install hook 在应用程序 Pod 内以 shell 命令形式运行。由于某些应用程序在没有成功的数据库初始化步骤的情况下无法运行，极狐GitLab 会在首次发布时仅部署数据库初始化步骤，而不部署应用程序。数据库初始化完成后，极狐GitLab 会按照标准方式部署包含应用程序的第二个版本。

post-install hook 意味着如果任何部署成功，则之后不会再处理 `DB_INITIALIZE`。

如果设置了 `DB_MIGRATE`，它会作为 Helm 的 pre-upgrade hook 在应用程序 Pod 内以 shell 命令形式运行。

例如，在一个使用 [Cloud Native Buildpacks](#auto-build-using-cloud-native-buildpacks) 构建的镜像中的 Rails 应用程序：

- `DB_INITIALIZE` 可以设置为 `RAILS_ENV=production /cnb/lifecycle/launcher bin/rails db:setup`
- `DB_MIGRATE` 可以设置为 `RAILS_ENV=production /cnb/lifecycle/launcher bin/rails db:migrate`

除非你的代码仓中包含 `Dockerfile`，否则你的镜像都是使用 Cloud Native Buildpacks 构建的，你必须在这些镜像中运行的命令前加上 `/cnb/lifecycle/launcher` 以复制应用程序的运行环境。

### 升级 auto-deploy-app Chart

你可以按照[升级指南](upgrading_auto_deploy_dependencies.md)升级 auto-deploy-app chart。

### Workers

某些 Web 应用程序必须为“工作进程”运行额外的部署。例如，Rails 应用程序通常使用单独的工作进程来运行后台任务，如发送电子邮件。

Auto Deploy 中使用的[默认 Helm chart](https://jihulab.com/gitlab-cn/cluster-integration/auto-deploy-image/-/tree/master/assets/auto-deploy-app) [支持运行工作进程](https://jihulab.com/gitlab-cn/charts/auto-deploy-app/-/merge_requests/9)。

要运行 worker，你必须确保 worker 能够响应标准的健康检查，这些检查期望在 `5000` 端口上收到成功的 HTTP 响应。对于 [Sidekiq](https://github.com/mperham/sidekiq)，你可以使用 [`sidekiq_alive` gem](https://rubygems.org/gems/sidekiq_alive)。

要使用 Sidekiq，你还必须确保你的部署可以访问 Redis 实例。Auto DevOps 不会为你部署该实例，因此你必须：

- 维护自己的 Redis 实例。
- 设置 CI/CD 变量 `K8S_SECRET_REDIS_URL`（该实例的 URL），以确保它被传递到你的部署中。

在配置 worker 以响应健康检查后，为你的 Rails 应用程序运行 Sidekiq worker。你可以通过在 [`.gitlab/auto-deploy-values.yaml` 文件](customize.md#customize-helm-chart-values)中设置以下内容来启用 worker：

```yaml
workers:
  sidekiq:
    replicaCount: 1
    command:
      - /cnb/lifecycle/launcher
      - sidekiq
    preStopCommand:
      - /cnb/lifecycle/launcher
      - sidekiqctl
      - quiet
    terminationGracePeriodSeconds: 60
```

### 在容器中运行命令

除非你的代码仓中包含[自定义 Dockerfile](#auto-build-using-a-dockerfile)，否则通过 [Auto Build](#auto-build) 构建的应用程序可能需要将命令按如下方式包裹：

```shell
/cnb/lifecycle/launcher $COMMAND
```

可能需要包裹命令的一些原因：

- 使用 `kubectl exec` 进行附加。
- 使用极狐GitLab [Web 终端](../../ci/environments/_index.md#web-terminals-deprecated)。

例如，要从应用程序根目录启动 Rails 控制台，请运行：

```shell
/cnb/lifecycle/launcher procfile exec bin/rails c
```

## Auto Code Intelligence

[极狐GitLab 代码智能](../../user/project/code_intelligence.md) 增加了交互式开发环境（IDE）常见的代码导航功能，包括类型签名、符号文档和跳转到定义。它由 [LSIF](https://lsif.dev/) 提供支持，目前仅适用于使用 Go 语言的 Auto DevOps 项目。极狐GitLab 计划随着更多 LSIF 索引器的推出而添加对更多语言的支持。你可以关注[代码智能史诗](https://jihulab.com/groups/gitlab-cn/-/epics/4212)以获取更新。

此阶段默认启用。你可以通过添加 `CODE_INTELLIGENCE_DISABLED` CI/CD 变量来禁用它。更多关于[禁用 Auto DevOps 作业](cicd_variables.md#job-skipping-variables)的信息。
```