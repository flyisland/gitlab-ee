---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 OpenShift 上运行极狐GitLab 私有化部署和极狐GitLab Runner 集群，并与极狐GitLab Kubernetes Agent 集成。
title: OpenShift 支持
---

OpenShift 与极狐GitLab 的兼容性可以从三个不同方面来考虑。本页面帮助您在这些方面之间进行导航，并提供 OpenShift 与极狐GitLab 入门的介绍性信息。

<a id="what-is-openshift"></a>

## 什么是 OpenShift

OpenShift 帮助您开发、部署和管理基于容器的应用。它为您提供一个自助服务平台，可按需创建、修改和部署应用。这实现了更快的开发和发布生命周期。

<a id="use-openshift-to-run-gitlab-self-managed"></a>

## 使用 OpenShift 运行极狐GitLab 私有化部署

您可以使用 GitLab Operator 在 OpenShift 集群中运行极狐GitLab。有关在 OpenShift 上设置极狐GitLab 的更多信息，请参阅 [GitLab Operator](https://docs.gitlab.com/operator/)。

<a id="use-openshift-to-run-a-gitlab-runner-fleet"></a>

## 使用 OpenShift 运行极狐GitLab Runner 集群

GitLab Operator 不包含极狐GitLab Runner。要在 OpenShift 集群中安装和管理极狐GitLab Runner 集群，请使用
[GitLab Runner Operator](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator)。

<a id="deploy-to-and-integrate-with-openshift-from-gitlab"></a>

### 从极狐GitLab 部署到 OpenShift 并与之集成

支持使用[极狐GitLab Kubernetes Agent](../../user/clusters/agent/_index.md) 从极狐GitLab 在 OpenShift 之上部署自定义或 COTS 应用。

<a id="unsupported-gitlab-features"></a>

### 不支持的极狐GitLab 功能

<a id="docker-in-docker"></a>

#### Docker-in-Docker

使用 OpenShift 运行极狐GitLab Runner 集群时，由于 OpenShift 的安全模型，部分极狐GitLab 功能不受支持。
需要 Docker-in-Docker 的功能可能无法正常工作。

对于 Auto DevOps，以下功能尚不受支持：

- [自动代码质量](../../ci/testing/code_quality.md)
- [许可证审批策略](../../user/compliance/license_approval_policies.md)
- 自动浏览器性能测试
- 自动构建
- [运维容器扫描](../../user/clusters/agent/vulnerabilities.md)（注意：支持在流水线中进行[容器扫描](../../user/application_security/container_scanning/_index.md)）
