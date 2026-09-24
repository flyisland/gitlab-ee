---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全资产清单
description: Group-level visibility of assets, scanner coverage, and vulnerabilities.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.2 中作为[测试版](../../../policy/development_stages_support.md)引入，带有一个名为 `security_inventory_dashboard` 的功能标志。默认启用。
- 在极狐GitLab 18.9 中 GA。功能标志 `security_inventory_dashboard` 已移除。

{{< /history >}}

使用安全资产清单来可视化您需要保护的资产，并了解需要采取哪些措施来提高安全性。安全领域有一句名言：“您无法保护您看不到的东西。”安全资产清单提供了对组织顶级群组安全态势的可见性，帮助您识别覆盖缺口，并使您能够做出高效的、基于风险的优先级决策。

安全资产清单显示：

- 您的群组、子群组和项目。
- 每个项目的安全扫描器覆盖情况，无论扫描器是如何启用的。工具覆盖反映了默认分支上最新流水线的扫描状态。安全扫描器包括：
  - 静态应用安全测试 (SAST)
  - 依赖项扫描
  - 容器扫描
  - 密钥检测
  - 动态应用安全测试 (DAST)
  - 基础设施即代码 (IaC) 扫描
- 每个群组或项目中的漏洞数量，按严重程度排序。

在 [epic 16939](https://jihulab.com/groups/gitlab-cn/-/work_items/16939) 中跟踪安全资产清单的开发进展。

<a id="view-the-security-inventory"></a>

## 查看安全资产清单

先决条件：

- 您必须在群组中拥有安全经理、开发者、维护者或所有者角色才能查看安全资产清单。

查看安全资产清单：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **安全** > **安全资产清单**。
1. 完成以下操作之一：
   - 要查看群组的子群组、项目和安全资产，请选择该群组。
   - 要查看群组或项目的扫描器覆盖情况，请搜索该群组或项目。

<a id="filter-projects-in-the-security-inventory"></a>

## 在安全资产清单中过滤项目

{{< history >}}

- 在极狐GitLab 18.5 中引入，带有一个名为 `security_inventory_filtering` 的[功能标志](../../../administration/feature_flags/_index.md)。默认启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。

您可以在安全资产清单中过滤项目，以专注于特定的关注领域。
以下过滤器可用：

- **漏洞数量**：根据已识别漏洞的数量过滤项目。例如，显示 `严重漏洞 ≥ 10` 的项目。
- **工具覆盖**：按安全分析器的状态（如 **已启用**、**未启用** 或 **失败**）过滤项目。例如，显示 `高级 SAST = 已启用` 的项目。
- **项目名称**：按名称搜索特定项目。

这些过滤器帮助您缩小大型清单中的结果，并更容易识别需要立即关注的项目。

<a id="related-topics"></a>

## 相关主题

- [安全仪表板](../security_dashboard/_index.md)
- [漏洞报告](../vulnerability_report/_index.md)
- GraphQL 参考：
  - [AnalyzerGroupStatusType](../../../api/graphql/reference/_index.md#analyzergroupstatustype) - 群组和子群组中每个分析器状态的计数。
  - [AnalyzerProjectStatusType](../../../api/graphql/reference/_index.md#analyzerprojectstatustype) - 项目的分析器状态（成功/失败）。
  - [VulnerabilityNamespaceStatisticType](../../../api/graphql/reference/_index.md#vulnerabilitynamespacestatistictype) - 群组及其子群组中每个漏洞严重程度的计数。
  - [VulnerabilityStatisticType](../../../api/graphql/reference/_index.md#vulnerabilitystatistictype) - 项目中每个漏洞严重程度的计数。

<a id="troubleshooting"></a>

## 故障排除

在使用安全资产清单时，您可能会遇到以下问题：

<a id="security-inventory-menu-item-missing"></a>

### 安全资产清单菜单项缺失

某些用户没有访问 **安全资产清单** 菜单项所需的权限。仅当已认证用户具有安全经理、开发者、维护者或所有者角色时，该菜单项才会对群组显示。