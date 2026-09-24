---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查作业产物问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [作业产物](job_artifacts.md) 时，可能会遇到以下问题。

<a id="job-does-not-retrieve-certain-artifacts"></a>

## 作业无法获取某些产物

默认情况下，作业会从先前阶段获取所有产物，但使用 `dependencies` 或 `needs` 的作业默认不会从所有作业获取产物。

如果使用这些关键字，产物只会从一部分作业中获取。请查看以下关键字参考，了解如何使用这些关键字获取产物：

- [`dependencies`](../yaml/_index.md#dependencies)
- [`needs`](../yaml/_index.md#needs)
- [`needs:artifacts`](../yaml/_index.md#needsartifacts)

<a id="job-artifacts-use-too-much-disk-space"></a>

## 作业产物占用过多磁盘空间

如果作业产物占用过多磁盘空间，请参阅
[作业产物管理文档](../../administration/cicd/job_artifacts_troubleshooting.md#job-artifacts-using-too-much-disk-space)。

<a id="error-message-no-files-to-upload"></a>

## 错误消息 `没有要上传的文件`

当 runner 找不到要上传的文件时，作业日志中会出现此消息。这可能是由于文件路径不正确，或文件未创建。您可以检查作业日志中的其他错误或警告，了解指定文件名及其未能生成的原因。

要获取更详细的作业日志，您可以[启用 CI/CD 调试日志](../variables/variables_troubleshooting.md#enable-debug-logging) 并再次运行作业。该日志可能会提供更多关于文件未创建原因的信息。

<a id="error-message-fatal-invalid-argument-when-uploading-a-dotenv-artifact-on-a-windows-runner"></a>

## 在 Windows runner 上上传 dotenv 产物时出现错误消息 `FATAL: invalid argument`

PowerShell 的 `echo` 命令会以 UCS-2 LE BOM（字节顺序标记）编码写入文件，但仅支持 UTF-8。如果尝试使用 `echo` 创建 [`dotenv`](../yaml/artifacts_reports.md) 产物，则会导致 `FATAL: invalid argument` 错误。

请改用 PowerShell 的 `Add-Content`，该命令使用 UTF-8 编码：

```yaml
test-job:
  stage: test
  tags:
    - windows
  script:
    - echo "test job"
    - Add-Content -Path build.env -Value "MY_ENV_VAR=true"
  artifacts:
    reports:
      dotenv: build.env
```

<a id="job-artifacts-do-not-expire"></a>

## 作业产物不会过期

如果某些作业产物未按预期过期，请检查是否启用了 [**保留最近成功作业的产物**](job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs) 设置。

启用此设置后，每个引用最新成功流水线的作业产物不会过期，也不会被删除。

<a id="error-message-this-job-could-not-start-because-it-could-not-retrieve-the-needed-artifacts"></a>

## 错误消息 `此作业无法启动，因为无法获取所需的产物。`

如果作业无法获取所需的产物，则会启动失败并返回此错误消息。以下情况下会返回此错误：

- 找不到作业的依赖项。默认情况下，后续阶段的作业会从所有先前阶段的作业获取产物，因此所有先前阶段的作业都被视为依赖项。如果作业使用了 [`dependencies`](../yaml/_index.md#dependencies) 关键字，则只有列出的作业是依赖项。
- 产物已过期。您可以通过 [`artifacts:expire_in`](../yaml/_index.md#artifactsexpire_in) 设置更长的过期时间。
- 由于权限不足，作业无法访问相关资源。

如果作业使用了 [`needs:artifacts`](../yaml/_index.md#needsartifacts) 关键字，请参阅以下其他排查步骤：

- [`needs:project`](#for-a-job-configured-with-needsproject)
- [`needs:pipeline:job`](#for-a-job-configured-with-needspipelinejob)

<a id="for-a-job-configured-with-needsproject"></a>

### 针对使用 `needs:project` 配置的作业

`could not retrieve the needed artifacts.` 错误可能会发生在使用 [`needs:project`](../yaml/_index.md#needsproject) 的作业上，配置类似如下：

```yaml
rspec:
  needs:
    - project: my-group/my-project
      job: dependency-job
      ref: master
      artifacts: true
```

要排查此错误，请验证：

- 项目 `my-group/my-project` 位于具有专业版订阅计划的群组中。
- 运行作业的用户可以访问 `my-group/my-project` 中的资源。
- `project`、`job` 和 `ref` 的组合存在，并产生所需的依赖关系。
- 使用的任何变量计算结果均为正确的值。

如果使用 `CI_JOB_TOKEN`，请将该令牌添加到项目的 [允许列表](ci_job_token.md#control-job-token-access-to-your-project) 中，以从其他项目拉取产物。

<a id="for-a-job-configured-with-needspipelinejob"></a>

### 针对使用 `needs:pipeline:job` 配置的作业

`could not retrieve the needed artifacts.` 错误可能会发生在使用 [`needs:pipeline:job`](../yaml/_index.md#needspipelinejob) 的作业上，配置类似如下：

```yaml
rspec:
  needs:
    - pipeline: $UPSTREAM_PIPELINE_ID
      job: dependency-job
      artifacts: true
```

要排查此错误，请验证：

- `$UPSTREAM_PIPELINE_ID` CI/CD 变量在当前流水线的父子流水线层级中可用。
- `pipeline` 和 `job` 的组合存在，并解析到一个已存在的流水线。
- `dependency-job` 已运行并成功完成。

<a id="jobs-show-unlockpipelinesinqueueworker-after-an-upgrade"></a>

## 升级后作业显示 `UnlockPipelinesInQueueWorker`

作业可能会停滞并显示一条错误，指出 `UnlockPipelinesInQueueWorker`。

此问题发生在升级后。

变通方法是启用 `ci_unlock_pipelines_extra_low` 功能标志。要切换功能标志，您必须是管理员。

在 JihuLab.com 上：

- 运行以下 [ChatOps](../chatops/_index.md) 命令：

  ```ruby
  /chatops gitlab run feature set ci_unlock_pipelines_extra_low true
  ```

在私有化部署实例上：

- [启用功能标志](../../administration/feature_flags/_index.md)，名称为 `ci_unlock_pipelines_extra_low`。

更多信息请参见 [合并请求 140318](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/140318#note_1718600424) 中的评论。

