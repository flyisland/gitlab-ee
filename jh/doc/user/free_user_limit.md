---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 基础版用户和群组限制
---

{{< details >}}

- Tier: 基础版
- Offering: JihuLab.com

{{< /details >}}

如果您使用的是基础版，以下用户和群组限制将会生效。

<a id="free-user-limit"></a>

## 基础版用户限制

在 JihuLab.com 上，您可以向新创建的、具有私有可见性的顶级命名空间添加最多五个用户。

如果命名空间是在 2022 年 12 月 28 日之前创建的，该用户限制已于 2023 年 6 月 13 日生效。

拥有超过五个用户的顶级私有命名空间将被设为只读状态。这些命名空间无法向以下任何对象写入新数据：

- 代码仓库
- Git 大文件存储（LFS）
- 软件包
- 镜像仓库

有关受限操作的完整列表，请参阅[只读命名空间](read_only_namespaces.md)。

用户限制不适用于以下处于基础版中的用户：

- JihuLab.com，对于：
  - 公开顶级群组
  - 个人命名空间 (因为它们默认是公开的)
  - 付费版本
  - 以下[社区计划](https://gitlab.cn/community/)：
    - GitLab for Open Source
    - GitLab for Education
    - GitLab for Startups
- [私有化部署订阅](../subscriptions/manage_subscription.md)

更多信息，您可以[联系专家](https://page.jihulab.com/usage_limits_help.html)。

<a id="top-level-group-limits"></a>

## 顶级群组限制

2026年1月27日之后在基础版上创建的账户最多只能有三个顶级群组（群组命名空间）。
您的[个人命名空间](namespace/_index.md#types-of-namespaces)不计入此限制。
此限制同样适用于正在试用旗舰版的账户。

如需创建更多群组，请升级到付费版本。

<a id="determine-namespace-user-counts"></a>

## 确定命名空间用户计数

具有私有可见性的顶级命名空间中的每个唯一用户都计入五个用户的限制。这包括该命名空间内每个群组、子群组和项目中的每个用户。

例如，有两个群组，`example-1` 和 `example-2`。

`example-1` 群组拥有：

- 一位群组所有者，`A`。
- 一个名为 `subgroup-1` 的子群组，其中有一位成员，`B`。
  - `subgroup-1` 从 `example-1` 继承了成员 `A`。
- 在 `subgroup-1` 中有一个名为 `project-1` 的项目，有两位成员，`C` 和 `D`。
  - `project-1` 从 `subgroup-1` 继承了成员 `A` 和 `B`。

命名空间 `example-1` 有四位唯一成员：`A`、`B`、`C` 和 `D`，因此没有超过五用户限制。

`example-2` 群组拥有：

- 一位群组所有者，`A`。
- 一个名为 `subgroup-2` 的子群组，其中有一位成员，`B`。
  - `subgroup-2` 从 `example-2` 继承了成员 `A`。
- 在 `subgroup-2` 中有一个名为 `project-2a` 的项目，有两位成员，`C` 和 `D`。
  - `project-2a` 从 `subgroup-2` 继承了成员 `A` 和 `B`。
- 在 `subgroup-2` 中有一个名为 `project-2b` 的项目，有两位成员，`E` 和 `F`。
  - `project-2b` 从 `subgroup-2` 继承了成员 `A` 和 `B`。

命名空间 `example-2` 有六位唯一成员：`A`、`B`、`C`、`D`、`E` 和 `F`，因此超过了五用户限制。

<a id="manage-members-in-your-group-namespace"></a>

## 管理群组命名空间中的成员

为了帮助您管理基础版的用户限制，您可以查看并管理命名空间中所有项目和群组的成员总数。

先决条件：

- 您必须拥有该群组的**所有者**角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **使用量配额**。
1. 要查看所有成员，选择 **席位** 选项卡。

在此页面上，您可以查看和管理命名空间中的所有成员。例如，要移除某个成员，选择 **移除用户**。

<a id="include-a-group-in-an-organizations-subscription"></a>

## 将群组纳入组织的订阅

如果您的组织中有多个群组，它们可能同时拥有付费（专业版或旗舰版）和基础版订阅。当一个拥有基础版订阅的群组超过用户限制时，其命名空间将变为[只读](read_only_namespaces.md)。

若要消除基础版订阅群组的用户限制，请将这些群组纳入您组织的订阅中：

1. 若要检查某个群组是否已纳入订阅，
   [查看该群组的订阅详情](../subscriptions/manage_subscription.md#view-subscription)。

   如果该群组拥有基础版订阅，则它不在您组织的订阅范围内。

1. 要将某个群组纳入您付费的专业版或旗舰版订阅中，
   [将该群组转移](group/manage.md#transfer-a-group)到您组织的顶级命名空间中。

如果您的群组即使有专业版或旗舰版的付费订阅，仍被施加了五用户限制，请确保
[您的订阅已关联](../subscriptions/manage_subscription.md#link-subscription-to-a-group)到以下任一项：

- 正确的顶级命名空间。
- 您的[客户门户](../subscriptions/billing_account.md) 账户。

<a id="impact-of-transferred-groups-on-subscription-costs"></a>

### 转移群组对订阅成本的影响

当您将群组转移到组织的订阅时，这可能会增加您的席位数量。这可能会给您的订阅带来额外费用。

例如，您的公司有群组 A 和群组 B：

- 群组 A 拥有付费的专业版或旗舰版订阅，并有五位用户。
- 群组 B 拥有基础版订阅，有八位用户，其中四位是群组 A 的成员。
- 群组 B 因为超过五用户限制而处于只读状态。
- 您将群组 B 转移到公司的订阅中以消除只读状态。
- 您的公司需要为群组 B 中未包含在群组 A 中的四位成员额外支付四个席位的费用。

不属于顶级命名空间的用户需要额外的席位才能保持活跃。更多信息，请参阅
[为您的订阅购买席位](../subscriptions/manage_seats.md#buy-more-seats)。

<a id="increase-the-five-user-limit"></a>

## 增加五用户上限

在 JihuLab.com 的基础版订阅中，您无法增加具有私有可见性的顶级群组的五用户限制。

对于更大的团队，您应该升级到付费的专业版或旗舰版。这些版本不限制用户数量，并拥有更多功能以提高团队生产力。更多信息，请参阅[升级私有化部署的订阅版本](../subscriptions/manage_subscription.md#upgrade-subscription-tier)。

在决定升级前，您可以开始
[免费试用](https://jihulab.com/-/trial_registrations/new?glm_source=gitlab.cn/docs/user/free_user_limit/) 极狐GitLab 旗舰版，以体验付费版本。

<a id="manage-members-in-personal-projects-outside-a-group-namespace"></a>

## 管理群组命名空间之外的个人项目中的成员

个人项目不在顶级群组命名空间中。您可以管理每个个人项目中的用户。您的个人项目中可以拥有超过五位用户。

您应该[将个人项目移动到群组中](../tutorials/move_personal_project_to_group/_index.md)，这样您就可以：

- 将用户数量增加到五个以上。
- 购买付费版本订阅、额外的计算分钟数或存储空间。
- 在群组中使用[极狐GitLab 功能](https://gitlab.cn/pricing/feature-comparison/)。
- 开始 [免费试用](https://jihulab.com/-/trial_registrations/new?glm_source=gitlab.cn/docs/user/free_user_limit/) 极狐GitLab 旗舰版。