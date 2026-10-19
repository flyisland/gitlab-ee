---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解极狐GitLab 密钥管理器如何计费、如何消耗极狐GitLab Credits，以及如何试用。
title: 极狐GitLab 密钥管理器 Credits 用量
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

极狐GitLab 密钥管理器的使用会消耗[极狐GitLab Credits](../../../subscriptions/gitlab_credits.md)，
依据两个计量项：

- 存储的密钥：密钥管理器中保存的密钥数量，按每个密钥每月计量。
- 密钥操作：获取密钥（在流水线中、从 Kubernetes 集群中或通过 API）算作一次操作。
  密钥更新和删除不计为操作。

<a id="gitlab-credits-consumption"></a>

## 极狐GitLab Credits 消耗

用于极狐GitLab 密钥管理器的极狐GitLab Credits 来自顶级群组（命名空间）订阅中可用的[月度承诺额度池](../../../subscriptions/gitlab_credits.md#monthly-commitment-pool)
和[按需 Credits](../../../subscriptions/gitlab_credits.md#on-demand-credits)。
跨群组项目及子群组的密钥管理器使用量会消耗顶级群组的 Credits。

> [!note]
> 分配给每位用户的包含 Credits
> 不适用于极狐GitLab 密钥管理器。

极狐GitLab Credits 用量上限不会限制密钥管理器的使用量。按用户设置的上限不适用，因为用量不归属于单个用户，而命名空间支出上限也不会阻止密钥管理器的消耗。

密钥存储和操作按以下费率消耗 Credits：

| 类型           | 费率                 | Credits | 详情 |
|----------------|-----------------------|---------|---------|
| 存储的密钥 | 一个密钥，每月 | 1       | Credits 消耗按天按比例计算，依据密钥存在的时间长短。例如，两个密钥存储半个月消耗一个 Credit。 |
| 密钥读取   | 2,500 次读取       | 1       | 跨所有密钥的密钥读取操作。包括通过 CI/CD 作业、密钥管理器 API 或集成（ESO、Terraform、OpenBao CLI）检索密钥。 |

在[极狐GitLab Credits 仪表板](../../../subscriptions/gitlab_credits_dashboard.md)中查看和管理 Credits 用量。

<a id="in-cicd-jobs"></a>

### 在 CI/CD 作业中

在 CI/CD 作业中每成功获取一个密钥都算作一次读取操作，即使该作业随后失败也是如此。引用多个密钥的作业会为每个密钥执行一次读取操作。如果您重试该作业，密钥会被再次获取。

如果读取操作失败，密钥操作不会消耗 Credits，包括以下情况：

- 引用的密钥不存在。
- 读取因权限错误而失败。

<a id="examples"></a>

### 示例

为帮助估算不同情况下密钥的预期月度消耗量，以下是一些示例：

- 一个小型团队，存储 25 个密钥，每月 500 条流水线，每条流水线读取 5 个密钥。
  - 存储：25 个密钥 = 25 Credits
  - 操作：2,500 次读取 = 1 Credit
  - 每月总计：26 Credits
- 一个多环境应用，在开发、预发布和生产环境中存储 120 个密钥，
  每月 2,000 条流水线，每条流水线读取 5 个密钥。
  - 存储：120 个密钥 = 120 Credits
  - 操作：10,000 次读取 = 4 Credits
  - 每月总计：124 Credits
- 企业级用量，存储 1,000 个密钥，每月 50,000 条流水线，
  每条流水线读取 10 个密钥。
  - 存储：1,000 个密钥 = 1,000 Credits
  - 操作：500,000 次读取 = 200 Credits
  - 每月总计：1,200 Credits

<a id="start-a-trial"></a>

## 开始试用

您可以通过 30 天免费试用评估极狐GitLab 密钥管理器。试用提供 500 个[临时评估 Credits](../../../subscriptions/gitlab_credits.md#temporary-evaluation-credits)的额度池，用于存储的密钥和密钥操作。

试用在以下任一情况先发生时结束：

- 自激活起满 30 天。
- 所有临时评估 Credits 均已消耗。

临时评估 Credits 在整个命名空间内共享，不按用户分配。它们不会结转，过期后无法使用。

每个订阅只能激活一次试用。如果您的命名空间之前已使用过试用，则无法再激活另一次试用。

先决条件：

- 您必须拥有顶级群组的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**，并找到您的顶级群组。
1. 在左侧边栏中，选择**安全** > **密钥管理器**。
1. 选择**开始 30 天试用**。

如果您在试用期间禁用极狐GitLab 密钥管理器，您可以在试用期结束前的任何时间重新启用它。

试用结束时：

- 如果您的订阅中有[可用的极狐GitLab Credits](../../../subscriptions/gitlab_credits.md)，
  用量会不间断地继续，先从月度承诺额度池中扣除，然后从按需 Credits 中扣除。
- 如果您无法使用极狐GitLab Credits，密钥管理器操作会被阻止，
  因此读取操作和依赖的流水线会失败。要恢复访问，您必须[购买极狐GitLab Credits](../../../subscriptions/gitlab_credits.md#buy-gitlab-credits)。
