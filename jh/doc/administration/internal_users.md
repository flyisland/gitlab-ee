---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 内部用户
description: 通过内部机器人用户为极狐GitLab 功能启用自动化系统操作。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

内部用户（也称为“机器人”）是极狐GitLab 自动创建的系统账号，用于执行特定的后台操作。当常规用户账号不适用时，例如生成告警或自动评审反馈时，极狐GitLab 会使用这些账号。内部用户拥有用户名和电子邮件地址，因此其操作可以归属到它们名下。它们不计入许可证限制，也无法手动创建。机器人在用户列表中会显示徽章。

内部用户的访问权限有限，无法直接用于身份验证等许多操作。部分机器人有权发起 API 请求，但大多数机器人不能。

内部用户有时会作为功能开发的一部分被创建。例如，GitLab Migration Bot 用于从极狐GitLab 代码片段[迁移](https://gitlab.com/gitlab-org/gitlab/-/issues/216120)到[版本化代码片段](../user/snippets.md#versioned-snippets)。当原始作者不可用时，该机器人会被指定为代码片段的作者。

内部用户的其他示例：

- [GitLab Automation Bot](../user/group/iterations/_index.md#gitlab-automation-bot-user)
- [GitLab Security Bot](#gitlab-security-bot)
- [GitLab Security Policy Bot](#gitlab-security-policy-bot)
- [Alert Bot](../operations/incident_management/alerts.md#trigger-actions-from-alerts)
- [Ghost User](../user/profile/account/delete_account.md#associated-records)
- [Support Bot](../user/project/service_desk/configure.md#support-bot-user)
- 导入期间创建的 [Placeholder User](../user/import/mapping/post_migration_mapping.md#placeholder-users)
- Visual Review Bot
- 资源访问令牌，包括[项目访问令牌](../user/project/settings/project_access_tokens.md)
  和[群组访问令牌](../user/group/settings/group_access_tokens.md)，它们是
  `project_{project_id}_bot_{random_string}` 和 `group_{group_id}_bot_{random_string}` 用户，拥有 `PersonalAccessToken`。

<a id="gitlab-admin-bot"></a>

## GitLab Admin Bot

[GitLab Admin Bot](https://gitlab.com/gitlab-org/gitlab/-/blob/1d38cfdbed081f8b3fa14b69dd743440fe85081b/lib/users/internal.rb#L104)
是一个内部用户，常规用户无法访问或修改它，它负责许多任务，包括：

- 为项目应用[默认合规框架](../user/compliance/compliance_frameworks/_index.md#default-compliance-frameworks)。
- [自动停用休眠用户](moderate_users.md#automatically-deactivate-dormant-users)。
- [自动删除未确认用户](moderate_users.md#automatically-delete-unconfirmed-users)。
- [删除休眠项目](dormant_project_deletion.md)。
- [锁定用户](../security/unlock_user.md)。

<a id="gitlab-security-bot"></a>

## GitLab Security Bot

GitLab Security Bot 是一个内部用户，负责对违反[安全策略](../user/application_security/policies/_index.md)的合并请求发表评论。

<a id="gitlab-security-policy-bot"></a>

## GitLab Security Policy Bot

GitLab Security Policy Bot 是一个内部用户，负责触发[安全策略](../user/application_security/policies/_index.md#gitlab-security-policy-bot-user)中定义的定时流水线。每个强制执行安全策略的项目都会创建此账号。

对于定时流水线执行策略，当项目所有者明确允许访问时，该机器人可以从私有项目读取 CI/CD 配置。

在极狐GitLab 19.1 及更高版本中，作为定时流水线执行策略的一部分，该机器人可以访问 API 来执行操作，例如从更早的流水线阶段下载产物。为限制 API 访问的风险，该机器人只能访问其所在项目中由其角色允许的端点。

机器人访问具有以下限制：

- 目标项目必须启用 **Security policy bot access**。
- 请求的文件路径必须匹配项目允许的文件模式。
- 机器人项目必须位于允许的群组层级中。如果未配置群组，极狐GitLab 会使用根祖先群组。

要为 Security Policy Bot 设置访问权限，请参阅
[定时流水线执行策略](../user/application_security/policies/scheduled_pipeline_execution_policies.md#option-2-allow-access-to-private-or-internal-projects)。
