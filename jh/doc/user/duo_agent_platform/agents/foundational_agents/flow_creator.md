---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 任务流创建器
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

任务流创建器是一款专门的 AI Agent，可帮助您为 AI 目录创建[自定义任务流](../../flows/custom.md)。用通俗语言描述您想要的任务流，该 Agent 会生成完整的任务流 YAML，您可以在 AI 目录中使用。

该 Agent 理解 Flow Registry 框架，包括组件、触发器、输入和路由。它在回答之前会查阅实时框架文档，因此其响应反映的是框架当前的能力，而非固定的快照。

在以下情况下使用任务流创建器：

- 创建任务流：根据您对任务流应执行的操作以及触发方式的描述，生成完整的任务流 YAML。
- 调试任务流：找出现有任务流配置无法通过验证或行为不符合预期的原因。
- 了解框架：了解哪些组件、参数和触发器可用，以及如何将它们组合在一起。

<a id="use-the-flow-creator"></a>

## 使用任务流创建器

先决条件：

- [开启](_index.md#turn-foundational-agents-on-or-off)内置 Agent。

要在极狐GitLab UI 中使用任务流创建器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在极狐GitLab Duo 侧边栏中，选择 **新会话** ({{< icon name="pencil-square" >}})。
1. 从下拉列表中，选择 **任务流创建器**。

   聊天会话将在屏幕右侧的极狐GitLab Duo 侧边栏中打开。
1. 描述您要创建的任务流。为获得最佳结果：

   - 描述应触发任务流的事件，例如，被指派到一个议题，或创建了新的合并请求。
   - 描述您想要的结果，而不是您认为需要的组件。该 Agent 会选择适当的组件。
   - 调试时，请粘贴完整的任务流 YAML，以便 Agent 根据框架规则进行验证。
1. 从 Agent 的响应中复制任务流 YAML，然后将其粘贴到您有权限创建任务流的项目中的[新任务流](../../flows/custom.md)界面。

<a id="example-prompts"></a>

## 示例提示词

- 创建任务流：
  - “创建一个任务流，在我被指派到议题时总结该议题。”
  - “创建一个任务流，根据议题描述为新议题添加标记。”
  - “创建一个任务流，在它对合并请求发表评论之前征求我的批准。”
- 调试任务流：
  - “为什么此任务流配置无法通过验证？`<flow YAML>`”
  - “此任务流一直运行不停。它有什么问题？`<flow YAML>`”
- 了解任务流的工作方式：
  - “如何将分支名称传递到我的任务流中？”
  - “在任务流中间，我应该使用哪个组件来请求用户输入？”

<a id="known-issues"></a>

## 已知问题

- 该 Agent 仅为 Flow Registry v1 Schema生成 YAML。
- 该 Agent 在响应前会阅读框架文档。因此，响应时间可能比其他 Agent 更长。
