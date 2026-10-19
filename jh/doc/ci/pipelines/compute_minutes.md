---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 计算、配额、购买信息。
title: 计算分钟
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

运行 CI/CD 作业的项目对实例 Runner 的使用量以计算分钟计量。

对于某些安装类型，您的[命名空间](../../user/namespace/_index.md)具有[计算配额](instance_runner_compute_minutes.md#compute-quota-enforcement)，该配额会限制您可以使用的计算分钟。

计算配额可应用于所有[管理员管理的实例 Runner](instance_runner_compute_minutes.md)：

- JihuLab.com 或极狐GitLab 私有化部署上的所有实例 Runner

计算配额默认处于禁用状态，但可以为顶级群组和用户命名空间启用。在 JihuLab.com 上，该配额默认启用，以限制基础版命名空间的使用量。如果购买了付费订阅，该限制会提高。

<a id="instance-runners"></a>

## 实例 Runner

对于 JihuLab.com 和极狐GitLab 私有化部署上的实例 Runner：

- 您可以在[实例 Runner 使用量仪表板](instance_runner_compute_minutes.md#view-usage)中查看使用量。
- 启用配额后：
  - 当接近配额限制时，您会收到通知。
  - 当超出配额时，会应用[强制执行措施](instance_runner_compute_minutes.md#enforcement)。

对于 JihuLab.com：

- 每月基础计算配额由您的订阅层级决定。
  基础版层级命名空间每月获得 400 计算分钟。
  付费层级获得更高的每月配额。
- 如果需要更多，您可以[购买额外的计算分钟](../../subscriptions/gitlab_com/compute_minutes.md)。

<a id="compute-usage-calculation"></a>

## 计算使用量计算

每个作业的计算分钟使用量使用以下公式计算：

```plaintext
Job duration / 60 * Cost factor
```

- 作业持续时间：作业运行所花费的时间（以秒为单位），不包括处于 `created` 或 `pending` 状态所花费的时间。
- 成本系数：基于 [Runner 类型](#cost-factors-of-hosted-runners-for-gitlabcom)和
  [项目类型](#project-type-discounts)的数字。

所得的计算分钟会添加到该作业顶级命名空间的使用量计数中。如果启用了计算配额，则会根据该配额来衡量此计数。

例如，如果用户 `alice` 运行一个流水线：

- 在 `gitlab-org` 命名空间中的项目里，流水线中每个作业使用的计算分钟
  会添加到 `gitlab-org` 命名空间的总体使用量中，而不是 `alice` 命名空间。
- 在其 `alice` 命名空间中的个人项目里，计算分钟会添加到
  其命名空间的总体使用量中。

一个流水线使用的计算量是该流水线中运行的所有作业使用的计算分钟总和。作业可以并发运行，因此总计算使用量可能高于一个流水线的端到端持续时间。

[触发作业](../yaml/_index.md#trigger)不在 Runner 上执行，因此它们不消耗计算分钟，即使使用 [`strategy:depend`](../yaml/_index.md#triggerstrategy) 等待[下游流水线](downstream_pipelines.md)状态时也是如此。被触发的下游流水线与其他流水线一样消耗计算分钟。

所有命名空间的使用量会在每月第一天重置为 `0`。如果启用了计算配额，该配额也会重置为其完整的每月分配量。在 JihuLab.com 上，[购买的计算分钟](../../subscriptions/gitlab_com/compute_minutes.md#monthly-rollover-of-purchased-compute-minutes)仅在每月配额用完后才会使用。如果未使用，它们会结转到下个月。

<a id="cost-factors"></a>

## 成本系数

成本系数是一个乘数，用于设定作业使用计算分钟的速度。它不是货币价格。该速率因 Runner 类型和项目设置而异。

<a id="cost-factors-of-hosted-runners-for-gitlabcom"></a>

### JihuLab.com 上托管 Runner 的成本系数

极狐GitLab 托管的 Runner 根据 Runner 类型
（Linux、Windows、macOS）和虚拟机配置具有不同的成本系数：

| Runner 类型                | 机器规格           | 成本系数             |
|:---------------------------|:-----------------------|:------------------------|
| Linux x86-64（默认）     | `small`                | `1`                     |
| Linux x86-64               | `medium`               | `2`                     |
| Linux x86-64               | `large`                | `3`                     |
| Linux x86-64               | `xlarge`               | `6`                     |
| Linux x86-64               | `2xlarge`              | `12`                    |
| Linux x86-64 + 启用 GPU | `medium`，GPU 标准 | `7`                     |
| Linux Arm64                | `small`                | `1`                     |
| Linux Arm64                | `medium`               | `2`                     |
| Linux Arm64                | `large`                | `3`                     |
| macOS M1                   | `medium`               | `6`（测试版）              |
| macOS M2 Pro               | `large`                | `12`（测试版）             |
| Windows                    | `medium`               | `1`（测试版）              |

这些成本系数适用于 JihuLab.com 的托管 Runner。

<a id="project-type-discounts"></a>

### 项目类型折扣

根据项目类型，会应用某些折扣：

| 项目类型 | 成本系数 | 使用的计算分钟 |
|--------------|-------------|---------------------|
| 标准项目 | 基于 Runner 类型 | 每（作业持续时间 / 60 × 成本系数）1 分钟 |
| [GitLab for Open Source](../../subscriptions/community_programs.md#gitlab-for-open-source) 计划中的公开项目 | `0.5` | 每 2 分钟作业时间 1 分钟 |
| GitLab for Open Source 计划中项目的公开复刻 | `0.008` | 每 125 分钟作业时间 1 分钟 |
| 社区贡献 | 动态折扣 | 请参阅以下部分 |

<a id="community-contributions"></a>

### 社区贡献

社区贡献者在为 GitLab 维护的开源项目做贡献时，可以在实例 Runner 上使用最多 300,000 分钟。只有在您专门为 GitLab 产品所属的项目做贡献时，才可能达到 300,000 分钟的上限。

实例 Runner 上可用的总分钟数会因其他项目的流水线所使用的计算分钟而减少。300,000 分钟适用于所有 JihuLab.com 层级。

成本系数计算方式为：

- `Monthly compute quota / 300,000 job duration minutes = Cost factor`

例如，在专业版中每月计算配额为 10,000 时：

- 10,000 / 300,000 = 0.03333333333 成本系数。

对于此降低后的成本系数：

- 合并请求源项目必须是 GitLab 维护项目的复刻，
  例如 [`gitlab-com/www-gitlab-com`](https://gitlab.com/gitlab-com/www-gitlab-com)，
  或 [`gitlab-org/gitlab`](https://jihulab.com/gitlab-cn/gitlab)。
- 合并请求目标项目必须是该复刻的父项目。
- 流水线必须是合并请求、合并结果或合并列车流水线。

<a id="reduce-compute-minute-usage"></a>

## 减少计算分钟使用量

如果您接近或超出计算配额，请尝试以下策略来减少使用量：

- 如果您使用项目镜像，请确保[镜像更新的流水线](../../user/project/repository/mirror/pull.md#trigger-pipelines-for-mirror-updates)
  已禁用。
- 降低[计划流水线](schedules.md)的频率。
- 在不需要时[跳过流水线](_index.md#skip-a-pipeline)。
- 使用[可中断](../yaml/_index.md#interruptible)作业，如果新的流水线启动，这些作业可以自动取消。
- 如果某个作业不必在每个流水线中运行，请使用 [`rules`](../jobs/job_control.md)
  使其仅在需要时运行。
- 为某些作业[使用私有 Runner](../runners/runners_scope.md#group-runners)。
- 如果您从复刻进行工作并向父项目提交合并请求，
  您可以请维护者[在父项目中](merge_request_pipelines.md#run-pipelines-in-the-parent-project)运行流水线。

如果您管理一个开源项目，这些改进还可以减少贡献者复刻项目的计算分钟使用量，从而支持更多贡献。

有关更多详细信息，请参阅[流水线效率指南](pipeline_efficiency.md)。
