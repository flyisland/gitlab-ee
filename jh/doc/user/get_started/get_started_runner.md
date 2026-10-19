---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 设置和管理极狐GitLab Runner。
title: 开始使用极狐GitLab Runner
---

极狐GitLab Runner 管理涵盖管理 CI/CD 作业执行基础设施的完整生命周期：

- 部署和注册 Runner
- 为特定工作负载配置执行器
- 扩展容量以匹配组织增长

管理 Runner 的过程是更大工作流的一部分：

![极狐GitLab 工作流：计划、创建、验证（包括管理 Runner）、安全、发布和监控。](img/get_started_runner_v18_3.png)

您可以通过作用域和标签管理 Runner 访问权限、监控性能并维护 Runner 集群。

<a id="step-1-install-runners"></a>

## 第 1 步：安装 Runner

安装极狐GitLab Runner 以创建执行 CI/CD 作业的应用程序。

安装包括在目标基础设施上下载并设置极狐GitLab Runner。
安装过程因目标操作系统而异。极狐GitLab 为 Linux、Windows、macOS 和 z/OS 提供二进制文件
和安装说明。请根据您的平台和需求选择安装方法。

更多信息，请参见[安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。

<a id="step-2-register-runners"></a>

## 第 2 步：注册 Runner

注册 Runner，以在您的极狐GitLab 实例与安装极狐GitLab Runner 的机器之间建立经过身份验证的通信。注册使用身份验证令牌将各个 Runner 连接到您的极狐GitLab 实例。注册期间，您需要指定 Runner 的作用域、执行器类型以及其他决定 Runner 运行方式的配置参数。

在注册 Runner 之前，您应确定是否要将其限制为特定的极狐GitLab 群组或项目。您可以在注册期间为私有化部署 Runner 配置不同的访问作用域，以确定它们可用于哪些项目：

- 实例 Runner：可用于您极狐GitLab 实例上的所有项目
- 群组 Runner：可用于特定群组及其子群组中的所有项目
- 项目 Runner：仅可用于特定项目

注册 Runner 时，请为其添加标签，以将作业路由到合适的 Runner。分配有意义的标签，并在您的 `.gitlab-ci.yml` 文件中引用它们，以确保作业在具备所需能力的 Runner 上运行。

CI/CD 作业运行时，会通过查看分配的标签来确定使用哪个 Runner。标签是筛选作业可用 Runner 列表的唯一方式。

更多信息，请参见：

- [注册 Runner](https://gitlab.cn/docs/runner/register/)
- [迁移到新的 Runner 注册工作流](../../ci/runners/new_creation_workflow.md)
- [实例 Runner](../../ci/runners/runners_scope.md#instance-runners)
- [群组 Runner](../../ci/runners/runners_scope.md#group-runners)
- [项目 Runner](../../ci/runners/runners_scope.md#project-runners)
- [标签](../../ci/yaml/_index.md#tags)

<a id="step-3-choose-executors"></a>

## 第 3 步：选择执行器

极狐GitLab Runner 执行器是极狐GitLab Runner 可用于执行 CI/CD 作业的不同环境和方法。
它们决定您的流水线作业实际运行的方式和位置。正确的配置可确保作业在具有正确安全边界的合适环境中运行。

注册 Runner 时，您必须选择执行器。极狐GitLab Runner 使用执行器系统来确定作业运行的位置和方式。执行器决定每个作业运行的环境。请选择与您的基础设施和作业需求相匹配的执行器。

例如：

- 如果您希望 CI/CD 作业运行 PowerShell 命令，可以在 Windows 服务器上安装极狐GitLab Runner，然后注册一个使用 shell 执行器的 Runner。
- 如果您希望 CI/CD 作业在自定义 Docker 容器中运行命令，
  可以在 Linux 服务器上安装极狐GitLab Runner，并注册一个使用
  Docker 执行器的 Runner。

这些示例只是几种可能的配置。您可以在虚拟机上安装极狐GitLab Runner，并让它使用另一台虚拟机作为执行器。

更多信息，请参见[执行器](https://gitlab.cn/docs/runner/executors/)。

<a id="step-4-configure-runners-and-start-running-jobs"></a>

## 第 4 步：配置 Runner 并开始运行作业

您可以通过编辑 `config.toml` 文件来配置极狐GitLab Runner，该文件会在您安装和注册 Runner 时自动生成。在此文件中，您可以编辑特定 Runner 或所有 Runner 的设置。通过配置该文件来设置并发限制、日志级别、缓存设置、CPU 限制以及执行器特定的参数。在您的 Runner 集群中使用一致的配置。

Runner 配置完成并可用于您的项目后，您的 CI/CD 作业即可使用该 Runner。

Runner 通常会在您安装极狐GitLab Runner 的同一台机器上处理作业。不过，您也可以让 Runner 在容器中、在 Kubernetes 集群中或在云端的自动扩缩实例中处理作业。

更多信息，请参见：

- [配置极狐GitLab Runner](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)
- [CI/CD 作业](../../ci/jobs/_index.md)

<a id="step-5-continue-to-configure-scale-and-optimize-your-runners"></a>

## 第 5 步：继续配置、扩展和优化您的 Runner

高级 Runner 功能可提高作业执行效率，并为复杂的 CI/CD 工作流提供专门能力。这些优化通过自动扩缩、性能监控、Runner 集群管理和专门配置，缩短作业运行时间并提升开发者体验。

自动扩缩会根据作业需求自动调整 Runner 容量，而性能优化可确保高效利用资源。这些能力可帮助您处理可变的工作负载，同时控制基础设施成本。

Runner 集群管理为多个 Runner 提供集中控制和监控，支持企业规模的 Runner 部署。Runner 集群扩缩涉及协调多个 Runner 之间的容量并实施运维最佳实践。

使用内置的 Prometheus 指标来帮助您监控 Runner 的运行状况和性能。您可以跟踪活动作业数、CPU 利用率、内存使用量、作业成功率和队列长度等关键指标，以确保 Runner 高效运行。

更多信息，请参见：

- [自动扩缩配置](https://gitlab.cn/docs/runner/runner_autoscale/)
- [Runner 集群扩缩](https://gitlab.cn/docs/runner/fleet_scaling/)
- [Runner 集群配置和最佳实践](../../topics/runner_fleet_design_guides/_index.md)
- [监控 Runner 性能](https://gitlab.cn/docs/runner/monitoring/)
- [Runner 集群仪表板](../../ci/runners/runner_fleet_dashboard.md)
- [长轮询](../../ci/runners/long_polling.md)
- [Docker-in-Docker 配置](https://gitlab.cn/docs/runner/executors/docker/)
- [GitLab Runner Infrastructure Toolkit (GRIT)](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit)
