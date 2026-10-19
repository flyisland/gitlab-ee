---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义 Agent
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="Model information" >}}

- 适用于[自部署模型的极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

Agent 使用 AI 来执行任务并回答复杂问题。创建自定义 Agent 以完成特定任务，例如创建合并请求或评审代码。或者，使用 AI 目录来发现由极狐GitLab 创建的 Agent。

当您准备好与 Agent 交互时，启用它，并开始在极狐GitLab UI、VS Code 和 JetBrains IDE 中通过极狐GitLab Duo Chat 使用它。

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../_index.md#prerequisites)。
- 已[开启自定义 Agent](#turn-custom-agents-on-or-off)。

<a id="agent-visibility"></a>

## Agent 可见性

> [!flag]
> **受限**可见性选项由名为 `ai_catalog_internal_visibility` 的功能标志控制。

当您创建自定义 Agent 时，您需要选择一个项目来管理它，并选择该 Agent 是公开、私有还是受限。

公开 Agent：

- 任何人都可以查看，并且可以在任何满足先决条件的项目中启用。

受限 Agent：

- 管理项目所在顶级群组中任何项目的成员都可以查看和使用。
- 可以在同一顶级群组中的其他项目中启用。
- 无法在该顶级群组之外查看或启用。
- 无法在探索的 AI 目录中查看。
- 只能从项目创建，不能从探索的 AI 目录创建。

如果公开 Agent 已被该顶级群组之外的项目启用，则您无法将其设为受限。

私有 Agent：

- 只有具有访客、计划者、报告者、开发者、维护者或所有者角色的管理项目成员才能查看。
- 无法在管理项目之外的其他项目中启用。

如果公开或受限 Agent 已被管理项目之外的其他项目启用，则您无法将其设为私有。

<a id="view-the-agents-for-your-project"></a>

## 查看项目的 Agent

先决条件：

- 您必须具有该项目的开发者、维护者或所有者角色。

要查看与您的项目关联的 Agent 列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
   - 要查看项目中已启用的 Agent，请选择 **已启用** 选项卡。
   - 要查看由项目管理的 Agent，请选择 **已管理** 选项卡。

选择一个 Agent 以查看其详细信息。

<a id="create-an-agent"></a>

## 创建 Agent

> [!flag]
> **受限**可见性选项由名为 `ai_catalog_internal_visibility` 的功能标志控制。

您可以从项目创建 Agent，或使用 AI 目录创建。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

{{< tabs >}}

{{< tab title="From a project" >}}

要创建 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
1. 选择 **新建 Agent**。
1. 在 **基本信息** 下：
   1. 在 **显示名称** 中，输入 Agent 的名称。
   1. 在 **描述** 中，输入 Agent 的描述。
1. 在 **可见性与访问** 下，对于 **可见性**，选择 **私有**、**受限** 或 **公开**。
1. 在 **提示词** 下，在 **系统提示词** 中，输入提示词以定义 Agent 的个性、专业知识和行为。
1. 可选。在 **可用工具** 下，从 **工具** 下拉列表中，选择 Agent 可以访问的工具。
   例如，要让 Agent 自动创建议题，请选择 **创建议题**。

   > [!note]
   > 某些工具需要 IDE 扩展，在 Web UI 中不可用。
   > 有关更多信息，请参阅 [Agent 工具](tools.md) 列表。
1. 选择 **创建 Agent**。

{{< /tab >}}

{{< tab title="From the AI Catalog" >}}

要创建 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** > **探索**。
1. 选择 **AI 目录**，然后选择 **Agents** 选项卡。
1. 选择 **新建 Agent**。
1. 在 **基本信息** 下：
   1. 在 **显示名称** 中，输入 Agent 的名称。
   1. 在 **描述** 中，输入 Agent 的描述。
1. 在 **可见性与访问** 下：
   1. 从 **由…管理** 下拉列表中，为 Agent 选择一个项目。
   1. 对于 **可见性**，选择 **私有** 或 **公开**。
1. 在 **提示词** 下，在 **系统提示词** 中，输入提示词以定义 Agent 的个性、专业知识和行为。
1. 可选。在 **可用工具** 下，从 **工具** 下拉列表中，选择 Agent 可以访问的工具。
   例如，要让 Agent 自动创建议题，请选择 **创建议题**。

   有关可用工具的列表，请参阅[内置工具定义](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/ai/catalog/built_in_tool_definitions.rb)。
1. 选择 **创建 Agent**。

{{< /tab >}}

{{< /tabs >}}

该 Agent 会出现在 AI 目录中。要将其与 Chat 一起使用，您必须启用它。

<a id="enable-an-agent"></a>

## 启用 Agent

启用 Agent 以将其与 Chat 一起使用。

当您在项目中启用 Agent 时，它也会同时在该项目的顶级群组中启用。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

{{< tabs >}}

{{< tab title="From the managing project" >}}

要启用 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
1. 选择 **已管理** 选项卡，然后选择要启用的 Agent。
1. 在右上角，选择 **启用**。
1. 在 **项目** 下，选择要启用该 Agent 的项目。
1. 选择 **启用**。

{{< /tab >}}

{{< tab title="From the AI Catalog" >}}

要启用 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** > **探索**。
1. 选择 **AI 目录**，然后选择 **Agents** 选项卡。
1. 选择要启用的 Agent。
1. 在右上角，选择 **启用**。
1. 在 **项目** 下，选择要启用该 Agent 的项目。

   要为多个项目启用公开或受限 Agent，请从 **项目** 下拉列表中，选择相关项目。您最多可以选择 100 个项目。

1. 选择 **启用**。

{{< /tab >}}

{{< /tabs >}}

该 Agent 会出现在群组和项目的 **AI** > **Agents** 页面中。
顶级群组中任何项目的成员现在都可以在其项目中启用该 Agent。

在项目中，您可以与该 Agent 开始新的聊天。
有关更多信息，请参阅[选择 Agent](../../gitlab_duo_chat/agentic_chat.md#select-an-agent)。

<a id="enable-in-a-project"></a>

### 在项目中启用

如果 Agent 已在顶级群组中启用，您可以在该群组的项目中启用它。

先决条件：

- 您必须具有该项目的维护者或所有者角色。
- 该 Agent 必须已在项目的顶级群组中启用。

要在项目中启用 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **AI** > **Agents**。
1. 在右上角，选择 **从群组启用 Agent**。
1. 从下拉列表中，选择要启用的 Agent。
1. 选择 **启用**。

该 Agent 会出现在项目的 **AI** > **Agents** 页面中。

在项目中，您可以与该 Agent 开始新的聊天。

<a id="use-an-agent"></a>

## 使用 Agent

您可以在极狐GitLab UI、VS Code 和 JetBrains IDE 中使用自定义 Agent。

<a id="in-the-gitlab-ui"></a>

### 在极狐GitLab UI 中

先决条件：

- 在您要使用 Agent 的项目中启用它。

要在极狐GitLab UI 中使用自定义 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 打开一个议题、史诗或合并请求。
1. 在极狐GitLab Duo 侧边栏中，选择 **添加新聊天** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择自定义 Agent。

   聊天对话将在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 输入您的问题或请求。

<a id="in-vs-code"></a>

### 在 VS Code 中

先决条件：

- 在您要使用 Agent 的项目中启用它。
- 安装并配置 [极狐GitLab for VS Code](../../../editor_extensions/visual_studio_code/setup.md)
  6.47.0 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

要在 VS Code 中使用自定义 Agent：

1. 在 VS Code 中，在左侧边栏中，选择 **极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}})。
1. 选择 **Chat** 选项卡。
1. 从 **新聊天** ({{< icon name="duo-chat-new" >}}) 下拉列表中，选择自定义 Agent。
1. 输入您的问题或请求。

<a id="in-jetbrains-ides"></a>

### 在 JetBrains IDE 中

先决条件：

- 在您要使用 Agent 的项目中启用它。
- 安装并配置 [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../../editor_extensions/jetbrains_ide/setup.md)
  3.19.0 或更高版本。
- 设置[默认极狐GitLab Duo 命名空间](../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

首先，启用极狐GitLab Duo Agent Platform：

1. 在您的 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
1. 在 **极狐GitLab Duo Agent Platform** 下，选中 **启用极狐GitLab Duo Agent Platform** 复选框。
1. 如果提示，请重启您的 IDE。

然后，要使用自定义 Agent：

1. 在您的 JetBrains IDE 中，在右侧工具窗口栏中，选择 **极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}})。
1. 选择 **Chat** 选项卡。
1. 从 **新聊天** ({{< icon name="duo-chat-new" >}}) 下拉列表中，选择自定义 Agent。
1. 输入您的问题或请求。

<a id="disable-an-agent"></a>

## 禁用 Agent

先决条件：

- 对于群组，您必须具有维护者或所有者角色。
- 对于项目，您必须具有维护者或所有者角色。

要禁用 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。
1. 选择 **AI** > **Agents**。
1. 找到要移除的 Agent，然后选择 **操作** ({{< icon name="ellipsis_v" >}}) > **禁用**。
1. 在确认对话框中，选择 **禁用**。

该 Agent 不再出现在项目中，并且在 Chat 中不可用。

<a id="duplicate-an-agent"></a>

## 复制 Agent

要修改 Agent 而不覆盖原始 Agent，请创建现有 Agent 的副本。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

要复制 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** > **探索**。
1. 选择 **AI 目录**，然后选择 **Agents** 选项卡。
1. 选择要复制的 Agent。
1. 在右上角，选择 **操作** ({{< icon name="ellipsis_v" >}}) > **复制**。
1. 可选。编辑您要更改的任何字段。
1. 选择 **创建 Agent**。

<a id="edit-an-agent"></a>

## 编辑 Agent

编辑 Agent 以更改其配置。

先决条件：

- 您必须是管理项目的成员，并且具有维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。
1. 选择 **AI** > **Agents**。
1. 选择要编辑的 Agent。
1. 在右上角，选择 **编辑**。
1. 编辑您要更改的任何字段，然后选择 **保存更改**。

<a id="hide-an-agent"></a>

## 隐藏 Agent

隐藏 Agent 以将其从 AI 目录中移除。

隐藏 Agent 后，用户无法再启用它。但是，他们仍然可以在已启用该 Agent 的群组和项目中与之交互。

先决条件：

- 您必须是管理项目的成员，并且具有维护者或所有者角色。

要隐藏 Agent：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。
1. 选择 **AI** > **Agents**。
1. 找到要隐藏的 Agent，然后选择 **操作** ({{< icon name="ellipsis_v" >}}) > **隐藏**。
1. 在确认对话框中，选择 **确认**。

<a id="delete-an-agent"></a>

## 删除 Agent

删除 Agent 以将其从实例中永久移除。

先决条件：

- 您必须是管理员。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组或项目。
1. 选择 **AI** > **Agents**。
1. 找到要删除的 Agent，然后选择 **操作** ({{< icon name="ellipsis_v" >}}) > **删除**。
1. 在确认对话框中，选择 **删除**。

<a id="turn-custom-agents-on-or-off"></a>

## 开启或关闭自定义 Agent

默认情况下，自定义 Agent 处于开启状态。
您可以为顶级群组或实例开启或关闭它们。

当自定义 Agent 被关闭时：

- 用户无法创建、启用、禁用或执行自定义 Agent。
- 现有的自定义 Agent 不再显示在项目的 **AI** > **Agents** > **已启用** 下。
- 在项目中创建的自定义 Agent 会显示在 **AI** > **Agents** > **已管理** 下，但无法执行。
- [内置 Agent](foundational_agents/_index.md) 和[外部 Agent](external.md) 仍然可用。

{{< tabs >}}

{{< tab title="GitLab.com" >}}

先决条件：

- 您必须具有该群组的所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **自定义和外部 Agent 及任务流** 下，选中或清除 **允许自定义 Agent** 复选框。
1. 选择 **保存更改**。

此设置会级联到群组中的所有子群组。

{{< /tab >}}

{{< tab title="GitLab Self-Managed" >}}

先决条件：

- 您必须是管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **自定义和外部 Agent 及任务流** 下，选中或清除 **允许自定义 Agent** 复选框。
1. 选择 **保存更改**。

当实例级设置被禁用时，群组级设置无法覆盖它。

{{< /tab >}}

{{< /tabs >}}
