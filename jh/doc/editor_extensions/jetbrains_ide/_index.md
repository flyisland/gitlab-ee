---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 JetBrains IDE 中连接并使用极狐GitLab Duo。
title: 适用于 JetBrains IDE 的极狐GitLab Duo 插件
---

[极狐GitLab Duo 插件](https://plugins.jetbrains.com/plugin/22325-gitlab-duo)将极狐GitLab Duo
与 IntelliJ、PyCharm、GoLand、Webstorm 和 Rubymine 等 JetBrains IDE 集成。

该插件包含以下功能：

- 在右侧工具窗口栏中，**极狐GitLab Duo Agent Platform**（{{< icon name="duo-agentic-chat" >}}）：
  - 聊天标签页：与极狐GitLab Duo Agentic Chat 交互，或使用 **新会话**（{{< icon name="duo-chat-new" >}}）
    下拉列表选择要使用的内置 Agent 或自定义 Agent。
  - 任务流标签页：使用软件开发任务流。详细了解
    [Chat 与任务流的区别](../software_development.md#flow-and-chat-comparison)。
- 在状态栏中，**Duo**（{{< icon name="tanuki-ai" >}}）：在编写代码时，查看
  极狐GitLab Duo 代码建议的功能状态，并在文件中查看建议。
- 在右侧工具窗口栏中，**GitLab Duo Non-Agentic Chat**（{{< icon name="duo-chat" >}}）：与
  GitLab Duo Non-Agentic Chat 交互。或者选择一些代码，然后在浮动工具栏中选择
  **极狐GitLab Duo 快速聊天**（{{< icon name="tanuki-ai" >}}）进行行内对话。

要开始使用，请[安装并配置](setup.md)该插件。

<a id="use-with-remote-development"></a>

## 与远程开发配合使用

当安装在主机（远程服务器）上时，极狐GitLab Duo 插件可与 JetBrains 远程开发配合使用。

> [!warning]
> 如果您使用远程开发，请仅在主机上安装该插件。
> 如果您同时在客户端（本地）机器上安装该插件，极狐GitLab Duo 功能将无法在您的 IDE 中正常工作。
有关在远程开发环境中安装插件的信息，请参阅 JetBrains 文档：

- [在远程项目中安装插件](https://www.jetbrains.com/help/idea/work-inside-remote-project.html#plugins)。
- [将插件添加到 Dev Containers](https://www.jetbrains.com/help/idea/customizing-devcontainer-json-file.html#add_plugins)。

<a id="enable-experimental-or-beta-features"></a>

## 启用实验或测试版功能

插件中的某些功能处于实验或测试版状态。要使用这些功能，您必须选择启用：

1. 转到 IDE 的顶部菜单栏，选择 **设置**，或者：
   - MacOS：按 <kbd>Command</kbd>+<kbd>,</kbd>
   - Windows 或 Linux：按 <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>S</kbd>
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
1. 选择 **启用实验性功能或 BETA 功能**。
1. 要应用更改，请重启 IDE。

<a id="update-the-extension"></a>

## 更新扩展

要将扩展更新到最新版本：

1. 在您的 JetBrains IDE 中，转到 **设置** > **插件**。
1. 在 **市场**中，选择由 **GitLab, Inc.** 发布的 **极狐GitLab Duo**。
1. 选择 **更新** 以更新到最新的插件版本。

<a id="enable-telemetry"></a>

## 启用遥测

极狐GitLab Duo 插件使用您 JetBrains IDE 中的遥测设置，将使用情况和错误
信息发送到极狐GitLab。要在您的 JetBrains IDE 中启用遥测：

1. 转到 IDE 的顶部菜单栏，选择 **设置**。例如，在 PyCharm 中，选择 **PyCharm** > **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
1. 在 **高级** 下，选中 **启用遥测** 复选框。
1. 选择 **确定** 或 **应用** 以保存更改。

<a id="integrate-with-1password-cli"></a>

## 与 1Password CLI 集成

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将插件配置为使用 1Password 密钥引用进行身份验证，而不是硬编码个人访问令牌。

先决条件：

- 您已安装 [1Password](https://1password.com) 桌面应用。
- 您已安装 [1Password CLI](https://www.1password.dev/cli/get-started) 工具。

要将适用于 JetBrains IDE 的极狐GitLab Duo 插件与 1Password CLI 集成：

1. 使用极狐GitLab 进行身份验证。任选其一：
   - [安装 `glab`](https://gitlab.cn/docs/cli/#install-the-cli) CLI 并
     配置 [1Password shell 插件](https://www.1password.dev/cli/shell-plugins/gitlab)。
   - 按照适用于 JetBrains IDE 的极狐GitLab Duo 插件[设置步骤](setup.md)操作。
1. 打开 1Password 条目。
1. [复制密钥引用](https://www.1password.dev/cli/secret-references#step-1-get-secret-references)。

   如果您使用 `gitlab` 1Password shell 插件，令牌将作为密码存储在 `"op://Private/GitLab Personal Access Token/token"` 下。

在 IDE 中：

1. 转到 IDE 的顶部菜单栏，选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
1. 在 **身份验证** 下，选择 **1Password CLI** 标签页。
1. 选择 **与 1Password CLI 集成**。
1. 可选。在 **密钥引用**中，粘贴您从 1Password 复制的密钥引用。
1. 可选。要验证您的凭据，请选择 **验证设置**。
1. 选择 **确定** 或 **保存**。

<a id="report-issues-with-the-plugin"></a>

## 报告插件问题

您可以在 [`gitlab-jetbrains-plugin` 议题跟踪器](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues)中报告任何问题、缺陷或功能请求。请使用 `Bug` 或 `Feature Proposal` 模板。

如果您在使用极狐GitLab Duo 时遇到错误，也可以使用 IDE 内置的错误报告工具进行报告：

1. 要访问该工具，任选其一：
   - 发生错误时，在错误消息中选择 **查看详情并提交报告**。
   - 在状态栏右下角，选择感叹号。
1. 在 **IDE 内部错误** 对话框中，描述该错误。
1. 选择 **报告并全部清除**。
1. 您的浏览器将打开一个 GitLab 议题表单，其中已预填调试信息。
1. 按照议题模板中的提示填写描述，尽可能
   提供更多上下文。
1. 选择 **创建议题** 以提交缺陷报告。
