---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组故障排查
---

<a id="validation-errors-on-namespaces-and-groups"></a>

## 命名空间和群组的验证错误

在创建或更新命名空间或群组时，会执行以下检查：

- 命名空间不能有父级。
- 群组父级必须是群组，不能是命名空间。

如果在极狐GitLab 实例中遇到这些错误，请[联系支持](https://gitlab.cn/support/)，以便极狐GitLab 改进此验证。

<a id="find-groups-using-an-sql-query"></a>

## 使用 SQL 查询查找群组

在 [Rails 控制台](../../administration/operations/rails_console.md)中，根据 SQL 查询查找并存储群组数组：

```ruby
# 查找以 '%oup' 结尾的群组和子群组
Group.find_by_sql("SELECT * FROM namespaces WHERE name LIKE '%oup'")
=> [#<Group id:3 @test-group>, #<Group id:4 @template-group/template-subgroup>]
```

<a id="transfer-subgroup-to-another-location-using-rails-console"></a>

## 使用 Rails 控制台将子群组转移到其他位置

如果通过 UI 或 API 转移群组失败，你可能希望在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中尝试执行转移：

> [!warning]
> 如果运行不当或在不适当的条件下，更改数据的命令可能会造成损坏。务必先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
user = User.find_by_username('<username>')
group = Group.find_by_name("<group_name>")
## 设置 parent_group = nil 使子群组成为顶级群组
parent_group = Group.find_by(id: "<group_id>")
service = ::Groups::TransferService.new(group, user)
service.execute(parent_group)
```

<a id="find-groups-pending-deletion-using-rails-console"></a>

## 使用 Rails 控制台查找待删除的群组

如果需要查找所有待删除的群组，可以在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中使用以下命令：

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

有时，群组删除可能会卡住。如果需要，可以在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中尝试使用以下命令删除群组：

> [!warning]
> 如果运行不当或在不适当的条件下，更改数据的命令可能会造成损坏。务必先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
GroupDestroyWorker.new.perform(group_id, user_id)
```

<a id="find-a-users-maximum-permissions-for-a-group-or-project"></a>

## 查找用户在群组或项目中的最大权限

管理员可以查找用户在群组或项目中的最大权限。

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

<a id="unable-to-remove-billable-members-with-badge-project-invite-group-invite"></a>

## 无法移除带有 `项目邀请/群组邀请` 徽章的计费成员

当用户属于已与你的[项目](../project/members/sharing_projects_groups.md)或[群组](../project/members/sharing_projects_groups.md#invite-a-group-to-a-group)共享的外部群组时，通常会出现以下错误：

<!-- vale gitlab_base.LatinTerms = NO -->
`通过群组邀请受邀的成员无法移除。你可以移除整个群组，或请求受邀群组的所有者移除该成员。`
<!-- vale gitlab_base.LatinTerms = YES -->

要将用户作为计费成员移除，请按照以下选项之一操作：

- 从你的项目或群组成员页面中移除受邀的群组成员身份。
- 推荐。如果你有该群组的访问权限，直接从受邀群组中移除该用户。

<a id="missing-or-insufficient-permission-delete-button-disabled"></a>

## 权限缺失或不足，删除按钮已禁用

当用户尝试在群组转移期间从已归档的项目中删除 `容器镜像仓库` 镜像时，通常会出现此错误。要解决此错误：

1. 取消归档项目。
1. 删除 `容器镜像仓库` 镜像。
1. 归档项目。

<a id="group-owner-unable-to-approve-pending-users-with-awaiting-user-signup-badge"></a>

## 群组所有者无法批准带有 `等待用户注册` 徽章的待处理用户

向非极狐GitLab 用户发送的电子邮件邀请会以 `待处理成员` 状态显示在 `等待用户注册` 下。
当用户注册 JihuLab.com 后，状态会更新为 `等待所有者操作`，群组所有者即可完成批准流程。

<a id="support-knowledge-base"></a>

## 支持知识库

如果仍然遇到问题，请查阅 [极狐GitLab 支持知识库](https://support.jihulab.com/hc/en-us/)。