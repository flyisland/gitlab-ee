---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 要求
---

- 一个使用以下支持的 API 类型的 Web API：
  - REST API
  - SOAP
  - GraphQL
  - 表单主体、JSON 或 XML
- 以下格式之一的 API 规范：
  - [OpenAPI v2 或 v3 规范](enabling_the_analyzer.md#openapi-specification)
  - [GraphQL Schema](enabling_the_analyzer.md#graphql-schema)
  - [HTTP Archive (HAR)](enabling_the_analyzer.md#http-archive-har)
  - [Postman Collection v2.0 或 v2.1](enabling_the_analyzer.md#postman-collection)

  每次扫描仅支持一个规范。要扫描多个规范，请使用多次扫描。
- [极狐GitLab Runner](../../../../ci/runners/_index.md) 可用，使用 Linux/amd64 上的 [`docker` executor](https://gitlab.cn/docs/runner/executors/docker.html)。
- 目标应用已部署。有关更多详细信息，请阅读[部署选项](#application-deployment-options)。
- 在 CI/CD 流水线定义中添加了 `dast` 阶段。这应该在部署步骤之后添加，例如：

  ```yaml
  stages:
    - build
    - test
    - deploy
    - dast
  ```

<a id="recommendations"></a>

## 建议

- 配置 runner 使用[始终拉取策略](https://gitlab.cn/docs/runner/executors/docker.html#using-the-always-pull-policy)来运行最新版本的分析器。
- 默认情况下，API 安全测试会下载流水线中先前作业定义的所有产物。如果你的 DAST 作业不依赖 `environment_url.txt` 来定义测试的 URL 或先前作业中创建的任何其他文件，则不应下载产物。为了避免下载产物，请扩展分析器 CI/CD 作业以指定无依赖项。例如，对于 API 安全测试分析器，在 `.gitlab-ci.yml` 文件中添加以下内容：

  ```yaml
  api_security:
    dependencies: []
  ```

<a id="application-deployment-options"></a>

## 应用部署选项

API 安全测试需要一个已部署的应用可供扫描。

根据目标应用的复杂性，有几种方法可以部署和配置 API 安全测试模板。

<a id="review-apps"></a>

### 评审应用

评审应用是部署你的 DAST 目标应用的最复杂方法。为了协助这一过程，我们使用 Google Kubernetes Engine (GKE) 创建了一个评审应用部署。

<a id="docker-services"></a>

### Docker 服务

如果你的应用使用 Docker 容器，你有另一种选择来使用 DAST 部署和扫描。在你的 Docker 构建作业完成并将镜像添加到你的容器镜像仓库后，你可以将镜像用作[服务](../../../../ci/services/_index.md)。

通过在 `.gitlab-ci.yml` 中使用服务定义，你可以使用 DAST 分析器扫描服务。

在作业中添加 `services` 部分时，`alias` 用于定义可以用于访问服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用的 URL 使用 `yourapp` 作为主机名 (`https://yourapp/`)。

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
  services: # 使用服务将你的应用容器链接到 dast 作业
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  APISEC_TARGET_URL: https://yourapp
```

大多数应用依赖于多个服务，例如数据库或缓存服务。默认情况下，在服务字段中定义的服务无法相互通信。要允许服务之间的通信，请启用 `FF_NETWORK_PER_BUILD` [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags.html#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # 启用每个构建的网络，以便所有服务可以在同一网络上进行通信

services: # 使用服务将容器链接到 dast 作业
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```
