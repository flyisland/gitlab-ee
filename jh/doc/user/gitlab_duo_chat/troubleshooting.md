---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo Chat 故障排除
---

使用极狐GitLab Duo Chat 时，您可能会遇到以下问题。

<a id="the-gitlab-duo-chat-button-is-not-displayed"></a>

## 未显示**极狐GitLab Duo Chat** 按钮

如果界面右上角未显示该按钮，
请确保已[启用](../gitlab_duo/turn_on_off.md)极狐GitLab Duo Chat。

在[已禁用极狐GitLab Duo 功能的群组和项目](../gitlab_duo/turn_on_off.md)中，不会显示**极狐GitLab Duo Chat** 按钮。

启用极狐GitLab Duo Chat 后，该按钮可能需要几分钟才会出现。

如果这样仍无法解决，您还可以查看以下故障排除文档：

- [极狐GitLab Duo 代码建议](../project/repository/code_suggestions/troubleshooting.md)。
- [VS Code](../../editor_extensions/visual_studio_code/troubleshooting.md)。
- [Microsoft Visual Studio](../../editor_extensions/visual_studio/visual_studio_troubleshooting.md)。
- [JetBrains IDE](../../editor_extensions/jetbrains_ide/jetbrains_troubleshooting.md)。
- [Neovim](../../editor_extensions/neovim/neovim_troubleshooting.md)。
- [Eclipse](../../editor_extensions/eclipse/troubleshooting.md)。
- [故障排除极狐GitLab Duo](../gitlab_duo/troubleshooting.md)。
- [故障排除极狐GitLab Duo 自部署版本](../../administration/gitlab_duo_self_hosted/troubleshooting.md)。

<a id="error-m2000"></a>

## `Error M2000`

您可能会收到如下错误：
`I'm sorry, I couldn't find any documentation to answer your question. Error code: M2000`。

当 Chat 无法找到相关文档来回答您的问题时，会出现此错误。如果搜索查询与任何可用文档都不匹配，或者文档搜索功能出现问题，就可能发生这种情况。

请重试，或参阅[极狐GitLab Duo Chat 最佳实践文档](best_practices.md)来优化您的问题。

<a id="error-m3002"></a>

## `Error M3002`

您可能会收到如下错误：
`I am sorry, I cannot access the information you are asking about. A group or project owner has turned off Duo features in this group or project. Error code: M3002`。

当您询问属于已[关闭](../gitlab_duo/turn_on_off.md)极狐GitLab Duo 的项目或群组的条目时，会出现此错误。

如果未开启极狐GitLab Duo，则极狐GitLab Duo Chat 无法处理该群组或项目中条目（如议题、史诗和合并请求）的相关信息。

<a id="error-m3003"></a>

## `Error M3003`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. You might want to try again. You could also be getting this error because the items you're asking about either don't exist, you don't have access to them, or your session has expired. Error code: M3003`。

出现此错误的情况包括：

- 您向极狐GitLab Duo Chat 询问您无权访问的条目（如议题、史诗和合并请求），或询问不存在的条目。
- 您的会话已过期。

请重试，并询问您有权访问的条目。如果问题仍然存在，可能是由于会话已过期。要继续使用极狐GitLab Duo Chat，请重新登录。有关更多信息，请参阅[控制极狐GitLab Duo 可用性](../gitlab_duo/turn_on_off.md)。

<a id="error-m3004"></a>

## `Error M3004`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. You do not have access to GitLab Duo Chat. Error code: M3004`。

当您尝试访问极狐GitLab Duo Chat 但不具备所需访问权限时，会出现此错误。

请确保您拥有[使用极狐GitLab Duo Chat 的权限](../gitlab_duo/turn_on_off.md)。

<a id="error-m3005"></a>

## `Error M3005`

您可能会收到如下错误：
`I'm sorry, this question is not supported in your Duo Pro subscription. You might consider upgrading to Duo Enterprise. Error code: M3005`。

当您尝试访问极狐GitLab Duo Chat 中未包含在您的极狐GitLab Duo 订阅层级中的工具时，会出现此错误。

请确保您的[极狐GitLab Duo 订阅层级](https://about.gitlab.com/gitlab-duo/#pricing)包含所选的工具。

<a id="error-m3006"></a>

## `Error M3006`

您可能会收到如下错误：
`I'm sorry, you don't have the GitLab Duo subscription required to use Duo Chat. Please contact your administrator. Error code: M3006`。

当您的极狐GitLab Duo 订阅不包含极狐GitLab Duo Chat 时，会出现此错误。

请确保您的[极狐GitLab Duo 订阅层级](https://about.gitlab.com/gitlab-duo/#pricing)包含极狐GitLab Duo Chat。

如果您的订阅层级已包含极狐GitLab Duo Chat，但仍看到此错误，请检查您是否在用户偏好设置中选择了[默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。当您未配置默认极狐GitLab Duo 命名空间时，可能会遇到错误 M3006，而不是[错误 G3002](#error-g3002)。

<a id="error-m4000"></a>

## `Error M4000`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. Please try again. Error code: M4000`。

当处理斜杠命令请求期间出现意外问题时，会出现此错误。请重试您的请求。如果问题仍然存在，请确保您的命令语法正确。

有关斜杠命令的更多信息，请参阅文档：

- [/tests](examples.md#write-tests-in-the-ide)
- [/refactor](examples.md#refactor-code-in-the-ide)
- [/fix](examples.md#fix-code-in-the-ide)
- [/explain](examples.md#explain-selected-code)

<a id="error-m4001"></a>

## `Error M4001`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. Please try again. Error code: M4001`。

当查找完成您的请求所需的信息出现问题时，会出现此错误。请重试您的请求。

<a id="error-m4002"></a>

## `Error M4002`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. Please try again. Error code: M4002`。

当回答[与 CI/CD 相关的问题](examples.md#ask-about-cicd)出现问题时，会出现此错误。请重试您的请求。

<a id="error-m4003"></a>

## `Error M4003`

您可能会收到如下错误：`This command is used for explaining vulnerabilities and can only be invoked from a vulnerability detail page.` 或
`Vulnerability Explanation currently only supports vulnerabilities reported by SAST. Error code: M4003`。

当使用 [`Explain Vulnerability`](examples.md#explain-a-vulnerability) 功能出现问题时，会出现此错误。

<a id="error-m4004"></a>

## `Error M4004`

您可能会收到如下错误：
`This resource has no comments to summarize`。

当使用 `Summarize Discussion` 功能出现问题时，会出现此错误。

<a id="error-m4005"></a>

## `Error M4005`

您可能会收到如下错误：`There is no job log to troubleshoot.` 或 `This command is used for troubleshooting jobs and can only be invoked from a failed job log page.`。

当使用 [`Troubleshoot job`](examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) 功能出现问题时，会出现此错误。

<a id="error-m5000"></a>

## `Error M5000`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. Please try again. Error code: M5000`。

当处理与条目（如议题、史诗和合并请求）相关的内容出现问题时，会出现此错误。请重试您的请求。

<a id="error-a1000"></a>

## `Error A1000`

您可能会收到如下错误：
`I'm sorry, I couldn't respond in time. Please try again. Error code: A1000`。

当处理过程中出现超时时，会出现此错误。请重试您的请求。

<a id="error-a1001"></a>

## `Error A1001`

您可能会收到如下错误：
`I'm sorry, I can't generate a response. Please try again. Error code: A1001`。

此错误表示处理您请求的 AI 服务遇到了问题。

一些可能的原因：

- 极狐GitLab 代码中的缺陷导致的客户端错误。
- HTTP 请求未到达 AI 网关。

[已有一个议题](https://gitlab.com/gitlab-org/gitlab/-/issues/479465)用于更清晰地说明该错误的原因。

要解决此问题，请重试您的请求。

如果错误仍然存在，请使用 `/new` 或 `/reset` 命令开始新对话。如果问题仍然存在，请向极狐GitLab 支持团队报告该问题。

<a id="gitlab-duo-self-hosted"></a>

### 极狐GitLab Duo 自部署版本

如果您在使用极狐GitLab Duo 自部署版本的 Chat 时遇到此错误，说明连接 AI 网关时出现问题。

要解决此问题，请使用[自部署调试脚本](../../administration/gitlab_duo_self_hosted/troubleshooting.md#use-debugging-scripts)检查是否可以从极狐GitLab 实例访问 AI 网关，以及其是否按预期工作。

如果问题仍然存在，请向极狐GitLab 支持团队报告该问题。

<a id="error-a1002"></a>

## `Error A1002`

您可能会收到如下错误：
`I'm sorry, I couldn't respond in time. Please try again. Error code: A1002`。

当 AI 网关未返回任何事件，或极狐GitLab 无法解析这些事件时，会出现此错误。

请重试您的请求，或检查 [AI 网关日志](../../administration/gitlab_duo_self_hosted/logging.md)中是否有任何错误。

<a id="error-a1003"></a>

## `Error A1003`

您可能会收到如下错误：
`I'm sorry, I couldn't respond in time. Please try again. Error code: A1003`。

当从 AI 网关流式传输响应失败时，会出现此错误。请重试您的请求。

如果较长的响应中途停止且没有报错，可能是代理、负载均衡器或防火墙切断了连接。有关更多信息，请参阅：

- [允许从极狐GitLab 实例到极狐GitLab Duo 的出站连接](../../administration/gitlab_duo/configure/_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)。
- 针对极狐GitLab Duo 自部署版本的[响应被截断且没有报错](../../administration/gitlab_duo_self_hosted/troubleshooting.md#responses-are-truncated-without-an-error)。

<a id="gitlab-duo-self-hosted-1"></a>

### 极狐GitLab Duo 自部署版本

如果您在使用极狐GitLab Duo 自部署版本的 Chat 时遇到此问题，请检查流式传输是否正常工作：

1. 在 AI 网关容器中，运行以下命令：

   ```shell
   curl --request 'POST' \
   'http://localhost:5052/v2/chat/agent' \
   --header 'accept: application/json' \
   --header 'Content-Type: application/json' \
   --header 'x-gitlab-enabled-feature-flags: expanded_ai_logging' \
   --data '{
     "messages": [
       {
         "role": "user",
         "content": "Hello",
         "context": null,
         "current_file": null,
         "additional_context": []
       }
     ],
     "model_metadata": {
       "provider": "custom_openai",
       "name": "mistral",
       "endpoint": "<change here>",
       "api_key": "<change here>",
       "identifier": "<change here>"
     },
     "unavailable_resources": [],
     "options": {
       "agent_scratchpad": {
         "agent_type": "react",
         "steps": []
       }
     }
   }'
   ```

   如果流式传输正常工作，应显示分块响应。如果不正常，
   响应将为空。

1. 要检查这是否是模型部署问题，请查看
   [AI 网关日志](../../administration/gitlab_duo_self_hosted/logging.md)
   中的具体错误消息。

1. 要验证连接，请在 AI 网关容器中设置
   `AIGW_CUSTOM_MODELS__DISABLE_STREAMING` 环境变量以禁用流式传输：

   ```shell
   docker run .... -e AIGW_CUSTOM_MODELS__DISABLE_STREAMING=true ...
   ```

<a id="error-a1004"></a>

## `Error A1004`

您可能会收到如下错误：
`I'm sorry, I couldn't respond in time. Please try again. Error code: A1004`。

当 AI 网关进程中发生错误时，会出现此错误。请重试您的请求。

<a id="error-a1005"></a>

## `Error A1005`

您可能会收到如下错误：
`I'm sorry, you've entered too many prompts. Please run /clear or /reset before asking the next question. Error code: A1005`。

当提示的长度超过 LLM 的最大 token 限制时，会出现此错误。请使用 `/new` 命令开始新对话，然后重试您的请求。

<a id="error-a1006"></a>

## `Error A1006`

您可能会收到如下错误：
`I'm sorry, Duo Chat agent reached the limit before finding an answer for your question. Please try a different prompt or clear your conversation history with /clear. Error code: A1006`。

当 ReAct Agent 未能为您的查询找到解决方案时，会出现此错误。请尝试其他提示，或使用 `/new` 或 `/reset` 开始新对话。

<a id="error-a1007"></a>

## `Error A1007`

您可能会收到如下错误：`There was an error processing your request. Please try again or contact support if the issue persists. Error code: A1007`。

当在极狐GitLab Duo Agent Platform 中处理您的请求时遇到意外错误，会出现此错误。

<a id="error-a1008"></a>

## `Error A1008`

您可能会收到如下错误：`There was an error processing your request. Please try again or contact support if the issue persists. Error code: A1008`。

当您的请求提交到极狐GitLab Duo Agent Platform 所使用的上游 LLM 提供商时出现错误，会出现此错误。

<a id="error-a6000"></a>

## `Error A6000`

您可能会收到如下错误：
`I'm sorry, I couldn't respond in time. Please try a more specific request or enter /clear to start a new chat. Error code: A6000`。

这是一个回退错误，在极狐GitLab Duo Chat 出现问题时发生。请尝试更具体的请求，输入 `/new` 开始新会话，或留下反馈以帮助我们改进。

<a id="error-a9999"></a>

## `Error A9999`

您可能会收到如下错误：
`I'm sorry, I couldn't respond in time. Please try again. Error code: A9999`。

当 ReAct Agent 中发生未知错误时，会出现此错误。请重试您的请求。

如果问题仍然存在，请[向极狐GitLab 支持团队报告该问题](https://gitlab.cn/support)。

<a id="error-g3001"></a>

## `Error G3001`

您可能会收到如下错误：
`I'm sorry, but answering this question requires a different Duo subscription. Please contact your administrator.`。

当您的订阅中不提供极狐GitLab Duo Chat 时，会出现此错误。请尝试其他请求，并联系您的管理员。

<a id="error-g3002"></a>

## `Error G3002`

您可能会收到如下错误：
`I'm sorry, you have not selected a default GitLab Duo namespace. Please select a default GitLab Duo namespace in your user preferences.`。

当您属于多个极狐GitLab Duo 命名空间，或在本地处理未配置极狐GitLab 远程仓库的项目时，会出现此错误。

要解决此问题，请[设置默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

<a id="links-in-chat-responses-are-not-selectable"></a>

## Chat 响应中的链接不可选择

极狐GitLab Duo Chat 不会在响应中将外部网站和第三方域名的 URL 显示为可选择链接。

Chat 会将这些类型的 URL 转换为仅显示链接文本的代码格式文本。目标 URL 不会显示。

此限制有助于保护用户免受 AI 响应中可能生成的有害链接的影响。

Chat 会在响应中将以下类型的链接显示为可选择链接：

- 指向 `docs.gitlab.com` 上 GitLab 文档的链接。
- 指向 `gitlab.com` 的链接，包括但不限于 GitLab 项目、议题和合并请求。
- 您的极狐GitLab 实例中的相对 URL。

<a id="issues-specific-to-gitlab-duo-agentic-chat"></a>

## 极狐GitLab Duo Agentic Chat 特有的问题

<a id="not-enough-gitlab-credits"></a>

### 极狐GitLab Credits 不足

您可能会因为极狐GitLab Credits 已用完而失去对 Chat 的访问权限。

要解决此问题，您可以执行以下任一操作：

- [购买更多极狐GitLab Credits](../../subscriptions/gitlab_credits.md#buy-gitlab-credits)。
- 切换到非 Agentic Chat。切换后会开始新对话。
  您仍可查看之前的 Agentic Chat 对话，但该对话为只读。

<a id="slow-response-times"></a>

### 响应时间缓慢

Agentic Chat 在处理和响应请求时可能比非 Agentic Chat 更慢。

出现此问题是因为 Agentic Chat 会进行多次 API 调用以收集信息，因此响应可能需要更长时间。

<a id="limited-permissions"></a>

### 权限受限

Agentic Chat 可以访问您的极狐GitLab 用户有权访问的相同资源。如果您发现 Agentic Chat 无法访问回答您请求所需的资源，请检查您的[用户权限](../permissions.md)。

<a id="search-limitations"></a>

### 搜索限制

Agentic Chat 使用基于关键词的搜索，而不是语义搜索。Agentic Chat 可能会遗漏不包含搜索所用确切关键词的相关内容。

<a id="header-mismatch-issue"></a>

## 请求头不匹配问题

您可能会收到如下错误：`I'm sorry, I can't generate a response. Please try again`，且没有具体的错误代码。

请检查 Sidekiq 日志，看是否能找到以下错误：`Header mismatch 'X-Gitlab-Instance-Id'`。

如果看到此错误，要解决此问题，请联系极狐GitLab 支持团队，请他们向您发送新的许可证激活码。

有关更多信息，请参阅[议题 103](https://gitlab.com/gitlab-com/enablement-sub-department/section-enable-request-for-help/-/issues/103)。

<a id="check-the-health-of-the-cloud-connector"></a>

## 检查 Cloud Connector 的运行状况

我们创建了一个脚本，用于验证与 Cloud Connector 相关的各种组件的状态，例如：

- 访问数据
- 令牌
- 许可证
- 主机连接
- 功能可访问性

您可以在调试模式下运行此脚本，以获得更详细的输出并生成报告文件。

1. 通过 SSH 登录到您的单节点实例并下载该脚本：

   ```shell
   wget https://gitlab.com/gitlab-org/gitlab/-/snippets/3734617/raw/main/health_check.rb
   ```

1. 使用 Rails Runner 执行该脚本。

   请确保使用该脚本的完整路径。

   ```ruby
   Usage: gitlab-rails runner full_path/to/health_check.rb
          --debug                     Enable debug mode
          --output-file <file_path>   Write a report to a specified file
          --username <username>       Provide a username to test seat assignments
          --skip [CHECK]              Skip specific checks (options: access_data, token, license, host, features, end_to_end)
   ```
