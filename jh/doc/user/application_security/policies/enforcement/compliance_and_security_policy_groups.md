---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to apply security policies across multiple groups and projects from a single, centralized location.
title: 合规和安全策略群组
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.2 中作为功能标志引入，名称为 `security_policies_csp`。默认禁用。
- 在极狐GitLab 18.3 的私有化部署中默认启用。
- 在极狐GitLab 18.5 中 GA。功能标志 `security_policies_csp` 已移除。

{{< /history >}}

中心化安全策略管理允许实例管理员指定一个合规和安全策略群组，以便从单一的中心位置跨多个群组和项目应用安全策略。

当你在合规和安全策略群组中创建或编辑安全策略时，你可以限定该群组范围，以在以下对象上强制执行策略：

- **特定群组和子群组**：仅将策略应用于选定的群组及其子群组。
- **特定项目**：将策略应用于单个项目。
- **实例中的所有项目**：将策略应用于整个极狐GitLab 实例。
- **所有项目但排除例外**：应用于所有项目，但指定排除的项目除外。

当你指定一个合规和安全策略群组作为你的中心化策略管理中心时，你可以：

- 创建和配置自动在整个实例中应用的安全策略。
- 将策略范围限定到特定群组、项目或整个实例。
- 查看全面的策略覆盖范围，了解哪些策略处于活动状态以及它们在何处生效。
- 在允许团队创建自己的附加策略的同时，保持中心化控制。

<a id="prerequisites"></a>

## 先决条件

- 私有化部署。
- 极狐GitLab 18.2 或更高版本。
- 你必须是实例管理员。
- 你必须有一个现有的顶级群组来充当合规和安全策略群组。
- 要使用 REST API（可选），你必须拥有具有管理员访问权限的令牌。

<a id="set-up-centralized-security-policy-management"></a>

## 设置中心化安全策略管理

要设置中心化安全策略管理，你需要指定一个合规和安全策略群组，然后在该群组中创建策略。

有关更多信息，请参见[实例级合规与安全策略管理](../../../../security/compliance_security_policy_management.md)。

<a id="enable-global-approval-groups"></a>

### 启用全局审批群组

要在整个实例中支持全局审批群组，你必须：

- 在[极狐GitLab 实例应用程序设置](../../../../api/settings.md)中启用 `security_policy_global_group_approvers_enabled`。

<a id="create-security-policies-in-the-compliance-and-security-policy-group"></a>

### 在合规与安全策略群组中创建安全策略

创建策略：

1. 转到你指定的合规与安全策略群组。
1. 转到 **安全** > **策略**。
1. 像往常一样创建一个或多个安全策略。在保存每个策略之前：
   - 在 **策略范围** 部分，选择一个范围以将策略应用于：
     - **群组**：将策略应用于特定的群组和子群组。
     - **项目**：将策略应用于单个项目。
     - **所有项目**：应用于整个实例。
     - **所有项目但排除以下项目**：应用于所有项目，但指定排除的例外情况。
1. 保存你的策略配置。

<a id="policy-storage-and-configuration"></a>

## 策略存储与配置

合规和安全策略群组中的策略存储在指定合规与安全策略群组内的 `policy.yml` 文件中，类似于群组策略的管理方式。在合规和安全策略群组中创建的策略，其配置格式与其他群组和项目中的安全策略相同。

<a id="policy-synchronization"></a>

## 策略同步

- 根据范围内群组和项目的数量，策略更改可能需要一些时间才能在整个实例中应用。
- 同步过程使用后台作业，这些作业在你指定合规和安全策略群组、创建策略或更新策略时会自动排队。
- 实例管理员可以在 **管理员** > **监控** > **后台作业** 中监控后台作业的处理情况。
- 要验证策略是否已成功应用到目标群组或项目中，请转到该群组或项目的 **安全** > **策略**。

<a id="managing-performance"></a>

### 管理性能

为了防止性能问题，请规划你的策略管理策略，以尽量减少对配置的修改次数：

- 仔细规划更改：避免在短时间内连续进行多个合规与安全策略群组的更改。
- 在维护窗口期内安排更改：在低使用时段进行更改，以尽量降低对用户的影响。
- 监控系统性能：为同步期间可能出现的性能下降做好准备。
- 允许额外时间：同步过程的完成时间取决于你的实例大小。

<a id="troubleshooting"></a>

## 故障排除

**策略未在目标群组或项目中显示**

- 验证策略范围是否包含目标群组或项目。
- 验证合规和安全策略群组是否已在管理员设置中正确指定。
- 验证策略是否在合规和安全策略群组中已启用。
- 策略更改可能需要一些时间才能应用。有关更多信息，请参见[策略同步](#policy-synchronization)。

**性能问题**

- 监控策略传播时间，尤其是在范围配置较大的情况下。
- 考虑将策略范围限定到特定的群组或项目，而不是将其应用于所有项目。
- 要在修改合规安全策略群组时减少性能影响，请参见[管理性能](#managing-performance)。