---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户许可证的可接受使用
---

<a id="user-licenses-and-affiliates"></a>

## 用户许可证与关联公司

<a id="affiliated-companies-ability-to-separately-purchase-user-licenses-under-one-master-agreement"></a>

### 关联公司在同一主协议下单独购买用户许可证的能力

关联公司可以各自根据极狐GitLab 与特定公司之间适用交易文档的条款，在同一主协议下直接向极狐GitLab 购买用户许可证。

客户也可以购买用户许可证并将这些许可证部署到关联公司，但须满足以下要求。

<a id="customers-ability-to-purchase-user-licenses-and-deploy-those-licenses-to-an-affiliated-company"></a>

### 客户购买用户许可证并将这些许可证部署到关联公司的能力

除某些例外情况外，客户可以购买用户许可证并将这些许可证部署到关联实体。极狐GitLab 可以满足关联公司的内部采购要求和计费政策，前提是这些要求在购买之前和计费之前已明确告知。

极狐GitLab 是一家全球性公司，可能采用特定区域的定价。如果客户希望在客户购买许可证所在地理区域（定义见下文）之外部署用户许可证，包括部署到关联公司，极狐GitLab 可能要求客户或关联公司接受其他定价和条件。

<a id="distinct-geographical-region-definition"></a>

### 特定地理区域：定义

“地理区域”定义为极狐GitLab 提供的报价中所列“Sold To”地址周围 4,000 英里（即 6,437 公里）范围内。除非经极狐GitLab 书面批准，严禁在地理区域之外使用、访问或分发这些许可证。

<a id="use-of-multiple-tiers"></a>

## 多版本的使用

极狐GitLab 提供三个版本的软件：(1) 基础版，(2) 专业版，以及 (3) 旗舰版。请参见 <https://about.gitlab.com/pricing/feature-comparison/>。

客户可以使用多个版本的软件，但须遵守本节“多版本的使用”以及下文“多实例的使用”中的要求。

<a id="customers-ability-use-different-tiers-of-gitlab-software"></a>

### 客户使用不同版本极狐GitLab 软件的能力

除某些例外情况外，客户可以使用不同版本的极狐GitLab 软件。这需要多个实例（见下文“多实例的使用”）。例如，客户可能有不同的业务部门或关联公司，各自需要极狐GitLab 软件的不同功能。该客户可能希望为一个业务部门部署一个专业版实例，为另一个业务部门部署一个旗舰版实例。

客户应确保此类多实例的使用保持相互独立和区分，以避免被禁止的功能混用，详见本节下文。

<!-- markdownlint-disable MD013 -->

<a id="customers-or-a-customers-business-unit-or-affiliates-ability-to-use-features-from-its-premium-or-ultimate-instance-with-code-developed-in-a-free-instance"></a>

### 客户（或客户的业务部门或关联公司）将专业版（或旗舰版）实例的功能与基础版实例中开发的代码结合使用的能力

这属于被禁止的功能混用。虽然客户有时可能合理地需要多个不同版本的极狐GitLab 软件实例，但客户仅限于使用相关实例特定版本的功能。在这种情况下，虽然客户可能合理地需要基础版和专业版（或旗舰版）实例，但禁止该客户将专业版（或旗舰版）实例中的功能用于基础版实例中开发的代码。

<!-- markdownlint-enable MD013 -->

<a id="customers-ability-to-use-features-from-an-ultimate-instance-with-code-developed-in-a-premium-instance"></a>

### 客户将旗舰版实例中的功能用于专业版实例中开发的代码的能力

这属于被禁止的功能混用。虽然客户有时可能合理地需要多个实例和不同版本的极狐GitLab 软件，但客户仅限于使用相关实例特定版本的功能。在这种情况下，虽然客户可能合理地需要专业版和旗舰版实例，但禁止该客户将旗舰版实例中的功能（如安全扫描）用于专业版实例中开发的代码。

<a id="use-of-multiple-instances"></a>

## 多实例的使用

<a id="customers-ability-to-have-multiple-instances"></a>

### 客户拥有多个实例的能力

一些客户可能希望为不同的团队、子公司等设置多个相互独立的极狐GitLab 实例。有时，客户可能希望拥有多个极狐GitLab 实例，且每个实例上的用户相同。根据其具体使用场景，这可能需要一个或多个订阅才能满足。多实例的使用还须遵守上文关于多版本使用的限制。

<a id="customers-ability-to-have-multiple-instances-of-free-tier-gitlabcom-or-self-managed"></a>

### 客户拥有多个基础版实例（JihuLab.com 或私有化部署）的能力

除某些例外情况外，客户可以拥有多个基础版实例。

对于 JihuLab.com 的基础版，[每个客户或实体的私有可见性顶级命名空间最多可有五个用户](../user/free_user_limit.md)。这五个用户上限是所有基础版实例的总和。因此，例如，如果客户有一个包含五个用户的基础版实例，则禁止该客户再激活任何用户级别的额外基础版实例，因为已达到五个用户的上限。

对于极狐GitLab 私有化部署的基础版，没有五个用户的上限。

<a id="customers-ability-to-have-multiple-instances-of-gitlabcom-or-dedicated"></a>

### 客户拥有多个 JihuLab.com 或 Dedicated 实例的能力

客户可以拥有多个 JihuLab.com 或 Dedicated 实例，前提是客户为每个所需实例购买订阅。

<a id="customers-ability-to-have-multiple-instances-of-self-managed-with-the-same-users"></a>

### 客户拥有多个用户相同的私有化部署实例的能力

这在技术上是可行的，但须满足某些条件：

根据客户与极狐GitLab 之间书面协议的条款，一个云许可证激活码（或许可证密钥）可以应用于多个极狐GitLab 私有化部署实例，前提是这些实例上的用户：

- 相同，或
- 是客户已获许可的生产实例用户的子集。

例如，如果客户有一个已获许可的极狐GitLab 生产实例，并且客户还有其他具有相同用户列表的实例，则生产激活码（或许可证密钥）将适用。即使这些用户配置在不同的群组和项目中，只要用户列表相同，激活码（或许可证密钥）就适用。

但是，如果上述任一条件不满足，客户将需要为这些用户单独购买一个实例的额外订阅。

<a id="use-of-multiple-gitlab-self-managed-instances-with-a-single-license-key-or-activation-code"></a>

## 使用单个许可证密钥或激活码管理多个极狐GitLab 私有化部署实例

<a id="validating-when-one-license-or-activation-code-is-applied-to-multiple-instances"></a>

### 验证一个许可证或激活码应用于多个实例的情况

极狐GitLab 要求与其客户签订书面协议，以明确其审计和核实客户遵守本文档条款的权利。

<a id="calculating-billable-users-when-one-license-key-or-activation-code-is-applied-to-multiple-instances"></a>

### 当一个许可证密钥或激活码应用于多个实例时计算计费用户数

当单个许可证文件或激活码应用于多个实例时，极狐GitLab 会检查与该订阅关联的所有实例，以确定**计费用户数最高**的实例。该实例将用于计算诸如 `billable users` 和 `max users` 等值，并将用于季度订阅对账和自动续订（如已启用）。

通过这种方法，极狐GitLab 假设所有其他用户数较低的实例包含该主实例的相同用户或用户子集。

<!-- markdownlint-disable MD013 -->

<a id="visibility-into-latest-usage-data-and-how-to-identify-which-of-the-customers-instances-the-data-is-for"></a>

### 查看最新使用数据，以及如何确定数据属于客户的哪个实例

共享的极狐GitLab 私有化部署使用数据存储在 CustomersDot 中的 `License seat links` 下。对于使用云许可证的客户，数据每天记录一次；对于使用离线许可证的客户，则在其通过电子邮件共享使用数据时记录（每月请求一次）。要查看此数据，客户可以按 `Company` 名称或 `Subscription` 名称搜索。随此数据一起记录的还有 `Hostname` 和 `Instance identifier` ID，这有助于表明数据来自生产实例还是开发实例。

在极狐GitLab 18.1 及更高版本中，还可以使用 `Unique instance` ID 字段来识别客户的极狐GitLab 私有化部署实例。

<!-- markdownlint-enable MD013 -->

<a id="ability-to-have-some-instances-using-cloud-licensing-and-others-air-gapped-or-offline"></a>

### 部分实例使用云许可证，其他实例气隙隔离或离线的能力

如果客户的任何实例需要旧版或离线许可证文件，客户需要在报价期间请求 [云许可证退出](https://docs.google.com/presentation/d/1gbdHGCLTc0yis0VFyBBZkriMomNo8audr0u8XXTY2iI/edit#slide=id.g137e73c15b5_0_298)以供 VP 批准。这将为客户提供相关的许可证文件，同时提供一个激活码，客户可将其应用于符合云许可证条件的实例。在这种情况下，极狐GitLab 将仅收到云许可证实例的席位数量数据，该数据将用于计算超额使用量。

<a id="scenarios-when-one-or-more-of-the-instances-are-a-dev-environment"></a>

### 一个或多个实例为开发环境时的场景

欢迎客户将其生产许可证密钥或激活码应用于开发环境。相同的用户限制将适用。

<a id="using-a-single-subscription-for-a-gitlabcom-dedicated-and-gitlab-self-managed-instance"></a>

### 为 JihuLab.com、Dedicated 和极狐GitLab 私有化部署实例使用单个订阅

如果客户希望拥有 JihuLab.com、Dedicated 和极狐GitLab 私有化部署实例，客户将需要为每个实例购买单独的订阅。

<a id="example-scenarios"></a>

### 示例场景

以下场景反映了客户可能提出的与多实例相关的问题。

<a id="example-1"></a>

#### 示例 1

- 问：我想购买一个总共 50 个用户的许可证，但想将这些用户拆分到两个实例中。我可以这样做吗？
- 答：可以，前提是用于两个极狐GitLab 私有化部署实例，您可以将一个云许可证激活码（或许可证密钥）应用于多个极狐GitLab 私有化部署实例，
  前提是这些实例上的用户相同，或者是总用户数的子集。在这种情况下，由于总共有 50 个或唯一用户，您可以将
  这些用户拆分到两个子集实例中。

<a id="example-2"></a>

#### 示例 2

- 问：我有 2 个不同的群组，分别有 20 个用户和 30 个用户，每个群组都需要自己的实例。我可以购买 30 个用户的订阅吗？
- 答：不可以。在这种情况下，客户应购买两个独立的订阅，分别为 20 个席位和 30 个席位，以便可以分别管理每个实例的超额使用量。
  另一种选择是客户购买一个 50 个用户的单一订阅并将其应用于两个实例。

<a id="example-3"></a>

#### 示例 3

- 问：我有 30 个用户需要一个基础版 JihuLab.com 实例。我可以为所有 30 个用户激活一个基础版 JihuLab.com 实例吗？
- 答：不可以。JihuLab.com 的基础版对每个客户总计最多限制为五个用户。请联系您的客户代表以开始试用或评估期。

<a id="example-5"></a>

#### 示例 5

- 问：我有一个包含五个用户的旗舰版实例和一个包含 100 个用户的专业版实例。我可以在专业版实例中开发的代码上使用旗舰版功能吗？
- 答：不可以。这属于被禁止的功能混用。
