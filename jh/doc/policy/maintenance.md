---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 发布和维护策略
description: Version support, release cadence, and backporting policies.
---

发布和部署团队是维护策略的所有者，必须批准任何请求的更新。这遵循我们的 DRI 模型，旨在确保客户的可预测性。

极狐GitLab 对主要、次要和补丁版本的版本命名和发布节奏有严格的政策。新版本在[极狐GitLab 博客](https://gitlab.cn/releases/categories/releases/)上公布。

我们目前的政策是：

- 在任何给定时间，**仅为当前稳定版本**向后移植错误修复 - 请参阅下面的[补丁版本](#patch-releases)。
- 将安全修复向后移植**到前两个月度版本以及当前稳定版本**。在某些情况下（在下面的[补丁版本](#patch-releases)中概述），我们可能仅针对当前稳定版本或在常规月度发布过程中解决安全漏洞，而不进行向后移植。

在极少数情况下，可能会批准例外，向后移植到超过最近两个月度版本。有关所需流程，请参阅[策略例外](#policy-exceptions)。

<a id="versioning"></a>

## 版本管理

极狐GitLab 对其发布使用[语义化版本](https://semver.org/)：`(Major).(Minor).(Patch)`。

例如，对于极狐GitLab 版本 18.3.2：

- `18` 代表主版本。主版本是 18.0.0，但通常称为 18.0。
- `3` 代表次要版本。次要版本是 18.3.0，但通常称为 18.3。
- `2` 代表补丁号。

版本号的任何部分都可以递增到多位数字，例如 18.3.11。

下表描述了版本类型及其发布频率：

| 版本类型 | 描述 | 发布频率 |
|:-------------|:------------|:--------|
| 主版本        | 用于重大变更，或当公共 API 引入任何向后不兼容的变更时。 | 每年一次。下一个主版本是极狐GitLab 19.0，计划于 2026 年 5 月 21 日发布。极狐GitLab 默认将[主版本安排在每年 5 月](https://gitlab.cn/releases/)。 |
| 次要版本        | 当公共 API 引入新的向后兼容功能、引入次要功能或推出一组较小功能时。 | 每月一次，安排在每月的第三个周四。 |
| 补丁版本        | 用于向后兼容的错误修复，修复不正确的行为。参见[补丁版本](#patch-releases)。 | 每月两次，安排在月度次要版本发布前一周的周三和发布后一周的周三。 |

<!-- Do not edit the following section without consulting the Technical Writing team -->

<!-- vale gitlab_base.CurrentStatus = NO -->

<a id="maintained-versions"></a>

## 维护的版本

目前维护以下极狐GitLab 发布版本：

{{< maintained-versions >}}

<!-- vale gitlab_base.CurrentStatus = YES -->

<!-- END -->

> [!note]
> 对于需要查找即将发布的补丁版本维护版本的极狐GitLab 团队成员，请参考内部 `delivery: Release Information` Grafana 仪表板中 `补丁发布信息` 部分下的 [`发布版本` 面板](https://dashboards.gitlab.net/goto/h228fPEHR?orgId=1)。
> 当活跃的月度发布日期早于活跃的补丁发布日期时，版本与上述维护版本列表不同。
>
> 错误修复向后移植维护当前（第一个）版本，安全修复向后移植维护所有版本。

<a id="upgrade-recommendations"></a>

## 升级建议

我们鼓励所有人运行[最新的稳定版本](https://gitlab.cn/releases/categories/releases/)，以确保你可以升级到最安全、功能最丰富的极狐GitLab 体验。为了确保你能运行最新的稳定版本，我们正在努力保持更新过程的可靠性。

如果你无法遵循我们的月度发布周期，则必须考虑几种情况。请遵循[升级路径指南](../update/upgrade_paths.md)在版本之间安全升级。

Linux 软件包的版本特定变更文档可用于：

- [极狐GitLab 17](../update/versions/gitlab_17_changes.md)
- [极狐GitLab 16](../update/versions/gitlab_16_changes.md)
- [极狐GitLab 15](../update/versions/gitlab_15_changes.md)

提供了本地下载 Linux 软件包并[手动安装](../update/package/_index.md#upgrade-with-a-downloaded-package)的说明。

[升级 Linux 软件包自带的 PostgreSQL 的分步指南另有文档说明](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="upgrading-major-versions"></a>

## 升级主版本

向后不兼容的变更和迁移保留给主版本。有关更多信息，请参阅[创建极狐GitLab 升级计划](../update/plan_your_upgrade.md)。

<a id="patch-releases"></a>

## 补丁版本

补丁版本包括针对极狐GitLab 当前稳定发布版本的**错误修复**，以及针对前两个月度版本和当前稳定版本的**安全修复**。

这些政策到位的原因如下：

1. 极狐GitLab 有基础版和旗舰版发行版，使得测试/发布软件的工作量翻倍。
1. 向旧版本向后移植会产生高昂的开发、质量保证和支持成本。
1. 支持并行版本会阻碍增量升级，随着时间的推移，增量升级会累积复杂性，给所有用户带来升级挑战。极狐GitLab 有一个专门团队，确保增量升级（和安装）尽可能简单。
1. 极狐GitLab 应用程序中创建的变更数量很高，这增加了向旧版本向后移植的复杂性。在几种情况下，向后移植必须经过与新变更相同的审查过程。
1. 在某些情况下，确保测试在旧版本上通过是一个相当大的挑战，因此非常耗时。

在补丁版本中包含新功能是不可能的，因为这会破坏[语义化版本](https://semver.org/)。破坏[语义化版本](https://semver.org/)会对必须遵守各种内部要求（例如，组织合规性、验证新功能等）的用户产生以下后果：

1. 无法快速升级以利用补丁版本中包含的错误修复。
1. 无法快速升级以利用补丁版本中包含的安全修复。
1. 要求不仅对稳定的极狐GitLab 版本进行广泛测试，还要对每个补丁版本进行广泛测试。

对于高度严重的安全问题，有[先例](https://gitlab.cn/releases/2016/05/02/cve-2016-4340-patches/)将安全修复向后移植到更多以前的极狐GitLab 发布版本。有关所需流程，请参阅[策略例外](#policy-exceptions)。

在某些情况下，我们可能选择使用常规月度发布过程来解决漏洞，仅更新活跃和当前稳定版本，而不进行向后移植。影响此决定的因素包括利用的可能性非常低、漏洞的影响低、安全修复的复杂性以及最终的稳定性风险。我们始终通过补丁版本解决高危和严重安全问题。

<a id="policy-exceptions"></a>

## 策略例外

在特殊情况下，可能需要偏离此维护策略。这包括请求将修复向后移植到比标准策略所涵盖的版本更早的版本，以及偏离[发布原则](https://handbook.gitlab.com/handbook/engineering/releases/#what-each-release-type-contains)。严重性 3 及更低的请求会自动被拒绝。

要请求策略例外，请遵循[例外流程](https://handbook.gitlab.com/handbook/engineering/releases/#exception-process)指南。

[发布例外流程](https://handbook.gitlab.com/handbook/engineering/releases/#exception-process)描述了请求策略例外的指南。例外由作为策略所有者的[发布经理](https://gitlab.cn/community/release-managers/)酌情授予，并受 [SLO 承诺](https://handbook.gitlab.com/handbook/engineering/releases/patch-releases/#slo-commitments)的约束。

<a id="more-information"></a>

## 更多信息

你可能还想阅读我们的：

- [发布文档](https://jihulab.com/gitlab-cn/release/docs)，描述了发布程序
- 开发文档中的弃用指南。
- [负责任的披露政策](https://gitlab.cn/security/disclosure/)