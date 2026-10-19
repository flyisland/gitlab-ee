---
stage: Fulfillment
group: Subscription Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Seat usage, compute minutes, storage limits, renewal info.
gitlab_dedicated: yes
title: 排查极狐GitLab 订阅问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您购买或使用极狐GitLab 订阅时，可能会遇到以下问题。

<a id="credit-card-declined"></a>

## 信用卡被拒绝

当您购买极狐GitLab 订阅时，您的信用卡可能因以下原因被拒绝：

- 信用卡信息不正确。最常见的原因是地址不完整或假地址。
- 信用卡账户余额不足。
- 信用卡已过期。
- 交易金额超过信用额度或卡的最高交易限额。
- [交易不被允许](#error-transaction_not_allowed)。

请与您的金融机构核实是否存在上述原因。如果均不适用，请联系 [极狐GitLab 支持](https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=360000071293)。

<a id="error-transaction_not_allowed"></a>

### 错误：`transaction_not_allowed`

当您购买极狐GitLab 订阅时，可能会收到如下错误：

```plaintext
交易被拒绝。402 - [card_error/card_declined/transaction_not_allowed]
您的卡不支持此类型的购买交易。
```

此错误表示您进行的交易类型被发卡机构限制。这是一项旨在保护您账户的安全措施。

您的交易可能因以下一个或多个原因被拒：

- 您的卡在印度发行，且交易不符合 [RBI 电子授权规则](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12051&Mode=0)。
- 您的卡未开通在线购买功能。
- 您的卡有特定的使用限制。例如，是一张仅限于本地交易的借记卡。
- 交易触发了银行的安全协议。

要解决此问题，请尝试以下方法：

- 对于在印度发行的卡：通过授权的本地经销商处理您的交易。请联系以下极狐GitLab 在印度的合作伙伴：
  - [Datamato Technologies Private Limited](https://gitlab.cn/partners/channel-partners/#/1345598)
  - [FineShift Software Private Limited](https://gitlab.cn/partners/channel-partners/#/1737250)
- 对于在美国境外发行的卡：确保您的卡已启用国际使用功能，并核实是否存在特定国家/地区的限制。
- 联系您的金融机构：询问交易被拒的原因，并请求为您的卡启用此类交易。

<a id="error-attempt_exceed_limitation"></a>

## 错误：`Attempt_Exceed_Limitation`

当您购买极狐GitLab 订阅时，可能会收到错误
`Attempt_Exceed_Limitation - Attempt exceed the limitation, refresh page to try again.`。

当信用卡表单在一分钟内重复提交三次或一小时内重复提交六次时，会出现此问题。要解决此问题，请等待几分钟后重试购买。

<a id="error-subscription-not-allowed-to-add"></a>

## 错误：`Subscription not allowed to add`

当您购买订阅附加服务（例如额外席位、计算分钟数、存储空间或极狐GitLab Duo Pro）时，可能会收到错误 `Subscription not allowed to add...`。

当您的活跃订阅满足以下条件时会出现此问题：

- 通过 [经销商购买](../billing_account.md#subscription-purchased-through-a-reseller)。
- 为多年期订阅。

要解决此问题，请联系您的 [极狐GitLab 销售代表](https://customers.jihulab.com/contact_us) 协助您完成购买。

<a id="no-purchases-listed-in-the-customers-portal-account"></a>

## 客户门户账号中未列出购买记录

要在客户门户的 **订阅与购买** 页面上查看购买记录，您必须被添加为您组织中该订阅的联系人。

要添加为联系人，请 [创建极狐GitLab 支持工单](https://support.gitlab.com/hc/en-us/requests/new?ticket_form_id=360000071293)。

<a id="unable-to-link-subscription-to-namespace"></a>

## 无法将订阅关联到命名空间

在 JihuLab.com 上，如果您无法将订阅关联到命名空间，可能是权限不足。确保您对该命名空间具有所有者角色，并查看 [转让限制](../manage_subscription.md#transfer-restrictions)。

<a id="subscription-data-fails-to-synchronize"></a>

## 订阅数据同步失败

在私有化部署的极狐GitLab 上，您的订阅数据可能无法同步。当您的极狐GitLab 实例与特定 IP 地址之间的网络流量不被允许时，可能会出现此问题。

要解决此问题，请允许从极狐GitLab 实例到 IP 地址 `172.64.146.11:443` 和 `104.18.41.245:443` (`customers.gitlab.com`) 的网络流量。

有关更多信息，请参阅 [排查连接性问题](../../administration/license.md#error-cannot-activate-instance-due-to-a-connectivity-issue)。