---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: Monitor application performance and troubleshoot performance issues.
ignore_in_report: true
title: 显示可观测性的 CI/CD 流水线遥测
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Experiment

{{< /details >}}

当启用后，极狐GitLab Observability 会自动检测您的 CI/CD 流水线，提供流水线性能、作业持续时间和执行流程的可视性，无需更改任何代码。

- 了解哪些作业拖延了您的流水线。
- 流水线性能随时间的变化。
- 部署流程中的瓶颈。

<a id="enable-pipeline-instrumentation"></a>

## 启用流水线检测

要启用自动流水线检测，请将 `GITLAB_OBSERVABILITY_EXPORT` CI/CD 变量添加到您的项目或群组中：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 选择 **添加变量**。
1. 配置变量：
   - **键**：`GITLAB_OBSERVABILITY_EXPORT`
   - **值**：`traces`、`metrics`、`logs` 中的一个或多个（多个值用逗号分隔）
   - **类型**：变量
   - **环境范围**：全部（或特定环境）
1. 选择 **添加变量**。

<a id="instrumentation-types"></a>

## 检测类型

`GITLAB_OBSERVABILITY_EXPORT` 变量接受以下值：

- `traces`：导出分布式追踪，显示流水线执行流、作业依赖关系和计时
- `metrics`：导出关于流水线持续时间、作业成功率和资源使用情况的指标
- `logs`：导出来自流水线执行的结构化日志

您可以通过用逗号分隔来启用多个类型：

```plaintext
traces,metrics,logs
```

<a id="how-it-works"></a>

## 工作原理

设置变量后，极狐GitLab 会自动：

1. 在每个流水线完成后捕获流水线执行数据
1. 根据您的配置将数据转换为 OpenTelemetry 格式
1. 将遥测数据导出到您的极狐GitLab Observability 实例
1. 使数据在您的可观测性仪表板中可用

无需对 `.gitlab-ci.yml` 文件进行任何更改。检测在后台自动进行。

<a id="view-pipeline-telemetry"></a>

## 查看流水线遥测

启用检测后运行流水线：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **可观测性** > **服务**。
1. 选择您的 `gitlab-ci` 服务以查看来自流水线执行的追踪、指标和日志。

来自 [极狐GitLab Observability 模板](https://jihulab.com/gitlab-cn/embody-team/experimental-observability/o11y-templates/) 的 CI/CD 仪表板模板为流水线性能分析提供了预构建的可视化。

<a id="related-topics"></a>

## 相关主题

- [排查可观测性问题](troubleshooting.md)