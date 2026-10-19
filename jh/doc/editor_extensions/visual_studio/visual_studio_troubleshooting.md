---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to address common issues for the 极狐 GitLab for Visual Studio extension.
title: 排查 极狐 GitLab Visual Studio 扩展的问题
---

如果本页面上的步骤无法解决您的问题，请查看扩展项目中的
[开放议题列表](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-visual-studio-extension/-/issues/?sort=created_date&state=opened&first_page_size=100)
。如果某个议题与您的问题匹配，请更新该议题。
如果没有议题与您的问题匹配，请 [创建新议题](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-visual-studio-extension/-/issues/new)。

<a id="gitlab-duo-features-do-not-appear"></a>

## 极狐 GitLab Duo 功能未显示

如果在 Visual Studio 中无法使用 极狐 GitLab Duo Chat 或 极狐 GitLab Duo 代码建议：

- 确保您满足 [先决条件](setup.md#configure-gitlab-duo) 且必要设置已开启。
- 确保 [管理员模式已禁用](../../administration/settings/sign_in_restrictions.md#turn-off-admin-mode-for-your-session)。
- 检查 极狐 GitLab Duo Agentic Chat 是否已启用：
  1. 在 Visual Studio 中，转到 **工具** > **选项** > **极狐 GitLab**。
  1. 在 **极狐 GitLab** 下，选择 **常规**。
  1. 检查 **启用 Agentic 模式 Duo Chat** 是否设置为 **真**。
- 检查 代码建议 是否已启用：
  1. 在 Visual Studio 中，在底部状态栏上，检查 极狐 GitLab 图标的工具提示以了解该功能的当前状态。
  1. 如果 代码建议 未启用，在顶部栏中，选择 **扩展** > **极狐 GitLab** > **切换代码建议**。

有关 代码建议 的支持，请参阅 [排查代码建议问题](../../user/project/repository/code_suggestions/troubleshooting.md#microsoft-visual-studio-troubleshooting)。

<a id="network-issues"></a>

## 网络问题

如果您在日志中看到来自 极狐 GitLab Duo 的 `HTTP/1.1` 响应，而不是 `/-/cable` WebSocket 端点，则您的 WebSocket 连接可能被阻止。

您的 极狐 GitLab 实例必须允许来自 IDE 客户端的入站 WebSocket 连接。
如果您怀疑是这个问题，请让您的网络管理员
[允许 WebSocket 流量访问您的极狐 GitLab 实例](../../administration/gitlab_duo/configure/_index.md#allow-inbound-connections-from-clients-to-the-gitlab-instance)。

<a id="view-more-logs"></a>

## 查看更多日志

更多日志可在 **极狐 GitLab 扩展输出** 窗口中找到：

1. 在 Visual Studio 中，在顶部栏中，转到 **工具** > **选项** 菜单。
1. 找到 **极狐 GitLab** 选项，并将 **日志级别** 设置为 **调试**。
1. 转到 **视图** > **输出** 以打开扩展日志。在下拉列表中，选择 **极狐 GitLab 扩展** 作为日志过滤器。
1. 验证调试日志是否包含类似的输出：

   ```shell
   GetProposalManagerAsync: 代码建议已启用。ContentType (csharp) 或文件扩展名 (cs) 受支持。
   GitlabProposalSourceProvider.GetProposalSourceAsync
   ```

<a id="view-activity-log"></a>

### 查看活动日志

如果您的扩展未加载或崩溃，请检查活动日志是否有错误。
您的活动日志位于以下位置：

```plaintext
C:\Users\WINDOWS_USERNAME\AppData\Roaming\Microsoft\VisualStudio\VS_VERSION\ActivityLog.xml
```

替换目录路径中的这些值：

- `WINDOWS_USERNAME`：您的 Windows 用户名。
- `VS_VERSION`：您的 Visual Studio 安装版本。

<a id="required-information-for-support"></a>

## 支持所需信息

在联系支持之前，请确保已安装最新的 极狐 GitLab 扩展。Visual Studio 应自动更新到最新版本的扩展。

从受影响的用户那里收集此信息，并在您的错误报告中提供：

1. 向用户显示的错误消息。
1. 工作流和语言服务器日志：
   1. [启用调试日志](#view-more-logs)。
   1. [检索日志文件](#view-activity-log)。
1. 诊断输出：
   1. 打开 Visual Studio 后，在顶部横幅上，选择 **帮助** > **关于 Microsoft Visual Studio**。
   1. 在对话框中，选择 **复制信息** 以将此部分所需的所有信息复制到剪贴板。
1. 系统详细信息：
   1. 打开 Visual Studio 后，在顶部横幅上，选择 **帮助** > **关于 Microsoft Visual Studio**。
   1. 在对话框中，选择 **系统信息** 以查看更详细的信息。
   1. 对于 **OS type and version**：复制 `OS Name` 和 `Version`。
   1. 对于 **Machine specifications (CPU, RAM)**：复制 `Processor` 和 `Installed Physical Memory (RAM)` 部分。
1. 描述影响范围。有多少用户受影响？
1. 描述如何重现错误。如果可能，请包括屏幕录制。
1. 描述其他 极狐 GitLab Duo 功能如何受影响：
   - 代码建议 是否正常工作？
1. 执行扩展隔离测试。尝试禁用（或卸载）所有其他扩展，以确定是否是另一个扩展导致了问题。这有助于确定问题是在我们的扩展中，还是来自外部来源。
