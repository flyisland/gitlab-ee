---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查代码质量问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用代码质量时，您可能会遇到以下问题。

<a id="the-code-cannot-be-found-and-the-pipeline-runs-always-with-default-configuration"></a>

## 找不到代码且流水线始终使用默认配置运行

您可能正在使用具有 Docker-in-Docker 套接字绑定配置的私有化部署 Runner。
您应该按照[使用私有化部署 Runner](code_quality_codeclimate_scanning.md#use-private-runners) 中的文档，配置代码质量检查在您的工作节点上运行。

<a id="changing-the-default-configuration-has-no-effect"></a>

## 更改默认配置无效

一个常见问题是术语 `Code Quality`（极狐GitLab 特定）和 `Code Climate`（极狐GitLab 使用的引擎）非常相似。您必须添加 **`.codeclimate.yml`** 文件来更改默认配置，**而不是** `.codequality.yml` 文件。如果您使用了错误的文件名，则仍会使用[默认的 `.codeclimate.yml`](https://jihulab.com/gitlab-cn/ci-cd/codequality/-/blob/master/codeclimate_defaults/.codeclimate.yml.template)。

<a id="no-code-quality-report-is-displayed-in-a-merge-request"></a>

## 合并请求中未显示代码质量报告

合并请求中可能缺少源分支或目标分支的代码质量报告以进行比较，因此无法显示任何信息。

源分支缺少报告可能是由于：

1. 使用了 [`REPORT_STDOUT` 环境变量](https://jihulab.com/gitlab-cn/ci-cd/codequality#environment-variables)，没有生成报告文件，合并请求中不会显示任何内容。

目标分支缺少报告可能是由于：

- 在您的 `.gitlab-ci.yml` 中新添加了代码质量作业。
- 您的流水线未设置为在目标分支上运行代码质量作业。
- 对默认分支的提交未运行代码质量作业。
- [`artifacts:expire_in`](../yaml/_index.md#artifactsexpire_in) CI/CD 设置可能导致代码质量产物比预期更快过期。

通过使用[合并请求 API](../../api/merge_requests.md#retrieve-a-merge-request) 获取 `base_sha`，并使用[带有 `sha` 属性的流水线 API](../../api/pipelines.md#list-project-pipelines) 检查流水线是否运行，来验证基础提交上是否存在报告。

<a id="no-code-quality-symbol-in-the-changes-view"></a>

## 变更视图中没有代码质量符号

如果[变更视图](code_quality.md#merge-request-changes-view)中没有显示符号，请确保代码质量报告中的 `location.path`：

- 使用相对于包含代码质量违规的文件的相对路径。
- 不以 `./` 为前缀。例如，`path` 应为 `somedir/file1.rb` 而不是 `./somedir/file1.rb`。

<a id="only-a-single-code-quality-report-is-displayed-but-more-are-defined"></a>

## 仅显示单个代码质量报告，但定义了多个

代码质量会自动[合并多个报告](code_quality.md#scan-code-for-quality-violations)。

在极狐GitLab 15.6 及更早版本中，代码质量仅使用最新创建的作业（具有最大作业 ID）的产物。较早作业的代码质量产物将被忽略。

<a id="rubocop-errors"></a>

## RuboCop 错误

在 Ruby 项目上使用代码质量作业时，您可能会遇到运行 RuboCop 的问题。
例如，当使用非常新或非常旧的 Ruby 版本时，可能会出现以下错误：

```plaintext
/usr/local/bundle/gems/rubocop-0.52.1/lib/rubocop/config.rb:510:in `check_target_ruby':
Unknown Ruby version 2.7 found in `.ruby-version`. (RuboCop::ValidationError)
Supported versions: 2.1, 2.2, 2.3, 2.4, 2.5
```

这是由于检查引擎使用的默认 RuboCop 版本未涵盖对所使用的 Ruby 版本的支持。

要使用[支持项目所使用的 Ruby 版本](https://docs.rubocop.org/rubocop/compatibility.html#support-matrix)的自定义 RuboCop 版本，
您可以通过在项目仓库中创建的 [`.codeclimate.yml` 文件覆盖配置](https://docs.codeclimate.com/docs/rubocop#using-rubocops-newer-versions)。

例如，要指定使用 RuboCop **0.67** 版本：

```yaml
version: "2"
plugins:
  rubocop:
    enabled: true
    channel: rubocop-0-67
```

<a id="no-code-quality-appears-on-merge-requests-when-using-custom-tool"></a>

## 使用自定义工具时合并请求上不显示代码质量

如果您的合并请求在使用自定义工具时未显示任何代码质量变更，请确保 JSON 中的*所有*行属性都是 `integer`。

<a id="error-could-not-analyze-code-quality"></a>

## 错误：`Could not analyze code quality`

您可能会遇到以下错误：

```shell
error: (CC::CLI::Analyze::EngineFailure) engine pmd ran for 900 seconds and was killed
Could not analyze code quality for the repository at /code
```

如果您启用了任何 Code Climate 插件，并且代码质量 CI/CD 作业失败并显示此错误消息，则可能是作业运行时间超过了默认的 900 秒超时时间：

要解决此问题，请在您的 `.gitlab-ci.yml` 文件中将 `TIMEOUT_SECONDS` 设置为更高的值。

例如：

```yaml
code_quality:
  variables:
    TIMEOUT_SECONDS: 3600
```

<a id="using-code-quality-with-a-kubernetes-or-openshift-runner"></a>

## 在 Kubernetes 或 OpenShift Runner 上使用代码质量

基于 CodeClimate 的扫描有特殊要求。
您可能需要[为基于 CodeClimate 的扫描配置 Kubernetes 或 OpenShift Runner](code_quality_codeclimate_scanning.md#configure-kubernetes-or-openshift-runners)，扫描才能正常工作。

<a id="error-x509-certificate-signed-by-unknown-authority"></a>

## 错误：`x509: certificate signed by unknown authority`

如果您将 `CODE_QUALITY_IMAGE` 设置为托管在使用不受信任的 TLS 证书（例如自签名证书）的 Docker 注册表中的镜像，您可能会看到以下错误：

```shell
$ docker pull --quiet "$CODE_QUALITY_IMAGE"
Error response from daemon: Get https://gitlab.example.com/v2/: x509: certificate signed by unknown authority
```

要解决此问题，请通过将证书放入 `/etc/docker/certs.d` 目录来配置 Docker 守护进程以[信任证书](https://distribution.github.io/distribution/about/insecure/#use-self-signed-certificates)。

此 Docker 守护进程会在[极狐GitLab 代码质量模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/v13.8.3-ee/lib/gitlab/ci/templates/Jobs/Code-Quality.gitlab-ci.yml#L41)中暴露给后续的代码质量 Docker 容器，并且应该暴露给您希望应用证书配置的任何其他容器。

<a id="docker"></a>

### Docker

如果您可以访问极狐GitLab Runner 配置，请将该目录添加为[卷挂载](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#volumes-in-the-runnersdocker-section)。

将 `gitlab.example.com` 替换为注册表的实际域名。

示例：

```toml
[[runners]]
  ...
  executor = "docker"
  [runners.docker]
    ...
    privileged = true
    volumes = ["/cache", "/etc/gitlab-runner/certs/gitlab.example.com.crt:/etc/docker/certs.d/gitlab.example.com/ca.crt:ro"]
```

<a id="kubernetes"></a>

### Kubernetes

如果您可以访问极狐GitLab Runner 配置和 Kubernetes 集群，
您可以[挂载 ConfigMap](https://gitlab.cn/docs/runner/executors/kubernetes/#configmap-volume)。

将 `gitlab.example.com` 替换为注册表的实际域名。

1. 使用证书创建 ConfigMap：

   ```shell
   kubectl create configmap registry-crt --namespace gitlab-runner --from-file /etc/gitlab-runner/certs/gitlab.example.com.crt
   ```

1. 更新极狐GitLab Runner `config.toml` 以指定 ConfigMap：

   ```toml
   [[runners]]
     ...
     executor = "kubernetes"
     [runners.kubernetes]
       image = "alpine:3.12"
       privileged = true
       [[runners.kubernetes.volumes.config_map]]
         name = "registry-crt"
         mount_path = "/etc/docker/certs.d/gitlab.example.com/ca.crt"
         sub_path = "gitlab.example.com.crt"
   ```

<a id="failed-to-load-code-quality-report"></a>

## 代码质量报告加载失败

当解析产物文件中的数据出现问题时，代码质量报告可能无法加载。
要深入了解错误，您可以使用以下步骤执行 GraphQL 查询：

1. 转到流水线详情页面。
1. 在 URL 后追加 `.json`。
1. 复制流水线的 `iid`。
1. 转到[交互式 GraphQL 探索器](../../api/graphql/_index.md#interactive-graphql-explorer)。
1. 运行以下查询：

   ```graphql
   {
     project(fullPath: "<fullpath-to-your-project>") {
       pipeline(iid: "<iid>") {
         codeQualityReports {
           count
           nodes {
             line
             description
             path
             fingerprint
             severity
           }
           pageInfo {
             hasNextPage
             hasPreviousPage
             startCursor
             endCursor
           }
         }
       }
     }
   }
   ```

<a id="no-report-artifact-is-created"></a>

## 未创建报告产物

在某些 Runner 配置下，代码质量扫描作业可能无法访问您的源代码。
如果发生这种情况，将不会创建 `gl-code-quality-report.json` 产物。

要解决此问题，请执行以下任一操作：

- 使用[推荐的 Docker-in-Docker Runner 配置](../docker/using_docker_build.md#use-docker-in-docker)，该配置使用特权模式而不是 Docker 套接字绑定。

有关更多详细信息，请参阅[更改 Runner 配置](code_quality_codeclimate_scanning.md#change-runner-configuration)。