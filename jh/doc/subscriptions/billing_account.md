---
stage: Fulfillment
group: Subscription Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Change billing account data and payment methods, pay for invoices, and link your GitLab account in the Customers Portal.
title: 管理账单账户
---

<a id="manage-billing-account"></a>

# 管理账单账户

Customers Portal 是您管理极狐GitLab 订阅和账单的综合性自助中心，详见[管理极狐GitLab 订阅](manage_subscription.md)。您可以在此购买极狐GitLab 产品、在整个订阅生命周期内管理您的订阅、查看并支付发票，以及访问您的账单详情和联系信息。

如果您通过授权经销商进行购买，则必须直接联系经销商以更改您的订阅。更多信息，请参阅[通过经销商购买的客户](#subscription-purchased-through-a-reseller)。

<a id="sign-in-to-customers-portal"></a>

## 登录 Customers Portal

您可以使用您的 JihuLab.com 账户或发送到您邮箱的一次性登录链接（前提是您尚未[将您的 Customers Portal 账户链接到您的 JihuLab.com 账户](#link-a-gitlabcom-account)）登录 Customers Portal。

> [!note]
> 如果您是使用 JihuLab.com 账户注册的 Customers Portal，请使用该账户登录。

要使用 JihuLab.com 账户登录 Customers Portal：

1. 前往 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 选择 **使用 JihuLab.com 账户继续**。

要通过邮箱接收一次性登录链接来登录 Customers Portal：

1. 前往 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 选择 **通过电子邮件登录**。
1. 输入您 Customers Portal 个人资料中的 **邮箱**。您将收到一封包含一次性登录链接的电子邮件。
1. 在收到的邮件中，选择 **登录**。

> [!note]
> 一次性登录链接将在 24 小时后失效，且只能使用一次。

<a id="confirm-customers-portal-email-address"></a>

## 确认 Customers Portal 邮箱地址

首次通过一次性登录链接登录 Customers Portal 时，您必须确认您的邮箱地址，以便保持对 Customers Portal 的访问权限。如果您通过 JihuLab.com 登录 Customers Portal，则无需确认邮箱地址。

对个人资料邮箱地址的任何更新也必须进行确认。您将收到一封自动邮件，其中包含确认说明，如有需要，您可以[重新发送](https://customers.jihulab.com/customers/confirmation/new)。

<a id="change-profile-owner-information"></a>

## 更改资料所有者信息

资料所有者的邮箱地址用于 [Customers Portal 旧版登录](#sign-in-to-customers-portal)。如果资料所有者同时也是[账单账户经理](#subscription-and-billing-contacts)，则其个人信息将用于发票以及许可证和订阅相关的邮件。

要更改资料详情，包括姓名和邮箱地址：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 选择 **我的资料** > **资料设置**。
1. 编辑 **您的个人详细信息**。
1. 选择 **保存更改**。

<a id="change-your-company-details"></a>

## 更改您公司的详细信息

要更改您公司的详细信息，包括公司名称和税号：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 选择 **账单账户设置**。
1. 向下滚动到 **公司信息** 部分。
1. 编辑公司详细信息。
1. 选择 **保存更改**。

<a id="subscription-and-billing-contacts"></a>

## 订阅和账单联系人

参与订阅管理的用户可扮演三种不同角色，拥有不同级别的权限和对订阅的可见性：

- 账单账户经理：可以查看和编辑订阅、付款方式和账单账户设置。可以支付和下载发票，并将订阅联系人更新为列表中的任何账单账户经理。
- 订阅联系人（或“售予”联系人）：订阅的所有者和账单账户的主要联系人。接收有关订阅事件和应用订阅信息的通知。默认情况下，该角色同时也是账单账户经理。
- 账单联系人（或“付款”联系人）：接收所有发票和订阅事件通知。除非该角色同时也是账单账户经理，否则没有可访问订阅的 Customers Portal 账户。

一个用户可同时拥有所有三种角色。

<a id="change-your-subscription-contact"></a>

### 更改订阅联系人

要更改订阅联系人：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. 滚动到 **公司信息** 部分，然后到 **订阅联系人**。
1. 要选择其他订阅联系人，请从 **账单账户经理** 下拉列表中选择。
1. 编辑联系人详细信息。
1. 选择 **保存更改**。

<a id="add-a-billing-account-manager"></a>

### 添加账单账户经理

要为您的账户添加另一位账单账户经理：

1. 确保您要添加的用户在 [Customers Portal](https://customers.jihulab.com/customers/sign_in) 中拥有账户。
1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. 滚动到 **账单账户经理** 部分。
1. 选择 **邀请账单账户经理**。
1. 输入您要添加的用户的邮箱地址。
1. 选择 **邀请**。

受邀用户将收到一封包含 Customers Portal 邀请的邮件。邀请有效期为七天。如果用户在邀请过期前未接受，您可以发送新的邀请。您最多可同时拥有 15 个待处理邀请。

<a id="remove-a-billing-account-manager"></a>

### 移除账单账户经理

您可以随时从账户中移除账单账户经理。移除后，他们不再有权查看或编辑您的账单账户信息。

要移除账单账户经理：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. 滚动到 **账单账户经理** 部分。
1. 在列表中，在要移除的账单账户经理旁边，选择 **移除**。
1. 在确认对话框中，选择 **移除** 以确认操作。

<a id="revoke-a-billing-account-manager-invitation"></a>

### 撤销账单账户经理邀请

您可以撤销尚未被接受的邀请。已受邀但尚未接受邀请的用户将显示为 **等待用户注册**。

要撤销邀请：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. 滚动到 **账单账户经理** 部分。
1. 在列表中，在显示 **等待用户注册** 的受邀用户旁边，选择 **移除**。
1. 在确认对话框中，选择 **移除** 以撤销邀请。

<a id="change-your-billing-contact"></a>

### 更改账单联系人

账单联系人接收所有发票和订阅事件通知。

要更改账单联系人：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. 滚动到 **公司信息** 部分，然后到 **账单联系人**。

   - 要将账单联系人改为订阅联系人：

     1. 选择 **账单联系人与订阅联系人相同**。
     1. 选择 **保存更改**。

   - 要将账单联系人改为其他账单账户经理：

     1. 清除 **账单联系人与订阅联系人相同** 复选框。
     1. 从 **用户** 下拉列表中选择其他账单账户经理。
     1. 编辑联系人详细信息。
     1. 选择 **保存更改**。

   - 要将账单联系人改为自定义联系人：

     1. 清除 **账单联系人与订阅联系人相同** 复选框。
     1. 从 **用户** 下拉列表中选择 **输入自定义联系人**。
     1. 输入联系人详细信息。
     1. 选择 **保存更改**。

<a id="change-your-payment-method"></a>

## 更改付款方式

在 Customers Portal 中进行购买时需要使用信用卡作为付款方式。您可以向账户添加多张信用卡，以便根据不同产品从相应的卡中扣款。

如果您希望使用其他付款方式，请[联系我们的销售团队](https://customers.jihulab.com/contact_us)。

要更改付款方式：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. **编辑** 现有付款方式信息或 **添加新付款方式**。
1. 选择 **保存更改**。

<a id="set-a-default-payment-method"></a>

### 设置默认付款方式

订阅的自动续订将从您的默认付款方式扣款。要将某个付款方式标记为默认：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **账单账户设置**。
1. **编辑** 所选付款方式，并勾选 **设为默认付款方式** 复选框。
1. 选择 **保存更改**。

<a id="delete-a-default-payment-method"></a>

### 删除默认付款方式

您不能直接通过 Customers Portal 删除默认付款方式。要删除默认付款方式，请[联系我们的账单团队](https://customers.jihulab.com/contact_us)寻求帮助。

<a id="pay-for-an-invoice"></a>

## 支付发票

您可以在 Customers Portal 中使用信用卡支付发票。

要支付发票：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在左侧边栏中，选择 **发票**。
1. 在要支付的发票上，选择 **支付发票**。
1. 填写付款表单。

如果您希望使用其他付款方式，请[联系我们的账单团队](https://customers.jihulab.com/contact_us#contact-billing-team)。

<a id="link-a-gitlabcom-account"></a>

## 链接 JihuLab.com 账户

如果您拥有用于登录的旧版 Customers Portal 资料，请遵循此指南。

要将 JihuLab.com 账户链接到您的 Customers Portal 资料：

1. 从您的 [Customers Portal](https://customers.jihulab.com/customers/sign_in?legacy=true) 账户触发一封发送到您邮箱的一次性登录链接。
1. 查找邮件并选择一次性登录链接以登录您的 Customers Portal 账户。
1. 选择 **我的资料** > **资料设置**。
1. 在 **您的 JihuLab.com 账户** 下方，选择 **关联账户**。
1. 登录您想要链接到 Customers Portal 资料的 [JihuLab.com](https://jihulab.com/users/sign_in) 账户。

<a id="change-the-linked-account"></a>

## 更改已链接的账户

如果您想将 Customers Portal 账户链接到不同的 JihuLab.com 账户，则必须使用您的 JihuLab.com 账户注册一个新的 Customers Portal 资料。

如果您想更改订阅联系人，您可以改为执行以下操作之一：

- [更改账单联系人](#change-your-billing-contact)。
- [更改订阅联系人](#change-your-subscription-contact)。

如果您拥有未链接到 JihuLab.com 账户的旧版 Customers Portal 资料，您仍然可以使用发送到邮箱的一次性登录链接进行[登录](https://customers.jihulab.com/customers/sign_in?legacy=true)。但是，您应该[创建](https://jihulab.com/users/sign_up)并[链接一个 JihuLab.com 账户](#change-the-linked-account)，以确保继续访问 Customers Portal。

要更改与您的 Customers Portal 资料链接的 JihuLab.com 账户：

1. 登录 [Customers Portal](https://customers.jihulab.com/customers/sign_in)。
1. 在单独的浏览器标签页中，前往 [JihuLab.com](https://jihulab.com/users/sign_in) 并确保您未登录。
1. 在 Customers Portal 页面上，选择 **我的资料** > **资料设置**。
1. 在 **您的 JihuLab.com 账户** 下方，选择 **更改已关联账户**。
1. 登录您想要链接到 Customers Portal 资料的 [JihuLab.com](https://jihulab.com/users/sign_in) 账户。

<a id="transfer-subscription-ownership"></a>

## 转移订阅所有权

您可以在 Customers Portal 中将订阅所有权转移给联系人，或从联系人处转移。

<a id="to-a-new-billing-account-manager"></a>

### 转移给新的账单账户经理

要将订阅所有权转移给未列为账单账户经理的联系人：

1. 邀请该联系人作为账单账户经理。
1. 在联系人接受邀请后，将订阅联系人更改为新的账单账户经理。

<a id="to-a-new-subscription-contact"></a>

### 转移给新的订阅联系人

如果您是当前的订阅联系人，并希望将所有权转移给另一个没有 Customers Portal 账户的人：

1. 将您的资料所有者信息更改为新联系人的详细信息。
1. 让新联系人使用他们自己的邮箱地址通过一次性登录链接登录 Customers Portal。
1. 让新联系人将已链接的 JihuLab.com 账户更改为他们自己的 JihuLab.com 账户。

<a id="from-a-contact-who-has-left-the-organization"></a>

### 从已离开组织的联系人处转移

如果您可以访问订阅联系人的邮箱：

1. 使用订阅联系人的邮箱地址通过一次性登录链接登录 Customers Portal。
1. 将订阅联系人信息更改为您的详细信息。
1. 将已链接的账户更改为您的 JihuLab.com 账户。

如果您无法访问订阅联系人的邮箱，请[联系支持团队](https://support.jihulab.com/hc/en-us/requests/new?ticket_form_id=360000071293)请求转移订阅所有权。您必须提供所有权证明，以便支持团队处理您的请求。

您可以使用以下模板发送支持请求：

```plaintext
您好 支持团队，

请更新我的订阅/账单账户的所有权。我确认我无法在 Customers Portal 中进行此更改。以下是相关详情：

- 旧的订阅联系人邮箱地址：
- 新的订阅联系人邮箱地址：
- （可选）订阅或账单账户名称：
- 所有权证明：
```

<a id="tax-id-for-non-us-customers"></a>

## 非美国客户的税号

税号是税务机关为注册增值税（VAT）、商品和服务税（GST）或类似间接税的企业分配的唯一编号。

提供有效税号可能通过允许我们采用反向征收机制而非在发票上收取增值税/商品和服务税来减轻您的税务负担。如果没有有效税号，将根据您所在的地点适用相应的增值税/商品和服务税率。

如果您的企业因规模门槛或其他原因未注册间接税，极狐GitLab 将根据当地法规适用标准增值税/商品和服务税率。

有关各国税号格式的详细信息和更多信息，请参阅我们的[税号完整参考指南](https://handbook.gitlab.com/handbook/finance/tax/#frequently-asked-questions---tax-id-for-non-us-customers)。

<a id="troubleshooting"></a>

## 故障排除

如果您对极狐GitLab 订阅有疑问或遇到问题，请访问[联系我们](https://customers.jihulab.com/contact_us)页面。获取销售、账单和支持团队的资源、服务和联系选项，以便快速获取所需帮助。

<a id="subscription-purchased-through-a-reseller"></a>

### 通过经销商购买的订阅

如果您通过授权经销商（包括 GCP 和 AWS 市场）购买了订阅，您可以使用 Customers Portal 执行以下操作：

- 查看您的订阅。
- 将您的订阅与相关群组（JihuLab.com）关联，或下载许可证（私有化部署极狐GitLab）。
- 管理联系信息。

其他更改和请求必须通过经销商进行，包括：

- 对订阅的更改。
- 购买额外的席位、存储或计算资源。
- 索要发票，因为这些发票由经销商而非极狐GitLab 开具。

经销商本身无法访问 Customers Portal 或其客户的账户。

您的订阅订单处理完毕后，您将收到几封邮件：

- 一封“欢迎使用 Customers Portal”的邮件，包含登录说明。
- 一封购买确认邮件，包含配置访问权限的说明。

<a id="billing-and-subscription-contacts-names-dont-match"></a>

### 账单和订阅联系人的姓名不匹配

如果账单账户经理的邮箱关联了不同姓氏或名字的联系人，系统将提示您更新姓名。

如果您是账单账户经理，请按照说明[更新您的个人资料](#change-profile-owner-information)。

如果您不是账单账户经理，请通知他们更新个人资料。

<a id="subscription-contact-is-no-longer-account-manager"></a>

### 订阅联系人不再是账户经理

如果订阅联系人不再是账单账户经理，系统将提示您选择新的联系人。请按照说明[更改您的订阅联系人](#change-your-subscription-contact)。

<a id="error-email-has-already-been-taken"></a>

### 错误：邮箱已被占用

如果您想注册的邮箱地址已在 Customers Portal 中被使用，您可以：

- 提供另一个邮箱地址。
- 转移订阅所有权。