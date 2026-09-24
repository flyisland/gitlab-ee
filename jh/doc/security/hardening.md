---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 加固建议
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档适用于那些希望对整体系统进行“加固”，以抵御常见甚至非常见攻击的极狐GitLab 实例。它并非旨在完全消除攻击，而是提供强大的缓解措施，从而降低整体风险。部分技术适用于任何极狐GitLab 部署，例如 JihuLab.com 或私有化部署，而其他技术则适用于底层操作系统。

这些技术仍在开发中，尚未经过大规模测试（例如拥有众多用户的大型环境）。它们已在运行 Linux 软件包安装的私有化部署单实例上进行了测试，虽然许多技术可迁移至其他部署类型，但它们可能并非全部适用或有效。

列出的建议大多根据通用文档提供了具体建议或参考选项。加固可能会影响您的用户特别需要或依赖的某些功能，因此您应与用户进行沟通，并分阶段推出加固更改。

为便于理解，加固说明分为五个类别，如下节所述。

<a id="gitlab-hardening-general-concepts"></a>

## 极狐GitLab 加固通用概念

详细介绍了将加固作为一种安全方法的信息以及一些更宏观的理念。更多信息，请参见[加固通用概念](hardening_general_concepts.md)。

<a id="gitlab-application-settings"></a>

## 极狐GitLab 应用程序设置

通过极狐GitLab GUI 对应用程序本身进行的应用程序设置。更多信息，请参见[应用程序建议](hardening_application_recommendations.md)。

<a id="gitlab-cicd-settings"></a>

## 极狐GitLab CI/CD 设置

CI/CD 是极狐GitLab 的核心组件，虽然安全原则的应用基于需求，但您可以采取多种措施来使您的 CI/CD 更加安全。更多信息，请参见[CI/CD 建议](hardening_cicd_recommendations.md)。

<a id="gitlab-configuration-settings"></a>

## 极狐GitLab 配置设置

用于控制和配置应用程序的配置文件设置（例如 `gitlab.rb`）将单独说明。更多信息，请参见[配置建议](hardening_configuration_recommendations.md)。

<a id="operating-system-settings"></a>

## 操作系统设置

您可以调整底层操作系统以提高整体安全性。更多信息，请参见[操作系统建议](hardening_operating_system_recommendations.md)。

<a id="nist-800-53-compliance"></a>

## NIST 800-53 合规

您可以配置私有化部署的极狐GitLab 以强制执行 NIST 800-53 安全标准的合规性。
