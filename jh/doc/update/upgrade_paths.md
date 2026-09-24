---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: "规划升级路径"
description: Latest version instructions.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级路径涉及从当前极狐GitLab版本升级到您想要升级到的极狐GitLab版本所需的步骤。要确定您的升级路径：

1. 注意当前版本在升级路径中的位置，包括必需的升级停靠点。
1. 参考[极狐GitLab 升级说明](versions/_index.md)。

即使未明确指定，也应将极狐GitLab升级到 `major`.`minor` 发布的最新可用补丁版本，而不是第一个补丁版本。例如，升级到 `16.8.7` 而不是 `16.8.0`。

某些 `major`.`minor` 版本是某些或所有环境的必需停靠点，因为这些版本中包含与升级过程相关的修复。

<a id="required-upgrade-stops"></a>

## 必需的升级停靠点

升级路径包括必需的升级停靠点，这些是您在升级到更高版本之前必须升级到的极狐GitLab版本。沿升级路径进行时：

1. 升级到当前版本之后的必需升级停靠点。
1. 等待升级的后台迁移完成。
1. 升级到下一个必需的升级停靠点。

在极狐GitLab 17.5 及更高版本中，为了为实例管理员提供可预测的升级计划，必需的升级停靠点位于版本 `x.2.z`、`x.5.z`、`x.8.z` 和 `x.11.z`。

要检查特定次要版本可用的补丁版本，您可以在[极狐GitLab 软件包仓库](https://packages.gitlab.cn/ui/browse/gitlab)中搜索该次要版本。

如果您正在升级极狐GitLab Helm chart 实例，请参阅[极狐GitLab Helm chart 映射列表](https://gitlab.cn/docs/charts/installation/version_mappings/#previous-chart-versions)。

<a id="required-gitlab-18-upgrade-stops"></a>

### 必需的极狐GitLab 18 升级停靠点

必需的升级停靠点位于版本 `18.2`、`18.5`、`18.8` 和 `18.11`。

在升级到更高版本之前，您必须先升级到极狐GitLab 18 的这些版本。对于您要升级到的每个版本，请参阅[极狐GitLab 18 的升级说明](versions/gitlab_18_changes.md)。如果某个版本不在升级说明中，则说明该版本没有需要特别注意的内容。

在极狐GitLab 软件包仓库中查找补丁版本。例如，要搜索适用于 Ubuntu 24.04 的最新极狐GitLab 18.2 企业版版本：

1. 前往 <https://packages.gitlab.cn/ui/browse/gitlab/gitlab-jh/ubuntu/noble/pool/main/g/gitlab-ee>。
1. 输入 `18.2` 作为搜索词。

<a id="required-gitlab-17-upgrade-stops"></a>

### 必需的极狐GitLab 17 升级停靠点

在升级到更高版本之前，您必须先升级到这些极狐GitLab 17 版本。

| 必需版本 | 备注 |
|:-----------------|:------|
| 17.11.7          | 升级到最新的极狐GitLab 17.11 补丁版本。参见 [极狐GitLab 17.11.0 的升级说明](versions/gitlab_17_changes.md#upgrades-to-17110)。 |
| 17.8.7           | 升级到最新的极狐GitLab 17.8 补丁版本。参见 [极狐GitLab 17.8.0 的升级说明](versions/gitlab_17_changes.md#upgrades-to-1780)。 |
| 17.5.5           | 升级到最新的极狐GitLab 17.5 补丁版本。参见 [极狐GitLab 17.5.0 的升级说明](versions/gitlab_17_changes.md#upgrades-to-1750)。 |
| 17.3.7           | 升级到最新的极狐GitLab 17.3 版本。参见 [极狐GitLab 17.3.0 的升级说明](versions/gitlab_17_changes.md#upgrades-to-1730)。 |
| 17.1.8           | 仅适用于具有[大型 `ci_pipeline_messages` 表](versions/gitlab_17_changes.md#long-running-pipeline-messages-data-change)的实例。参见 [极狐GitLab 17.1.0 的升级说明](versions/gitlab_17_changes.md#upgrades-to-1710)。 |

<a id="required-gitlab-16-upgrade-stops"></a>

### 必需的极狐GitLab 16 升级停靠点

在升级到更高版本之前，您必须先升级到这些极狐GitLab 16 版本。

| 必需版本 | 备注 |
|:-----------------|:------|
| 16.11.10         | 参见 [极狐GitLab 16.11.0 的升级说明](versions/gitlab_16_changes.md#16110)。 |
| 16.7.10          | 参见 [极狐GitLab 16.8.0 的升级说明](versions/gitlab_16_changes.md#1670) 及更高版本的极狐GitLab 16.7 版本。 |
| 16.3.9           | 参见 [极狐GitLab 16.3.0 的升级说明](versions/gitlab_16_changes.md#1630) 及更高版本的极狐GitLab 16.3 版本。 |
| 16.2.11          | 仅适用于具有[大型流水线变量历史](versions/gitlab_16_changes.md#1630)的极狐GitLab 实例。参见 [极狐GitLab 16.2.0 的升级说明](versions/gitlab_16_changes.md#1620)。 |
| 16.1.8           | 仅适用于[在其软件包仓库中有 NPM 包的极狐GitLab 实例](versions/gitlab_16_changes.md#1610)。参见 [极狐GitLab 16.1.0 的升级说明](versions/gitlab_16_changes.md#1610)。 |
| 16.0.10          | 仅适用于具有[大量用户](versions/gitlab_16_changes.md#long-running-user-type-data-change)或[大型流水线变量历史](versions/gitlab_16_changes.md#1610)的极狐GitLab 实例。参见 [极狐GitLab 16.0.0 的升级说明](versions/gitlab_16_changes.md#1600) 及更高版本的极狐GitLab 16.0 版本。 |

<a id="required-gitlab-15-upgrade-stops"></a>

### 必需的极狐GitLab 15 升级停靠点

在升级到更高版本之前，您必须先升级到这些极狐GitLab 15 版本。

| 必需版本 | 备注 |
|:-----------------|:------|
| 15.11.13         | 参见 [极狐GitLab 15.11.0 的升级说明](versions/gitlab_15_changes.md#15110) 及更高版本的极狐GitLab 15.11 版本。 |
| 15.4.6           | 参见 [极狐GitLab 15.4.0 的升级说明](versions/gitlab_15_changes.md#1540) 及更高版本的极狐GitLab 15.4 版本。 |
| 15.1.6           | 仅适用于具有多个 Web 节点的极狐GitLab 实例。参见 [极狐GitLab 15.1.0 的升级说明](versions/gitlab_15_changes.md#1510)。 |
| 15.0.5           | 参见 [极狐GitLab 15.0 的升级说明](versions/gitlab_15_changes.md#1500)。 |

<a id="upgrade-path-tool"></a>

## 升级路径工具

要快速计算基于您当前和所需目标极狐GitLab版本的升级停靠点，请参见[升级路径工具](https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/)。该工具由极狐GitLab 支持团队维护。

要分享反馈并帮助改进该工具，请在 [`upgrade-path` 项目](https://jihulab.com/gitlab-com/support/toolbox/upgrade-path)中创建一个议题或合并请求。

<a id="earlier-gitlab-versions"></a>

## 更早的极狐GitLab 版本

有关升级到更早极狐GitLab 版本的信息，请参见[文档归档](https://archives.docs.gitlab.com)。归档中的文档版本包含针对更早极狐GitLab 版本的特定版本信息。