---
stage: Fulfillment
group: Subscription Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Billable users, renewal and upgrade info.
title: 极狐GitLab 私有化部署订阅
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

在您订阅极狐GitLab 后，您可以管理私有化部署订阅的详细信息。

<a id="obtain-a-self-managed-subscription"></a>

## 获取私有化部署订阅

要为极狐GitLab 私有化部署实例订阅：

1. 转到[定价页面](https://gitlab.cn/pricing/)并选择一个私有化部署计划。您将被重定向到[客户门户](https://support.gitlab.cn/#/portal/index)以完成购买。
1. 购买后，一个订阅许可证会发送到与客户门户账户关联的电子邮件地址。您必须[将许可证导入到您的极狐GitLab 实例](../../administration/license.md)。

{{< alert type="note" >}}

如果您为现有的**基础版**极狐GitLab 私有化部署实例购买订阅，请确保您购买了足够的席位以[覆盖您的用户](../../administration/admin_area.md#administering-users)。

{{< /alert >}}

<a id="how-gitlab-bills-for-users"></a>

## 极狐GitLab 如何为用户计费

极狐GitLab 私有化部署订阅使用混合模式。您根据订阅期间启用的[最大用户数](#maximum-users)为订阅付费。

对于不离线或未在封闭网络上的实例，每季度检查一次极狐GitLab 私有化部署实例中同时在线的最大用户数。

如果一个实例无法生成季度使用报告，则使用现有的[真实模型](#users-over-subscription)。如果没有季度使用报告，则无法进行按比例收费。

<a id="billable-users"></a>

### 计费用户

计费用户计入您订阅中购买的订阅席位数量。

当您在当前订阅期间阻止、停用或[添加](#add-seats-to-a-subscription)用户到您的实例时，计费用户的数量会发生变化。

用户在以下情况下不被计入计费用户：

- 他们被[停用](../../administration/moderate_users.md#deactivate-a-user)或[阻止](../../administration/moderate_users.md#block-a-user)。
- 他们在[待批准](../../administration/moderate_users.md#users-pending-approval)状态。
- 他们仅在极狐GitLab 私有化部署旗舰版订阅中具有[最低访问角色](../../user/permissions.md#users-with-minimal-access)。
- 他们仅在旗舰版订阅中具有[访客角色](#free-guest-users)。
- 他们在旗舰版订阅中没有项目或群组成员资格。
- 账户是极狐GitLab 创建的账户：
  - [幽灵用户](../../user/profile/account/delete_account.md#associated-records)。
  - 机器人用户，例如：
    - [支持机器人](../../user/project/service_desk/configure.md#support-bot-user)。
    - [项目的机器人用户](../../user/project/settings/project_access_tokens.md#bot-users-for-projects)。
    - [群组的机器人用户](../../user/group/settings/group_access_tokens.md#bot-users-for-groups)。
    - 其他[内部用户](../../administration/internal_users.md)。

**计费用户**的数量每天在**管理员**区域报告一次。

<a id="users-in-subscription"></a>

### 订阅中的用户

订阅中的用户数量代表您当前许可证中包含的用户数量，这是基于您支付的费用。除非您购买更多席位，否则此数字在整个订阅期间保持不变。

<a id="maximum-users"></a>

### 最大用户数

最大用户数反映了您系统上当前许可证期间的计费用户的最高数量。

<a id="users-over-subscription"></a>

### 超出订阅的用户

极狐GitLab 订阅对于特定数量的席位有效。超出订阅的用户数量显示在当前订阅期间超出订阅允许的用户数量。

计算公式为 `最大用户数` - `订阅中的用户`。例如，您为 10 个用户购买了订阅。

| 事件                                              | 计费用户   | 最大用户数 |
|:---------------------------------------------------|:-----------------|:--------------|
| 十个用户占用了所有 10 个席位。                     | 10               | 10            |
| 两个新用户加入。                                | 12               | 12            |
| 三个用户离开，他们的账户被阻止。  | 9                | 12            |
| 四个新用户加入。                               | 13               | 13            |

超出订阅的用户 = 13 - 10 (最大用户数 - 订阅中的用户)

对于试用许可证，超出订阅的用户值始终为零。

如果超出订阅的用户值大于零，则表示您在极狐GitLab 实例中的用户超过了您获得许可证的用户数。您必须在[续订前或续订时](../quarterly_reconciliation.md)为额外的用户付费。这被称为 _真实_ 过程。如果您不这样做，您的许可证密钥将不起作用。

要查看超出订阅的用户数量，请转到**管理员**区域。

<a id="free-guest-users"></a>

### 免费访客用户

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

在**旗舰版**层中，分配了访客角色的用户不消耗席位。用户不得在实例中被分配任何其他角色。

- 如果您的项目是私有或内部的，具有访客角色的用户拥有[一组权限](../../user/permissions.md#project-members-permissions)。
- 如果您的项目是公开的，所有用户，包括具有访客角色的用户，都可以访问您的项目。
- 用户的最高分配角色是异步更新的，可能需要一些时间来更新。

{{< alert type="note" >}}

如果用户创建了一个项目，他们将被分配为维护者或所有者角色。为了防止用户创建项目，作为管理员，您可以将用户标记为[外部](../../administration/external_users.md)。

{{< /alert >}}

<a id="view-users"></a>

## 查看用户

查看您实例中的用户列表：

1. 在左侧边栏底部，选择**管理员**。
1. 选择**用户**。

选择一个用户以查看其账户信息。

<a id="check-daily-and-historical-billable-users"></a>

### 检查每日和历史计费用户

先决条件：

- 您必须是管理员。

您可以在极狐GitLab 实例中获取每日和历史计费用户的列表：

1. [启动 Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 统计实例中的用户数量：

   ```ruby
   User.billable.count
   ```

1. 获取过去一年的实例历史最大用户数量：

   ```ruby
   ::HistoricalData.max_historical_user_count(from: 1.year.ago.beginning_of_day, to: Time.current.end_of_day)
   ```

<a id="update-daily-and-historical-billable-users"></a>

### 更新每日和历史计费用户

先决条件：

- 您必须是管理员。

您可以在极狐GitLab 实例中手动触发每日和历史计费用户的更新。

1. [启动 Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 强制更新每日计费用户：

   ```ruby
   identifier = Analytics::UsageTrends::Measurement.identifiers[:billable_users]
   ::Analytics::UsageTrends::CounterJobWorker.new.perform(identifier, User.minimum(:id), User.maximum(:id), Time.zone.now)
   ```

1. 强制更新历史最大计费用户：

   ```ruby
   ::HistoricalDataWorker.new.perform
   ```

<a id="manage-users-and-subscription-seats"></a>

## 管理用户和订阅席位

管理用户数量与订阅席位数量可能很困难：

- 如果 [LDAP 与极狐GitLab 集成](../../administration/auth/ldap/_index.md)，配置域中的任何人都可以注册极狐GitLab 账户。这可能导致续订时出现意外账单。
- 如果您的实例中启用了注册，则可以访问实例的任何人都可以注册账户。

极狐GitLab 提供了多个功能来帮助您管理用户数量。您可以：

- [要求管理员批准新注册](../../administration/settings/sign_up_restrictions.md#require-administrator-approval-for-new-sign-ups)。
- 自动阻止新用户，无论是通过 [LDAP](../../administration/auth/ldap/_index.md#basic-configuration-settings)还是[OmniAuth](../../integration/omniauth.md#configure-common-settings)。
- [限制计费用户的数量](../../administration/settings/sign_up_restrictions.md#user-cap)，他们可以在没有管理员批准的情况下注册或添加到订阅中。
- [禁用新注册](../../administration/settings/sign_up_restrictions.md)，而是手动管理新用户。
- 查看按角色分类的用户详细信息，在[用户统计](../../administration/admin_area.md#users-statistics)页面中。

<a id="add-seats-to-a-subscription"></a>

### 向订阅中添加席位

要增加许可证涵盖的用户数量，请在订阅期间向您的订阅中添加席位。订阅期间添加的席位的成本从购买日期按比例计算到订阅期结束。即使您达到许可证用户数量，您也可以继续添加用户。极狐GitLab [向您收取超额费用](../quarterly_reconciliation.md)。

要向订阅中添加席位：

1. 登录到[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 转到**订阅和购买**页面。
1. 在相关订阅卡上选择**添加席位**。
1. 输入额外用户的数量。
1. 查看**购买摘要**部分，其中列出了系统上所有用户的总价以及您已支付的信用。您只需支付净变更费用。
1. 输入您的付款信息。
1. 选择**购买席位**。

如果您的订阅是通过激活码激活的，额外的席位会立即反映在您的实例中。如果您使用许可证文件，您将收到更新的文件。要添加席位，[添加许可证文件](../../administration/license_file.md)到您的实例。

<a id="subscription-data-synchronization"></a>

## 订阅数据同步

先决条件：

- 极狐GitLab 企业版 (JH)。
- 连接到互联网，且不能有离线环境。
- [激活](../../administration/license.md)您的实例并使用激活码。

您的[订阅数据](#subscription-data)每天在您的极狐GitLab 私有化部署实例和极狐GitLab 之间自动同步。

在大约凌晨 3:00（UTC）时，此每日同步作业会将[订阅数据](#subscription-data)发送到客户门户。因此，更新和续订可能不会立即生效。

数据通过加密的 HTTPS 连接安全地发送到 `customers.gitlab.com` 的 `443` 端口。如果作业失败，它会在大约 17 小时内重试 12 次。

在您设置自动数据同步后，以下过程也会自动化。

- [季度订阅对账](../quarterly_reconciliation.md)。
- 订阅续订。
- 订阅更新，例如添加更多席位或升级极狐GitLab 层级。

<a id="manually-synchronize-subscription-data"></a>

### 手动同步订阅数据

您也可以随时手动同步订阅数据。

1. 在左侧边栏底部，选择**管理员**。
1. 选择**订阅**。
1. 在**订阅详细信息**部分，选择**同步** ({{< icon name="retry" >}})。

然后会排队一个同步作业。当作业完成时，订阅详细信息会更新。

<a id="subscription-data"></a>

### 订阅数据

每日同步作业会将以下信息发送到客户门户：

- 日期
- 时间戳
- 许可证密钥，其中加密了以下内容：
  - 公司名称
  - 许可证持有人姓名
  - 许可证持有人电子邮件
- 历史[最大用户数](#maximum-users)
- [计费用户数量](#billable-users)
- 极狐GitLab 版本
- 主机名
- 实例 ID

此外，我们还发送附加指标，例如：

- 附加类型
- 购买的席位
- 分配的席位

许可证同步请求示例：

```json
{
  "gitlab_version": "14.1.0-pre",
  "timestamp": "2021-06-14T12:00:09Z",
  "date": "2021-06-14",
  "license_key": "eyJkYXRhIjoiYlR2MFBPSEJPSnNOc1plbGtFRGZ6M
  Ex1mWWhyM1Y3NWFOU0Zj\nak1xTmtLZHU1YzJJUWJzZzVxT3FQRU1PXG5
  KRzErL2ZNd0JuKzBwZmQ3YnY4\nTkFrTDFsMFZyQi9NcG5DVEdkTXQyNT
  R3NlR0ZEc0MjBoTTVna2VORlVcbjAz\nbUgrNGl5N0NuenRhZlljd096R
  nUzd2JIWEZ3NzV2V2lqb3FuQ3RYZWppWVFU\neDdESkgwSUIybFJhZlxu
  Y2k0Mzl3RWlKYjltMkJoUzExeGIwWjN3Uk90ZGp1\nNXNNT3dtL0Vtc3l
  zWVowSHE3ekFILzBjZ2FXSXVQXG5ENWJwcHhOZzRlcFhr\neFg0K3d6Zk
  w3cHRQTTJMTGdGb2Vwai90S0VJL0ZleXhxTEhvaUc2NzVIbHRp\nVlRcb
  nYzY090bmhsdTMrc0VGZURJQ3VmcXFFUS9ISVBqUXRhL3ZTbW9SeUNh\n
  SjdDTkU4YVJnQTlBMEF5OFBiZlxuT0VORWY5WENQVkREdUMvTTVCb25Re
  ENv\nK0FrekFEWWJ6VGZLZ1dBRjgzUXhyelJWUVJGTTErWm9TeTQ4XG5V
  aWdXV0d4\nQ2graGtoSXQ1eXdTaUFaQzBtZGd2aG1YMnl1KzltcU9WMUx
  RWXE4a2VSOHVn\nV3BMN1VFNThcbnMvU3BtTk1JZk5YUHhOSmFlVHZqUz
  lXdjlqMVZ6ODFQQnFx\nL1phaTd6MFBpdG5NREFOVnpPK3h4TE5CQ1xub
  GtacHNRdUxTZmtWWEZVUnB3\nWTZtWGdhWE5GdXhURjFndWhyVDRlTE92
  bTR3bW1ac0pCQnBkVWJIRGNyXG5z\nUjVsTWJxZEVUTXJNRXNDdUlWVlZ
  CTnJZVTA2M2dHblc4eVNXZTc0enFUcW1V\nNDBrMUZpN3RTdzBaZjBcbm
  16UGNYV0RoelpkVk02cWR1dTl0Q1VqU05tWWlU\nOXlwRGZFaEhXZWhjb
  m50RzA5UWVjWEM5em52Y1BjU1xueFU0MDMvVml5R3du\nQXNMTHkyajN5
  b3hhTkJUSWpWQ1BMUjdGeThRSEVnNGdBd0x6RkRHVWg1M0Qz\nMHFRXG5
  5eWtXdHNHN3VBREdCNmhPODFJanNSZnEreDhyb2ZpVU5JVXo4NCtD\nem
  Z1V1Q0K1l1VndPTngyc1l0TU5cbi9WTzlaaVdPMFhtMkZzM2g1NlVXcGI
  y\nSUQzRnRlbW5vZHdLOWU4L0tiYWRESVRPQmgzQnIxbDNTS2tHN1xuQ3
  hpc29D\nNGh4UW5mUmJFSmVoQkh6eHV1dkY5aG11SUsyVmVDQm1zTXZCY
  nZQNGdDbHZL\ndUExWnBEREpDXG41eEhEclFUd3E1clRYS2VuTjhkd3BU
  SnVLQXgvUjlQVGpy\ncHJLNEIzdGNMK0xIN2JKcmhDOTlabnAvLzZcblZ
  HbXk5SzJSZERIcXp3U2c3\nQjFwSmFPcFBFUHhOUFJxOUtnY2hVR0xWMF
  d0Rk9vPVxuIiwia2V5IjoiUURM\nNU5paUdoRlVwZzkwNC9lQWg5bFY0Q
  3pkc2tSQjBDeXJUbG1ZNDE2eEpPUzdM\nVXkrYXRhTFdpb0lTXG5sTWlR
  WEU3MVY4djFJaENnZHJGTzJsTUpHbUR5VHY0\ndWlSc1FobXZVWEhpL3h
  vb1J4bW9XbzlxK2Z1OGFcblB6anp1TExhTEdUQVdJ\nUDA5Z28zY3JCcz
  ZGOEVLV28xVzRGWWtUUVh2TzM0STlOSjVHR1RUeXkzVkRB\nc1xubUdRe
  jA2eCtNNkFBM1VxTUJLZXRMUXRuNUN2R3l3T1VkbUx0eXZNQ3JX\nSWVQ
  TElrZkJwZHhPOUN5Z1dCXG44UkpBdjRSQ1dkMlFhWVdKVmxUMllRTXc5\
  nL29LL2hFNWRQZ1pLdWEyVVZNRWMwRkNlZzg5UFZrQS9mdDVcbmlETWlh
  YUZz\nakRVTUl5SjZSQjlHT2ovZUdTRTU5NVBBMExKcFFiVzFvZz09XG4
  iLCJpdiI6\nImRGSjl0YXlZWit2OGlzbGgyS2ZxYWc9PVxuIn0=\n",
  "max_historical_user_count": 75,
  "billable_users_count": 75,
  "hostname": "gitlab.example.com",
  "instance_id": "9367590b-82ad-48cb-9da7-938134c29088",
  "add_on_metrics": [
    {
      "add_on_type": "duo_enterprise",
      "purchased_seats": 100,
      "assigned_seats": 50
    }
  ]
}
```

<a id="view-your-subscription"></a>

## 查看您的订阅

先决条件：

- 您必须是管理员。

您可以查看您的订阅状态：

1. 在左侧边栏底部，选择**管理员**。
1. 选择**订阅**。

**订阅**页面包含以下信息：

- 许可证持有人
- 计划
- 上传、开始和到期的时间
- [订阅中的用户](#users-in-subscription)数量
- [计费用户](#billable-users)数量
- [最大用户数](#maximum-users)
- [超出订阅的用户](#users-over-subscription)数量

<a id="export-your-license-usage"></a>

## 导出您的许可证使用情况

先决条件：

- 您必须是管理员。

您可以将许可证使用情况导出到 CSV 文件中。

此文件包含极狐GitLab 用于手动处理[季度对账](../quarterly_reconciliation.md)或[续订](#renew-your-subscription)的信息。如果您的实例被防火墙保护或处于离线环境中，您必须将此信息提供给极狐GitLab。

{{< alert type="warning" >}}

不要打开许可证使用文件。如果您打开文件，可能会在[提交您的许可证使用数据](../../administration/license_file.md#submit-license-usage-data)时发生故障。

{{< /alert >}}

1. 在左侧边栏底部，选择**管理员**。
1. 选择**订阅**。
1. 在右上角，选择**导出许可证使用文件**。

<a id="license-usage-file-contents"></a>

### 许可证使用文件内容

许可证使用文件包括以下信息：

- 许可证密钥
- 许可证持有人电子邮件
- 许可证开始日期 (UTC)
- 许可证结束日期 (UTC)
- 公司
- 文件生成和导出的时间戳 (UTC)
- 在期间内每天的历史用户计数表：
  - 记录计数的时间戳 (UTC)
  - [计费用户](#billable-users)计数

<a id="renew-your-subscription"></a>

## 续订您的订阅

您可以[自动续订您的订阅](#automatic-subscription-renewal)或手动续订。

如果您想要以下任一选项，您应该[手动续订您的订阅](#renew-subscription-manually)：

- [续订更少的席位](#renew-for-fewer-seats)。
- 增加或减少续订产品的数量。
- 移除不再需要的附加产品，以便续订订阅期限。
- 升级订阅层级。

在您的订阅续订日期之前，您应查看您的账户。

如果您需要帮助访问客户门户或更改管理您订阅的联系人，请联系[支持团队](https://support.gitlab.cn/#/portal/index)。如果您需要帮助续订订阅，请联系[销售团队](https://support.gitlab.cn/#/portal/index)。

<a id="review-your-account"></a>

### 查看您的账户

您应该定期查看您的帐单账户设置和购买信息。

要查看您的账单账户设置：

1. 登录到[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 选择**账单账户设置**。
1. 验证或更新：
   - 在**付款方式**下，文件中的信用卡。
   - 在**公司信息**下，订阅和账单联系信息。
1. 保存任何更改。

您还应该定期查看您的用户账户，以确保您只为正确数量的活跃计费用户续订。非活跃用户账户：

- 可能计入计费用户。如果您为非活跃用户账户续订，您支付的费用可能比您应该的要多。
- 可能是安全风险。定期检查有助于降低这种风险。

有关更多信息，请参阅以下文档：

- [用户统计](../../administration/admin_area.md#users-statistics)。
- [管理用户和订阅席位](#manage-users-and-subscription-seats)。

<a id="renew-for-fewer-seats"></a>

### 续订更少的席位

如果您想以更少的席位续订，您可以执行以下任一操作：

- [手动续订您的订阅](#renew-subscription-manually)。
- [取消您的订阅](#enable-or-disable-automatic-subscription-renewal)并联系[销售团队](https://support.gitlab.cn/#/portal/index)以指定您在未来的订阅中需要的席位数量。

<a id="automatic-subscription-renewal"></a>

### 自动订阅续订

先决条件：

- 您必须启用了[订阅数据同步](#subscription-data-synchronization)。

在续订日期至少两天前，您应该[查看您的账户](#review-your-account)，以便您的更改及时同步到极狐GitLab 进行续订。

当订阅设置为自动续订时，它会在到期日期的午夜 UTC 自动续订，而不会中断可用服务。通过客户门户购买的订阅默认设置为自动续订。

用户席位数量会在续订时根据实例中[计费用户的数量](#view-users)进行调整，如果该数量高于当前订阅数量。

<a id="email-notifications"></a>

#### 电子邮件通知

在订阅自动续订前 15 天，会发送一封电子邮件，提供有关续订的信息。

- 如果您的信用卡已过期，电子邮件会告诉您如何更新。
- 如果您有任何未结算的超额费用或您的订阅无法自动续订的其他原因，电子邮件会告诉您联系销售团队或[在客户门户中手动续订](#renew-subscription-manually)。
- 如果没有问题，电子邮件将指定：
  - 续订的产品名称和数量。
  - 您欠的总金额。如果您的使用在续订前增加，则此金额会更改。

<a id="enable-or-disable-automatic-subscription-renewal"></a>

#### 启用或禁用自动订阅续订

您可以使用客户门户启用或禁用自动订阅续订：

1. 登录到[客户门户](https://support.gitlab.cn/#/portal/index)。您将被带到**订阅和购买**页面。
1. 检查订阅卡：
   - 如果卡片显示**到期于 DATE**，您的订阅未设置为自动续订。要启用自动续订，在**订阅操作** ({{< icon name="ellipsis_v" >}})中选择**打开自动续订**。
   - 如果卡片显示**自动续订于 DATE**，您的订阅设置为自动续订。要禁用自动续订：
     1. 在**订阅操作** ({{< icon name="ellipsis_v" >}})中选择**取消订阅**。
     1. 选择取消的原因。
     1. 可选：在**您想添加什么吗？**中，输入任何相关信息。
     1. 选择**取消订阅**。

<a id="storage"></a>

## 存储

极狐GitLab 私有化部署实例的存储和传输量没有应用限制。管理员负责底层基础设施成本，并可以设置[存储库大小限制](../../administration/settings/account_and_limit_settings.md#repository-size-limit)。
