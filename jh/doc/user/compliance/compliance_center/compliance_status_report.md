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

合规状态报告显示项目不遵守[合规框架要求](../compliance_frameworks/_index.md#requirements)的最新实例。它是合规中心的一部分，可帮助您快速识别并修复各项目中控制措施实施方面的差距。

<a id="scan-timing-and-triggers"></a>

## 扫描时机和触发条件

更新状态报告的合规扫描会在以下情况下自动触发：

- 为项目添加框架。
- 修改关联框架的要求。
- 运行计划扫描（每 12 小时一次）。

扫描触发后，结果可能需要五到十分钟才会显示在合规状态报告中。

要详细了解合规框架中如何定义要求和控制措施，请参阅[创建和管理合规框架要求](../compliance_frameworks/_index.md#add-requirements)。

<a id="view-the-compliance-status-report"></a>

## 查看合规状态报告

先决条件：

- 您必须是管理员，或拥有该群组的安全管理员或所有者角色。

查看合规状态报告：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在**合规报告**部分，选择**合规状态报告**。

<a id="report-details"></a>

## 报告详情

合规状态报告显示项目遵守或不遵守框架控制措施的最新实例。每一行都提供特定项目中某项控制措施当前状态的详细信息，帮助您监控整个群组的合规情况。

您可以：

- 按项目、框架或控制措施筛选报告。
- 直接导航到项目的合规详情视图。
- 查看首次检测到不遵守情况的时间。

合规状态报告包含以下列：

- **项目**：存在不遵守情况的项目。
- **框架**：该控制措施所属的合规框架（例如 GitLab 或 SOC 2）。
- **控制措施**：项目未遵守的具体控制措施（例如“至少两次批准”）。
- **检测时间**：首次记录不遵守情况的日期和时间。
- **更多信息**：指向项目其他上下文或相关设置的链接。

<a id="export-compliance-status-report"></a>

## 导出合规状态报告

导出群组中项目的状态报告内容。报告会被截断至 15 MB，以避免电子邮件附件过大。

先决条件：

- 您必须是管理员，或拥有该群组的安全管理员或所有者角色。

导出群组中项目的合规状态报告：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在右上角，选择**导出**。
1. 选择**导出合规状态报告**。

系统会生成报告，并作为附件发送到您的电子邮箱。
