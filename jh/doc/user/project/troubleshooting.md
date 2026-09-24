---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 项目故障排查
description: Problem solving, common issues, debugging, and error resolution.
---

在使用项目时，您可能会遇到以下问题，或需要使用替代方法完成特定任务。

<a id="an-error-occurred-while-fetching-commit-data"></a>

## `获取提交数据时发生错误`

如果您在浏览器中使用了广告拦截器，访问项目时可能会显示 `获取提交数据时发生错误` 消息。解决方法是针对您尝试访问的极狐GitLab 实例禁用广告拦截器。

<a id="find-projects-using-an-sql-query"></a>

## 使用 SQL 查询查找项目

在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中，您可以通过 SQL 查询查找并存储项目数组：

```ruby
# 查找以 '%ject' 结尾的项目
projects = Project.find_by_sql("SELECT * FROM projects WHERE name LIKE '%ject'")
=> [#<Project id:12 root/my-first-project>>, #<Project id:13 root/my-second-project>>]
```

<a id="clear-a-projects-or-repositorys-cache"></a>

## 清除项目或代码仓的缓存

如果项目或代码仓已更新，但状态未在 UI 中反映出来，您可能需要清除项目或代码仓的缓存。您可以通过 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 并执行以下操作之一：

> [!warning]
> 更改数据的命令如果运行不当或在错误条件下运行，可能会导致数据损坏。请务必先在测试环境中运行命令，并准备好用于恢复的备份实例。

```ruby
## 清除项目缓存
ProjectCacheWorker.perform_async(project.id)

## 清除代码仓 .exists? 缓存
project.repository.expire_exists_cache
```

<a id="find-projects-that-are-pending-deletion"></a>

## 查找待删除的项目

如果您需要查找所有已标记为删除但尚未删除的项目，请 [启动 Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 并运行以下命令：

```ruby
projects = Project.where(pending_delete: true)
projects.each do |p|
  puts "Project ID: #{p.id}"
  puts "Project name: #{p.name}"
  puts "Repository path: #{p.repository.full_path}"
end
```

<a id="transfer-a-project-using-console"></a>

### 使用控制台转移项目

如果通过 UI 或 API 转移项目不成功，您可以在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中尝试转移。

```ruby
p = Project.find_by_full_path('<project_path>')

# 设置项目所有者
current_user = p.creator

# 您希望将项目移动到的命名空间
namespace = Namespace.find_by_full_path("<new_namespace>")

Projects::TransferService.new(p, current_user).execute(namespace)
```

<a id="delete-a-project-using-console"></a>

## 使用控制台删除项目

如果某个项目无法删除，您可以尝试通过 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 将其删除。

> [!warning]
> 更改数据的命令如果运行不当或在错误条件下运行，可能会导致数据损坏。请务必先在测试环境中运行命令，并准备好用于恢复的备份实例。

```ruby
project = Project.find_by_full_path('<project_path>')
user = User.find_by_username('<username>')
Projects::DestroyService.new(project, user, {}).execute
```

如果此操作失败，显示为什么无法删除：

```ruby
project = Project.find_by_full_path('<project_path>')
project.deletion_error
```

<a id="toggle-a-feature-for-all-projects-within-a-group"></a>

## 为群组内所有项目切换功能

虽然可以通过 [项目 API](../../api/projects.md) 为项目切换功能，但您可能需要对大量项目执行此操作。

要切换特定功能，您可以 [启动 Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session) 并运行以下函数：

> [!warning]
> 更改数据的命令如果运行不当或在错误条件下运行，可能会导致数据损坏。请务必先在测试环境中运行命令，并准备好用于恢复的备份实例。

```ruby
projects = Group.find_by_name('_group_name').projects
projects.each do |p|
  ## 在所有实例中将 <feature-name> 替换为适当的功能名称
  state = p.<feature-name>

  if state != 0
    puts "#{p.name} 已启用 <feature-name>。跳过..."
  else
    puts "#{p.name} 未启用 <feature-name>。正在启用..."
    p.project_feature.update!(<feature-name>: ProjectFeature::PRIVATE)
  end
end
```

要查找可以切换的功能，请运行 `pp p.project_feature`。
可用的权限级别列在 [concerns/featurable.rb](https://jihulab.com/gitlab-cn/gitlab/blob/master/app/models/concerns/featurable.rb) 中。

<a id="support-knowledge-base"></a>

## 支持知识库

如果您仍然遇到问题，请参阅 [极狐GitLab 支持知识库](https://support.jihulab.com/hc/en-us/)。