---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Run GitLab Self-Managed and GitLab Runner fleets on OpenShift and integrate with the GitLab agent for Kubernetes.
title: OpenShift 支持
---

OpenShift - 极狐GitLab 兼容性可以从三个不同方面来探讨。本页面帮助您在这些方面之间导航，并提供开始使用 OpenShift 和极狐GitLab 的入门信息。

<a id="what-is-openshift"></a>

## 什么是 OpenShift

OpenShift 帮助您开发、部署和管理基于容器的应用程序。它为您提供了一个自助服务平台，可以按需创建、修改和部署应用程序，从而加快开发和发布生命周期。

<a id="use-openshift-to-run-gitlab-self-managed"></a>

## 使用 OpenShift 运行极狐GitLab 私有化部署

您可以使用极狐GitLab Operator 在 OpenShift 集群中运行极狐GitLab。有关在 OpenShift 上设置极狐GitLab 的更多信息，请参阅 [极狐GitLab Operator](https://gitlab.cn/docs/operator/)。

<a id="use-openshift-to-run-a-gitlab-runner-fleet"></a>

## 使用 OpenShift 运行极狐GitLab Runner 机群

极狐GitLab Operator 不包含极狐GitLab Runner。要在 OpenShift 集群中安装和管理极狐GitLab Runner 机群，请使用 [极狐GitLab Runner Operator](https://jihulab.com/gitlab-cn/gl-openshift/gitlab-runner-operator)。

<a id="deploy-to-and-integrate-with-openshift-from-gitlab"></a>

### 从极狐GitLab 部署到 OpenShift 并与之集成

从极狐GitLab 将自定义或 COTS 应用程序部署到 OpenShift 之上，可以使用 [极狐GitLab Kubernetes 代理](../../user/clusters/agent/_index.md) 来支持。

<a id="unsupported-gitlab-features"></a>

### 不支持的极狐GitLab 功能

<a id="docker-in-docker"></a>

#### Docker-in-Docker

当使用 OpenShift 运行极狐GitLab Runner 机群时，由于 OpenShift 的安全模型，某些极狐GitLab 功能不受支持。需要 Docker-in-Docker 的功能可能无法工作。

对于 Auto DevOps，以下功能尚不支持：

- [Auto Code Quality](../../ci/testing/code_quality.md)
- [许可证批准策略](../../user/compliance/license_approval_policies.md)
- 自动浏览器性能测试
- 自动构建
- [运维容器扫描](../../user/clusters/agent/vulnerabilities.md)（注意：流水线中的 [容器扫描](../../user/application_security/container_scanning/_index.md) 是支持的）