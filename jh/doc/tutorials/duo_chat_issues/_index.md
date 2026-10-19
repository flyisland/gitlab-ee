---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在哪里找到极狐GitLab Duo Chat，以及如何使用它处理议题。
title: "教程：使用极狐GitLab Duo Chat 管理议题"
---

极狐GitLab Duo Agentic Chat 使用称为 Agent 的 AI 助手，帮助您完成特定任务并回答复杂问题。
在本教程中，您将完成以下任务，以帮助您熟悉极狐GitLab Duo Chat 界面：

- 让默认的极狐GitLab Duo Agent 回答一个一般性问题。
- 使用计划者 Agent 完成更复杂的议题管理任务，具体包括：
  - 在议题中查找并筛选高优先级缺陷。
  - 查找分配给您的议题，并将所需工作拆分为子任务。

<a id="before-you-begin"></a>

## 开始之前

- 满足[极狐GitLab Duo Agent Platform 先决条件](../../user/duo_agent_platform/_index.md#prerequisites)。
- 设置[默认极狐GitLab Duo 命名空间](../../user/profile/preferences.md#set-a-default-gitlab-duo-namespace)。
- 选择一个您熟悉的项目。至少有一个分配给您的未关闭议题。

<a id="open-gitlab-duo-chat"></a>

## 打开极狐GitLab Duo Chat

首先，熟悉聊天界面并开始您的第一次对话。

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在右侧的极狐GitLab Duo 边栏中，选择**添加新聊天**。
1. 现在选择要使用的 Agent。要提出一般性问题，请选择 **极狐GitLab Duo**。

   ![开始对话并选择 Agent。](img/add_new_chat_v18_9.png)

极狐GitLab Duo 面板从屏幕右侧滑出。当您在极狐GitLab 中导航时，该面板会保持打开，因此您可以在聊天时参考代码、议题或合并请求。

![极狐GitLab Duo 面板中一个新的空对话。](img/chat_panel_v18_9.png)

在面板底部，聊天文本框附近，您可以选择要使用的大语言模型。在本教程中，您可以保留默认选择。

![模型选择器。](img/choose_model_v18_9.png)

现在试一试吧！

1. 在聊天文本框中，输入：

   ```plaintext
   Give me an overview of this project's architecture.
   ```

1. 按 <kbd>Enter</kbd> 或选择**发送**。

极狐GitLab Duo 会在面板中总结其发现。

<a id="find-and-filter-issues"></a>

## 查找并筛选议题

现在尝试在您的项目中搜索特定议题。您想要识别项目中的所有高优先级缺陷。

对于此任务，请切换到计划者 Agent。

1. 在极狐GitLab Duo 边栏中，选择**添加新聊天** > **Planner**。
1. 在聊天文本框中，输入：

   ```plaintext
   List all open issues labeled 'bug' and 'high-priority' created in the last 30 days.
   ```

1. 按 <kbd>Enter</kbd> 或选择**发送**。

计划者 Agent 会搜索您的项目，并根据您的条件筛选议题。您会收到一个匹配议题的列表，其中包含标题、议题编号和链接。

接下来，尝试一些后续提示，按不同的标记、日期范围或其他条件进行筛选。例如：

```plaintext
Order this list by date created, and then alphabetically by name.
```

<a id="analyze-an-issue-and-create-subtasks"></a>

## 分析议题并创建子任务

您将使用 Chat 查看分配给您的议题列表，并详细分析其中一个议题。

1. 在计划者 Agent 对话的聊天文本框中，输入：

   ```plaintext
   Show me all the open issues assigned to me.
   ```

1. 按 <kbd>Enter</kbd> 或选择**发送**。
1. 选择其中一个议题。现在您将使用计划者 Agent 创建子项，
   将工作拆分为更易于管理的步骤。

   如果您不需要这些子项，也不用担心，您可以稍后随时关闭它们。
1. 在聊天文本框中，输入：

   ```plaintext
   Analyze issue #<selected_issue_number> and suggest how to break up the work into two or three subtasks.
   ```

1. 按 <kbd>Enter</kbd> 或选择**发送**。
1. 查看建议的子项，如果您同意这些子项，请输入：

   ```plaintext
   Create these subtasks as child items under issue #<selected_issue_number>.
   ```

   或者，使用后续提示请求进一步调整，直到您满意为止。
1. 按 <kbd>Enter</kbd> 或选择**发送**。
1. 极狐GitLab Duo 会准备工作项以供最终审核。阅读描述并查看 JSON 请求参数，
   然后选择**批准**。

   ![批准极狐GitLab Duo 准备的工作项。](img/approve_chat_v18_9.png)

这些议题会作为子项添加到您的议题中，聊天面板会显示它们的链接。然后您可以添加标记、分配议题或设置里程碑。

<a id="next-steps"></a>

## 后续步骤

恭喜！您已经学会了如何使用极狐GitLab Duo Chat 和计划者 Agent 进行简单的议题管理。

您可以继续细化子任务的细节，例如：

- `Can you provide more detail on task 3?`
- `Split task 2 into separate tasks`
- `Add technical implementation notes to these tasks`

或者，如果您只是将此作为实验尝试，可以关闭这些子任务：

```plaintext
Close these subtasks and add a comment in each that says: "This subtask was created as part of a tutorial exercise."
```

要查看您已完成的工作，可以返回之前的对话。
在极狐GitLab Duo 边栏中，选择 **极狐GitLab Duo Chat 历史**（{{< icon name="history" >}}）。

![对话历史列表。](img/chat_history_v18_9.png)
