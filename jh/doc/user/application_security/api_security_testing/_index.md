---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: API 安全测试分析器
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 中，从“DAST API 分析器” [重命名为“API 安全测试分析器”]。

{{< /history >}}

测试 Web API 以帮助发现其他 QA 流程可能遗漏的漏洞和潜在安全问题。
除了其他安全扫描器和您自己的测试流程外，还可使用 API 安全测试。您可以在 CI/CD 工作流中运行 API 安全测试，也可以 [按需](../dast/on-demand_scan.md) 运行，或者两者兼顾。

> [!warning]
> 不要对生产服务器运行 API 安全测试。它不仅能够执行 API 能执行的任何功能，还可能触发 API 中的漏洞。这包括修改和删除数据等操作。仅在测试服务器上运行 API 安全测试。

<a id="getting-started"></a>

## 入门

通过编辑您的 CI/CD 配置开始使用 API 安全测试。

先决条件：

- 您的 Web API 使用以下受支持的 API 类型之一：
  - REST API
  - SOAP
  - GraphQL
  - 表单体、JSON 或 XML
- 您具有以下格式之一的 API 规范：
  - [OpenAPI v2 或 v3 规范](configuration/enabling_the_analyzer.md#openapi-specification)
  - [GraphQL 模式](configuration/enabling_the_analyzer.md#graphql-schema)
  - [HTTP 存档 (HAR)](configuration/enabling_the_analyzer.md#http-archive-har)
  - [Postman Collection v2.0 或 v2.1](configuration/enabling_the_analyzer.md#postman-collection)

  每个扫描仅支持一种规范。要扫描多种规范，请使用多个扫描。
- 您有一个可用的 [GitLab Runner](../../../ci/runners/_index.md) 在 Linux/amd64 上，并且具有 [`docker` 执行器](https://gitlab.cn/docs/runner/executors/docker/)。
- 您有一个已部署的目标应用程序。更多详情请参阅 [部署选项](#application-deployment-options)。
- `dast` 阶段已添加到您的 CI/CD 流水线定义中，位于 `deploy` 阶段之后。例如：

  ```yaml
  stages:
    - build
    - test
    - deploy
    - dast
  ```

要启用 API 安全测试，您必须根据环境的独特需求修改极狐GitLab CI/CD 配置 YAML。您可以使用以下方式指定要扫描的 API：

- [OpenAPI v2 或 v3 规范](configuration/enabling_the_analyzer.md#openapi-specification)
- [GraphQL 模式](configuration/enabling_the_analyzer.md#graphql-schema)
- [HTTP 存档 (HAR)](configuration/enabling_the_analyzer.md#http-archive-har)
- [Postman Collection v2.0 或 v2.1](configuration/enabling_the_analyzer.md#postman-collection)

<a id="understanding-the-results"></a>

## 了解结果

要查看安全扫描的输出：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择该流水线。
1. 选择 **安全** 选项卡。
1. 选择一个漏洞以查看其详情，包括：
   - 状态：指示漏洞已分流还是已解决。
   - 描述：说明漏洞的原因、潜在影响以及推荐的修复步骤。
   - 严重性：根据影响分为六个级别。
     [了解更多关于严重性级别](../vulnerabilities/severities.md)。
   - 扫描器：标识检测到该漏洞的分析器。
   - 方法：建立有漏洞的服务器交互类型。
   - URL：显示漏洞的位置。
   - 证据：描述证明存在特定漏洞的测试用例。
   - 标识符：用于分类漏洞的参考列表，例如 CWE 标识符。

您还可以下载安全扫描结果：

- 在流水线的 **安全** 选项卡中，选择 **下载结果**。

更多详情，请参阅 [流水线安全报告](../detect/security_scanning_results.md)。

> [!note]
> 在功能分支上生成发现项。当它们合并到默认分支时，就会成为漏洞。在评估您的安全状况时，这一区别很重要。

<a id="optimization"></a>

## 优化

为充分利用 API 安全测试，请遵循以下建议：

- 配置 Runner 使用 [始终拉取策略](https://gitlab.cn/docs/runner/executors/docker/#using-the-always-pull-policy) 以运行分析器的最新版本。
- 默认情况下，API 安全测试会下载流水线中先前作业定义的所有产物。如果您的 DAST 作业不依赖 `environment_url.txt` 来定义被测 URL 或先前作业创建的其他文件，则不应下载产物。为避免下载产物，请扩展分析器的 CI/CD 作业以指定无依赖项。例如，对于 API 安全测试分析器，请将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

  ```yaml
  api_security:
    dependencies: []
  ```

要为您的特定应用程序或环境配置 API 安全测试，请参阅完整的 [配置选项](configuration/_index.md)。

<a id="roll-out"></a>

## 推广

在 CI/CD 流水线中运行时，API 安全测试扫描默认在 `dast` 阶段运行。为确保 API 安全测试扫描检查最新代码，请确保您的 CI/CD 流水线在 `dast` 阶段之前的一个阶段将变更部署到测试环境。

如果您的流水线配置为每次运行都部署到同一个 Web 服务器，那么在另一个流水线仍在运行时再运行一个流水线可能会导致竞争条件，其中一个流水线覆盖另一个流水线的代码。在 API 安全测试扫描期间，要扫描的 API 应排除变更。对 API 的唯一更改应来自 API 安全测试扫描器。在扫描期间对 API 进行的更改（例如，由用户、计划任务、数据库更改、代码更改、其他流水线或其他扫描器引起的更改）可能会导致不准确的结果。

<a id="example-api-security-testing-scanning-configurations"></a>

### API 安全测试扫描配置示例

以下项目演示了 API 安全测试扫描：

- [示例 OpenAPI v3 规范项目](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/openapi-v3-example)
- [示例 OpenAPI v2 规范项目](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/openapi-example)
- [示例 HTTP 存档 (HAR) 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/har-example)
- [示例 Postman Collection 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/postman-example)
- [示例 GraphQL 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/graphql-example)
- [示例 SOAP 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/soap-example)
- [使用 Selenium 的身份验证令牌](https://jihulab.com/gitlab-cn/security-products/demos/api-dast/auth-token-selenium)

<a id="application-deployment-options"></a>

### 应用程序部署选项

API 安全测试需要部署可扫描的应用程序。

根据目标应用程序的复杂性，有几种部署和配置 API 安全测试模板的选项。

<a id="review-apps"></a>

#### 审查应用

审查应用是部署 DAST 目标应用程序最复杂的方法。为了协助这一过程，极狐GitLab 创建了使用 Google Kubernetes Engine (GKE) 的审查应用部署。此示例可在 [审查应用 - GKE](https://jihulab.com/gitlab-cn/security-products/demos/dast/review-app-gke) 项目中找到，并在 [README.md](https://jihulab.com/gitlab-cn/security-products/demos/dast/review-app-gke/-/blob/master/README.md) 中提供了详细的说明，以配置用于 DAST 的审查应用。

<a id="docker-services"></a>

#### Docker 服务

如果您的应用程序使用 Docker 容器，您还可以选择使用 DAST 进行部署和扫描。在 Docker 构建作业完成后，并且您的镜像已添加到容器镜像仓库中，您可以将该镜像用作 [服务](../../../ci/services/_index.md)。

在 `.gitlab-ci.yml` 中使用服务定义，您可以使用 DAST 分析器扫描服务。

在作业中添加 `services` 部分时，`alias` 用于定义可用来访问服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分表示已部署应用程序的 URL 使用 `yourapp` 作为主机名 (`https://yourapp/`)。

```yaml
stages:
  - build
  - dast

include:
  - template: API-Security.gitlab-ci.yml

# 将容器部署到极狐GitLab 容器镜像仓库
deploy:
  services:
  - name: docker:dind
    alias: dind
  image: docker:20.10.16
  stage: build
  script:
    - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
    - docker pull $CI_REGISTRY_IMAGE:latest || true
    - docker build --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --tag $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest

api_security:
  services: # 使用服务将您的应用容器链接到 dast 作业
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  APISEC_TARGET_URL: https://yourapp
```

大多数应用程序依赖于多个服务，例如数据库或缓存服务。默认情况下，在 services 字段中定义的服务无法彼此通信。要允许服务之间的通信，请启用 `FF_NETWORK_PER_BUILD` [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # 启用按构建划分网络，以便所有服务可以在同一网络上通信

services: # 使用服务将容器链接到 dast 作业
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```

<a id="get-support-or-request-an-improvement"></a>

## 获取支持或请求改进

要获得针对您的特定问题的支持，请使用 [获取帮助渠道](https://gitlab.cn/get-help/)。

极狐GitLab.com 上的 [极狐GitLab 议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues) 是报告有关 API 安全测试的漏洞和功能建议的正确地方。
在提交与 API 安全测试相关的新议题时，使用 `~"Category:API Security"` 标签，以确保它被合适的人员快速审核。

在提交自己的议题之前，[搜索议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues) 中是否有类似的条目，很可能其他人已经提出了相同的问题或功能建议。用表情符号回应表示支持，或加入讨论。

当遇到未按预期工作的行为时，请考虑提供上下文信息：

- 如果使用极狐GitLab 私有化部署实例，请提供极狐GitLab 版本。
- `.gitlab-ci.yml` 作业定义。
- 完整的作业控制台输出。
- 作为作业产物提供的扫描器日志文件，名为 `gl-api-security-scanner.log`。

> [!warning]
> **清理支持议题中附带的数据**。删除敏感信息，包括：凭据、密码、令牌、密钥和密钥。

<a id="glossary"></a>

## 术语表

- 断言：断言是检查用来触发漏洞的检测模块。许多断言都有配置。一个检查可以使用多个断言。例如，日志分析、响应分析和状态码是检查经常一起使用的常见断言。具有多个断言的检查允许将其启用或禁用。
- 检查：执行特定类型的测试，或者对某种类型的漏洞进行检查。例如，SQL 注入检查对 SQL 注入漏洞执行 DAST 测试。API 安全测试扫描器由多个检查组成。检查可以在一个配置文件中启用或禁用。
- 配置文件：配置文件具有一个或多个测试配置文件，或子配置。您可以为功能分支设置一个配置文件，为主分支设置另一个带有额外测试的配置文件。