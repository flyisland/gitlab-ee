---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Auto DevOps 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本页文档中的信息介绍了使用 Auto DevOps 时的常见错误，以及可用的变通方法。

<a id="trace-helm-commands"></a>

## 跟踪 Helm 命令

将 CI/CD 变量 `TRACE` 设置为任意值，即可让 Helm 命令输出详细日志。您可以使用这些输出来诊断 Auto DevOps 部署问题。

您可以通过更改高级 Auto DevOps 配置变量来解决某些 Auto DevOps 部署问题。详细了解[自定义 Auto DevOps CI/CD 变量](cicd_variables.md)。

<a id="unable-to-select-a-buildpack"></a>

## 无法选择 buildpack

Auto Test 可能无法检测您的语言或框架，并出现以下错误：

```plaintext
Step 5/11 : RUN /bin/herokuish buildpack build
 ---> Running in eb468cd46085
    -----> Unable to select a buildpack
The command '/bin/sh -c /bin/herokuish buildpack build' returned a non-zero code: 1
```

可能的原因如下：

- 您的应用可能缺少 buildpack 所需的关键文件。
  Ruby 应用需要 `Gemfile` 才能被正确检测，
  尽管编写 Ruby 应用时可以不使用 `Gemfile`。
- 您的应用可能没有对应的 buildpack。请尝试指定
  [自定义 buildpack](customize.md#custom-buildpacks)。

<a id="builder-sunset-error"></a>

## Builder 停用错误

由于此 [Heroku 更新](https://github.com/heroku/cnb-builder-images/pull/478)，旧版 shimmed `heroku/buildpacks:20` 和 `heroku/builder-classic:22` 镜像现在会生成错误，而不是警告。

要解决此问题，您应迁移到 `heroku/builder:*` builder 镜像。作为临时变通方法，您也可以设置环境变量来跳过错误。

<a id="migrating-to-herokubuilder"></a>

### 迁移到 `heroku/builder:*`

在迁移之前，您应阅读每个 [spec 版本](https://github.com/buildpacks/spec/releases)的发布说明，以确定可能的破坏性变更。
在本例中，相关的 buildpack API 版本为 0.6 和 0.7。
这些破坏性变更对 buildpack 维护者尤为重要。

有关这些变更的更多信息，您还可以对比 [spec 本身](https://github.com/buildpacks/spec/compare/buildpack/v0.5...buildpack/v0.7#files_bucket)。

<a id="skipping-errors"></a>

### 跳过错误

作为临时变通方法，您可以通过设置并转发 `ALLOW_EOL_SHIMMED_BUILDER` 环境变量来跳过错误：

```yaml
  variables:
    ALLOW_EOL_SHIMMED_BUILDER: "1"
    AUTO_DEVOPS_BUILD_IMAGE_FORWARDED_CI_VARIABLES: ALLOW_EOL_SHIMMED_BUILDER
```

<a id="pipeline-that-extends-auto-devops-with-only--except-fails"></a>

## 仅使用 only / except 扩展 Auto DevOps 的流水线失败

如果您的流水线失败并显示以下消息：

```plaintext
Unable to run pipeline

  jobs:test config key may not be used with `rules`: only
```

当所包含作业的规则配置被 `only` 或 `except` 语法覆盖时，会出现此错误。要解决此问题，您必须将 `only/except` 语法转换为 rules。

<a id="failure-to-create-a-kubernetes-namespace"></a>

## 无法创建 Kubernetes 命名空间

如果极狐GitLab 无法为您的项目创建 Kubernetes 命名空间和服务账号，Auto Deploy 会失败。如需帮助调试此问题，请参阅[故障排除失败的部署作业](../../user/project/clusters/deploy_to_cluster.md#troubleshooting)。

<a id="auto-devops-is-automatically-disabled-for-a-project"></a>

## 项目的 Auto DevOps 被自动禁用

如果某个项目的 Auto DevOps 被自动禁用，可能是由于以下原因：

- 未在[项目](_index.md#per-project)本身中显式启用 Auto DevOps 设置。它仅在父[群组](_index.md#per-group)或其[实例](../../administration/settings/continuous_integration.md#configure-auto-devops-for-all-projects)中启用。
- 该项目没有成功运行 Auto DevOps 流水线的历史记录。
- 某条 Auto DevOps 流水线失败了。

要解决此问题：

- 在项目中启用 Auto DevOps 设置。
- 修复导致流水线中断的错误，以便流水线重新运行。

<a id="error-unable-to-recognize--no-matches-for-kind-deployment-in-version-extensionsv1beta1"></a>

## 错误：`unable to recognize "": no matches for kind "Deployment" in version "extensions/v1beta1"`

将 Kubernetes 集群升级到 [v1.16+](stages.md#kubernetes-116) 后，
使用 Auto DevOps 部署时可能会遇到以下消息：

```plaintext
UPGRADE FAILED
Error: failed decoding reader into objects: unable to recognize "": no matches for kind "Deployment" in version "extensions/v1beta1"
```

如果环境命名空间上当前的部署是使用 Kubernetes v1.16+ 中已不存在的已弃用/已移除 API 部署的，则可能出现此问题。

要恢复此类过时资源，您必须通过将旧版 API 映射到较新 API 来转换当前部署。

<a id="error-not-a-valid-chart-repository-or-cannot-be-reached"></a>

## `Error: not a valid chart repository or cannot be reached`

正如[官方 CNCF 博客文章所宣布](https://www.cncf.io/blog/2020/10/07/important-reminder-for-all-helm-users-stable-incubator-repos-are-deprecated-and-all-images-are-changing-location/)，
stable Helm chart 仓库已于 2020 年 11 月 13 日弃用并移除。
在该日期之后，您可能会遇到此错误：

```plaintext
Error: error initializing: Looks like "https://kubernetes-charts.storage.googleapis.com"
is not a valid chart repository or cannot be reached
```

部分极狐GitLab 功能曾依赖 stable chart。为减轻影响，这些依赖项
改用新的官方仓库或[由 GitLab 维护的 Helm Stable Archive 仓库](https://gitlab.com/gitlab-org/cluster-integration/helm-stable-archive)。
Auto Deploy 包含[一个修复示例](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/merge_requests/127)。

在 Auto Deploy 中，`auto-deploy-image`的 `v1.0.6+` 不再将已弃用的 stable 仓库添加到
`helm` 命令中。如果您使用自定义 chart 且它依赖已弃用的 stable 仓库，请指定较旧版本的 `auto-deploy-image`，如下例所示：

```yaml
include:
  - template: Auto-DevOps.gitlab-ci.yml

.auto-deploy:
  image: "registry.gitlab.com/gitlab-org/cluster-integration/auto-deploy-image:v1.0.5"
```

请记住，当 stable 仓库被移除后，此方法将不再有效，因此您最终必须修复您的自定义 chart。

要修复您的自定义 chart：

1. 在您的 chart 目录中，将 `requirements.yaml` 文件中的 `repository` 值从：

   ```yaml
   repository: "https://kubernetes-charts.storage.googleapis.com/"
   ```

   改为：

   ```yaml
   repository: "https://charts.helm.sh/stable"
   ```

1. 在您的 chart 目录中，使用与 Auto DevOps 相同的 Helm 主版本运行 `helm dep update .`。
1. 提交 `requirements.yaml` 文件的更改。
1. 如果您之前有 `requirements.lock` 文件，请提交对该文件的更改。
   如果您的 chart 中之前没有 `requirements.lock` 文件，
   则无需提交新文件。此文件是可选的，但存在时，
   会用于验证所下载依赖项的完整性。

您可以在
[议题 #263778，“Migrate PostgreSQL from stable Helm repository”](https://gitlab.com/gitlab-org/gitlab/-/issues/263778)中找到更多信息。

<a id="error-release--failed-timed-out-waiting-for-the-condition"></a>

## `Error: release .... failed: timed out waiting for the condition`

在开始使用 Auto DevOps 时，您可能会在首次部署应用时遇到此错误：

```plaintext
INSTALL FAILED
PURGING CHART
Error: release staging failed: timed out waiting for the condition
```

这很可能是由于部署过程中尝试的存活（或就绪）探针失败所致。默认情况下，这些探针会针对所部署应用的根页面在端口 5000 上运行。如果您的应用未配置为在根页面提供任何内容，或配置为在 5000 以外的特定端口上运行，则此检查会失败。

如果检查失败，您应在相关 Kubernetes 命名空间的事件中看到这些失败。这些事件如下例所示：

```plaintext
LAST SEEN   TYPE      REASON                   OBJECT                                            MESSAGE
3m20s       Warning   Unhealthy                pod/staging-85db88dcb6-rxd6g                      Readiness probe failed: Get http://10.192.0.6:5000/: dial tcp 10.192.0.6:5000: connect: connection refused
3m32s       Warning   Unhealthy                pod/staging-85db88dcb6-rxd6g                      Liveness probe failed: Get http://10.192.0.6:5000/: dial tcp 10.192.0.6:5000: connect: connection refused
```

要更改存活检查使用的端口，请向
Auto DevOps 使用的 [Helm chart 传递自定义值](customize.md#customize-helm-chart-values)：

1. 在代码仓库根目录下创建一个名为 `.gitlab/auto-deploy-values.yaml`的目录和文件。
1. 用以下内容填充该文件，并将端口值替换为
   您的应用实际配置使用的端口号：

   ```yaml
   service:
     internalPort: <port_value>
     externalPort: <port_value>
   ```

1. 提交您的更改。

提交更改后，后续探针应使用新定义的端口。所探测的页面也可以通过以相同方式覆盖 `livenessProbe.path` 和 `readinessProbe.path` 值（如[默认 `values.yaml`](https://gitlab.com/gitlab-org/cluster-integration/auto-deploy-image/-/blob/master/assets/auto-deploy-app/values.yaml) 文件中所示）来更改。
