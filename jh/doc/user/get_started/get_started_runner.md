---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Set up and manage GitLab Runner.
title: 开始使用极狐GitLab Runner
---

<a id="step-1-install-runners"></a>

极狐GitLab Runner 管理涵盖了管理 CI/CD 作业执行基础设施的完整生命周期：

- 部署和注册 runner
- 针对特定工作负载配置执行器
- 根据组织增长扩展容量

管理 runner 的过程是更大工作流的一部分：

![极狐GitLab 工作流：计划、创建、验证（包括管理 runner）、安全、发布和监控。](img/get_started_runner_v18_3.png)

您可以通过作用域和标签来管理 runner 的访问权限，监控性能并维护 runner 集群。

<a id="step-1-install-runners"></a>

## 步骤 1：安装 runner

安装极狐GitLab Runner，创建执行 CI/CD 作业的应用程序。

安装包括在目标基础设施上下载和设置极狐GitLab Runner。安装过程因目标操作系统而异。极狐GitLab 为 Linux、Windows、macOS 和 z/OS 提供二进制文件和安装说明。根据您的平台和需求选择安装方法。

更多信息，请参见[安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)。

<a id="step-2-register-runners"></a>

## 步骤 2：注册 runner

注册 runner，建立极狐GitLab 实例与安装极狐GitLab Runner 的机器之间的经过身份验证的通信。
注册时会使用身份验证令牌将各个 runner 连接到您的极狐GitLab 实例。在注册过程中，您可以指定 runner 的作用域、执行器类型以及其他决定 runner 运行方式的配置参数。

注册 runner 之前，应确定是否要将其限制于特定的极狐GitLab 群组或项目。
您可以在注册过程中为私有化部署的 runner 配置不同的访问作用域，以确定它们可用于哪些项目：

- 实例 runner：可用于极狐GitLab 实例上的所有项目
- 群组 runner：可用于特定群组及其子群组中的所有项目
- 项目 runner：仅可用于特定项目

注册 runner 时，请为其添加标签以将作业路由到合适的 runner。分配有意义的标签，并在 `.gitlab-ci.yml` 文件中引用它们，以确保作业在具有所需能力的 runner 上运行。

当 CI/CD 作业运行时，它会通过查看分配的标签来确定要使用的 runner。标签是筛选作业可用 runner 列表的唯一方式。

更多信息，请参见：

- [注册 runner](https://gitlab.cn/docs/runner/register/)
- [迁移到新的 runner 注册工作流](../../ci/runners/new_creation_workflow.md)
- [实例 runner](../../ci/runners/runners_scope.md#instance-runners)
- [群组 runner](../../ci/runners/runners_scope.md#group-runners)
- [项目 runner](../../ci/runners/runners_scope.md#project-runners)
- [标签](../../ci/yaml/_index.md#tags)

<a id="step-3-choose-executors"></a>

## 步骤 3：选择执行器

极狐GitLab Runner 执行器是极狐GitLab Runner 可用于执行 CI/CD 作业的不同环境和方法。它们决定了流水线作业实际在何处以及如何运行。正确配置可确保作业在具有正确安全边界的适当环境中运行。

注册 runner 时，您必须选择一个执行器。极狐GitLab Runner 使用执行器系统来决定作业在何处以及如何运行。执行器决定了每个作业运行的环境。选择与您的基础设施和作业要求相匹配的执行器。

例如：

- 如果您希望 CI/CD 作业运行 PowerShell 命令，可以在 Windows 服务器上安装极狐GitLab Runner，然后注册一个使用 Shell 执行器的 runner。
- 如果您希望 CI/CD 作业在自定义 Docker 容器中运行命令，可以在 Linux 服务器上安装极狐GitLab Runner，然后注册一个使用 Docker 执行器的 runner。

以上仅是几种可能的配置示例。您可以在虚拟机上安装极狐GitLab Runner，并让其使用另一台虚拟机作为执行器。

更多信息，请参见[执行器](https://gitlab.cn/docs/runner/executors/)。

<a id="step-4-configure-runners-and-start-running-jobs"></a>

## 步骤 4：配置 runner 并开始运行作业

您可以通过编辑 `config.toml` 文件来配置极狐GitLab Runner，该文件在您安装和注册 runner 时自动生成。在此文件中，您可以编辑特定 runner 或所有 runner 的设置。配置它可以设置并发限制、日志级别、缓存设置、CPU 限制以及特定于执行器的参数。在整个 runner 集群中使用一致的配置。

当 runner 配置完成并可用于项目后，您的 CI/CD 作业就可以使用该 runner。

Runner 通常在安装极狐GitLab Runner 的同一台机器上处理作业。但是，您也可以让 runner 在容器、Kubernetes 集群或云中的自动扩缩实例中处理作业。

更多信息，请参见：

- [配置极狐GitLab Runner](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)
- [CI/CD 作业](../../ci/jobs/_index.md)

<a id="step-5-continue-to-configure-scale-and-optimize-your-runners"></a>

## 步骤 5：继续配置、扩展和优化您的 runner

高级 runner 功能可提高作业执行效率，并为复杂的 CI/CD 工作流提供专门的功能。这些优化通过自动扩缩、性能监控、集群管理和专用配置，减少了作业运行时间并提升了开发者体验。

自动扩缩会根据作业需求自动调整 runner 容量，而性能优化则确保资源得到高效利用。这些能力可帮助您处理可变的工作负载，同时控制基础设施成本。

集群管理为多个 runner 提供集中控制和监控，支持企业级的 runner 部署。集群扩展涉及协调多个 runner 之间的容量并实施运维最佳实践。

使用内置的 Prometheus 指标来帮助您监控 runner 的健康状况和性能。您可以跟踪关键指标，如活动作业数、CPU 利用率、内存使用、作业成功率和队列长度，以确保您的 runner 高效运行。

更多信息，请参见：

- [自动扩缩配置](https://gitlab.cn/docs/runner/runner_autoscale/)
- [集群扩展](https://gitlab.cn/docs/runner/fleet_scaling/)
- [Runner 集群配置和最佳实践](../../topics/runner_fleet_design_guides/_index.md)
- [监控 runner 性能](https://gitlab.cn/docs/runner/monitoring/)
- [Runner 集群仪表板](../../ci/runners/runner_fleet_dashboard.md)
- [长轮询](../../ci/runners/long_polling.md)
- [Docker-in-Docker 配置](https://gitlab.cn/docs/runner/executors/docker/)
- [极狐GitLab Runner Infrastructure Toolkit (GRIT)](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/grit)