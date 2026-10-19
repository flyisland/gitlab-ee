---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 跟踪并比较性能、内存和自定义指标。
title: 指标报告
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

指标报告会在合并请求中显示自定义指标，以跟踪分支之间的性能、内存用量和其他测量值。

使用指标报告可以：

- 监控内存用量变化。
- 跟踪负载测试结果。
- 衡量代码复杂度。
- 比较代码覆盖率统计信息。

<a id="metrics-processing-workflow"></a>

## 指标处理工作流

当流水线运行时，极狐GitLab 会从报告产物中读取指标，并将其存储为字符串值以便比较。默认文件名为 `metrics.txt`。

对于合并请求，极狐GitLab 会将源分支的指标与目标分支上[基线流水线](_index.md#baseline-pipeline-selection)的值进行比较。合并请求小部件按以下顺序显示指标：

- 值已更改的现有指标。
- 由合并请求添加的指标（带有 **新增** 标记）。
- 由合并请求移除的指标（带有 **已删除** 标记）。
- 值未更改的现有指标。

如果基线流水线没有指标报告产物，则源分支的所有指标都会显示为新指标。仅当源分支流水线处于已完成状态且具有指标报告产物时，才会显示指标比较小部件。

<a id="configure-metrics-reports"></a>

## 配置指标报告

将指标报告添加到您的 CI/CD 流水线，以在合并请求中跟踪自定义指标。

先决条件：

- 指标文件必须使用 [OpenMetrics](https://prometheus.io/docs/instrumenting/exposition_formats/#openmetrics-text-format) 文本格式。

要配置指标报告：

1. 在您的 `.gitlab-ci.yml` 文件中，添加一个生成指标报告的作业。
1. 向该作业添加一个脚本，用于生成 OpenMetrics 格式的指标。
1. 配置该作业，使用 [`artifacts:reports:metrics`](../yaml/artifacts_reports.md#artifactsreportsmetrics) 上传指标文件。

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

![合并请求中显示指标名称和值的指标报告小部件。](img/metrics_report_v18_3.png)

有关其他格式规范和示例，请参阅
[Prometheus 文本格式详细信息](https://prometheus.io/docs/instrumenting/exposition_formats/#text-format-details)。

<a id="troubleshooting"></a>

## 故障排除

使用指标报告时，您可能会遇到以下问题。

<a id="metrics-reports-did-not-change"></a>

### 指标报告没有变化

在合并请求中查看指标报告时，您可能会看到 **指标报告扫描未检测到新变更**。

出现此问题的原因包括：

- 目标分支没有可用于比较的基线指标报告。
- 您的极狐GitLab 订阅不包含指标报告（需要专业版或旗舰版）。

要解决此问题：

1. 确认您的极狐GitLab 订阅层级包含指标报告。
1. 确保目标分支有一个配置了指标报告的流水线。
   为确保有可用的流水线，请在目标分支上运行可生成指标报告产物的流水线。
1. 确认您的指标文件使用有效的 OpenMetrics 格式。
