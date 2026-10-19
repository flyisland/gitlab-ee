---
stage: Fulfillment
group: Subscription Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Buy, view, and renew your 极狐GitLab subscriptions.
title: 管理订阅
---

<a id="buy-a-subscription"></a>

购买订阅

在您 [注册](https://gitlab.com/users/sign_up) 极狐GitLab 后，
您可以购买 JihuLab.com 或私有化部署的订阅。
订阅决定了您的私有项目可以使用哪些功能。

订阅极狐GitLab 后，您可以管理订阅的详细信息。
如果您遇到任何问题，请参阅 [极狐GitLab 订阅疑难解答](gitlab_com/gitlab_subscription_troubleshooting.md)。

拥有公开开源项目的组织可以申请加入 [极狐GitLab 开源计划](community_programs.md#gitlab-for-open-source)。

<a id="for-gitlabcom"></a>

### 针对 JihuLab.com

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

JihuLab.com 是极狐GitLab 的多租户软件即服务（SaaS）产品。
您无需安装任何东西即可使用 JihuLab.com，只需 [注册](https://gitlab.com/users/sign_up) 即可。
注册时，您需要选择：

- [一个订阅](https://gitlab.cn/pricing/)。
  查看 [JihuLab.com 功能比较](https://gitlab.cn/pricing/feature-comparison/)，决定您想要的版本。
- 所需的席位数量。
- 一个 极狐GitLab Credits 选项。

JihuLab.com 的订阅适用于顶级群组。
群组内每个子群组和项目的成员：

- 可以使用订阅的功能。
- 会占用订阅中的席位。

如果用户查看或选择其他顶级群组（例如他们自己创建的群组），
而该群组没有付费订阅，则用户不会看到任何付费功能。

一个用户可以属于两个不同的顶级群组，并拥有不同的订阅。
在这种情况下，用户只能看到该订阅可用的功能。

要订阅 JihuLab.com：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **计费**。
1. 选择 **升级订阅**。
1. 选择一个版本和一个 极狐GitLab Credits 选项。
1. 选择 **继续结账**。您将被重定向到客户门户。
1. 在 **席位** 字段中，输入所需的席位数量。
1. 查看订阅详情和账单信息。
1. 选中 **我接受隐私声明和服务条款** 复选框。
1. 选择 **购买订阅**。

<a id="for-gitlab-self-managed"></a>

### 针对私有化部署

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要为私有化部署实例订阅极狐GitLab：

1. 访问 [定价页面](https://gitlab.cn/pricing/) 并选择一个私有化部署方案。您将被重定向到 [客户门户](https://customers.jihulab.com/) 完成购买。
1. 购买后，激活码将发送至客户门户账户关联的邮箱地址。
   您必须 [将此激活码添加到您的极狐GitLab 实例](../administration/license.md)。

> [!note]
> 如果您为现有的 **基础版** 私有化部署实例购买订阅，请确保购买足够的席位，
> 以 [覆盖您的用户](../administration/admin_area.md#administering-users)。

<a id="view-subscription"></a>

查看订阅

<a id="for-gitlabcom-1"></a>

### 针对 JihuLab.com

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

前提条件：

- 您必须拥有该群组的 所有者 角色。

要查看您的 JihuLab.com 订阅状态：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **计费**。

将显示以下信息：

| 字段                         | 描述 |
|:----------------------------|:------------|
| **订阅中的席位**               | 如果是付费方案，表示您为该群组购买的席位数量（包括企业级敏捷规划席位）。 |
| **当前已用席位**               | 正在使用的席位数量。选择 **查看使用情况** 可查看使用这些席位的用户列表。 |
| **已用最大席位数**             | 您曾使用的最高席位数。 |
| **欠缴席位**                  | **已用最大席位数** - **订阅中的席位**。 |
| **订阅开始日期**               | 订阅开始的日期。 |
| **订阅结束日期**               | 当前订阅结束的日期。 |

<a id="for-gitlab-self-managed-1"></a>

### 针对私有化部署

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 您必须是管理员。

您可以查看订阅状态：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **订阅**。

**订阅** 页面包括以下信息：

- 被许可方
- 方案
- 上传时间、开始时间以及过期时间
- 订阅中的用户数（包括企业级敏捷规划席位）
- 计费用户数
- 最大用户数
- 超出订阅的用户数

<a id="review-your-account"></a>

审查您的账户

您应该定期审查您的计费账户设置和购买信息。

要审查您的计费账户设置：

1. 登录 [客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 选择 **计费账户设置**。
1. 验证或更新：
   - 在 **支付方式** 下，存档的信用卡。
   - 在 **公司信息** 下，订阅和账单联系人详细信息。
1. 保存任何更改。

您还应该定期审查您的用户账户，以确保您仅为正确数量的活跃计费用户续订。非活跃用户账户：

- 可能被计为用户。如果您为非活跃用户账户续订，您支付的费用会超出应支付的金额。
- 可能带来安全风险。定期审查有助于降低此风险。

有关更多信息，请参阅以下文档：

- [用户统计](../administration/admin_area.md#users-statistics)。
- [许可证使用情况](../administration/license_usage.md)。
- [管理用户和订阅席位](manage_seats.md)。

<a id="upgrade-subscription-tier"></a>

升级订阅版本

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

前提条件：

- 您必须是计费账户管理员。

要升级您的 [极狐GitLab 版本](https://gitlab.cn/pricing/)：

1. 登录 [客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 在相关订阅卡片上选择 **升级方案**。
1. 选择您要升级到的方案。
1. 选择 **继续结账**。
1. 查看升级详情和账单信息。
1. 选中 **我接受隐私声明和服务条款** 复选框。
1. 选择 **升级订阅**。

以下内容将通过电子邮件发送给您：

- 付款收据。您也可以在客户门户的 [**发票**](https://customers.jihulab.com/invoices) 下访问此信息。
- 对于私有化部署，您将收到一个新的许可证激活码。

在私有化部署实例上，新版本将在下次订阅同步时生效。
您也可以 [手动同步订阅](#subscription-data-synchronization) 以立即升级。

在 JihuLab.com 上，购买订阅时您还可以选择一个 极狐GitLab Credits 选项。

<a id="renew-subscription"></a>

续订订阅

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在订阅续订日期之前，您应该审查您的账户，检查当前的席位使用情况和计费用户数量。

您可以自动或手动续订订阅。
如果您想要执行以下任一操作，则应手动续订订阅：

- 减少席位数量进行续订。
- 增加或减少续订产品的数量。
- 删除续订期内不再需要的附加产品。
- 升级订阅版本。

续订期开始日期显示在群组计费页面的 **下一个订阅期开始日期** 下。

联系：

- [支持团队](https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=360000071293) 如果您在访问客户门户或更改管理订阅的联系人时需要帮助。
- [销售团队](https://customers.jihulab.com/contact_us) 如果您在续订订阅时需要帮助。

<a id="check-when-subscription-expires"></a>

### 检查订阅何时到期

在订阅到期前 15 天，极狐GitLab 用户界面中会为管理员显示一个包含订阅到期日期的横幅。

您无法在订阅到期前 15 天以上手动续订订阅。要检查何时可以续订：

1. 登录 [客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 选择 **订阅操作**（{{< icon name="ellipsis_v" >}}），然后选择 **续订订阅** 查看您可以续订的日期。

<a id="renew-automatically"></a>

### 自动续订

前提条件：

- 对于私有化部署，您必须 [同步订阅数据](#subscription-data-synchronization) 并在续订前至少两天审查您的账户，以确保您的更改已同步。

当订阅设置为自动续订时，它会在到期日期的 UTC 午夜自动续订，不会出现服务中断。
在订阅自动续订之前，您会收到 [电子邮件通知](#renewal-notifications)。

续订时，席位数量不会自动减少。如果续订时您的计费用户数超过当前订阅数量，您的席位数量将自动增加，以匹配您的 [群组](manage_seats.md#view-seat-usage) 或 [实例](../administration/moderate_users.md#view-users) 中的当前用户数。
要避免意外为更多席位续订，请了解如何 [减少席位进行续订](#renew-for-fewer-seats)。

通过客户门户购买的订阅默认设置为自动续订，
但您可以 [关闭自动订阅续订](#turn-on-or-turn-off-automatic-subscription-renewal)。

<a id="turn-on-or-turn-off-automatic-subscription-renewal"></a>

#### 开启或关闭自动订阅续订

您可以使用客户门户开启或关闭自动订阅续订：

1. 登录 [客户门户](https://customers.jihulab.com/customers/sign_in)。
   您将进入 **订阅和购买** 页面。
1. 检查订阅卡片：
   - 如果卡片显示 **到期日期为 DATE**，则您的订阅未设置为自动续订。要启用自动续订，在 **订阅操作**（{{< icon name="ellipsis_v" >}}）中，选择 **开启自动续订**。
   - 如果卡片显示 **将于 DATE 自动续订**，则您的订阅已设置为自动续订。要禁用自动续订：
     1. 在 **订阅操作**（{{< icon name="ellipsis_v" >}}）中，选择 **取消订阅**。
     1. 选择一个取消原因。
     1. 可选。在 **您还有什么要补充的吗？** 中，输入任何相关信息。
     1. 选择 **取消订阅**。

<a id="renew-manually"></a>

### 手动续订

要手动续订您的订阅：

1. 确定您在下一个订阅期内需要的用户数量。
1. 登录 [客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 在您现有的订阅下，选择 **开始续订**。此按钮在订阅到期前 15 天才会显示。
1. 如果续订专业版或旗舰版产品，在 **席位** 文本框中，输入您来年所需的用户席位总数。

   > [!note]
   > 请确保此数字等于或大于
   > 续订时系统中的 [计费用户](manage_seats.md#billable-users) 数量。

1. 可选。对于私有化部署，如果在上一订阅期内您的实例中的最大用户数超过了您许可的数量，则 [超额费用](quarterly_reconciliation.md) 将在续订时支付。

   在 **超出许可的用户数** 文本框中，输入产生的用户超额数量，即 [超出订阅的用户数](manage_seats.md#users-over-subscription-limit)。
1. 可选。如果续订附加产品，请审查并更新所需数量。您也可以删除产品。
1. 可选。如果升级订阅版本，请选择所需的选项。
1. 审查您的续订详情，然后选择 **续订订阅** 以完成付款流程。
1. 对于私有化部署，在 [订阅和购买](https://customers.jihulab.com/subscriptions) 页面的相关订阅卡片上，选择 **复制激活码** 以获取续订期激活码的副本，并将 [激活码添加到您的实例](../administration/license.md)。

要向您的订阅添加产品，请 [联系销售团队](https://customers.jihulab.com/contact_us)。

<a id="renew-for-fewer-seats"></a>

### 减少席位进行续订

以更少席位续订订阅时，必须等于或超过当前的计费用户数量。

在续订订阅之前：

- 对于 JihuLab.com，如果计费用户数超过您希望续订的席位数量，请 [减少计费用户数](manage_seats.md#remove-users-from-subscription)。
- 对于私有化部署，[阻止不活跃或不需要的用户](../administration/moderate_users.md#block-a-user)。

要以更少席位手动续订订阅，您可以：

- 在订阅续订日期前 15 天内 [手动续订](#renew-manually)。确保在续订时指定席位数量。
- [关闭订阅自动续订](#turn-on-or-turn-off-automatic-subscription-renewal)，然后联系 [销售团队](https://customers.jihulab.com/contact_us) 以所需席位数量进行续订。

<a id="renewal-notifications"></a>

### 续订通知

在订阅自动续订前 15 天，您将收到一封关于续订信息的电子邮件。

- 如果您的信用卡已过期，邮件会告知您如何更新。
- 如果您有任何未结的超额费用，或者由于任何其他原因无法自动续订，邮件会告知您联系我们的销售团队或在客户门户中手动续订。
- 如果没有问题，邮件会指定：
  - 续订产品的名称和数量。
  - 您应支付的总金额。如果您的使用量在续订前增加，此金额会发生变化。

<a id="manage-renewal-invoice"></a>

### 管理续订发票

您的续订会生成一张发票。要查看或下载此续订发票，
请前往 [客户门户发票页面](https://customers.jihulab.com/invoices)。

如果您的账户有 [存档的信用卡](billing_account.md#change-your-payment-method)，
该卡将被收取发票金额。

如果无法处理付款或由于任何其他原因自动续订失败，
您有 14 天的时间续订您的订阅，否则您的极狐GitLab 版本将被降级。

<a id="expired-subscription"></a>

过期的订阅

订阅将在到期日期的服务器时间 00:00 到期。

例如，如果订阅有效期为 2024 年 1 月 1 日至 2025 年 1 月 1 日：

- 它将于 2024 年 12 月 31 日 UTC 23:59:59 到期。
- 自 2025 年 1 月 1 日 UTC 00:00:00 起视为已过期。

如果您的订阅已过期，您仍可以在到期日期后 15 天内手动续订。15 天后，手动续订选项将不再可用，您必须购买新订阅才能恢复对付费功能的访问。

<a id="for-gitlabcom-2"></a>

### 针对 JihuLab.com

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

当您的订阅到期时，付费功能将不再可用。
但是，您可以继续使用免费功能。
要恢复付费功能，请续订您的订阅。

<a id="for-gitlab-self-managed-2"></a>

### 针对私有化部署

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当您的许可证到期时：

- 您的实例将变为只读。
- 极狐GitLab 会锁定功能，例如 Git 推送和议题创建。
- 所有实例管理员都会看到一条到期消息。

许可证过期后：

- 要恢复功能，
  [激活新订阅](../administration/license_file.md#activate-subscription-during-installation)。
- 仅继续使用基础版功能，
  [移除过期的许可证](../administration/license_file.md#remove-a-license)。

<a id="subscription-data-synchronization"></a>

订阅数据同步

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 极狐GitLab 企业版 (EE)。
- 连接互联网，并且不能处于离线环境。
- 已为您的实例 [激活](../administration/license.md) 激活码。

您的 [订阅数据](#subscription-data) 每天会在您的私有化部署实例与极狐GitLab 之间自动同步一次。

大约在 UTC 凌晨 3:00，此每日同步作业会将 [订阅数据](#subscription-data) 发送到客户门户。因此，更新和续订可能不会立即生效。

数据通过加密的 HTTPS 连接安全地发送到 `customers.jihulab.com` 的端口 `443`。如果作业失败，它会在约 17 小时内重试最多 12 次。

设置自动数据同步后，以下流程也会自动化。

- [季度订阅核对](quarterly_reconciliation.md)。
- 订阅续订。
- 订阅更新，例如添加更多席位或升级 极狐GitLab 版本。

<a id="manually-synchronize-subscription-data"></a>

### 手动同步订阅数据

前提条件：

- 管理员访问权限。

您也可以随时手动同步订阅数据。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **订阅**。
1. 在 **订阅详情** 部分，选择 **同步**（{{< icon name="retry" >}}）。

同步作业随后将排队。作业完成后，订阅详情将更新。

<a id="subscription-data"></a>

### 订阅数据

{{< history >}}

- 唯一实例 ID [引入于](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/189399) 极狐GitLab 18.1。

{{< /history >}}

每日同步作业会向客户门户发送以下信息：

- 日期
- 时间戳
- 许可证密钥，其中加密包含以下信息：
  - 公司名称
  - 被许可方名称
  - 被许可方电子邮件
- 历史 [最大用户数](manage_seats.md#self-managed-billing-and-usage)
- [计费用户数](manage_seats.md#billable-users)
- 极狐GitLab 版本
- 主机名
- 实例 ID
- 唯一实例 ID

此外，您还会获得附加组件的指标，例如：

- 附加组件类型
- 已购买席位
- 已分配席位

许可证同步请求示例：

```json
{
  "gitlab_version": "14.1.0-pre",
  "timestamp": "2021-06-14T12:00:09Z",
  "date": "2021-06-14",
  "license_key": "XXX",
  "max_historical_user_count": 75,
  "billable_users_count": 75,
  "hostname": "gitlab.example.com",
  "instance_id": "9367590b-82ad-48cb-9da7-938134c29088",
  "unique_instance_id": "a98bab6e-73e3-5689-a487-1e7b89a56901",
  "add_on_metrics": [
    {
      "add_on_type": "duo_enterprise",
      "purchased_seats": 100,
      "assigned_seats": 50
    }
  ]
}
```

<a id="link-subscription-to-a-group"></a>

将订阅关联到群组

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

前提条件：

- 一个群组命名空间。

一个订阅只能关联一个群组命名空间。

如果您的专业版或旗舰版订阅位于个人命名空间上，在关联您的订阅之前，您应该：

- [将您的项目](../user/project/working_with_projects.md#transfer-a-project) 转移到一个群组。
- [将您的个人命名空间转换为群组](../tutorials/convert_personal_namespace_to_group/_index.md)，以保留您现有的 URL。

要将您的订阅关联到一个群组或更改与 JihuLab.com 订阅关联的群组：

1. 使用一个 [已关联](billing_account.md#link-a-gitlabcom-account) 的 JihuLab.com 账户登录 [客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 执行以下操作之一：
   - 如果订阅尚未关联到群组，选择 **将订阅关联到群组**。
   - 如果订阅已关联到群组，选择 **订阅操作**（{{< icon name="ellipsis_v" >}}）> **更改关联的群组**。
1. 从 **新命名空间** 下拉列表中选择所需的群组。要使群组出现在此处，您必须具有该群组的 所有者 角色。
1. 如果您的群组中的 [用户总数](manage_seats.md#view-seat-usage) 超过订阅中的席位数量，
   您将被提示为额外的用户付费。订阅费用根据群组中的用户总数计算，包括其子群组和嵌套项目。

   如果您是通过授权经销商购买的订阅，则无法为额外用户付费。
   您可以：

   - 移除额外用户，以避免检测到超额。
   - 联系合作伙伴，立即或在订阅期结束时购买额外席位。

1. 选择 **确认更改**。

<a id="add-or-change-subscription-contacts"></a>

添加或更改订阅联系人

联系人可以续订订阅、取消订阅或将订阅转移到其他命名空间。

您可以 [更改个人资料所有者信息](billing_account.md#change-profile-owner-information)
以及 [添加另一位计费账户管理员](billing_account.md#add-a-billing-account-manager)。

<a id="transfer-restrictions"></a>

### 转移限制

您可以更改关联的命名空间，但并非所有订阅类型都支持此操作。

您无法转移：

- 已过期或试用的订阅。
- 已关联到命名空间的带有计算分钟数的订阅。
- 带有专业版或旗舰版方案的订阅转移至已拥有专业版或旗舰版方案的命名空间。
- 带有 极狐GitLab Duo 附加组件的订阅转移至已拥有 极狐GitLab Duo 附加组件订阅的命名空间。
- 带有专业版或旗舰版方案的订阅转移至个人命名空间。
- 使用折扣码购买的订阅。