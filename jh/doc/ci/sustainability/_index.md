---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Measure and reduce the carbon footprint of your CI/CD pipelines with sustainability tools.
title: 流水线可持续性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 本页面介绍的可持续性工具均为第三方集成。
> 极狐GitLab 不维护或支持这些工具，
> 也不保证这些工具符合任何法规或合规要求。

CI/CD 流水线会消耗计算资源并产生碳排放。
你可以集成第三方工具来测量和减少软件开发工作流中的范围 3 排放，
以用于可持续性报告和合规性。

范围 3 排放是指来自供应链和供应商的间接排放，
包括运行你的 CI/CD 流水线的云基础设施。

将可持续性工具集成到流水线中可以带来以下好处：

- 追踪和报告 CI/CD 基础设施的碳排放。
- 识别资源密集型作业和优化机会。
- 基于数据决策 Runner 选择和作业调度。
- 满足可持续性目标和法规要求。

<a id="emission-measurement"></a>

## 排放测量

CI/CD 流水线的排放来自执行作业所消耗的计算资源。
碳足迹取决于 CPU 利用率、内存使用和执行时间带来的能耗。
此外，它还受碳强度的影响，
碳强度表示每单位电力的碳排放量，会因地区和时间而异。
云提供商、数据中心位置、硬件效率等基础设施因素也会影响总体影响。

可持续性工具使用不同的方法来计算排放：

- 估算模型基于 CPU 使用模式和预设的功耗曲线计算能耗。
- 实际测量使用云提供商 API 获取真实的资源消耗数据。
- 碳强度查询会调用 [Electricity Maps](https://app.electricitymaps.com/dashboard) 等服务，以应用区域碳因子和基于时间的变化。

<a id="measure-emissions-with-eco-ci"></a>

## 使用 Eco CI 测量排放

Eco CI 可测量 CI/CD 流水线的能耗和碳排放。
它作为轻量级 bash 脚本在流水线作业内运行，无需独立的服务器或数据库。

有关更多信息，请参阅 [Eco CI](eco_ci.md)。

<a id="best-practices"></a>

## 最佳实践

请考虑以下策略来减少 CI/CD 流水线的碳足迹。

<a id="optimize-job-execution"></a>

### 优化作业执行

优化作业执行的方法：

- 使用缓存避免重复工作。
- 不要在多个作业的开始阶段进行资源密集型构建，而是在一个早期作业中执行一次构建，
  然后将输出作为产物与后续所有需要它的作业共享。
- 设置适当的超时值以防止作业失控。
- 使用更小的 Docker 镜像以减少下载和启动时间。

<a id="choose-efficient-runners"></a>

### 选择高效的 Runner

选择高效 Runner 的方法：

- 选择与工作负载要求匹配的 Runner 实例类型。
- 避免为简单作业过度分配资源。
- 考虑对非关键工作负载使用竞价实例。
- 使用自动扩缩容使容量与需求匹配。

<a id="schedule-strategically"></a>

### 战略性调度

战略性调度的方法：

- 尽可能将资源密集型流水线安排在非高峰时段运行。
- 对于非紧急流水线，考虑碳感知调度。
- 将相似的作业批量处理以改善资源利用率。

<a id="monitor-and-iterate"></a>

### 监控与迭代

在可持续性工作上监控与迭代的方法：

- 为你的流水线建立基准指标。
- 设定减排目标。
- 定期审查高影响作业以寻找优化机会。
- 与团队共享可持续性指标。

