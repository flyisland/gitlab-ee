---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the GitLab for VS Code extension to handle common GitLab tasks directly in VS Code.
title: 适用于 VS Code 的极狐GitLab 扩展
---

[适用于 VS Code 的极狐GitLab 扩展](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow) 将极狐GitLab Duo 和其他极狐GitLab 功能直接集成到您的 IDE 中。

要开始使用，请[安装和配置该扩展](setup.md)。为增强安全性，您可以在 Visual Studio Code Dev Container 中设置该扩展。

配置完成后，此扩展会将您日常使用的极狐GitLab 功能直接带入 VS Code 环境：

- [处理项目](projects.md)：使用议题计划并跟踪工作，审查并讨论合并请求中的变更，分享代码片段。使用极狐GitLab Duo 进行 AI 原生的规划和编码。
- [监控和测试 CI/CD 流水线](cicd.md)：测试您的流水线配置，查看流水线状态和作业输出。
- [保护您的应用程序](security_scanning.md)：审查安全发现，并对您的项目进行 SAST 扫描。
- [浏览代码库](remote_urls.md#browse-a-repository-in-read-only-mode)：以只读模式访问极狐GitLab 代码库，无需克隆。

当您在 VS Code 中查看极狐GitLab 项目时，扩展会显示有关当前分支的信息：

- 分支最新 CI/CD 流水线的状态。
- 指向该分支合并请求的链接。
- 如果合并请求包含[议题关闭模式](../../user/project/issues/managing_issues.md#closing-issues-automatically)，则提供指向该议题的链接。

<a id="gitlab-extension-panels"></a>

## 极狐GitLab 扩展面板

安装并设置扩展后，您可以访问以下功能：

- 在左侧边栏中，**极狐GitLab** ({{< icon name="tanuki" >}})：管理议题和合并请求，运行 CI/CD 命令，查看流水线状态，以及执行安全扫描。您还可以使用[自定义查询](custom_queries.md)扩展您的视图。
- 在左侧边栏中，**极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}}):
  - 聊天标签页：与极狐GitLab Duo Agentic Chat 交互，或使用 **新会话** ({{< icon name="duo-chat-new" >}}) 下拉列表选择一个基础或自定义代理进行协作。
  - 流程标签页：使用软件开发工作流。了解更多关于[聊天和工作流的区别](../../user/duo_agent_platform/flows/foundational_flows/software_development.md#flow-and-chat-comparison)。
- 在状态栏中，**Duo** ({{< icon name="tanuki-ai" >}})：查看极狐GitLab Duo 代码建议的功能状态，并在编写代码时查看文件中的建议。
- 在左侧边栏中，**极狐GitLab Duo Chat** ({{< icon name="duo-chat" >}})：与极狐GitLab Duo 非 Agent 聊天交互。

如果这些功能未出现，请参阅[故障排除](troubleshooting.md#gitlab-duo-features-are-unavailable)获取指导。

<a id="customize-keyboard-shortcuts"></a>

## 自定义键盘快捷键

您可以为 **接受行内建议**、**接受行内建议的下一个单词** 或 **接受行内建议的下一行** 分配不同的键盘快捷键：

1. 在 VS Code 中，运行 `首选项: 打开键盘快捷方式` 命令。
1. 找到您想要编辑的快捷方式，然后选择 **更改键绑定** ({{< icon name="pencil" >}})。
1. 将您偏好的快捷键分配给 **接受行内建议**、**接受行内建议的下一个单词** 或 **接受行内建议的下一行**。
1. 按 <kbd>Enter</kbd> 键保存更改。

<a id="update-the-extension"></a>

## 更新扩展

要将扩展更新到最新版本：

1. 在 Visual Studio Code 中，前往 **设置** > **扩展**。
1. 搜索由 **极狐GitLab (`gitlab.com`)** 发布的 **极狐GitLab**。
1. 在 **扩展: 极狐GitLab** 中，选择 **更新到 {更高版本}**。
1. 可选。要在未来启用自动更新，请选择 **自动更新**。

<a id="install-the-pre-release-version"></a>

## 安装预发布版

极狐GitLab 将扩展的预发布构建发布到 VS Code Extension Marketplace。

要安装预发布构建：

1. 打开 VS Code。
1. 在 **扩展** > **极狐GitLab** 下，选择 **切换到预发布版本**。
1. 选择 **重启扩展**。

<a id="check-gitlab-duo-status"></a>

## 检查极狐GitLab Duo 状态

1. 在 Visual Studio Code 中，在底部状态栏上，选择极狐GitLab 图标 ({{< icon name="tanuki" >}})。
1. VS Code 搜索框下方会打开一个菜单，适用于 VS Code 的极狐GitLab 扩展会显示状态。任何错误会显示在 **状态:** 旁边。

对于极狐GitLab Duo 非 Agent 聊天，您还可以查看 [Chat 状态](../../user/gitlab_duo_chat/_index.md#check-the-status-of-chat)。