---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何从一个集中位置管理整个极狐GitLab 实例中的合规框架。
title: 集中式合规框架
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

集中式安全合规框架管理允许极狐GitLab 管理员集中管理和强制执行极狐GitLab 实例中所有群组和项目的合规要求。

通过指定一个合规与安全策略（CSP）群组，您可以创建自动对所有顶级群组可用的合规框架。

当您指定一个合规与安全策略群组时：

- 在合规与安全策略群组中创建的所有合规框架都会对您实例中的每个顶级群组可用。
- 群组所有者可以将这些集中式框架分配给他们的项目。
- 这些框架会与任何群组专属框架一起显示，并有明确的指示表明它们来自合规与安全策略群组。
- 对于合规与安全策略群组的非成员，合规与安全策略框架是只读的，从而确保合规标准的一致应用。

框架可见性和权限：

- 所有用户都可以看到哪些框架已应用于他们有权访问的项目。
- 群组成员可以查看其群组可用的所有合规与安全策略框架。
- 合规中心会同时显示合规与安全策略群组框架和群组专属框架。

<a id="prerequisites"></a>

## 先决条件

- 您必须是管理员。
- 需要一个现有的顶级群组作为合规与安全策略群组。
- 要使用 REST API（可选），您必须拥有具有管理员访问权限的令牌。

<a id="before-you-begin"></a>

## 开始之前

开始之前，请指定一个顶级群组作为您的合规与安全策略群组，作为管理合规框架的集中位置。

有关详细说明，请参阅[指定合规与安全策略群组](../../../security/compliance_security_policy_management.md#designate-a-compliance-and-security-policy-group)。

<a id="create-compliance-frameworks-in-the-compliance-and-security-policy-group"></a>

## 在合规与安全策略群组中创建合规框架

指定合规与安全策略群组后，在其中创建合规框架：

1. 转到您指定的合规与安全策略群组。
1. 选择**安全** > **合规中心**。
1. 在该页面上，选择**框架**标签页。
1. 选择**新建框架**。
1. 输入框架详情：
   - **名称**：框架的描述性名称。
   - **描述**：说明框架的用途和要求。
   - **颜色**：选择一种颜色以便视觉识别。
   - **要求**（可选）：添加具体的控制和需求。
1. 选择**保存更改**。

该框架现在对您实例中的所有顶级群组可用。

<a id="configure-framework-requirements-optional"></a>

## 配置框架要求（可选）

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为每个合规框架定义具体的要求和控制：

1. 在合规与安全策略群组中创建或编辑框架时，转到**要求**部分。
1. 选择**新建要求**。
1. 添加一个或多个控制：
   - **极狐GitLab 控制**：针对极狐GitLab 功能和设置的预定义检查。
   - **外部控制**：与第三方合规工具的集成。
1. 选择**保存对框架的更改**。

有关可用控制的更多信息，请参阅[极狐GitLab 合规控制](_index.md#gitlab-compliance-controls)以及[支持的合规标准](compliance_standards.md)的详细信息。

<a id="apply-compliance-and-security-policy-frameworks-to-projects"></a>

## 将合规与安全策略框架应用到项目

以群组所有者或项目所有者的身份将合规与安全策略框架应用到项目。

<a id="as-a-group-owner"></a>

### 作为群组所有者

群组所有者可以查看合规与安全策略框架并将其应用到他们的项目。合规与安全策略框架在群组上是只读的，您无法从您的群组中编辑或删除它们。

要将合规与安全策略框架应用到您群组中的项目：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在该页面上，选择**项目**标签页。
1. 合规与安全策略框架会以特殊指示符显示在列表中。
1. 选择一个合规与安全策略框架，将其应用到您群组中的项目。

<a id="as-a-project-owner"></a>

### 作为项目所有者

要查看哪些合规框架适用于您的项目：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**合规框架**部分。
1. 查看所有已应用的框架，包括来自合规与安全策略群组的框架。

<a id="modifying-compliance-and-security-policy-frameworks"></a>

## 修改合规与安全策略框架

当您在合规与安全策略群组中修改合规框架时：

- 更改会立即反映到所有群组。
- 使用该框架的项目会自动继承这些更新。
- 审计事件会跟踪所有修改。
- 群组或项目所有者无需执行任何操作。

<a id="deleting-compliance-and-security-policy-frameworks"></a>

## 删除合规与安全策略框架

当您删除合规与安全策略框架时，极狐GitLab 会显示有关受影响项目的警告。

当您确认要删除某个合规与安全策略框架时：

- 该框架会从所有项目中移除。
- 会生成审计事件。
- 该框架在任何群组中都不再可见。

<a id="changing-the-compliance-and-security-policy-group"></a>

## 更改合规与安全策略群组

如果您需要更改哪个群组作为合规与安全策略群组：

- 来自先前合规与安全策略群组的所有框架都会变为不可用。
- 来自新合规与安全策略群组的框架会变为可用。
- 如有需要，必须将项目重新分配给新的框架。

有关详细说明，请参阅[指定合规与安全策略群组](../../../security/compliance_security_policy_management.md#designate-a-compliance-and-security-policy-group)。

<a id="integration-with-security-policies"></a>

## 与安全策略集成

合规与安全策略框架可以与安全策略集成，以增强合规性：

1. 在合规与安全策略群组中创建安全策略。
1. 将策略限定到特定的合规框架。
1. 具有这些框架的项目会自动继承这些策略。

有关更多信息，请参阅[合规与安全策略群组中的安全策略管理](../../application_security/policies/enforcement/compliance_and_security_policy_groups.md)。

<a id="troubleshooting"></a>

## 故障排除

使用集中式合规框架时可能遇到的问题的可行解决方案。

<a id="frameworks-not-appearing-in-groups"></a>

### 框架未出现在群组中

如果合规与安全策略框架在您的群组中不可见：

1. 验证合规与安全策略群组已在管理员设置中正确指定。
1. 检查合规与安全策略群组中是否存在框架。
1. 确保您拥有查看框架的适当权限。

<a id="cannot-modify-compliance-and-security-policy-frameworks"></a>

### 无法修改合规与安全策略框架

合规与安全策略框架只能从合规与安全策略群组中修改：

1. 直接转到合规与安全策略群组。
1. 确保您在合规与安全策略群组上拥有所有者角色。
1. 从合规与安全策略群组的合规中心进行更改。
