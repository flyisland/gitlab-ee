---

stage: Fulfillment
group: Subscription Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Seat usage, compute minutes, storage limits, renewal info.
title: JihuLab.com 订阅

---

{{< details >}}

1. Tier: 专业版，旗舰版
1. Offering: JihuLab.com

{{< /details >}}

{{< alert type="note" >}}

极狐GitLab SaaS 订阅正在更名为 JihuLab.com。在此过渡期间，您可能会在用户界面和文档中看到极狐GitLab SaaS 和 JihuLab.com 的引用。

{{< /alert >}}

JihuLab.com 是极狐GitLab 的多租户软件即服务 (SaaS) 提供。您无需安装任何东西即可使用 JihuLab.com，您只需[注册](https://jihulab.com/users/sign_up)。注册时，您可以选择：

- [一个订阅](https://gitlab.cn/pricing/)。
- [您想要的席位数量](#how-seat-usage-is-determined)。

<a id="obtain-a-gitlabcom-subscription"></a>

## 获取 JihuLab.com 订阅

JihuLab.com 订阅适用于顶级群组。群组中的每个子群组和项目的成员：

- 可以使用订阅的功能。
- 消耗订阅中的席位。

要订阅 JihuLab.com：

1. 查看 [JihuLab.com 功能比较](https://gitlab.cn/pricing/feature-comparison/) 并决定您想要哪个级别。
1. 使用[注册页面](https://jihulab.com/users/sign_up)为自己创建一个用户帐户。
1. 创建一个 [群组](../../user/group/_index.md#create-a-group)。您的订阅级别适用于顶级群组、其子群组和项目。
1. 创建其他用户并[将他们添加到群组](../../user/group/_index.md#add-users-to-a-group)。此群组、其子群组和项目中的用户可以使用您的订阅级别的功能，并且他们会消耗您的订阅中的席位。
1. 在左侧侧边栏中，选择 **设置 > 计费** 并选择一个级别。您将进入客户门户。
1. 填写表格以完成购买。

<a id="view-gitlabcom-subscription"></a>

## 查看 JihuLab.com 订阅

先决条件：

- 您必须拥有群组的所有者角色。

要查看您的 JihuLab.com 订阅状态：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 计费**。

显示以下信息：

| 字段                       | 描述 |
|:----------------------------|:------------|
| **订阅中的席位**   | 如果这是付费计划，则表示您为该群组购买的席位数量。 |
| **当前使用的席位**  | 使用中的席位数量。选择 **查看使用情况** 以查看使用这些席位的用户列表。 |
| **使用的最大席位**          | 您使用的最高席位数量。 |
| **欠下的席位**              | **使用的最大席位** 减去 **订阅中的席位**。 |
| **订阅开始日期** | 您的订阅开始的日期。 |
| **订阅结束日期**   | 您当前订阅结束的日期。 |

<a id="renew-gitlabcom-subscription"></a>

## 续订 JihuLab.com 订阅

在订阅到期前 15 天，极狐GitLab 用户界面会显示包含订阅到期日期的横幅给群组所有者。

在您续订 JihuLab.com 订阅之前，您应该[审查您的帐户](../self_managed/_index.md#review-your-account)。

您可以[手动](../self_managed/_index.md#renew-subscription-manually)或[自动](#automatic-subscription-renewal)续订您的订阅。您的更新订阅应用于您的命名空间。续订期开始日期显示在群组计费页面上的 **下一个订阅期限开始日期** 下。

您可以随时查看和[管理续订发票](../self_managed/_index.md#manage-renewal-invoice)。

<a id="renew-for-fewer-seats"></a>

### 为较少的席位续订

席位较少的订阅续订必须具有或超过当前的计费用户数量。在您续订订阅之前，如果超出您想要续订的席位数量，[减少计费用户数量](#remove-users-from-subscription)。

要手动为较少的席位续订订阅，您可以：

- 在订阅续订日期的 15 天内[手动续订](../self_managed/_index.md#renew-subscription-manually)。确保在续订时指定席位数量。
- [禁用自动续订您的订阅](../self_managed/_index.md#enable-or-disable-automatic-subscription-renewal)，并联系[销售团队](https://support.gitlab.cn/#/portal/index)以续订您想要的席位数量。

<a id="automatic-subscription-renewal"></a>

### 自动订阅续订

当订阅设置为自动续订时，它会在到期日期的午夜 UTC 自动续订，而不会中断可用服务。您将在订阅自动续订之前收到[电子邮件通知](../self_managed/_index.md#email-notifications)。通过客户门户或 JihuLab.com 购买的订阅默认设置为自动续订，但您可以[禁用自动订阅续订](../self_managed/_index.md#enable-or-disable-automatic-subscription-renewal)。

如果席位数量高于当前订阅数量，则席位数量会调整以适应[续订时您群组中的计费用户数量](#view-seat-usage)。

<a id="expired-subscriptions"></a>

## 过期订阅

当您的订阅到期时，您可以继续使用极狐GitLab 的付费功能 14 天。第 15 天起，付费功能将不再可用。您可以继续使用基础版功能。

例如，如果订阅开始日期为 2024 年 1 月 1 日，结束日期为 2025 年 1 月 1 日：

- 它在 2024 年 12 月 31 日晚上 11:59:59 UTC 到期。
- 它被视为 2025 年 1 月 1 日凌晨 12:00:00 UTC 起过期。
- 14 天的宽限期从 2025 年 1 月 1 日凌晨 12:00:00 UTC 开始，到 2025 年 1 月 14 日晚上 11:59:59 UTC 结束。
- 自 2025 年 1 月 15 日凌晨 12:00:00 UTC 起，付费功能将不再可用。

要恢复付费功能，购买新的订阅。

<a id="upgrade-subscription-tier"></a>

## 升级订阅级别

要升级您的[极狐GitLab 级别](https://gitlab.cn/pricing/)：

1. 登录到[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在相关订阅卡上选择 **升级**。
1. 选择所需的升级。
1. 确认活动的付款方式或添加新的付款方式。
1. 勾选 **我接受隐私声明和服务条款** 复选框。
1. 选择 **确认购买**。

购买处理完成后，您将收到新订阅级别的确认。

<a id="add-or-change-subscription-contacts"></a>

## 添加或更改订阅联系人

联系人可以续订订阅、取消订阅或将订阅转移到不同的命名空间。

您可以[更改个人信息所有者信息](../customers_portal.md#change-profile-owner-information)并[为您的订阅添加第二联系人](../customers_portal.md#add-a-secondary-contact)。

<a id="how-seat-usage-is-determined"></a>

## 如何确定席位使用情况

JihuLab.com 订阅使用并发（_席位_）模型。您根据顶级群组、其子群组和项目在计费期间分配的最大用户数量支付订阅费用。您可以在订阅期间添加和删除用户，而不会产生额外费用，只要在任何给定时间的总用户数量不超过订阅数量即可。如果总用户数超过您的订阅数量，您将产生超额费用，必须在下次[对账](../quarterly_reconciliation.md)时支付。

顶级群组可以像其他群组一样[更改](../../user/group/manage.md#change-a-groups-path)。

<a id="billable-users"></a>

### 计费用户

计费用户计入您订阅中购买的订阅席位数量。

如果用户属于以下情况，则不计为计费用户：

- 他们正在等待审批。
- 他们仅在[旗舰版订阅中拥有访客角色](#free-guest-users)。
- 他们仅拥有任何 JihuLab.com 订阅的[最小访问角色](../../user/permissions.md#users-with-minimal-access)。
- 他们是[被禁止的成员](../../user/group/moderate_users.md#ban-a-user)。
- 他们是[被阻止的用户](../../administration/moderate_users.md#block-a-user)。
- 该帐户是极狐GitLab 创建的服务帐户：
  - [幽灵用户](../../user/profile/account/delete_account.md#associated-records)。
  - 机器人：
    - [支持机器人](../../user/project/service_desk/configure.md#support-bot-user)。
    - [项目的机器人用户](../../user/project/settings/project_access_tokens.md#bot-users-for-projects)。
    - [群组的机器人用户](../../user/group/settings/group_access_tokens.md#bot-users-for-groups)。

席位使用情况每季度或每年[审查](../quarterly_reconciliation.md)。

如果用户查看或选择不同的顶级群组（例如他们自己创建的群组），并且该群组没有付费订阅，则用户不会看到任何付费功能。

用户可以属于两个具有不同订阅的顶级群组。在这种情况下，用户仅看到该订阅可用的功能。

<a id="free-guest-users"></a>

### 免费访客用户

{{< details >}}

1. Tier: 旗舰版
1. Offering: JihuLab.com, 极狐GitLab 私有化部署

{{< /details >}}

在 **旗舰版** 级别，分配访客角色的用户不会消耗席位。用户不得在实例或 JihuLab.com 的命名空间中分配任何其他角色。

- 如果您的项目是：
  - 私有或内部，具有访客角色的用户具有[一组权限](../../user/permissions.md#project-members-permissions)。
  - 公共，所有用户，包括具有访客角色的用户，都可以访问您的项目。
- 对于 JihuLab.com，如果具有访客角色的用户在其个人命名空间中创建项目，则用户不会消耗席位。该项目位于用户的个人命名空间，与具有旗舰版订阅的群组无关。

<a id="seats-owed"></a>

### 欠下的席位

如果计费用户数量超过 **订阅中的席位** 数量，称为 **欠下的席位** 数量，您必须为超额用户支付费用。

例如，如果您为 10 个用户购买订阅：

| 事件                                              | 计费成员 | 最大用户 |
|:---------------------------------------------------|:-----------------|:--------------|
| 十个用户占用了所有 10 个席位。                     | 10               | 10            |
| 两个新用户加入。                                | 12               | 12            |
| 三个用户离开并删除了他们的帐户。  | 9                | 12            |

欠下的席位 = 12 - 10 (最大用户 - 订阅中的用户)

为了防止欠下的席位产生费用，您可以[开启限制访问](../../user/group/manage.md#turn-on-restricted-access)。此设置会限制群组在订阅中没有剩余席位时添加新的计费用户。

<a id="seat-usage-alerts"></a>

### 席位使用警报

{{< history >}}

1. 引入于极狐GitLab 15.2，使用名为 `seat_flag_alerts` 的[功能标志](../../administration/feature_flags.md)。
1. 在极狐GitLab 15.4 中 GA。功能标志 `seat_flag_alerts` 被移除。

{{< /history >}}

如果您拥有顶级群组的所有者角色，警报会通知您您的总席位使用情况。

警报显示在群组、子群组和项目页面上，并且仅适用于与参与[季度订阅对账](../quarterly_reconciliation.md)的订阅链接的顶级群组。警报被关闭后，在使用另一个席位之前不会显示。

警报显示基于以下席位使用情况。您无法配置警报显示的数量。

| 订阅中的席位 | 警报显示时 |
|-----------------------|---------------------|
| 0-15                  | 剩余一个席位。   |
| 16-25                 | 剩余两个席位。   |
| 26-99                 | 剩余 10% 的席位。|
| 100-999               | 剩余 8% 的席位。 |
| 1000+                 | 剩余 5% 的席位。 |

<a id="view-seat-usage"></a>

## 查看席位使用情况

要查看正在使用的席位列表：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 使用配额**。
1. 选择 **席位** 选项卡。

对于每个用户，列表显示用户是直接成员的群组和项目。

- **群组邀请** 表示用户是[受邀加入群组的群组](../../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-group)的成员。
- **项目邀请** 表示用户是[受邀加入项目的群组](../../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-project)的成员。

席位使用列表中的数据、**使用中的席位** 和 **订阅中的席位** 是实时更新的。**使用的最大席位** 和 **欠下的席位** 的计数每天更新一次。

<a id="view-billing-information"></a>

### 查看计费信息

要查看您的订阅信息和席位计数摘要：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 计费**。

- 使用统计数据每天更新一次，这可能导致 **使用配额** 页面和 **计费页面** 中的信息之间出现差异。
- **上次登录** 字段在用户注销后再次登录时更新。如果用户重新验证时存在活动会话（例如，在 24 小时 SAML 会话超时后），则此字段不会更新。

<a id="search-seat-usage"></a>

## 搜索席位使用情况

要搜索席位使用情况：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 使用配额**。
1. 在 **席位选项卡** 中，在搜索字段中输入字符串。需要至少 3 个字符。

搜索返回用户的名字、姓氏或用户名包含搜索字符串。

例如：

| 名字 | 搜索字符串 | 匹配？ |
|:-----------|:--------------|:--------|
| Amir       | `ami`         | 是     |
| Amir       | `amr`         | 否      |

<a id="export-seat-usage"></a>

## 导出席位使用情况

要将席位使用数据导出为 CSV 文件：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 使用配额**。
1. 在 **席位** 选项卡中，选择 **导出列表**。

<a id="export-seat-usage-history"></a>

## 导出席位使用历史记录

先决条件：

- 您必须拥有群组的所有者角色。

要将席位使用历史记录导出为 CSV 文件：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 使用配额**。
1. 在 **席位** 选项卡中，选择 **导出席位使用历史记录**。

生成的列表包含所有正在使用的席位，并不受当前搜索的影响。

<a id="add-seats-to-subscription"></a>

## 向订阅添加席位

您的订阅费用是基于计费期间您使用的最大席位数量。

- 如果开启了[限制访问](../../user/group/manage.md#turn-on-restricted-access)，当您的订阅中没有剩余席位时，您必须购买更多席位以便群组添加新的计费用户。
- 如果关闭了限制访问，当您的订阅中没有剩余席位时，群组可以继续添加计费用户。极狐GitLab 会[向您收取超额费用](../quarterly_reconciliation.md)。

如果您通过[授权经销商](../customers_portal.md#customers-that-purchased-through-a-reseller)（包括 GCP 和 AWS 市场）购买订阅，则无法向您的订阅添加席位。请联系经销商添加更多席位。

如果您有多年订阅，请联系[销售团队](https://support.gitlab.cn/#/portal/index)以添加更多席位。

要向订阅添加席位：

1. 登录到[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 转到 **订阅和购买** 页面。
1. 在相关订阅卡上选择 **添加席位**。
1. 输入额外用户的数量。
1. 查看 **购买摘要** 部分。系统列出了所有用户的总价格以及您已支付的费用的信用额度。您只需支付净变化费用。
1. 输入您的付款信息。
1. 勾选 **我接受隐私声明和服务条款** 复选框。
1. 选择 **购买席位**。

<a id="remove-users-from-subscription"></a>

## 从订阅中移除用户

要从您的 JihuLab.com 订阅中移除计费用户：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 计费**。
1. 在 **当前使用的席位** 部分，选择 **查看使用情况**。
1. 在您要移除的用户所在行的右侧，选择 **移除用户**。
1. 重新输入用户名并选择 **移除用户**。

如果您通过[与其他群组共享群组](../../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-group)功能添加成员到群组，您无法通过此方法移除成员。相反，您可以：

- [从共享群组中移除成员](../../user/group/_index.md#remove-a-member-from-the-group)。
- [移除受邀群组](../../user/project/members/sharing_projects_groups.md#remove-an-invited-group)。

<a id="link-subscription-to-a-group"></a>

## 将订阅链接到群组

要更改与 JihuLab.com 订阅链接的群组：

1. 使用与[链接](../customers_portal.md#link-a-gitlabcom-account)的 JihuLab.com 帐户登录到[客户门户](https://customers.gitlab.com/customers/sign_in)。
1. 执行以下操作之一：
   - 如果订阅未链接到群组，选择 **将订阅链接到群组**。
   - 如果订阅已链接到群组，选择 **订阅操作** ({{< icon name="ellipsis_v" >}}) > **更改链接的群组**。
1. 从 **新命名空间** 下拉列表中选择所需的群组。要在此处显示群组，您必须拥有该群组的所有者角色。
1. 如果您群组中的[用户总数](#view-seat-usage)超过您订阅中的席位数量，系统会提示您为额外用户支付费用。订阅费用是基于群组中的用户总数计算的，包括其子群组和嵌套项目。

   如果您通过授权经销商购买订阅，则无法为额外用户支付费用。您可以：

   - 移除额外用户，以便没有检测到超额。
   - 联系合作伙伴以便在您的订阅期限结束或现在购买额外席位。

1. 选择 **确认更改**。

只有一个命名空间可以链接到订阅。

<a id="transfer-restrictions"></a>

### 转移限制

您可以更改链接的命名空间，但这并不适用于所有订阅类型。

您不能转移：

- 过期或试用订阅。
- 已链接到命名空间且具有计算分钟的订阅。
- 将具有专业版或旗舰版计划的订阅转移到已经具有专业版或旗舰版计划的命名空间。
- 将具有极狐GitLab Duo 附加组件的订阅转移到已经具有极狐GitLab Duo 附加组件的订阅的命名空间。

<a id="compute-minutes"></a>

## 计算分钟

[计算分钟](../../ci/pipelines/compute_minutes.md)是在极狐GitLab 实例 runner 上运行[CI/CD 流水线](../../ci/_index.md)时消耗的资源。如果计算分钟用完，您可以[购买额外的计算分钟](compute_minutes.md)。

<a id="enterprise-agile-planning"></a>

## 企业敏捷规划

极狐GitLab 企业敏捷规划是一个附加组件，可帮助非技术用户进入同一 DevSecOps 平台，在那里工程师构建、测试、保护和部署代码。该附加组件使开发人员和非开发人员之间能够进行跨团队协作，而无需为非工程团队成员购买完整的极狐GitLab 许可证。通过企业敏捷规划席位，非工程团队成员可以参与规划工作流，通过价值流分析衡量软件交付速度和影响，并使用执行仪表板推动组织可见性。

<a id="purchase-more-storage"></a>

## 购买更多存储

{{< details >}}

1. Tier: 基础版

{{< /details >}}

{{< alert type="note" >}}

要超过您的基础版 JihuLab.com 命名空间的 5 GiB 免费级别限制，您可以为您的个人或群组命名空间购买更多存储。

{{< /alert >}}

先决条件：

- 您必须拥有所有者角色。

{{< alert type="note" >}}

存储订阅**每年自动续订**。您可以[禁用自动订阅续订](../self_managed/_index.md#enable-or-disable-automatic-subscription-renewal)。

{{< /alert >}}

<a id="for-your-personal-namespace"></a>

### 对于您的个人命名空间

1. 登录 JihuLab.com。
1. 从您的个人主页或群组页面转到 **设置 > 使用配额**。
1. 选择 **存储** 选项卡。
1. 对于每个只读项目，按其 **使用** 超过免费配额和购买的存储的总量。您必须购买超过此总量的存储增量。
1. 选择 **购买存储**。您将进入客户门户。
1. 在 **订阅详细信息** 部分，从下拉列表中选择用户的姓名。
1. 输入所需的存储包数量。
1. 在 **客户信息** 部分，验证您的地址。
1. 在 **计费信息** 部分，从下拉列表中选择付款方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买存储**。

**购买的可用存储** 总量增加了购买的数量。所有项目的只读状态被移除，其超额使用量从额外存储中扣除。

<a id="for-your-group-namespace"></a>

### 对于您的群组命名空间

如果您正在使用 JihuLab.com，您可以购买额外的存储，以便在您用完主配额中的所有存储后，您的流水线不会被阻止。您可以在[极狐GitLab 定价页面](https://gitlab.cn/pricing/#storage)上找到额外存储的定价。

要为您的群组在 JihuLab.com 上购买额外存储：

1. 在左侧侧边栏中，选择 **搜索或前往** 并找到您的群组。
1. 选择 **设置 > 使用配额**。
1. 选择 **存储** 选项卡。
1. 选择 **购买存储**。您将进入客户门户。
1. 在 **订阅详细信息** 部分，输入所需的存储包数量。
1. 在 **客户信息** 部分，验证您的地址。
1. 在 **计费信息** 部分，从下拉列表中选择付款方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买存储**。

付款处理完成后，额外的存储可用于您的群组命名空间。

要确认可用存储，请遵循上面列出的前三个步骤。

**购买的可用存储** 总量增加了购买的数量。所有锁定的项目都被解锁，其超额使用量从额外存储中扣除。
