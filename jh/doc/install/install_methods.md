---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Linux、Helm、Docker、Operator、源码或脚本。
title: 安装方法
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以在多个[云服务提供商](cloud_providers.md)上安装极狐GitLab，也可以使用以下方法之一。

<a id="linux-package"></a>

## Linux 软件包

Linux 软件包包含官方 `deb` 和 `rpm` 软件包。该软件包包含极狐GitLab 及其依赖组件，包括 PostgreSQL、Redis 和 Sidekiq。

如果您想要最成熟、可扩展性最强的方法，请使用此方式。JihuLab.com 也使用此版本。

更多信息，请参见：

- [Linux 软件包](package/_index.md)
- [参考架构](../administration/reference_architectures/_index.md)
- [系统要求](requirements.md)
- [支持的 Linux 操作系统](package/_index.md#supported-platforms)

<a id="helm-chart"></a>

## Helm chart

使用 chart 在 Kubernetes 上安装云原生版本的极狐GitLab 及其组件。

如果您的基础设施运行在 Kubernetes 上，并且您熟悉其工作方式，请使用此方式。

在使用此安装方法之前，请考虑以下事项：

- 管理、可观测性以及其他一些概念与传统部署方式不同。
- 管理和故障排除需要具备 Kubernetes 知识。
- 对于较小的安装规模，成本可能更高。
- 默认安装所需的资源比单节点 Linux 软件包部署更多，因为大多数服务以冗余方式部署。

更多信息，请参见 [Helm charts](https://gitlab.cn/docs/charts/)。

<a id="gitlab-operator"></a>

## GitLab Operator

要在 Kubernetes 中安装云原生版本的极狐GitLab 及其组件，请使用 GitLab Operator。
此安装和管理方法遵循 [Kubernetes Operator 模式](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)。

如果您的基础设施运行在 Kubernetes 或 [OpenShift](openshift_and_gitlab/_index.md) 上，并且您熟悉 Operator 的工作方式，请使用此方式。

此安装方法提供 Helm chart 安装方法之外的其他功能，包括[极狐GitLab 升级步骤](https://docs.gitlab.com/operator/gitlab_upgrades/)的自动化。Helm chart 的注意事项同样适用于此方式。

如果您受到 [GitLab Operator 已知问题](https://docs.gitlab.com/operator/#known-issues)的限制，请考虑使用 Helm chart 安装方法。

更多信息，请参见 [GitLab Operator](https://docs.gitlab.com/operator/)。

<a id="docker"></a>

## Docker

在 Docker 容器中安装极狐GitLab 软件包。

如果您熟悉 Docker，请使用此方式。

更多信息，请参见 [Docker](docker/_index.md)。

<a id="self-compiled"></a>

## 自行编译

从零开始安装极狐GitLab 及其组件。

如果上述方法均不适用于您的平台，请使用此方式。您可以将其用于不受支持的系统，例如 \*BSD。

更多信息，请参见[自行编译安装](self_compiled/_index.md)。

<a id="gitlab-environment-toolkit-get"></a>

## GitLab Environment Toolkit (GET)

[GitLab Environment Toolkit (GET)](https://gitlab.com/gitlab-org/gitlab-environment-toolkit#documentation) 是一组有预设规范的 Terraform 和 Ansible 脚本。

您可以使用 GET，在选定的主要云服务提供商（GCP、AWS 和 Azure）上按照[参考架构](../administration/reference_architectures/_index.md)部署规模化极狐GitLab 环境。

此安装方法有一些[限制](https://gitlab.com/gitlab-org/gitlab-environment-toolkit#missing-features-to-be-aware-of)，并且生产环境需要手动设置。

<a id="unsupported-linux-distributions-and-unix-like-operating-systems"></a>

## 不受支持的 Linux 发行版和类 Unix 操作系统

在以下操作系统上[自行编译安装](self_compiled/_index.md)极狐GitLab 是可行的，但不受支持：

- Arch Linux
- FreeBSD
- Gentoo
- macOS

<a id="microsoft-windows"></a>

## Microsoft Windows

极狐GitLab 是为基于 Linux 的操作系统开发的。它无法在 Microsoft Windows 上运行，近期也没有支持该系统的计划。有关最新开发状态，请参见[议题 22337](https://gitlab.com/gitlab-org/gitlab/-/issues/22337)。请考虑使用虚拟机来运行极狐GitLab。
