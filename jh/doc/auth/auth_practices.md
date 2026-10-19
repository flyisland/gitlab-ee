---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 认证和授权最佳实践
description: Security recommendations and best practices for authentication, authorization, and access management.
---

遵循这些安全最佳实践来保护您的极狐GitLab 实例并维护适当的访问控制。这些建议有助于您在维护安全访问的同时，不限制整个组织的生产力。

<a id="security-principles"></a>

## 安全原则

建立构成访问控制策略基础的基本安全原则。

<a id="principle-of-least-privilege"></a>

### 最小权限原则

此原则通过限制来自受损账户或内部威胁的潜在损害来降低安全风险。

- 授予用户完成工作所需的最小权限。
- 在顶级群组中分配最小角色（最小访问权限或访客），然后仅在需要的特定子群组和项目中授予更高权限。
- 通过实施限制对敏感设置访问的自定义角色，尽量减少所有者和维护者的数量。
- 创建令牌时，使用尽可能最受限的范围，或为特定目的创建具有不同范围的多个令牌。

<a id="hierarchical-permission-management"></a>

### 分层权限管理

组织权限以匹配您的组织结构并减少管理开销。

- 尽可能应用群组成员权限而不是项目成员权限，以减少管理开销。
- 为您的组织创建一个顶级群组，以实现集中式访问控制和报告。
- 组织您的群组层次结构以匹配组织结构，并明确所有权边界。

<a id="defense-in-depth"></a>

### 纵深防御

层叠多个安全控制以防范各种类型的攻击和失败。如果一个控制失败，其他控制提供备份保护。

- 为关键应用程序设置[受保护分支](../user/project/repository/branches/protected.md)以防止未经授权的更改。
- 配置[受保护环境](../ci/environments/protected_environments.md)将部署限制为特定角色或用户。
- 使用[受保护容器](../user/packages/container_registry/container_repository_protection_rules.md)为敏感产物增加额外安全。

<a id="authentication-and-credentials"></a>

## 认证和凭证

实施强身份验证方法以防止对您的极狐GitLab 实例的未经授权的访问。

<a id="password-security"></a>

### 密码安全

尽管存在局限性，密码仍是一种主要的身份验证方法。强密码策略通过要求符合组织安全标准的强密码，降低了基于凭证的攻击风险。

- 配置适合您组织的[密码复杂性要求](../administration/settings/sign_up_restrictions.md#modify-password-complexity-requirements)。
- 启用[泄露密码检测](../user/profile/user_passwords.md)以防止使用已知泄露的密码。

<a id="two-factor-authentication"></a>

### 双因素认证

双因素认证（2FA）通过要求第二种验证形式显著提高安全性。即便密码被泄露，2FA 也能防止未经授权的访问。

- 要求所有用户，尤其是具有提升权限的用户，使用[双因素认证](../user/profile/account/two_factor_authentication.md)。
- 提供清晰的文档和 2FA 设置支持，以确保用户采用。
- 实施备份恢复方法以防止账户被锁定。

<a id="token-based-authentication"></a>

### 基于令牌的认证

令牌提供对极狐GitLab 资源的安全、编程式访问。不同的令牌类型用于不同目的，并具有不同的安全影响。

- 定期轮换[个人访问令牌](../user/profile/personal_access_tokens.md)，并在过期前进行。
- 对于自动化流程，使用[群组访问令牌](../user/group/settings/group_access_tokens.md)和[项目访问令牌](../user/project/settings/project_access_tokens.md)代替个人令牌。
- 安全地存储令牌，切勿将其提交到仓库。

<a id="ssh-key-authentication"></a>

### SSH 密钥认证

SSH 密钥提供对 Git 仓库的安全、无密码访问。适当的密钥管理对于维护安全至关重要。

- 使用强 SSH 密钥算法（至少 RSA 2048 位或 Ed25519）。
- 配置 [SSH 密钥限制](../security/ssh_keys_restrictions.md)以强制执行安全标准。
- 定期审计和轮换 SSH 密钥，尤其是对于服务账户。

<a id="access-management"></a>

## 访问管理

控制谁可以访问哪些资源，并持续监控这些权限。有效的访问管理在安全要求与运营效率之间取得平衡。

<a id="user-type-management"></a>

### 用户类型管理

不同的用户类型根据其与组织的关系和安全要求需要不同的访问级别。正确分类用户有助于强制实施适当的访问边界。

- 将承包商和第三方指定为[外部用户](../administration/external_users.md)，以自动限制他们对内部项目的可见性。
- 为需要与仓库进行有限交互的外部协作者分配访客角色。
- 对于需要在整个实例上只读访问的合规和安全人员，使用[审计员用户](../administration/auditor_users.md)。

<a id="regular-access-reviews"></a>

### 定期访问审查

定期访问审查确保随着角色和职责的变化，用户权限保持适当。定期审查有助于在不当访问成为安全风险之前识别并纠正。

- 进行定期访问审查以验证用户权限，并立即解决差异。
- 使用[用户导出](../administration/admin_area.md#user-permission-export)和[群组导出](../user/group/manage.md#export-members-as-csv)功能生成全面的访问报告。
- 当用户离开组织或变更角色时，立即删除访问权限。

<a id="access-monitoring-and-auditing"></a>

### 访问监控和审计

持续监控访问模式和权限更改有助于检测安全事件并保持合规性。审计跟踪提供了谁在何时访问了哪些资源的可见性。

- 配置[审计事件流](../administration/compliance/audit_event_streaming.md)到 SIEM 工具进行实时安全监控。
- 定期审查[凭证清单](../administration/credentials_inventory.md)，以识别未使用或权限过高的令牌。
- 监控未经授权的访问更改或权限升级。

<a id="organizational-scaling"></a>

## 组织扩展

不同的组织规模和结构需要不同的权限管理方法。随着您的成长，调整您的访问控制实践以保持安全。

<a id="foundation-level-1-50-users"></a>

### 基础级别（1-50 名用户）

专注于建立良好的基础，而不使用可能妨碍生产力的复杂流程。

- 从默认角色开始，在群组级别而非每个项目级别分配权限。
- 记录您的权限决策和理由以供将来参考。
- 培训您的核心团队了解极狐GitLab 权限模型和安全实践。
- 建立群组级别的 CI/CD 配置以强制执行一致的安全实践。

<a id="growth-level-50-200-users"></a>

### 增长级别（50-200 名用户）

平衡安全要求与可扩展流程的需求。

- 将 [LDAP](../user/group/access_and_permissions.md#manage-group-memberships-with-ldap) 或 [SAML](../user/group/saml_sso/group_sync.md) 与用户群组集成，以简化管理。
- 为共享资源和敏感资源创建单独的子群组以控制访问。
- 为团队成员制定正式的入职和离职流程。
- 尽量减少深层嵌套的群组结构（大多数组织限制在 4-5 级）。

<a id="enterprise-level-200-users"></a>

### 企业级别（200+ 名用户）

实施企业级控制和治理流程。

- 开发[自定义角色](../user/custom_roles/_index.md)以满足独特的访问需求，同时减少高权限用户的数量。
- 使用极狐GitLab API 自动化批量访问操作，以减少手动配置开销。
- 建立权限变更的治理流程，以防止业务中断。
- 为特权角色实施基于时间的访问，并为职责分离实施合规框架。

<a id="repository-and-cicd-security"></a>

## 仓库和 CI/CD 安全

保护您的代码、部署和自动化流程免受未经授权的更改和访问。这些控制确保您的软件开发和交付流水线的完整性。

<a id="pipeline-security"></a>

### 流水线安全

CI/CD 流水线通常具有较高的权限来部署应用程序和访问敏感资源。保护流水线执行可防止未经授权的操作并保护您的部署流程。

- 使用[作业权限](../ci/jobs/fine_grained_permissions.md)来控制流水线执行期间可访问哪些资源。
- 为关键部署阶段配置[审批关卡](../ci/environments/deployment_approvals.md)。
- 使用特定于环境的 runner 或 runner 标签来隔离部署，并限制对敏感生产资源的访问。

<a id="repository-protection"></a>

### 仓库保护

源代码仓库包含组织的知识产权，需要保护免受未经授权的更改。仓库安全控制确保代码完整性并防止恶意修改。

- 实施[推送规则](../user/project/repository/push_rules.md)以强制执行提交标准并防止敏感数据泄露。
- 通过审批规则要求在将更改合并到受保护分支之前进行[代码审查](../user/project/merge_requests/approvals/rules.md)。
- 使用[签名提交](../user/project/repository/signed_commits/_index.md)提供提交真实性的加密验证。

<a id="api-and-automation-security"></a>

### API 和自动化安全

自动化流程和 API 集成通常使用具有广泛访问权限的长期凭证。这些非人类访问模式需要特殊的安全考虑，以防止凭证滥用。

- 使用具有有限权限的服务账户用于自动化流程，而不是个人令牌。
- 定期轮换自动化流程和 CI/CD 流水线中使用的凭证。
- 监控自动化访问模式，以发现异常行为或权限提升尝试。
- 为 API 访问创建令牌时，使用尽可能具体的范围。
- 为 API 集成实施错误处理和日志记录。
- 对 API 请求进行速率限制，以防止滥用并确保系统稳定性。