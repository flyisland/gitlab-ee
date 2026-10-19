---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用部署选项
---

DAST 需要有一个已部署的应用程序可供扫描。

根据目标应用程序的复杂程度，部署和配置 DAST 模板有几种可选方案。在 [DAST 演示](https://gitlab.com/gitlab-org/security-products/demos/dast/)项目中提供了一组示例应用程序及其配置。

<a id="review-apps"></a>

## 审查应用

审查应用是部署 DAST 目标应用程序最复杂的方法。为协助这一过程，
GitLab 使用 Google Kubernetes Engine (GKE) 创建了一个审查应用部署示例。该示例可在
[审查应用 - GKE](https://gitlab.com/gitlab-org/security-products/demos/dast/review-app-gke) 项目中找到，此外 [README](https://gitlab.com/gitlab-org/security-products/demos/dast/review-app-gke/-/blob/master/README.md)中还提供了为 DAST 配置审查应用的详细说明。

<a id="docker-services"></a>

## Docker 服务

如果您的应用程序使用 Docker 容器，那么在使用 DAST 部署和扫描时还有另一种选择。在您的 Docker 构建作业完成并将镜像添加到容器镜像仓库后，您可以将该镜像用作[服务](../../../../ci/services/_index.md)。

通过在 `.gitlab-ci.yml`中使用服务定义，您可以使用 DAST 分析器扫描服务。

在向作业添加 `services` 部分时，`alias` 用于定义可用于访问该服务的主机名。在以下示例中，`dast` 作业定义中的 `alias: yourapp` 部分意味着已部署应用程序的 URL 使用 `yourapp` 作为主机名（`https://yourapp/`）。

```yaml
stages:
  - build
  - dast

include:
  - template: DAST.gitlab-ci.yml

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

dast:
  services: # use services to link your app container to the dast job
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: yourapp

variables:
  DAST_TARGET_URL: https://yourapp
  DAST_FULL_SCAN: "true" # do a full scan
  DAST_BROWSER_SCAN: "true" # use the browser-based GitLab DAST crawler
```

大多数应用程序依赖多个服务，例如数据库或缓存服务。默认情况下，服务字段中定义的服务无法相互通信。要允许服务之间通信，请启用 `FF_NETWORK_PER_BUILD` [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。

```yaml
variables:
  FF_NETWORK_PER_BUILD: "true" # enable network per build so all services can communicate on the same network

services: # use services to link the container to the dast job
  - name: mongo:latest
    alias: mongo
  - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    alias: yourapp
```
