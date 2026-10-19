---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全中心
description: 可配置的空间，用于查看多个项目中的漏洞。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

安全中心是一个可配置的个人空间，包含来自多个项目的漏洞数据。您可以从您所属的任意项目中，向安全中心添加最多 1,000 个项目。

> [!note]
> 安全中心设置页面中的**项目**列表最多显示 100 个项目。
> 如需查找未显示在前 100 个项目中的项目，请使用搜索筛选器。

安全中心显示：

- 您已添加项目的安全仪表板。
- 您已添加项目的[漏洞报告](../vulnerability_report/_index.md)。
- 用于添加或移除项目的设置区域。

<a id="view-the-security-center"></a>

## 查看安全中心

查看安全中心：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**您的工作**。
1. 选择**安全** > **安全仪表板**。

安全中心默认为空。您必须添加一个或多个已配置至少一个安全扫描器的项目。

<a id="add-projects-to-the-security-center"></a>

## 向安全中心添加项目

添加项目：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**您的工作**。
1. 展开**安全**。
1. 选择**设置**。
1. 使用**搜索您的项目**文本框搜索并选择项目。
1. 选择**添加项目**。

添加项目后，安全仪表板和漏洞报告会显示在这些项目的默认分支中发现的漏洞。

<a id="remove-projects-from-the-security-center"></a>

## 从安全中心移除项目

安全中心最多显示 100 个项目，因此您可能需要使用搜索功能来移除项目。移除项目：

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**您的工作**。
1. 展开**安全**。
1. 选择**设置**。
1. 使用**搜索您的项目**文本框搜索该项目。
1. 选择**从仪表板移除项目** ({{< icon name="remove" >}})。

移除项目后，安全仪表板和漏洞报告将不再显示在这些项目的默认分支中发现的漏洞。

<a id="exporting"></a>

## 导出

您可以导出 PDF 文件，其中包含安全仪表板中所列漏洞的详细信息。

导出内容中的图表包括：

- 漏洞随时间的变化
- 项目安全状态
- 项目的安全仪表板

<a id="export-details"></a>

### 导出详细信息

如需导出安全仪表板中所列所有漏洞的详细信息，请选择**导出**。

导出详细信息可用后，极狐GitLab 会向您发送电子邮件。如需下载导出的详细信息，请选择电子邮件中的链接。
