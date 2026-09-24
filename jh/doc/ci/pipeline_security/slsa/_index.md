---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件制品的供应链级别（SLSA）
---

[软件制品的供应链级别（SLSA）](https://slsa.dev/)，发音为“salsa”，是一套由行业共识建立的、可逐步采用的供应链安全指南。该标准从制品生产者、验证者、消费者和基础设施提供者的角度定义。

极狐GitLab 作为基础设施提供者，为用户提供工具，以安全地生成与容器和制品相关的元数据。此外，极狐GitLab 还提供验证和安全使用这些元数据的机制，以加固供应链并防止某些类型的攻击。

<a id="slsa-levels"></a>

## SLSA 级别

极狐GitLab 可以生成符合不同级别 SLSA 规范的来源证明。要达到特定级别需要根据具体标准进行自我评估。

更多信息，请参阅 SLSA [构建：基础追踪](https://slsa.dev/spec/v1.2/build-track-basics) 页面。

<a id="level-1-provenance-showing-how-the-package-was-built"></a>

### 级别 1：显示软件包构建方式的来源证明

SLSA 级别 1 要求自动生成的来源证明，描述制品是如何构建的，包括：

- 哪个实体构建了该软件包。
- 使用了什么构建过程。
- 构建的顶级输入是什么。

<a id="level-2-signed-provenance-generated-by-a-hosted-build-platform"></a>

### 级别 2：由托管构建平台生成的签名来源证明

SLSA 级别 2 具有与级别 1 相同的要求，但额外要求托管构建平台对生成的来源证明进行签名。签名可以通过以下方式进行：

- 原始构建。
- 事后可重现构建。
- 某些等效系统，确保来源证明的可信性。

极狐GitLab 提供符合 SLSA 级别 2 的来源声明，该声明可以[为极狐GitLab Runner 生成的所有构建产物自动生成](../../runners/configure_runners.md#artifact-provenance-metadata)。该来源声明也符合级别 1，由 runner 自身生成。

在此级别实现 SLSA 有很多好处，包括：

- 帮助组织创建软件和构建平台的清单。
- 通过数字签名防止篡改。
- 将攻击面缩小到特定的构建平台。

<a id="sign-and-verify-slsa-provenance-with-a-ci-cd-component"></a>

#### 使用 CI/CD 组件签名和验证 SLSA 来源证明

[极狐GitLab SLSA CI/CD 组件](https://jihulab.com/explore/catalog/components/slsa) 为以下操作提供配置：

- 签名 runner 生成的来源声明。
- 为作业产物生成[验证摘要证明（VSA）](https://slsa.dev/spec/v1.0/verification_summary)。

更多信息和示例配置，请参阅 [SLSA 组件文档](https://jihulab.com/components/slsa#slsa-supply-chain-levels-for-software-artifacts)。

<a id="level-3-hardened-build-platform"></a>

### 级别 3：加固的构建平台

SLSA 级别 3 实现了级别 1 和级别 2 的所有要求，并且还防止来源证明被篡改。例如，防止攻破构建过程本身的攻击者进行篡改。

这种增强的抗篡改能力来自：

- 增强的 runner 隔离。
- 确保密钥材料不能被运行用户自定义构建步骤的环境访问。
- 确保来源证明中的每个字段都由构建平台在可信控制平面中生成或验证。

更多信息，请参阅 [SLSA 级别 3 页面](level_3/_index.md) 和 [SLSA 来源规范](level_3/provenance_v1.md)。