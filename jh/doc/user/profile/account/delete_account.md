---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Remove user accounts and manage associated records and contributions.
title: 删除用户
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

用户可以从极狐GitLab 实例中删除，方式包括：

- 用户本人。
- 管理员。

> [!note]
> 删除用户会删除该用户命名空间中的所有项目。

<a id="delete-your-own-account"></a>

## 删除您自己的账户

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.0 中引入了一个[功能标志](../../../administration/feature_flags/_index.md)，名为 `delay_delete_own_user`，用于延迟用户删除自己账户到用户记录实际删除的时间。在 JihuLab.com 上默认启用。

{{< /history >}}

> [!note]
> 在私有化部署实例上，此功能默认禁用。使用[应用程序设置 API](../../../api/settings.md) 为实例启用 `delay_user_account_self_deletion` 设置。

您可以安排账户删除。删除账户后，它会进入待删除状态。通常，删除会在一到两小时内完成，但对于与评论、议题、合并请求、注释或片段关联的账户，最长可能需要七天。

在您的账户处于待删除状态期间：

- 您的账户被[阻止](../../../administration/moderate_users.md#block-a-user)。
- 您不能使用相同的用户名创建新账户。
- 您不能使用相同的主要电子邮件地址创建新账户，除非您先更改电子邮件地址。

> [!note]
> 账户删除后，任何用户都可以使用相同的用户名创建用户账户。如果其他用户使用了该用户名，您将无法要求归还。

要删除您自己的账户：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **账户**。
1. 选择 **删除账户**。

如果您无法在 JihuLab.com 上删除您的账户，请提交[个人数据请求](https://support.gitlab.io/personal-data-request/)以从极狐GitLab 中删除您的账户和数据。

<a id="delete-users-and-user-contributions"></a>

## 删除用户及其贡献

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

前提条件：

- 您必须是该实例的管理员。

要删除用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择一个用户。
1. 在 **账户** 选项卡下，选择：
   - **删除用户** 以仅删除用户但保留其[关联记录](#associated-records)。如果所选用户是任何群组的唯一所有者，则无法使用此选项。
   - **删除用户及其贡献** 以删除用户及其关联记录。此选项还会删除用户作为唯一直接所有者的所有群组（以及这些群组中的项目）。继承的所有权不适用。

> [!warning]
> 使用 **删除用户及其贡献** 选项可能导致删除比预期更多的数据。请参阅[关联记录](#associated-records) 了解详情。

<a id="associated-records"></a>

### 关联记录

删除用户时，您可以：

- 仅删除用户，但将贡献转移给幽灵用户：
  - 此内部用户充当所有已删除用户贡献的容器。
  - 在 JihuLab.com 上，此用户称为幽灵用户 (`@ghost1`)。
  - 用户的个人资料和个人项目会被删除，而不是转移给幽灵用户。
- 删除用户及其贡献，包括：
  - 滥用报告。
  - 表情反应。
  - 用户作为唯一具有所有者角色的群组。
  - 个人访问令牌。
  - 史诗。
  - 议题。
  - 合并请求。
  - 片段。
  - [注释和评论](../../../api/notes.md)
    针对其他用户的[提交](../../project/repository/_index.md#commit-changes-to-a-repository)、
    [史诗](../../group/epics/_index.md)、
    [议题](../../project/issues/_index.md)、
    [合并请求](../../project/merge_requests/_index.md)
    和[片段](../../snippets.md)。

在两种情况下，提交都会保留[用户信息](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects#_git_commit_objects)，因此 [Git 仓库](../../project/repository/_index.md) 中的数据完整性得以保持。

删除的替代方法是[阻止用户](../../../administration/moderate_users.md#block-a-user)。

当用户因[滥用报告](../../../administration/review_abuse_reports.md)或垃圾信息日志而被删除时，这些关联记录始终会被删除。

可以在 [API](../../../api/users.md#delete-a-user) 以及 **管理员** 区域中请求删除关联记录选项。

> [!warning]
> 用户批准与用户 ID 关联。其他用户贡献没有关联的用户 ID。当您删除用户并将其贡献转移到幽灵用户时，批准贡献将引用缺失或无效的用户 ID。考虑[阻止](../../../administration/moderate_users.md#block-a-user)、[禁言](../../../administration/moderate_users.md#ban-a-user) 或 [停用](../../../administration/moderate_users.md#deactivate-a-user) 用户，而不是删除用户。

<a id="delete-the-root-account-on-a-gitlab-self-managed-instance"></a>

## 在私有化部署实例上删除根账户

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 根账户是系统上权限最高的账户。删除根账户可能导致在实例上失去对 [**管理员** 区域](../../../administration/admin_area.md) 的访问权限，如果实例上没有其他管理员的话。

您可以使用 UI 或 [极狐GitLab Rails 控制台](../../../administration/operations/rails_console.md) 删除根账户。

在删除根账户之前：

1. 如果您为根账户创建了任何[项目](../../project/settings/project_access_tokens.md)或[个人访问令牌](../personal_access_tokens.md)并在工作流中使用它们，请将必要的权限或所有权从根账户转移给新的管理员。
1. [备份您的私有化部署实例](../../../administration/backup_restore/backup_gitlab.md)。
1. 考虑改为[停用](../../../administration/moderate_users.md#deactivate-a-user)或[阻止](../../../administration/moderate_users.md#block-and-unblock-users)根账户。

<a id="use-the-ui"></a>

### 使用 UI

前提条件：

- 您必须是私有化部署实例的管理员。

要删除根账户：

1. 在 **管理员** 区域中，[创建一个具有管理员访问权限的新用户](create_accounts.md#create-a-user-in-the-admin-area)。这确保您在删除根账户时仍保持管理员访问权限。
1. [删除根账户](#delete-users-and-user-contributions)。

<a id="use-the-gitlab-rails-console"></a>

### 使用极狐GitLab Rails 控制台

> [!warning]
> 如果命令未正确运行或在错误的条件下运行，更改数据的命令可能会造成损害。请始终先在测试环境中运行命令，并准备好要恢复的备份实例。

前提条件：

- 您必须具有访问极狐GitLab Rails 控制台的权限。

要在 Rails 控制台中删除根账户：

1. 为另一个现有用户授予管理员访问权限：

   ```ruby
   user = User.find(username: 'Username') # 或使用 User.find_by(email: 'email@example.com') 通过电子邮件查找
   user.admin = true
   user.save!
   ```

   这确保您在删除根账户时仍保持对实例的管理员访问权限。

1. 要删除根账户，请执行以下任一操作：

   - 阻止根账户：

     ```ruby
     # 这需要是当前管理员用户
     current_user = User.find(username: 'Username')

     # 这是要阻止的根用户
     user = User.find(username: 'Username')

     ::Users::BlockService.new(current_user).execute(user)
     ```

   - 停用根用户：

     ```ruby
     # 这需要是当前管理员用户
     current_user = User.find(username: 'Username')

     # 这是要停用的根用户
     user = User.find(username: 'Username')

     ::Users::DeactivateService.new(current_user, skip_authorization: true).execute(user)
     ```

