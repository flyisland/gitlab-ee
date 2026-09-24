---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解极狐GitLab Secrets Manager 如何计费、如何消耗极狐GitLab Credits，以及如何试用。
title: 极狐GitLab Secrets Manager 的 Credits 用量
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

极狐GitLab Secrets Manager 的使用会消耗 [极狐GitLab Credits](../../../subscriptions/gitlab_credits.md)，计费基于以下两个计量项：

- 存储的密钥：Secrets Manager 中持有的密钥数量，按每个密钥每月计量。
- 密钥操作：获取密钥（在流水线中、从 Kubernetes 集群或通过 API）计为一次操作。密钥更新和删除不计为操作。

<a id="gitlab-credits-consumption"></a>

## 极狐GitLab Credits 消耗

用于极狐GitLab Secrets Manager 的极狐GitLab Credits 从顶级群组（命名空间）订阅中可用的 [月度承诺池](../../../subscriptions/gitlab_credits.md#monthly-commitment-pool) 和 [按需 Credits](../../../subscriptions/gitlab_credits.md#on-demand-credits) 中扣除。群组项目及子群组中的 Secrets Manager 使用量会消耗顶级群组的 Credits。

> [!note]
> 分配给每个用户的 [包含 Credits](../../../subscriptions/gitlab_credits.md#included-credits) 不适用于极狐GitLab Secrets Manager。

极狐GitLab Credits 用量上限不限制 Secrets Manager 的使用。由于用量不归属于单个用户，因此按用户设置的上限不适用；命名空间支出上限也不会阻止 Secrets Manager 的消耗。

Credits 按以下费率消耗，用于密钥存储和操作：

| 类型           | 费率                 | Credits | 详情 |
|----------------|-----------------------|---------|---------|
| 存储的密钥 | 每个密钥，每月 | 1       | Credit 消耗按天按比例计算，基于密钥存在的时长。例如，两个密钥存储半个月消耗 1 个 Credit。 |
| 密钥读取   | 2,500 次读取       | 1       | 所有密钥的读取操作。包括通过 CI/CD 作业、Secrets Manager API 或集成（ESO、Terraform、OpenBao CLI）检索密钥。 |

在 [极狐GitLab Credits 仪表板](../../../subscriptions/gitlab_credits_dashboard.md) 中查看和管理 Credits 用量。

<a id="in-cicd-jobs"></a>

### 在 CI/CD 作业中

CI/CD 作业中每次成功获取的密钥计为一次读取操作，即使该作业后续失败也是如此。引用多个密钥的作业会为每个密钥执行一次读取操作。如果您重试该作业，密钥会再次被获取。

如果读取操作失败，则密钥操作不消耗 Credits，包括以下情况：

- 引用的密钥不存在。
- 由于权限错误导致读取失败。

<a id="examples"></a>

### 示例

为帮助您评估不同情况下密钥的预期月度消耗，以下是一些示例：

- 一个小型团队存储了 25 个密钥，每月运行 500 次流水线，每次流水线读取 5 个密钥。
  - 存储：25 个密钥 = 25 Credits
  - 操作：2,500 次读取 = 1 Credit
  - 月度总计：26 Credits
- 一个多环境应用在开发、预发布和生产环境中存储了 120 个密钥，每月运行 2,000 次流水线，每次流水线读取 5 个密钥。
  - 存储：120 个密钥 = 120 Credits
  - 操作：10,000 次读取 = 4 Credits
  - 月度总计：124 Credits
- 企业级使用场景，存储了 1,000 个密钥，每月运行 50,000 次流水线，每次流水线读取 10 个密钥。
  - 存储：1,000 个密钥 = 1,000 Credits
  - 操作：500,000 次读取 = 200 Credits
  - 月度总计：1,200 Credits

<a id="when-your-subscription-ends"></a>

## 订阅到期时

当您命名空间的专业版或旗舰版订阅被取消或到期时，Secrets Manager 会进入一个从订阅结束日期开始的 14 天宽限期。

在宽限期内：

- 流水线和服务账号仍可执行密钥读取操作。
- 您无法创建、更新或删除密钥。

宽限期结束后，密钥操作将被阻止。极狐GitLab 不会删除您的密钥，您仍可在 UI 中查看它们。

要恢复完整访问权限，请续订您的订阅。

<a id="end-of-beta"></a>

## 测试版结束

极狐GitLab Secrets Manager 的测试版使用不消耗极狐GitLab Credits。JihuLab.com 上的测试版将于 2026 年 9 月 21 日结束。

在测试版结束前的任何时间，您都可以开始试用并使用临时评估 Credits。试用结束时，您必须确保订阅中有可用的极狐GitLab Credits，以避免任何服务中断。

如果您不开始试用，极狐GitLab Secrets Manager 将在测试版结束时被禁用。

<a id="start-a-trial"></a>

## 开始试用

您可以通过 30 天免费试用评估极狐GitLab Secrets Manager。该试用提供一个 500 Credits 的 [临时评估 Credits](../../../subscriptions/gitlab_credits.md#temporary-evaluation-credits) 池，用于存储的密钥和密钥操作。

试用在以下任一情况发生时结束：

- 激活后满 30 天。
- 所有临时评估 Credits 已用完。

临时评估 Credits 在命名空间内共享，不按用户分配。它们不会结转，过期后无法使用。

您只能为您的订阅激活一次试用。如果您的命名空间之前使用过试用，则没有资格再次激活。

先决条件：

- 您必须对顶级群组具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到**，并找到您的顶级群组。
1. 在左侧边栏中，选择 **安全** > **Secrets Manager**。
1. 选择 **开始 30 天试用**。

试用结束时：

- 如果您的订阅中有 [可用的极狐GitLab Credits](../../../subscriptions/gitlab_credits.md)，使用将无中断地继续，先从月度承诺池中扣除，再从按需 Credits 中扣除。
- 如果您无法使用极狐GitLab Credits，Secrets Manager 操作将被阻止，因此读取操作和依赖的流水线将失败。要恢复访问权限，您必须 [购买极狐GitLab Credits](../../../subscriptions/gitlab_credits.md#buy-gitlab-credits)。
