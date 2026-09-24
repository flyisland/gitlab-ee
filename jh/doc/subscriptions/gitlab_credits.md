---
stage: Fulfillment
group: Utilization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Understand how GitLab Credits work and view your credit usage.
title: 极狐GitLab Credit 及用量计费
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.7 中引入。
- 极狐GitLab Duo Agent Platform 和 极狐GitLab Credit 在 极狐GitLab 18.8 及更高版本中支持。
- 在 极狐GitLab 18.11 中为基础版订阅引入。

{{< /history >}}

极狐GitLab Credit 是按量计费的标准化消费货币。
Credit 用于[极狐GitLab Duo Agent Platform](../user/duo_agent_platform/_index.md)，每次使用操作都会消耗一定数量的 Credit。

Credit 根据你使用的功能和模型计算，如 Credit 乘数表中所列。
你需为[正式发布（GA）](../policy/development_stages_support.md#generally-available)的功能付费。

计费发生在根命名空间或顶级群组级别，而非项目级别。
Credit 用量归因于执行操作的用户，无论他们在哪个项目中使用这些功能。
根命名空间或顶级群组中的所有用量都将合并计费。

极狐GitLab 提供以下获取 Credit 的方式：

- 月度额度
- 预购额度

有关 Credit 定价的信息，请参见[极狐GitLab 定价](https://gitlab.cn/pricing/)。

<a id="monthly-commitment-pool"></a>

## 月度额度

月度额度是一个供订阅中所有用户使用的共享 Credit 池。

你可以按年或多年合同期购买 Credits。
每年购买的总 Credit 除以 12 个月。

例如，当你购买 1,000 Credit 的月度额度时，
在合同期内，你每月将有 1,000 Credit 可用。

你可以随时通过极狐GitLab 客户经理团队增加 Credits。
新增的月度额度将适用于合同的剩余期限。
你只能在续费时减少月度额度。

你可以通过内置的分层折扣购买 Credits。
月度额度在合同期开始时一次性付款。

购买后 Credit 立即可用，并在每月初重置。
未使用的 Credit 不会结转到下个月。

> [!note]
> 购买 Credits即表示你接受本用量计费条款，包括预购额度的使用。

<a id="on-demand-credits"></a>

## 预购额度

预购额度是月度额度的补充，用于应对月度额度不够用的情况。当你当月的月度额度即将或已经耗尽，可通过购买预购额度继续使用，避免业务中断。

**核心规则**

| 项目         | 说明                                                 |
| ------------ | ---------------------------------------------------- |
| **价格**     | 每 Credit **1 元人民币**（标价消费，无折扣）         |
| **购买方式** | 一次性充值，到账即可用                               |
| **有效期**   | 与你 **GitLab 订阅的截止日期一致**，到期清零、不结转 |
| **消耗顺序** | **先扣月度额度，月度额度用尽后再扣预购额度**         |

**举例说明**

以某客户为例：

1. **1 月 1 日**：购买旗舰版，订阅有效期至 **12 月 31 日**。
2. **4 月 1 日**：购买 Credits **10,000 Credit/月**，合同剩余 9 个月，总价 **90,000 元**（10,000 Credit/月 × 9 个月 × 1 元/Credit）。
3. **5 月 20 日**：发现月度额度即将耗尽，增购 **30,000 预购额度**，有效期至 **12 月 31 日**。
4. **6 月**：当月共消耗 **15,000 Credit**：
   - 先扣月度额度 **10,000**；
   - 不足部分从预购额度扣 **5,000**；
   - 预购额度剩余 **25,000**，可继续在订阅期内使用。

**温馨提示**

- 预购额度**不会按月重置**，购买后在订阅有效期内持续可用，直至订阅到期或额度耗尽。
- 由于有效期跟随订阅截止日期，建议结合订阅剩余时长按需采购，避免到期未用完造成浪费。
- 日常用量稳定时优先使用月度额度；预购额度更适合应对**突发的临时性超额需求**。


<a id="temporary-evaluation-credits"></a>

## 申请试用

如需申请试用，请[联系销售团队](https://gitlab.cn/sales/)。


<a id="for-the-free-tier-on-jihulabcom"></a>

## 适用于 JihuLab.com 上的基础版

{{< details >}}

- Tier: 基础版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.10 中引入。

{{< /history >}}

JihuLab.com 上基础版用户可以为其群组命名空间购买 极狐GitLab Credit 的月度额度。这使他们能够访问一系列[极狐GitLab Duo Agent Platform 功能](../user/duo_agent_platform/_index.md)，而无需 专业版或旗舰版订阅。


<a id="buy-gitlab-credits"></a>

## 购买 极狐GitLab Credit

你可以在 Customers Portal 中购买 极狐GitLab Credit 月度额度。

{{< tabs >}}

{{< tab title="Customers Portal" >}}

先决条件：

- 你必须是计费账户管理员。

1. 登录 [Customers Portal](https://customers.jihulab.com/)。
1. 在相关订阅卡上，选择 **极狐GitLab Credit 仪表盘**。
1. 选择 **购买 Credits** 或 **增加 Credits**。
1. 输入你想要购买的 Credit 数量。
1. 选择 **审查订单**。验证 Credit 数量、客户信息和付款方式是否正确。
1. 选择 **确认购买**。

{{< /tab >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 你必须具有群组的**所有者**角色。

对于**专业版**和**旗舰版**：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的顶级群组。
1. 选择 **设置** > **极狐GitLab Credit**。
1. 选择 **购买 Credits** 或 **增加 Credits**。
1. 在 Customers Portal 表单中，输入你想要购买的 Credit 数量。
1. 选择 **审查订单**。验证 Credit 数量、客户信息和付款方式是否正确。
1. 选择 **确认购买**。

对于**基础版**：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的顶级群组。
1. 选择 **设置** > **计费**。
1. 如果你：
   - 未处于试用期：在 极狐GitLab Credit 卡片上，选择 **购买 Credits** 或 **增加 Credits**。
   - 处于有效试用期：在 极狐GitLab Credit 卡片上，选择 **购买 Credits** 或 **增加 Credits**。
2. 在 Customers Portal 表单中，输入你想要购买的 Credit 数量。
3. 选择 **审查订单**。验证 Credit 数量、客户信息和付款方式是否正确。
4. 选择 **确认购买**。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 你必须是管理员。
- 你的实例必须能够与 极狐GitLab 同步订阅数据。

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **订阅**。
3. 选择 **购买Credit**。
4. 在 Customers Portal 表单中，输入你想要购买的 Credit 数量。
5. 选择 **审查订单**。验证 Credit 数量、客户信息和付款方式是否正确。
6. 选择 **确认购买**。

{{< /tab >}}

{{< /tabs >}}

你的 极狐GitLab Credit 将显示在 Customers Portal 的订阅卡和 极狐GitLab Credit 仪表盘中。

<a id="credit-multipliers"></a>

## Credit 乘数

Credit 用量根据所使用的功能和模型计算。
某些功能有多个模型选项可供选择，而其他功能则只使用一个模型。

一次请求代表由用户发起的单个（可计费）操作（例如，发送聊天消息或请求代码生成）。
这从用户角度来看是一次交互。

一次模型调用代表为满足用户请求而对 LLM 发起的底层 API 调用。
单个用户请求可能触发多次模型调用。例如，一次调用理解上下文，另一次调用生成响应。

<a id="models"></a>

### 模型

下表列出使用 1 个 极狐GitLab Credit 可以针对不同[模型](../user/duo_agent_platform/model_selection.md)进行的 LLM 调用次数。
更新、更复杂的模型具有更高的乘数，需要更多 Credit。

模型使用量根据以下计费方式收费：

- 极狐GitLab 托管模型的可变定价：一次请求等同于一次 LLM 调用。一个流程进行一次或多次调用。 Credit 成本取决于所使用的模型。
- 极狐GitLab Duo 功能的固定定价：每次成功的端到端执行都会消耗预设数量的 Credit，无论执行过程中进行了多少次 LLM 调用。

只有完成的调用或执行才会计费。
如果调用或执行失败，不会扣减 Credit。


| 模型                   | 1 Credit 可支持的调用次数 |
| ---------------------- | ------------------------- |
| `DeepSeek-V4-Pro-0813` | 1.6                       |
| `DeepSeek-V4-Flash`    | 4.8                       |
| `Qwen3.7-Max`          | 2.1                       |
| `Qwen3.8-max`          | 1.9                       |
| `GLM-5.2`              | 2.7                       |
| `GLM-5.3`              | 1.7                       |
| `MiniMax-M3`           | 6.2                       |
| `MiniMax-M2.7`         | 12.1                      |
| `mimo-v2.5-pro`        | 5.0                       |
| `Kimi-K2.6`            | 3.4                       |
| `Kimi-K3`              | 0.8                       |

<a id="features"></a>

### 功能

下表列出了对于不同功能，使用 1 个 极狐GitLab Credit 可以进行的执行次数。
同一个功能，选用不同模型，消耗的 Credits 不一样：性能更高的模型，单次调用会消耗更多额度。

| 功能                    | 模型              | 1 Credit 可支持的调用次数 |
| ----------------------- | ----------------- | ------------------------- |
| 代码审查流程            | 默认              | 1.0                       |
| 代码审查流程            | `DeepSeek-V4 Pro` | 0.8                       |
| 代码审查流程            | `Kimi K3`         | 0.4                       |
| SAST 误报检测流程       | 默认              | 0.8                       |
| 密钥误报检测流程        | 默认              | 0.8                       |
| SAST 漏洞修复流程       | 默认              | 0.2                       |
| 极狐GitLab Duo 代码生成 | 默认              | 1.0                       |
| 极狐GitLab Duo 代码生成 | `DeepSeek-V4 Pro` | 0.8                       |
| 极狐GitLab Duo 代码补全 | 默认              | 15.8                      |

> [!note]
> 代码审查流程当前处于促销期，上表所列为促销定价。

对于 极狐GitLab Duo Agentic Chat，一条已发送的消息计为一个或多个可计费请求，
因为回答问题会进行一次或多次 LLM 调用。
一个对话窗口可以包含多条消息，因此包含多个可计费请求。
定价取决于所选模型。

<a id="gitlab-credits-dashboard"></a>

## 极狐GitLab Credit 仪表盘

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.7 中引入。
- 结果排序在 极狐GitLab 18.10 中引入。

{{< /history >}}

极狐GitLab Credit 仪表盘显示你的 极狐GitLab Credit 用量信息。
使用仪表盘来监控 Credit 消耗、跟踪趋势并识别使用模式。

在仪表盘上，已使用的 Credit 代表从可用 Credit 中的扣减。

为帮助你管理 Credit 消耗，极狐GitLab 会向管理员和订阅所有者发送以下电子邮件信息：

- 每月 Credit 用量摘要
- 当 Credit 用量达到 50%、80% 和 100% 阈值时的通知

你可以在 Customers Portal 和 极狐GitLab 中访问仪表盘。

> [!note]
> 用量数据并非实时显示。
> 数据会定期同步到仪表盘，因此用量数据应在实际消耗后的几小时内显示。
> 这意味着你的仪表盘显示的是最近的用量，但可能未反映过去几个小时内进行的操作。

<a id="in-customers-portal"></a>

### 在 Customers Portal 中

Customers Portal 中的 极狐GitLab Credit 仪表盘提供了最详细的用量和成本视图。

仪表盘显示关键指标的摘要卡片：

- **本月用量**：当前月使用的 极狐GitLab Credit 总数（如果你有月度额度）
- **月度额度**：月度额度中的 Credit（如果适用）
- **预购额度**：超出月度额度的已消耗 Credit。

<a id="in-gitlab"></a>

### 在 极狐GitLab 中

极狐GitLab 中的 极狐GitLab Credit 仪表盘提供了组织内 Credit 使用的运营可见性。
使用仪表盘了解哪些用户、群组或项目推动了用量，并就资源分配做出明智的决策。

仪表盘显示以下信息：

- **组织用量**：你的 极狐GitLab 实例或群组的总 Credit 用量
- **用量趋势**：当前计费周期内累计消耗的 Credit 数量，以累积面积图显示。虚线阈值线表示每种 Credit 类型的总可用 Credit。
- **用量概览**：按 Credit 类型细分的每日 Credit 消耗，以堆叠条形图显示
- **用户用量**：每位用户使用的 Credit 数量
- **用户向下钻取视图**：每位用户的个人使用事件，并附有指向 极狐GitLab Duo Agent Platform 会话详情的链接

> [!note]
> **用量趋势** 图表仅在以下情况下可用：
>
> - 你没有临时评估 Credit。
> - 你有月度额度或预购额度。

<a id="view-the-gitlab-credits-dashboard"></a>

### 查看 极狐GitLab Credit 仪表盘

{{< history >}}

- 历史用量周期选择在 极狐GitLab 18.11 中引入。

{{< /history >}}

{{< tabs >}}

{{< tab title="Customers Portal" >}}

先决条件：

- 要查看详细的用量信息，你必须是计费账户管理员。

1. 登录 [Customers Portal](https://customers.jihulab.com/)。
1. 在订阅卡上，选择 **极狐GitLab Credit 仪表盘**。
1. 可选。要查看前一个月的数据，请从 **用量周期** 下拉列表中选择你想要查看的周期。
1. 可选。要按 **用户** 或 **总 Credit 使用量** 对结果排序，请选择相应的列。

{{< /tab >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 你必须具有群组的**所有者**角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的顶级群组。
1. 选择 **设置** > **极狐GitLab Credit**。
1. 可选。要按 **用户** 或 **总 Credit 使用量** 对结果排序，请选择相应的列。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 你必须是管理员。
- 你的实例必须能够与 极狐GitLab 同步订阅数据。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Credit**。
1. 可选。要按 **用户** 或 **总 Credit 使用量** 对结果排序，请选择相应的列。

{{< /tab >}}

{{< /tabs >}}

默认情况下，个人用户数据不会显示在 极狐GitLab Credit 仪表盘中。
要显示它，你必须为你的[群组](../user/group/manage.md#display-gitlab-credits-user-data)或[实例](../administration/settings/visibility_and_access_controls.md#display-gitlab-credits-user-data)启用此设置。

<a id="usage-caps"></a>

### 使用上限

{{< details >}}

- Status: Beta

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 18.11 中引入，带有名为 `budget_caps_graphql_api` 的[功能标志](../administration/feature_flags/_index.md)。默认启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。

你可以在用户级别设置每月 极狐GitLab Credit 上限，以防止意外的超额费用。当 Credit 消耗达到配置的上限时，对消耗 极狐GitLab Credit 的功能（例如，极狐GitLab Duo Agent Platform）的访问将自动暂停，直到下一个计费周期开始，或直到管理员调整或禁用该上限。

提供以下几种上限类型：

| 上限类型     | 适用于                   | 计入的 Credit 来源 | 管理方式    |
| ------------ | ------------------------ | ------------------ | ----------- |
| 固定用户上限 | 个人用户（默认限制）     | 全部               | GraphQL API |
| 每用户覆盖   | 特定用户（覆盖固定上限） | 全部               | GraphQL API |

达到上限的用户将无法访问 极狐GitLab Duo Agent Platform 功能，直到上限被提高或下一个计费周期开始。

用量计数器在每个计费周期开始时自动重置。
上限值在计费周期之间保持不变，除非被更改。

上限的实施基于最新的可用用量数据。由于数据并非实时，在上限生效前可能会产生有限的额外 极狐GitLab Credit 用量。

<a id="set-a-usage-cap"></a>

#### 设置使用上限

你可以使用 GraphQL API 来[查看使用上限](../api/graphql/reference/_index.md#gitlabsubscriptionbudgetcaps) 并设置[固定用户级别上限](../api/graphql/reference/_index.md#mutationupsertflatusercap)或[每用户覆盖上限](../api/graphql/reference/_index.md#mutationupsertuserbudgetcapoverrides)。

<a id="usage-control-status"></a>

### 使用控制状态

{{< history >}}

- 在 极狐GitLab 18.11 中引入。

{{< /history >}}

启用每用户 Credit 上限后，极狐GitLab Credit 仪表盘上的 **用户用量** 选项卡会显示 **使用控制状态** 列。
此列显示每个用户是否可以访问
[极狐GitLab Duo Agent Platform](../user/duo_agent_platform/_index.md) 功能，或因达到 Credit 上限而被阻止。

此列显示以下状态之一：

| 状态                        | 描述                                                                    |
| --------------------------- | ----------------------------------------------------------------------- |
| **常规**                    | 用户尚未达到 Credit 上限，可以使用 极狐GitLab Duo Agent Platform 功能。 |
| **已阻止 - 用户上限已达到** | 用户达到了固定用户上限，或为其专门设置的每用户覆盖上限。                |

<a id="unblock-a-user-who-reached-their-credit-cap"></a>

#### 解除对达到 Credit 上限的用户的阻止

你可以通过使用每用户覆盖 GraphQL API 来恢复对被阻止用户的访问。

要解除阻止用户，你可以执行以下任一操作：

- 提高上限：设置更高的每用户覆盖上限，使用户用量低于新的限制。
- 移除上限：删除每用户覆盖，使用户不再受个人上限的限制。

更新上限后，用户的状态将变为 **常规**，并且他们可以再次使用 极狐GitLab Duo Agent Platform 功能。

<a id="view-user-credit-usage-details"></a>

### 查看用户 Credit 使用详情

{{< history >}}

- 链接到 极狐GitLab Duo Agent Platform 会话详情在 极狐GitLab 18.10 中引入。

{{< /history >}}

要在向下钻取视图中查看用户个人使用事件：

1. 在 极狐GitLab Credit 仪表盘中，选择 **用户用量** 选项卡。
1. 在 **用户** 列中，选择你要查看的用户。
1. 要查看会话详情，在 **操作** 列中，选择你要查看的操作。

> [!note]
> 会话链接仅适用于在项目中触发且具有关联会话 ID 的 极狐GitLab Duo Agent Platform 使用事件。
> 在群组中触发的使用事件、旧版事件以及 Agent Platform 之外的操作没有链接。

<a id="export-usage-data"></a>

### 导出用量数据

{{< history >}}

- 在 极狐GitLab 18.10 中引入。

{{< /history >}}

你可以在 Customers Portal 中将订阅的 Credit 用量数据导出为 CSV 文件。
CSV 文件会列出当月每天的使用事件和所用 Credit。
先决条件：

- 你必须是计费账户管理员。

1. 登录 [Customers Portal](https://customers.jihulab.com/)。
1. 在订阅卡上，选择 **极狐GitLab Credit 仪表盘**。
1. 从 **用量周期** 下拉列表中，选择你要导出数据的周期。
1. 选择 **导出用量数据**。
