---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use GitLab Duo Chat to ask questions about your code, get help with GitLab, and complete tasks in the GitLab UI or your IDE.
title: 极狐GitLab Duo 非 Agentic聊天
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: GitLab Duo Core, Pro, or Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../gitlab_duo/model_selection.md#default-models)
- 可访问 [自部署模型的 GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 作为[实验](../../policy/development_stages_support.md#experiment)在极狐GitLab 16.0 中引入到 JihuLab.com。
- 在极狐GitLab 16.6 中转为[测试版](../../policy/development_stages_support.md#beta)，适用于 JihuLab.com。
- 在极狐GitLab 16.8 中作为测试版引入到私有化部署。
- 在极狐GitLab 16.9 中，从旗舰版变更为专业版，同时处于测试版。
- 在极狐GitLab 16.11 中 [GA](../../policy/development_stages_support.md#generally-available)。
- 在极狐GitLab 17.6 及更高版本中，要求使用极狐GitLab Duo 插件。
- 在极狐GitLab 18.3 中添加到 GitLab Duo Core。
- 在极狐GitLab 18.6 中，默认 LLM 更新为国内 SOTA 大模型。

{{< /history >}}

极狐GitLab Duo Chat 是一个 AI 助手，通过上下文感知的对话式 AI 加速开发。这个非 Agentic Chat：

- 直接在你的开发环境中解释代码并建议改进。
- 分析代码、合并请求、议题和其他极狐GitLab 工件。
- 根据你的需求和代码库生成代码、测试和文档。
- 直接集成在极狐GitLab UI 和 Web IDE 中。
- 可以包含来自你的仓库和项目的信息，以提供有针对性的改进。

了解新的 [极狐GitLab Duo Agentic Chat](agentic_chat.md)。

## 支持的编辑器扩展

你可以在以下环境中使用极狐GitLab Duo Chat：

- 极狐GitLab UI
- [极狐GitLab Web IDE（云中的 VS Code）](../project/web_ide/_index.md)

> [!note]
> 如果你使用私有化部署：请使用极狐GitLab 17.2 及更高版本以获得最佳用户体验和结果。早期版本可能仍可工作，但体验可能会下降。

## 在极狐GitLab UI 中使用极狐GitLab Duo Chat

{{< history >}}

- 在极狐GitLab 18.5 中，变更为在 JihuLab.com 的极狐GitLab UI 的所有页面上可用。
- 在极狐GitLab 18.6 中，新的导航和极狐GitLab Duo 侧边栏在 JihuLab.com 上引入，带有一个名为 `paneled_view` 的[功能标志](../../administration/feature_flags/_index.md)，默认启用。
- 在极狐GitLab 18.7 中，之前的导航说明被移除。
- 在极狐GitLab 18.8 中，新的导航和极狐GitLab Duo 侧边栏 GA，功能标志 `paneled_view` 被移除。

{{< /history >}}

前提条件：

- 你必须拥有极狐GitLab Duo Chat 的访问权限，并且极狐GitLab Duo 必须开启。
- 在私有化部署上，你必须在 Chat 可用的位置。它在以下位置不可用：
  - **你的工作**页面，如待办事项列表。
  - 你的**用户设置**页面。
  - **帮助**菜单。

要在极狐GitLab UI 中使用 Chat：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的项目。
1. 在极狐GitLab Duo 侧边栏中，选择**新建极狐GitLab Duo Chat**
   （{{< icon name="pencil-square" >}}）或**当前极狐GitLab Duo Chat**
   （{{< icon name="duo-chat" >}}）。
   一个 Chat 对话会在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 在 Chat 文本框下方，关闭 **Agentic** 切换开关。
1. 在消息框中输入你的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。
   - 你可以为聊天提供额外的[上下文](../gitlab_duo/context.md)。
   - 交互式 AI 聊天可能需要几秒钟才能生成答案。
1. 可选。你可以：
   - 提出后续问题。
   - 开始[另一个对话](#进行多个对话)。

要提出一个新的、不相关的问题，输入 `/reset` 并选择**发送**以清除上下文。

### 查看 Chat 历史记录

聊天历史记录中保留最近的 25 条消息。

在极狐GitLab Duo 侧边栏中，选择**极狐GitLab Duo Chat 历史记录**（{{< icon name="history" >}}）。

### 进行多个对话

{{< history >}}

- 在极狐GitLab 17.10 中引入，带有一个名为 `duo_chat_multi_thread` 的[功能标志](../../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 17.11 中在私有化部署上启用。
- 在极狐GitLab 18.1 中 GA。功能标志 `duo_chat_multi_thread` 被移除。
- 在极狐GitLab 18.9 中，极狐GitLab UI 中的聊天历史记录搜索功能引入。

{{< /history >}}

在极狐GitLab 17.10 及更高版本中，你可以与 Chat 进行无限数量的同时对话。

1. 通过执行以下任一操作来创建新的 Chat 对话：

   - 在极狐GitLab Duo 侧边栏中，选择**新建极狐GitLab Duo Chat**（{{< icon name="pencil-square" >}}）。
   - 在消息框中，输入 `/new` 并按 <kbd>Enter</kbd> 或选择**发送**。

   一个新的 Chat 对话会替换前一个。
1. 在 Chat 文本框下方，关闭 **Agentic** 切换开关。
1. 要查看你的所有对话，请查看 [Chat 历史记录](#查看-chat-历史记录)。
1. 要在对话之间切换，请在 Chat 历史记录中选择相应的对话。
1. 在极狐GitLab UI 中，要在聊天历史记录中搜索特定对话，
   在**搜索话题**文本框中输入你的搜索词。

每个对话都会持久保存无限数量的消息。但是，只有最后 25 条消息会发送给 LLM，以适应 LLM 的上下文窗口。

在此功能启用之前创建的对话在 Chat 历史记录中不可见。

### 删除对话

要删除对话：

1. 选择 [Chat 历史记录](#查看-chat-历史记录)。
1. 在历史记录中，选择**删除此聊天**（{{< icon name="remove" >}}）。

默认情况下，单个对话在 30 天不活动后过期并自动删除。

但是，管理员可以[更改此过期期限](#配置-chat-对话过期)。

## 在 Web IDE 中使用极狐GitLab Duo Chat

{{< history >}}

- 在极狐GitLab 16.6 中作为[实验](../../policy/development_stages_support.md#experiment)引入。
- 在极狐GitLab 16.11 中转为 GA。

{{< /history >}}

要在极狐GitLab 的 Web IDE 中使用极狐GitLab Duo Chat：

1. 打开 Web IDE：
   1. 在极狐GitLab UI 中，在顶部栏中选择**搜索或跳转到**并找到你的项目。
   1. 选择一个文件。然后在右上角选择**编辑** > **在 Web IDE 中打开**。
1. 通过以下方法之一打开 Chat：
   - 在左侧边栏中，选择**极狐GitLab Duo Chat**。
   - 在编辑器中打开的文件中，选择一些代码。
     1. 右键单击并选择**极狐GitLab Duo Chat**。
     1. 选择**解释所选片段**、**修复**、**生成测试**、**打开快速聊天**或**重构**。
   - 使用键盘快捷键：
     - 在 Windows 或 Linux 上：<kbd>ALT</kbd>+<kbd>d</kbd>
     - 在 macOS 上：<kbd>Option</kbd>+<kbd>d</kbd>
1. 在消息框中，输入你的问题并按 <kbd>Enter</kbd> 或选择**发送**。

如果你在编辑器中选择了代码，此选择会包含在你向极狐GitLab Duo Chat 提出的问题中。
例如，你可以选择代码并询问 Chat，`你能简化一下吗？`。

### 检查配置诊断

要检查你的极狐GitLab Duo 配置诊断和系统设置，包括
系统版本控制、功能状态管理和功能标志：

- 在 Chat 窗格中，在右上角选择**状态**。

## 配置 Chat 对话过期

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

你可以配置对话在过期并自动删除之前保留多长时间。

前提条件：

- 你必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**极狐GitLab Duo Chat 对话**下，选择以下任一选项：
   - **自对话上次更新后**。
   - **自对话创建后**。
1. 选择**保存更改**。

## IDE 快捷键

当你在支持的 IDE 中使用 Chat 时，你可以使用[键盘快捷键](../shortcuts.md#gitlab-duo-chat)。

## 可用的语言模型

不同的语言模型可以作为极狐GitLab Duo Chat 的来源。

- 在 JihuLab.com 或私有化部署上，默认的极狐GitLab 管理的模型和
  由极狐GitLab 托管的基于云的 AI Gateway。
- 在私有化部署上，从极狐GitLab 17.9 开始，[使用受支持的自部署模型的极狐GitLab Duo 自托管](../../administration/gitlab_duo_self_hosted/_index.md)。自部署模型通过确保没有任何内容发送到外部模型来最大化安全性和隐私性。你可以使用极狐GitLab 管理的模型、其他受支持的语言模型，或者自带兼容模型。

## 输入和输出长度

对于每个 Chat 对话，输入和输出长度有限制：

- 输入限制为 200,000 个 token（大约 680,000 个字符）。输入 token 包括：
  - Chat 所感知的所有[上下文](../gitlab_duo/context.md)。
  - 该对话中所有之前的问题和答案。
- 输出限制为 8,192 个 token（大约 28,600 个字符）。

## 提供反馈

你的反馈非常重要，因为极狐GitLab 不断改进极狐GitLab Duo Chat 体验。
反馈有助于根据你的需求定制 Chat，并为所有人提高其性能。

要针对特定回复提供反馈，请使用回复消息中的反馈按钮。
或者，你可以在反馈 issue 中添加评论。