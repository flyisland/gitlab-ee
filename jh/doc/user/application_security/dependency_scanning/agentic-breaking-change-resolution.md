---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Agentic 破坏性变更解决
description: 使用 AI 原生方式解决依赖升级合并请求中的问题。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Agentic 破坏性变更解决是一个需主动启用的内置任务流，它可以：

- 分析升级依赖的合并请求上失败的流水线。
- 生成修复方案，以解决依赖更新引入的破坏性变更。

> [!warning]
> 启用此功能后，受影响的合并请求中的流水线日志和代码上下文将发送给大语言模型（LLM）进行分析。在启用此功能前，请审查您组织的数据政策。

在此内置任务流中，极狐GitLab Duo 将：

- 检查流水线错误日志，以确定失败的根因。
- 分析依赖变更日志和发布说明，以识别破坏性变更。
- 审查已更新依赖项的代码使用模式。
- 生成代码修复，并直接提交到依赖升级合并请求分支。
- 应用修复后重新运行流水线。

结果基于 AI 分析，合并前应由开发者进行审查。

<a id="prerequisites"></a>

## 先决条件

- 您的项目或群组中已[启用极狐GitLab Duo](../../gitlab_duo/turn_on_off.md)。
- 已在您的用户偏好中[设置默认的极狐GitLab Duo 命名空间](../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 已为项目启用[依赖扫描自动修复](../remediate/auto_remediation.md)。Agentic 破坏性变更解决作用于自动修复创建的依赖升级合并请求。

<a id="enable-agentic-breaking-change-resolution"></a>

## 启用 Agentic 破坏性变更解决

该功能默认关闭，必须在群组和项目两个层面显式启用。

<a id="turn-on-this-foundational-flow-in-a-top-level-group"></a>

### 在顶级群组中开启此内置任务流

要允许群组中的所有项目使用此内置任务流：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 在 **允许内置任务流** 下，选中 **解决依赖升级破坏性变更** 复选框。
1. 选择 **保存更改**。

<a id="turn-on-this-foundational-flow-for-a-project"></a>

### 为项目开启此内置任务流

先决条件：

- 项目的维护者或所有者角色。
- 已为顶级群组启用此内置任务流。

要为特定项目开启 Agentic 破坏性变更解决：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo**。
1. 打开 **开启 AI 驱动的依赖升级破坏性变更解决** 开关。
1. 选择 **保存更改**。

<a id="trigger-the-flow"></a>

## 触发任务流

您可以自动或手动触发此任务流。

<a id="automatic-trigger"></a>

### 自动触发

当满足以下条件时，任务流会自动运行：

- 自动修复 Agent 创建的依赖升级合并请求上的流水线失败。
- 已为项目启用此功能。
- 已为项目或群组启用极狐GitLab Duo 功能。

分析在后台运行。完成后，任何生成的修复都会提交到合并请求分支，并重新运行流水线。

<a id="manual-trigger"></a>

### 手动触发

要在具有失败流水线的依赖升级合并请求上手动触发 Agentic 破坏性变更解决：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求**。
1. 选择具有失败流水线的依赖升级合并请求。
1. 在流水线小部件中，选择 **使用 Duo 解决破坏性变更**。

任务流在后台运行。完成后，它会将任何生成的修复提交到合并请求分支，并重新运行流水线。

<a id="provide-feedback"></a>

## 提供反馈

在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/605189)中分享您的反馈。
