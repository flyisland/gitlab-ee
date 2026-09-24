---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Runners
description: Configuration and job execution.
---

Runners 是运行 [极狐GitLab Runner](https://gitlab.cn/docs/runner/) 应用程序以在流水线中执行极狐GitLab CI/CD 任务的代理。它们负责运行你在 `.gitlab-ci.yml` 文件中定义的构建、测试、部署以及其他 CI/CD 任务。

<a id="runner-execution-flow"></a>

## Runner 执行流程

以下是 runner 如何工作的基本流程：

1. 一个 runner 必须先向极狐GitLab [注册](https://gitlab.cn/docs/runner/register/)，从而建立 runner 与极狐GitLab 之间的持久连接。
1. 当流水线被触发时，极狐GitLab 将任务提供给已注册的 runner。
1. 匹配的 runner 领取任务，每个 runner 一次领取一个任务，并执行它们。
1. 结果会实时返回给极狐GitLab。

更多信息，请参见 [Runner 执行流程](https://gitlab.cn/docs/runner/#runner-execution-flow)。

<a id="runner-job-scheduling-and-execution"></a>

## Runner 任务调度与执行

当一个 CI/CD 任务需要执行时，极狐GitLab 根据 `.gitlab-ci.yml` 文件中定义的任务创建一个任务。任务被放入队列中。极狐GitLab 检查可用的 runner 并匹配：

- Runner 标签
- Runner 类型（如共享或群组）
- Runner 状态与容量
- 所需能力

被分配的 runner 接收到任务详情。runner 准备环境并按照 `.gitlab-ci.yml` 文件中的规定运行任务的命令。

<a id="runner-categories"></a>

## Runner 分类

在决定使用哪些 runner 来执行你的 CI/CD 任务时，你可以选择：

- 适用于 JihuLab.com 用户的 [极狐GitLab 托管的 runner](hosted_runners/_index.md)。
- 适用于所有极狐GitLab 安装的 [私有化部署的 runner](https://gitlab.cn/docs/runner/)。

Runners 可以是群组、项目或实例 runner。极狐GitLab 托管的 runner 是实例 runner。

<a id="gitlab-hosted-runners"></a>

### 极狐GitLab 托管的 runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

极狐GitLab 托管的 runner 具有以下特点：

- 由极狐GitLab 全权管理。
- 无需安装即可立即可用。
- 每次任务运行在全新的虚拟机上。
- 提供 Linux、Windows 和 macOS 选项。
- 根据需求自动扩缩容。

在以下情况下选择极狐GitLab 托管的 runner：

- 你想要零维护的 CI/CD。
- 你需要快速设置，无需管理基础设施。
- 你的任务需要每次运行环境隔离。
- 你使用标准构建环境。
- 你正在使用 JihuLab.com。

<a id="self-managed-runners"></a>

### 私有化部署的 runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

私有化部署的 runner 具有以下特点：

- 由你安装和管理。
- 运行在你自己的基础设施上。
- 可根据你的需求进行定制。
- 支持多种执行器（包括 Shell、Docker 和 Kubernetes）。
- 可以被共享，也可以指定给特定的项目或群组。

在以下情况下选择私有化部署的 runner：

- 你需要自定义配置。
- 你想在私有网络中运行任务。
- 你需要特定的安全控制。
- 你需要项目或群组级别的 runner。
- 你需要通过 runner 重用优化速度。
- 你想管理自己的基础设施。

<a id="related-topics"></a>

## 相关主题

- [安装极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)
- [配置极狐GitLab Runner](https://gitlab.cn/docs/runner/configuration/)
- [管理极狐GitLab Runner](https://gitlab.cn/docs/runner/)