---
stage: Fulfillment
group: Utilization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 查看并管理您的 Credits 用量。
title: 极狐GitLab Credits 仪表板
---

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Credits 仪表板显示您使用极狐GitLab Credits 的相关信息。
使用该仪表板监控 Credits 消耗、跟踪趋势并识别使用模式。

为帮助您管理 Credits 消耗，极狐GitLab 会向与计费账号关联的 Customers Portal 用户发送以下电子邮件：

- 每月 Credits 使用摘要
- 当 Credits 使用阈值达到 50%、80% 和 100% 时的通知

您可以在 Customers Portal 和极狐GitLab 中访问该仪表板。
群组级和个人级 Credits 使用视图仅在 JihuLab.com 上提供。

> [!note]
> 使用数据并非实时显示。
> 数据会定期同步到仪表板，因此使用数据应在实际消耗后的几小时内显示。
> 这意味着您的仪表板会显示近期使用情况，但可能无法反映最近几小时内的操作。

<a id="in-gitlab"></a>

## 在极狐GitLab 中

> [!note]
> 该仪表板显示所有基于 Credits 的功能的使用情况，包括不收费的测试版和实验性功能。要仅查看计费使用情况，请前往 Customers Portal。
>
> 某些预发布功能（例如安全审查任务流）是计费的，并需支付
> 极狐GitLab Credits 费用。

极狐GitLab 中的极狐GitLab Credits 仪表板可让您直观了解组织中 Credits 的使用情况。
使用该仪表板了解哪些用户、群组或项目推动了使用量，并就资源分配做出明智决策。

该仪表板显示以下信息：

- **组织使用情况**：整个极狐GitLab 实例或群组中的 Credits 总用量、活跃用户数、每日 Credits 平均值和峰值日用量
- **Credits 总消耗量**：所有产品的每日 Credits 消耗量，以柱状图显示
- **按用户统计的使用量**：每个用户使用的 Credits 数量
- **用户下钻视图**：每个用户的单独使用事件，并附有每个基于 Credits 的功能的会话详情链接
- **按产品统计的使用量**：基于 Credits 的功能所使用的 Credits 数量及其占总 Credits 的百分比

> [!note]
> 虽然 [GitLab Secrets Manager](../ci/secrets/secrets_manager/_index.md) 处于测试阶段，
> 极狐GitLab 不对此使用量收费。Secrets Manager 会出现在 Credits 仪表板中，
> 但在测试期结束前不显示任何使用数据。

<a id="non-human-subject-usage"></a>

## 非人类主体使用情况

Credits 消耗可由人类用户或非人类主体（例如 SAST 误报检测任务流等 AI 功能）触发。

为帮助您识别 Credits 的消耗位置，极狐GitLab Credits 仪表板上的 **按用户统计的使用量** 选项卡会在代表非人类主体的行旁边显示 **自动任务流** 徽章。
没有徽章的行代表人类用户。

**自动任务流** 徽章的显示由 **显示极狐GitLab Credits 用户数据** 设置控制，
该设置适用于[群组](../user/group/manage.md#display-gitlab-credits-user-data)
和[实例](../administration/settings/visibility_and_access_controls.md#display-gitlab-credits-user-data)。

<a id="usage-caps"></a>

## 用量上限

您可以在订阅级别和用户级别设置每月极狐GitLab Credits 上限，以防止意外的超额费用。当 Credits 消耗达到配置的上限时，
对基于 Credits 的功能的访问
将自动暂停，直到下一个计费周期开始，
或直到管理员调整或禁用该上限。

可用的上限类型如下：

| 上限类型 | 适用范围 | 计入的 Credits 来源 | 管理方式 |
|---|---|---|---|
| 订阅上限 | 订阅中的所有用户 | 仅按需 | Customers Portal |
| 固定用户上限 | 单个用户（默认限制） | 全部 | GraphQL API |
| 每用户覆盖 | 特定用户的总用量，包括其包含的 Credits。覆盖固定上限。因此，用户最多可消耗其包含的分配量或上限中较大的一个。 | 全部 | GraphQL API |

当当前计费周期内的按需使用量达到或超过配置的上限时，
该订阅或实例上的所有用户的
所有基于 Credits 的功能
都将被暂停，并且极狐GitLab 会向计费账号管理员发送电子邮件通知。对于用户级上限，
只有达到其上限的单个用户会被暂停。

固定用户上限和每用户覆盖上限适用于用户包含的分配量之外的使用量。
当用户仍有包含的 Credits 时，即使其使用量达到上限，
他们仍可继续消耗其包含的 Credits。
只有在用户包含的 Credits 用尽后，上限才会生效。

达到上限的用户将无法访问 Agent Platform 功能，
直到上限提高或下一个计费周期开始。

使用计数器会在每个计费周期开始时自动重置。
除非更改，否则上限值会跨计费周期保留。

上限使用最新的可用使用数据来执行。由于数据
并非实时，因此在执行生效前
可能会发生有限的额外极狐GitLab Credits 使用。

上限不会阻止用户消耗其包含的极狐GitLab Credits。执行从每个用户开始，且仅在该用户包含的分配量用尽后开始。在此之前，无论上限值如何（包括上限为 `0`），用户都保留完整的极狐GitLab Duo Agent Platform 访问权限。

要立即停止所有极狐GitLab Credits 消耗，无论包含的余额如何，
请为受影响的用户或命名空间禁用极狐GitLab Duo。

上限值的应用方式取决于上限类型：

- **订阅级上限**仅适用于按需使用量。该上限是订阅中允许的按需使用量，是在每个用户包含的 Credits 之外额外计算的。
- **每用户上限**适用于用户的总用量，包括其包含的 Credits。因此，用户最多可消耗其包含的分配量或上限中较大的一个。

<a id="examples"></a>

### 示例

对于订阅级上限，假设一个订阅有 10 个用户，每个用户包含 100 个极狐GitLab Credits。计费账号管理员将订阅级按需上限设置为 `0`。

- 已用完其包含的全部 100 个 Credits 的用户会立即（在下次执行检查时）被阻止访问 Agent Platform 功能，因为任何进一步的使用都将是按需的。
- 仅使用了其包含的 40 个 Credits 的用户可以继续使用 Agent Platform 功能并消耗其剩余的 60 个包含的 Credits。`0` 上限尚不适用于他们。

对于每用户上限，假设一个用户包含 24 个极狐GitLab Credits。

- 每用户上限为 `50` 时，该用户在使用总量达到 50 个 Credits 后被阻止，即超出其包含的分配量 26 个 Credits。
- 每用户上限为 `10` 时，该用户在其包含的分配量用尽后（即使用 24 个 Credits 后）被阻止。

<a id="usage-control-status"></a>

## 使用控制状态

当启用每用户 Credits 上限时，极狐GitLab Credits 仪表板上的 **按用户统计的使用量** 选项卡会显示 **使用控制状态** 列。
此列显示每个用户是否可以访问
基于 Credits 的功能，
或者是否因达到其 Credits 上限而被阻止。

**使用控制状态** 列仅在极狐GitLab 对该用户执行上限时显示 **已阻止** 状态。
极狐GitLab 在用户包含的 Credits 用尽后执行上限。
已达到上限但仍有包含的 Credits 的用户状态为 **正常**，
因为他们可以继续消耗其包含的 Credits。

该列显示以下状态之一：

| 状态 | 描述 |
|--------|-------------|
| **正常** | 用户未达到其 Credits 上限，或已达到上限但仍有包含的 Credits，并且可以使用极狐GitLab Duo Agent Platform 功能。 |
| **已阻止 - 达到订阅上限** | 用户达到了在订阅级别设置的固定每用户上限。 |
| **已阻止 - 达到用户上限** | 用户达到了专门为其设置的每用户覆盖上限。 |

<a id="unblock-a-user-who-reached-their-credit-cap"></a>

### 为达到 Credits 上限的用户解除阻止

您可以使用每用户覆盖 GraphQL API 恢复被阻止用户的访问权限。

要解除对用户的阻止，请执行以下任一操作：

- 提高上限：设置更高的每用户覆盖上限，使用户的
  使用量低于新限制。
- 移除上限：删除每用户覆盖，使用户不再
  受个人上限约束。

更新上限后，用户的状态将更改为 **正常**，并且他们
可以再次使用基于 Credits 的功能。

<a id="view-user-credit-usage-details"></a>

## 查看用户 Credits 使用详情

要以下钻视图查看用户的单独使用事件：

1. 在极狐GitLab Credits 仪表板中，选择 **按用户统计的使用量** 选项卡。
1. 在 **用户** 列中，选择要查看的用户。
1. 要查看会话详情，请在 **操作** 列中选择要查看的操作。

> [!note]
> 会话链接仅适用于在项目中触发并具有关联会话 ID 的极狐GitLab Duo Agent Platform 使用事件。
> 在群组中触发的使用事件、旧事件以及 Agent Platform 之外的操作没有链接。
