---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 删除用户账号并管理关联记录和贡献。
title: 删除用户
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

用户可以从极狐GitLab 实例中删除，方式有两种：

- 用户自行删除。
- 管理员删除。

> [!note]
> 删除用户会删除该用户命名空间中的所有项目。

<a id="delete-your-own-account"></a>

## 删除您自己的账号

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 在极狐GitLab 私有化部署上，延迟删除账号功能默认禁用。请使用
> [应用程序设置 API](../../../api/settings.md) 为实例启用
> `delay_user_account_self_deletion` 设置。

您可以安排删除自己的账号。删除账号后，账号会进入待删除状态。通常，删除会在一到两小时内完成，但对于关联了评论、议题、合并请求或代码片段的账号，可能需要长达七天。

在您的账号处于待删除状态期间：

- 您的账号会被[屏蔽](../../../administration/moderate_users.md#block-a-user)。
- 您无法使用相同的用户名创建新账号。
- 您无法使用相同的主电子邮件地址创建新账号，除非您先更改该电子邮件地址。

> [!note]
> 账号删除后，任何用户都可以使用相同的用户名创建用户账号。如果
> 其他用户占用了该用户名，您将无法再取回。

要删除您自己的账号：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **帐户**。
1. 选择 **删除帐户**。

如果您无法在 JihuLab.com 上删除账号，请联系[极狐支持](https://gitlab.cn/support)以从极狐GitLab 中移除您的账号和数据。

<a id="delete-users-and-user-contributions"></a>

## 删除用户和用户贡献

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须是该实例的管理员。

要删除用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择一个用户。
1. 在 **帐户** 标签页下，选择：
   - **删除用户**，仅删除该用户，但保留其[关联记录](#associated-records)。如果所选用户是任何群组的唯一所有者，则无法使用此选项。
   - **删除用户及相关贡献**，删除该用户及其关联记录。此选项还会移除该用户作为群组唯一直接所有者的所有群组（以及这些群组中的项目）。继承的所有权不适用。

> [!warning]
> 使用 **删除用户及相关贡献** 选项可能会移除超出预期的数据。有关更多详情，请参阅
> [关联记录](#associated-records)。

<a id="associated-records"></a>

### 关联记录

删除用户时，您可以选择：

- 仅删除用户，但将贡献转移给幽灵用户：
  - 此内部用户充当所有已删除用户贡献的容器。
  - 在 JihuLab.com 上，此用户称为幽灵用户（`@ghost1`）。
  - 该用户的个人资料和个人项目会被删除，而不是转移给幽灵用户。
- 删除该用户及其贡献，包括：
  - 滥用报告。
  - Emoji 回应。
  - 该用户是唯一具有所有者角色的用户的群组。
  - 个人访问令牌。
  - 史诗。
  - 议题。
  - 合并请求。
  - 代码片段。
  - 其他用户的[提交](../../project/repository/_index.md#commit-changes-to-a-repository)、
    [史诗](../../group/epics/_index.md)、
    [议题](../../project/issues/_index.md)、
    [合并请求](../../project/merge_requests/_index.md)
    和[代码片段](../../snippets.md)上的
    [评论](../../../api/notes.md)。

在这两种情况下，提交都会保留[用户信息](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects#_git_commit_objects)，从而保持 [Git 代码仓库](../../project/repository/_index.md)内的数据完整性。

删除的替代方案是[屏蔽用户](../../../administration/moderate_users.md#block-a-user)。

当用户从[滥用报告](../../../administration/review_abuse_reports.md)或垃圾日志中被删除时，这些关联记录始终会被移除。

删除关联记录的选项可以在 [API](../../../api/users.md#delete-a-user)中请求，也可以在**管理**区域中请求。

> [!warning]
> 用户审批与用户 ID 关联。其他用户贡献没有关联的用户 ID。当您
> 删除用户并将其贡献转移给幽灵用户时，审批贡献会引用缺失或
> 无效的用户 ID。与其删除用户，不如考虑[屏蔽](../../../administration/moderate_users.md#block-a-user)、
> [封禁](../../../administration/moderate_users.md#ban-a-user)或[停用](../../../administration/moderate_users.md#deactivate-a-user)
> 他们。

<a id="delete-the-root-account-on-a-gitlab-self-managed-instance"></a>

## 在极狐GitLab 私有化部署实例上删除 root 账号

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!warning]
> root 账号是系统上权限最高的账号。如果实例上没有其他可用的管理员，删除 root 账号可能会导致无法访问实例的[**管理**区域](../../../administration/admin_area.md)。

您可以使用 UI 或 [GitLab Rails 控制台](../../../administration/operations/rails_console.md)删除 root 账号。

在删除 root 账号之前：

1. 如果您为 root 账号创建了任何[项目](../../project/settings/project_access_tokens.md)或[个人访问令牌](../personal_access_tokens.md)并在工作流中使用它们，请将任何必要的权限或所有权从 root 账号转移给新的管理员。
1. [备份您的极狐GitLab 私有化部署实例](../../../administration/backup_restore/backup_gitlab.md)。
1. 考虑改为[停用](../../../administration/moderate_users.md#deactivate-a-user)或[屏蔽](../../../administration/moderate_users.md#block-and-unblock-users) root 账号。

<a id="use-the-ui"></a>

### 使用 UI

先决条件：

- 您必须是极狐GitLab 私有化部署实例的管理员。

要删除 root 账号：

1. 在**管理**区域中，[创建一个具有管理员访问权限的新用户](create_accounts.md#create-a-user-in-the-admin-area)。这可以确保您在降低删除 root 账号相关风险的同时，保持对实例的管理员访问权限。
1. [删除 root 账号](#delete-users-and-user-contributions)。

<a id="use-the-gitlab-rails-console"></a>

### 使用 GitLab Rails 控制台

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

先决条件：

- 您必须能够访问 GitLab Rails 控制台。

要删除 root 账号，请在 Rails 控制台中：

1. 为另一个现有用户授予管理员访问权限：

   ```ruby
   user = User.find(username: 'Username') # or use User.find_by(email: 'email@example.com') to find by email
   user.admin = true
   user.save!
   ```

   这可以确保您在降低删除 root 账号相关风险的同时，保持对实例的管理员访问权限。

1. 要删除 root 账号，请执行以下任一操作：

   - 屏蔽 root 账号：

     ```ruby
     # This needs to be a current admin user
     current_user = User.find(username: 'Username')

     # This is the root user to block
     user = User.find(username: 'Username')

     ::Users::BlockService.new(current_user).execute(user)
     ```

   - 停用 root 用户：

     ```ruby
     # This needs to be a current admin user
     current_user = User.find(username: 'Username')

     # This is the root user to deactivate
     user = User.find(username: 'Username')

     ::Users::DeactivateService.new(current_user, skip_authorization: true).execute(user)
     ```
