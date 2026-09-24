---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Track and compare performance, memory, and custom metrics.
title: 指标报告
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

指标报告在合并请求中显示自定义指标，用于跟踪性能、内存使用情况以及分支之间的其他测量值。

使用指标报告可以：

- 监控内存使用变化。
- 跟踪负载测试结果。
- 测量代码复杂度。
- 比较代码覆盖率统计信息。

<a id="metrics-processing-workflow"></a>

## 指标处理工作流

当流水线运行时，极狐GitLab 从报告产物中读取指标，并将其存储为字符串值以供比较。默认文件名为 `metrics.txt`。

对于合并请求，极狐GitLab 将特性分支的指标与目标分支的值进行比较，并按以下顺序在合并请求小部件中显示：

- 值发生变化的现有指标。
- 合并请求新增的指标（带有 **新增** 标记）。
- 合并请求移除的指标（带有 **已移除** 标记）。
- 值未变化的现有指标。

<a id="baseline-pipeline-selection"></a>

### 基线流水线选择

为了比较分支之间的指标，极狐GitLab 通过以下过程在目标分支上确定基线流水线：

1. 按顺序检查目标分支上匹配以下提交 SHA 的流水线：
   1. 创建[合并请求流水线](../pipelines/merge_request_pipelines.md)时的目标分支顶端。
      此 SHA 仅适用于合并请求流水线。
   1. 合并基础提交（源分支和目标分支的共同祖先）。
   1. 合并请求差异的起始提交。
1. 为第一个具有匹配流水线的 SHA 选择最近创建的流水线（按流水线 ID）。

基线流水线选择：

- 不过滤流水线状态。
  任何状态（`success`、`failed`、`canceled` 或 `skipped`）的流水线都可以被选为基线。
- 不检查基线流水线是否有指标报告产物。
  如果基线流水线存在但没有指标产物，则特性分支中的所有指标都会显示为新增。

指标比较小部件仅在特性分支流水线处于已完成状态且具有指标报告产物时出现。

流水线类型会影响首先匹配哪个提交 SHA：

- 合并请求流水线：目标分支顶端 SHA 通常可用，因此基线通常是创建合并请求流水线时目标分支顶端的最新流水线。
- 分支流水线：目标分支顶端 SHA 不可用，因此改用合并基础提交。基线是目标分支上共同祖先提交处的最新流水线。

为确保始终有基线可供比较：

- 在目标分支上运行产生指标报告产物的流水线。
- 如果使用分支流水线，请确保合并基础提交在目标分支上有流水线。

<a id="configure-metrics-reports"></a>

## 配置指标报告

将指标报告添加到 CI/CD 流水线中，以在合并请求中跟踪自定义指标。

前提条件：

- 指标文件必须使用 [OpenMetrics](https://prometheus.io/docs/instrumenting/exposition_formats/#openmetrics-text-format) 文本格式。

要配置指标报告：

1. 在 `.gitlab-ci.yml` 文件中，添加一个生成指标报告的作业。
1. 在作业中添加一个脚本，以 OpenMetrics 格式生成指标。
1. 配置作业，使用 [`artifacts:reports:metrics`](../yaml/artifacts_reports.md#artifactsreportsmetrics) 上传指标文件。

例如：

```yaml
metrics:
  stage: test
  script:
    - echo 'memory_usage_bytes 2621440' > metrics.txt
    - echo 'response_time_seconds 0.234' >> metrics.txt
    - echo 'test_coverage_percent 87.5' >> metrics.txt
    - echo '# EOF' >> metrics.txt
  artifacts:
    reports:
      metrics: metrics.txt
```

流水线运行后，指标报告会显示在合并请求小部件中。

![合并请求中的指标报告小部件，显示指标名称和值。](img/metrics_report_v18_3.png)

有关其他格式规范和示例，请参阅
[Prometheus 文本格式详情](https://prometheus.io/docs/instrumenting/exposition_formats/#text-format-details)。

<a id="troubleshooting"></a>

## 故障排除

在使用指标报告时，您可能会遇到以下问题。

<a id="metrics-reports-did-not-change"></a>

### 指标报告未更改

在合并请求中查看指标报告时，您可能会看到 **指标报告扫描未检测到新更改**。

此问题发生在以下情况：

- 目标分支没有用于比较的基线指标报告。
- 您的极狐GitLab 订阅不包含指标报告（需要专业版或旗舰版）。

要解决此问题：

1. 确认您的极狐GitLab 订阅级别包含指标报告。
1. 确保目标分支有配置了指标报告的流水线。
   为确保有一个可用，请在目标分支上运行产生指标报告产物的流水线。
1. 验证您的指标文件使用了有效的 OpenMetrics 格式。