---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Web API 模糊测试
description: Testing, security, vulnerabilities, automation, and errors.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Web API 模糊测试将非预期值传递给 API 操作参数，从而在后端引发非预期行为和错误。使用模糊测试可以发现其他 QA 流程可能遗漏的缺陷和潜在漏洞。

除了在 [极狐GitLab Secure](../_index.md) 和其他安全扫描器中，你还应同时使用模糊测试以及自己的测试流程。如果你正在使用 [极狐GitLab CI/CD](../../../ci/_index.md)，可以将模糊测试作为 CI/CD 工作流的一部分运行。

<a id="getting-started"></a>

## 入门

通过编辑 CI/CD 配置开始使用 API 模糊测试。

先决条件：

- 使用以下任一受支持 API 类型的 Web API：
  - REST API
  - SOAP
  - GraphQL
  - 表单体、JSON 或 XML
- 以下格式之一的 API 规范：
  - OpenAPI v2 或 v3 规范
  - GraphQL 模式
  - HTTP 存档 (HAR)
  - Postman Collection v2.0 或 v2.1
- 一个可用的极狐GitLab Runner，带有 Linux/amd64 上的 `docker` 执行器。
- 已部署的目标应用程序。
- `fuzz` 阶段已添加到 CI/CD 流水线定义中，位于 `deploy` 阶段之后：

  ```yaml
  stages:
    - build
    - test
    - deploy
    - fuzz
  ```

要启用 API 模糊测试：

- 使用 [Web API 模糊测试配置表单](configuration/enabling_the_analyzer.md#web-api-fuzzing-configuration-form)。

  该表单允许你为最常见的 API 模糊测试选项选择值，并构建一个 YAML 片段，你可将其粘贴到极狐GitLab CI/CD 配置中。

<a id="understanding-the-results"></a>

## 理解结果

要查看安全扫描的输出：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 标签页。
1. 选择一个漏洞以查看其详细信息，包括：
   - 状态：指示漏洞是否已被分类或解决。
   - 描述：解释了漏洞的原因、潜在影响以及建议的修复步骤。
   - 严重性：根据影响分为六个级别。
     更多信息，请参见[严重性级别](../vulnerabilities/severities.md)。
   - 扫描器：标识哪个分析器检测到该漏洞。
   - 方法：建立易受攻击的服务器交互类型。
   - URL：显示漏洞的位置。
   - 证据：描述用于证明给定漏洞存在的测试用例。
   - 标识符：用于对漏洞进行分类的引用列表，例如 CWE 标识符。

你还可以下载安全扫描结果：

- 在流水线的 **安全** 标签页中，选择 **下载结果**。

更多详细信息，请参见[流水线安全报告](../detect/security_scanning_results.md)。

> [!note]
> 发现是在功能分支上生成的。当它们合并到默认分支时，它们就变成漏洞。在评估安全态势时，这一区别很重要。

<a id="optimization"></a>

## 优化

为了充分利用 API 模糊测试，请遵循以下建议：

- 为了运行最新版本的分析器，将 runners 配置为使用 `pull_policy: always`。
- 默认情况下，API 模糊测试会下载流水线中先前作业定义的所有产物。如果你的 API 模糊测试作业不依赖于 `environment_url.txt` 来定义测试 URL 或任何其他先前作业中创建的文件，则不应下载产物。

  为了避免下载产物，可以扩展分析器 CI/CD 作业以指定无依赖项。
  例如，对于 API 模糊测试分析器，请将以下内容添加到你的 `.gitlab-ci.yml` 文件中：

  ```yaml
  apifuzzer_fuzz:
    dependencies: []
  ```

<a id="application-deployment-options"></a>

### 应用程序部署选项

API 模糊测试需要一个已部署的应用程序可供扫描。

根据目标应用程序的复杂性，有几种关于如何部署和配置 API 模糊测试模板的选项。

<a id="docker-services"></a>

#### Docker 服务

如果你的应用程序使用 Docker 容器，则你可以选择另一种部署并使用 API 模糊测试进行扫描的方式。
在 Docker 构建作业完成并且你的镜像被添加到容器镜像仓库后，你可以将该镜像用作服务。

通过在 `.gitlab-ci.yml` 中使用服务定义，你可以使用 DAST 分析器扫描服务。

向作业添加 `services` 部分时，`alias` 用于定义可用于访问服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用程序的 URL 使用 `yourapp` 作为主机名：`https://yourapp/`。

```yaml
stages:
  - build
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

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

apifuzzer_fuzz:
  services: # 使用服务将你的应用程序容器链接到 dast 作业
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  FUZZAPI_TARGET_URL: https://yourapp
```

大多数应用程序依赖于多个服务，例如数据库或缓存服务。默认情况下，在 services 字段中定义的服务之间无法相互通信。要允许服务之间通信，请启用 `FF_NETWORK_PER_BUILD` 功能标志。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # 启用每个构建的网络，以便所有服务可以在同一网络上通信

services: # 使用服务将容器链接到 dast 作业
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```

<a id="roll-out"></a>

## 推广

Web API 模糊测试在 CI/CD 流水线的 `fuzz` 阶段运行。为了确保 API 模糊测试能够扫描最新的代码，你的 CI/CD 流水线应在 `fuzz` 阶段之前的某个阶段中，将更改部署到测试环境。

如果你的流水线配置为在每次运行时都部署到同一 Web 服务器，则在另一个流水线仍在运行时运行一个流水线可能会导致竞争条件，从而导致一个流水线覆盖另一个流水线的代码。在模糊扫描期间，要扫描的 API 应不受更改的影响。只有来自模糊测试扫描器的更改才能影响 API。在扫描期间对 API 所做的任何更改（例如由用户、计划任务、数据库更改、代码更改、其他流水线或其他扫描器所做的更改）都可能导致不准确的结果。

你可以使用以下方法运行 Web API 模糊测试扫描：

- OpenAPI 规范（版本 2 和 3）
- GraphQL 模式
- HTTP 存档 (HAR)
- Postman Collections（版本 2.0 和 2.1）

<a id="example-api-fuzzing-projects"></a>

### 示例 API 模糊测试项目

- [示例 OpenAPI v2 规范项目](https://jihulab.com/gitlab-cn/security-products/demos/api-fuzzing-example/-/tree/openapi)
- [示例 HTTP 存档 (HAR) 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-fuzzing-example/-/tree/har)
- [示例 Postman Collection 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-fuzzing/postman-api-fuzzing-example)
- [示例 GraphQL 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-fuzzing/graphql-api-fuzzing-example)
- [示例 SOAP 项目](https://jihulab.com/gitlab-cn/security-products/demos/api-fuzzing/soap-api-fuzzing-example)
- [使用 Selenium 的身份验证令牌](https://jihulab.com/gitlab-cn/security-products/demos/api-fuzzing/auth-token-selenium)

<a id="get-support-or-request-an-improvement"></a>

## 获取支持或请求改进

要针对你的特定问题获得支持，请使用[获取帮助渠道](https://gitlab.cn/get-help/)。

JihuLab.com 上的[极狐GitLab 议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues) 是报告关于 API 安全和 API 模糊测试的 bug 和功能提案的正确场所。
在打开有关 API 模糊测试的新议题时，请使用 `~"Category:API Security"` 标签，以确保它被正确的人员快速审查。

在提交自己的议题之前，先在议题跟踪器中搜索类似的条目，很有可能其他人已经有相同的问题或功能提案。用表情符号反应表示支持或加入讨论。

当遇到行为不符合预期的情况时，请考虑提供上下文信息：

- 如果使用私有化部署实例，提供极狐GitLab 版本。
- `.gitlab-ci.yml` 作业定义。
- 完整的作业控制台输出。
- 作为作业产物可用的扫描器日志文件，名为 `gl-api-security-scanner.log`。

> [!warning]
> 提交议题时请勿包含敏感信息。删除密码、令牌和密钥等凭据。

<a id="glossary"></a>

## 术语表

- 断言：断言是检查用来触发故障的检测模块。许多断言都有配置。一个检查可以使用多个断言。例如，日志分析、响应分析和状态码是检查通常一起使用的常见断言。具有多个断言的检查允许它们被打开和关闭。
- 检查：执行特定类型的测试，或检查某种类型的漏洞。例如，JSON 模糊测试检查对 JSON 载荷执行模糊测试。API 模糊测试器由多个检查组成。可以在配置文件中打开和关闭检查。
- 故障：在模糊测试期间，由断言识别的失败称为故障。故障会被调查以确定它们是安全漏洞、非安全问题还是误报。在调查之前，故障没有已知的漏洞类型。漏洞类型示例包括 SQL 注入和拒绝服务。
- 配置文件：配置文件具有一个或多个测试配置文件或子配置。你可以为功能分支设置一个配置文件，并为主分支设置另一个包含额外测试的配置文件。

