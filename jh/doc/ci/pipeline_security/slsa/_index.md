---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件制品供应链级别（SLSA）
---

[软件制品供应链级别（SLSA）](https://slsa.dev/)，读作“salsa”，是一套可逐步采用的供应链安全指南，由行业共识确立。该标准围绕制品生产者、验证者、使用者和基础设施提供商来定义。

极狐GitLab 作为基础设施提供商，为用户提供工具，以便安全地生成与容器和制品相关的元数据。此外，极狐GitLab 还提供相应机制，用于验证并安全地使用这些元数据，从而强化供应链并防范某些类型的攻击。

<a id="slsa-levels"></a>

## SLSA 级别

极狐GitLab 可以生成符合 SLSA 规范不同级别的来源证明。达到特定级别需要依据特定标准进行自我评估。

更多信息，请参见 SLSA [构建：跟踪基础](https://slsa.dev/spec/v1.2/build-track-basics)页面。

<a id="level-1-provenance-showing-how-the-package-was-built"></a>

### 级别 1：展示软件包如何构建的来源证明

SLSA 级别 1 要求自动生成来源证明，描述制品是如何构建的，包括：

- 构建该软件包的实体。
- 使用了什么构建过程。
- 构建的顶层输入是什么。

<a id="level-2-signed-provenance-generated-by-a-hosted-build-platform"></a>

### 级别 2：由托管构建平台生成的已签名来源证明

SLSA 级别 2 与级别 1 的要求相同，但额外要求托管构建平台对生成的来源证明进行签名。签名可以由以下方式完成：

- 原始构建。
- 事后可复现的构建。
- 某种确保来源证明可信的等效系统。

极狐GitLab 提供符合 SLSA 级别 2 的来源声明，可[为极狐GitLab Runner 生成的所有构建产物自动生成](../../runners/configure_runners.md#artifact-provenance-metadata)。该来源声明也符合级别 1，并且由 Runner 自身生成。

在此级别实施 SLSA 有很多好处，包括：

- 帮助组织建立软件和构建平台清单。
- 通过数字签名防止篡改。
- 将攻击面缩小到特定的构建平台。

<a id="sign-and-verify-slsa-provenance-with-a-cicd-component"></a>

#### 使用 CI/CD 组件对 SLSA 来源证明进行签名和验证

[GitLab SLSA CI/CD 组件](https://gitlab.com/explore/catalog/components/slsa)
提供以下配置：

- 对 Runner 生成的来源声明进行签名。
- 为作业产物生成[验证摘要证明（VSA）](https://slsa.dev/spec/v1.0/verification_summary)。

更多信息和示例配置，请参见 [SLSA 组件文档](https://gitlab.com/components/slsa#slsa-supply-chain-levels-for-software-artifacts)。

<a id="level-3-hardened-build-platform"></a>

### 级别 3：强化的构建平台

SLSA 级别 3 实现了级别 1 和级别 2 的所有要求，并且还能防止对来源证明的篡改，例如防止已攻陷构建过程本身的攻击者进行篡改。

这种更强的防篡改能力来自：

- 更高的 Runner 隔离性。
- 确保运行用户自定义构建步骤的环境无法访问密钥材料。
- 确保来源证明中的每个字段都由构建平台在可信控制平面中生成或验证。

更多信息，请参见 [SLSA 级别 3 页面](level_3/_index.md)和 [SLSA 来源证明规范](level_3/provenance_v1.md)。
