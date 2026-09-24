---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to manage compliance frameworks across your entire GitLab instance from a single, centralized location.
title: 集中式合规框架
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 中引入，带有功能标志 `security_policies_csp` 和 `include_csp_frameworks`。默认启用。
- 功能标志 `security_policies_csp` 在极狐GitLab 18.5 中移除。
- 在极狐GitLab 18.6 中 GA。功能标志 `include_csp_frameworks` 已移除。

{{< /history >}}

集中式安全合规框架管理允许极狐GitLab管理员在极狐GitLab实例中集中管理和执行所有群组及项目的合规要求。

通过指定合规与安全策略（CSP）群组，您可以创建自动适用于所有顶级群组的合规框架。

当您指定合规与安全策略群组时：

- 在该合规与安全策略群组中创建的所有合规框架都将可用于您实例中的每一个顶级群组。
- 群组所有者可以将这些集中式框架分配给他们的项目。
- 这些框架会与任何特定群组的框架一同显示，并带有清晰指示，表明它们来自合规与安全策略群组。
- 对于不是合规与安全策略群组成员的人，合规与安全策略框架是只读的，从而确保合规标准的一致应用。

框架可见性与权限：

- 所有用户都可以看到哪些框架应用到了他们有访问权限的项目。
- 群组成员可以查看其群组可用的所有合规与安全策略框架。
- 合规中心同时显示合规与安全策略群组框架和特定群组的框架。

<a id="prerequisites"></a>

## 先决条件

- 您必须是管理员。
- 一个现有的顶级群组，用于充当合规与安全策略群组。
- 如需使用 REST API（可选），您必须拥有具备管理员访问权限的令牌。

<a id="before-you-begin"></a>

## 开始之前

在开始之前，请先指定一个顶级群组作为您的合规与安全策略群组，用作管理合规框架的中央位置。

有关详细说明，请参见
[指定合规与安全策略群组](../../../security/compliance_security_policy_management.md#designate-a-compliance-and-security-policy-group)。

<a id="create-compliance-frameworks-in-the-compliance-and-security-policy-group"></a>

## 在合规与安全策略群组中创建合规框架

指定合规与安全策略群组后，在其中创建合规框架：

1. 前往您指定的合规与安全策略群组。
1. 选择 **安全** > **合规中心**。
1. 在页面上，选择 **框架** 标签页。
1. 选择 **新增框架**。
1. 输入框架详情：
   - **名称**：框架的描述性名称。
   - **描述**：解释框架的目的和要求。
   - **颜色**：选择一种颜色以便视觉识别。
   - **要求**（可选）：添加特定的控制项和要求。
1. 选择 **保存更改**。

该框架现在可用于您实例中的所有顶级群组。

<a id="configure-framework-requirements-optional"></a>

## 配置框架要求（可选）

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为每个合规框架定义特定的要求和控制项：

1. 在合规与安全策略群组中创建或编辑框架时，转到 **要求** 部分。
1. 选择 **新增要求**。
1. 添加一个或多个控制项：
   - **极狐GitLab 控制项**：针对极狐GitLab 功能与设置的预定义检查。
   - **外部控制项**：与第三方合规工具的集成。
1. 选择 **保存框架更改**。

有关可用控制项的更多信息，请参见[极狐GitLab 合规控制项](_index.md#gitlab-compliance-controls)
以及[支持的合规标准](compliance_standards.md)的详细信息。

<a id="apply-compliance-and-security-policy-frameworks-to-projects"></a>

## 将合规与安全策略框架应用到项目

作为群组所有者或项目所有者，将合规与安全策略框架应用到项目。

<a id="as-a-group-owner"></a>

### 作为群组所有者

群组所有者可以查看合规与安全策略框架并将其应用到他们的项目。对于群组，合规与安全策略框架是只读的，您无法在您的群组中编辑或删除它们。

要将合规与安全策略框架应用到您群组中的项目：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **安全** > **合规中心**。
1. 在页面上，选择 **项目** 标签页。
1. 合规与安全策略框架会带有特殊指示符显示在列表中。
1. 选择一个合规与安全策略框架，将其应用到您群组中的项目。

<a id="as-a-project-owner"></a>

### 作为项目所有者

要查看哪些合规框架适用于您的项目：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **合规框架** 部分。
1. 查看所有已应用的框架，包括那些来自合规与安全策略群组的框架。

<a id="modifying-compliance-and-security-policy-frameworks"></a>

## 修改合规与安全策略框架

当您在合规与安全策略群组中修改合规框架时：

- 更改会立即在所有群组中反映出来。
- 使用该框架的项目会自动继承这些更新。
- 审计事件会跟踪所有修改。
- 群组或项目所有者无需采取任何行动。

<a id="deleting-compliance-and-security-policy-frameworks"></a>

## 删除合规与安全策略框架

当您删除合规与安全策略框架时，极狐GitLab 会显示关于受影响项目的警告。

当您确认要删除合规与安全策略框架时：

- 该框架会从所有项目中移除。
- 会生成审计事件。
- 该框架将不再在任何群组中可见。

<a id="changing-the-compliance-and-security-policy-group"></a>

## 更改合规与安全策略群组

如果您需要更改作为合规与安全策略群组的群组：

- 之前合规与安全策略群组的所有框架将变为不可用。
- 新合规与安全策略群组的框架将变为可用。
- 如有必要，项目必须重新分配给新的框架。

有关详细说明，请参见
[指定合规与安全策略群组](../../../security/compliance_security_policy_management.md#designate-a-compliance-and-security-policy-group)。

<a id="integration-with-security-policies"></a>

## 与安全策略集成

合规与安全策略框架可以与安全策略集成，以增强合规性：

1. 在合规与安全策略群组中创建安全策略。
1. 将策略范围限定到特定的合规框架。
1. 具有这些框架的项目会自动继承这些策略。

有关更多信息，请参见[合规与安全策略群组中的安全策略管理](../../application_security/policies/enforcement/compliance_and_security_policy_groups.md)。

<a id="troubleshooting"></a>

## 故障排除

使用集中式合规框架时可能遇到的问题的潜在解决方案。

<a id="frameworks-not-appearing-in-groups"></a>

### 框架未显示在群组中

如果合规与安全策略框架未在您的群组中显示：

1. 验证合规与安全策略群组是否已在管理设置中正确指定。
1. 检查合规与安全策略群组中是否存在框架。
1. 确保您具有查看框架的适当权限。

<a id="cannot-modify-compliance-and-security-policy-frameworks"></a>

### 无法修改合规与安全策略框架

合规与安全策略框架只能从合规与安全策略群组中修改：

1. 直接前往合规与安全策略群组。
1. 确保您在合规与安全策略群组上具有所有者角色。
1. 从合规与安全策略群组的合规中心进行更改。

