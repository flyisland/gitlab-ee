---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 来自 Linux 软件包的软件包和镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

下面介绍一些基本信息，说明极狐GitLab 为什么提供带有捆绑依赖项的软件包和 Docker 镜像。

这些方式非常适合物理机和虚拟机安装，以及简单的 Docker 安装。

<a id="goals"></a>

## 目标

这些软件包有几个核心目标：

1. 安装、升级和维护极其简单。
1. 支持多种操作系统。
1. 广泛支持各类云服务提供商。

<a id="linux-package-architecture"></a>

## Linux 软件包架构

极狐GitLab 的核心是一个 Ruby on Rails 项目。但作为一个整体应用，极狐GitLab 更为复杂，包含多个组件。如果这些组件缺失或配置不正确，极狐GitLab 将无法工作，或运行结果不可预测。

GitLab 开发文档中的 GitLab 架构概览展示了其中一些组件及其交互方式。每个组件都需要配置并保持更新。

大多数组件还有外部依赖项。例如，Rails 应用依赖若干 [Ruby gem](https://gitlab.com/gitlab-org/gitlab-foss/blob/master/Gemfile.lock)。其中一些依赖项还有各自的外部依赖项，这些依赖项需要存在于操作系统上，它们才能正常工作。

此外，极狐GitLab 采用每月发布周期，需要频繁维护才能保持最新。

上述所有情况都给维护极狐GitLab 安装的用户带来了挑战。

<a id="external-software-dependencies"></a>

## 外部软件依赖项

对于极狐GitLab 这类应用，外部依赖项通常会带来以下挑战：

- 在直接依赖项和间接依赖项之间保持版本同步
- 某个版本在特定操作系统上的可用性
- 版本变更可能引入或移除之前使用的配置
- 当某个库被标记为存在漏洞但尚未发布新版本时带来的安全影响

请记住，如果某个依赖项存在于您的操作系统上，它不一定存在于其他受支持的操作系统上。

<a id="benefits"></a>

## 优势

带有捆绑依赖项的软件包有以下一些优势：

1. 安装极狐GitLab 所需的工作量极小。
1. 让极狐GitLab 启动并运行所需的配置极少。
1. 在极狐GitLab 各版本之间升级所需的工作量极小。
1. 支持多个平台。
1. 旧平台上的维护大大简化。
1. 支持潜在问题所需的工作量更少。

<a id="drawbacks"></a>

## 劣势

带有捆绑依赖项的软件包有以下一些劣势：

1. 可能与已存在的软件重复。
1. 配置灵活性较低。

<a id="why-would-you-install-a-package-from-the-linux-package-when-you-can-use-a-system-package"></a>

## 既然可以使用系统软件包，为什么还要安装 Linux 软件包中的软件包？

答案可以简化为：所需维护更少。与其处理多个软件包（如果版本不兼容，它们可能会破坏现有功能），不如只处理一个。

多个软件包需要在多个位置进行正确配置。保持配置同步很容易出错。

如果您有能力维护所有当前依赖项，并且有足够时间处理未来可能引入的任何依赖项，那么上述理由可能不足以让您放弃使用 Linux 软件包中的软件包。

在采用这种方式之前，有两点需要记住：

1. 由于使用未经大多数用户测试的库版本时存在多种可能性，您遇到的任何问题可能更难获得支持。
1. 如果您需要独立运行某个组件，Linux 软件包中的软件包也允许关闭任何您不需要的服务。例如，您可以在 Linux 软件包安装中使用[非捆绑的 PostgreSQL 数据库](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)。

请记住，当应用包含许多可变部分时，像 Linux 软件包这样的非标准解决方案可能更合适。

<a id="docker-image-with-multiple-services"></a>

## 包含多个服务的 Docker 镜像

[极狐GitLab Docker 镜像](../../install/docker/_index.md)基于 Linux 软件包。

考虑到从此镜像创建的容器包含多个进程，这类容器也被称为“胖容器”。

对于这样的镜像，既有支持的理由，也有反对的理由，但它们与前面提到的类似：

1. 上手非常简单。
1. 升级到最新版本极其简单。
1. 在多个容器中运行单独的服务并保持它们持续运行可能更复杂，而且对于特定安装来说可能并不需要。

这种方式适合刚开始使用容器和调度器的组织，这些组织可能尚未准备好进行更复杂的安装。这种方式是很好的入门选择，也适合规模较小的组织。
