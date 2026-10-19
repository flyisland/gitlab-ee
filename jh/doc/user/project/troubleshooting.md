---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目故障排除
description: 问题解决、常见问题、调试和错误解决。
---

使用项目时，您可能会遇到以下问题，或者需要其他方法来完成特定任务。

<a id="an-error-occurred-while-fetching-commit-data"></a>

## `An error occurred while fetching commit data`

当您访问项目时，如果浏览器中使用了广告拦截器，可能会显示消息 `An error occurred while fetching commit data`。解决方法是针对您尝试访问的极狐GitLab 实例禁用广告拦截器。

<a id="find-projects-using-an-sql-query"></a>

## 使用 SQL 查询查找项目

在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，您可以根据 SQL 查询查找并存储项目数组：

```ruby
# Finds projects that end with '%ject'
projects = Project.find_by_sql("SELECT * FROM projects WHERE name LIKE '%ject'")
=> [#<Project id:12 root/my-first-project>>, #<Project id:13 root/my-second-project>>]
```

<a id="clear-a-projects-or-repositorys-cache"></a>

## 清除项目或代码仓库的缓存

如果项目或代码仓库已更新，但 UI 中未反映其状态，您可能需要清除项目或代码仓库的缓存。您可以通过 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)以及以下方法之一来完成：

> [!warning]
> 如果未在正确的条件下正确运行，更改数据的命令可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
## Clear project cache
ProjectCacheWorker.perform_async(project.id)

## Clear repository .exists? cache
project.repository.expire_exists_cache
```

<a id="find-projects-that-are-pending-deletion"></a>

## 查找待删除的项目

如果您需要查找所有已标记为删除但尚未删除的项目，请[启动 Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)并运行以下命令：

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

如果通过 UI 或 API 转移项目无法正常工作，您可以尝试在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中转移。

```ruby
p = Project.find_by_full_path('<project_path>')

# To set the owner of the project
current_user = p.creator

# Namespace where you want this to be moved
namespace = Namespace.find_by_full_path("<new_namespace>")

Projects::TransferService.new(p, current_user).execute(namespace)
```

<a id="project-transfer-stuck-in-transfer_in_progress-or-transfer_scheduled-state"></a>

## 项目转移卡在 `transfer_in_progress` 或 `transfer_scheduled` 状态

当异步转移作业失败时，项目转移可能会停滞，例如由于锁争用或语句超时。重试转移会返回：

`Unable to initiate transfer. The project may already have a transfer in progress.`

在极狐GitLab 19.1 及更高版本中，请重试转移。即使项目命名空间仍处于 `transfer_in_progress` 或 `transfer_scheduled` 状态，极狐GitLab 也会重新安排转移。

在早于 19.1 的极狐GitLab 版本中，请在重试转移之前，在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中取消过期的转移状态：

> [!warning]
> 如果未在正确的条件下正确运行，更改数据的命令可能会造成损害。
> 请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
Project.find_by_full_path('<group>/<project_name>').project_namespace.cancel_transfer!
```

<a id="delete-a-project-using-console"></a>

## 使用控制台删除项目

如果项目无法删除，您可以尝试通过 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)删除它。

> [!warning]
> 如果未在正确的条件下正确运行，更改数据的命令可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
project = Project.find_by_full_path('<project_path>')
user = User.find_by_username('<username>')
Projects::DestroyService.new(project, user, {}).execute
```

如果此操作失败，请使用以下命令显示失败原因：

```ruby
project = Project.find_by_full_path('<project_path>')
project.deletion_error
```

<a id="toggle-a-feature-for-all-projects-within-a-group"></a>

## 为群组内的所有项目切换功能

虽然可以通过[项目 API](../../api/projects.md) 在项目中切换功能，但您可能需要对大量项目执行此操作。

要切换特定功能，您可以[启动 Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)并运行以下函数：

> [!warning]
> 如果未在正确的条件下正确运行，更改数据的命令可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

```ruby
projects = Group.find_by_name('_group_name').projects
projects.each do |p|
  ## replace <feature-name> with the appropriate feature name in all instances
  state = p.<feature-name>

  if state != 0
    puts "#{p.name} has <feature-name> already enabled. Skipping..."
  else
    puts "#{p.name} didn't have <feature-name> enabled. Enabling..."
    p.project_feature.update!(<feature-name>: ProjectFeature::PRIVATE)
  end
end
```

要查找可切换的功能，请运行 `pp p.project_feature`。可用的权限级别列在
[concerns/featurable.rb](https://gitlab.com/gitlab-org/gitlab/blob/master/app/models/concerns/featurable.rb)中。

<a id="support-knowledge-base"></a>

## 支持知识库

如果您仍有问题，请参阅[极狐GitLab 支持知识库](https://gitlab.cn/support)。
