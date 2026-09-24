---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Troubleshooting tips for common problems in Code Suggestions.
title: 排查 Code Suggestions 问题
---

使用极狐GitLab Duo Code Suggestions 时，你可能会遇到以下问题。

你可以运行 [健康检查](../../../gitlab_duo/turn_on_off.md) 来测试你的实例是否符合运行 Code Suggestions 的要求。

有关排查极狐GitLab Duo 问题的更多信息，请参考：

- [排查极狐GitLab Duo 问题](../../../gitlab_duo/troubleshooting.md)。
- [排查极狐GitLab Duo Chat 问题](../../../gitlab_duo_chat/troubleshooting.md)。
- [排查私有化部署的极狐GitLab Duo 问题](../../../../administration/gitlab_duo_self_hosted/troubleshooting.md)。

<a id="suggestions-are-not-displayed"></a>

## 建议未显示

如果建议未显示，请确保你：

- 已[正确配置极狐GitLab Duo](../../../gitlab_duo/turn_on_off.md)。
- 正在使用[受支持的语言](supported_extensions.md#supported-languages-by-ide)
  和[编辑器扩展](supported_extensions.md#supported-editor-extensions)。
- 已[正确配置你的编辑器扩展](set_up.md#configure-editor-extension)。

如果这时建议仍未显示，请尝试以下故障排除步骤。

<a id="code-suggestions-returns-a-401-error"></a>

## Code Suggestions 返回 401 错误

Code Suggestions 依赖于一个许可证令牌，该令牌用于将你的订阅信息与极狐GitLab [同步](../../../../administration/license.md)。

当头显过期时，Code Suggestions 会返回状态为 `401` 的以下错误：

```plaintext
Token validation failed in Language Server:
(Failed to check token: Error: Fetching Information about personal access token
```

如果极狐GitLab 能够访问云服务器，请尝试
[手动同步你的许可证](../../../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。

<a id="authentication-troubleshooting"></a>

## 鉴权排查

问题可能源于近期的鉴权变更，特别是令牌系统。要解决这个问题：

1. 从你的极狐GitLab 账户设置中移除现有的个人访问令牌。
1. 使用 OAuth 重新授权你的极狐GitLab 账户。
1. 使用不同的文件扩展名测试 Code Suggestions 功能，以验证问题是否已解决。

<a id="error-422-no-default-gitlab-duo-namespace"></a>

## 错误 422：无默认极狐GitLab Duo 命名空间

你可能会收到一个错误，提示 `Code Suggestions 无法检测到该项目的命名空间。要继续，请在你的用户偏好设置中设置一个默认的极狐GitLab Duo 命名空间。`

当你属于多个极狐GitLab Duo 命名空间，或者在本地处理一个未配置极狐GitLab 远程的项目时，会出现此问题。

要解决此问题，请 [设置一个默认的极狐GitLab Duo 命名空间](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

<a id="disable-streaming-of-code-generation-results"></a>

## 关闭代码补全结果流的流式传输

默认情况下，代码补全功能会流式传输 AI 生成的代码。流式传输是将生成的代码逐步发送到你的编辑器，而不是等待整个代码片段生成完毕。这能够提供更具交互性和响应性的体验。

如果你希望在代码生成结果完整时再查看，可以关闭流式传输。但关闭流式传输可能会导致你感觉代码生成请求的响应时间变长。要关闭流式传输：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 在右上角，选择 **打开设置 (Open Settings (JSON))** 以编辑你的 `settings.json` 文件：

   ![The icons in the upper-right corner of VS Code, including 'Open Settings.'](img/open_settings_v17_5.png)
1. 在你的 `settings.json` 文件中，添加下面这行，或者如果已存在则将其设置为 `false`：

   ```json
   "gitlab.featureFlags.streamCodeGenerations": false,
   ```

1. 保存你的更改。

<a id="error-direct-connection-fails"></a>

## 错误：直连失败

{{< history >}}

- 直连模式在极狐GitLab 17.2 中引入。

{{< /history >}}

为了降低延迟，极狐GitLab for VS Code 扩展会尝试将补全建议请求直接发送至极狐GitLab Cloud Connector，从而绕过极狐GitLab 实例。此网络连接不会使用 VS Code 扩展的代理和证书设置。

如果你的极狐GitLab 实例不支持直连，或者你的网络阻止扩展连接到
极狐GitLab Cloud Connector，你可能会在日志中看到以下警告：

```plaintext
无法从极狐GitLab 实例获取直连详情。
代码补全建议请求将被发送到极狐GitLab 实例。
```

此错误意味着你的实例不支持直连，或者配置有误。

如果你看到此错误，则表示扩展无法连接到极狐GitLab Cloud Connector，并已恢复使用你的极狐GitLab 实例：

```plaintext
代码建议的直连连接失败。
代码补全建议请求将被发送到你的极狐GitLab 实例。
```

通过极狐GitLab 实例的间接连接大约慢 100 毫秒，但在其他方面功能相同。此问题通常是由网络连接问题引起的，例如局域网防火墙或代理设置。

<a id="error-unable-to-find-valid-certification-path-to-requested-target"></a>

## 错误：`unable to find valid certification path to requested target`

极狐GitLab Duo 插件在连接到你的极狐GitLab 实例之前会验证 TLS 证书信息。
你可以 [为 Code Suggestions 添加自定义 SSL 证书](set_up.md#add-a-custom-certificate-for-code-suggestions)。

<a id="error-failed-to-check-token-in-jetbrains-ides"></a>

## JetBrains IDE 中的错误提示：`Failed to check token`

当传递给极狐GitLab Language Server 进程的连接实例 URL 和身份验证令牌无效时，会出现此错误。要重新启用 Code Suggestions：

1. 在你的 IDE 中，选择顶部栏中的 IDE 名称，然后选择 **设置 (Settings)**。
1. 在左侧边栏中，选择 **工具 (Tools)** > **极狐GitLab Duo**。
1. 在 **连接 (Connection)** 下，选择 **验证设置 (Verify setup)**。
1. 根据需要更新你的 **连接 (Connection)** 详细信息。
1. 选择 **验证设置 (Verify setup)**，并确认身份验证成功。
1. 选择 **确定 (OK)** 或 **保存 (Save)**。

<a id="latency-issues-with-code-completion"></a>

## 代码补全的延迟问题

如果你被分配到一个为代码补全选择了特定模型的项目中：

- 你的 IDE 扩展会禁用[与 AI Gateway 的直连](../../../../administration/gitlab_duo/gateway.md#region-support)
- 代码补全请求将先通过极狐GitLab，然后由其选择指定模型来响应这些请求。

这可能会导致代码补全请求出现更高的延迟。

