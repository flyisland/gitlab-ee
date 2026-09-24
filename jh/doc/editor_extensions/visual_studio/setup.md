---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use GitLab Duo in Visual Studio.
title: 安装和设置适用于 Visual Studio 的极狐GitLab 扩展
---

您可以通过以下任一方式获取扩展：

- 在 Visual Studio 活动栏中选择 **扩展**，然后搜索 `GitLab for Visual Studio`。
- 从 [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=GitLab.GitLabExtensionForVisualStudio) 获取。
- 从极狐GitLab 获取，既可以从 [发布列表](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-visual-studio-extension/-/releases) 中获取，也可以 [直接下载最新版本](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-visual-studio-extension/-/releases/permalink/latest/downloads/GitLab.Extension.vsix)。

该扩展要求：

- Visual Studio 2022 17.6 或更高版本（AMD64 或 Arm64）。
- 适用于 Visual Studio 的 [IntelliCode](https://visualstudio.microsoft.com/services/intellicode/) 组件。
- 极狐GitLab 16.1 或更高版本。
  - 极狐GitLab Duo 代码建议需要 极狐GitLab 16.8 或更高版本。
- 您未使用 Visual Studio for Mac，因为其不受支持。

启用此功能不会收集额外的新数据。非公开的极狐GitLab 客户数据不会被用作训练数据。

<a id="connect-to-gitlab"></a>

## 连接到极狐GitLab

安装扩展后，通过创建个人访问令牌并向极狐GitLab 进行身份验证，将其连接到您的极狐GitLab 账户。

<a id="create-a-personal-access-token"></a>

### 创建个人访问令牌

如果您使用极狐GitLab 私有化部署，请创建个人访问令牌。

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **个人访问令牌**。
1. 选择 **添加新令牌**。
1. 输入名称、描述和过期日期。
1. 选择 `api` 和 `read_user` 权限范围。
1. 选择 **创建个人访问令牌**。

<a id="authenticate-with-gitlab"></a>

### 向极狐GitLab 进行身份验证

要验证身份：

1. 在 Visual Studio 顶部栏中，进入 **工具** > **选项** > **极狐GitLab**。
1. 在 **访问令牌** 文本框中粘贴您的令牌。令牌不显示，也无法被他人访问。
1. 在 **极狐GitLab URL** 文本框中，输入您的极狐GitLab 实例的 URL。对于 JihuLab.com，使用 `https://jihulab.com`。

<a id="enable-telemetry"></a>

## 启用遥测

极狐GitLab 扩展使用 Visual Studio 中的遥测设置向极狐GitLab 发送使用情况和错误信息。要为 Visual Studio 中的极狐GitLab 启用遥测：

1. 在 Visual Studio 顶部栏中，进入 **工具** > **选项**。
1. 在左侧边栏中，展开 **极狐GitLab** 并选择 **通用**。
1. 在 **启用遥测** 下拉列表中，选择 **True**。
1. 选择 **确定**。

<a id="configure-the-extension"></a>

## 配置扩展

此扩展提供了可用于极狐GitLab 的自定义命令。大多数命令没有默认的键盘快捷键，以避免与您现有的 Visual Studio 配置冲突。

| 命令名称 | 默认键盘快捷键 | 描述 |
| --- | --- | --- |
| `GitLab.ToggleCodeSuggestions` | 无 | 开启或关闭 代码建议。 |
| `GitLab.OpenDuoChat` | 无 | 打开 极狐GitLab Duo Chat。 |
| `GitLab.GitLabDuoNextSuggestions` | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>N</kbd> | 切换到下一个代码建议。 |
| `GitLab.GitLabDuoPreviousSuggestions` | 无 | 切换到上一个代码建议。 |
| `GitLab.GitLabExplainTerminalWithDuo` | <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>E</kbd> | 解释终端中选中的文本。 |
| `GitLabDuoChat.ExplainCode` | 无 | 解释选中的代码。 |
| `GitLabDuoChat.Fix` | 无 | 修复选中代码的问题。 |
| `GitLabDuoChat.GenerateTests` | 无 | 为选中的代码生成测试。 |
| `GitLabDuoChat.Refactor` | 无 | 重构选中的代码。 |

您可以通过键盘快捷键访问扩展的自定义命令，并可自定义快捷键：

1. 在顶部栏中，进入 **工具** > **选项**。
1. 进入 **环境** > **键盘**。搜索 `GitLab.`。
1. 选择一个命令，并为它分配键盘快捷键。

<a id="configure-gitlab-duo"></a>

### 配置 极狐GitLab Duo

满足前提条件时，默认会启用 极狐GitLab Duo 功能：

- 对于 agentic 功能，您需满足 [极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md#prerequisites) 的前提条件。
- 您已经 [开启](../../user/gitlab_duo/turn_on_off.md) 了 极狐GitLab Duo。
- 对于流程，您已经 [开启了基础流程](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 您的项目位于 [群组命名空间](../../user/namespace/_index.md) 中。
- 您已经设置了 [默认的极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)，或者打开了一个具有极狐GitLab Duo 访问权限的项目。
- 对于 极狐GitLab Duo 代码建议，您需要 [满足额外的前提条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。

