---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 要求
---

- [极狐GitLab Runner](../../../../../ci/runners/_index.md)可用，有在 Linux/amd64 上的   [`docker` executor](https://gitlab.cn/docs/runner/executors/docker.html)。
- 目标应用程序已部署。更多详情，可以查看[部署选项](#application-deployment-options).
- 在 CI/CD 流水线定义中添加 `dast` 阶段。此阶段应在部署步骤之后添加，例如：

  ```yaml
  stages:
    - build
    - test
    - deploy
    - dast
  ```

- runner 与目标应用程序之间需要有网络连接。

  如何连接取决于你的 DAST 配置：
  - 如果 `DAST_TARGET_URL` 和 `DAST_AUTH_URL` 指定了端口号，则使用这些端口。
  - 如果未指定端口号，则使用 HTTP 和 HTTPS 的标准端口。

  你可能需要同时开放 HTTP 和 HTTPS 端口。例如，如果目标 URL 使用 HTTP，但应用程序链接的资源使用 HTTPS。配置扫描时，请务必测试你的连接。

<a id="recommendations"></a>

## 推荐建议

- 注意，如果你的流水线被配置为在每次运行时部署到同一个 Web 服务器。正在更新服务器时运行 DAST 扫描会导致结果不准确且不确定。
- 配置 runners 使用[always pull 策略](https://gitlab.cn/docs/runner/executors/docker.html#using-the-always-pull-policy)以运行最新版本的分析器。
- 默认情况下，DAST 下载流水线中前面作业定义的所有产物。如果你的 DAST 作业不依赖于 `environment_url.txt` 来定义测试的 URL 或任何其他在前面作业中创建的文件，我们建议你不要下载产物。为避免下载产物，扩展分析器 CI/CD 作业以指定没有依赖关系。例如，对于基于 DAST 代理的分析器，在你的 `.gitlab-ci.yml` 文件中添加以下内容：

  ```yaml
  dast:
    dependencies: []
  ```

<a id="application-deployment-options"></a>

## 应用程序部署选项

DAST 需要已部署的应用程序才能进行扫描。

根据目标应用程序的复杂性，有几种选择可以部署和配置 DAST 模板。我们在[DAST 演示](https://gitlab.com/gitlab-org/security-products/demos/dast/)项目中提供了一组示例应用程序及其配置。

<a id="review-apps"></a>

### 审查应用程序

审查应用程序是部署你的 DAST 目标应用程序最复杂的方法。为了协助这个过程，我们使用 Google Kubernetes Engine (GKE) 创建了一个审查应用程序部署。

<a id="docker-services"></a>

### Docker 服务

如果你的应用程序使用 Docker 容器，你有另一种选择来部署和使用 DAST 进行扫描。在你的 Docker 构建作业完成并将你的镜像添加到容器镜像仓库后，你可以将该镜像作为[服务](../../../../../ci/services/_index.md)。

通过在你的 `.gitlab-ci.yml` 中使用服务定义，你可以使用 DAST 分析器扫描服务。

在作业中添加 `services` 部分时，`alias` 用于定义可用于访问服务的主机名。在下面的示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用程序的 URL 使用 `yourapp` 作为主机名（`https://yourapp/`）。

```yaml
stages:
  - build
  - dast

include:
  - template: DAST.gitlab-ci.yml

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

dast:
  services: # 使用服务将你的应用容器链接到 dast 作业
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  DAST_TARGET_URL: https://yourapp
  DAST_FULL_SCAN: "true" # 执行完整扫描
  DAST_BROWSER_SCAN: "true" # 使用基于浏览器的极狐GitLab DAST 爬虫
```

大多数应用程序依赖于多个服务，例如数据库或缓存服务。默认情况下，在服务字段中定义的服务无法相互通信。要允许服务之间的通信，请启用 `FF_NETWORK_PER_BUILD` [特性标志](https://gitlab.cn/docs/runner/configuration/feature-flags.html#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # 启用每个构建的网络，以便所有服务可以在同一网络上进行通信

services: # 使用服务将容器链接到 dast 作业
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```
