---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use GitLab Duo in JetBrains IDEs.
title: 故障排除 JetBrains
---

如果本页的步骤无法解决您的问题，请查看 JetBrains 插件项目中的开放议题列表。如果某个议题与您的问题匹配，请更新该议题。如果没有匹配的议题，请创建一个新议题，并提供[支持所需的信息](#required-information-for-support)。

<a id="gitlab-duo-features-are-unavailable"></a>

## 极狐GitLab Duo 功能不可用

要在 IDE 中排除极狐GitLab Duo 错误：

1. 确保您满足[前提条件](setup.md#configure-gitlab-duo)并且必要的设置已开启。
1. 确保[管理员模式已禁用](../../administration/settings/sign_in_restrictions.md#turn-off-admin-mode-for-your-session)。
1. 查看诊断输出：
   - 在您的 JetBrains IDE 中，转到 **工具** > **极狐GitLab** > **诊断** 并查看输出，检查是否有任何失败的检查。
1. 如果诊断表明功能未启用：
   1. 在您的 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
   1. 找到并选中复选框以启用缺失的功能。
   1. 选择 **确定** 或 **保存**。
   1. 如果提示，重启您的 IDE。
1. 如果诊断表明当前项目不支持 Agentic 聊天，请[设置默认的极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)。

有关代码建议的支持，请参阅[代码建议故障排除](../../user/project/repository/code_suggestions/troubleshooting.md#jetbrains-ides-troubleshooting)。

<a id="network-issues"></a>

## 网络问题

如果您在日志中看到来自极狐GitLab Duo 的 `HTTP/1.1` 响应，而不是 `/-/cable` WebSocket 端点，则您的 WebSocket 连接可能被阻止。

您的极狐GitLab 实例必须允许来自 IDE 客户端的入站 WebSocket 连接。如果您怀疑是此问题，请让您的网络管理员[允许 WebSocket 流量到您的极狐GitLab 实例](../../administration/gitlab_duo/configure/_index.md#allow-inbound-connections-from-clients-to-the-gitlab-instance)。

<a id="ide-commands-fail-or-run-indefinitely"></a>

## IDE 命令失败或无限运行

在您的 IDE 中使用极狐GitLab Duo Agentic 聊天或软件开发流程时，极狐GitLab Duo 可能会陷入循环或难以运行命令。

当您使用 shell 主题或集成（如 `Oh My ZSH!` 或 `powerlevel10k`）时，可能会发生此问题。当极狐GitLab Duo Agent 生成终端时，主题或集成可能会阻止命令正常运行。

作为临时解决方法，为代理发送的命令使用更简单的主题。VS Code 扩展项目中的议题 2070 跟踪了对此行为的改进，以便不再需要此解决方法。

<a id="edit-your-zshrc-file"></a>

### 编辑您的 `.zshrc` 文件

在 VS Code 和 JetBrains IDE 中，配置 `Oh My ZSH!` 或 `powerlevel10k`，使其在运行代理发送的命令时使用更简单的主题。您可以使用 IDE 暴露的环境变量来设置这些值。

编辑您的 `~/.zshrc` 文件以包含以下代码：

```shell
# ~/.zshrc

# oh-my-zsh 安装路径
export ZSH="$HOME/.oh-my-zsh"

# ...

# 决定是否加载完整的终端环境，
# 还是为 IDE 中的 agentic AI 保持最小化
if [[ "$TERM_PROGRAM" == "vscode" || "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]]; then
  echo "检测到 IDE agentic 环境，不加载完整的 shell 集成"
else
  # Oh My ZSH
  source $ZSH/oh-my-zsh.sh
  # 主题：Powerlevel10k
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  # 其他集成，如语法高亮
fi

# 其他设置，如 PATH 变量
```

<a id="enable-debug-mode"></a>

## 启用调试模式

要在 JetBrains 中启用调试日志：

1. 在顶部栏中，转到 **帮助** > **诊断工具** > **调试日志设置**，或通过转到 **帮助** > **查找操作** > **调试日志设置** 搜索该操作。
1. 添加此行：`com.gitlab.plugin`
1. 选择 **确定** 或 **保存**。

如果您遇到[证书错误](#certificate-errors)或其他连接错误，并且使用 HTTP 代理连接到您的极狐GitLab 实例，则必须为极狐GitLab Language Server [配置 Language Server 以使用代理](../language_server/_index.md#configure-the-language-server-to-use-a-proxy)。

您还可以[启用代理身份验证](../language_server/_index.md#enable-proxy-authentication)。

<a id="enable-gitlab-language-server-debug-logs"></a>

## 启用极狐GitLab Language Server 调试日志

要启用极狐GitLab Language Server 调试日志：

1. 在您的 IDE 中，在顶部栏中，选择您的 IDE 名称，然后选择 **设置**。
1. 在左侧边栏中，选择 **工具** > **极狐GitLab Duo**。
1. 选择 **极狐GitLab Language Server** 以展开该部分。
1. 在 **日志** > **日志级别** 中，输入 `debug`。
1. 选择 **应用**。
1. 在 **启用极狐GitLab Language Server** 下方，选择 **重启 Language Server**。

<a id="get-debug-logs"></a>

## 获取调试日志

调试日志可在 `idea.log` 日志文件中找到。要查看此文件，可以：

<!-- vale gitlab_base.SubstitutionWarning = NO -->

- 在您的 IDE 中，转到 **帮助** > **在 Finder 中显示日志**。
- 转到目录 `/Users/<user>/Library/Logs/JetBrains/IntelliJIdea<build_version>`，将 `<user>` 和 `<build_version>` 替换为适当的值。

<!-- vale gitlab_base.SubstitutionWarning = YES -->

<a id="certificate-errors"></a>

## 证书错误

如果您的机器通过代理连接到极狐GitLab 实例，您可能会在 JetBrains 中遇到 SSL 证书错误。极狐GitLab Duo 尝试检测系统存储中的证书；但是，Language Server 无法执行此操作。如果您看到来自 Language Server 的关于证书的错误，请尝试启用传递证书颁发机构 (CA) 证书的选项：

为此：

1. 在 IDE 的右下角，选择极狐GitLab 图标。
1. 在对话框中，选择 **显示设置**。这将打开 **设置** 对话框，并定位到 **工具** > **极狐GitLab Duo**。
1. 选择 **极狐GitLab Language Server** 以展开该部分。
1. 选择 **HTTP 代理选项** 以展开它。
1. 要么：
   - 选择选项 **将 CA 证书从 Duo 传递到 Language Server**。
   - 在 **证书颁发机构 (CA)** 中，指定您的 `.pem` 文件路径（包含 CA 证书）。
1. 重启您的 IDE。

<a id="ignore-certificate-errors"></a>

### 忽略证书错误

如果极狐GitLab Duo 仍然无法连接，您可能需要忽略证书错误。在启用[调试模式](jetbrains_troubleshooting.md#enable-debug-mode)后，您可能会在极狐GitLab Language Server 日志中看到错误：

```plaintext
2024-10-31T10:32:54:165 [错误]: 获取：请求 https://gitlab.com/api/v4/personal_access_tokens/self 失败，原因：
请求 https://gitlab.com/api/v4/personal_access_tokens/self 失败，原因：无法获取本地颁发者证书
FetchError: 请求 https://gitlab.com/api/v4/personal_access_tokens/self 失败，原因：无法获取本地颁发者证书
```

从设计上讲，此设置存在安全风险：这些错误会提醒您潜在的安全漏洞。只有在您绝对确定代理导致问题时，才应启用此设置。

前提条件：

- 您已在系统浏览器或机器管理员处验证了证书链，或已确认忽略此错误是安全的。

为此：

1. 请参阅 JetBrains 关于 [SSL 证书](https://www.jetbrains.com/help/idea/ssl-certificates.html)的文档。
1. 转到 IDE 的顶部菜单栏，选择 **设置**。
1. 在左侧边栏中，选择 **工具** > **极狐GitLab Duo**。
1. 确认您的默认浏览器信任您正在使用的 **极狐GitLab 实例 URL**。
1. 启用 **忽略证书错误** 选项。
1. 选择 **验证设置**。
1. 选择 **确定** 或 **保存**。

<a id="authentication-fails-in-pycharm"></a>

### PyCharm 中身份验证失败

如果在极狐GitLab 身份验证的 **验证设置** 阶段遇到问题，请确认您正在运行受支持的 PyCharm 版本：

1. 转到[插件兼容性](https://plugins.jetbrains.com/plugin/22325-gitlab-duo/versions)页面。
1. 对于 **兼容性**，选择 `PyCharm Community` 或 `PyCharm Professional`。
1. 对于 **渠道**，选择您所需的 GitLab 插件稳定性级别。
1. 对于您的 PyCharm 版本，选择 **下载** 以下载正确的 GitLab 插件版本，并进行安装。

<a id="jcef-errors"></a>

## JCEF 错误

如果您遇到与 JCEF（Java Chromium 嵌入式框架）相关的极狐GitLab Duo Chat 问题，可以尝试以下步骤：

1. 在顶部栏中，转到 **帮助** > **查找操作** 并搜索 `Registry`。
1. 找到或搜索 `ide.browser.jcef.sandbox.enable`。
1. 清除复选框以禁用此设置。
1. 关闭注册表对话框。
1. 重启您的 IDE。
1. 在顶部栏中，转到 **帮助** > **查找操作** 并搜索 `Choose Boot Java Runtime for the IDE`。
1. 选择与当前 IDE 版本相同的引导 Java 运行时版本，但需捆绑 JCEF：
   ![JCEF 支持的运行时示例](img/jcef_supporting_runtime_example_v17_3.png)
1. 重启您的 IDE。

<a id="required-information-for-support"></a>

## 支持所需的信息

在联系支持之前，请确保已安装最新的极狐GitLab Duo 插件。所有版本均可在 [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/22325-gitlab-duo/versions) 的 **版本** 选项卡中找到。

从受影响的用户那里收集以下信息，并在您的错误报告中提供：

1. 向用户显示的错误消息。
1. 诊断和日志。选择以下方法之一：
   - 自动（推荐）：
     - 运行 `GitLab: Export Diagnostics Bundle` 快速操作。适用于极狐GitLab Duo 插件 3.27.0 或更高版本。
     - 这会将包含 IDE 日志和诊断的 zip 文件下载到您指定的位置。
   - 手动：
     - 启用并收集[调试日志](#enable-debug-mode)
     - 启用并收集 [Language Server 调试日志](#enable-gitlab-language-server-debug-logs)
     - 捕获[日志输出](#get-debug-logs)
     - 从快速操作菜单运行 `GitLab: Diagnostics` 并复制 Markdown 输出
1. 描述影响范围。有多少用户受到影响？
1. 描述如何重现错误。如果可能，请附上屏幕录制。
1. 描述其他极狐GitLab Duo 功能如何受到影响：
   - 极狐GitLab 快速聊天是否正常工作？
   - 代码建议是否正常工作？
1. 执行扩展隔离测试。尝试禁用（或卸载）所有其他扩展，以确定是否是其他扩展导致的问题。这有助于确定问题出在我们的扩展还是外部来源。