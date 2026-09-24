---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 下游流水线排错
---

<a id="trigger-job-fails-and-does-not-create-multi-project-pipeline"></a>

## 触发作业失败且未创建多项目流水线

对于多项目流水线，以下情况下触发作业会失败，且不会创建下游流水线：

- 未找到下游项目。
- 创建上游流水线的用户没有在下游项目中[创建流水线的权限](../../user/permissions.md)。
- 下游流水线以受保护分支为目标，且用户没有针对该受保护分支运行流水线的权限。有关更多信息，请参阅[受保护分支的流水线安全性](_index.md#pipeline-security-on-protected-branches)。

要确定下游项目中哪个用户有权限问题，您可以在 [Rails 控制台](../../administration/operations/rails_console.md)中使用以下命令检查触发作业，并查看 `user_id` 属性。

```ruby
Ci::Bridge.find(<job_id>)
```

<a id="job-in-child-pipeline-is-not-created-when-the-pipeline-runs"></a>

## 子流水线中的作业在流水线运行时未创建

如果父流水线是[合并请求流水线](merge_request_pipelines.md)，子流水线必须[使用 `workflow:rules` 或 `rules` 来确保作业运行](downstream_pipelines.md#run-child-pipelines-with-merge-request-pipelines)。

如果由于 `rules` 配置缺失或不正确，导致子流水线中没有作业可以运行：

- 子流水线无法启动。
- 父流水线的触发作业会失败，并显示：`下游流水线无法创建，生成的流水线将为空。请检查相关作业的`[`rules`](../yaml/_index.md#rules)`配置。`

<a id="variable-with--character-does-not-get-passed-to-a-downstream-pipeline-properly"></a>

## 带有 `$` 字符的变量未正确传递到下游流水线

在[向子流水线传递 CI/CD 变量](downstream_pipelines.md#pass-cicd-variables-to-a-downstream-pipeline)时，您不能[使用 `$$` 来转义 CI/CD 变量中的 `$` 字符](../variables/job_scripts.md#use-the--character-in-cicd-variables)。子流水线仍会将 `$` 视为变量引用的起始符。

您可以在 UI 中配置变量时[防止 CI/CD 变量扩展](../variables/_index.md#allow-cicd-variable-expansion)，或使用 [`variables:expand` 关键字](../yaml/_index.md#variablesexpand)将变量值设置为不扩展。然后，此变量可以传递到下游流水线，而其中的 `$` 不会被解释为变量引用。

<a id="ref-is-ambiguous"></a>

## `引用不明确`

当存在同名的分支时，您无法使用标签触发多项目流水线。子流水线会创建失败，并显示错误：`下游流水线无法创建，引用不明确`。

请仅使用与分支名称不匹配的标签名称触发多项目流水线。

<a id="403-forbidden-error-when-downloading-a-job-artifact-from-an-upstream-pipeline"></a>

## 从上游流水线下载作业产物时出现 `403 Forbidden` 错误

在极狐GitLab 15.9 及更高版本中，CI/CD 作业令牌的作用域限定为流水线执行所在的极狐GitLab 项目。因此，默认情况下，子流水线中的作业令牌不能用于访问上游项目。

要解决此问题，请[将子流水线项目添加到作业令牌作用域白名单](../jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)。

<a id="error-needsneed-pipeline-should-be-a-string"></a>

## `needs:need pipeline 应为字符串` 错误

当将 [`needs:pipeline:job`](../yaml/_index.md#needspipelinejob) 与动态子流水线结合使用时，您可能会收到此错误：

```plaintext
无法运行流水线
- jobs:<job_name>:needs:need pipeline 应为字符串
```

当流水线 ID 被解析为整数而非字符串时，会发生此错误。要修复此问题，请将流水线 ID 用引号括起来：

```yaml
rspec:
  needs:
    - pipeline: "$UPSTREAM_PIPELINE_ID"
      job: dependency-job
      artifacts: true
```