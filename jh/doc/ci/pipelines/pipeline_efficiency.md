---
stage: Verify
group: Pipeline Execution
info: This page is maintained by Developer Relations, author @dnsmichi, see <https://handbook.gitlab.com/handbook/marketing/developer-relations/developer-advocacy/content/#maintained-documentation>
title: 流水线效率
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[CI/CD 流水线](_index.md) 是 [极狐GitLab CI/CD](../_index.md) 的基本构建块。
提高流水线的效率有助于节省开发人员的时间，从而：

- 加速 DevOps 流程
- 降低成本
- 缩短开发反馈循环

新团队或新项目通常以缓慢且低效的流水线起步，并通过反复试验逐步改进其配置。更好的做法是从一开始就使用能够提高效率的流水线功能，从而更早获得更快的软件开发生命周期。

首先，请确保您熟悉 [极狐GitLab CI/CD 基础知识](../_index.md)，
并理解 [快速入门指南](../quick_start/_index.md)。

<a id="identify-bottlenecks-and-common-failures"></a>

## 识别瓶颈和常见故障

检查低效流水线最容易的指标是作业、阶段的运行时间，以及流水线本身的总运行时间。总的流水线时长在很大程度上受以下因素影响：

- [代码仓库的大小](../../user/project/repository/monorepos/_index.md)
- 阶段和作业的总数。
- 作业之间的依赖关系。
- [“关键路径”](#needs-dependency-visualization)，它表示
  流水线的最短和最长时长。

需要关注的其它要点与 [极狐GitLab Runner](../runners/_index.md) 相关：

- Runner 的可用性及其预配的资源。
  如果您使用极狐GitLab 托管的 Runner，请选择适合作业的
  [机器类型](../runners/hosted_runners/linux.md#machine-types-available-for-linux---x86-64)，
  而不是过度预配或预配不足。
- 构建依赖项、其安装时间和存储空间要求。
- [容器镜像大小](#docker-images)。
- 网络延迟和慢速连接。

频繁且不必要地失败的流水线也会导致开发生命周期变慢。您应该关注作业失败的问题模式：

- 随机失败或产生不可靠测试结果的不稳定单元测试。
- 测试覆盖率下降和代码质量与该行为相关。
- 可以安全忽略但会中断流水线的失败。
- 在长流水线结束时才失败的测试，但这些测试本可以放在更早的阶段，
  从而导致反馈延迟。

<a id="pipeline-analysis"></a>

## 流水线分析

分析您的流水线性能，以找到提高效率的方法。分析可以帮助识别 CI/CD 基础设施中可能的阻塞点。这包括分析：

- 作业负载。
- 执行时间中的瓶颈。
- 整体流水线架构。

理解和记录流水线工作流，并讨论可能的操作和更改非常重要。重构流水线可能需要 DevSecOps 生命周期中各团队之间的仔细协作。

流水线分析有助于识别成本效率问题。例如，使用付费云服务托管的 [Runner](../runners/_index.md) 可能预配了：

- 超出 CI/CD 流水线所需的资源，造成资金浪费。
- 资源不足，导致运行缓慢并浪费时间。

<a id="pipeline-insights"></a>

### 流水线洞察

[流水线成功率和时长图表](_index.md#pipeline-success-and-duration-charts)
提供有关流水线运行时间和失败作业数量的信息。

[单元测试](../testing/unit_test_reports.md)、集成测试、端到端测试、
[代码质量](../testing/code_quality.md) 测试等测试
确保 CI/CD 流水线能自动发现问题。可能涉及许多流水线阶段，从而导致运行时间过长。

您可以通过在同一阶段并行运行测试不同内容的作业来缩短运行时间，从而减少总体运行时间。缺点是您需要更多 Runner 同时运行以支持并行作业。

<a id="needs-dependency-visualization"></a>

### `needs` 依赖可视化

在 [完整流水线图](_index.md#group-jobs-by-stage-or-needs-configuration) 中查看 `needs` 依赖关系
有助于分析流水线中的关键路径并理解可能的阻塞点。

<a id="pipeline-monitoring"></a>

### 流水线监控

全局流水线健康状况是监控的关键指标，同时还要监控作业和流水线时长。
[CI/CD 分析](_index.md#pipeline-success-and-duration-charts) 提供
流水线健康状况的可视化表示。

实例管理员可以访问额外的 [性能指标和自监控](../../administration/monitoring/_index.md)。

您可以从 [API](../../api/rest/_index.md) 获取特定的流水线健康指标。
外部监控工具可以轮询 API 并验证流水线健康状况，或收集指标用于长期 SLA 分析。

例如，用于 Prometheus 的 [GitLab CI Pipelines Exporter](https://github.com/mvisonneau/gitlab-ci-pipelines-exporter)
从 API 和流水线事件获取指标。它可以自动检查项目中的分支，并获取流水线状态和时长。结合 Grafana 仪表板，这有助于为您的运维团队构建可操作的视图。指标图表还可以嵌入到事件中，使问题解决更容易。此外，它还可以导出有关作业和环境的指标。

如果您使用 GitLab CI Pipelines Exporter，应从 [示例配置](https://github.com/mvisonneau/gitlab-ci-pipelines-exporter/blob/main/docs/configuration_syntax.md) 开始。

![显示 CI 运行状态和历史统计信息（包括频率和失败率）的 Grafana 仪表板。](img/ci_efficiency_pipeline_health_grafana_dashboard_v19_3.png)

或者，您可以使用能够执行脚本的监控工具，例如
[`check_gitlab`](https://gitlab.com/6uellerBpanda/check_gitlab)。

<a id="runner-monitoring"></a>

#### Runner 监控

您还可以在其主机系统或 Kubernetes 等集群中 [监控 CI Runner](https://gitlab.cn/docs/runner/monitoring/)。
这包括检查：

- 磁盘和磁盘 IO
- CPU 使用率
- 内存
- Runner 进程资源

[Prometheus Node Exporter](https://prometheus.io/docs/guides/node-exporter/)
可以监控 Linux 主机上的 Runner，而 [`kube-state-metrics`](https://github.com/kubernetes/kube-state-metrics)
在 Kubernetes 集群中运行。

您还可以使用云提供商测试 [极狐GitLab Runner 自动扩缩](https://gitlab.cn/docs/runner/configuration/autoscale/)，
并定义离线时间以降低成本。

<a id="dashboards-and-incident-management"></a>

#### 仪表板和事件管理

使用您现有的监控工具和仪表板来集成 CI/CD 流水线监控，或从头开始构建。确保运行时数据在团队间可操作，以便运维/SRE 能尽早发现问题。
[事件管理](../../operations/incident_management/_index.md) 在这里也有帮助，
它带有嵌入式指标图表和所有有价值的细节来分析问题。

<a id="storage-usage"></a>

### 存储使用

审查以下内容的存储使用情况，以帮助分析成本与效率：

- [作业产物](../jobs/job_artifacts.md) 及其 [`expire_in`](../yaml/_index.md#artifactsexpire_in)
  配置。如果保留时间过长，存储使用量会增加，并可能拖慢流水线。
- [容器镜像仓库](../../user/packages/container_registry/_index.md) 使用情况。
- [软件包仓库](../../user/packages/package_registry/_index.md) 使用情况。

<a id="pipeline-configuration"></a>

## 流水线配置

配置流水线以加速流水线并减少资源使用时，请做出谨慎的选择。这包括利用极狐GitLab CI/CD 的内置功能，使流水线运行得更快、更高效。

<a id="reduce-how-often-jobs-run"></a>

### 减少作业运行频率

尝试找出哪些作业并非在所有情况下都需要运行，并使用流水线配置来阻止它们运行：

- 使用 [`interruptible`](../yaml/_index.md#interruptible) 关键字，在旧流水线
  被新流水线取代时停止它们。
- 使用 [`rules`](../yaml/_index.md#rules) 跳过不需要的测试。例如，
  仅更改前端代码时跳过后端测试。
- 降低非必要的 [定时流水线](schedules.md) 的运行频率。
- 将 [`cron` 计划](schedules.md#distribute-pipeline-schedules-to-prevent-system-load) 均匀分布在不同时间。

<a id="fail-fast"></a>

### 快速失败

确保在 CI/CD 流水线中尽早检测到错误。耗时很长的作业会阻止流水线在该作业完成前返回失败状态。

设计流水线时，应让可以 [快速失败](../testing/fail_fast_testing.md) 的作业
更早运行。例如，添加一个早期阶段，并将语法、样式 lint、Git 提交消息验证以及类似的作业移入其中。

决定让长作业提前运行是否重要，而不是优先考虑更快作业的快速反馈。最初的失败可能会清楚地表明流水线的其余部分不应运行，从而节省流水线资源。

<a id="needs-keyword"></a>

### `needs` 关键字

在基本配置中，作业总是等待早期阶段中的所有其他作业完成后才运行。这种配置最简单，但在大多数情况下也是最慢的。
[使用 `needs` 关键字的流水线](../yaml/needs.md) 和
[父/子流水线](downstream_pipelines.md#parent-child-pipelines) 更灵活，并且可能
更高效，但也可能使流水线更难理解和分析。

<a id="reuse-configuration-with-cicd-components"></a>

### 使用 CI/CD 组件复用配置

与其使用 [`include`](../yaml/includes.md) 复制流水线配置，不如使用
[CI/CD 组件](../components/_index.md) 在项目间复用经过测试的、带版本的配置。
您可以在 CI/CD Catalog 中找到已发布的组件。组件减少了维护重复配置同步的开销。

<a id="caching"></a>

### 缓存

另一种优化方法是 [缓存](../caching/_index.md) 依赖项。如果您的依赖项很少更改，缓存可以使流水线执行快得多。
有关 NodeJS、PHP、Python、Ruby 和 Go 的配置示例，请参阅
[缓存依赖项示例](../caching/examples.md#cache-dependencies)。

您可以使用 [`cache:when`](../yaml/_index.md#cachewhen) 在作业失败时
也缓存下载的依赖项。

<a id="docker-images"></a>

### Docker 镜像

下载和初始化 Docker 镜像可能占作业总运行时间的很大一部分。

如果 Docker 镜像拖慢了作业执行速度，请分析基础镜像大小以及与镜像仓库的网络连接。如果极狐GitLab 在云中运行，请寻找云厂商提供的云容器镜像仓库。此外，您还可以使用
[极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)，极狐GitLab 实例访问它
比其他镜像仓库更快。

<a id="optimize-docker-images"></a>

#### 优化 Docker 镜像

构建优化的 Docker 镜像，因为大型 Docker 镜像占用大量空间，并且在连接速度较慢时需要很长时间下载。如果可能，避免为所有作业使用一个大型镜像。使用多个较小的镜像，每个镜像用于特定任务，下载和运行速度更快。

尝试使用预装了软件的自定义 Docker 镜像。下载一个较大的预配置镜像通常比使用通用镜像并每次在其上安装
软件要快得多。Docker 的 [编写 Dockerfile 的最佳实践文章](https://docs.docker.com/build/building/best-practices/)
提供了有关构建高效 Docker 镜像的更多信息。

减小 Docker 镜像大小的方法：

- 使用小型基础镜像，例如 `debian-slim`。
- 使用 [distroless](https://github.com/GoogleContainerTools/distroless) 镜像，它
  仅包含您的应用程序及其运行时依赖项，没有包管理器、
  shell 或典型 Linux 发行版中的其他程序。
- 如果并非严格需要，请勿安装 vim 或 curl 等便利工具。
- 创建专用的开发镜像。
- 禁用软件包安装的 man 页面和文档以节省空间。
- 减少 `RUN` 层数并合并软件安装步骤。
- 使用 [多阶段构建](https://blog.alexellis.io/mutli-stage-docker-builds/)
  将使用构建器模式的多个 Dockerfile 合并为一个 Dockerfile，这可以减小镜像大小。
- 如果使用 `apt`，请添加 `--no-install-recommends` 以避免安装不必要的软件包。
- 最后清理不再需要的缓存和文件。例如，对于 Debian 和 Ubuntu，使用
  `rm -rf /var/lib/apt/lists/*`；对于 RHEL 和 CentOS，使用 `yum clean all`。
- 使用 [dive](https://github.com/wagoodman/dive) 或 [Slim Toolkit](https://github.com/slimtoolkit/slim)
  等工具来分析和缩减镜像。

为简化 Docker 镜像管理，您可以创建一个专用群组来管理
[Docker 镜像](../docker/_index.md)，并使用 CI/CD 流水线进行测试、构建和发布。

<a id="test-document-and-learn"></a>

## 测试、记录和学习

改进流水线是一个迭代过程。进行小改动，监控效果，然后再次迭代。许多小的改进可以累积成流水线效率的大幅提升。

记录流水线设计和架构会有所帮助。您可以直接在极狐GitLab
代码仓库中使用 [Markdown 中的 Mermaid 图表](../../user/markdown.md#mermaid) 来做到这一点。

在议题中记录 CI/CD 流水线问题和事件，包括已完成的研究和找到的解决方案。这有助于新团队成员快速上手，也有助于识别 CI 流水线效率方面反复出现的问题。
