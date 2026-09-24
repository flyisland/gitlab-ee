---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 内部用户
description: Enable automated system operations through internal bot users for 极狐GitLab functionality.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.4 中引入，机器人在用户列表中带有徽章标识。

{{< /history >}}

极狐GitLab 使用内部用户（有时称为“机器人”）来执行无法归因于普通用户的操作或功能。

内部用户：

- 由极狐GitLab 自动创建，不计入许可证限制。无法手动创建内部用户。
- 在传统用户账户不适用时使用。例如，生成警报或自动审核反馈时。
- 访问权限有限，目的非常具体。不能用于常规用户操作，如身份验证或 API 请求。
- 拥有可归因于其所执行任何操作的电子邮件地址和名称。

内部用户有时作为功能开发的一部分创建。例如，GitLab Migration Bot 用于从极狐GitLab 代码片段迁移到版本化代码片段。当代码片段的原始作者不可用时（例如用户被禁用时），GitLab Migration Bot 被用作代码片段的作者。

其他内部用户示例：

- [极狐GitLab 自动化机器人](../user/group/iterations/_index.md#gitlab-automation-bot-user)
- [极狐GitLab 安全机器人](#gitlab-security-bot)
- [极狐GitLab 安全策略机器人](#gitlab-security-policy-bot)
- [警报机器人](../operations/incident_management/alerts.md#trigger-actions-from-alerts)
- [幽灵用户](../user/profile/account/delete_account.md#associated-records)
- [支持机器人](../user/project/service_desk/configure.md#support-bot-user)
- 导入期间创建的[占位用户](../user/import/mapping/post_migration_mapping.md#placeholder-users)
- 可视化审查机器人
- 资源访问令牌，包括[项目访问令牌](../user/project/settings/project_access_tokens.md)和[群组访问令牌](../user/group/settings/group_access_tokens.md)，它们是 `project_{project_id}_bot_{random_string}` 和 `group_{group_id}_bot_{random_string}` 用户，带有 `PersonalAccessToken`。

<a id="gitlab-admin-bot"></a>

## GitLab 管理员机器人

极狐GitLab 管理员机器人是一个内部用户，无法被普通用户访问或修改，负责许多任务，包括：

- 向项目应用[默认合规框架](../user/compliance/compliance_frameworks/_index.md#default-compliance-frameworks)。
- [自动停用休眠用户](moderate_users.md#automatically-deactivate-dormant-users)。
- [自动删除未确认用户](moderate_users.md#automatically-delete-unconfirmed-users)。
- [删除休眠项目](dormant_project_deletion.md)。
- [锁定用户](../security/unlock_user.md)。

<a id="gitlab-security-bot"></a>

## GitLab 安全机器人

极狐GitLab 安全机器人是一个内部用户，负责对违反[安全策略](../user/application_security/policies/_index.md)的合并请求进行评论。

<a id="gitlab-security-policy-bot"></a>

## GitLab 安全策略机器人

极狐GitLab 安全策略机器人是一个内部用户，负责触发[安全策略](../user/application_security/policies/_index.md#gitlab-security-policy-bot-user)中定义的定时流水线。该账户会在每个强制执行安全策略的项目中创建。

对于定时流水线执行策略，当项目所有者明确允许访问时，该机器人可以从私有项目读取 CI/CD 配置。

机器人访问有以下限制：

- 目标项目必须启用 **安全策略机器人访问**。
- 请求的文件路径必须匹配项目允许的文件模式。
- 机器人项目必须位于允许的群组层次结构中。如果未配置群组，极狐GitLab 使用根祖先群组。

要设置安全策略机器人访问，请参见[定时流水线执行策略](../user/application_security/policies/scheduled_pipeline_execution_policies.md#option-2-allow-security-policy-bot-access-to-private-projects)。