---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Calculations, quotas, purchase information.
title: 计算分钟
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 重命名 “CI/CD minutes” 为 “计算配额” 或 “计算分钟” 在极狐GitLab 16.1。

{{< /history >}}

项目运行 CI/CD 作业对实例 runner 的使用以计算分钟来衡量。

对于某些安装类型，您的 [命名空间](../../user/namespace/_index.md) 具有 [计算配额](instance_runner_compute_minutes.md#compute-quota-enforcement)，它限制了您可以使用的计算分钟。

计算配额可应用于所有 [管理员管理的实例 runner](instance_runner_compute_minutes.md)：
- 所有 JihuLab.com 或 私有化部署 上的实例 runner

计算配额默认处于禁用状态，但可以针对顶级群组和用户命名空间启用。
在 JihuLab.com 上，配额默认启用以限制基础版命名空间的使用。如果购买了付费订阅，则限制会增加。

<a id="instance-runners"></a>

## 实例 runner

对于 JihuLab.com 和 私有化部署 的实例 runner：
- 您可以在 [实例 runner 用量仪表板](instance_runner_compute_minutes.md#view-usage) 中查看用量。
- 启用配额时：
  - 在接近配额限制时您会收到通知。
  - 超出配额时会应用执行措施。

对于 JihuLab.com：
- 基础月度计算配额由您的订阅层级决定。
- 如果需要，您可以 [购买额外的计算分钟](../../subscriptions/gitlab_com/compute_minutes.md)。

<a id="compute-minute-usage"></a>

## 计算分钟用量

<a id="compute-usage-calculation"></a>

### 计算用量计算

每个作业的计算分钟用量使用以下公式计算：

```plaintext
Job duration / 60 * Cost factor
```

- **作业持续时间**：作业运行的时间（秒），不包括处于 `created` 或 `pending` 状态的时间。
- **成本因子**：基于 [runner 类型](#cost-factors) 和 [项目类型](#cost-factors) 的数字。

该值将转换为计算分钟，并添加到作业所在顶级命名空间的已用单位计数中。

例如，如果用户 `alice` 运行一个流水线：
- 在 `gitlab-org` 命名空间中的项目中，流水线中每个作业使用的计算分钟将添加到 `gitlab-org` 命名空间的总体用量中，而不是 `alice` 命名空间。
- 在 `alice` 命名空间的个人项目中，计算分钟将添加到其命名空间的总体用量中。

一个流水线使用的计算量是流水线中运行的所有作业使用的总计算分钟。作业可以并发运行，因此总计算用量可能高于流水线的端到端持续时间。

[触发作业](../yaml/_index.md#trigger) 不在 runner 上执行，因此它们不消耗计算分钟，即使使用 [`strategy:depend`](../yaml/_index.md#triggerstrategy) 等待 [下游流水线](downstream_pipelines.md) 状态。触发的下游流水线与其他流水线一样消耗计算分钟。

用量按月跟踪。在每个月的第一天，所有命名空间的当月用量为 `0`。

<a id="cost-factors"></a>

### 成本因子

计算分钟的消耗速率根据 runner 类型和项目设置而有所不同。

<a id="cost-factors-of-hosted-runners-for-gitlabcom"></a>

#### JihuLab.com 的托管 runner 的成本因子

极狐GitLab 托管的 runner 根据 runner 类型（Linux、Windows、macOS）和虚拟机配置具有不同的成本因子：

| Runner 类型                | 机器大小           | 成本因子             |
|:---------------------------|:-----------------------|:------------------------|
| Linux x86-64（默认）     | `小型`                | `1`                     |
| Linux x86-64               | `中型`               | `2`                     |
| Linux x86-64               | `大型`                | `3`                     |
| Linux x86-64               | `超大型`               | `6`                     |
| Linux x86-64               | `2x 超大型`              | `12`                    |
| Linux x86-64 + GPU 启用 | `中型`，GPU 标准 | `7`                     |
| Linux Arm64                | `小型`                | `1`                     |
| Linux Arm64                | `中型`               | `2`                     |
| Linux Arm64                | `大型`                | `3`                     |
| macOS M1                   | `中型`               | `6` （**状态**：测试版）  |
| macOS M2 Pro               | `大型`                | `12` （**状态**：测试版） |
| Windows                    | `中型`               | `1` （**状态**：测试版）  |

这些成本因子适用于 JihuLab.com 的托管 runner。

根据项目类型，适用某些折扣：

| 项目类型 | 成本因子 | 使用的计算分钟 |
|--------------|-------------|---------------------|
| 标准项目 | [基于 runner 类型](#cost-factors-of-hosted-runners-for-gitlabcom) | 每 (作业持续时间 / 60 × 成本因子) 使用 1 分钟 |
| [极狐GitLab 开源项目](../../subscriptions/community_programs.md#gitlab-for-open-source) 中的公共项目 | `0.5` | 每 2 分钟作业时间使用 1 分钟 |
| [极狐GitLab 开源项目](../../subscriptions/community_programs.md#gitlab-for-open-source) 的公共分支 | `0.008` | 每 125 分钟作业时间使用 1 分钟 |
| [社区对 极狐GitLab 项目的贡献](#community-contributions-to-gitlab-projects) | 动态折扣 | 请参阅下一部分 |

<a id="community-contributions-to-gitlab-projects"></a>

#### 社区对 极狐GitLab 项目的贡献

社区贡献者在为极狐GitLab 维护的开源项目做贡献时，最多可使用 300,000 分钟的实例 runner 时间。仅在对极狐GitLab 产品中的项目进行贡献时，才有可能达到最大 300,000 分钟。

实例 runner 可用的总分钟数会减去其他项目流水线使用的计算分钟。300,000 分钟适用于所有 JihuLab.com 层级。

成本因子计算方法为：

`月计算配额 / 300,000 作业持续时间分钟 = 成本因子`

例如，在专业版层级中月计算配额为 10,000：
- 10,000 / 300,000 = 0.03333333333 成本因子。

对于此降低的成本因子：
- 合并请求源项目必须是极狐GitLab 维护的项目的一个分支，例如 [`gitlab-com/www-gitlab-com`](https://gitlab.com/gitlab-com/www-gitlab-com) 或 [`gitlab-org/gitlab`](https://jihulab.com/gitlab-cn/gitlab)。
- 合并请求目标项目必须是分支的父项目。
- 流水线必须是合并请求、合并结果或合并火车流水线。

<a id="reduce-compute-minute-usage"></a>

### 减少计算分钟用量

如果您的项目消耗的计算分钟过多，请尝试以下策略来减少用量：

- 如果您使用项目镜像，请确保 [镜像更新触发的流水线](../../user/project/repository/mirror/pull.md#trigger-pipelines-for-mirror-updates) 已禁用。
- 降低 [定时流水线](schedules.md) 的频率。
- 在不需要时 [跳过流水线](_index.md#skip-a-pipeline)。
- 使用 [可中断](../yaml/_index.md#interruptible) 作业，当新流水线启动时，这些作业可以自动取消。
- 如果某个作业不需要在每个流水线中运行，请使用 [`rules`](../jobs/job_control.md) 使其仅在需要时运行。
- 为某些作业 [使用私有 runner](../runners/runners_scope.md#group-runners)。
- 如果您从分支进行工作并向父项目提交合并请求，您可以请求维护者在 [父项目中运行流水线](merge_request_pipelines.md#run-pipelines-in-the-parent-project)。

如果您管理一个开源项目，这些改进还可以减少贡献者分支项目的计算分钟用量，从而促成更多贡献。

更多详情，请参阅 [流水线效率指南](pipeline_efficiency.md)。
