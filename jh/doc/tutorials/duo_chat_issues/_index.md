---
stage: none
group: Tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Where to find GitLab Duo Chat and how to use it to work with issues.
title: "教程：使用极狐GitLab Duo Chat 管理议题"
---

极狐GitLab Duo Agentic Chat 使用称为代理的 AI 助手，帮助您完成特定任务并回答复杂问题。在本教程中，您将完成以下任务，以帮助您熟悉极狐GitLab Duo Chat 界面：

- 询问默认的极狐GitLab Duo Agent 来回答一个一般性问题。
- 使用计划者代理来完成更复杂的议题管理任务，具体包括：
  - 在议题中查找并筛选高优先级缺陷。
  - 查找分配给您的议题，并将所需工作分解为子任务。

<a id="before-you-begin"></a>

## 准备工作

- 满足 [极狐GitLab Duo Agent Platform 前提条件](../../user/duo_agent_platform/_index.md#prerequisites)。
- 设置 [默认极狐GitLab Duo 命名空间](../../user/profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 选择一个您熟悉的项目。至少有一个分配给您的开放议题。

<a id="open-gitlab-duo-chat"></a>

## 打开极狐GitLab Duo Chat

首先，熟悉聊天界面并开始您的第一个会话。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在右侧的极狐GitLab Duo 侧边栏中，选择 **新建会话**。
1. 现在选择要使用的代理。要问一般性问题，请选择 **极狐GitLab Duo**。

   ![新建会话并选择代理。](img/add_new_chat_v18_9.png)

极狐GitLab Duo 面板从屏幕右侧滑出。当您在极狐GitLab 中导航时，该面板会保持打开状态，因此您可以在聊天时参考代码、议题或合并请求。

![极狐GitLab Duo 面板中的一个新的空会话。](img/chat_panel_v18_9.png)

在面板底部，靠近聊天文本框处，您可以选择要使用的大语言模型。对于本教程，您可以保留默认选择。

![模型选择器。](img/choose_model_v18_9.png)

现在试试吧！

1. 在聊天文本框中，输入：

   ```plaintext
   给出这个项目架构的概述。
   ```

1. 按 <kbd>Enter</kbd> 键或选择 **发送**。

极狐GitLab Duo 在面板中汇总其发现。

<a id="find-and-filter-issues"></a>

## 查找和筛选议题

现在尝试在您的项目中搜索特定议题。您想找出项目中所有高优先级的缺陷。

对于此任务，请切换到计划者代理。

1. 在极狐GitLab Duo 侧边栏中，选择 **新建会话** > **计划者**。
1. 在聊天文本框中，输入：

   ```plaintext
   列出所有标签为‘缺陷’和‘高优先级’且在最近 30 天内创建的开放议题。
   ```

1. 按 <kbd>Enter</kbd> 键或选择 **发送**。

计划者代理搜索您的项目，并根据您的条件筛选议题。您会收到一个匹配议题的列表，包含其标题、编号和链接。

接下来，尝试一些后续提示，以按不同标签、日期范围或其他条件进行筛选。例如：

```plaintext
按创建日期对该列表排序，然后按名称字母顺序排序。
```

<a id="analyze-an-issue-and-create-subtasks"></a>

## 分析议题并创建子任务

您将使用 Chat 来查看分配给您的议题列表，并更详细地分析其中一个。

1. 在计划者代理对话的聊天文本框中，输入：

   ```plaintext
   显示所有分配给我的开放议题。
   ```

1. 按 <kbd>Enter</kbd> 键或选择 **发送**。
1. 选择一个议题。现在您将使用计划者代理创建子项，将工作分解为更易于管理的步骤。

   如果您不需要这些子项，也不必担心，您可以稍后关闭它们。
1. 在聊天文本框中，输入：

   ```plaintext
   分析议题 #<选定的议题编号>，并建议如何将工作分解为两到三个子任务。
   ```

1. 按 <kbd>Enter</kbd> 键或选择 **发送**。
1. 审查建议的子项，如果您同意，请输入：

   ```plaintext
   在议题 #<选定的议题编号> 下将这些子任务创建为子项。
   ```

   或者，使用后续提示请求更多细化，直到您满意为止。
1. 按 <kbd>Enter</kbd> 键或选择 **发送**。
1. 极狐GitLab Duo 准备工作项以供最终审查。阅读描述并查看 JSON 请求参数，然后选择 **批准**。

   ![批准由极狐GitLab Duo 准备的工作项。](img/approve_chat_v18_9.png)

这些议题将作为子项添加到您的议题中，聊天面板会显示它们的链接。然后，您可以添加标签、指派人或设置里程碑。

<a id="next-steps"></a>

## 下一步

祝贺您！您已经学会了如何使用极狐GitLab Duo Chat 和计划者代理进行简单的议题管理。

您可以继续对子任务的细节进行迭代，例如：

- `您能提供更多关于任务 3 的细节吗？`
- `将任务 2 拆分为单独的任务`
- `为这些任务添加技术实施说明`

或者，如果您只是作为实验尝试，您可以关闭这些子任务：

```plaintext
关闭这些子任务并分别添加评论，说明："此子任务作为教程练习的一部分而创建。"
```

要查看您已完成的工作，您可以返回到之前的聊天。在极狐GitLab Duo 侧边栏中，选择 **极狐GitLab Duo 聊天历史** ({{< icon name="history" >}})。

![聊天历史列表。](img/chat_history_v18_9.png)