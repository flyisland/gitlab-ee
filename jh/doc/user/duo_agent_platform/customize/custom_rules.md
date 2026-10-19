---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义规则
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在极狐GitLab Duo Agent Platform 中使用自定义规则，
以确保生成的输出（例如代码或文档）符合您的特定指令，或满足任何其他要求，例如开发风格指南。

以下 Agent Platform 功能支持自定义规则：

- 极狐GitLab UI 和本地环境中的
  [极狐GitLab Duo Agentic Chat](../../gitlab_duo_chat/agentic_chat.md)。
- [内置和自定义 Agent](../agents/_index.md)。
- [内置和自定义任务流](../flows/_index.md)，不包括代码评审任务流。

<a id="create-custom-rules"></a>

## 创建自定义规则

您可以根据使用极狐GitLab Duo 的方式，在两个级别创建自定义规则：

| 级别                                                           | 极狐GitLab UI | 编辑器扩展 | 极狐GitLab Duo CLI |
|-----------------------------------------------------------------|--------------------------|------------------|--------------|
| 用户级：应用于您的所有项目        | {{< no >}}  |  {{< yes >}}    | {{< yes >}} |
| 项目级：仅应用于特定项目  | {{< yes >}} | {{< yes >}}         | {{< yes >}} |

如果您在 IDE 中使用多根工作区，可以为工作区中的每个项目创建项目级自定义规则。

如果同时存在用户级和项目级规则，极狐GitLab Duo Chat 会将两者都应用于对话。

先决条件：

- 满足 [Agent Platform 先决条件](../_index.md#prerequisites)。
- 对于本地环境中的极狐GitLab Duo，请安装并配置以下任一工具：
  - [GitLab for VS Code](../../../editor_extensions/visual_studio_code/setup.md) 6.32.2 或更高版本。
  - [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../../editor_extensions/jetbrains_ide/setup.md) 3.12.2
    或更高版本。
  - [GitLab for Visual Studio](../../../editor_extensions/visual_studio/setup.md) 0.60.0 或更高版本。
  - [极狐GitLab Duo CLI](../../gitlab_duo_cli/set_up.md) 8.43.0 或更高版本。

> [!note]
> 在您创建任何自定义规则之前就已存在的对话不会遵循这些规则。

<a id="create-user-level-custom-rules"></a>

### 创建用户级自定义规则

用户级自定义规则会应用于您本地环境中的所有项目。

1. 在主目录中创建自定义规则文件：
   - 在 Linux 或 macOS 上，在 `~/.gitlab/duo/chat-rules.md` 处创建该文件。
   - 在 Windows 上，在 `%APPDATA%\GitLab\duo\chat-rules.md` 处创建该文件。
1. 向该文件添加自定义规则。例如：

   ```markdown
   - Don't put comments in the generated code
   - Be brief in your explanations
   - Always use single quotes for JavaScript strings
   ```

1. 保存该文件。
1. 要应用新的自定义规则，请根据情况执行以下任一操作：
   - 启动新的极狐GitLab Duo Chat 对话。
   - 在 Chat 对话、讨论、议题或合并请求中使用 Agent。
   - 触发任务流。

如果您设置了特定的环境变量，则需要在其他位置创建自定义规则文件：

- 如果您设置了 `GLAB_CONFIG_DIR` 环境变量，
  请在 `$GLAB_CONFIG_DIR/chat-rules.md` 处创建该文件。
- 如果您设置了 `XDG_CONFIG_HOME` 环境变量，
  请在 `$XDG_CONFIG_HOME/gitlab/duo/chat-rules.md` 处创建该文件。

<a id="create-project-level-custom-rules"></a>

### 创建项目级自定义规则

项目级自定义规则仅应用于特定项目。您可以使用此方法为团队在项目中应用一组自定义规则。例如，可以应用团队使用的一套开发风格指南。

1. 在项目的根目录中，创建自定义规则文件：`.gitlab/duo/chat-rules.md`。
1. 向该文件添加自定义规则。例如：

   ```markdown
   - Don't put comments in the generated code
   - Be brief in your explanations
   - Always use single quotes for JavaScript strings
   ```

1. 保存该文件。
1. 对于项目：将 `.gitlab/duo/chat-rules.md` 文件添加到 Git 代码仓库。
   随后 Chat、Agent 和任务流会自动从
   代码仓库中读取自定义规则并纳入上下文。
1. 要应用新的自定义规则，请启动新的极狐GitLab Duo 对话。

   每次更改自定义规则时都必须执行此操作。

有关更多信息，请参阅 [GitLab Duo Chat 中的自定义规则教程博客](https://about.gitlab.com/blog/custom-rules-duo-agentic-chat-deep-dive/)。

<a id="update-custom-rules"></a>

## 更新自定义规则

要更新自定义规则，请编辑并保存自定义规则文件。然后，启动新的极狐GitLab Duo 对话以应用更新后的规则。

您无法使用 Chat 直接编辑自定义规则文件。

要管理谁必须批准对自定义规则的任何更改，请使用[代码所有者](../../project/codeowners/_index.md)。
