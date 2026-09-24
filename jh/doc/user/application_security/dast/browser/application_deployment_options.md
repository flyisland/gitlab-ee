---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用部署选项
---

DAST 需要部署一个可扫描的应用。

根据目标应用程序的复杂度，有几种选项来部署和配置 DAST 模板。项目 [DAST 演示](https://jihulab.com/gitlab-cn/security-products/demos/dast/) 提供了一组示例应用程序及其配置。

<a id="review-apps"></a>

## 审查应用

审查应用是部署 DAST 目标应用程序最复杂的方法。为了帮助这一过程，极狐GitLab 创建了使用 Google Kubernetes Engine (GKE) 的审查应用部署示例。该示例可以在 [审查应用 - GKE](https://jihulab.com/gitlab-cn/security-products/demos/dast/review-app-gke) 项目找到，并且在 [README](https://jihulab.com/gitlab-cn/security-products/demos/dast/review-app-gke/-/blob/master/README.md) 中提供了配置审查应用用于 DAST 的详细说明。

<a id="docker-services"></a>

## Docker 服务

如果你的应用程序使用 Docker 容器，则有另一种部署和 DAST 扫描的选项。Docker 构建作业完成后，镜像被添加到容器镜像仓库，你可以将镜像用作 [服务](../../../../ci/services/_index.md)。

通过在 `.gitlab-ci.yml` 中使用服务定义，你可以使用 DAST 分析器扫描服务。

当向作业添加 `services` 部分时，`alias` 用于定义可用于访问该服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用的 URL 使用 `yourapp` 作为主机名 (`https://yourapp/`)。

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
  services: # 使用服务将你的应用程序容器链接到 dast 作业
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  DAST_TARGET_URL: https://yourapp
  DAST_FULL_SCAN: "true" # 执行全量扫描
  DAST_BROWSER_SCAN: "true" # 使用基于浏览器的极狐GitLab DAST 爬虫
```

大多数应用程序依赖多个服务，例如数据库或缓存服务。默认情况下，在 services 字段中定义的服务之间不能相互通信。为了使服务间能够通信，需要启用 `FF_NETWORK_PER_BUILD` [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # 启用每个构建的网络，以便所有服务可以在同一网络中通信

services: # 使用服务将容器链接到 dast 作业
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```