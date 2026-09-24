---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Agentic 破坏性变更解决任务流
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

Agentic 破坏性变更解决任务流会自动分析依赖升级合并请求上的流水线失败，并生成代码修复，以解决依赖更新引入的破坏性变更。

当依赖升级合并请求的流水线失败时，极狐GitLab Duo 会分析失败原因并尝试生成修复。该任务流会检查：

- 流水线错误日志，以确定失败的根本原因。
- 依赖变更日志和发布说明，以识别破坏性变更。
- 更新后依赖的代码使用模式，以确定需要更改的内容。

生成修复后，该任务流会将修复直接提交到依赖升级合并请求分支，并重新运行流水线。

结果基于 AI 分析，合并前应进行审阅。

<a id="prerequisites"></a>

## 先决条件

- 满足 [极狐GitLab Duo Agent Platform 的先决条件](../../_index.md#prerequisites)。
- 为[顶级群组](_index.md#turn-foundational-flows-on-or-off)开启 **允许内置任务流** 和 **解决依赖升级破坏性变更**。
- [配置推送规则以允许服务账号](../../troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
- 为您的项目[配置您自己的 Runner](../execution/_index.md)，或开启 [极狐GitLab 托管 Runner](../../../../ci/runners/hosted_runners/_index.md)。
- 为项目开启该功能。请参阅 [启用 Agentic 破坏性变更解决](../../../application_security/dependency_scanning/agentic-breaking-change-resolution.md#enable-agentic-breaking-change-resolution)。

<a id="run-the-agentic-breaking-change-resolution-flow"></a>

## 运行 Agentic 破坏性变更解决任务流

当自动修复 Agent 创建的依赖升级合并请求上的流水线失败，且项目已启用该功能时，该任务流会自动运行。

您也可以手动触发该任务流：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求**。
1. 选择带有失败流水线的依赖升级合并请求。
1. 在流水线小组件中，选择 **使用 Duo 解决破坏性变更**。

该任务流在后台运行。完成后，它会将任何生成的修复提交到合并请求分支，并重新运行流水线。
