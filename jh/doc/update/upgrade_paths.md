---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 规划升级路径
description: 最新版本说明。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

升级路径包含从当前极狐GitLab 版本升级到目标极狐GitLab 版本所需执行的步骤。要确定您的升级路径：

1. 记下当前版本在升级路径中的位置，包括必需的升级停靠点。
1. 查阅[极狐GitLab 升级说明](versions/_index.md)。

即使未明确指定，也应将极狐GitLab 升级到 `major`.`minor` 版本可用的最新补丁版本，而不是第一个补丁版本。例如，升级到 `16.8.7` 而不是 `16.8.0`。

某些 `major`.`minor` 版本是部分或全部环境的必需停靠点，因为这些版本包含与升级过程相关问题的修复。

<a id="required-upgrade-stops"></a>

## 必需的升级停靠点

升级路径包含必需的升级停靠点，即您必须先升级到这些极狐GitLab 版本，然后才能升级到更高版本。在沿升级路径升级时：

1. 升级到当前版本之后的必需升级停靠点。
1. 等待升级的后台迁移完成。
1. 升级到下一个必需升级停靠点。

在极狐GitLab 17.5 及更高版本中，为了给实例管理员提供可预测的升级计划，必需的升级停靠点出现在版本 `x.2.z`、`x.5.z`、`x.8.z` 和 `x.11.z`。

要查看特定次要版本的可用补丁版本，请在[极狐GitLab 软件包仓库](https://packages.gitlab.cn/#browse/browse)中浏览这些版本。

如果您要升级 GitLab Helm chart 实例，请参阅
[GitLab Helm chart 映射列表](https://gitlab.cn/docs/charts/installation/version_mappings/#previous-chart-versions)。

<a id="required-gitlab-19-upgrade-stops"></a>

### 极狐GitLab 19 必需的升级停靠点

> [!note]
> 其中某些版本可能尚未发布。要查看哪些版本可用，请参阅
> [极狐GitLab 19 发布说明](../releases/19/_index.md)。

必需的升级停靠点出现在以下版本：

- `19.2`
- `19.5`
- `19.8`
- `19.11`

在升级到更高版本之前，您必须先升级到极狐GitLab 19 的这些版本。对于您要升级到的每个版本，请参阅[极狐GitLab 19 升级说明](versions/gitlab_19_changes.md)。如果某个版本未出现在升级说明中，则说明该版本没有需要特别注意的内容。

请在极狐GitLab 软件包仓库中查找补丁版本。例如，要查找适用于 Ubuntu 24.04 的最新 `gitlab-jh` 19.2 软件包：

1. 前往 <https://packages.gitlab.cn/service/rest/repository/browse/ubuntu-noble/packages/g/gitlab-jh/>。
1. 打开最新的 `19.2.x-jh.0` 版本目录，并选择适用于您架构的 `gitlab-jh` 软件包。

<a id="required-gitlab-18-upgrade-stops"></a>

### 极狐GitLab 18 必需的升级停靠点

必需的升级停靠点出现在版本 `18.2`、`18.5`、`18.8` 和 `18.11`。

在升级到更高版本之前，您必须先升级到极狐GitLab 18 的这些版本。对于您要升级到的每个版本，请参阅[极狐GitLab 18 升级说明](versions/gitlab_18_changes.md)。如果某个版本未出现在升级说明中，则说明该版本没有需要特别注意的内容。

请在极狐GitLab 软件包仓库中查找补丁版本。例如，要查找适用于 Ubuntu 24.04 的最新 `gitlab-jh` 18.2 软件包：

1. 前往 <https://packages.gitlab.cn/service/rest/repository/browse/ubuntu-noble/packages/g/gitlab-jh/>。
1. 打开最新的 `18.2.x-jh.0` 版本目录，并选择适用于您架构的 `gitlab-jh` 软件包。

<a id="required-gitlab-17-upgrade-stops"></a>

### 极狐GitLab 17 必需的升级停靠点

在升级到更高版本之前，您必须先升级到极狐GitLab 17 的这些版本。

| 必需版本 | 说明 |
|:-----------------|:------|
| 17.11.7          | 升级到最新的极狐GitLab 17.11 补丁版本。请参阅[极狐GitLab 17.11.0 升级说明](versions/gitlab_17_changes.md#upgrades-to-17110)。 |
| 17.8.7           | 升级到最新的极狐GitLab 17.8 补丁版本。请参阅[极狐GitLab 17.8.0 升级说明](versions/gitlab_17_changes.md#upgrades-to-1780)。 |
| 17.5.5           | 升级到最新的极狐GitLab 17.5 补丁版本。请参阅[极狐GitLab 17.5.0 升级说明](versions/gitlab_17_changes.md#upgrades-to-1750)。 |
| 17.3.7           | 升级到最新的极狐GitLab 17.3 版本。请参阅[极狐GitLab 17.3.0 升级说明](versions/gitlab_17_changes.md#upgrades-to-1730)。 |
| 17.1.8           | 仅适用于具有[大型 `ci_pipeline_messages` 表](versions/gitlab_17_changes.md#long-running-pipeline-messages-data-change)的实例。请参阅[极狐GitLab 17.1.0 升级说明](versions/gitlab_17_changes.md#upgrades-to-1710)。|

<a id="required-gitlab-16-upgrade-stops"></a>

### 极狐GitLab 16 必需的升级停靠点

在升级到更高版本之前，您必须先升级到极狐GitLab 16 的这些版本。

| 必需版本 | 说明 |
|:-----------------|:------|
| 16.11.10         | 请参阅[极狐GitLab 16.11.0 升级说明](versions/gitlab_16_changes.md#16110)。 |
| 16.7.10          | 请参阅[极狐GitLab 16.8.0 升级说明](versions/gitlab_16_changes.md#1670)及更高极狐GitLab 16.7 版本。 |
| 16.3.9           | 请参阅[极狐GitLab 16.3.0 升级说明](versions/gitlab_16_changes.md#1630)及更高极狐GitLab 16.3 版本。 |
| 16.2.11          | 仅适用于具有[大型流水线变量历史记录](versions/gitlab_16_changes.md#1630)的极狐GitLab 实例。请参阅[极狐GitLab 16.2.0 升级说明](versions/gitlab_16_changes.md#1620)。 |
| 16.1.8           | 仅适用于[软件包仓库中包含 NPM 软件包](versions/gitlab_16_changes.md#1610)的极狐GitLab 实例。请参阅[极狐GitLab 16.1.0 升级说明](versions/gitlab_16_changes.md#1610)。 |
| 16.0.10          | 仅适用于[用户数量众多](versions/gitlab_16_changes.md#long-running-user-type-data-change)或[大型流水线变量历史记录](versions/gitlab_16_changes.md#1610)的极狐GitLab 实例。请参阅[极狐GitLab 16.0.0 升级说明](versions/gitlab_16_changes.md#1600)及更高极狐GitLab 16.0 版本。 |

<a id="required-gitlab-15-upgrade-stops"></a>

### 极狐GitLab 15 必需的升级停靠点

在升级到更高版本之前，您必须先升级到极狐GitLab 15 的这些版本。

| 必需版本 | 说明 |
|:-----------------|:------|
| 15.11.13         | 请参阅[极狐GitLab 15.11.0 升级说明](versions/gitlab_15_changes.md#15110)及更高极狐GitLab 15.11 版本。 |
| 15.4.6           | 请参阅[极狐GitLab 15.4.0 升级说明](versions/gitlab_15_changes.md#1540)及更高极狐GitLab 15.4 版本。 |
| 15.1.6           | 仅适用于具有多个 Web 节点的极狐GitLab 实例。请参阅[极狐GitLab 15.1.0 升级说明](versions/gitlab_15_changes.md#1510)。 |
| 15.0.5           | 请参阅[极狐GitLab 15.0 升级说明](versions/gitlab_15_changes.md#1500)。 |

<a id="upgrade-path-tool"></a>

## 升级路径工具

要根据当前极狐GitLab 版本和目标极狐GitLab 版本快速计算需要哪些升级停靠点，请参阅[升级路径工具](https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/)。此工具由极狐GitLab 支持团队维护。

要分享反馈并帮助改进此工具，请在 [`upgrade-path` 项目](https://gitlab.com/gitlab-com/support/toolbox/upgrade-path)中创建议题或合并请求。

<a id="earlier-gitlab-versions"></a>

## 更早的极狐GitLab 版本

有关升级到更早极狐GitLab 版本的信息，请参阅[文档归档](https://archives.docs.gitlab.com)。归档中的文档版本包含更早极狐GitLab 版本的特定信息。
