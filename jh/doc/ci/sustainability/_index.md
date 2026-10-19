---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 衡量、分析并减少您的流水线和基础设施产生的碳排放。
title: CI/CD 可持续性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 本页介绍的可持续性工具均为第三方集成。
> 极狐GitLab 不维护也不为这些工具提供支持，
> 且不表示这些工具满足任何监管或合规要求。

您可以集成第三方工具，以衡量、分析并减少您的流水线和基础设施产生的碳排放。

合适的工具取决于您想要衡量的对象：

- 要衡量 CI/CD 流水线作业产生的排放，请使用 [Eco CI](eco_ci.md)。
- 要衡量虚拟机、Pod 或应用工作负载产生的排放，请使用 [Carmen](carmen.md)。

<a id="eco-ci"></a>

## Eco CI

Eco CI 衡量 CI/CD 流水线的能耗和碳排放。它以轻量级 bash 脚本的形式在您的流水线作业中运行，无需单独的服务器或数据库。

使用 Eco CI 可以：

- 衡量 CI/CD 流水线作业的能耗和碳排放。
- 识别流水线中资源消耗较大的作业。
- 跟踪每次流水线运行的碳排放随时间的变化。
- 在项目 README 中显示碳排放徽章。

<a id="carmen"></a>

## Carmen

Carmen（Carbon Measurement Engine）是一款开源工具，用于衡量
虚拟机、Pod 和应用工作负载产生的碳排放。它基于
[Green Software Foundation Impact Framework](https://if.greensoftware.foundation/) 构建。

使用 Carmen 可以：

- 识别您的技术栈中哪些服务、虚拟机或 Pod 排放的 CO2 最多。
- 比较各组件并确定减排优先级。
- 将各组件的碳评分输入到您自己的 FinOps 仪表板或内部工具中。

请勿将 Carmen 用于：

- 企业或 ESG 报告。
- 新闻稿或营销材料。
- 合规或监管披露。

<a id="best-practices"></a>

## 最佳实践

以下策略有助于减少 CI/CD 工作流的碳排放。

<a id="optimize-job-execution"></a>

### 优化作业执行

要优化作业执行：

- 使用缓存避免重复工作。
- 在靠前的作业中一次性运行资源消耗较大的构建，然后将输出作为产物
  共享给后续需要它的作业。
- 设置适当的超时值，防止作业失控。
- 使用更小的 Docker 镜像，以减少下载和启动时间。

<a id="choose-efficient-runners"></a>

### 选择高效的 Runner

要选择高效的 Runner：

- 选择与您的工作负载需求相匹配的 Runner 实例类型。
- 避免为小型作业过度预配资源。
- 对非关键工作负载使用竞价实例。
- 使用自动扩缩以按需匹配容量。

<a id="schedule-strategically"></a>

### 合理安排调度

要合理安排调度：

- 将资源消耗较大的流水线安排在您的 CI 服务器所在区域可再生能源
  最充足时运行。查看 [Electricity Maps](https://app.electricitymaps.com/map/live/hourly)
  以找到最佳时间和区域。
  正午通常是较好的默认选择。
- 对非紧急的流水线考虑碳感知调度。
- 将相似的作业批量合并运行，以提高资源利用率。

<a id="monitor-and-iterate"></a>

### 监控并持续改进

要监控并持续改进您的可持续性工作：

- 为您的流水线建立基准指标。
- 设定减排目标。
- 定期检查高影响作业，寻找优化机会。
- 与您的团队分享可持续性指标。
