---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全清单
description: 群组级资产、扫描器覆盖范围和漏洞的可见性。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用安全清单可以直观地了解需要保护哪些资产，并了解为提高安全性需要采取哪些措施。安全领域有一句常见的话：“看不见的东西就无法保护。”安全清单可让您了解组织顶级群组的安全态势，帮助您识别覆盖缺口，并使您能够基于风险做出高效的优先级决策。

安全清单显示：

- 您的群组、子群组和项目。
- 每个项目的安全扫描器覆盖情况，无论扫描器是如何启用的。工具覆盖情况反映默认分支上最近一次流水线的扫描状态。安全扫描器包括：
  - 静态应用安全测试（SAST）
  - 依赖扫描
  - 容器扫描
  - 密钥检测
  - 动态应用安全测试（DAST）
  - 基础设施即代码（IaC）扫描
- 每个群组或项目中的漏洞数量，按严重级别排序。该计数不包括不再检测到的漏洞。

在[史诗 16939](https://gitlab.com/groups/gitlab-org/-/work_items/16939)中跟踪安全清单的开发进展。随着该功能的持续开发，欢迎分享[您的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/553062)。

<a id="view-the-security-inventory"></a>

## 查看安全清单

先决条件：

- 您必须在群组中拥有安全管理员、开发者、维护者或所有者角色，才能查看安全清单。

查看安全清单：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **安全清单**。
1. 完成以下操作之一：
   - 要查看群组的子群组、项目和安全资产，请选择该群组。
   - 要查看群组或项目的扫描器覆盖情况，请搜索该群组或项目。

<a id="scanner-coverage"></a>

## 扫描器覆盖情况

当默认分支流水线完成时，会评估安全扫描器状态。每个安全扫描器会为每个项目或群组显示以下覆盖状态之一：

- **未启用**：未配置该扫描器。
- **已启用**：已配置该扫描器并成功完成。
- **失败**：该扫描器已运行，但未成功完成。
- **过期**：之前已启用的扫描器在最近连续三次流水线中均未运行。

<a id="filter-projects-in-the-security-inventory"></a>

## 在安全清单中筛选项目

您可以在安全清单中筛选项目，以专注于特定的关注领域。可用的筛选条件如下：

- **漏洞数量**：根据已识别漏洞的数量筛选项目。例如，显示 `critical vulnerabilities ≥ 10`的项目。
- **工具覆盖情况**：按安全分析器的状态（如**已启用**、**未启用**或**失败**）筛选项目。例如，显示 `Advanced SAST = enabled`的项目。
- **项目名称**：按名称搜索特定项目。

这些筛选条件可帮助您在大型清单中缩小结果范围，并更轻松地识别需要立即关注的项目。

<a id="troubleshooting"></a>

## 故障排除

使用安全清单时，您可能会遇到以下问题：

<a id="security-inventory-menu-item-missing"></a>

### 安全清单菜单项缺失

部分用户没有访问**安全清单**菜单项所需的权限。仅当已认证用户拥有安全管理员、开发者、维护者或所有者角色时，该菜单项才会对群组显示。
