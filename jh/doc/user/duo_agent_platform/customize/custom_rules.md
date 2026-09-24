---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义规则
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 自定义规则在极狐GitLab 18.2 中添加。
- 在极狐GitLab 18.8 中 GA。
- 在极狐GitLab 18.11 中引入了对极狐GitLab UI 的支持。

{{< /history >}}

您可以在极狐GitLab Duo Agent Platform 中使用自定义规则，以确保生成的输出（例如代码或文档）符合您的特定指令或任何其他要求，如开发风格指南。

以下 Agent Platform 功能支持自定义规则：

- [极狐GitLab Duo Agentic Chat](../../gitlab_duo_chat/agentic_chat.md) 在极狐GitLab UI 中。
- [基础和自定义 Agent](../agents/_index.md)。
- [基础和自定义流](../flows/_index.md)，不包括代码审查流。

<a id="create-custom-rules"></a>

## 创建自定义规则

您可以根据使用极狐GitLab Duo 的方式在两个级别创建自定义规则：

| 级别 | 极狐GitLab UI |
|-----------------------------------------------------------------|--------------|
| 用户级：适用于您的所有项目和工作区 | {{< no >}} |
| 工作区级：仅适用于特定项目或工作区 | {{< yes >}} |

如果同时存在用户级和工作区级规则，极狐GitLab Duo Chat 会将两者应用于对话中。

前提条件：

- 满足 [Agent Platform 前提条件](../_index.md#prerequisites)。

> [!note]
> 在您创建任何自定义规则之前已存在的对话不会遵循这些规则。

<a id="create-workspace-level-custom-rules"></a>

### 创建工作区级自定义规则

工作区级自定义规则仅适用于特定项目或工作区。您可以使用此方法为团队在项目中应用一套自定义规则。例如，您可以应用团队使用的一套开发风格指南。

1. 在您的项目工作区中创建自定义规则文件：`.gitlab/duo/chat-rules.md`。
1. 将自定义规则添加到文件中。例如：

   ```markdown
   - 不要在生成的代码中添加注释
   - 解释要简明扼要
   - 对于 JavaScript 字符串始终使用单引号
   ```

1. 保存文件。
1. 对于项目：将 `.gitlab/duo/chat-rules.md` 文件添加到 Git 仓库中。
   Chat、Agent 和流随后会自动从仓库读取自定义规则到上下文中。
1. 要应用新的自定义规则，请开始一个新的极狐GitLab Duo 对话。

   每次更改自定义规则后都必须这样做。

有关更多信息，请参阅[极狐GitLab Duo Chat 自定义规则教程博客](https://gitlab.cn/blog/custom-rules-duo-agentic-chat-deep-dive/)。

<a id="update-custom-rules"></a>

## 更新自定义规则

要更新自定义规则，请编辑并保存自定义规则文件。然后，开始一个新的极狐GitLab Duo 对话以应用更新后的规则。

您无法直接使用 Chat 编辑自定义规则文件。

要管理必须批准自定义规则更改的人员，请使用 [Code Owners](../../project/codeowners/_index.md)。