---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用极狐GitLab Duo Agentic Chat 回答复杂问题，并自主创建或编辑文件。
title: 极狐GitLab Duo Agentic Chat
---

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../duo_agent_platform/model_selection.md#default-models)
- 适用于[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

极狐GitLab Duo Agentic Chat 是极狐GitLab Duo Non-Agentic Chat 的增强版本。这个新的 Chat 可以代表您自主执行操作，帮助您更全面地回答复杂问题。

非 Agentic Chat 基于单一上下文回答问题，而 Agentic Chat 会搜索、检索并组合来自您极狐GitLab 项目中多个来源的信息，从而提供更全面、更相关的答案。

Agentic Chat 可以：

- 使用基于关键字的搜索（而非语义搜索）搜索项目，以查找相关议题、合并请求和其他产物。
- 访问本地项目中的文件，无需手动指定文件路径。
- 在多个位置创建和编辑文件。
- 检索议题、合并请求和 CI/CD 流水线等资源。
- 分析多个来源以提供完整的答案。
  使用[模型上下文协议](../gitlab_duo/model_context_protocol/_index.md)连接到外部数据源和工具。
- 使用您的自定义规则提供定制化响应。
- 在极狐GitLab UI 中使用 Chat 时创建提交。


<a id="use-gitlab-duo-chat"></a>

## 使用极狐GitLab Duo Chat

您可以在以下环境中使用极狐GitLab Duo Chat：

- 极狐GitLab UI。
- VS Code。
- JetBrains IDE。
- 适用于 Windows 的 Visual Studio。

借助[极狐GitLab Duo CLI](../gitlab_duo_cli/_index.md)，您还可以在终端中使用 Agentic Chat。

<a id="use-gitlab-duo-chat-in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中使用极狐GitLab Duo Chat

先决条件：

- 满足[极狐GitLab Duo Agent Platform 先决条件](../duo_agent_platform/_index.md#prerequisites)。
- 设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

要在极狐GitLab UI 中使用 Chat：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在极狐GitLab Duo 边栏中，选择**添加新会话**（{{< icon name="pencil-square" >}}）
   或**当前极狐GitLab Duo Chat**（{{< icon name="duo-chat" >}}）。

   如果您选择了新会话，请从下拉列表中选择一个 Agent。

   Chat 对话会在屏幕右侧的极狐GitLab Duo 边栏中打开。
1. 在聊天文本框下方，确保 **Agentic** 开关已打开。
1. 在聊天文本框中输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。
   - 您可以为聊天提供额外的[上下文](../duo_agent_platform/context.md#gitlab-duo-agentic-chat)。
   - 交互式 AI 聊天可能需要几秒钟才能生成答案。
1. 可选。您可以：
   - 提出后续问题。
   - 开始[另一个对话](#have-multiple-conversations)。

如果您重新加载当前网页，或转到另一个网页，Chat 会记住您最近的对话，并且该对话在 Chat 抽屉中仍处于活动状态。

<a id="foundational-flows"></a>

#### 内置任务流

> [!flag]
> 此功能的可用性由功能标志控制。

在适当的情况下，可以从 Agentic Chat 对话中触发以下内置任务流，以回答问题或达成目标。

- [开发者任务流](../duo_agent_platform/flows/foundational_flows/developer.md#use-the-flow-in-agentic-chat)
- [代码评审任务流](../duo_agent_platform/flows/foundational_flows/code_review/_index.md#use-the-flow)
- [修复 CI/CD 流水线任务流](../duo_agent_platform/flows/foundational_flows/fix_pipeline.md#fix-the-pipeline-in-a-merge-request)

<a id="use-gitlab-duo-chat-in-vs-code"></a>

### 在 VS Code 中使用极狐GitLab Duo Chat

先决条件：

- [安装并配置 GitLab for VS Code 扩展](../../editor_extensions/visual_studio_code/setup.md) 6.15.1 或更高版本。
- 满足[极狐GitLab Duo Agent Platform 先决条件](../duo_agent_platform/_index.md#prerequisites)。
- 设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

打开极狐GitLab Duo Chat：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择**扩展** > **GitLab** > **极狐GitLab Duo**。
1. 在 **GitLab › Duo Agent Platform: Enabled** 下，选中
   **启用极狐GitLab Duo Agent Platform** 复选框。

然后，要使用极狐GitLab Duo Chat：

1. 在左侧边栏中，选择**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
1. 选择 **Chat** 标签页。
1. 如果出现提示，选择**刷新页面**。
1. 在消息框中，输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。

<a id="use-gitlab-duo-chat-in-jetbrains-ides"></a>

### 在 JetBrains IDE 中使用极狐GitLab Duo Chat

先决条件：

- [安装并配置适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../editor_extensions/jetbrains_ide/setup.md) 3.11.1 或更高版本。
- 满足[极狐GitLab Duo Agent Platform 先决条件](../duo_agent_platform/_index.md#prerequisites)。
- 设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

打开极狐GitLab Duo Chat：

1. 在您的 JetBrains IDE 中，转到**设置** > **工具** > **极狐GitLab Duo**。
1. 在**极狐GitLab Duo Agent Platform** 下，选中**启用极狐GitLab Duo Agent Platform** 复选框。
1. 如果出现提示，请重启您的 IDE。

然后，要使用极狐GitLab Duo Chat：

1. 在右侧工具窗口栏中，选择**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
1. 选择 **Chat** 标签页。
1. 在消息框中，输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。

<a id="use-gitlab-duo-chat-in-visual-studio"></a>

### 在 Visual Studio 中使用极狐GitLab Duo Chat

先决条件：

- 安装并配置 [GitLab for Visual Studio 扩展](../../editor_extensions/visual_studio/setup.md) 0.60.0 或更高版本。
- 满足[极狐GitLab Duo Agent Platform 先决条件](../duo_agent_platform/_index.md#prerequisites)。
- 设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

打开极狐GitLab Duo Chat：

1. 在 Visual Studio 中，转到**工具** > **选项** > **GitLab**。
1. 在 **GitLab** 下，选择**常规**。
1. 对于 **启用 Agentic Duo Chat**，选择 **True**，然后选择 **确定**。

然后，要使用极狐GitLab Duo Chat：

1. 选择**扩展** > **GitLab** > **打开 Agentic Chat**。
1. 在消息框中，输入您的问题，然后按 **Enter**。

<a id="view-the-chat-history"></a>

## 查看聊天历史

要查看您的聊天历史：

- 在极狐GitLab UI 中，在极狐GitLab Duo 边栏中，选择 **极狐GitLab Duo Chat 历史**
  （{{< icon name="history" >}}）。

- 在您的 IDE 中，在消息框的右上角，选择
  **聊天历史**（{{< icon name="history" >}}）。

在极狐GitLab UI 中，聊天历史中的所有对话都可见。

在您的 IDE 中，最近 20 个对话可见。[议题 1308](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/1308) 提议更改此行为。

<a id="have-multiple-conversations"></a>

## 拥有多个对话

您可以与极狐GitLab Duo Chat 同时进行无限数量的对话。

您的对话会在极狐GitLab UI 和 IDE 中的极狐GitLab Duo Chat 之间同步。

1. 在极狐GitLab UI 或您的 IDE 中打开极狐GitLab Duo Chat。
1. 输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。
1. 创建新的 Chat 对话：

   - 在极狐GitLab UI 中，您可以执行以下任一操作：

     - 要使用特定 Agent 创建新对话：
       1. 在极狐GitLab Duo 边栏中，选择**添加新会话**（{{< icon name="pencil-square" >}}）。
       1. 从下拉列表中选择一个 Agent。
     - 要使用与现有对话相同的 Agent 创建新对话，
       请在消息框中输入 `/new`，然后按 <kbd>Enter</kbd> 或选择**发送**。

     新的 Chat 对话会替换现有对话。
   - 在 Chat 文本框下方，确保 **Agentic** 开关已打开。
   - 在您的 IDE 中，在消息框的右上角，选择**新会话**
     （{{< icon name="plus" >}}）。
1. 输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。
1. 要查看您的所有对话，请查看您的[聊天历史](#view-the-chat-history)。
1. 要在对话之间切换，请在您的聊天历史中选择
   相应的对话。
1. 要在聊天历史中搜索特定对话：
   - 极狐GitLab UI：在**搜索讨论串**文本框中，输入您的搜索词。
   - IDE：在**搜索特定会话**文本框中，输入您的搜索词。

由于 LLM 上下文窗口限制，每个对话会被截断为 200,000 个令牌（约 800,000 个字符）。

<a id="delete-a-conversation"></a>

## 删除对话

1. 在极狐GitLab UI 或您的 IDE 中，选择[聊天历史](#view-the-chat-history)。
1. 在历史记录中，选择**删除该会话**（{{< icon name="remove" >}}）。

单个对话会在 30 天无活动后过期并自动删除。

<a id="customize-gitlab-duo-chat-in-your-local-environment"></a>

## 在本地环境中自定义极狐GitLab Duo Chat

通过提供反映您的编码风格、团队实践和项目要求的指令，自定义极狐GitLab Duo Chat 在您本地环境中的行为。

极狐GitLab Duo Chat 支持两种方式：

- `chat-rules.md`中的[自定义规则](../duo_agent_platform/customize/custom_rules.md)：仅适用于极狐GitLab。
  最适合个人偏好和团队标准。
- [`AGENTS.md`中的共享规则](../duo_agent_platform/customize/agents_md.md)：适用于极狐GitLab 和其他支持 `AGENTS.md` 规范的 AI
  工具。最适合项目上下文、monorepo 组织
  和特定目录的约定。

您可以同时使用这两个文件。极狐GitLab Duo Chat 会应用所有可用规则文件中的指令。

详细了解如何[自定义极狐GitLab Duo](../duo_agent_platform/customize/_index.md)。

<a id="select-a-model"></a>

## 选择模型

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您在极狐GitLab UI、VS Code 或 JetBrains IDE 中使用 Chat 时，您可以选择
用于对话的模型。

如果您从聊天历史中打开之前的聊天并继续该对话，Chat 会使用您之前选择的模型。

如果您在现有对话中选择新模型，Chat 会使用新选择的模型继续当前对话。

先决条件：

{{< tabs >}}

{{< tab title=GitLab.com >}}

- 顶级群组的所有者尚未为极狐GitLab Duo Agent Platform 选择模型。如果[已为群组选择模型](../gitlab_duo/model_selection.md)，您将无法更改 Chat 的模型。
- 您必须在顶级群组中使用 Chat。如果您在组织中访问 Chat，则无法更改模型。

{{< /tab >}}

{{< tab title="Self-managed" >}}

- 管理员尚未为实例选择模型。如果已为实例选择模型，
  您将无法更改 Chat 的模型。
- 您的实例必须连接到极狐GitLab AI 网关。

{{< /tab >}}

{{< /tabs >}}

要选择模型：

- 在极狐GitLab UI 中：
  1. 在聊天文本框下方，确保 **Agentic** 开关已打开。
  1. 从下拉列表中选择一个模型。
- 在您的 IDE 中：
  1. 在边栏中，选择**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）。
  1. 选择 **Chat** 标签页。
  1. 从下拉列表中选择一个模型。

<a id="select-an-agent"></a>

## 选择 Agent

当您在极狐GitLab UI、VS Code 或 JetBrains IDE 的项目中使用 Chat 时，
您可以选择供 Chat 使用的特定 Agent。

先决条件：

- 在您的项目中，[必须启用来自 AI 目录的 Agent](../duo_agent_platform/agents/custom.md#enable-an-agent)。
- 您必须是启用了该 Agent 的项目的成员。
- 对于 VS Code，[安装并配置 GitLab for VS Code 扩展](../../editor_extensions/visual_studio_code/setup.md) 6.49.12 或更高版本。
- 对于 JetBrains IDE，[安装并配置适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../editor_extensions/jetbrains_ide/setup.md) 3.22.0 或更高版本。

要选择 Agent：

1. 在极狐GitLab UI 或您的 IDE 中，在极狐GitLab Duo Chat 中打开新对话。
1. 在极狐GitLab UI 中，在 Chat 文本框下方，确保 **Agentic** 开关已打开。
1. 在下拉列表中，选择一个 Agent。如果您尚未设置任何
   Agent，则没有下拉列表，Chat 会使用默认的极狐GitLab Duo Agent。
1. 输入您的问题，然后按 <kbd>Enter</kbd> 或选择**发送**。

在使用 Agent 创建对话后：

- 该对话会记住您选择的 Agent。您无法为该对话选择其他
  Agent。
- 如果您使用聊天历史返回到同一对话，它会使用相同的 Agent。
- 如果您返回到某个对话，而关联的 Agent 已不再可用，
  您将无法继续该对话。

<a id="tool-approvals"></a>

## 工具审批

在 Agentic Chat 可以代表您使用工具之前，需要获得您的批准。默认情况下，每次调用工具都需要批准。

如果您信任某个工具并希望简化工作流，可以改为为整个会话批准一次。

会话批准仅适用于 Chat，不适用于任务流。

<a id="manage-tool-approvals"></a>

### 管理工具审批

所有者和管理员可以控制用户是否可以为会话批准工具。设置会从实例级联到群组再到项目。

为群组或实例配置以下选项之一：

- **默认开启**：用户可以为会话批准工具一次。群组和子群组可以将其关闭。
- **默认关闭**：（默认）用户必须批准每次工具调用。群组和子群组可以将其打开。
- **始终关闭**：用户无法为会话批准工具。群组和子群组无法覆盖此设置。

<a id="manage-default-settings"></a>

#### 管理默认设置

为您的实例或顶级群组配置默认工具审批设置。

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 顶级群组的 所有者角色。

要配置默认工具审批设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 选择**设置** > **极狐GitLab Duo**。
1. 从 **会话工具审批** 下拉列表中，选择您偏好的选项。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 管理员访问权限。

要配置默认工具审批设置：

1. 在右上角，选择**管理员**。
1. 选择 **极狐GitLab Duo**。
1. 从 **会话工具审批** 下拉列表中，选择您偏好的选项。

{{< /tab >}}

{{< tab title="GitLab Dedicated" >}}

先决条件：

- 管理员访问权限。

要配置默认工具审批设置：

1. 在右上角，选择**管理员**。
1. 选择 **极狐GitLab Duo**。
1. 从 **会话工具审批** 下拉列表中，选择您偏好的选项。

{{< /tab >}}

{{< /tabs >}}

<a id="manage-group-or-project-settings"></a>

#### 管理群组或项目设置

为特定群组或项目配置工具审批设置。

先决条件：

- 群组的 所有者角色，或项目的 维护者角色。

要配置工具审批设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组或项目。
1. 选择**设置** > **极狐GitLab Duo**。
1. 对于群组，从 **会话工具审批** 下拉列表中，选择您偏好的选项。
1. 对于项目，选中或清除 **允许会话工具审批** 复选框。

<a id="approve-tools-in-your-local-environment"></a>

### 在本地环境中批准工具

先决条件：

- 已为您的群组或实例打开工具审批。
- 对于本地环境中的极狐GitLab Duo Chat，安装并配置以下之一：
  - [GitLab for VS Code](../../editor_extensions/visual_studio_code/setup.md) 6.72.0 或更高版本。
  - [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../editor_extensions/jetbrains_ide/setup.md) 3.33.0 或更高版本。
  - [极狐GitLab Duo CLI](../gitlab_duo_cli/_index.md) 8.80.0 或更高版本。

要为当前会话批准或拒绝某个工具：

1. 当出现工具审批提示时，选择批准按钮旁边的下拉列表。
1. 选择以下选项之一：
   - **批准**：Chat 可以使用这些参数使用该工具一次。
   - **为会话批准**：Chat 可以在会话剩余时间内使用这些参数使用该工具。不同的参数需要额外批准。
   - **拒绝**：Chat 无法使用该工具。

当您开始新对话时，所有批准都会重置。

<a id="chat-feature-comparison"></a>

## Chat 功能比较

| 能力                                              | 极狐GitLab Duo Non-Agentic Chat |                                                         极狐GitLab Duo Agentic Chat                                                                                                           |
| ------------                                            |------|                                                         -------------                                                                                                          |
| 提出一般编程问题 |                       是  |                                                          是                                                                                                                   |
| 获取关于编辑器中打开文件的答案 |     是  |                                                          是。在您的问题中提供该文件的路径。                                                                   |
| 提供指定文件的上下文 |                   是。使用 `/include` 将文件添加到对话中。 <sup>1</sup> |        是。在您的问题中提供该文件的路径。                                                                   |
| 自主搜索项目内容 |                    否 |                                                            是                                                                                                                   |
| 自主创建文件和更改文件 |              否 |                                                            是。要求它更改文件。它可能会覆盖您手动做出且尚未提交的更改。  |
| 在不指定 ID 的情况下检索议题和合并请求 |          否 |                                                            是。按其他条件搜索。例如，合并请求或议题的标题或指派人。                                       |
| 组合来自多个来源的信息 |               否 |                                                            是                                                                                                                   |
| 分析流水线日志 |                                   是。需要极狐GitLab Duo Enterprise 附加组件。 |                          是                                                                                                                   |
| 重新开始对话 |                                  是。使用 `/new` 或 `/reset`。 |                             是。使用 `/new`，或者如果在 UI 中，使用 `/reset`。                                                                                       |
| 删除对话 |                                   是，在聊天历史中。|                                             是，在聊天历史中                                                                                                            |
| 创建议题和合并请求 |                                   否 |                                                            是                                                                                                                   |
| 使用 Git 只读命令 |                                                 否 |                                                            是                                                  |
| 使用 Git 写入命令 |                                                 否 |                                                            是，仅限 UI                                                  |
| 运行 Shell 命令 |                                      否 |                                                            是，仅限 IDE                                                                                                        |
| 运行 MCP 工具 |                                      否 |                                                            是，仅限 IDE                                                                                                          |
| 为会话批准工具 |                        否 |                                                            是，仅限 IDE                                                                                                          |

**脚注**：

1. 在 Web IDE 中使用极狐GitLab Duo Non-Agentic Chat 时不可用。

<a id="troubleshooting"></a>

## 故障排除

使用极狐GitLab Duo Chat 时，您可能会遇到问题。

有关解决这些问题的信息，请参阅[故障排除](troubleshooting.md)。
