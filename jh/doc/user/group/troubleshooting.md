---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组故障排除
---

<a id="validation-errors-on-namespaces-and-groups"></a>

## 命名空间和群组的验证错误

在创建或更新命名空间或群组时，执行以下检查：

- 命名空间不得有父级。
- 群组的父级必须是群组，而不是命名空间。

如果在您的极狐GitLab 安装中遇到这些错误（这种情况不太可能发生），请[联系支持](https://gitlab.cn/support)，以便极狐GitLab 改进此验证。

<a id="find-groups-using-an-sql-query"></a>

## 使用 SQL 查询查找群组

要根据 [Rails 控制台](../../administration/operations/rails_console.md)中的 SQL 查询查找并存储群组数组：

```ruby
# Finds groups and subgroups that end with '%oup'
Group.find_by_sql("SELECT * FROM namespaces WHERE name LIKE '%oup'")
=> [#<Group id:3 @test-group>, #<Group id:4 @template-group/template-subgroup>]
```

<a id="transfer-subgroup-to-another-location-using-rails-console"></a>

## 使用 Rails 控制台将子群组转移到其他位置

如果通过 UI 或 API 无法转移群组，您可以尝试在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中执行转移：

> [!warning]
> 如果未正确运行或在不当条件下运行，更改数据的命令可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
user = User.find_by_username('<username>')
group = Group.find_by_name("<group_name>")
## Set parent_group = nil to make the subgroup a top-level group
parent_group = Group.find_by(id: "<group_id>")
service = ::Groups::TransferService.new(group, user)
service.execute(parent_group)
```

<a id="group-transfer-stuck-in-transfer_in_progress-or-transfer_scheduled-state"></a>

## 群组转移卡在 `transfer_in_progress` 或 `transfer_scheduled` 状态

当异步转移作业失败时，群组转移可能会停滞，例如由于锁争用或语句超时。重试转移会返回：

`Unable to initiate transfer. The group may already have a transfer in progress.`

在极狐GitLab 19.1 及更高版本中，请重试转移。即使命名空间仍处于 `transfer_in_progress` 或 `transfer_scheduled` 状态，极狐GitLab 也会重新安排转移。

在早于 19.1 的极狐GitLab 版本中，请先在
[Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中
取消过期的转移状态，然后再重试转移：

> [!warning]
> 如果未正确运行或在不当条件下运行，更改数据的命令可能会造成损害。
> 请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
Group.find_by_full_path('<group_path>').cancel_transfer!
```

<a id="find-groups-pending-deletion-using-rails-console"></a>

## 使用 Rails 控制台查找待删除的群组

如果您需要查找所有待删除的群组，可以在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中使用以下命令：

```ruby
Group.all.each do |g|
 if g.self_deletion_scheduled?
    puts "Group ID: #{g.id}"
    puts "Group name: #{g.name}"
    puts "Group path: #{g.full_path}"
 end
end
```

<a id="delete-a-group-using-rails-console"></a>

## 使用 Rails 控制台删除群组

有时，群组删除可能会卡住。如有需要，可以在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中尝试使用以下命令删除群组：

> [!warning]
> 如果未正确运行或在不当条件下运行，更改数据的命令可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
GroupDestroyWorker.new.perform(group_id, user_id)
```

<a id="find-a-users-maximum-permissions-for-a-group-or-project"></a>

## 查找用户对群组或项目的最大权限

管理员可以查找用户对群组或项目的最大权限。

1. 启动 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下命令：

   ```ruby
   user = User.find_by_username 'username'
   project = Project.find_by_full_path 'group/project'
   user.max_member_access_for_project project.id
   ```

   ```ruby
   user = User.find_by_username 'username'
   group = Group.find_by_full_path 'group'
   user.max_member_access_for_group group.id
   ```

<a id="unable-to-remove-billable-members-with-badge-project-invitegroup-invite"></a>

## 无法移除带有 `Project Invite/Group Invite` 徽章的计费成员

以下错误通常发生在用户属于已共享到您的[项目](../project/members/sharing_projects_groups.md)或[群组](../project/members/sharing_projects_groups.md#invite-a-group-to-a-group)的外部群组时：

<!-- vale gitlab_base.LatinTerms = NO -->
`Members who were invited via a group invitation cannot be removed. You can either remove the entire group, or ask an Owner of the invited group to remove the member.`
<!-- vale gitlab_base.LatinTerms = YES -->

要将该用户作为计费成员移除，请执行以下选项之一：

- 从您的项目或群组成员页面移除受邀群组成员资格。
- 推荐。如果您有权访问该受邀群组，请直接从该群组中移除该用户。

<a id="missing-or-insufficient-permission-delete-button-disabled"></a>

## 权限缺失或不足，删除按钮已禁用

此错误通常发生在用户尝试在群组转移期间从已归档项目中移除 `container_registry` 镜像时。要解决此错误：

1. 取消归档该项目。
1. 删除 `container_registry` 镜像。
1. 归档该项目。

<a id="group-owner-unable-to-approve-pending-users-with-awaiting-user-signup-badge"></a>

## 群组所有者无法批准带有 `Awaiting user signup` 徽章的待处理用户

向非极狐GitLab 用户发送的电子邮件邀请会列在 `Pending members` 下，状态为 `Awaiting user signup`。当该用户注册 JihuLab.com 后，状态会更新为 `Pending owner action`，群组所有者即可完成批准流程。

<a id="support-knowledge-base"></a>

## 支持知识库

如果您仍然遇到问题，请参阅[极狐GitLab 支持知识库](https://gitlab.cn/support)。
