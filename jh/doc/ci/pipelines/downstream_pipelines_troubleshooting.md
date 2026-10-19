---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 下游流水线故障排除
---

<a id="trigger-job-fails-and-does-not-create-multi-project-pipeline"></a>

## 触发作业失败且未创建多项目流水线

使用多项目流水线时，如果出现以下情况，触发作业会失败且不会创建下游流水线：

- 未找到下游项目。
- 创建上游流水线的用户没有在下游项目中创建流水线的[权限](../../user/permissions.md)。
- 下游流水线的目标是受保护分支，而该用户没有针对受保护分支运行流水线的权限。更多信息，请参见[受保护分支的流水线安全](_index.md#pipeline-security-on-protected-branches)。

要确定下游项目中哪个用户存在权限问题，您可以在 [Rails 控制台](../../administration/operations/rails_console.md)中使用以下命令检查触发作业，并查看 `user_id` 属性。

```ruby
Ci::Bridge.find(<job_id>)
```

<a id="job-in-child-pipeline-is-not-created-when-the-pipeline-runs"></a>

## 流水线运行时未创建子流水线中的作业

如果父流水线是[合并请求流水线](merge_request_pipelines.md)，则子流水线必须[使用 `workflow:rules` 或 `rules` 来确保作业运行](downstream_pipelines.md#run-child-pipelines-with-merge-request-pipelines)。

如果由于 `rules` 配置缺失或不正确，导致子流水线中没有任何作业可以运行：

- 子流水线无法启动。
- 父流水线的触发作业失败，并显示：`downstream pipeline can not be created, the resulting pipeline would have been empty. Review the`[`rules`](../yaml/_index.md#rules)`configuration.`

<a id="variable-with--character-does-not-get-passed-to-a-downstream-pipeline-properly"></a>

## 包含 `$` 字符的变量无法正确传递到下游流水线

当[将 CI/CD 变量传递到下游流水线](downstream_pipelines.md#pass-cicd-variables-to-a-downstream-pipeline)时，您无法使用 [`$$` 来转义 CI/CD 变量中的 `$` 字符](../variables/job_scripts.md#use-the--character-in-cicd-variables)。下游流水线仍会将 `$` 视为变量引用的开头。

在 UI 中配置变量时，您可以[阻止 CI/CD 变量展开](../variables/_index.md#allow-cicd-variable-expansion)，或使用 [`variables:expand` 关键字](../yaml/_index.md#variablesexpand)将变量值设置为不展开。这样，该变量就可以传递到下游流水线，而不会将 `$` 解释为变量引用。

<a id="variable-in-a-triggerinclude-path-is-empty-or-has-an-unexpected-value"></a>

## `trigger:include` 路径中的变量为空或值不符合预期

[`trigger:include`](../yaml/_index.md#triggerinclude) 路径中的 CI/CD 变量不会在触发作业中展开。该路径会以字符串形式连同未展开的变量传递给生成子流水线的进程。随后，展开会在子流水线的上下文中进行。

因此：

- 来自流水线配置的变量只有在转发到子流水线时，才能用于 `trigger:include` 路径。这包括默认 `variables` 和触发作业自身的 `variables`。如果触发作业使用 [`trigger:forward`](../yaml/_index.md#triggerforward) 并设置 `yaml_variables: false`，则路径中的任何变量都无法展开，并会求值为空字符串。项目、群组和实例 CI/CD 变量不受影响，因为它们在两种上下文中都可用。
- 预定义变量保存的是子流水线的值。例如，`$CI_PIPELINE_SOURCE` 是子流水线中的 `parent_pipeline`，而不是父流水线的流水线来源。
- 作用域为[环境](../environments/_index.md)的变量会解析为其无作用域的值，因为子流水线没有环境。

要避免此行为，请使用 [inputs](../inputs/_index.md) 和 `$[[ inputs.name ]]` 插值，而不是 CI/CD 变量。插值会在配置处理之前解析。

<a id="ref-is-ambiguous"></a>

## `Ref is ambiguous`

当存在同名分支时，您无法使用标签触发多项目流水线。下游流水线创建失败，并显示错误：`downstream pipeline can not be created, Ref is ambiguous`。

请仅使用与分支名称不匹配的标签名称触发多项目流水线。

<a id="trigger-job-fails-with-data-integrity-failure"></a>

## 触发作业失败并显示 `data integrity failure`

此错误表示作业处理期间发生了意外异常。有关原因和解决步骤，请参见[错误：`data integrity failure`](../jobs/job_troubleshooting.md#error-data-integrity-failure)。

<a id="403-forbidden-error-when-downloading-a-job-artifact-from-an-upstream-pipeline"></a>

## 从上游流水线下载作业产物时出现 `403 Forbidden` 错误

CI/CD 作业令牌的作用域限定为流水线运行所在的项目。因此，默认情况下，下游流水线中的作业令牌不能用于访问上游项目。

要解决此问题，请[将下游项目添加到作业令牌作用域允许名单](../jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)。

<a id="error-needsneed-pipeline-should-be-a-string"></a>

## 错误：`needs:need pipeline should be a string`

将 [`needs:pipeline:job`](../yaml/_index.md#needspipelinejob) 与动态子流水线一起使用时，您可能会收到此错误：

```plaintext
Unable to run pipeline
- jobs:<job_name>:needs:need pipeline should be a string
```

当流水线 ID 被解析为整数而不是字符串时，会发生此错误。要修复此问题，请将流水线 ID 用引号括起来：

```yaml
rspec:
  needs:
    - pipeline: "$UPSTREAM_PIPELINE_ID"
      job: dependency-job
      artifacts: true
```
