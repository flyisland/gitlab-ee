---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 购买额外的计算分钟数
---

{{< details >}}

1. Tier: 基础版, 专业版, 旗舰版
1. Offering: JihuLab.com

{{< /details >}}

[计算分钟](../../ci/pipelines/compute_minutes.md) 是在极狐GitLab 实例运行 [CI/CD 流水线](../../ci/_index.md) 时消耗的资源。你可以在[极狐GitLab 价格页面](https://gitlab.cn/pricing/#compute-minutes)上找到额外计算分钟的价格。

额外的计算分钟：

1. 仅在订阅中包含的月度配额用完后使用。
1. 如果在月底还有剩余，将[结转到下个月](#monthly-rollover-of-purchased-compute-minutes)。
1. 如果在购买后的 12 个月内未消耗完，则有效。
1. 计算分钟的到期尚未强制执行，这允许在到期日之后使用它们。然而，极狐GitLab 不保证计算分钟在到期日后仍然有效。
1. 在试用订阅中购买的计算分钟在试用结束或升级到付费计划后可用。
1. 当你更改订阅等级时，包括在付费等级之间或更改为基础版时，计算分钟仍然可用。

<a id="purchase-compute-minutes-for-a-group"></a>

## 为群组购买计算分钟

先决条件：

1. 你必须拥有该群组的所有者角色。

你可以为你的群组购买额外的计算分钟。你不能将购买的计算分钟从一个群组转移到另一个群组，因此请务必选择正确的群组。

1. 在左侧边栏，选择 **搜索或前往** 并找到你的群组。
1. 选择 **设置 > 使用配额**。
1. 选择 **流水线**。
1. 选择 **购买额外的计算分钟**。你将被带到客户门户。
1. 输入所需的计算分钟包数量。
1. 在 **客户信息** 部分，验证你的地址。
1. 在 **账单信息** 部分，从下拉列表中选择一种支付方式。
1. 选择 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买计算分钟**。

支付处理完成后，额外的计算分钟将添加到你的群组命名空间中。

<a id="purchase-compute-minutes-for-a-personal-namespace"></a>

## 为个人命名空间购买计算分钟

要为你的个人命名空间购买额外的计算分钟：

1. 在左侧边栏，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏，选择 **使用配额**。
1. 选择 **购买额外的计算分钟**。你将被带到客户门户。
1. 在 **订阅详情** 部分，从下拉列表中选择用户的姓名。
1. 输入所需的计算分钟包数量。
1. 在 **客户信息** 部分，验证你的地址。
1. 在 **账单信息** 部分，从下拉列表中选择一种支付方式。
1. 选择 **隐私声明** 和 **服务条款** 复选框。
1. 选择 **购买计算分钟**。

支付处理完成后，额外的计算分钟将添加到你的个人命名空间中。

<a id="monthly-rollover-of-purchased-compute-minutes"></a>

## 购买的计算分钟的月度结转

如果你购买了额外的计算分钟但没有全部使用，剩余的数量将结转到下个月。额外的计算分钟是一次性购买，每月不会续订或刷新。

例如，如果你的月度配额是 10,000 计算分钟：

1. 在 4 月 1 日，你购买了 5,000 个额外的计算分钟，因此你在 4 月有 15,000 分钟可用。
1. 在 4 月期间，你使用了 13,000 分钟，因此你使用了 5,000 个额外计算分钟中的 3,000 个。
1. 在 5 月 1 日，[月度配额重置](../../ci/pipelines/compute_minutes.md#monthly-reset-of-compute-usage)，未使用的计算分钟结转。因此，你有 2,000 个额外的计算分钟剩余，5 月总共可用 12,000 分钟。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-last-name-cant-be-blank"></a>

### 错误：`Last name can't be blank`

在购买计算分钟时，你可能会收到错误 "Last name can't be blank"。当你的个人资料的 **全名** 字段中缺少姓氏时，会出现此问题。

要解决此问题：

1. 确保你的用户个人资料中填写了姓氏：

  1. 在左侧边栏，选择你的头像。
  1. 选择 **编辑个人资料**。
  1. 更新 **全名** 字段，使其包含名字和姓氏，然后保存更改。

1. 清除浏览器缓存和 cookies，然后重试购买过程。
1. 如果错误仍然存在，请尝试使用不同的网络浏览器或隐身/私人浏览窗口。

<a id="error-attempt_exceed_limitation-attempt-exceed-the-limitation-refresh-page-to-try-again"></a>

### 错误：`Attempt_Exceed_Limitation - Attempt exceed the limitation, refresh page to try again`

在购买计算分钟时，你可能会收到错误 `Attempt_Exceed_Limitation - Attempt exceed the limitation, refresh page to try again.`

当信用卡表单提交得太快时（三次提交在一分钟内或六次提交在一小时内），会出现此问题。

要解决此问题，请等待几分钟，然后重试购买过程。
