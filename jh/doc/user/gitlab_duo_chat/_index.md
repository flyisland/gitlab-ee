---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用极狐GitLab Duo Chat 询问有关代码的问题、获取极狐GitLab 相关帮助，并在极狐GitLab UI 或 IDE 中完成任务。
title: GitLab Duo Non-Agentic Chat
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Pro 或 Enterprise、极狐GitLab Duo with Amazon Q
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../gitlab_duo/model_selection.md#default-models)
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

> [!flag]
> 极狐GitLab Duo Core 客户访问权限的移除由功能标志控制。

极狐GitLab Duo Chat 是一款 AI 助手，通过上下文感知的对话式 AI 加速开发。此非自主 Chat：

- 直接在您的开发环境中解释代码并提出改进建议。
- 分析代码、合并请求、议题和其他极狐GitLab 产物。
- 根据您的需求和代码库生成代码、测试和文档。
- 直接集成到极狐GitLab UI、Web IDE、VS Code、JetBrains IDE 和 Visual Studio 中。
- 可以包含来自您的代码仓库和项目的信息，以提供有针对性的改进。


了解[极狐GitLab Duo Agentic Chat](agentic_chat.md)。

<a id="access-for-gitlab-duo-core-users"></a>

## 极狐GitLab Duo Core 用户的访问权限

自 2026 年 5 月 21 日起，所有极狐GitLab 版本上的极狐GitLab Duo Core 用户都无法访问
GitLab Duo Non-Agentic Chat。

您可以选择以下任一方式：

- 使用[极狐GitLab Duo Agentic Chat](agentic_chat.md)，作为极狐GitLab Duo Agent Platform 的一部分。

  如果您曾在 Web IDE 或 Eclipse 中使用 Non-Agentic Chat，则必须使用
  其他 IDE。
- 购买极狐GitLab Duo Pro 或 Enterprise。

<a id="supported-editor-extensions"></a>

## 支持的编辑器扩展

您可以在以下环境中使用极狐GitLab Duo Chat：

- 极狐GitLab UI
- [极狐GitLab Web IDE（云端 VS Code）](../project/web_ide/_index.md)

您还可以通过安装编辑器扩展，在以下 IDE 中使用极狐GitLab Duo Chat：

- [VS Code](../../editor_extensions/visual_studio_code/setup.md)
- [JetBrains](../../editor_extensions/jetbrains_ide/setup.md)
- [Eclipse](../../editor_extensions/eclipse/setup.md)
- [Visual Studio](../../editor_extensions/visual_studio/setup.md)

> [!note]
> 如果您使用极狐GitLab 私有化部署：请使用极狐GitLab 17.2 及更高版本，以获得最佳用户体验和结果。更早的版本可能仍可运行，但体验可能会有所下降。

<a id="use-gitlab-duo-chat-in-the-gitlab-ui"></a>

## 在极狐GitLab UI 中使用极狐GitLab Duo Chat

先决条件：

- 您必须有权访问极狐GitLab Duo Chat，并且极狐GitLab Duo 必须已开启。
- 在极狐GitLab 私有化部署上，您必须处于 Chat 可用的位置。以下位置不可用：
  - **您的工作**页面，例如待办事项列表。
  - 您的**用户设置**页面。
  - **帮助**菜单。

要在极狐GitLab UI 中使用 Chat：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在极狐GitLab Duo 边栏中，选择**新建极狐GitLab Duo Chat**
   ({{< icon name="pencil-square" >}})或**当前极狐GitLab Duo Chat**
   ({{< icon name="duo-chat" >}})。
   Chat 对话会在屏幕右侧的极狐GitLab Duo 边栏中打开。
1. 在 Chat 文本框下方，关闭 **Agentic** 开关。
1. 在消息框中输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。
   - 您可以为聊天提供额外的[上下文](../gitlab_duo/context.md)。
   - 交互式 AI 聊天可能需要几秒钟才能生成回答。
1. 可选。您可以：
   - 提出后续问题。
   - 开始[另一个对话](#have-multiple-conversations)。

要提出一个新的、不相关的问题，请输入 `/reset` 并选择**发送**以清除上下文。

<a id="view-the-chat-history"></a>

### 查看聊天历史

聊天历史中会保留最近 25 条消息。

在极狐GitLab Duo 边栏中，选择 **极狐GitLab Duo Chat 聊天历史** ({{< icon name="history" >}})。

<a id="have-multiple-conversations"></a>

### 进行多个对话

在极狐GitLab 17.10 及更高版本中，您可以与 Chat 同时进行无限数量的对话。

1. 通过以下任一方式创建新的 Chat 对话：

   - 在极狐GitLab Duo 边栏中，选择**新建极狐GitLab Duo Chat** ({{< icon name="pencil-square" >}})。
   - 在消息框中，输入 `/new` 并按 <kbd>Enter</kbd> 或选择**发送**。

   新的 Chat 对话会替换上一个对话。
1. 在 Chat 文本框下方，关闭 **Agentic** 开关。
1. 要查看您的所有对话，请查看[聊天历史](#view-the-chat-history)。
1. 要在对话之间切换，请在聊天历史中选择相应的对话。
1. 在极狐GitLab UI 中，要在聊天历史中搜索特定对话，
   请在**搜索特定会话**文本框中输入搜索词。

每个对话都会保留无限数量的消息。但是，为了将内容放入 LLM 的上下文窗口，只有最近 25 条消息会发送给 LLM。

在此功能启用之前创建的对话不会显示在聊天历史中。

<a id="delete-a-conversation"></a>

### 删除对话

要删除对话：

1. 选择[聊天历史](#view-the-chat-history)。
1. 在历史记录中，选择**删除该会话** ({{< icon name="remove" >}})。

默认情况下，单个对话会在 30 天无活动后过期并自动删除。

但是，管理员可以[更改此过期期限](#configure-chat-conversation-expiration)。

<a id="use-gitlab-duo-chat-in-the-web-ide"></a>

## 在 Web IDE 中使用极狐GitLab Duo Chat

要在极狐GitLab 上的 Web IDE 中使用极狐GitLab Duo Chat：

1. 打开 Web IDE：
   1. 在极狐GitLab UI 的顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
   1. 选择一个文件。然后在右上角，选择**编辑** > **在 Web IDE 中打开**。
1. 使用以下任一方法打开 Chat：
   - 在左侧边栏中，选择 **极狐GitLab Duo Chat**。
   - 在编辑器中打开的文件中，选择一些代码。
     1. 右键单击并选择 **极狐GitLab Duo Chat**。
     1. 选择 **解释所选代码片段**、**修复**、**生成测试**、**打开快速聊天** 或 **重构**。
   - 使用键盘快捷键：
     - 在 Windows 或 Linux 上：<kbd>ALT</kbd>+<kbd>d</kbd>
     - 在 macOS 上：<kbd>Option</kbd>+<kbd>d</kbd>
1. 在消息框中，输入您的问题并按 <kbd>Enter</kbd> 或选择**发送**。

如果您在编辑器中选择了代码，该选择内容会随您的问题一起发送给极狐GitLab Duo Chat。例如，您可以选择代码并向 Chat 提问：`Can you simplify this?`。

<a id="check-configuration-diagnostics"></a>

### 检查配置诊断

要检查您的极狐GitLab Duo 配置诊断和系统设置，包括系统版本管理、功能状态管理和功能标志：

- 在 Chat 窗格中，在右上角，选择**状态**。

<a id="use-gitlab-duo-chat-in-vs-code"></a>

## 在 VS Code 中使用极狐GitLab Duo Chat

先决条件：

- 您已[安装并配置 VS Code 扩展](../../editor_extensions/visual_studio_code/setup.md)。

要在 GitLab for VS Code 扩展中使用极狐GitLab Duo Chat：

1. 在 VS Code 中，打开一个文件。该文件不必是 Git 代码仓库中的文件。
1. 在左侧边栏中，选择 **极狐GitLab Duo Chat** ({{< icon name="duo-chat" >}})。
1. 在消息框中，输入您的问题并按 <kbd>Enter</kbd> 或选择**发送**。

如果您在编辑器中选择了代码，该选择内容会随您的问题一起发送给极狐GitLab Duo Chat。例如，您可以选择代码并向 Chat 提问：`Can you simplify this?`。

<a id="use-chat-while-working-in-the-editor-window"></a>

### 在编辑器窗口中工作时使用 Chat

要在编辑器窗口中打开极狐GitLab Duo Chat，请使用以下任一方法：

- 使用键盘快捷键：
  - 在 Windows 和 Linux 上：<kbd>ALT</kbd>+<kbd>c</kbd>
  - 在 macOS 上：<kbd>Option</kbd>+<kbd>c</kbd>
- 在 IDE 中当前打开的文件中，右键单击并选择 **极狐GitLab Duo Chat** > **打开快速聊天**。
  选择一些代码以提供额外的上下文。
- 打开命令面板，然后选择 **极狐GitLab Duo Chat：打开快速聊天**。

Quick Chat 打开后：

1. 在消息框中，输入您的问题。您还可以：
   - 输入 `/` 以显示所有可用命令。
   - 输入 `/re` 以显示 `/refactor` 和 `/reset`。
1. 要发送您的问题，请选择**发送**，或按 <kbd>Command</kbd>+<kbd>Enter</kbd>。
1. 要与响应交互，请在代码块上方使用 **复制代码片段** 和 **插入代码片段** 链接。
1. 要退出聊天，请选择装订线中的聊天图标，或在聊天获得焦点时按 **Escape**。

<a id="check-the-status-of-chat"></a>

### 检查 Chat 的状态

要检查您的极狐GitLab Duo 配置的运行状况：

- 在聊天窗格中，在右上角，选择**状态**。

<a id="close-chat"></a>

### 关闭 Chat

要关闭极狐GitLab Duo Chat：

- 对于左侧边栏中的极狐GitLab Duo Chat，选择 **极狐GitLab Duo Chat** ({{< icon name="duo-chat" >}})。
- 对于嵌入在您文件中的快速聊天窗口，在右上角，
  选择**折叠** ({{< icon name="chevron-lg-up" >}})。

<a id="use-gitlab-duo-chat-in-visual-studio-for-windows"></a>

## 在 Windows 版 Visual Studio 中使用极狐GitLab Duo Chat

先决条件：

- 您已安装并配置 [GitLab for Visual Studio 扩展](../../editor_extensions/visual_studio/setup.md)。

要在 GitLab for Visual Studio 扩展中使用极狐GitLab Duo Chat：

1. 在 Visual Studio 中，打开一个文件。该文件不必是 Git 代码仓库中的文件。
1. 使用以下任一方法打开 Chat：
   - 在顶部菜单栏中，选择**扩展**，然后选择 **打开 Duo Chat**。
   - 在编辑器中打开的文件中，选择一些代码。
     1. 右键单击并选择 **极狐GitLab Duo Chat**。
     1. 选择 **解释所选代码** 或 **生成测试**。
1. 在消息框中，输入您的问题并按 <kbd>Enter</kbd> 或选择**发送**。

如果您在编辑器中选择了代码，该选择内容会随您的问题一起发送给 AI。这样您就可以就该代码选择提问。例如：`Could you refactor this?`。

<a id="use-gitlab-duo-chat-in-jetbrains-ides"></a>

## 在 JetBrains IDE 中使用极狐GitLab Duo Chat

先决条件：

- 您已[安装并配置适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../editor_extensions/jetbrains_ide/setup.md)。

要在适用于 JetBrains IDE 的极狐GitLab Duo 插件中使用极狐GitLab Duo Chat：

1. 在 JetBrains IDE 中，打开一个项目。
1. 在聊天窗口或编辑器窗口中打开极狐GitLab Duo Chat。

<a id="in-a-chat-window"></a>

### 在聊天窗口中

要在聊天窗口中打开极狐GitLab Duo Chat，请使用以下任一方法：

- 在右侧工具窗口栏中，选择 **GitLab Duo Non-Agentic Chat**。
- 使用键盘快捷键：
  - 在 Windows 和 Linux 上：<kbd>ALT</kbd>+<kbd>d</kbd>
  - 在 macOS 上：<kbd>Option</kbd>+<kbd>d</kbd>
- 从打开的编辑器文件：
  1. 右键单击并选择 **极狐GitLab Duo Chat**。
  1. 选择 **打开聊天窗口**。
- 使用选中的代码：
  1. 在编辑器中，选择要随命令一起包含的代码。
  1. 右键单击并选择 **极狐GitLab Duo Chat**。
  1. 选择 **解释代码**、**修复代码**、**生成测试** 或 **重构代码**。
- 从突出显示的代码问题：
  1. 右键单击并选择 **显示上下文操作**。
  1. 选择 **使用 Duo 修复**。
- 使用极狐GitLab Duo 操作的键盘或鼠标快捷键，您可以在**设置** > **按键映射**中设置。

极狐GitLab Duo Chat 打开后：

1. 在消息框中，输入您的问题。您还可以：
   - 输入 `/` 以显示所有可用命令。
   - 输入 `/re` 以显示 `/refactor` 和 `/reset`。
1. 要发送您的问题，请按 <kbd>Enter</kbd> 或选择**发送**。
1. 使用响应中代码块内的按钮与其交互。

<a id="in-an-editor-window"></a>

### 在编辑器窗口中

要在编辑器窗口中打开极狐GitLab Duo Chat，请使用以下任一方法：

- 使用键盘快捷键：
  - 在 Windows 和 Linux 上：<kbd>ALT</kbd>+<kbd>c</kbd>
  - 在 macOS 上：<kbd>Option</kbd>+<kbd>c</kbd>
- 在 IDE 中打开的文件中，选择一些代码，
  然后，在浮动工具栏中，选择 **极狐GitLab Duo Quick Chat** ({{< icon name="tanuki-ai" >}})。
- 右键单击并选择 **极狐GitLab Duo Chat** > **打开快速聊天**。

Quick Chat 打开后：

1. 在消息框中，输入您的问题。您还可以：
   - 输入 `/` 以显示所有可用命令。
   - 输入 `/re` 以显示 `/refactor` 和 `/reset`。
1. 要发送您的问题，请按 <kbd>Enter</kbd>。
1. 要与响应交互，请使用代码块周围的按钮。
1. 要退出聊天，请选择 **按 Escape 关闭**，或在聊天获得焦点时按 <kbd>Escape</kbd>。

<a id="use-gitlab-duo-chat-in-eclipse"></a>

## 在 Eclipse 中使用极狐GitLab Duo Chat

先决条件：

- 您已[安装并配置 GitLab for Eclipse 插件](../../editor_extensions/eclipse/setup.md)。

要在 GitLab for Eclipse 插件中使用极狐GitLab Duo Chat：

1. 在 Eclipse 中打开一个项目。
1. 在右上角，选择 **极狐GitLab Duo Chat** ({{< icon name="duo-chat" >}})，或使用键盘快捷键：
   - 对于 Windows 和 Linux：<kbd>Alt</kbd>+<kbd>D</kbd>
   - 对于 macOS：<kbd>Option</kbd>+<kbd>D</kbd>
1. 在消息框中，输入您的问题并按 <kbd>Enter</kbd> 或选择**发送**。

<a id="configure-chat-conversation-expiration"></a>

## 配置 Chat 对话过期

您可以配置对话在过期并自动删除之前保留多长时间。

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo Chat 对话** 下，选择以下任一选项：
   - **自对话上次更新后**。
   - **自对话创建后**。
1. 选择 **保存更改**。

<a id="ide-shortcuts"></a>

## IDE 快捷键

当您在受支持的 IDE 中使用 Chat 时，可以使用[键盘快捷键](../shortcuts.md#gitlab-duo-chat)。

<a id="available-language-models"></a>

## 可用的语言模型

不同的语言模型可以作为极狐GitLab Duo Chat 的来源。

- 在 JihuLab.com 或极狐GitLab 私有化部署上，使用默认的极狐GitLab 托管模型和
  由极狐GitLab 托管的基于云的 AI 网关。
- 在极狐GitLab 私有化部署上，在极狐GitLab 17.9 及更高版本中，[极狐GitLab Duo 自部署版本与受支持的自部署模型](../../administration/gitlab_duo_self_hosted/_index.md)。自部署模型通过确保不向外部模型发送任何内容，最大限度地提高
  安全性和隐私性。您可以使用极狐GitLab 托管模型、其他受支持的语言模型，或自带兼容模型。

<a id="input-and-output-length"></a>

## 输入和输出长度

对于每个 Chat 对话，输入和输出长度都有限制：

- 输入限制为 200,000 个令牌（约 680,000 个字符）。输入令牌
  包括：
  - 所有 [Chat 可感知的上下文](../gitlab_duo/context.md)。
  - 该对话中所有之前的问题和回答。
- 输出限制为 8,192 个令牌（约 28,600 个字符）。

<a id="give-feedback"></a>

## 提供反馈

您的反馈非常重要，因为极狐GitLab 会持续增强极狐GitLab Duo Chat 体验。反馈有助于根据您的需求定制 Chat，并为所有人改进其性能。

要针对特定响应提供反馈，请使用响应消息中的反馈按钮。或者，您可以在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430124)中添加评论。
