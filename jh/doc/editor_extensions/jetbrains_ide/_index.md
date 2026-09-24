---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use GitLab Duo in JetBrains IDEs.
title: 适用于 JetBrains IDE 的极狐GitLab Duo 插件
---

[极狐GitLab Duo 插件](https://plugins.jetbrains.com/plugin/22325-gitlab-duo) 将极狐GitLab Duo 与 JetBrains IDE（如 IntelliJ、PyCharm、GoLand、Webstorm 和 Rubymine）进行集成。

安装并配置扩展后，你可以访问以下功能：

- 在右侧工具窗口栏上，**极狐GitLab Duo Agent Platform** ({{< icon name="duo-agentic-chat" >}}):
  - 聊天选项卡：与 极狐GitLab Duo Agentic 聊天交互，或使用 **新会话** ({{< icon name="duo-chat-new" >}})
    下拉列表选择一个基础或自定义 Agent 进行协作。
  - 流程选项卡：使用 软件开发流程。了解有关[聊天与流程之间的区别](../../user/duo_agent_platform/flows/foundational_flows/software_development.md#flow-and-chat-comparison)的详细信息。
- 在状态栏中，**Duo** ({{< icon name="tanuki-ai" >}}): 检查 极狐GitLab Duo 代码建议的功能状态，并在编写代码时查看文件中的建议。
- 在右侧工具窗口栏上，**极狐GitLab Duo 非 Agent 聊天** ({{< icon name="duo-chat" >}}): 与 极狐GitLab Duo 非 Agent 聊天进行交互。或者选择一些代码，然后在浮动工具栏中选择 **极狐GitLab Duo 快速聊天** ({{< icon name="tanuki-ai" >}}) 进行内联对话。

<a id="use-with-remote-development"></a>

## 与远程开发配合使用

当安装在主机（远程服务器）上时，极狐GitLab Duo 插件可与 JetBrains 远程开发配合使用。

有关在远程开发环境中安装插件的信息，请参阅 JetBrains 文档：

- [在远程项目中安装插件](https://www.jetbrains.com/help/idea/work-inside-remote-project.html#plugins)。
- [向开发容器添加插件](https://www.jetbrains.com/help/idea/customizing-devcontainer-json-file.html#add_plugins)。

<a id="enable-experimental-or-beta-features"></a>

## 启用实验性功能或 Beta 功能

插件中的某些功能处于实验或 Beta 状态。要使用它们，你必须选择加入：

1. 前往你 IDE 的顶部菜单栏，选择 **设置**，或：
   - MacOS：按 <kbd>Command</kbd>+<kbd>,</kbd>
   - Windows 或 Linux：按 <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>S</kbd>
1. 在左侧边栏中，展开 **工具**，然后选择 **GitLab Duo**。
1. 选择 **启用实验性功能或 BETA 功能**。
1. 要应用更改，请重启你的 IDE。

<a id="update-the-extension"></a>

## 更新扩展

要将扩展更新到最新版本：

1. 在你的 JetBrains IDE 中，前往 **设置** > **插件**。
1. 在 **市场** 中，选择由 **极狐GitLab** 发布的 **极狐GitLab Duo**。
1. 选择 **更新** 以更新到最新的插件版本。

<a id="enable-telemetry"></a>

## 启用遥测

极狐GitLab Duo 插件使用 JetBrains IDE 中的遥测设置，将使用情况和错误信息发送到 极狐GitLab。要在你的 JetBrains IDE 中启用遥测：

1. 前往你 IDE 的顶部菜单栏，选择 **设置**。例如，在 PyCharm 中，选择 **PyCharm** > **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **GitLab Duo**。
1. 在 **高级** 下，勾选 **启用遥测** 复选框。
1. 选择 **确定** 或 **应用** 保存你的更改。

<a id="integrate-with-1password-cli"></a>

## 与 1Password CLI 集成

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab Duo 2.1 中为 极狐GitLab 16.11 及更高版本引入。

{{< /history >}}

你可以配置插件使用 1Password 密钥引用进行身份验证，而不是硬编码个人访问令牌。

先决条件：

- 你已安装 [1Password](https://1password.com) 桌面应用。
- 你已安装 [1Password CLI](https://developer.1password.com/docs/cli/get-started/) 工具。

要将适用于 JetBrains IDE 的极狐GitLab Duo 插件与 1Password CLI 集成：

1. 与 极狐GitLab 进行身份验证。可以选择：
   - [安装 `glab`](https://gitlab.cn/docs/cli/#install-the-cli) CLI 并配置 [1Password shell 插件](https://developer.1password.com/docs/cli/shell-plugins/gitlab/)。
   - 按照适用于 JetBrains IDE 的极狐GitLab Duo 插件的[设置步骤](setup.md)操作。
1. 打开 1Password 条目。
1. [复制密钥引用](https://developer.1password.com/docs/cli/secret-references/#step-1-copy-secret-references)。

   如果你使用 `gitlab` 1Password shell 插件，令牌将作为密码存储在 `"op://Private/GitLab Personal Access Token/token"` 下。

在 IDE 中：

1. 前往你 IDE 的顶部菜单栏，选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **GitLab Duo**。
1. 在 **身份验证** 下，选择 **1Password CLI** 选项卡。
1. 选择 **与 1Password CLI 集成**。
1. 可选。在 **密钥引用** 中，粘贴你从 1Password 复制的密钥引用。
1. 可选。要验证你的凭证，选择 **验证设置**。
1. 选择 **确定** 或 **保存**。

<a id="report-issues-with-the-plugin"></a>

## 报告插件问题

你可以在 [`gitlab-jetbrains-plugin` 议题跟踪器](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-jetbrains-plugin/-/issues)中报告任何问题、Bug 或功能请求。使用 `Bug` 或 `Feature Proposal` 模板。

如果在使用 极狐GitLab Duo 时遇到错误，你也可以使用 IDE 的内置错误报告工具进行报告：

1. 要访问该工具，可以选择：
   - 发生错误时，在错误信息中，选择 **查看详情并提交报告**。
   - 在状态栏右下角，选择感叹号。
1. 在 **IDE 内部错误** 对话框中，描述错误。
1. 选择 **报告并全部清除**。
1. 你的浏览器将打开一个 极狐GitLab 议题表单，已预填调试信息。
1. 按照议题模板中的提示填写描述，提供尽可能多的上下文。
1. 选择 **创建议题** 以提交 Bug 报告。

