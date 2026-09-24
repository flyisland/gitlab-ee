```xml
---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Auto DevOps 故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档页面中的信息描述了使用 Auto DevOps 时的常见错误以及任何可用的解决方法。

<a id="trace-helm-commands"></a>

## 追踪 Helm 命令

将 CI/CD 变量 `TRACE` 设置为任意值，可以使 Helm 命令生成详细输出。你可以使用此输出来诊断 Auto DevOps 部署问题。

你可以通过更改高级 Auto DevOps 配置变量来解决一些 Auto DevOps 部署问题。阅读更多关于[自定义 Auto DevOps CI/CD 变量](cicd_variables.md)的信息。

<a id="unable-to-select-a-buildpack"></a>

## 无法选择 buildpack

Auto Test 可能无法检测到你的语言或框架，并显示以下错误：

```plaintext
Step 5/11 : RUN /bin/herokuish buildpack build
 ---> Running in eb468cd46085
    -----> Unable to select a buildpack
The command '/bin/sh -c /bin/herokuish buildpack build' returned a non-zero code: 1
```

以下是可能的原因：

- 你的应用程序可能缺少 buildpack 正在寻找的关键文件。Ruby 应用程序需要 `Gemfile` 才能被正确检测到，尽管编写没有 `Gemfile` 的 Ruby 应用程序也是可能的。
- 可能没有适合你应用程序的 buildpack。尝试指定一个[自定义 buildpack](customize.md#custom-buildpacks)。

<a id="builder-sunset-error"></a>

## Builder 停止支持错误

由于此 [Heroku 更新](https://github.com/heroku/cnb-builder-images/pull/478)，传统的 `heroku/buildpacks:20` 和 `heroku/builder-classic:22` 镜像现在会生成错误而不是警告。

要解决此问题，你应该迁移到 `heroku/builder:*` 构建器镜像。作为临时解决方法，你也可以设置一个环境变量来跳过错误。

<a id="migrating-to-herokubuilder"></a>

### 迁移到 `heroku/builder:*`

在迁移之前，你应该阅读每个[规范发布](https://github.com/buildpacks/spec/releases)的发布说明，以确定潜在的破坏性更改。在这种情况下，相关的 buildpack API 版本是 0.6 和 0.7。这些破坏性更改与 buildpack 维护者尤其相关。

有关更改的更多信息，你还可以对比[规范本身](https://github.com/buildpacks/spec/compare/buildpack/v0.5...buildpack/v0.7#files_bucket)。

<a id="skipping-errors"></a>

### 跳过错误

作为临时解决方法，你可以通过设置并转发 `ALLOW_EOL_SHIMMED_BUILDER` 环境变量来跳过错误：

```yaml
  variables:
    ALLOW_EOL_SHIMMED_BUILDER: "1"
    AUTO_DEVOPS_BUILD_IMAGE_FORWARDED_CI_VARIABLES: ALLOW_EOL_SHIMMED_BUILDER
```

<a id="pipeline-that-extends-auto-devops-with-only--except-fails"></a>

## 使用 only / except 扩展 Auto DevOps 的流水线失败

如果你的流水线失败并显示以下消息：

```plaintext
Unable to run pipeline

  jobs:test config key may not be used with `rules`: only
```

当所包含作业的 rules 配置已被 `only` 或 `except` 语法覆盖时，会出现此错误。要修复此问题，你必须将 `only/except` 语法转换为 rules。

<a id="failure-to-create-a-kubernetes-namespace"></a>

## 无法创建 Kubernetes 命名空间

如果极狐GitLab 无法为你的项目创建 Kubernetes 命名空间和服务账户，则 Auto Deploy 会失败。有关调试此问题的帮助，请参阅[部署作业失败故障排查](../../user/project/clusters/deploy_to_cluster.md#troubleshooting)。

<a id="auto-devops-is-automatically-disabled-for-a-project"></a>

## 项目自动禁用 Auto DevOps

如果 Auto DevOps 在项目中自动被禁用，可能是由于以下原因：

- 未在[项目](_index.md#per-project)本身中显式启用 Auto DevOps 设置。它仅在其父[群组](_index.md#per-group)或[实例](../../administration/settings/continuous_integration.md#configure-auto-devops-for-all-projects)中启用。
- 该项目没有任何成功的 Auto DevOps 流水线历史记录。
- Auto DevOps 流水线失败。

要解决此问题：

- 在项目中启用 Auto DevOps 设置。
- 修复导致流水线中断的错误，以便流水线重新运行。

<a id="error-unable-to-recognize--no-matches-for-kind-deployment-in-version-extensionsv1beta1"></a>

## 错误：`unable to recognize "": no matches for kind "Deployment" in version "extensions/v1beta1"`

将你的 Kubernetes 集群升级到 [v1.16+](stages.md#kubernetes-116) 后，使用 Auto DevOps 部署时可能会遇到此消息：

```plaintext
UPGRADE FAILED
Error: failed decoding reader into objects: unable to recognize "": no matches for kind "Deployment" in version "extensions/v1beta1"
```

如果环境命名空间上的当前部署使用的是 Kubernetes v1.16+ 中不存在的已弃用/已删除 API，则可能会发生这种情况。

要恢复这些过时的资源，你必须通过将旧版 API 映射到新版 API 来转换当前的部署。

<a id="error-not-a-valid-chart-repository-or-cannot-be-reached"></a>

## `Error: not a valid chart repository or cannot be reached`

根据[官方 CNCF 博客文章的公告](https://www.cncf.io/blog/2020/10/07/important-reminder-for-all-helm-users-stable-incubator-repos-are-deprecated-and-all-images-are-changing-location/)，稳定的 Helm 图表仓库已于 2020 年 11 月 13 日弃用并移除。在此日期之后，你可能会遇到此错误：

```plaintext
Error: error initializing: Looks like "https://kubernetes-charts.storage.googleapis.com"
is not a valid chart repository or cannot be reached
```

一些极狐GitLab 功能曾依赖于 stable 图表。为了减轻影响，这些依赖项使用了新的官方仓库或[由极狐GitLab 维护的 Helm Stable Archive 仓库](https://gitlab.com/gitlab-org/cluster-integration/helm-stable-archive)。Auto Deploy 包含[一个修复示例](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/merge_requests/127)。

在 Auto Deploy 中，`auto-deploy-image` 的 `v1.0.6+` 版本不再将已弃用的 stable 仓库添加到 `helm` 命令中。如果你使用自定义图表并且它依赖于已弃用的 stable 仓库，请像此示例一样指定一个旧版本的 `auto-deploy-image`：

```yaml
include:
  - template: Auto-DevOps.gitlab-ci.yml

.auto-deploy:
  image: "registry.gitlab.com/gitlab-org/cluster-integration/auto-deploy-image:v1.0.5"
```

请记住，当 stable 仓库被移除后，这种方法将不再有效，因此你最终必须修复你的自定义图表。

要修复你的自定义图表：

1. 在你的图表目录中，将 `requirements.yaml` 文件中的 `repository` 值从：

   ```yaml
   repository: "https://kubernetes-charts.storage.googleapis.com/"
   ```

   更改为：

   ```yaml
   repository: "https://charts.helm.sh/stable"
   ```

1. 在你的图表目录中，使用与 Auto DevOps 相同的主 Helm 版本运行 `helm dep update .`。
1. 提交 `requirements.yaml` 文件的更改。
1. 如果你之前有 `requirements.lock` 文件，请提交对该文件的更改。如果你之前图表中没有 `requirements.lock` 文件，则无需提交新文件。此文件是可选的，但如果存在，它会用于验证已下载依赖项的完整性。

你可以在[议题 #263778，“将 PostgreSQL 从 stable Helm 仓库迁移”](https://gitlab.com/gitlab-org/gitlab/-/issues/263778)中找到更多信息。

<a id="error-release--failed-timed-out-waiting-for-the-condition"></a>

## `Error: release .... failed: timed out waiting for the condition`

初次使用 Auto DevOps 时，你在首次部署应用程序时可能会遇到此错误：

```plaintext
INSTALL FAILED
PURGING CHART
Error: release staging failed: timed out waiting for the condition
```

这很可能是由于在部署过程中尝试的存活探针（或就绪探针）检查失败造成的。默认情况下，这些探针会针对已部署应用程序在 5000 端口上的根页面运行。如果你的应用程序未配置为在根页面提供任何服务，或配置为在 5000 *之外*的特定端口上运行，则此检查将失败。

如果失败，你应该在相关 Kubernetes 命名空间的事件中看到这些失败。这些事件类似于以下示例：

```plaintext
LAST SEEN   TYPE      REASON                   OBJECT                                            MESSAGE
3m20s       Warning   Unhealthy                pod/staging-85db88dcb6-rxd6g                      Readiness probe failed: Get http://10.192.0.6:5000/: dial tcp 10.192.0.6:5000: connect: connection refused
3m32s       Warning   Unhealthy                pod/staging-85db88dcb6-rxd6g                      Liveness probe failed: Get http://10.192.0.6:5000/: dial tcp 10.192.0.6:5000: connect: connection refused
```

要更改用于存活探针检查的端口，请向 Auto DevOps 使用的 Helm 图表[传递自定义值](customize.md#customize-helm-chart-values)：

1. 在你的仓库根目录中创建一个目录和文件，命名为 `.gitlab/auto-deploy-values.yaml`。
1. 使用以下内容填充该文件，将端口值替换为你的应用程序实际配置使用的端口号：

   ```yaml
   service:
     internalPort: <port_value>
     externalPort: <port_value>
   ```

1. 提交你的更改。

提交更改后，后续探针将使用新定义的端口。也可以通过相同的方式覆盖 `livenessProbe.path` 和 `readinessProbe.path` 值（在[默认 `values.yaml`](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/blob/master/assets/auto-deploy-app/values.yaml) 文件中显示）来更改被探测的页面。
```