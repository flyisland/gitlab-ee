---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理员合规功能
description: Compliance center, audit events, security policies, and compliance frameworks.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 管理员合规功能可确保您的极狐GitLab 实例满足常见的合规标准。许多功能也适用于群组和项目。

<a id="compliant-workflow-automation"></a>

## 合规工作流自动化

对于合规团队来说，重要的是确信其控制措施和要求已正确设置，并且保持正确设置。一种方法是定期手动检查设置，但这容易出错且耗时。更好的方法是通过单一可信来源设置和自动化来确保合规团队配置的任何内容都能保持配置正确且正常运行。这些功能可帮助您自动化合规：

| 功能 | 实例 | 群组 | 项目 | 描述 |
|:----------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------|:-------------------------------------|:--------------------------------------|:------------|
| [合并请求批准策略批准设置](../../user/application_security/policies/merge_request_approval_policies.md#approval_settings) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 强制执行合并请求批准策略，要求多个批准人，并覆盖极狐GitLab 实例或群组中所有强制实施的群组或项目的多种项目设置。 |

<a id="audit-management"></a>

## 审计管理

任何合规计划的一个重要部分都是能够追溯并了解发生了什么、何时发生以及谁负责。您可以在审计情况下使用此功能，也可以在问题发生时了解其根本原因。

同时拥有低级别的原始审计数据列表和高级别的汇总审计数据列表很有帮助。在这两者之间，合规团队可以快速识别是否存在问题，然后深入了解这些问题的细节。这些功能有助于提高极狐GitLab 的可见性并审计正在发生的情况：

| 功能 | 实例 | 群组 | 项目 | 描述 |
|:---------------------------------------------------------|:-------------------------------------|:-------------------------------------|:-------------------------------------|:------------|
| [审计事件](audit_event_reports.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 为维护代码完整性，审计事件使管理员能够在高级审计事件系统中查看在极狐GitLab 服务器中进行的任何修改，以便您可以控制、分析和跟踪每一个更改。 |
| [审计报告](audit_event_reports.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 根据已发生的审计事件创建和访问报告。使用预构建的极狐GitLab 报告或 API 构建您自己的报告。 |
| [审计事件流](audit_event_streaming.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 将极狐GitLab 审计事件流式传输到 HTTP 端点或第三方服务，例如 AWS S3 或 GCP 日志记录。 |
| [审计员用户](../auditor_users.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 审计员用户是对极狐GitLab 实例上的所有项目、群组和其他资源具有只读访问权限的用户。 |

<a id="policy-management"></a>

## 策略管理

由于组织标准或监管机构的强制要求，组织具有独特的策略要求。以下功能可帮助您定义规则和策略，以遵守工作流程要求、职责分离和安全供应链最佳实践：

| 功能 | 实例 | 群组 | 项目 | 描述 |
|:------------------------------------------------------------------------------|:-------------------------------------|:-------------------------------------|:-------------------------------------|:------------|
| [凭据清单](../credentials_inventory.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 跟踪极狐GitLab 实例中所有用户使用的凭据。 |
| [精细用户角色<br/>和灵活权限](../../user/permissions.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 使用五种不同的用户角色和外部用户设置来管理访问和权限。根据人员的角色设置权限，而不仅仅是对仓库的读取或写入访问权限。不要与只需要访问议题跟踪器的人员共享源代码。 |
| [合并请求批准](../../user/project/merge_requests/approvals/_index.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 配置合并请求所需的批准。 |
| [推送规则](../../user/project/repository/push_rules.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 控制对仓库的推送。 |
| [安全策略](../../user/application_security/policies/_index.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | {{< icon name="check-circle" >}} 是 | 配置可自定义的策略，要求根据策略规则进行合并请求批准，或强制安全扫描器在项目流水线中执行以满足合规要求。策略可以针对特定项目精细执行，也可以针对群组或子群组中的所有项目执行。 |

<a id="other-compliance-features"></a>

## 其他合规功能

这些功能也可以帮助满足合规要求：

| 功能 | 实例 | 群组 | 项目 | 描述 |
|:--------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------|:-------------------------------------|:-------------------------------------|:------------|
| [向项目、群组或整个服务器的<br/>所有用户发送电子邮件](../email_from_gitlab.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 根据项目或群组成员身份向用户组发送电子邮件，或向使用极狐GitLab 实例的所有人发送电子邮件。这些电子邮件非常适合计划内维护或升级。 |
| [强制接受服务条款](../settings/terms.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 通过阻止极狐GitLab 流量来强制用户接受新的服务条款。 |
| [生成用户权限级别报告](../admin_area.md#user-permission-export) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 生成列出实例中所有用户对群组和项目的访问权限的报告。 |
| [LDAP 群组同步](../auth/ldap/ldap_synchronization.md#group-sync) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 自动同步群组并管理 SSH 密钥、权限和身份验证，让您可以专注于构建产品，而不是配置工具。 |
| [LDAP 群组同步过滤器](../auth/ldap/ldap_synchronization.md#group-sync) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 更灵活地基于过滤器与 LDAP 同步，这意味着您可以利用 LDAP 属性映射极狐GitLab 权限。 |
| [Linux 软件包安装支持<br/>日志转发](https://gitlab.cn/docs/omnibus/settings/logs/#udp-log-forwarding) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 将日志转发到中央系统。 |
| [限制 SSH 密钥](../../security/ssh_keys_restrictions.md) | {{< icon name="check-circle" >}} 是 | {{< icon name="dotted-circle" >}} 否 | {{< icon name="dotted-circle" >}} 否 | 控制用于访问极狐GitLab 的 SSH 密钥的技术和密钥长度。 |