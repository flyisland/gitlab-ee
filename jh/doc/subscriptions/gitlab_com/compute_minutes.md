---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Purchase additional compute minutes for group and personal namespaces on GitLab.com, including monthly rollover and troubleshooting.
title: 购买额外计算分钟
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

[计算分钟](../../ci/pipelines/compute_minutes.md) 是在 JihuLab.com 实例 runner 上运行 [CI/CD 流水线](../../ci/_index.md) 时消耗的资源。你可以在 [极狐GitLab 定价页面](https://gitlab.cn/pricing/#compute-minutes) 上找到额外计算分钟的定价。

额外计算分钟：

- 仅在您订阅中包含的月度配额用完后才会使用。
- 如果在月末仍有剩余，将 [结转到下个月](#monthly-rollover-of-purchased-compute-minutes)。
- 自购买之日起 12 个月内有效，若未提前消耗。
- 计算分钟的过期尚未强制执行，因此即使在过期日期后仍可使用。但是，极狐GitLab 不保证计算分钟在过期日期后仍然有效。
- 在试用订阅中购买的，在试用结束或升级到付费计划后可用。
- 更改订阅级别时仍然可用，包括在付费级别之间更改或切换到基础版。

<a id="purchase-compute-minutes-for-a-group"></a>

## 为群组购买计算分钟

您可以为您的群组购买额外计算分钟。
购买的计算分钟无法从一个群组转移到另一个群组，
因此请确保选择正确的群组。

先决条件：

- 您必须具有群组的 所有者 角色，或者是计费账户管理员。
- 计费账户必须与群组命名空间的订阅相关联。

要为群组购买计算分钟：

{{< tabs >}}

{{< tab title="群组所有者" >}}

1. 登录到 JihuLab.com。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **使用配额**。
1. 选择 **流水线**。
1. 选择 **购买额外计算分钟**。您将被引导至客户门户。
1. 在 **订阅详情** 部分，在 **数量** 字段中输入所需的计算分钟包数量。
1. 在 **客户信息** 部分，验证您的地址。
1. 在 **结算信息** 部分，从下拉列表中选择一种支付方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买计算分钟**。

{{< /tab >}}

{{< tab title="计费账户管理员" >}}

1. 前往 [客户门户](https://customers.jihulab.com/customers/sign_in)。
1. 在订阅卡片上，选择垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择 **购买更多计算分钟**。
1. 在 **订阅详情** 部分，在 **数量** 字段中输入所需的计算分钟包数量。
1. 在 **客户信息** 部分，验证您的地址。
1. 在 **结算信息** 部分，从下拉列表中选择一种支付方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买计算分钟**。

{{< /tab >}}

{{< /tabs >}}

付款处理完毕后，额外计算分钟将添加到您的群组命名空间。
额外计算分钟在 [**使用配额** 页面](../../ci/pipelines/instance_runner_compute_minutes.md#view-usage-for-a-group) 上显示为 **额外单位**。

<a id="purchase-compute-minutes-for-a-personal-namespace"></a>

## 为个人命名空间购买计算分钟

要为您的个人命名空间购买额外计算分钟：

1. 登录到 JihuLab.com。
1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **使用配额**。
1. 选择 **购买额外计算分钟**。您将被引导至客户门户。
1. 在 **订阅详情** 部分，从下拉列表中选择用户名称。
1. 输入所需的计算分钟包数量。
1. 在 **客户信息** 部分，验证您的地址。
1. 在 **结算信息** 部分，从下拉列表中选择一种支付方式。
1. 勾选 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买计算分钟**。

付款处理完毕后，额外计算分钟将添加到您的个人命名空间。
额外计算分钟在 [**使用配额** 页面](../../ci/pipelines/instance_runner_compute_minutes.md#view-usage-for-a-personal-namespace) 上显示为 **额外单位**。

<a id="monthly-rollover-of-purchased-compute-minutes"></a>

## 已购买计算分钟的月度结转

如果您购买了额外计算分钟但未用完，剩余部分将结转到下个月。额外计算分钟为一次性购买，不会每月续期或刷新。

例如，如果您的月度配额为 10,000 计算分钟：

- 4 月 1 日，您购买了 5,000 额外计算分钟，因此 4 月共有 15,000 分钟可用。
- 4 月期间，您使用了 13,000 分钟，因此使用了 5,000 额外计算分钟中的 3,000 分钟。
- 5 月 1 日，[月度配额重置](../../ci/pipelines/instance_runner_compute_minutes.md#monthly-reset)，未使用的计算分钟结转到下一月。因此您剩余 2,000 额外计算分钟，5 月总共有 12,000 分钟可用。

<a id="troubleshooting"></a>

## 故障排查

<a id="error-last-name-cant-be-blank"></a>

### 错误：`姓不能为空`

在购买计算分钟时，您可能会遇到错误“姓不能为空”。
当您的个人资料 **全名** 字段中缺少姓氏时，会发生此问题。

要解决此问题：

- 确保您的用户个人资料中填写了姓氏：

  1. 在右上角，选择您的头像。
  1. 选择 **编辑个人资料**。
  1. 更新 **全名** 字段，使其包含名字和姓氏，然后保存更改。

- 清除浏览器缓存和 Cookie，然后重新尝试购买流程。
- 如果错误仍然存在，请尝试使用不同的网络浏览器或无痕/隐私浏览窗口。

<a id="error-attempt_exceed_limitation---attempt-exceed-the-limitation-refresh-page-to-try-again"></a>

### 错误：`尝试超出限制，刷新页面重试`

在购买计算分钟时，您可能会遇到错误 `尝试超出限制，刷新页面重试`。

此问题是由于信用卡表单被提交过于频繁（1 分钟内提交 3 次或 1 小时内提交 6 次）引起的。

要解决此问题，请等待几分钟后重新尝试购买流程。