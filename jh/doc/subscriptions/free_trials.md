---
title: 旗舰版试用
stage: Growth
group: Acquisition
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Start an Ultimate trial on JihuLab.com or 极狐GitLab Self-Managed.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以获取极狐GitLab 旗舰版的试用许可证。

在试用期间，您几乎可以使用所有旗舰版功能。

旗舰版试用许可证的有效期为：

- 如果您当前为基础版，有效期为 30 天。
- 如果您当前为专业版，有效期为 60 天。

试用期从您收到包含激活码的确认邮件时开始，而非从激活时开始。

试用期结束后，您将无法再使用付费功能。要继续使用，您可以[购买订阅](manage_subscription.md#buy-a-subscription)。

<a id="gitlab-duo-agent-platform-trials"></a>

## 极狐GitLab Duo Agent Platform 试用

先决条件：

- 对于私有化部署实例，您必须使用极狐GitLab 18.9 或更高版本。
- 对于 JihuLab.com，您的试用必须在 2026 年 2 月 10 日之后开始。

如果您当前为基础版，并开启旗舰版试用，您的试用包含每位用户 24 个[极狐GitLab 积分](gitlab_credits.md#included-credits)。您可以使用这些积分来测试极狐GitLab Duo Agent Platform 功能。

对于 JihuLab.com，如果您已经[购买了月度承诺池](gitlab_credits.md#for-the-free-tier-on-gitlabcom)，试用期间不会为您分配额外的积分。试用期间使用的积分将从池中扣除。

积分在试用期内有效（30 天）。如果您购买订阅或试用结束后，未使用的积分不会结转。如果您在试用结束前用完了所有包含的积分，您将无法获得更多积分。

如果您尚未设置[默认极狐GitLab Duo 命名空间](../user/profile/preferences.md#set-a-default-gitlab-duo-namespace)，则无法在试用期间使用需要代理端点的人工智能功能。这包括外部代理和直接 `/v1/proxy` API 调用（例如，使用极狐GitLab 令牌通过 CLI、IDE 或自定义脚本调用代理）。此限制不影响 Agentic Chat，以及自定义和内置 Agent 与流程。

如果您已经开启或完成了一个不包含积分的试用，您可以开始一个新的试用：

- 如果您的试用已过期，您可以立即开始新的试用。
- 如果您的试用仍在进行中，您必须先完成当前的试用期，然后才能开始新的试用。

如果您当前为专业版，您的试用不会在现有每位用户包含的积分之上提供额外积分。您可以申请额外的[临时评估积分](gitlab_credits.md#temporary-evaluation-credits) 来试用极狐GitLab Duo Agent Platform 功能。

<a id="start-a-trial-on-gitlab-com"></a>

## 在 JihuLab.com 上开始试用

即使您尚未注册极狐GitLab 账户，也可以开始试用。

<a id="if-you-dont-have-an-account"></a>

### 如果你没有账户

如果您没有极狐GitLab 账户，要开始免费试用：

1. 前往 <https://jihulab.com/-/trial_registrations/new>。
1. 填写表单详细信息，然后选择 **继续**。
1. 完成剩余步骤，然后选择 **创建项目**。您将进入新项目，并以您创建的新用户身份登录。
1. 在左侧边栏底部，一个小部件会显示您的试用类型和试用剩余天数。

<a id="if-you-already-have-an-account"></a>

### 如果你已有账户

如果您已有极狐GitLab 账户，可以直接从群组设置中开始试用。

先决条件：

- 您必须对将应用试用的顶级群组具有所有者角色。通过群组成员身份的间接所有权是不够的。
- 该顶级群组之前不能使用极狐GitLab 积分进行过试用。

要开始试用：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **计费**。
1. 选择 **开始免费试用**。
1. 填写字段。
1. 选择 **继续**。
1. 选择应应用试用的群组。
1. 选择 **激活我的试用**。

您的试用将立即开始。在左侧边栏底部，一个小部件会显示您的试用类型和试用剩余天数。

<a id="start-a-trial-on-gitlab-self-managed"></a>

## 在私有化部署实例上开始试用

要开始私有化部署实例的试用，请填写表单以通过电子邮件接收试用许可证。

先决条件：

- 您必须[安装](../install/_index.md)并配置了私有化部署实例。
- 您的实例必须能够与极狐GitLab [同步您的订阅数据](manage_subscription.md#subscription-data-synchronization)。
- 您必须是管理员。

要开始试用：

1. 前往[极狐GitLab 旗舰版](https://gitlab.cn/free-trial/?hosted=self-managed)试用页面。
1. 填写字段。
1. 选择 **开始**。
1. 检查您的电子邮件中是否有试用激活码。
   包含激活码的邮件会在提交试用请求后不久发送到您在试用申请表中所提供的电子邮件地址。
   激活码仅供一次性使用。
1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **订阅**。
1. 将激活码粘贴到 **激活码** 中。
1. 阅读并接受服务条款。
1. 选择 **激活**。

订阅已激活。

<a id="view-remaining-trial-period-days"></a>

## 查看试用期剩余天数

您可以跟踪剩余试用期时间，以便规划订阅升级。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏底部，一个小部件会显示您的试用类型和试用剩余天数。
1. 在私有化部署实例上，要访问有关升级后可用的功能信息，请选择 **了解更多**。

