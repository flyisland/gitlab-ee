---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 要求
---

1. 使用支持的 API 类型之一的 Web API：
   1. REST API
   1. SOAP
   1. GraphQL
   1. 表单体、JSON 或 XML

1. 以下格式之一的 API 规范：
   1. [OpenAPI v2 或 v3 规范](enabling_the_analyzer.md#openapi-specification)
   1. [GraphQL 模式](enabling_the_analyzer.md#graphql-schema)
   1. [HTTP Archive (HAR)](enabling_the_analyzer.md#http-archive-har)
   1. [Postman Collection v2.0 或 v2.1](enabling_the_analyzer.md#postman-collection)

1. [极狐GitLab Runner](../../../../ci/runners/_index.md) 可用，使用 Linux/amd64 上的 [`docker` 执行器](https://gitlab.cn/docs/runner/executors/docker.html)。
1. 目标应用已部署。有关更多详细信息，请阅读 [部署选项](#application-deployment-options)。
1. 在 CI/CD 流水线定义中添加了 `fuzz` 阶段。这应该在部署步骤之后添加，例如：

   ```yaml
   stages:
     - build
     - test
     - deploy
     - fuzz
   ```

<a id="recommendations"></a>

## 建议

1. 配置 runners 使用 [始终拉取策略](https://gitlab.cn/docs/runner/executors/docker.html#using-the-always-pull-policy) 来运行分析器的最新版本。
1. 默认情况下，API Fuzzing 下载流水线中之前作业定义的所有产物。如果您的 API Fuzzing 作业不依赖于 `environment_url.txt` 来定义测试的 URL 或之前作业创建的任何其他文件，您不应该下载产物。为了避免下载产物，请扩展分析器的 CI/CD 作业以指定无依赖项。例如，对于 API fuzzing 分析器，请将以下内容添加到您的 `.gitlab-ci.yml` 文件中：

   ```yaml
   apifuzzer_fuzz:
     dependencies: []
   ```

<a id="application-deployment-options"></a>

## 应用部署选项

API Fuzzing 需要已部署的应用程序可供扫描。

根据目标应用程序的复杂性，有几个选项可以部署和配置 API Fuzzing 模板。

<a id="review-apps"></a>

### 审核应用

审核应用是部署 API Fuzzing 目标应用程序的最复杂方法。

<a id="docker-services"></a>

### Docker 服务

如果您的应用程序使用 Docker 容器，您有另一种选择来使用 API Fuzzing 部署和扫描。在您的 Docker 构建作业完成并将镜像添加到您的容器镜像仓库后，您可以使用该镜像作为 [服务](../../../../ci/services/_index.md)。

通过在您的 `.gitlab-ci.yml` 中使用服务定义，您可以使用 DAST 分析器扫描服务。

在作业中添加 `services` 部分时，`alias` 用于定义可用于访问服务的主机名。在下面的示例中，`dast` 作业定义的 `alias: yourapp` 部分意味着已部署应用程序的 URL 使用 `yourapp` 作为主机名 (`https://yourapp/`)。

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
  services: # 使用服务将您的应用容器连接到 dast 作业
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  FUZZAPI_TARGET_URL: https://yourapp
```

大多数应用程序依赖于多个服务，如数据库或缓存服务。默认情况下，服务字段中定义的服务无法相互通信。要允许服务之间的通信，请启用 `FF_NETWORK_PER_BUILD` [特性标志](https://gitlab.cn/docs/runner/configuration/feature-flags.html#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # 启用每个构建的网络，以便所有服务可以在同一网络上通信

services: # 使用服务将容器连接到 dast 作业
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```
