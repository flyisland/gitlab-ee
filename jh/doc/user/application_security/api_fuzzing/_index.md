---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Web API 模糊测试
description: 测试、安全、漏洞、自动化和错误。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Web API 模糊测试会向 API 操作参数传入意外值，以在后端引发意外行为和错误。使用模糊测试可以发现其他 QA 流程可能遗漏的缺陷和潜在漏洞。

您应该在 [极狐GitLab Secure](../_index.md)中的其他安全扫描器以及您自己的测试流程之外，额外使用模糊测试。如果您使用 [极狐GitLab CI/CD](../../../ci/_index.md)，可以将模糊测试作为 CI/CD 工作流的一部分运行。

<a id="getting-started"></a>

## 开始使用

通过编辑 CI/CD 配置开始使用 API 模糊测试。

先决条件：

- 使用以下受支持 API 类型之一的 Web API：
  - REST API
  - SOAP
  - GraphQL
  - 表单正文、JSON 或 XML
- 采用以下格式之一的 API 规范：
  - OpenAPI v2 或 v3 规范
  - GraphQL Schema
  - HTTP Archive (HAR)
  - Postman Collection v2.0 或 v2.1
- 在 Linux/amd64 上具有 `docker` 执行器的可用极狐GitLab Runner。
- 已部署的目标应用程序。
- 在 `deploy` 阶段之后，将 `fuzz` 阶段添加到您的 CI/CD 流水线定义中：

  ```yaml
  stages:
    - build
    - test
    - deploy
    - fuzz
  ```

要启用 API 模糊测试：

- 使用 [Web API 模糊测试配置表单](configuration/enabling_the_analyzer.md#web-api-fuzzing-configuration-form)。

  该表单允许您为最常见的 API 模糊测试选项选择值，并生成一个 YAML 片段，您可以将其粘贴到您的极狐GitLab CI/CD 配置中。

<a id="understanding-the-results"></a>

## 了解结果

要查看安全扫描的输出：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线**。
1. 选择该流水线。
1. 选择 **安全** 标签页。
1. 选择一个漏洞以查看其详细信息，包括：
   - 状态：指示该漏洞是否已被分类或解决。
   - 描述：说明漏洞的原因、潜在影响以及建议的修复步骤。
   - 严重性：根据影响分为六个级别。
     更多信息，请参见[严重性级别](../vulnerabilities/severities.md)。
   - 扫描器：标识检测到该漏洞的分析器。
   - 方法：确定易受攻击的服务器交互类型。
   - URL：显示漏洞的位置。
   - 证据：描述用于证明给定漏洞存在的测试用例
   - 标识符：用于对漏洞进行分类的引用列表，例如 CWE 标识符。

您还可以下载安全扫描结果：

- 在该流水线的 **安全** 标签页中，选择 **下载结果**。

更多详情，请参见[流水线安全报告](../detect/security_scanning_results.md)。

> [!note]
> 发现项在功能分支上生成。当它们合并到默认分支后，就会成为漏洞。在评估您的安全态势时，这一区别很重要。

<a id="optimization"></a>

## 优化

要充分利用 API 模糊测试，请遵循以下建议：

- 要运行最新版本的分析器，请将 runner 配置为使用 `pull_policy: always`。
- 默认情况下，API 模糊测试会下载流水线中先前作业定义的所有产物。如果您的
  API 模糊测试作业不依赖 `environment_url.txt` 来定义被测 URL 或先前作业中创建的任何其他
  文件，则不应下载产物。

  要避免下载产物，请扩展分析器 CI/CD 作业以指定无依赖项。
  例如，对于 API 模糊测试分析器，将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

  ```yaml
  apifuzzer_fuzz:
    dependencies: []
  ```

<a id="application-deployment-options"></a>

### 应用程序部署选项

API 模糊测试需要有一个已部署的应用程序可供扫描。

根据目标应用程序的复杂程度，有几种部署和配置 API 模糊测试模板的选项。

<a id="review-apps"></a>

#### Review apps

Review apps 是部署 API 模糊测试目标应用程序最复杂的方法。为协助这一过程，
GitLab 使用 Google Kubernetes Engine (GKE) 创建了一个 review app 部署。此示例可在
[Review apps - GKE](https://gitlab.com/gitlab-org/security-products/demos/dast/review-app-gke) 项目中找到，此外还有在 DAST 中配置 review apps 的详细
说明。

<a id="docker-services"></a>

#### Docker 服务

如果您的应用程序使用 Docker 容器，您还有另一种使用 API 模糊测试进行部署和扫描的选项。在您的 Docker 构建作业完成并将镜像添加到容器镜像仓库后，您可以将该镜像用作服务。

通过在 `.gitlab-ci.yml`中使用服务定义，您可以使用 DAST 分析器扫描服务。

在向作业添加 `services` 部分时，`alias` 用于定义可用于访问该服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用程序的 URL 使用 `yourapp` 作为主机名：`https://yourapp/`。

```yaml
stages:
  - build
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

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

apifuzzer_fuzz:
  services: # use services to link your app container to the dast job
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  FUZZAPI_TARGET_URL: https://yourapp
```

大多数应用程序依赖多个服务，例如数据库或缓存服务。默认情况下，在 services 字段中定义的服务无法相互通信。要允许服务之间通信，请启用 `FF_NETWORK_PER_BUILD` 功能标志。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # enable network per build so all services can communicate on the same network

services: # use services to link the container to the dast job
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```

<a id="roll-out"></a>

## 推出

Web API 模糊测试在 CI/CD 流水线的 `fuzz` 阶段中运行。为确保 API 模糊测试扫描最新代码，您的 CI/CD 流水线应在 `fuzz` 阶段之前的某个阶段将更改部署到测试环境。

如果您的流水线配置为在每次运行时部署到同一 Web 服务器，则在一个流水线仍在运行时运行另一个流水线可能会导致竞态条件，其中一个流水线会覆盖另一个的代码。在模糊测试扫描期间，应排除对要扫描的 API 的更改。对 API 的唯一更改应来自模糊测试扫描器。在扫描期间对 API 所做的任何更改（例如，由用户、计划任务、数据库更改、代码更改、其他流水线或其他扫描器所做）都可能导致结果不准确。

您可以使用以下方法运行 Web API 模糊测试扫描：

- OpenAPI 规范（版本 2 和 3）
- GraphQL schema
- HTTP archive (HAR)
- Postman collection（版本 2.0 和 2.1）

<a id="example-api-fuzzing-projects"></a>

### API 模糊测试项目示例

- [OpenAPI v2 规范项目示例](https://gitlab.com/gitlab-org/security-products/demos/api-fuzzing-example/-/tree/openapi)
- [HTTP Archive (HAR) 项目示例](https://gitlab.com/gitlab-org/security-products/demos/api-fuzzing-example/-/tree/har)
- [Postman Collection 项目示例](https://gitlab.com/gitlab-org/security-products/demos/api-fuzzing/postman-api-fuzzing-example)
- [GraphQL 项目示例](https://gitlab.com/gitlab-org/security-products/demos/api-fuzzing/graphql-api-fuzzing-example)
- [SOAP 项目示例](https://gitlab.com/gitlab-org/security-products/demos/api-fuzzing/soap-api-fuzzing-example)
- [使用 Selenium 的身份验证令牌](https://gitlab.com/gitlab-org/security-products/demos/api-fuzzing/auth-token-selenium)

<a id="get-support-or-request-an-improvement"></a>

## 获取支持或请求改进

要获取针对您特定问题的支持，请使用[获取帮助渠道](https://about.gitlab.com/get-help/)。

[GitLab.com 上的 GitLab 议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/issues)是提交有关 API 安全和 API 模糊测试的缺陷和功能建议的合适场所。在提交有关 API 模糊测试的新议题时，请使用 `~"Category:API Security"` 标记，以确保它被合适的人员快速审阅。

在提交您自己的议题之前，请先在议题跟踪器中搜索类似条目，很可能其他人已经遇到过相同的问题或功能建议。用表情回应表示您的支持，或加入讨论。

当遇到行为不符合预期的情况时，请考虑提供上下文信息：

- 如果使用极狐GitLab 私有化部署实例，请提供极狐GitLab 版本。
- `.gitlab-ci.yml` 作业定义。
- 完整的作业控制台输出。
- 作为作业产物提供的扫描器日志文件，名称为 `gl-api-security-scanner.log`。

> [!warning]
> 提交议题时请勿包含敏感信息。移除密码、令牌和密钥等凭据。

<a id="glossary"></a>

## 术语表

- Assert：断言是检查用于触发故障的检测模块。许多断言都有
  配置。一个检查可以使用多个断言。例如，日志分析、响应分析
  和状态码是检查常一起使用的常见断言。具有多个断言的检查
  允许将它们打开和关闭。
- Check：执行特定类型的测试，或对某种类型的漏洞执行检查。例如，
  JSON Fuzzing Check 对 JSON 负载执行模糊测试。API 模糊测试器
  由多个检查组成。检查可以在配置文件中打开和关闭。
- Fault：在模糊测试期间，由断言识别出的失败称为故障。会对故障
  进行调查，以确定它们是安全漏洞、非安全问题还是误报。
  在调查之前，故障没有已知的漏洞类型。示例
  漏洞类型包括 SQL 注入和拒绝服务。
- Profile：一个配置文件有一个或多个测试配置文件，或子配置。您可能
  有一个用于功能分支的配置文件，以及另一个对主分支进行额外测试的配置文件。
