---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the GitLab CI Lint tool to validate CI/CD configuration and simulate pipelines to find errors before jobs run.
title: 验证极狐GitLab CI/CD 配置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 CI Lint 工具检查极狐GitLab CI/CD 配置的有效性。
你可以验证来自 `.gitlab-ci.yml` 文件或任何其他示例 CI/CD 配置的语法。
该工具检查语法和逻辑错误，并且可以模拟流水线创建，以尝试发现更复杂的配置问题。

如果你使用[流水线编辑器](../pipeline_editor/_index.md)，它会自动验证配置语法。

<a id="check-cicd-syntax"></a>

## 检查 CI/CD 语法

CI Lint 工具检查极狐GitLab CI/CD 配置的语法，包括使用 [`includes` 关键字](_index.md#include)添加的配置。

要使用 CI Lint 工具检查 CI/CD 配置：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **流水线编辑器**。
1. 选择 **验证** 标签页。
1. 选择 **Lint CI/CD 示例**。
1. 将你要检查的 CI/CD 配置的副本粘贴到文本框中。
1. 选择 **验证**。

<a id="simulate-a-pipeline"></a>

## 模拟流水线

你可以模拟极狐GitLab CI/CD 流水线的创建，以发现更复杂的问题，包括 [`needs`](_index.md#needs) 和 [`rules`](_index.md#rules) 配置的问题。模拟会以默认分支上的 Git `push` 事件运行。

先决条件：

- 你必须拥有在该分支上创建流水线的[权限](../../user/permissions.md#project-permissions)，才能通过模拟进行验证。

要模拟流水线：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **流水线编辑器**。
1. 选择 **验证** 标签页。
1. 选择 **Lint CI/CD 示例**。
1. 将你要检查的 CI/CD 配置的副本粘贴到文本框中。
1. 选择 **模拟默认分支的流水线创建**。
1. 选择 **验证**。