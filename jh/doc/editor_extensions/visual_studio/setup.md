---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 Visual Studio 中连接并使用极狐GitLab Duo。
title: 安装并设置 GitLab for Visual Studio 扩展
---

要获取该扩展，请使用以下任一方法：

- 在 Visual Studio 中，从活动栏选择**扩展**，然后搜索 `GitLab for Visual Studio`。
- 从 [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=GitLab.GitLabExtensionForVisualStudio) 获取。
- 从 GitLab 获取，可以访问
  [版本列表](https://gitlab.com/gitlab-org/editor-extensions/gitlab-visual-studio-extension/-/releases)，或直接
  [下载最新的 `GitLab.Extension.vsix` 软件包](https://gitlab.com/gitlab-org/editor-extensions/gitlab-visual-studio-extension/-/releases)。

该扩展需要：

- Visual Studio 2022 版本 17.6 或更高版本（AMD64 或 Arm64）。
- Visual Studio 的 [IntelliCode](https://visualstudio.microsoft.com/services/intellicode/) 组件。
- 极狐GitLab 版本 16.1 或更高版本。
  - 极狐GitLab Duo 代码建议需要极狐GitLab 版本 16.8 或更高版本。
- 您未使用 Visual Studio for Mac，因为该版本不受支持。

启用此功能不会收集任何新的额外数据。私有的非公开极狐GitLab 客户数据不会用作训练数据。
详细了解 Gemini Enterprise Agent Platform 的数据治理。

<a id="connect-to-gitlab"></a>

## 连接到极狐GitLab

安装扩展后，通过创建个人访问令牌并使用极狐GitLab 进行身份验证，将其连接到您的极狐GitLab 账号。

<a id="create-a-personal-access-token"></a>

### 创建个人访问令牌

如果您使用的是极狐GitLab 私有化部署，请创建个人访问令牌。

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **个人访问令牌**。
1. 选择**添加新令牌**。
1. 输入名称、描述和到期日期。
1. 选择 `api` 和 `read_user` 作用域。
1. 选择**创建个人访问令牌**。

<a id="authenticate-with-gitlab"></a>

### 使用极狐GitLab 进行身份验证

要使用极狐GitLab 进行身份验证：

1. 在 Visual Studio 中，从顶部栏转到**工具** > **选项** > **GitLab**。
1. 在**访问令牌**文本框中，粘贴您的令牌。该令牌不会显示，其他人也无法访问。
1. 在 **极狐GitLab URL** 文本框中，输入您的极狐GitLab 实例的 URL。对于 JihuLab.com，请使用 `https://gitlab.com`。

<a id="enable-telemetry"></a>

## 启用遥测

GitLab 扩展使用 Visual Studio 中的遥测设置向极狐GitLab 发送使用情况和错误信息。要在 GitLab for Visual Studio 中启用遥测：

1. 在 Visual Studio 中，从顶部栏转到**工具** > **选项**。
1. 在左侧边栏中，展开 **GitLab** 并选择**常规**。
1. 在**启用遥测**下拉列表中，选择 **True**。
1. 选择**确定**。

<a id="configure-the-extension"></a>

## 配置扩展

此扩展提供了可与极狐GitLab 一起使用的自定义命令。大多数命令没有默认键盘快捷键，以避免与您现有的 Visual Studio 配置冲突。

| 命令名称                          | 默认键盘快捷键                   | 描述 |
|---------------------------------------|---------------------------------------------|-------------|
| `GitLab.ToggleCodeSuggestions`        | 无                                        | 打开或关闭代码建议。 |
| `GitLab.OpenDuoChat`                  | 无                                        | 打开极狐GitLab Duo Chat。 |
| `GitLab.GitLabDuoNextSuggestions`     | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>N</kbd> | 切换到下一个代码建议。 |
| `GitLab.GitLabDuoPreviousSuggestions` | 无                                        | 切换到上一个代码建议。 |
| `GitLab.GitLabExplainTerminalWithDuo` | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>E</kbd> | 解释终端中选中的文本。 |
| `GitLabDuoChat.ExplainCode`           | 无                                        | 解释选中的代码。 |
| `GitLabDuoChat.Fix`                   | 无                                        | 修复选中代码的问题。 |
| `GitLabDuoChat.GenerateTests`         | 无                                        | 为选中的代码生成测试。 |
| `GitLabDuoChat.Refactor`              | 无                                        | 重构选中的代码。 |

您可以使用键盘快捷键访问扩展的自定义命令，并可以自定义这些快捷键：

1. 在顶部栏中，转到**工具** > **选项**。
1. 转到**环境** > **键盘**。搜索 `GitLab.`。
1. 选择一个命令，并为其分配键盘快捷键。

<a id="configure-gitlab-duo"></a>

### 配置极狐GitLab Duo

当您满足先决条件时，极狐GitLab Duo 功能默认启用：

- 对于 Agent 功能，您满足[极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md#prerequisites)的先决条件。
- 您已[开启](../../user/gitlab_duo/turn_on_off.md)极狐GitLab Duo。
- 对于任务流，您已[开启内置任务流](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 对于代码建议，您满足[其他先决条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。
- 您的项目位于[群组命名空间](../../user/namespace/_index.md)中。
- 您已设置[默认极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)，
  或打开了一个具有极狐GitLab Duo 访问权限的项目。

<a id="turn-code-suggestions-on-or-off"></a>

#### 打开或关闭代码建议

代码建议默认开启。

要在 Visual Studio 中打开或关闭代码建议，可以：

- 在顶部栏中，选择**扩展** > **GitLab** > **切换代码建议**。
- 为 `GitLab.ToggleCodeSuggestions`
  命令[分配键盘快捷键](#configure-the-extension)，然后使用该快捷键。

<a id="uninstall-the-extension"></a>

## 卸载扩展

要禁用或卸载该扩展，请参阅
[Microsoft Visual Studio 关于卸载或禁用扩展的文档](https://learn.microsoft.com/en-us/visualstudio/ide/finding-and-using-visual-studio-extensions?view=vs-2022#uninstall-or-disable-an-extension)。
