---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 维护控制台命令
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下命令在 [Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行。

> [!warning]
> 任何直接更改数据的命令，如果运行不正确，或即使在条件合适的情况下，都可能造成损害。
> 强烈建议您在测试环境中运行这些命令，并准备好可恢复的实例备份，以防万一。

<a id="cancel-all-running-pipelines-and-their-jobs"></a>

## 取消所有正在运行的流水线及其作业

```ruby
admin = User.find(user_id) # replace user_id with the id of the admin you want to cancel the pipeline
# Iterate over each cancelable pipeline
Ci::Pipeline.cancelable.find_each do |pipeline|
  Ci::CancelPipelineService.new(
    pipeline: pipeline,
    current_user: user,
    cascade_to_children: false # the children are included in the outer loop
  )
end
```

<a id="cancel-stuck-pending-pipelines"></a>

## 取消卡住的待处理流水线

```ruby
project = Project.find_by_full_path('<project_path>')
Ci::Pipeline.where(project_id: project.id).where(status: 'pending').count
Ci::Pipeline.where(project_id: project.id).where(status: 'pending').each {|p| p.cancel if p.stuck?}
Ci::Pipeline.where(project_id: project.id).where(status: 'pending').count
```

<a id="try-merge-request-integration"></a>

## 尝试合并请求集成

```ruby
project = Project.find_by_full_path('<project_path>')
mr = project.merge_requests.find_by(iid: <merge_request_iid>)
mr.project.try(:ci_integration)
```

<a id="validate-the-gitlab-ciyml-file"></a>

## 验证`.gitlab-ci.yml` 文件

```ruby
project = Project.find_by_full_path('<project_path>')
content = project.ci_config_for(project.repository.root_ref_sha)
Gitlab::Ci::Lint
  .new(project: project, current_user: User.first, surface: :rails_console)
  .validate(content, dry_run: false, ref: project.default_branch)
```

<a id="disable-autodevops-on-existing-projects"></a>

## 在现有项目上禁用 AutoDevOps

```ruby
Project.all.each do |p|
  p.auto_devops_attributes={"enabled"=>"0"}
  p.save
end
```

<a id="run-pipeline-schedules-manually"></a>

## 手动运行流水线计划

您可以通过 Rails 控制台手动运行流水线计划，以发现通常不可见的任何错误。

```ruby
# schedule_id can be obtained from Edit Pipeline Schedule page
schedule = Ci::PipelineSchedule.find_by(id: <schedule_id>)

# Select the user that you want to run the schedule for
user = User.find_by_username('<username>')

# Run the schedule
ps = Ci::CreatePipelineService.new(schedule.project, user, ref: schedule.ref).execute!(:schedule, ignore_skip_ci: true, save_on_errors: false, schedule: schedule)
```

<!--- start_remove The following content will be removed on remove_date: '2027-08-15' -->

<a id="obtain-runners-registration-token-deprecated"></a>

## 获取 Runner 注册令牌（已废弃）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版做法，
> 不建议使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成身份验证令牌以注册 Runner。此过程可提供 Runner 所有权的完整
> 可追溯性，并增强 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](../../ci/runners/new_creation_workflow.md)。

先决条件：

- 必须在**管理**区域中[启用](../settings/continuous_integration.md#control-runner-registration) Runner 注册令牌。

```ruby
Gitlab::CurrentSettings.current_application_settings.runners_registration_token
```

<a id="seed-runners-registration-token-deprecated"></a>

## 预设 Runner 注册令牌（已废弃）

> [!warning]
> 传递 Runner 注册令牌的选项以及对某些配置参数的支持被视为旧版做法，
> 不建议使用。
> 请使用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成身份验证令牌以注册 Runner。此过程可提供 Runner 所有权的完整
> 可追溯性，并增强 Runner 集群的安全性。
> 有关更多信息，请参阅
> [迁移到新的 Runner 注册工作流](../../ci/runners/new_creation_workflow.md)。

```ruby
appSetting = Gitlab::CurrentSettings.current_application_settings
appSetting.set_runners_registration_token('<new-runners-registration-token>')
appSetting.save!
```

<!--- end_remove -->
