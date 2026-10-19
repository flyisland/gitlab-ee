---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Runner
description: 配置与作业执行。
---

Runner 是运行[极狐GitLab Runner](https://gitlab.cn/docs/runner/) 应用程序的代理，用于在流水线中执行极狐GitLab CI/CD 作业。
它们负责运行您在 `.gitlab-ci.yml` 文件中定义的构建、测试、部署及其他 CI/CD 任务。

<a id="runner-execution-flow"></a>

## Runner 执行流程

以下是 Runner 工作原理的基本流程：

1. Runner 必须先在极狐GitLab 中[注册](https://gitlab.cn/docs/runner/register/)，
   这会在 Runner 与极狐GitLab 之间建立持久连接。
1. 当流水线被触发时，极狐GitLab 会将作业提供给已注册的 Runner。
1. 匹配的 Runner 会获取作业，每个 Runner 一次获取一个作业并执行。
1. 结果会实时报告回极狐GitLab。

更多信息，请参见 [Runner 执行流程](https://gitlab.cn/docs/runner/#runner-execution-flow)。

<a id="runner-job-scheduling-and-execution"></a>

## Runner 作业调度与执行

当需要执行 CI/CD 作业时，极狐GitLab 会根据 `.gitlab-ci.yml` 文件中定义的任务创建作业。这些作业会被放入队列。极狐GitLab 会检查是否有符合以下条件的可用 Runner：

- [Runner 标签](../yaml/_index.md#tags)。
- Runner 类型（如共享或群组）
- Runner 状态和容量
- 所需能力

被分配的 Runner 会收到作业详情。Runner 会准备环境，并按照 `.gitlab-ci.yml` 文件中的指定运行作业命令。

<a id="runner-categories"></a>

## Runner 类别

在决定使用哪些 Runner 来执行 CI/CD 作业时，您可以选择：

- [极狐GitLab 托管的 Runner](hosted_runners/_index.md)，适用于 JihuLab.com 用户。
- [私有化部署的 Runner](https://gitlab.cn/docs/runner/)，适用于所有极狐GitLab 安装实例。

Runner 可以是群组、项目或实例 Runner。极狐GitLab 托管的 Runner 属于实例 Runner。

<a id="gitlab-hosted-runners"></a>

### 极狐GitLab 托管的 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

极狐GitLab 托管的 Runner：

- 由极狐GitLab 全权管理。
- 无需设置即可立即使用。
- 每个作业都在全新的虚拟机上运行。
- 包含 Linux、Windows 和 macOS 选项。
- 根据需求自动扩缩。

在以下情况下选择极狐GitLab 托管的 Runner：

- 您希望实现零维护的 CI/CD。
- 您需要快速设置，无需管理基础设施。
- 您的作业需要在各次运行之间保持隔离。
- 您使用的是标准构建环境。
- 您使用的是 JihuLab.com。

<a id="self-managed-runners"></a>

### 私有化部署的 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

私有化部署的 Runner：

- 由您自行安装和管理。
- 在您自己的基础设施上运行。
- 可根据您的需求进行自定义。
- 支持多种执行器（包括 Shell、Docker 和 Kubernetes）。
- 可以共享，也可以指定给特定项目或群组。

在以下情况下选择私有化部署的 Runner：

- 您需要自定义配置。
- 您希望在私有网络中运行作业。
- 您需要特定的安全控制。
- 您需要项目或群组 Runner。
- 您需要通过复用 Runner 来优化速度。
- 您希望管理自己的基础设施。
