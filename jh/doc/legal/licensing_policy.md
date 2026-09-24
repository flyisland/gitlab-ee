---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 可接受的用户许可证使用
---

<a id="user-licenses-and-affiliates"></a>

## 用户许可证与关联公司

<a id="affiliated-companies-ability-to-separately-purchase-user-licenses-under-one-master-agreement"></a>

### 关联公司在一份主协议下分别购买用户许可证的能力

关联公司可以在一份主协议下各自直接向极狐GitLab 购买用户许可证，
但须遵守极狐GitLab 和具体公司间适用的交易文档条款。

客户也可以购买用户许可证，并将这些许可证部署给关联公司，但须满足以下要求。

<a id="customers-ability-to-purchase-user-licenses-and-deploy-those-licenses-to-an-affiliated-company"></a>

### 客户购买用户许可证并将这些许可证部署给关联公司的能力

除某些例外情况外，客户可以购买用户许可证，并将这些许可证部署给关联实体。
极狐GitLab 可以满足关联公司的内部采购要求和账单政策，
前提是这些要求在购买前和开票前已明确沟通。

极狐GitLab 是一家全球性公司，可能会使用特定区域的定价。如果客户想将用户许可证部署到客户购买许可证所在地理区域（定义见下文）之外，包括部署到关联公司，
极狐GitLab 可能会要求客户或关联公司接受替代定价和条件。

<a id="distinct-geographical-region-definition"></a>

### 独立地理区域：定义

“地理区域”定义为极狐GitLab 提供的报价中“售至”地址周围 4,000 英里或 6,437 公里以内。
任何在各地理区域之外使用、访问或分发许可证的行为均被严格禁止，除非经极狐GitLab 书面批准。

<a id="use-of-multiple-tiers"></a>

## 使用多个版本

极狐GitLab 提供三个版本的软件：(1) 基础版，(2) 专业版，以及 (3) 旗舰版。请参阅 <https://gitlab.cn/pricing/feature-comparison/>。

客户可以使用软件的多个版本，但须遵守本部分“使用多个版本”和下一部分“使用多个实例”中的要求。

<a id="customers-ability-use-different-tiers-of-gitlab-software"></a>

### 客户使用不同版本极狐GitLab 软件的能力

除某些例外情况外，客户可以使用不同版本的极狐GitLab 软件。这需要多个实例
（请参阅下面的“使用多个实例”）。例如，客户可能有不同的业务部门或
关联公司，各自需要极狐GitLab 软件的不同功能。该客户可能希望为一个业务部门部署专业版实例，
为另一个业务部门部署旗舰版实例。

客户应确保此类多个实例的使用保持分开和独立，以避免禁止的功能混用，本部分下文将进一步讨论。

<!-- markdownlint-disable MD013 -->

<a id="customers-or-a-customers-business-unit-or-affiliates-ability-to-use-features-from-its-premium-or-ultimate-instance-with-code-developed-in-a-free-instance"></a>

### 客户（或其业务部门或关联公司）将专业版（或旗舰版）实例的功能与基础版实例中开发的代码结合使用的能力

这是一种禁止的功能混用。虽然客户有时可能需要使用不同版本的极狐GitLab 软件的多个实例，
但客户仅限于使用相关实例特定版本的功能。
在这种情况下，尽管客户可能拥有基础版和专业版（或旗舰版）实例的合法需求，但禁止客户将专业版（或旗舰版）实例的功能与基础版实例中开发的代码结合使用。

<!-- markdownlint-enable MD013 -->

<a id="customers-ability-to-use-features-from-an-ultimate-instance-with-code-developed-in-a-premium-instance"></a>

### 客户将旗舰版实例的功能与专业版实例中开发的代码结合使用的能力

这是一种禁止的功能混用。虽然客户有时可能需要使用多个实例和
不同版本的极狐GitLab 软件，但客户仅限于使用相关实例特定版本的功能。
在这种情况下，尽管客户可能拥有专业版和旗舰版实例的合法需求，但禁止客户将旗舰版实例的功能（例如安全扫描）与专业版实例中开发的代码结合使用。

<a id="use-of-multiple-instances"></a>

## 使用多个实例

<a id="customers-ability-to-have-multiple-instances"></a>

### 客户拥有多个实例的能力

某些客户可能希望拥有多个独立的极狐GitLab 实例，用于不同的团队、子公司等。
有时，客户可能希望拥有多个极狐GitLab 实例，每个实例上有相同的用户。
根据其具体的用例，这可能需要一份或多份订阅来满足。
使用多个实例也受上述关于“使用多个版本”的限制。

<a id="customers-ability-to-have-multiple-instances-of-free-tier-gitlabcom-or-self-managed"></a>

### 客户拥有基础版实例的多个实例（JihuLab.com 或私有化部署）的能力

客户可以拥有基础版的多个实例，但受某些例外情况限制。

对于 JihuLab.com 的基础版，每个客户或实体在具有私有可见性的顶级命名空间上[最多五个用户](../user/free_user_limit.md)。
此五个用户上限是任何基础版实例的总和。因此，例如，如果一个客户拥有一个包含五个用户的基础版实例，
则该客户将被禁止启用另一个任何用户级别的基础版实例，因为已经达到了五个用户的上限。

对于私有化部署的基础版，没有五个用户的上限。

<a id="customers-ability-to-have-multiple-instances-of-self-managed-with-the-same-users"></a>

### 客户拥有使用相同用户的多个私有化部署实例的能力

这在技术上是可行的，但须满足某些条件：

根据客户与极狐GitLab 之间书面协议的条款，一个云许可证激活码（或许可证密钥）可以
应用于多个极狐GitLab 私有化部署实例，前提是这些实例上的用户：

- 相同，或者
- 是客户的已许可生产实例用户的子集。

例如，如果客户拥有一个已许可的极狐GitLab 生产实例，并且该客户拥有用户列表相同的其他实例，
则生产激活码（或许可证密钥）将适用。即使这些用户配置在不同的群组和项目中，
只要用户列表相同，激活码（或许可证密钥）将适用。

然而，如果上述任一条件不满足，客户将需要为这些用户购买一份额外订阅，用于一个单独实例。

<a id="use-of-multiple-gitlab-self-managed-instances-with-a-single-license-key-or-activation-code"></a>

## 使用单个许可证密钥或激活码管理多个极狐GitLab 私有化部署实例

<a id="validating-when-one-license-or-activation-code-is-applied-to-multiple-instances"></a>

### 验证将一个许可证或激活码应用于多个实例的情况

极狐GitLab 要求与其客户签订书面协议，约定极狐GitLab 有审计和验证客户是否遵守本文档条款的权利。

<a id="calculating-billable-users-when-one-license-key-or-activation-code-is-applied-to-multiple-instances"></a>

### 计算将单个许可证密钥或激活码应用于多个实例时的计费用户数

当单个许可证文件或激活码应用于多个实例时，极狐GitLab 会检查与该订阅关联的所有实例，
以确定具有**最高计费用户数**的实例。这将用于计算诸如“计费用户”和“最大用户”等值，并将用于季度订阅对账和自动续订（如果已启用）。

通过这种方式，极狐GitLab 假设所有其他用户数较低的实例包含与此主实例相同或为子集的用户。

<!-- markdownlint-disable MD013 -->

<a id="visibility-into-latest-usage-data-and-how-to-identify-which-of-the-customers-instances-the-data-is-for"></a>

### 了解最新使用数据，以及如何识别数据针对客户的哪个实例

极狐GitLab 私有化部署共享的使用数据存储在 CustomersDot 下的 `License seat links` 中。对于使用云许可证的客户，每天记录数据；对于使用离线许可证并通过电子邮件（每月要求）共享其使用数据的客户，则在收到时记录。
要查看此数据，客户可以按 `Company` 名称或 `Subscription` 名称进行搜索。同时记录的数据还包括 `Hostname` 和 `Instance identifier` ID，这有助于表明数据是来自生产实例还是开发实例。

在极狐GitLab 18.1 及更高版本中，`Unique instance` ID 字段也可用于识别客户的极狐GitLab 私有化部署实例。

<!-- markdownlint-enable MD013 -->

<a id="ability-to-have-some-instances-using-cloud-licensing-and-others-air-gapped-or-offline"></a>

### 部分实例使用云许可证，其他实例处于物理隔离或离线状态的能力

如果客户的任何实例需要旧版或离线许可证文件，客户需要请求[云许可证退出](https://docs.google.com/presentation/d/1gbdHGCLTc0yis0VFyBBZkriMomNo8audr0u8XXTY2iI/edit#slide=id.g137e73c15b5_0_298)，并在报价期间获得 VP 批准。
这将向客户提供相关的许可证文件，同时也提供客户可应用于符合云许可证条件实例的激活码。在这种情况下，极狐GitLab 仅会收到云许可证实例的席位计数数据，并将其用于计算超额使用。

<a id="scenarios-when-one-or-more-of-the-instances-are-a-dev-environment"></a>

### 当一个或多个实例是开发环境时的场景

客户可以将其生产许可证密钥或激活码应用于开发环境。同样的用户限制将适用。

<a id="using-a-single-subscription-for-a-jihulabcom-and-gitlab-self-managed-instance"></a>

### 针对 JihuLab.com 和 极狐GitLab 私有化部署实例使用单个订阅

如果客户希望拥有 JihuLab.com 和 极狐GitLab 私有化部署实例，客户需要为每个实例购买单独的订阅。

<a id="example-scenarios"></a>

### 场景示例

以下场景反映了客户可能提出的与多个实例相关的问题。

<a id="example-1"></a>

#### 示例 1

- 问：我想购买一个总数为 50 个用户的许可证，但想将这些用户拆分到两个实例上。我可以这样做吗？
- 答：可以，前提是用于两个极狐GitLab 私有化部署实例，你可以将一个云许可证激活码（或许可证密钥）应用于多个极狐GitLab 私有化部署实例，
  条件是这些实例上的用户相同，或者是总用户的子集。在这种情况下，因为有 50 个总用户或唯一用户，你可以将这些用户拆分为两个子集实例。

<a id="example-2"></a>

#### 示例 2

- 问：我有 2 个不同的群组，分别为 20 个用户和 30 个用户，每个都需要自己的实例。我可以购买一份 30 个用户的订阅吗？
- 答：不可以。在这种情况下，客户应购买两份独立的订阅，分别为 20 个席位和 30 个席位，以便每个实例的超额使用可以单独管理。
  第二个选择是，客户购买一份 50 个用户的订阅，并将其应用于两个实例。

<a id="example-3"></a>

#### 示例 3

- 问：我有 30 个用户需要一个免费的 JihuLab.com 实例。我可以为所有 30 个用户激活一个免费的 JihuLab.com 实例吗？
- 答：不可以。JihuLab.com 的基础版每个客户总计最多五个用户。请联系您的客户代表以开始试用或评估期。

<a id="example-4"></a>

#### 示例 4

- 问：我在印度购买了 100 个许可证，但只需要部署 75 个。我可以将剩余的 25 个许可证部署给在美国加利福尼亚的团队吗？
- 答：不可以。加利福尼亚在印度的地理区域之外，因此你无法以这种方式部署剩余的 25 个许可证。

<a id="example-5"></a>

#### 示例 5

- 问：我有一个包含五个用户的旗舰版实例和一个包含 100 个用户的专业版实例。我可以在专业版实例中开发的代码上利用旗舰版的功能吗？
- 答：不可以。这是一种禁止的功能混用。