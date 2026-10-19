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

测试 Web API，帮助发现其他 QA 流程可能遗漏的缺陷和潜在安全问题。除其他安全扫描器和您自己的测试流程外，还应使用 API 安全测试。您可以将 API 安全测试作为 CI/CD 工作流的一部分运行，[按需运行](../dast/on-demand_scan.md)，或两者兼用。

> [!warning]
> 请勿对生产服务器运行 API 安全测试。它不仅能够执行 API 可以执行的任何功能，
> 还可能触发 API 中的缺陷。这包括修改和删除数据等操作。请仅对测试服务器运行 API 安全测试。

<a id="getting-started"></a>

## 开始使用

通过编辑 CI/CD 配置开始使用 API 安全测试。

先决条件：

- 您有一个使用以下受支持 API 类型之一的 Web API：
  - REST API
  - SOAP
  - GraphQL
  - 表单正文、JSON 或 XML
- 您有以下格式之一的 API 规范：
  - [OpenAPI v2 或 v3 规范](configuration/enabling_the_analyzer.md#openapi-specification)
  - [GraphQL Schema](configuration/enabling_the_analyzer.md#graphql-schema)
  - [HTTP Archive (HAR)](configuration/enabling_the_analyzer.md#http-archive-har)
  - [Postman Collection v2.0 或 v2.1](configuration/enabling_the_analyzer.md#postman-collection)

  每次扫描仅支持一个规范。要扫描多个规范，请使用多次扫描。
- 您有一个可用的[极狐GitLab Runner](../../../ci/runners/_index.md)，并在 Linux/amd64 上使用
  [`docker` 执行器](https://gitlab.cn/docs/runner/executors/docker/)。
- 您有一个已部署的目标应用程序。有关更多详细信息，请参阅[部署选项](#application-deployment-options)。
- 在 CI/CD 流水线定义中，`dast` 阶段已添加到 `deploy` 阶段之后。例如：

  ```yaml
  stages:
    - build
    - test
    - deploy
    - dast
  ```

要启用 API 安全测试，您必须根据环境的独特需求修改极狐GitLab CI/CD 配置 YAML。您可以使用以下方式指定要扫描的 API：

- [OpenAPI v2 或 v3 规范](configuration/enabling_the_analyzer.md#openapi-specification)
- [GraphQL Schema](configuration/enabling_the_analyzer.md#graphql-schema)
- [HTTP Archive (HAR)](configuration/enabling_the_analyzer.md#http-archive-har)
- [Postman Collection v2.0 或 v2.1](configuration/enabling_the_analyzer.md#postman-collection)

<a id="understanding-the-results"></a>

## 了解结果

要查看安全扫描的输出：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择该流水线。
1. 选择**安全**选项卡。
1. 选择某个漏洞以查看其详细信息，包括：
   - 状态：指示该漏洞是否已排查或解决。
   - 描述：说明漏洞的成因、潜在影响以及建议的修复步骤。
   - 严重性：根据影响分为六个级别。
     [详细了解严重性级别](../vulnerabilities/severities.md)。
   - 扫描器：标识检测到该漏洞的分析器。
   - 方法：确定存在漏洞的服务器交互类型。
   - URL：显示漏洞的位置。
   - 证据：描述用于证明给定漏洞存在的测试用例。
   - 标识符：用于对漏洞进行分类的引用列表，例如 CWE 标识符。

您还可以下载安全扫描结果：

- 在该流水线的**安全**选项卡中，选择**下载结果**。

有关更多详细信息，请参阅[流水线安全报告](../detect/security_scanning_results.md)。

> [!note]
> 发现项在功能分支上生成。当它们合并到默认分支后，就会成为漏洞。在评估您的安全状况时，这一区别很重要。

<a id="optimization"></a>

## 优化

要充分利用 API 安全测试，请遵循以下建议：

- 将 Runner 配置为使用 [always pull 策略](https://gitlab.cn/docs/runner/executors/docker/#set-the-always-pull-policy)，以运行最新版本的分析器。
- 默认情况下，API 安全测试会下载流水线中先前作业定义的所有产物。
  如果您的 DAST 作业不依赖 `environment_url.txt` 来定义被测 URL 或先前作业中创建的任何其他
  文件，则不应下载产物。要避免下载产物，
  请扩展分析器 CI/CD 作业以指定无依赖项。例如，对于 API 安全
  测试分析器，请将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

  ```yaml
  api_security:
    dependencies: []
  ```

要为您的特定应用程序或环境配置 API 安全测试，请参阅完整的[配置选项](configuration/_index.md)列表。

<a id="roll-out"></a>

## 推广

在 CI/CD 流水线中运行时，API 安全测试扫描默认在 `dast` 阶段运行。为确保 API 安全测试扫描检查最新代码，请确保您的 CI/CD 流水线在 `dast` 阶段之前的某个阶段将更改部署到测试环境。

如果您的流水线配置为在每次运行时部署到同一 Web 服务器，则在一个流水线仍在运行时运行另一个流水线可能会导致竞态条件，其中一个流水线会覆盖另一个的代码。在 API 安全测试扫描期间，应排除对被测 API 的更改。对 API 的唯一更改应来自 API 安全测试扫描器。在扫描期间对 API 所做的更改（例如，由用户、计划任务、数据库更改、代码更改、其他流水线或其他扫描器所做的更改）可能会导致结果不准确。

<a id="example-api-security-testing-scanning-configurations"></a>

### API 安全测试扫描配置示例

以下项目演示了 API 安全测试扫描：

- [OpenAPI v3 规范示例项目](https://gitlab.com/gitlab-org/security-products/demos/api-dast/openapi-v3-example)
- [OpenAPI v2 规范示例项目](https://gitlab.com/gitlab-org/security-products/demos/api-dast/openapi-example)
- [HTTP Archive (HAR) 示例项目](https://gitlab.com/gitlab-org/security-products/demos/api-dast/har-example)
- [Postman Collection 示例项目](https://gitlab.com/gitlab-org/security-products/demos/api-dast/postman-example)
- [GraphQL 示例项目](https://gitlab.com/gitlab-org/security-products/demos/api-dast/graphql-example)
- [SOAP 示例项目](https://gitlab.com/gitlab-org/security-products/demos/api-dast/soap-example)
- [使用 Selenium 的认证令牌](https://gitlab.com/gitlab-org/security-products/demos/api-dast/auth-token-selenium)

<a id="application-deployment-options"></a>

### 应用程序部署选项

API 安全测试需要有一个已部署的应用程序可供扫描。

根据目标应用程序的复杂程度，部署和配置 API 安全测试模板有几种选项。

<a id="review-apps"></a>

#### 审查应用

审查应用是部署 DAST 目标应用程序最复杂的方法。为协助这一过程，
极狐GitLab 使用 Google Kubernetes Engine (GKE) 创建了一个审查应用部署示例。该示例可在
[Review Apps - GKE](https://gitlab.com/gitlab-org/security-products/demos/dast/review-app-gke) 项目中找到，此外还有为 DAST 配置审查应用的详细说明，
见 [README.md](https://gitlab.com/gitlab-org/security-products/demos/dast/review-app-gke/-/blob/master/README.md)。

<a id="docker-services"></a>

#### Docker 服务

如果您的应用程序使用 Docker 容器，则还有另一种使用 DAST 进行部署和扫描的选项。在您的 Docker 构建作业完成并将镜像添加到容器镜像仓库后，您可以将该镜像用作[服务](../../../ci/services/_index.md)。

通过在 `.gitlab-ci.yml`中使用服务定义，您可以使用 DAST 分析器扫描服务。

在向作业添加 `services` 部分时，`alias` 用于定义可用于访问该服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用程序的 URL 使用 `yourapp` 作为主机名（`https://yourapp/`）。

```yaml
stages:
  - build
  - dast

include:
  - template: API-Security.gitlab-ci.yml

# Deploys the container to the GitLab container registry
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
  services: # use services to link your app container to the dast job
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  APISEC_TARGET_URL: https://yourapp
```

大多数应用程序依赖多个服务，例如数据库或缓存服务。默认情况下，services 字段中定义的服务无法相互通信。要允许服务之间通信，请启用 `FF_NETWORK_PER_BUILD` [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # enable network per build so all services can communicate on the same network

services: # use services to link the container to the dast job
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```

<a id="get-support-or-request-an-improvement"></a>

## 获取支持或请求改进

要获取针对您特定问题的支持，请使用[获取帮助渠道](https://gitlab.cn/support)。

[GitLab 在 GitLab.com 上的议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/issues)是提交有关 API 安全测试的缺陷和功能建议的合适场所。在提交有关 API 安全测试的新议题时，请使用 `~"Category:API Security"` 标记，以确保由合适的人员快速审阅。

在提交您自己的条目之前，请[搜索议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/issues)查找类似条目。很可能其他人也有相同的议题或功能建议。用表情回应表示您的支持，或加入讨论。

当遇到行为不符合预期的情况时，请考虑提供上下文信息：

- 如果使用极狐GitLab 私有化部署实例，请提供极狐GitLab 版本。
- `.gitlab-ci.yml` 作业定义。
- 完整的作业控制台输出。
- 作为作业产物提供的扫描器日志文件，名称为 `gl-api-security-scanner.log`。

> [!warning]
> **清理附加到支持议题的数据**。移除敏感信息，包括：凭据、密码、令牌、密钥和机密。

<a id="glossary"></a>

## 术语表

- 断言（Assert）：断言是检查用于触发漏洞的检测模块。许多断言都有
  配置。一个检查可以使用多个断言。例如，日志分析、响应分析
  和状态码是检查常用的断言。具有多个断言的检查
  允许开启和关闭这些断言。
- 检查（Check）：执行特定类型的测试，或针对某种类型的漏洞执行检查。例如，
  SQL 注入检查会对 SQL 注入漏洞执行 DAST 测试。API 安全测试扫描器由多个检查组成。检查可以在测试配置中开启和关闭。
- 测试配置（Profile）：一个配置文件包含一个或多个测试配置，即子配置。您可能
  有一个用于功能分支的测试配置，以及另一个用于主分支的额外测试配置。
