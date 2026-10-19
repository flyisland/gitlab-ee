---
stage: GitLab Delivery
group: Release and Deploy
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 发布与维护策略
description: 版本支持、发布节奏和向后移植策略。
---

发布与部署团队是维护策略的所有者，任何请求的更新都必须经其批准。这遵循我们的 DRI 模型，旨在确保客户的可预测性。

极狐GitLab 对主要、次要和补丁版本的版本命名和发布节奏有严格的策略。新版本会在 [GitLab 博客](https://about.gitlab.com/releases/categories/releases/)上公布。

我们当前的策略是：

- 在任何给定时间，仅为当前稳定版本向后移植缺陷修复——请参阅下方的[补丁版本](#patch-releases)。
- 除当前稳定版本外，还会将安全修复向后移植到前两个月度版本。在某些情况下（详见下方的[补丁版本](#patch-releases)），我们可能仅针对当前稳定版本处理安全漏洞，或在常规月度发布流程中处理，而不进行向后移植。

在极少数情况下，可能会批准例外，允许向后移植到超过最近两个月度版本。所需流程请参阅[策略例外](#policy-exceptions)。

<a id="versioning"></a>

## 版本命名

极狐GitLab 的版本采用[语义化版本](https://semver.org/)：
`(Major).(Minor).(Patch)`。

例如，对于极狐GitLab 版本 18.3.2：

- `18` 表示主要版本。主要版本为 18.0.0，但通常称为 18.0。
- `3` 表示次要版本。次要版本为 18.3.0，但通常称为 18.3。
- `2` 表示补丁号。

版本号的任何部分都可以递增为多位数，例如 18.3.11。

下表描述了版本类型及其发布节奏：

| 版本类型 | 描述 | 节奏 |
|:-------------|:------------|:--------|
| 主要版本        | 用于重大变更，或向公共 API 引入任何不向后兼容的变更时。 | 每年一次。下一个主要版本是极狐GitLab 20.0，计划于 2027 年 5 月 20 日发布。极狐GitLab 默认将[主要版本安排在](https://handbook.gitlab.com/handbook/engineering/releases/monthly-releases/)每年 5 月。 |
| 次要版本        | 用于向公共 API 引入新的向后兼容功能、引入次要功能，或推出一组较小的功能时。 | 每月一次，安排在每月第三个星期四。 |
| 补丁版本        | 用于修复错误行为的向后兼容缺陷修复。请参阅[补丁版本](#patch-releases)。 | 每月两次，分别安排在月度次要版本前一周的星期三和后一周的星期三。 |

<!-- Do not edit the following section without consulting the Technical Writing team -->

<!-- vale gitlab_base.CurrentStatus = NO -->

<a id="maintained-versions"></a>

## 维护中的版本

以下极狐GitLab 发布版本目前处于维护状态：

{{< maintained-versions >}}

<!-- vale gitlab_base.CurrentStatus = YES -->

<!-- END -->

> [!note]
> GitLab 团队成员如需了解即将发布的补丁版本的维护版本，请参阅内部 `delivery: Release Information` Grafana 仪表板中 `Patch Release Information` 部分下的 [`Release Versions` 面板](https://dashboards.gitlab.net/goto/h228fPEHR?orgId=1)。
> 当生效的月度发布日期早于生效的补丁发布日期时，版本会与上方的维护版本列表不同。
>
> 缺陷修复的向后移植针对当前（第一个）版本进行维护，安全修复的向后移植针对所有版本进行维护。

<a id="upgrade-recommendations"></a>

## 升级建议

我们鼓励所有人运行[最新稳定版本](https://about.gitlab.com/releases/categories/releases/)，以确保您可以升级到最安全、功能最丰富的极狐GitLab 体验。为确保您能运行最新的稳定版本，我们正在努力保持更新流程的可靠性。

如果您无法遵循我们的月度发布周期，需要考虑几种情况。请遵循[升级路径指南](../update/upgrade_paths.md)在版本之间安全升级。

Linux 软件包的版本特定变更文档可在此处获取：

- [极狐GitLab 17](../update/versions/gitlab_17_changes.md)
- [极狐GitLab 16](../update/versions/gitlab_16_changes.md)
- [极狐GitLab 15](../update/versions/gitlab_15_changes.md)

有关在本地下载 Linux 软件包并[手动安装](../update/package/_index.md#upgrade-with-a-downloaded-package)的说明可供参考。

[升级 Linux 软件包内置的 PostgreSQL 的分步指南另有文档说明](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="upgrading-major-versions"></a>

## 升级主要版本

不向后兼容的变更和迁移仅保留给主要版本。更多信息，请参阅[创建极狐GitLab 升级计划](../update/plan_your_upgrade.md)。

<a id="patch-releases"></a>

## 补丁版本

补丁版本包含针对极狐GitLab 当前稳定发布版本的缺陷修复，以及针对当前稳定版本和前两个月度版本的安全修复。

制定这些策略的原因如下：

1. 极狐GitLab 有基础版和企业版两种发行版，使测试/发布软件所需的工作量翻倍。
1. 向后移植到较旧版本会产生高昂的开发、质量保证和支持成本。
1. 支持并行版本会阻碍增量升级，而增量升级会随时间累积复杂性，给所有用户带来升级挑战。极狐GitLab 有专门的团队确保增量升级（和安装）尽可能简单。
1. 极狐GitLab 应用程序中产生的变更数量很多，这增加了向后移植到较旧版本的复杂性。在许多情况下，向后移植必须经过与新变更相同的评审流程。
1. 在某些情况下，确保测试在较旧版本上通过是一项相当大的挑战，因此非常耗时。

在补丁版本中包含新功能是不可能的，因为这会破坏[语义化版本](https://semver.org/)。破坏[语义化版本](https://semver.org/)会对必须遵守各种内部要求（例如组织合规、验证新功能等）的用户产生以下后果：

1. 无法快速升级以利用补丁版本中包含的缺陷修复。
1. 无法快速升级以利用补丁版本中包含的安全修复。
1. 要求不仅对稳定版极狐GitLab 进行大量测试，还要对每个补丁版本进行大量测试。

对于非常严重的安全问题，已有[先例](https://about.gitlab.com/releases/2016/05/02/cve-2016-4340-patches/)将安全修复向后移植到更多以前的极狐GitLab 发布版本。所需流程请参阅[策略例外](#policy-exceptions)。

在某些情况下，我们可能选择通过常规月度发布流程处理漏洞，仅更新生效版本和当前稳定版本，而不进行向后移植。影响此决定的因素包括被利用的可能性极低、漏洞影响较小、安全修复的复杂性以及最终对稳定性的风险。我们始终通过补丁版本处理高危及严重安全问题。

<a id="policy-exceptions"></a>

## 策略例外

在特殊情况下，可能需要偏离此维护策略。这包括请求将修复向后移植到标准策略覆盖范围之外的较旧版本，以及偏离[发布原则](https://handbook.gitlab.com/handbook/engineering/releases/#what-each-release-type-contains)。严重性 3 及更低的请求会自动被拒绝。

如需请求策略例外，请遵循[例外流程](https://handbook.gitlab.com/handbook/engineering/releases/#exception-process)指南。

[发布例外流程](https://handbook.gitlab.com/handbook/engineering/releases/#exception-process)描述了请求策略例外的指南。例外由作为策略所有者的[发布经理](https://about.gitlab.com/community/release-managers/)酌情批准，并受 [SLO 承诺](https://handbook.gitlab.com/handbook/engineering/releases/patch-releases/#slo-commitments)约束。

<a id="more-information"></a>

## 更多信息

您可能还想阅读我们的：

- [发布文档](https://gitlab.com/gitlab-org/release/docs)，其中描述了发布流程
- 开发文档中的弃用指南。
- [负责任披露策略](https://about.gitlab.com/security/disclosure/)
