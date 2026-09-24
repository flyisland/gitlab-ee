---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安装方式
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使用以下方法之一安装极狐GitLab。

## Linux 软件包

<a id="linux-package"></a>

Linux 软件包包含官方的 `deb` 和 `rpm` 软件包。该软件包包含极狐GitLab 及其依赖组件，包括 PostgreSQL、Redis 和 Sidekiq。

如果您想要最成熟、可扩展的方法，请使用此方法。此版本也在 JihuLab.com 上使用。

更多信息，请参见：

- [Linux 软件包](package/_index.md)
- [参考架构](../administration/reference_architectures/_index.md)
- [系统要求](requirements.md)
- [支持的 Linux 操作系统](package/_index.md#supported-platforms)

## Helm Chart

<a id="helm-chart"></a>

使用 Chart 在 Kubernetes 上安装云原生版本的极狐GitLab 及其组件。

如果您的基础设施在 Kubernetes 上并且您熟悉其工作原理，请使用此方法。

在使用此安装方法之前，请考虑以下几点：

- 管理、可观测性和一些其他概念与传统部署不同。
- 管理和故障排除需要 Kubernetes 知识。
- 对于较小的安装，成本可能更高。
- 默认安装比单节点 Linux 软件包部署需要更多资源，因为大多数服务以冗余方式部署。

更多信息，请参见 [Helm charts](https://gitlab.cn/docs/charts/)。

## 极狐GitLab Operator

<a id="gitlab-operator"></a>

要在 Kubernetes 中安装云原生版本的极狐GitLab 及其组件，请使用极狐GitLab Operator。此安装和管理方法遵循 [Kubernetes Operator 模式](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)。

如果您的基础设施在 Kubernetes 或 [OpenShift](openshift_and_gitlab/_index.md) 上，并且您熟悉 Operator 的工作方式，请使用此方法。

此安装方法提供了超越 Helm chart 安装方法的额外功能，包括自动执行 [极狐GitLab 升级步骤](https://gitlab.cn/docs/operator/gitlab_upgrades/)。Helm chart 的注意事项同样适用。

如果您受到 [极狐GitLab Operator 已知问题](https://gitlab.cn/docs/operator/#known-issues) 的限制，请考虑使用 Helm chart 安装方法。

更多信息，请参见 [极狐GitLab Operator](https://gitlab.cn/docs/operator/)。

## Docker

<a id="docker"></a>

在 Docker 容器中安装极狐GitLab 软件包。

如果您熟悉 Docker，请使用此方法。

更多信息，请参见 [Docker](docker/_index.md)。

## 自行编译

<a id="self-compiled"></a>

从源代码安装极狐GitLab 及其组件。

如果之前的任何方法都不适用于您的平台，请使用此方法。可用于不受支持的系统，如 \*BSD。

更多信息，请参见 [自行编译安装](self_compiled/_index.md)。

## 极狐GitLab 环境工具包 (GET)

<a id="gitlab-environment-toolkit-get"></a>

[极狐GitLab 环境工具包 (GET)](https://jihulab.com/gitlab-cn/gitlab-environment-toolkit#documentation) 是一组预设的 Terraform 和 Ansible 脚本。

您可以使用 GET 在选定的主要云提供商（GCP、AWS 和 Azure）上按照 [参考架构](../administration/reference_architectures/_index.md) 部署可扩展的极狐GitLab 环境。

此安装方法有一些 [限制](https://jihulab.com/gitlab-cn/gitlab-environment-toolkit#missing-features-to-be-aware-of)，并且需要手动设置生产环境。

## 不受支持的 Linux 发行版和类 Unix 操作系统

<a id="unsupported-linux-distributions-and-unix-like-operating-systems"></a>

在以下操作系统上 [自行编译安装](self_compiled/_index.md) 极狐GitLab 是可能的，但不被支持：

- Arch Linux
- FreeBSD
- Gentoo
- macOS

## Microsoft Windows

<a id="microsoft-windows"></a>

极狐GitLab 是为基于 Linux 的操作系统开发的。
它不能在 Microsoft Windows 上运行，并且近期没有支持它的计划。
考虑使用虚拟机运行极狐GitLab。
