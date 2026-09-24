---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全中心
description: 可配置的空间，用于查看跨多个项目的漏洞。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

安全中心是一个可配置的个人空间，包含来自多个项目的漏洞数据。你可以从你所属的任何项目中添加最多 1,000 个项目到安全中心。

> [!note]
> 安全中心设置页面中的 **项目** 列表最多显示 100 个项目。
> 要查找未在前 100 个项目中显示的项目，请使用搜索过滤器。

安全中心显示：

- 针对你已添加项目的安全仪表盘。
- 针对你已添加项目的[漏洞报告](../vulnerability_report/_index.md)。
- 用于添加或删除项目的设置区域。

<a id="view-the-security-center"></a>

## 查看安全中心

要查看安全中心：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **您的工作**。
1. 选择 **安全** > **安全仪表盘**。

默认情况下，安全中心为空。你必须添加一个或多个已配置至少一个安全扫描器的项目。

<a id="add-projects-to-the-security-center"></a>

## 添加项目到安全中心

要添加项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **您的工作**。
1. 展开 **安全**。
1. 选择 **设置**。
1. 使用 **搜索你的项目** 文本框搜索并选择项目。
1. 选择 **添加项目**。

添加项目后，安全仪表盘和漏洞报告将显示在这些项目的默认分支中发现的漏洞。

<a id="remove-projects-from-the-security-center"></a>

## 从安全中心删除项目

安全中心最多显示 100 个项目，因此你可能需要使用搜索功能来删除项目。要删除项目：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **您的工作**。
1. 展开 **安全**。
1. 选择 **设置**。
1. 使用 **搜索你的项目** 文本框搜索项目。
1. 选择 **从仪表盘删除项目** ({{< icon name="remove" >}})。

删除项目后，安全仪表盘和漏洞报告将不再显示在这些项目的默认分支中发现的漏洞。

<a id="exporting"></a>

## 导出

{{< history >}}

- 在极狐GitLab 18.2 中引入，[使用一个功能标志](../../../administration/feature_flags/_index.md) 名为 `vulnerabilities_pdf_export`。默认启用。
- 在 18.5 中 GA。功能标志 `vulnerabilities_pdf_export` 已移除。

{{< /history >}}

你可以导出一个 PDF 文件，其中包含安全仪表盘中列出的漏洞的详细信息。

导出中的图表包括：

- 随时间变化的漏洞
- 项目安全状态
- 项目的安全仪表盘

<a id="export-details"></a>

### 导出详情

要导出安全仪表盘中列出的所有漏洞的详细信息，请选择 **导出**。

当导出的详细信息可用时，极狐GitLab 会向你发送一封电子邮件。要下载导出的详细信息，请选择电子邮件中的链接。

<a id="related-topics"></a>

## 相关主题

- [安全仪表盘](../security_dashboard/_index.md)
- [漏洞报告](../vulnerability_report/_index.md)
- [漏洞页面](../vulnerabilities/_index.md)