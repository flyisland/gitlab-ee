---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Manage users and seats associated with your GitLab subscription.
title: 管理席位
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

席位管理是控制并监控哪些用户占用您订阅中的席位的过程。
有效的席位管理有助于控制成本、避免意外的超额费用，并确保团队成员获得所需访问权限。

<a id="billable-users"></a>

## 可计费用户

可计费用户是指占用订阅席位并计入订阅已购席位数的用户。

以下用户计为可计费：

- 可以访问订阅中的命名空间或顶级群组的用户，例如直接[成员](../user/project/members/_index.md#membership-types)、继承成员和具有以下任一角色的受邀用户：
  - 访客（在专业版中计费，在基础版和旗舰版中不计费）
  - 计划者
  - 报告者
  - 安全经理
  - 开发者
  - 维护者
  - 所有者
  - [自定义角色](../user/custom_roles/_index.md)，除了仅具有 `read_code` 权限的自定义访客成员角色
- [审计员用户](../administration/auditor_users.md)
- 管理员（在专业版和旗舰版的极狐GitLab 私有化部署上）
- 无命名空间访问权限的用户（在专业版的极狐GitLab 私有化部署上）

在当前订阅期内，当您屏蔽、停用或向实例或群组添加用户时，可计费用户数量会变化。
如果用户属于持有该订阅的同一顶级群组下的多个群组或项目，则仅计数一次。

席位使用情况将[按季度或按年度](quarterly_reconciliation.md)进行审查。

为防止意外新增可计费用户而导致超额费用，您应该：

- [阻止邀请群组层级之外的群组](../user/project/members/sharing_projects_groups.md#prevent-inviting-groups-outside-the-group-hierarchy)。
- 为[群组](../user/group/manage.md#turn-on-restricted-access)或[实例](../administration/settings/sign_up_restrictions.md#turn-on-restricted-access)开启限制访问。

<a id="criteria-for-non-billable-users"></a>

## 非计费用户的标准

如果用户满足以下任一条件，则不计为可计费用户：

- 待审批。
- 已[停用](../administration/moderate_users.md#deactivate-a-user)、
  [封禁](../user/group/moderate_users.md#ban-a-user)、
  或[屏蔽](../administration/moderate_users.md#block-a-user)。
- 不属于任何项目或群组（仅限旗舰版订阅）。
- 仅具有访客角色（仅限旗舰版订阅）。
- 仅具有[最小访问权限角色](../user/permissions.md#users-with-minimal-access)。
- 该账户是极狐GitLab 创建的服务账户：
  - [幽灵用户](../user/profile/account/delete_account.md#associated-records)。
  - 机器人：
    - [支持机器人](../user/project/service_desk/configure.md#support-bot-user)。
    - [项目机器人用户](../user/project/settings/project_access_tokens.md#bot-users-for-projects)。
    - [群组机器人用户](../user/group/settings/group_access_tokens.md#bot-users-for-groups)。
    - 其他[内部用户](../administration/internal_users.md)。

<a id="users-over-subscription-limit"></a>

## 超出订阅限制的用户

当实例或顶级群组中的可计费用户数量超过已购席位数量时，即出现超出订阅的用户（或欠席位数）。

例如，当新用户被添加到实例或群组，或现有用户被提升为计费角色时，可能发生此情况。

超出订阅的用户数计算方法为：计费周期内的最大用户数 - 订阅已购席位数。

例如，您购买了一个 10 席位的订阅，计费周期内用户数量变化如下：

| 事件                                             | 可计费用户 | 最大用户数 |
|:--------------------------------------------------|:----------------|:--------------|
| 十名用户占满全部 10 个席位。                    | 10              | 10            |
| 两名新用户加入。                               | 12              | 12            |
| 三名用户离开，其账户被屏蔽。                 | 9               | 12            |
| 四名新用户加入。                              | 13              | 13            |

在此示例中，有 3 名用户超出订阅（13 最大用户数 - 10 已购席位）。

当超出订阅限制时，您必须在续费前或续费时为额外用户付费。
费用基于计费周期内的最大用户数，而非当前用户数。

在极狐GitLab 私有化部署上，对于试用许可证，超出订阅的用户值始终为零。

为避免意外的超额费用，您可以：

- 开启限制访问，防止在无剩余席位时添加用户。
- [要求管理员审批新用户账户](../administration/settings/sign_up_restrictions.md#require-administrator-approval-for-new-user-accounts)。
- 在接近限额时主动购买更多席位。

<a id="free-guest-users"></a>

## 免费访客用户

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

在 **旗舰版** 中，分配为访客角色的用户不消耗席位。
该用户在整个实例（极狐GitLab 私有化部署）或命名空间（JihuLab.com）内不得被分配其他任何角色。

在 **专业版** 的极狐GitLab 私有化部署上，如果访客用户在任意项目或群组（包括其个人命名空间）中拥有更高角色，
则当您升级到 **旗舰版** 时，该更高角色具有优先权，他们将占用席位。
为确保极狐GitLab 私有化部署旗舰版上的访客用户不会消耗席位，请在升级前确认他们在实例或命名空间中没有其他角色分配。

- 如果您的项目是：
  - 私有或内部，具有访客角色的用户拥有[一组权限](../user/permissions.md#project-permissions)。
  - 公开，所有用户，包括具有访客角色的用户，都可以访问您的项目。
- 对于 JihuLab.com，如果具有访客角色的用户在其个人命名空间中创建项目，则该用户不消耗席位。
  该项目位于用户的个人命名空间下，与持有旗舰版订阅的群组无关。
- 在极狐GitLab 私有化部署上，用户最高角色的更新是异步的，可能需要一些时间才能生效。

> [!note]
> 在极狐GitLab 私有化部署上，如果用户创建项目，他们将被分配为维护者或所有者角色。
> 要阻止用户创建项目，作为管理员，您可以将该用户标记为[外部用户](../administration/external_users.md)。

<a id="buy-more-seats"></a>

## 购买更多席位

{{< details >}}

- Offering: JihuLab.com，极狐GitLab 私有化部署

{{< /details >}}

您的订阅费用基于计费周期内使用的最大席位数。

如果限制访问：
- 已开启，当订阅中没有剩余席位时，您必须购买更多席位，群组才能添加新的可计费用户。
- 已关闭，当订阅中没有剩余席位时，群组可以继续添加可计费用户。极狐GitLab 会向您收取超额费用。

在以下情况下，您无法为订阅购买席位：
- 您是通过[授权经销商](billing_account.md#subscription-purchased-through-a-reseller)（包括 GCP 和 AWS 市场）购买的订阅。请联系经销商添加席位。
- 您签订了多年期订阅。请联系[销售团队](https://customers.jihulab.com/contact_us)添加席位。

要购买订阅席位：

1. 登录 [Customers Portal](https://customers.jihulab.com/)。
1. 进入 **Subscriptions & purchases** 页面。
1. 在相应订阅卡上选择 **Add seats**。
1. 输入需添加的用户数。
1. 查看 **Purchase summary** 部分。系统会列出所有用户的总价以及您已支付部分的抵扣，仅对净变化收费。
1. 输入您的支付信息。
1. 勾选 **I accept the Privacy Statement and Terms of Service** 复选框。
1. 选择 **Purchase seats**。

您将通过电子邮件收到付款收据。
也可以在 Customers Portal 的 [**Invoices**](https://customers.jihulab.com/invoices) 下获取该收据。

<a id="reduce-seats"></a>

## 减少席位

您只能在进行订阅续费时减少席位。
如需减少订阅席位数，您可以[按更少的席位数续费](manage_subscription.md#renew-for-fewer-seats)。

<a id="self-managed-billing-and-usage"></a>

## 极狐GitLab 私有化部署计费与用量

{{< details >}}

- Offering: 极狐GitLab 私有化部署

{{< /details >}}

极狐GitLab 私有化部署订阅采用混合模式。您根据订阅期内启用的最大用户数付费。

对于非离线或封闭网络的实例，极狐GitLab 私有化部署实例的最大并发用户数每季度核查一次。

如果实例无法生成季度用量报告，则使用现有的补差模型。无季度用量报告则无法按比例计费。

订阅用户数代表您当前许可证中包含的用户数，基于您已支付的费用。
除非购买更多席位，此数值在整个订阅期内保持不变。

最大用户数反映当前许可证周期内系统上可计费用户的最高数量。

您可以查看和管理[可计费用户](../administration/moderate_users.md#billable-users)及[许可证用量](../administration/license_usage.md)。

如需增加许可证覆盖的用户数，请在订阅期内购买更多席位。订阅期内新增席位的费用从购买日期至订阅期末按比例计算。
即使达到许可证用户数，您仍可继续添加用户。极狐GitLab 会向您收取超额费用。

如果您的订阅使用激活码激活，新增席位会立即反映在实例中。如果使用许可证文件，您将收到更新后的文件。要添加席位，请将许可证文件添加到实例中。

如果[ LDAP 与极狐GitLab 集成](../administration/auth/ldap/_index.md)，所配置域中的任何人都可以注册极狐GitLab 账户。
这可能导致续费时出现意料之外的账单。
如果您的实例允许创建新用户账户，任何能访问实例的人都可以注册账户。

为防止意外超额，请参阅席位管理最佳实践。

<a id="gitlab-com-billing-and-usage"></a>

## JihuLab.com 计费与用量

{{< details >}}

- Offering: JihuLab.com

{{< /details >}}

JihuLab.com 订阅采用并发（席位）模式。
您可以选择一个席位数量，这些席位允许用户同时使用订阅功能，并根据计费周期内分配给顶级群组、其子群组和项目的最大用户数付费。

您可以在订阅期内添加和移除用户，无需额外付费，只要任意时刻的总用户数不超过订阅席位数即可。
如果添加更多用户超出了已购席位数，会产生超额费用，该费用将计入下一张发票。

<a id="seat-usage-alerts"></a>

### 席位使用警报

{{< history >}}

- 在极狐GitLab 15.2 引入，带有一个名为 `seat_flag_alerts` 的[功能标志](../administration/feature_flags/_index.md)。
- 在极狐GitLab 15.4 GA，功能标志 `seat_flag_alerts` 已移除。

{{< /history >}}

如果您是绑定到订阅且已登记参加季度订阅对账的顶级群组的所有者角色，您会收到有关订阅席位用量的警报。

警报会显示在群组、子群组和项目页面上。
关闭警报后，在再次使用席位之前不会再次显示。

警报在以下阈值显示：

| 订阅席位数 | 警报               |
|-----------------------|---------------------|
| 0-15                  | 剩余一个席位。   |
| 16-25                 | 剩余两个席位。   |
| 26-99                 | 剩余 10% 席位。 |
| 100-999               | 剩余 8% 席位。   |
| 1000+                 | 剩余 5% 席位。   |

<a id="view-seat-usage"></a>

### 查看席位使用情况

要查看正在使用的席位列表：

1. 在顶部菜单栏，选择 **搜索或跳转到**，并查找您的群组。
1. 在左侧边栏，选择 **设置** > **用量配额**。
1. 选择 **Seats** 选项卡。

对于每位用户，列表会显示其作为直接成员的群组和项目。

- **Group invite** 表示该用户是[被邀请至群组的群组](../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-group)的成员。
- **Project invite** 表示该用户是[被邀请至项目的群组](../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-project)的成员。

席位用量列表中的 **Seats in use** 和 **Seats in subscription** 数据实时更新。
**Max seats used** 和 **Seats owed** 计数每天更新一次。

<a id="view-billing-information"></a>

#### 查看账单信息

要查看订阅信息和席位计数摘要：

1. 在顶部菜单栏，选择 **搜索或跳转到**，并查找您的群组。
1. 在左侧边栏，选择 **设置** > **Billing**。

- 用量统计每天更新一次，这可能会导致 **Usage quotas** 页面和 **Billing page** 页面中的信息存在差异。
- **Last login** 字段在用户退出登录后重新登录时更新。如果用户重新认证时已有活跃会话（例如，24 小时 SAML 会话超时后），此字段不会更新。

<a id="search-users-seat-usage"></a>

### 搜索用户的席位使用情况

您可以查看在订阅中使用席位的用户。
要搜索用户的席位使用情况：

1. 在顶部菜单栏，选择 **搜索或跳转到**，并查找您的群组。
1. 在左侧边栏，选择 **设置** > **用量配额**。
1. 在 **Seats** 选项卡中的搜索字段，输入用户的姓名或用户名。
   搜索字符串必须至少包含三个字符。

搜索将返回名字、姓氏或用户名与搜索字符串匹配的用户列表。

例如，对于名为 Amir 的用户，搜索字符串 `ami` 会产生匹配，但 `amr` 不会。

<a id="export-seat-usage-data"></a>

### 导出席位使用数据

要将席位使用数据导出为 CSV 文件：

1. 在顶部菜单栏，选择 **搜索或跳转到**，并查找您的群组。
1. 在左侧边栏，选择 **设置** > **用量配额**。
1. 在 **Seats** 选项卡中，选择 **Export list**。

<a id="export-seat-usage-history"></a>

### 导出席位使用记录

前提条件：

- 您必须具有该群组的所有者角色。

要将席位使用记录导出为 CSV 文件：

1. 在顶部菜单栏，选择 **搜索或跳转到**，并查找您的群组。
1. 在左侧边栏，选择 **设置** > **用量配额**。
1. 在 **Seats** 选项卡中，选择 **Export seat usage history**。

生成的列表包含所有正在使用的席位，且不受当前搜索条件影响。

<a id="remove-users-from-subscription"></a>

### 从订阅中移除用户

要从 JihuLab.com 订阅中移除可计费用户：

1. 在顶部菜单栏，选择 **搜索或跳转到**，并查找您的群组。
1. 在左侧边栏，选择 **设置** > **Billing**。
1. 在 **Seats currently in use** 部分，选择 **See usage**。
1. 在要移除的用户行右侧，选择 **Remove user**。
1. 重新输入用户名并选择 **Remove user**。

如果您是通过与其他群组共享群组的方式添加成员，则无法使用此方法移除该成员。此时，您可以：

- [从共享群组中移除该成员](../user/group/_index.md#remove-a-member-from-the-group)。
- [移除被邀请的群组](../user/project/members/sharing_projects_groups.md#remove-an-invited-group)。

<a id="enterprise-agile-planning"></a>

## 企业敏捷规划

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 企业敏捷规划是一个附加组件，帮助将非工程用户引入同一个 DevSecOps 平台，在该平台工程师进行代码构建、测试、安全扫描和部署。
该附加组件支持开发者与非开发者之间的跨团队协作，而无需为非工程团队成员购买极狐GitLab 旗舰版许可证。

通过企业敏捷规划席位，非工程团队成员可以参与规划工作流、利用价值流分析衡量软件交付速度和影响，并使用高管仪表板提高组织可见性。

有关企业敏捷规划席位的更多信息及如何购买，请联系您的[极狐GitLab 销售代表](https://customers.jihulab.com/contact_us)。

<a id="using-enterprise-agile-planning-seats"></a>

### 使用企业敏捷规划席位

用户占用企业敏捷规划席位的条件是：

- 您的订阅包含已购买的企业敏捷规划席位。
- 用户在顶级群组、其子群组和项目中的最高[角色](../user/permissions.md#default-roles)为计划者。

在以下情况下，用户将占用旗舰版席位而非企业敏捷规划席位：

- 您的订阅不包含已购买的企业敏捷规划席位。
- 被分配为计划者角色的用户在组织层次结构中的任何位置（如开发者或维护者）被分配了更高角色。

要使用已购买的企业敏捷规划席位，您必须先将计划者角色分配给[群组](../user/group/_index.md#add-users-to-a-group)或[项目](../user/project/members/_index.md#add-users-to-a-project)中的用户。

为防止具有计划者角色的用户被分配不同角色进而占用旗舰版席位，您可以使用[全局 SAML 群组成员身份锁定](../user/group/saml_sso/group_sync.md)。

您可以在[订阅详情](manage_subscription.md#view-subscription)和 [Customers Portal](billing_account.md) 中查看已使用的企业敏捷规划席位数量。
在极狐GitLab 私有化部署上，您还可以在[用户统计](../administration/admin_area.md#users-statistics)中查看按角色划分的用户总数。

<a id="best-practices"></a>

## 最佳实践

要有效管理订阅席位并控制成本，请遵循以下最佳实践。

初始设置：

- [关闭新用户账户创建](../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)。
- 通过 [LDAP](../administration/auth/ldap/_index.md#basic-configuration-settings) 或 [OmniAuth](../integration/omniauth.md#configure-common-settings) 自动屏蔽新用户。
- 要求对[新账户](../administration/settings/sign_up_restrictions.md#require-administrator-approval-for-new-user-accounts)和[角色提升](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)进行审批，以从一开始就控制席位分配。
- 使用席位控制开启限制访问，或为[群组](../user/group/manage.md#user-cap-for-groups)或[实例](../administration/settings/sign_up_restrictions.md#user-cap)设置用户上限，防止意外席位占用。
- 尽可能分配不计费的角色，如访客（基础版和旗舰版）或最小访问权限，以减少席位占用。

定期活动：

- 定期监控席位用量和用户统计，以识别潜在的超额情况。
- 对席位不足时提醒的席位使用警报采取行动。
- 自动[停用](../administration/moderate_users.md#automatically-deactivate-dormant-users)或[移除](../user/group/moderate_users.md#automatically-remove-dormant-members)不活跃成员，为活跃团队成员释放席位。

战略规划：

- 为非工程团队成员使用企业敏捷规划席位，而非完整的旗舰版席位。
- 在接近上限时提前购买席位，为增长做好规划。
- 导出并分析席位使用记录，以预测未来需求。