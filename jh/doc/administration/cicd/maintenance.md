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

以下命令在 [Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行。

> [!warning]
> 任何直接更改数据的命令如果未正确运行或在适当的条件下运行，都可能造成损害。
> 我们强烈建议在测试环境中运行它们，并准备好实例的备份以便恢复，以防万一。

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

<a id="validate-the-gitlab-ci-yml-file"></a>

## 验证 `.gitlab-ci.yml` 文件

```ruby
project = Project.find_by_full_path('<project_path>')
content = project.ci_config_for(project.repository.root_ref_sha)
Gitlab::Ci::Lint.new(project: project, current_user: User.first).validate(content)
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

你可以通过 Rails 控制台手动运行流水线计划，以揭示通常不可见的任何错误。

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

## 获取 runners 注册令牌（已弃用）

> [!warning]
> 传递 runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不推荐使用。
> 使用 [runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 runners。此过程提供了 runner 所有权的完全可追溯性，并增强了 runner 队列的安全性。
> 更多信息，请参见
> [迁移到新的 runner 注册工作流](../../ci/runners/new_creation_workflow.md)。

前提条件：

- 必须在 **管理员** 区域中 [启用 runner 注册令牌](../settings/continuous_integration.md#control-runner-registration)。

```ruby
Gitlab::CurrentSettings.current_application_settings.runners_registration_token
```

<a id="seed-runners-registration-token-deprecated"></a>

## 种子 runners 注册令牌（已弃用）

> [!warning]
> 传递 runner 注册令牌的选项以及对某些配置参数的支持被视为旧版，不推荐使用。
> 使用 [runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)
> 生成认证令牌来注册 runners。此过程提供了 runner 所有权的完全可追溯性，并增强了 runner 队列的安全性。
> 更多信息，请参见
> [迁移到新的 runner 注册工作流](../../ci/runners/new_creation_workflow.md)。

```ruby
appSetting = Gitlab::CurrentSettings.current_application_settings
appSetting.set_runners_registration_token('<new-runners-registration-token>')
appSetting.save!
```

<!--- end_remove -->