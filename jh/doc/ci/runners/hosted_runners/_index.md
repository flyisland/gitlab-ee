---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 托管 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用极狐GitLab 托管 Runner 在 JihuLab.com 上运行您的 CI/CD 作业。
这些 Runner 可以在不同环境中构建、测试和部署应用程序。

要创建和注册您自己的 Runner，请参见[私有化部署 Runner](https://gitlab.cn/docs/runner/)。

<a id="hosted-runners-for-gitlabcom"></a>

## JihuLab.com 上的托管 Runner

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

这些 Runner 与 JihuLab.com 完全集成，默认情况下为所有项目启用，无需配置。
您的作业可以在以下环境中运行：

- [Linux 上的托管 Runner](linux.md)。
- [启用 GPU 的托管 Runner](gpu_enabled.md)。
- [Windows 上的托管 Runner](windows.md)（[测试版](../../../policy/development_stages_support.md#beta)）。
- [macOS 上的托管 Runner](macos.md)（[测试版](../../../policy/development_stages_support.md#beta)）。

<a id="gitlabcom-hosted-runner-workflow"></a>

### JihuLab.com 托管 Runner 工作流程

当您使用托管 Runner 时：

- 您的每个作业都在一个新配置的虚拟机中运行，该虚拟机专用于特定作业。
- 运行作业的虚拟机具有无密码的 `sudo` 访问权限。
- 存储由操作系统、包含预装软件的容器镜像以及您克隆的仓库副本共享。
  这意味着您的作业可用的空闲磁盘空间会减少。
- [未标记](../../yaml/_index.md#tags)的作业在 `small` Linux x86-64 Runner 上运行。

> [!note]
> 无论项目中配置的超时时间如何，JihuLab.com 上由托管 Runner 处理的作业都会在 3 小时后超时。

<a id="security-of-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 的安全性

以下部分概述了增强极狐GitLab Runner 构建环境安全性的额外内置层。

JihuLab.com 的托管 Runner 配置如下：

- 防火墙规则仅允许从临时虚拟机到公共互联网的出站通信。
- 不允许从公共互联网到临时虚拟机的入站通信。
- 防火墙规则不允许虚拟机之间的通信。
- 允许到临时虚拟机的唯一内部通信来自 Runner 管理器。
- 临时 Runner 虚拟机仅服务于单个作业，并在作业执行后立即删除。

<a id="architecture-diagram-of-hosted-runners-for-gitlabcom"></a>

#### JihuLab.com 托管 Runner 架构图

下图显示了 JihuLab.com 托管 Runner 的架构图

![JihuLab.com 托管 Runner 架构](img/gitlab-hosted_runners_architecture_v17_0.png)

有关 Runner 如何认证和执行作业负载的更多信息，请参见[Runner 执行流程](https://gitlab.cn/docs/runner/#runner-execution-flow)。

<a id="job-isolation-of-hosted-runners-for-gitlabcom"></a>

#### JihuLab.com 托管 Runner 的作业隔离

除了在网络上隔离 Runner 之外，每个临时 Runner 虚拟机仅服务于单个作业，并在作业执行后立即删除。
在以下示例中，一个项目的流水线中执行了三个作业。每个作业都在专用的临时虚拟机中运行。

![CI/CD 流水线阶段在独立的隔离虚拟机上运行：构建、测试、部署。](img/build_isolation_v17_9.png)

构建作业在 `runner-ns46nmmj-project-43717858` 上运行，测试作业在 `f131a6a2runner-new2m-od-project-43717858` 上运行，部署作业在 `runner-tmand5m-project-43717858` 上运行。

极狐GitLab 在 CI 作业完成后立即向 Google Compute API 发送删除临时 Runner 虚拟机的命令。Google Compute Engine 虚拟机管理程序负责安全删除虚拟机及相关数据。

有关 JihuLab.com 托管 Runner 安全性的更多信息，请参见：

- [极狐GitLab 信任中心](https://gitlab.cn/security/)
- 极狐GitLab 安全合规控制

<a id="pricing-of-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 的定价

在 JihuLab.com 托管 Runner 上运行的作业会消耗分配给您的命名空间的[计算分钟](../../pipelines/compute_minutes.md)。
您可以在这些 Runner 上使用的分钟数取决于您的[订阅计划](https://gitlab.cn/pricing/)中包含的计算分钟数或[额外购买的计算分钟](../../../subscriptions/gitlab_com/compute_minutes.md)。

有关基于大小的机器类型所应用的成本系数的更多信息，请参见[成本系数](../../pipelines/compute_minutes.md#cost-factors-of-hosted-runners-for-gitlabcom)。

<a id="slo--release-cycle-for-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 托管 Runner 的 SLO 和发布周期

SLO 目标是让 90% 的 CI/CD 作业在 120 秒或更短时间内开始执行。错误率应低于 0.5%。

极狐GitLab 的目标是在[极狐GitLab Runner](https://gitlab.cn/docs/runner/#gitlab-runner-versions)发布后一周内更新到最新版本。
您可以在[弃用和移除](../../../update/deprecations.md)中找到所有极狐GitLab Runner 的重大变更。

<a id="hosted-runners-for-gitlab-community-contributions"></a>

## 极狐GitLab 社区贡献的托管 Runner

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

如果您想[为极狐GitLab 做贡献](https://gitlab.cn/community/contribute/)，作业将由专用于极狐GitLab 项目和相关社区分支的 `gitlab-shared-runners-manager-X.jihulab.com` Runner 队列处理。

这些 Runner 由与我们 `small` Linux x86-64 Runner 相同的机器类型支持。
与 JihuLab.com 的托管 Runner 不同，极狐GitLab 社区贡献的托管 Runner 最多可重复使用 40 次。

由于鼓励每个人做出贡献，这些 Runner 是免费的。

<a id="supported-image-lifecycle"></a>

## 支持的镜像生命周期

macOS 和 Windows 上的托管 Runner 只能在受支持的镜像上运行作业。您不能自带镜像。
受支持的镜像具有以下生命周期：

<a id="beta"></a>

### 测试版

新镜像作为测试版发布。这使我们能够在正式发布之前收集反馈并解决潜在问题。
在测试版镜像上运行的任何作业均不在服务等级协议涵盖范围内。
如果您使用测试版镜像，可以通过创建议题来提供反馈。

<a id="general-availability"></a>

### 正式发布

镜像在完成测试阶段并被认为稳定后正式发布。
要正式发布，镜像必须满足以下要求：

- 通过解决所有报告的重大错误，成功完成测试阶段
- 已安装软件与底层操作系统的兼容性

在正式发布镜像上运行的作业受定义的服务等级协议涵盖。

<a id="deprecated"></a>

### 已弃用

一次最多支持两个正式发布镜像。在新的正式发布镜像发布后，
最旧的正式发布镜像将变为已弃用。已弃用的镜像不再更新，并在 3 个月后删除。