---
stage: Fulfillment
group: Subscription Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Payment and company details.
title: 极狐GitLab 客户管理中心
---

为了管理您的订阅和账户的某些任务，例如购买额外的席位或存储以及查看发票，您需要使用客户门户。请参阅以下页面以获取有关管理您订阅的具体说明：

- [极狐GitLab SaaS 订阅](gitlab_com/_index.md)
- [极狐GitLab 私有化部署订阅](self_managed/_index.md)

<a id="sign-in-to-customers-portal"></a>

## 登录客户门户

您可以使用您的 JihuLab.com 帐户或发送到您电子邮件的一次性登录链接登录客户门户。

{{< alert type="note" >}}

如果您使用 JihuLab.com 帐户注册客户门户，请使用此帐户登录。

{{< /alert >}}

使用您的 JihuLab.com 帐户登录客户门户：

1. 前往[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 选择 **继续使用 JihuLab.com 帐户**。

使用您的电子邮件登录客户门户并接收一次性登录链接：

1. 前往[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 选择 **使用您的电子邮件登录**。
1. 提供您的客户门户配置文件的 **电子邮件**。您将收到一封带有一次性登录链接的电子邮件。
1. 在您收到的电子邮件中，选择 **登录**。

{{< alert type="note" >}}

一次性登录链接在 24 小时内过期，并且只能使用一次。

{{< /alert >}}

<a id="confirm-customers-portal-email-address"></a>

## 确认客户门户电子邮件地址

首次使用一次性登录链接登录客户门户时，您必须确认您的电子邮件地址以保持对客户门户的访问权限。如果您通过 JihuLab.com 登录客户门户，则无需确认您的电子邮件地址。

您还必须确认对配置文件电子邮件地址的任何更新。您将收到自动电子邮件，其中包含有关如何确认的说明，如果需要，您可以[重新发送](https://customers.gitlab.com/customers/confirmation/new)。

<a id="change-profile-owner-information"></a>

## 更改配置文件所有者信息

配置文件所有者的电子邮件地址用于[客户门户旧版登录](#sign-in-to-customers-portal)。如果配置文件所有者也是[账单账户经理](#subscription-and-billing-contacts)，则其个人详细信息将用于发票以及与许可证和订阅相关的电子邮件。

要更改配置文件详细信息，包括姓名和电子邮件地址：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 选择 **我的配置文件 > 配置文件设置**。
1. 编辑 **您的个人详细信息**。
1. 选择 **保存更改**。

如果您想将客户门户配置文件的所有权转移给其他人，在输入该人的个人详细信息后，您还必须：

- [更改链接的 JihuLab.com 帐户](#change-the-linked-account)，如果您有一个已链接的帐户。

<a id="change-your-company-details"></a>

## 更改公司详细信息

要更改您的公司详细信息，包括公司名称和税号：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 选择 **账单账户设置**。
1. 向下滚动到 **公司信息** 部分。
1. 编辑公司详细信息。
1. 选择 **保存更改**。

<a id="subscription-and-billing-contacts"></a>

## 订阅和账单联系人

<a id="change-your-subscription-contact"></a>

### 更改您的订阅联系人

订阅联系人是您账单账户的主要联系人。他们接收订阅事件通知和关于应用订阅的信息。

要更改订阅联系人：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在左侧边栏，选择 **账单账户设置**。
1. 滚动到 **公司信息** 部分，然后到 **订阅联系人**。
1. 要选择其他订阅联系人，请从 **账单账户经理** 下拉列表中选择。
1. 编辑联系人的详细信息。
1. 选择 **保存更改**。

<a id="add-a-secondary-contact"></a>

### 添加次要联系人

要为您的账户添加次要联系人：

1. 确保在[客户门户](https://support.gitlab.cn/#/portal/index)中为您要添加的用户创建了一个账户。
1. [与支持团队创建工单](https://support.gitlab.cn/#/portal/index)。在您的请求中包含任何相关材料。

<a id="change-your-billing-contact"></a>

### 更改您的账单联系人

账单联系人接收所有发票和订阅事件通知。

要更改账单联系人：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在左侧边栏，选择 **账单账户设置**。
1. 滚动到 **公司信息** 部分，然后到 **账单联系人**。

   - 要将您的账单联系人更改为您的订阅联系人：

     1. 选择 **账单联系人与订阅联系人相同**。
     1. 选择 **保存更改**。

   - 要将您的账单联系人更改为不同的账单账户经理：

     1. 清除 **账单联系人与订阅联系人相同** 复选框。
     1. 从 **用户** 下拉列表中选择不同的账单账户经理。
     1. 编辑联系人的详细信息。
     1. 选择 **保存更改**。

   - 要将您的账单联系人更改为自定义联系人：

     1. 清除 **账单联系人与订阅联系人相同** 复选框。
     1. 从 **用户** 下拉列表中选择 **输入自定义联系人**。
     1. 输入联系人的详细信息。
     1. 选择 **保存更改**。

<a id="troubleshooting-your-billing-or-subscription-contacts-name"></a>

### 故障排除您的账单或订阅联系人的姓名

如果账单账户经理的电子邮件链接到具有不同名字或姓氏的联系人，您将被提示更新姓名。

如果您是账单账户经理，请按照说明[更新您的个人配置文件](#change-profile-owner-information)。

如果您不是账单账户经理，请通知他们更新个人配置文件。

<a id="troubleshooting-your-subscription-contact"></a>

### 故障排除您的订阅联系人

如果订阅联系人不再是账单账户经理，您将被提示选择新的联系人。请按照说明[更改您的订阅联系人](#change-your-subscription-contact)。

<a id="change-your-payment-method"></a>

## 更改您的支付方式

在客户门户中进行购买需要记录的信用卡作为支付方式。您可以向您的账户添加多张信用卡，以便不同产品的购买费用记入正确的卡。

要更改您的支付方式：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在左侧边栏，选择 **账单账户设置**。
1. **编辑**现有支付方式的信息或**添加新的支付方式**。
1. 选择 **保存更改**。

<a id="set-a-default-payment-method"></a>

### 设置默认支付方式

订阅的自动续订将记入您的默认支付方式。要将支付方式标记为默认：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在左侧边栏，选择 **账单账户设置**。
1. **编辑**所选支付方式并选中 **设为默认支付方式** 复选框。
1. 选择 **保存更改**。

<a id="pay-for-an-invoice"></a>

## 支付发票

您可以在客户门户中使用信用卡支付您的发票。

要支付发票：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在左侧边栏，选择 **发票**。
1. 在您要支付的发票上，选择 **支付发票**。
1. 完成支付表单。

<a id="link-a-gitlabcom-account"></a>

## 链接一个 JihuLab.com 帐户

如果您有旧版客户门户配置文件以进行登录，请遵循此指南。

要将 JihuLab.com 帐户链接到您的客户门户配置文件：

1. 从[客户门户](https://support.gitlab.cn/#/portal/index)触发一次性登录链接到您的电子邮件。
1. 找到电子邮件并点击一次性登录链接以登录到您的客户门户帐户。
1. 选择 **我的配置文件 > 配置文件设置**。
1. 在 **您的 JihuLab.com 帐户**下，选择 **链接帐户**。
1. 登录到您要链接到客户门户配置文件的 [JihuLab.com](https://jihulab.com/users/sign_in) 帐户。

<a id="change-the-linked-account"></a>

## 更改链接的帐户

如果您想将您的客户门户帐户链接到不同的 JihuLab.com 帐户，您必须使用您的 JihuLab.com 帐户注册一个新的客户门户配置文件。

如果您想更改订阅联系人，您可以选择执行以下任一操作：

- [更改账单联系人](#change-your-billing-contact)。
- [更改订阅联系人](#change-your-subscription-contact)。

如果您有未链接到 JihuLab.com 帐户的旧版客户门户配置文件，您仍然可以使用发送到您电子邮件的一次性登录链接[登录](https://support.gitlab.cn/#/portal/index)。但是，您应该[创建](https://jihulab.com/users/sign_up)并[链接一个 JihuLab.com 帐户](#change-the-linked-account)以确保继续访问客户门户。

要更改链接到您客户门户配置文件的 JihuLab.com 帐户：

1. 登录[客户门户](https://support.gitlab.cn/#/portal/index)。
1. 在一个单独的浏览器选项卡中，前往 [JihuLab.com](https://jihulab.com/users/sign_in) 并确保您未登录。
1. 在客户门户页面上，选择 **我的配置文件 > 配置文件设置**。
1. 在 **您的 JihuLab.com 帐户**下，选择 **更改链接帐户**。
1. 登录到您要链接到客户门户配置文件的 [JihuLab.com](https://jihulab.com/users/sign_in) 帐户。

<a id="customers-that-purchased-through-a-reseller"></a>

## 通过经销商购买的客户

如果您通过授权经销商（包括 GCP 和 AWS 市场）购买了订阅，您可以访问客户门户以：

- 查看您的订阅。
- 将您的订阅与相关群组（JihuLab.com）关联或下载许可证（极狐GitLab 私有化部署）。
- 管理联系信息。

其他更改和请求必须通过经销商进行，包括：

- 订阅的更改。
- 购买额外的席位、存储或计算。
- 请求发票，因为这些是由经销商而不是极狐GitLab 开具的。

经销商无法访问客户门户或其客户的账户。

在您的订阅订单处理完毕后，您将收到几封电子邮件：

- 一封“欢迎来到客户门户”的电子邮件，其中包括如何登录的说明。
- 一封购买确认电子邮件，其中包含如何提供访问权限的说明。

<a id="get-support"></a>

## 获取支持

如果您遇到问题或对您的极狐GitLab 订阅有疑问，可以直接扫描下方二维码联系专业人员：

![wechat support](../administration/img/wechat-support.png)

