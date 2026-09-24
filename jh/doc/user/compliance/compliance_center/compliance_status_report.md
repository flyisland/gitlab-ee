---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合规状态报告
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 17.11 中引入，伴随一个功能标志 `enable_standards_adherence_dashboard_v2`，默认启用。
- 在 极狐GitLab 18.3 中 GA，功能标志 `enable_standards_adherence_dashboard_v2` 已移除。

{{< /history >}}

合规状态报告显示项目不符合[合规框架要求](../compliance_frameworks/_index.md#requirements)的最近实例。它是合规中心的一部分，可帮助你快速识别并修复整个群组项目中的控制实施差距。

<a id="scan-timing-and-triggers"></a>

## 扫描时机和触发器

更新状态报告的合规扫描在以下情况下自动触发：

- 向项目添加框架。
- 关联框架的要求被修改。
- 计划扫描运行（每 12 小时一次）。

触发扫描后，结果可能需要五到十分钟才会出现在合规状态报告中。

要了解有关如何在合规框架中定义要求和控制的更多信息，请参阅[创建和管理合规框架要求](../compliance_frameworks/_index.md#add-requirements)。

<a id="view-the-compliance-status-report"></a>

## 查看合规状态报告

先决条件：

- 你必须是群组的管理员，或具有安全经理或所有者角色。

查看合规状态报告：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在 **合规报告** 部分，选择 **合规状态报告**。

<a id="report-details"></a>

## 报告详情

合规状态报告显示项目遵守或不遵守框架控制的最近实例。每一行提供特定项目中控制当前状态的详细信息，帮助你监控群组的合规情况。

你可以：

- 按项目、框架或控制筛选报告。
- 直接导航到项目的合规详细信息视图。
- 查看首次检测到不符合项的时间。

合规状态报告包含以下列：

- **项目**：存在不符合项的项目。
- **框架**：控制所属的合规框架（例如，极狐GitLab 或 SOC 2）。
- **控制**：项目未遵守的特定控制（例如，“至少两人审批”）。
- **检测于**：首次记录不符合项的日期和时间。
- **更多信息**：指向项目附加上下文或相关设置的链接。

<a id="export-compliance-status-report"></a>

## 导出合规状态报告

导出群组中项目的状态报告内容。报告被截断为 15 MB，以避免大邮件附件。

先决条件：

- 你必须是群组的管理员，或具有安全经理或所有者角色。

导出群组中项目的合规状态报告：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在右上角，选择 **导出**。
1. 选择 **导出合规状态报告**。

报告将被编译并作为附件发送到你的电子邮件收件箱。