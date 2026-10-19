---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 托管的 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用极狐GitLab 托管的 Runner 在 JihuLab.com 上运行您的 CI/CD 作业。
这些 Runner 可以在不同环境中构建、测试和部署应用程序。

要创建并注册您自己的 Runner，请参阅[私有化部署 Runner](https://gitlab.cn/docs/runner/)。

<a id="hosted-runners-for-gitlabcom"></a>

## JihuLab.com 的托管 Runner

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

这些 Runner 与 JihuLab.com 完全集成，默认对所有项目启用，无需任何配置。您的作业可以运行在：

- [Linux 上的托管 Runner](linux.md)。
- [启用 GPU 的托管 Runner](gpu_enabled.md)。
- [Windows 上的托管 Runner](windows.md)（[测试版](../../../policy/development_stages_support.md#beta)）。
- [macOS 上的托管 Runner](macos.md)（[测试版](../../../policy/development_stages_support.md#beta)）。

<a id="gitlabcom-hosted-runner-workflow"></a>

### JihuLab.com 托管 Runner 工作流

使用托管 Runner 时：

- 您的每个作业都在新预配的虚拟机中运行，该虚拟机专用于该特定作业。
- 运行您作业的虚拟机拥有免密码的 `sudo` 访问权限。
- 存储空间由操作系统、预装软件的容器镜像以及您克隆的代码仓库副本共享。
  这意味着您的作业可用的空闲磁盘空间会减少。
- [未打标签](../../yaml/_index.md#tags)的作业在 `small` Linux x86-64 Runner 上运行。

> [!note]
> 由 JihuLab.com 上的托管 Runner 处理的作业会在 3 小时后超时，无论项目中配置的超时时间是多少。

<a id="security-of-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 的安全性

以下部分概述了用于强化极狐GitLab Runner 构建环境安全性的额外内置防护层。

JihuLab.com 的托管 Runner 配置如下：

- 防火墙规则仅允许从临时虚拟机到公共互联网的出站通信。
- 不允许从公共互联网到临时虚拟机的入站通信。
- 防火墙规则不允许虚拟机之间通信。
- 允许到临时虚拟机的唯一内部通信来自 Runner 管理器。
- 临时 Runner 虚拟机只服务单个作业，并在作业执行完成后立即删除。

<a id="architecture-diagram-of-hosted-runners-for-gitlabcom"></a>

#### JihuLab.com 托管 Runner 的架构图

下图展示了 JihuLab.com 托管 Runner 的架构图

![JihuLab.com 托管 Runner 架构](img/gitlab-hosted_runners_architecture_v17_0.png)

有关 Runner 如何认证并执行作业负载的更多信息，请参阅 [Runner 执行流程](https://gitlab.cn/docs/runner/#runner-execution-flow)。

<a id="job-isolation-of-hosted-runners-for-gitlabcom"></a>

#### JihuLab.com 托管 Runner 的作业隔离

除了在网络层面隔离 Runner 之外，每个临时 Runner 虚拟机只服务单个作业，并在作业执行完成后立即删除。在以下示例中，三个作业在项目的流水线中执行。每个作业都在专用的临时虚拟机中运行。

![在各自隔离的虚拟机上运行的 CI/CD 流水线阶段：构建、测试、部署。](img/build_isolation_v17_9.png)

构建作业在 `runner-ns46nmmj-project-43717858` 上运行，测试作业在 `f131a6a2runner-new2m-od-project-43717858` 上运行，部署作业在 `runner-tmand5m-project-43717858` 上运行。

CI 作业完成后，极狐GitLab 会立即向 Google Compute API 发送删除临时 Runner 虚拟机的命令。[Google Compute Engine 虚拟机监控程序](https://cloud.google.com/blog/products/gcp/7-ways-we-harden-our-kvm-hypervisor-at-google-cloud-security-in-plaintext)接管安全删除虚拟机及相关数据的任务。

有关 JihuLab.com 托管 Runner 安全性的更多信息，请参阅：

- [Google Cloud 基础设施安全设计概览白皮书](https://docs.cloud.google.com/docs/security/infrastructure/design/resources/google_infrastructure_whitepaper_fa.pdf)
- [GitLab 信任中心](https://about.gitlab.com/security/)
- GitLab 安全合规控制措施

<a id="caching-on-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 上的缓存

托管 Runner 共享一个存储在 Google Cloud Storage (GCS) 存储桶中的[分布式缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)。
根据[对象生命周期管理策略](https://docs.cloud.google.com/storage/docs/lifecycle)，最近 14 天内未更新的缓存内容会被自动删除。缓存变为压缩归档后，上传的缓存产物最大可为 5 GB。

有关缓存工作原理的更多信息，请参阅 [JihuLab.com 托管 Runner 的架构图](#architecture-diagram-of-hosted-runners-for-gitlabcom)和[极狐GitLab CI/CD 中的缓存](../../caching/_index.md)。

<a id="pricing-of-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 的定价

在 JihuLab.com 托管 Runner 上运行的作业会消耗分配给您的命名空间的[计算分钟](../../pipelines/compute_minutes.md)。您可以在这些 Runner 上使用的分钟数取决于您的[订阅计划](https://gitlab.cn/pricing)中包含的计算分钟，或[额外购买的计算分钟](../../../subscriptions/gitlab_com/compute_minutes.md)。

有关按大小应用于机器类型的成本系数的更多信息，请参阅[成本系数](../../pipelines/compute_minutes.md#cost-factors-of-hosted-runners-for-gitlabcom)。

<a id="slo--release-cycle-for-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 的 SLO 与发布周期

SLO 目标是让 90% 的 CI/CD 作业在 120 秒或更短时间内开始执行。错误率应低于 0.5%。

极狐GitLab 的目标是在[极狐GitLab Runner](https://gitlab.cn/docs/runner/#gitlab-runner-versions) 发布后一周内更新到最新版本。您可以在[弃用和移除](../../../update/deprecations.md)中找到所有极狐GitLab Runner 破坏性变更。

<a id="hosted-runners-for-gitlab-community-contributions"></a>

## 面向 GitLab 社区贡献的托管 Runner

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

如果您想[为 GitLab 贡献](https://about.gitlab.com/community/contribute/)，作业会由 `gitlab-shared-runners-manager-X.gitlab.com` Runner 集群接收，该集群专用于 GitLab 项目及相关的社区复刻。

这些 Runner 使用的机器类型与我们的 `small` Linux x86-64 Runner 相同。
与 JihuLab.com 的托管 Runner 不同，面向 GitLab 社区贡献的托管 Runner 最多可重复使用 40 次。

因为鼓励所有人参与贡献，这些 Runner 免费使用。

<a id="supported-image-lifecycle"></a>

## 支持的镜像生命周期

macOS 和 Windows 上的托管 Runner 只能在受支持的镜像上运行作业。您不能自带镜像。受支持的镜像具有以下生命周期：

<a id="beta"></a>

### 测试版

新镜像以测试版形式发布。这使我们能够收集反馈，并在正式发布前解决潜在问题。在测试版镜像上运行的任何作业都不在服务级别协议的覆盖范围内。如果您使用测试版镜像，可以通过创建议题来提供反馈。

<a id="general-availability"></a>

### 正式发布

镜像在完成测试阶段并被认为稳定后即正式发布。要正式发布，镜像必须满足以下要求：

- 通过解决所有已报告的重大缺陷成功完成测试阶段
- 已安装软件与底层操作系统兼容

在正式发布的镜像上运行的作业受已定义的服务级别协议覆盖。

<a id="deprecated"></a>

### 已弃用

一次最多支持两个正式发布的镜像。新的正式发布镜像发布后，最旧的正式发布镜像即被弃用。已弃用的镜像不再更新，并会在 3 个月后删除。
